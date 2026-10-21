import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../auth.dart';
import '../config.dart';
import '../l10n/app_localizations.dart';
import '../main_tabs_page.dart';
import '../user_timezone.dart';

const _blue = Color(0xFF0866EB),
    _ink = Color(0xFF0C2032),
    _muted = Color(0xFF627183),
    _border = Color(0xFFE5EAF1),
    _background = Color(0xFFFAFBFD);
const _headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json'
};
String _date(BuildContext context, dynamic value) {
  try {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_Hm()
        .format(UserTimeZone.at(DateTime.parse(value.toString())));
  } catch (_) {
    return '';
  }
}

String _status(AppLocalizations loc, dynamic status) => switch (status) {
      'open' => loc.supportStatusOpen,
      'pending' => loc.supportStatusPending,
      'in_progress' => loc.supportInProgress,
      'resolved' => loc.supportResolved,
      'closed' => loc.supportStatusClosed,
      _ => loc.supportStatusPending
    };
Color _statusColor(dynamic status) => switch (status) {
      'open' => _blue,
      'pending' || 'in_progress' => const Color(0xFFAD6A0B),
      'resolved' => const Color(0xFF008577),
      _ => _muted
    };
String _priority(AppLocalizations loc, dynamic priority) => switch (priority) {
      'low' => loc.supportPriorityLow,
      'high' => loc.supportPriorityHigh,
      'urgent' => loc.supportPriorityUrgent,
      _ => loc.supportPriorityMedium
    };
String _failure(http.Response response, String fallback) {
  try {
    final body = jsonDecode(response.body);
    if (body['errors'] is Map) {
      for (final value in (body['errors'] as Map).values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
      }
    }
    return body['message']?.toString() ?? fallback;
  } catch (_) {
    return fallback;
  }
}

Map<String, dynamic>? _ticketData(http.Response response) {
  try {
    final data = jsonDecode(response.body)['data'];
    return data is Map ? Map<String, dynamic>.from(data) : null;
  } catch (_) {
    return null;
  }
}

void _snack(BuildContext context, String message, {bool success = false}) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor:
            success ? const Color(0xFF008577) : const Color(0xFFCF354D),
        behavior: SnackBarBehavior.floating));
InputDecoration _field(String label) => InputDecoration(
    labelText: label,
    alignLabelWithHint: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border)));
