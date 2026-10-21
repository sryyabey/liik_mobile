import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth.dart';
import '../config.dart';
import '../l10n/app_localizations.dart';

String? appointmentShareUrl(Map<String, dynamic> appointment) {
  final value = appointment['share_url']?.toString() ?? '';
  final uri = Uri.tryParse(value);
  return uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty
      ? uri.toString()
      : null;
}

Future<void> shareAppointment(
    BuildContext context, Map<String, dynamic> appointment) async {
  final url = appointmentShareUrl(appointment);
  if (url == null) return;
  final loc = AppLocalizations.of(context);
  final box = context.findRenderObject();
  final origin = box is RenderBox && box.hasSize
      ? box.localToGlobal(Offset.zero) & box.size
      : const Rect.fromLTWH(0, 0, 1, 1);
  try {
    await Share.share(url,
        subject: loc.appointmentDetails, sharePositionOrigin: origin);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.appointmentShareFailed)));
  }
}

Future<void> showAppointmentDetails(
    BuildContext context, Map<String, dynamic> appointment,
    {String? statusLabel, VoidCallback? onEdit, VoidCallback? onRebook}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFFFAFBFD),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AppointmentDetails(
        appointment: appointment,
        statusLabel: statusLabel,
        onEdit: onEdit,
        onRebook: onRebook),
  );
}

class _AppointmentDetails extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final String? statusLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onRebook;
  const _AppointmentDetails(
      {required this.appointment,
      this.statusLabel,
      this.onEdit,
      this.onRebook});
  @override
  State<_AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<_AppointmentDetails> {
  late Map<String, dynamic> data;
  List<Map<String, dynamic>> history = [];
  bool loading = true;
  bool failed = false;
  @override
  void initState() {
    super.initState();
    data = widget.appointment;
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await authGet(
          Uri.parse('$apiBaseUrl/api/appointments/${widget.appointment['id']}'),
          headers: {'Accept': 'application/json'});
      if (response.statusCode != 200) {
        throw StateError('Appointment unavailable');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        data = Map<String, dynamic>.from(body['data'] as Map);
        history = ((body['recent_appointments'] ??
                    (body['meta'] is Map
                        ? body['meta']['recent_appointments']
                        : null)) as List? ??
                [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          failed = true;
        });
      }
    }
  }

  String date(Map<String, dynamic> item) {
    final raw = item['date']?.toString() ?? '';
    // Dates are appointment wall dates, not device-local UTC instants.
    final parsed =
        DateTime.tryParse(raw.length >= 10 ? raw.substring(0, 10) : raw);
    return parsed == null
        ? raw
        : DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
            .format(parsed);
  }

  String time(Map<String, dynamic> item) {
    final raw = item['time']?.toString() ?? '';
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  Widget field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF627183))),
          const SizedBox(height: 5),
          SelectableText(value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0C2032))),
        ]),
      );
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final customer =
        data['customer'] is Map ? data['customer'] as Map : const {};
    final status = data['appointment_status'] is Map
        ? data['appointment_status'] as Map
        : const {};
    final url = appointmentShareUrl(data);
    final alias = status['alias']?.toString() ?? '';
    final statuses = {
      'pending': loc.statusPending,
      'confirmed': loc.statusConfirmed,
      'completed': loc.statusCompleted,
      'cancelled': loc.statusCancelled,
      'rescheduled': loc.statusRescheduled,
      'no_show': loc.statusNoShow
    };
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .9),
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(loc.appointmentDetails,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800))),
                  IconButton(
                      tooltip: loc.appointmentsClose,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close))
                ]),
                if (loading) const LinearProgressIndicator(),
                if (failed)
                  TextButton.icon(
                      onPressed: () {
                        setState(() {
                          loading = true;
                          failed = false;
                        });
                        _load();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.calendarLoadError)),
                const SizedBox(height: 16),
                Text(customer['name']?.toString() ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                if ((customer['phone']?.toString() ?? '').isNotEmpty)
                  field(
                      loc.appointmentsFieldPhone,
                      '${customer['country_code'] ?? ''} ${customer['phone']}'
                          .trim()),
                if ((customer['email']?.toString() ?? '').isNotEmpty)
                  field(loc.emailLabel, customer['email'].toString()),
                field(loc.calendarDateTimeSection,
                    '${date(data)} · ${time(data)}'),
                if ((data['timezone']?.toString() ?? '').isNotEmpty)
                  field(loc.appointmentTimezone, data['timezone'].toString()),
                field(
                    loc.appointmentStatusLabel,
                    statuses[alias] ??
                        widget.statusLabel ??
                        status['name']?.toString() ??
                        ''),
                if ((data['notes']?.toString() ?? '').isNotEmpty)
                  field(loc.appointmentNotes, data['notes'].toString()),
                if ((data['share_code']?.toString() ?? '').isNotEmpty)
                  field(loc.appointmentCode, data['share_code'].toString()),
                if (url != null) ...[
                  SelectableText(url,
                      style: const TextStyle(color: Color(0xFF0866EB))),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    Builder(
                        builder: (source) => FilledButton.icon(
                            onPressed: () => shareAppointment(source, data),
                            icon: const Icon(Icons.share_outlined),
                            label: Text(loc.appointmentShare))),
                    TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(loc.appointmentLinkCopied)));
                          }
                        },
                        icon: const Icon(Icons.copy),
                        label: Text(loc.appointmentCopyLink)),
                  ]),
                  TextButton.icon(
                      onPressed: () async {
                        try {
                          final opened = await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                          if (!opened) throw StateError('Unavailable');
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(loc.dashboardLinkOpenFailed)));
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: Text(loc.appointmentOpenCalendar)),
                ],
                Wrap(spacing: 8, children: [
                  if (widget.onEdit != null)
                    TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onEdit!();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(loc.calendarActionEdit)),
                  if (widget.onRebook != null)
                    TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onRebook!();
                        },
                        icon: const Icon(Icons.event_repeat),
                        label: Text(loc.calendarActionNew)),
                ]),
                if (history.isNotEmpty) ...[
                  const Divider(),
                  Text(loc.appointmentHistory,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  ...history.map((item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${date(item)} · ${time(item)}'),
                      subtitle: Text(item['share_code']?.toString() ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final navigator = Navigator.of(context);
                        navigator.pop();
                        showAppointmentDetails(navigator.context, item);
                      }))
                ],
              ])),
    );
  }
}