Widget _badge(AppLocalizations loc, dynamic status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: .09),
        borderRadius: BorderRadius.circular(8)),
    child: Text(_status(loc, status),
        style: TextStyle(
            color: _statusColor(status),
            fontSize: 12,
            fontWeight: FontWeight.w600)));

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  AppLocalizations get loc => AppLocalizations.of(context);
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true, _creating = false;
  String? _error;
  String _filter = 'all';
  int _request = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchTickets();
    });
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const MainTabsPage(initialIndex: 0)));
    }
  }

  Future<void> _fetchTickets() async {
    if (!mounted) return;
    final version = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await authGet(
          Uri.parse('$apiBaseUrl/api/support/tickets'),
          headers: _headers);
      if (response.statusCode != 200) throw Exception();
      final data = jsonDecode(response.body)['data'];
      if (data is! List) throw const FormatException();
      if (mounted && version == _request) {
        setState(() {
          _tickets = data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && version == _request) {
        setState(() {
          _error = loc.supportLoadError;
          _loading = false;
        });
      }
    }
  }

  Future<void> _newTicket() async {
    if (_creating) return;
    _creating = true;
    final created = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: _background,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .94),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => const _NewTicketSheet());
    _creating = false;
    if (created == true && mounted) {
      setState(() => _filter = 'all');
      _snack(context, loc.supportCreateSuccess, success: true);
      await _fetchTickets();
    }
  }

  void _openTicket(Map<String, dynamic> ticket) {
    final id = int.tryParse(ticket['id'].toString());
    if (id == null) return;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            _TicketDetailSheet(ticketId: id, onUpdated: _fetchTickets));
  }

  Widget _message(String message, {bool retry = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(children: [
        Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(20)),
            child: Icon(retry ? Icons.cloud_off_outlined : Icons.forum_outlined,
                color: _blue, size: 34)),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, height: 1.5)),
        if (retry) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
              onPressed: _fetchTickets,
              icon: const Icon(Icons.refresh),
              label: Text(loc.supportRetry))
        ]
      ]));
  Widget _card(Map<String, dynamic> ticket) => Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          key: ValueKey('ticket-${ticket['id']}'),
          onTap: () => _openTicket(ticket),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFEAF1FF),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: _blue,
                                  size: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    ticket['title']?.toString() ??
                                        loc.supportTicketDetail,
                                    style: const TextStyle(
                                        color: _ink,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('#${ticket['id']}',
                                    style: const TextStyle(
                                        color: _muted, fontSize: 12))
                              ])),
                          const Icon(Icons.chevron_right_rounded, color: _muted)
                        ]),
                    const SizedBox(height: 14),
                    Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _badge(loc, ticket['status']),
                          Text(_priority(loc, ticket['priority']),
                              style:
                                  const TextStyle(color: _muted, fontSize: 12))
                        ]),
                    const SizedBox(height: 12),
                    Text(
                        loc.supportMessagesMeta(
                            (ticket['message_count'] ?? 0).toString(),
                            _date(context,
                                ticket['updated_at'] ?? ticket['created_at'])),
                        style: const TextStyle(
                            color: _muted, fontSize: 12, height: 1.5)),
                  ]))));
  @override
  Widget build(BuildContext context) {
    final visible = _tickets.where((ticket) {
      final finished =
          ticket['status'] == 'closed' || ticket['status'] == 'resolved';
      return _filter == 'all' || (_filter == 'active' ? !finished : finished);
    }).toList();
    return Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: _ink,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded)),
            title: Text(loc.supportTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                  onPressed: _fetchTickets,
                  tooltip: loc.supportRefresh,
                  icon: const Icon(Icons.refresh_rounded))
            ]),
        body: SafeArea(
            child: RefreshIndicator(
                onRefresh: _fetchTickets,
                color: _blue,
                child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          sliver: SliverToBoxAdapter(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(loc.supportTitle,
                                    style: const TextStyle(
                                        color: _ink,
                                        fontSize: 30,
                                        height: 1.15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1)),
                                const SizedBox(height: 9),
                                Text(loc.supportSubtitle,
                                    style: const TextStyle(
                                        color: _muted,
                                        fontSize: 14,
                                        height: 1.5)),
                                const SizedBox(height: 20),
                                SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                        onPressed: _newTicket,
                                        icon: const Icon(Icons.add_rounded,
                                            size: 20),
                                        label: Text(loc.supportNewTicket),
                                        style: FilledButton.styleFrom(
                                            backgroundColor: _blue,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        14))))),
                                const SizedBox(height: 20),
                                Wrap(spacing: 8, runSpacing: 8, children: [
                                  for (final entry in {
                                    'all': loc.contactsAll,
                                    'active': loc.supportActive,
                                    'finished': loc.supportFinished
                                  }.entries)
                                    ChoiceChip(
                                        label: Text(entry.value),
                                        selected: _filter == entry.key,
                                        onSelected: (_) =>
                                            setState(() => _filter = entry.key),
                                        selectedColor: const Color(0xFFEAF1FF),
                                        labelStyle: TextStyle(
                                            color: _filter == entry.key
                                                ? _blue
                                                : _muted,
                                            fontWeight: FontWeight.w600),
                                        side: const BorderSide(color: _border),
                                        showCheckmark: false)
                                ]),
                              ]))),
                      if (_loading)
                        const SliverToBoxAdapter(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: _blue))))
                      else if (_error != null)
                        SliverToBoxAdapter(
                            child: _message(_error!, retry: true))
                      else if (visible.isEmpty)
                        SliverToBoxAdapter(
                            child: _message(_tickets.isEmpty
                                ? loc.supportEmpty
                                : loc.supportFilterEmpty))
                      else
                        SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList.separated(
                                itemCount: visible.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) => _card(visible[i]))),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ]))));
  }
}

class _NewTicketSheet extends StatefulWidget {
  const _NewTicketSheet();
  @override
  State<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<_NewTicketSheet> {
  final _title = TextEditingController(), _message = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;
  AppLocalizations get loc => AppLocalizations.of(context);
  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_saving || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final response = await authPost(
          Uri.parse('$apiBaseUrl/api/support/tickets'),
          headers: _headers,
          body: jsonEncode(
              {'title': _title.text.trim(), 'message': _message.text.trim()}));
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() => _saving = false);
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = _failure(response, loc.supportSendError));
      }
    } catch (_) {
      if (mounted) setState(() => _error = loc.supportSendError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_saving,
      child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
          child: SingleChildScrollView(
              child: Form(
                  key: _form,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: _border,
                                    borderRadius: BorderRadius.circular(4)))),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(
                              child: Text(loc.supportNewTicket,
                                  style: const TextStyle(
                                      color: _ink,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800))),
                          IconButton(
                              tooltip: loc.appointmentsClose,
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded))
                        ]),
                        const SizedBox(height: 8),
                        Text(loc.supportFormHint,
                            style: const TextStyle(color: _muted, height: 1.5)),
                        const SizedBox(height: 24),
                        TextFormField(
                            key: const ValueKey('support-title'),
                            controller: _title,
                            enabled: !_saving,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: _field(loc.supportTitleLabel),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? loc.supportCreateValidation
                                    : value.trim().length > 255
                                        ? loc.linksTextTooLong
                                        : null),
                        const SizedBox(height: 16),
                        TextFormField(
                            key: const ValueKey('support-message'),
                            controller: _message,
                            enabled: !_saving,
                            minLines: 4,
                            maxLines: 8,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: _field(loc.supportMessageLabel),
                            validator: (value) =>
                                (value?.trim().length ?? 0) < 5
                                    ? loc.supportMessageTooShort
                                    : null),
                        const SizedBox(height: 24),
                        if (_error != null) ...[
                          Text(_error!,
                              style: const TextStyle(color: Color(0xFFCF354D))),
                          const SizedBox(height: 16)
                        ],
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                                onPressed: _saving ? null : _send,
                                style: FilledButton.styleFrom(
                                    backgroundColor: _blue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14))),
                                icon: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Icon(Icons.send_outlined, size: 18),
                                label: Text(_saving
                                    ? loc.supportSending
                                    : loc.supportSend)))
                      ])))));
}

class _TicketDetailSheet extends StatefulWidget {
  final int ticketId;
  final Future<void> Function() onUpdated;
  const _TicketDetailSheet({required this.ticketId, required this.onUpdated});
  @override
  State<_TicketDetailSheet> createState() => _TicketDetailSheetState();
}

class _TicketDetailSheetState extends State<_TicketDetailSheet> {
  AppLocalizations get loc => AppLocalizations.of(context);
  Map<String, dynamic>? _ticket;
  bool _loading = true, _replying = false, _closing = false;
  String? _error, _replyError;
  final _reply = TextEditingController();
  bool get _busy => _replying || _closing;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await authGet(
          Uri.parse('$apiBaseUrl/api/support/tickets/${widget.ticketId}'),
          headers: _headers);
      final data = _ticketData(response);
      if (response.statusCode != 200 || data == null) throw Exception();
      if (mounted) setState(() => _ticket = data);
    } catch (_) {
      if (mounted) setState(() => _error = loc.supportLoadError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    if (_busy || _ticket?['status'] == 'closed') return;
    if (_reply.text.trim().length < 2) {
      setState(() => _replyError = loc.supportReplyTooShort);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _replying = true;
      _replyError = null;
    });
    try {
      final response = await authPost(
          Uri.parse('$apiBaseUrl/api/support/tickets/${widget.ticketId}/reply'),
          headers: _headers,
          body: jsonEncode({'message': _reply.text.trim()}));
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _reply.clear();
        final data = _ticketData(response);
        if (data != null) {
          setState(() => _ticket = data);
        } else {
          await _load();
        }
        await widget.onUpdated();
      } else {
        setState(() => _replyError = _failure(response, loc.supportSendError));
      }
    } catch (_) {
      if (mounted) setState(() => _replyError = loc.supportSendError);
    } finally {
      if (mounted) setState(() => _replying = false);
    }
  }

  Future<void> _close() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(loc.supportCloseTicket),
                content: Text(loc.supportCloseConfirm),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(loc.customersCancel)),
                  FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(loc.supportCloseTicket))
                ]));
    if (confirmed != true || !mounted || _busy) return;
    setState(() => _closing = true);
    try {
      final response = await authPost(
          Uri.parse('$apiBaseUrl/api/support/tickets/${widget.ticketId}/close'),
          headers: _headers);
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() => _ticket =
            _ticketData(response) ?? {...?_ticket, 'status': 'closed'});
        await widget.onUpdated();
      } else {
        _snack(context, _failure(response, loc.supportCloseError));
      }
    } catch (_) {
      if (mounted) _snack(context, loc.supportCloseError);
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  Widget _message(Map<String, dynamic> message) {
    final sender = message['sender'] is Map
        ? Map<String, dynamic>.from(message['sender'])
        : <String, dynamic>{};
    final own = sender['is_owner'] == true;
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Align(
            alignment: own ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
                widthFactor: .94,
                child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: own ? const Color(0xFFEAF1FF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: own ? const Color(0xFFD4E3FF) : _border)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              own
                                  ? loc.supportSenderYou
                                  : sender['name']?.toString() ??
                                      loc.supportSenderSupport,
                              style: TextStyle(
                                  color: own ? _blue : _ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(message['message']?.toString() ?? '',
                              style: const TextStyle(color: _ink, height: 1.5)),
                          const SizedBox(height: 10),
                          Text(_date(context, message['created_at']),
                              style:
                                  const TextStyle(color: _muted, fontSize: 11))
                        ])))));
  }

  @override
  Widget build(BuildContext context) {
    final closed = _ticket?['status'] == 'closed';
    final messages =
        _ticket?['messages'] is List ? _ticket!['messages'] as List : [];
    return PopScope(
        canPop: !_busy,
        child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: FractionallySizedBox(
                heightFactor: .94,
                child: Material(
                    color: _background,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    clipBehavior: Clip.antiAlias,
                    child: SafeArea(
                        top: false,
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                              child: Row(children: [
                                Expanded(
                                    child: Text(loc.supportTicketDetail,
                                        style: const TextStyle(
                                            color: _ink,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800))),
                                IconButton(
                                    tooltip: loc.appointmentsClose,
                                    onPressed: _busy
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.close_rounded,
                                        color: _muted))
                              ])),
                          Expanded(
                              child: _loading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: _blue))
                                  : _error != null
                                      ? SingleChildScrollView(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(children: [
                                            Text(_error!,
                                                textAlign: TextAlign.center),
                                            const SizedBox(height: 16),
                                            OutlinedButton.icon(
                                                onPressed: _load,
                                                icon: const Icon(Icons.refresh),
                                                label: Text(loc.supportRetry))
                                          ]))
                                      : ListView(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 8, 20, 16),
                                          children: [
                                              Text(
                                                  _ticket?['title']
                                                          ?.toString() ??
                                                      loc.supportTicketNotFound,
                                                  style: const TextStyle(
                                                      color: _ink,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                  spacing: 10,
                                                  runSpacing: 8,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    _badge(loc,
                                                        _ticket?['status']),
                                                    Text('#${widget.ticketId}',
                                                        style: const TextStyle(
                                                            color: _muted,
                                                            fontSize: 12)),
                                                    if (!closed)
                                                      TextButton.icon(
                                                          onPressed: _busy
                                                              ? null
                                                              : _close,
                                                          icon: _closing
                                                              ? const SizedBox(
                                                                  width: 16,
                                                                  height: 16,
                                                                  child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2))
                                                              : const Icon(
                                                                  Icons
                                                                      .check_circle_outline_rounded,
                                                                  size: 18),
                                                          label: Text(_closing
                                                              ? loc
                                                                  .supportStatusClosing
                                                              : loc
                                                                  .supportCloseTicket),
                                                          style: TextButton
                                                              .styleFrom(
                                                                  foregroundColor:
                                                                      _muted))
                                                  ]),
                                              const SizedBox(height: 20),
                                              if (messages.isEmpty)
                                                Text(loc.supportNoMessages,
                                                    style: const TextStyle(
                                                        color: _muted))
                                              else
                                                for (final message in messages)
                                                  _message(
                                                      Map<String, dynamic>.from(
                                                          message as Map)),
                                            ])),
                          if (_ticket != null && _error == null)
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 16),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        top: BorderSide(color: _border))),
                                child: closed
                                    ? Text(loc.supportReplyClosed,
                                        style: const TextStyle(
                                            color: _muted, height: 1.5))
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            if (_replyError != null) ...[
                                              Text(_replyError!,
                                                  style: const TextStyle(
                                                      color:
                                                          Color(0xFFCF354D))),
                                              const SizedBox(height: 8)
                                            ],
                                            Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                      child: TextField(
                                                          key: const ValueKey(
                                                              'support-reply'),
                                                          controller: _reply,
                                                          enabled: !_busy,
                                                          minLines: 1,
                                                          maxLines: 3,
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .sentences,
                                                          decoration: _field(loc
                                                              .supportReplyPlaceholder))),
                                                  const SizedBox(width: 10),
                                                  IconButton.filled(
                                                      onPressed:
                                                          _busy ? null : _send,
                                                      tooltip:
                                                          loc.supportReplySend,
                                                      style:
                                                          IconButton.styleFrom(
                                                              backgroundColor:
                                                                  _blue,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              minimumSize:
                                                                  const Size(
                                                                      48, 48)),
                                                      icon: _replying
                                                          ? const SizedBox(
                                                              width: 18,
                                                              height: 18,
                                                              child: CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                  strokeWidth:
                                                                      2))
                                                          : const Icon(
                                                              Icons
                                                                  .send_outlined,
                                                              size: 20))
                                                ])
                                          ])),
                        ]))))));
  }
}
