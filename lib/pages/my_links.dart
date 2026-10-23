import 'dart:convert';
import 'package:liik_mobile/auth.dart';
import 'package:liik_mobile/config.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/main_tabs_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _blue = Color(0xFF0866EB);
const _ink = Color(0xFF0C2032);
const _muted = Color(0xFF627183);
const _border = Color(0xFFE5EAF1);
const _background = Color(0xFFFAFBFD);

class MyLinksPage extends StatefulWidget {
  const MyLinksPage({super.key});
  @override
  State<MyLinksPage> createState() => _MyLinksPageState();
}

class _MyLinksPageState extends State<MyLinksPage> {
  AppLocalizations get loc => AppLocalizations.of(context);
  List<Map<String, dynamic>> _links = [], _types = [], _colors = [];
  bool _loading = true,
      _settingsLoading = true,
      _ordering = false,
      _formOpen = false;
  final Set<int> _deleting = {};
  String? _loadError, _settingsError;
  int _loadVersion = 0;
  Future<void>? _settingsRequest;
  bool get _busy => _ordering || _deleting.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  int? _id(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');
  int? _typeId(Map<String, dynamic> link) => _id(link['type_id'] ??
      link['typeId'] ??
      (link['type'] is Map ? link['type']['id'] : null));
  int? _colorId(Map<String, dynamic> link) => _id(link['color_id'] ??
      link['colorId'] ??
      (link['color'] is Map ? link['color']['id'] : null));
  List<Map<String, dynamic>> _list(dynamic data) => data is List
      ? data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
      : [];
  String _name(Map<String, dynamic> value) =>
      (value['name'] ?? value['title'] ?? '').toString();
  Map<String, dynamic> _lookup(List<Map<String, dynamic>> items, int? id) =>
      items.firstWhere((item) => _id(item['id']) == id, orElse: () => {});
  Color _color(dynamic value) {
    final hex = value?.toString().replaceAll('#', '') ?? '';
    if (!RegExp(r'^(?:[a-fA-F0-9]{6}|[a-fA-F0-9]{8})$').hasMatch(hex)) {
      return _blue;
    }
    return Color(int.parse(hex.length == 6 ? 'ff$hex' : hex, radix: 16));
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const MainTabsPage(initialIndex: 0)));
    }
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor:
              error ? const Color(0xFFCF354D) : const Color(0xFF008577),
          behavior: SnackBarBehavior.floating));
  }

  String _responseError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        if (body['errors'] is Map) {
          for (final errors in (body['errors'] as Map).values) {
            if (errors is List && errors.isNotEmpty) {
              return errors.first.toString();
            }
          }
        }
        if (body['message'] is String &&
            (body['message'] as String).isNotEmpty) {
          return body['message'];
        }
      }
    } catch (_) {}
    return fallback;
  }

  Future<bool> _hasSession() async =>
      (await getAccessToken())?.isNotEmpty == true;

  Future<void> _refresh() async {
    if (_busy) return;
    await Future.wait([_fetchLinks(), _fetchSettings()]);
  }

  Future<void> _fetchLinks() async {
    final version = ++_loadVersion;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      if (!await _hasSession()) throw Exception();
      final response = await authGet(Uri.parse('$apiBaseUrl/api/user/profile'),
          headers: const {'Accept': 'application/json'});
      if (response.statusCode != 200) throw Exception();
      final body = jsonDecode(response.body);
      final raw = body['data']['links'];
      if (raw is! List) throw const FormatException();
      if (!mounted || version != _loadVersion) return;
      setState(() {
        _links = _list(raw);
        _loading = false;
      });
    } catch (_) {
      if (mounted && version == _loadVersion) {
        setState(() {
          _loadError = loc.linksLoadError;
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchSettings() => _settingsRequest ??=
      _loadSettings().whenComplete(() => _settingsRequest = null);

  Future<void> _loadSettings() async {
    if (!mounted) return;
    setState(() {
      _settingsLoading = true;
      _settingsError = null;
    });
    try {
      if (!await _hasSession()) throw Exception();
      final responses = await Future.wait([
        authGet(Uri.parse('$apiBaseUrl/api/settings/link-types'),
            headers: const {'Accept': 'application/json'}),
        authGet(Uri.parse('$apiBaseUrl/api/settings/colors'),
            headers: const {'Accept': 'application/json'}),
      ]);
      if (responses.any((response) => response.statusCode != 200)) {
        throw Exception();
      }
      dynamic decode(http.Response response) {
        final body = jsonDecode(response.body);
        return body is Map ? body['data'] : body;
      }

      final types = _list(decode(responses[0])),
          colors = _list(decode(responses[1]));
      if (types.isEmpty || colors.isEmpty) throw Exception();
      if (mounted) {
        setState(() {
          _types = types;
          _colors = colors;
          _settingsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _settingsLoading = false;
          _settingsError = loc.linksSettingsError;
        });
      }
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (_busy || _loading || oldIndex == newIndex) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex == oldIndex) return;
    final previous = List<Map<String, dynamic>>.from(_links);
    setState(() {
      _ordering = true;
      final item = _links.removeAt(oldIndex);
      _links.insert(newIndex, item);
    });
    try {
      if (!await _hasSession()) throw Exception();
      final response = await authPost(
          Uri.parse('$apiBaseUrl/api/links/reorder'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({
            'orders': [
              for (var i = 0; i < _links.length; i++)
                {'id': _id(_links[i]['id']), 'order': i}
            ]
          }));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _links = previous);
        _snack(loc.linksOrderError, error: true);
      }
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> link) async {
    if (_busy) return;
    final id = _id(link['id']);
    if (id == null) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(loc.linksDeleteTitle),
                content: Text(loc.linksDeleteBody),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(loc.customersCancel)),
                  FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFCF354D)),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(loc.customersDelete))
                ]));
    if (confirmed != true || !mounted || _busy) return;
    setState(() => _deleting.add(id));
    try {
      if (!await _hasSession()) throw Exception();
      final response = await authDelete(Uri.parse('$apiBaseUrl/api/links/$id'),
          headers: const {'Accept': 'application/json'});
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _snack(_responseError(response, loc.myLinksDeleteFailed), error: true);
        return;
      }
      if (mounted) {
        setState(() => _links.removeWhere((item) => _id(item['id']) == id));
        _snack(loc.myLinksDeleteSuccess);
      }
    } catch (_) {
      _snack(loc.myLinksDeleteError, error: true);
    } finally {
      if (mounted) setState(() => _deleting.remove(id));
    }
  }

  String _placeholder(int? typeId) => switch (
          (_lookup(_types, typeId)['type'] ?? _lookup(_types, typeId)['alias'])
              ?.toString()) {
        'phone' || 'sms' || 'whatsapp' => '+15551234567',
        'email' => 'hello@example.com',
        'telegram' => 'https://t.me/username',
        _ => 'https://example.com',
      };
  InputDecoration _decoration(String label, {String? hint, IconData? icon}) =>
      InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon, size: 20, color: _muted),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border)));

  Future<int?> _chooseType() {
    String query = '';
    return showDialog<int>(
        context: context,
        builder: (ctx) => Dialog(
            child: SizedBox(
                height: MediaQuery.sizeOf(ctx).height * .72,
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: StatefulBuilder(builder: (ctx, update) {
                      final items = _types
                          .where((item) => _name(item)
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                          .toList();
                      return Column(children: [
                        Row(children: [
                          Expanded(
                              child: Text(loc.myLinksSearchType,
                                  style: const TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18))),
                          IconButton(
                              tooltip: loc.appointmentsClose,
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: const Icon(Icons.close_rounded))
                        ]),
                        const SizedBox(height: 12),
                        TextField(
                            key: const ValueKey('link-type-search'),
                            onChanged: (value) => update(() => query = value),
                            decoration: _decoration(loc.myLinksSearchType,
                                icon: Icons.search_rounded)),
                        const SizedBox(height: 12),
                        Expanded(
                            child: items.isEmpty
                                ? Center(child: Text(loc.myLinksNoResults))
                                : ListView.builder(
                                    itemCount: items.length,
                                    itemBuilder: (_, index) => ListTile(
                                        title: Text(_name(items[index])),
                                        onTap: () => Navigator.of(ctx)
                                            .pop(_id(items[index]['id'])))))
                      ]);
                    })))));
  }

  Future<void> _openForm({Map<String, dynamic>? link}) async {
    if (_formOpen || _busy || _loading) return;
    _formOpen = true;
    if (_settingsLoading) await (_settingsRequest ?? _fetchSettings());
    if (!mounted) {
      _formOpen = false;
      return;
    }
    final title = TextEditingController(text: link?['title']?.toString() ?? ''),
        url = TextEditingController(text: link?['url']?.toString() ?? '');
    final form = GlobalKey<FormState>();
    int? typeId = link == null
        ? (_types.isEmpty ? null : _id(_types.first['id']))
        : _typeId(link);
    int? colorId = link == null
        ? (_colors.isEmpty ? null : _id(_colors.first['id']))
        : _colorId(link);
    bool saving = false;
    String? error;
    ModalRoute<dynamic>? route;
    try {
      await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: _background,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .94),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (ctx) {
            route = ModalRoute.of(ctx);
            return StatefulBuilder(builder: (ctx, update) {
              final validType = _types.any((item) => _id(item['id']) == typeId)
                  ? typeId
                  : null;
              final validColor =
                  _colors.any((item) => _id(item['id']) == colorId)
                      ? colorId
                      : null;
              return PopScope(
                  canPop: !saving,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, 16, 20, MediaQuery.viewInsetsOf(ctx).bottom + 24),
                      child: SingleChildScrollView(
                          child: Form(
                              key: form,
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
                                                borderRadius:
                                                    BorderRadius.circular(4)))),
                                    const SizedBox(height: 18),
                                    Row(children: [
                                      Expanded(
                                          child: Text(
                                              link == null
                                                  ? loc.myLinksNewLink
                                                  : loc.myLinksEditTitle,
                                              style: const TextStyle(
                                                  color: _ink,
                                                  fontSize: 24,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      IconButton(
                                          tooltip: loc.appointmentsClose,
                                          onPressed: saving
                                              ? null
                                              : () => Navigator.of(ctx).pop(),
                                          icon: const Icon(Icons.close_rounded,
                                              color: _muted))
                                    ]),
                                    const SizedBox(height: 8),
                                    Text(loc.linksFormSubtitle,
                                        style: const TextStyle(
                                            color: _muted, height: 1.5)),
                                    const SizedBox(height: 24),
                                    if (_settingsLoading)
                                      const Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Center(
                                              child: CircularProgressIndicator(
                                                  color: _blue)))
                                    else if (_settingsError != null) ...[
                                      Text(_settingsError!,
                                          style:
                                              const TextStyle(color: _muted)),
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                          onPressed: () async {
                                            update(() {});
                                            final future = _fetchSettings();
                                            update(() {});
                                            await future;
                                            if (ctx.mounted) {
                                              update(() {
                                                if (link == null) {
                                                  typeId ??= _types.isEmpty
                                                      ? null
                                                      : _id(_types.first['id']);
                                                  colorId ??= _colors.isEmpty
                                                      ? null
                                                      : _id(
                                                          _colors.first['id']);
                                                }
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.refresh),
                                          label: Text(loc.customersRetry))
                                    ] else ...[
                                      DropdownButtonFormField<int>(
                                          key: ValueKey('link-type-$validType'),
                                          initialValue: validType,
                                          isExpanded: true,
                                          decoration: _decoration(
                                                  loc.myLinksLinkType,
                                                  icon: Icons.category_outlined)
                                              .copyWith(
                                                  suffixIcon: IconButton(
                                                      tooltip:
                                                          loc.myLinksSearchType,
                                                      onPressed: saving
                                                          ? null
                                                          : () async {
                                                              final selected =
                                                                  await _chooseType();
                                                              if (ctx.mounted &&
                                                                  selected !=
                                                                      null) {
                                                                update(() =>
                                                                    typeId =
                                                                        selected);
                                                              }
                                                            },
                                                      icon: const Icon(Icons
                                                          .search_rounded))),
                                          items: _types
                                              .map((item) => DropdownMenuItem(
                                                  value: _id(item['id']),
                                                  child: Text(_name(item),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis)))
                                              .toList(),
                                          onChanged: saving
                                              ? null
                                              : (value) =>
                                                  update(() => typeId = value),
                                          validator: (value) => value == null
                                              ? loc.myLinksTypeMissing
                                              : null),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                          key: const ValueKey('link-title'),
                                          controller: title,
                                          enabled: !saving,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          decoration: _decoration(
                                              loc.myLinksTitleLabel,
                                              icon: Icons.title_rounded),
                                          validator: (value) =>
                                              (value?.length ?? 0) > 255
                                                  ? loc.linksTextTooLong
                                                  : null),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                          key: const ValueKey('link-url'),
                                          controller: url,
                                          enabled: !saving,
                                          keyboardType: TextInputType.url,
                                          autocorrect: false,
                                          decoration: _decoration(
                                              loc.myLinksUrlLabel,
                                              hint: _placeholder(typeId),
                                              icon: Icons.link_rounded),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return loc
                                                  .linksDestinationRequired;
                                            }
                                            if (value.trim().length > 255) {
                                              return loc.linksTextTooLong;
                                            }
                                            return null;
                                          }),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<int>(
                                          key: ValueKey(
                                              'link-color-$validColor'),
                                          initialValue: validColor,
                                          isExpanded: true,
                                          decoration: _decoration(
                                              loc.myLinksColorLabel),
                                          items: _colors
                                              .map((item) => DropdownMenuItem(
                                                  value: _id(item['id']),
                                                  child: Row(children: [
                                                    Container(
                                                        width: 16,
                                                        height: 16,
                                                        decoration: BoxDecoration(
                                                            color: _color(
                                                                item['color']),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            border: Border.all(
                                                                color:
                                                                    _border))),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                        child: Text(_name(item),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis))
                                                  ])))
                                              .toList(),
                                          onChanged: saving
                                              ? null
                                              : (value) =>
                                                  update(() => colorId = value),
                                          validator: (value) => value == null
                                              ? loc.myLinksColorMissing
                                              : null),
                                      const SizedBox(height: 24),
                                      if (error != null) ...[
                                        Text(error!,
                                            style: const TextStyle(
                                                color: Color(0xFFCF354D))),
                                        const SizedBox(height: 16)
                                      ],
                                      SizedBox(
                                          width: double.infinity,
                                          child: FilledButton(
                                              onPressed: saving
                                                  ? null
                                                  : () async {
                                                      if (!form.currentState!
                                                          .validate()) {
                                                        return;
                                                      }
                                                      FocusScope.of(ctx)
                                                          .unfocus();
                                                      update(() {
                                                        saving = true;
                                                        error = null;
                                                      });
                                                      try {
                                                        if (!await _hasSession()) {
                                                          throw Exception();
                                                        }
                                                        final payload =
                                                            jsonEncode({
                                                          'type_id': validType,
                                                          'color_id':
                                                              validColor,
                                                          'title': title.text
                                                                  .trim()
                                                                  .isEmpty
                                                              ? null
                                                              : title.text
                                                                  .trim(),
                                                          'url': url.text.trim()
                                                        });
                                                        final response = link ==
                                                                null
                                                            ? await authPost(
                                                                Uri.parse(
                                                                    '$apiBaseUrl/api/links'),
                                                                headers: {
                                                                  'Content-Type':
                                                                      'application/json'
                                                                },
                                                                body: payload)
                                                            : await authPut(
                                                                Uri.parse(
                                                                    '$apiBaseUrl/api/links/${link['id']}'),
                                                                headers: {
                                                                  'Content-Type':
                                                                      'application/json'
                                                                },
                                                                body: payload);
                                                        if (!ctx.mounted) {
                                                          return;
                                                        }
                                                        if (response.statusCode >=
                                                                200 &&
                                                            response.statusCode <
                                                                300) {
                                                          update(() =>
                                                              saving = false);
                                                          Navigator.of(ctx)
                                                              .pop();
                                                          _snack(link == null
                                                              ? loc
                                                                  .myLinksCreateSuccess
                                                              : loc
                                                                  .myLinksUpdateSuccess);
                                                          await _fetchLinks();
                                                        } else {
                                                          update(() {
                                                            saving = false;
                                                            error = _responseError(
                                                                response,
                                                                link == null
                                                                    ? loc
                                                                        .myLinksCreateFailed
                                                                    : loc
                                                                        .myLinksUpdateFailed);
                                                          });
                                                        }
                                                      } catch (_) {
                                                        if (ctx.mounted) {
                                                          update(() {
                                                            saving = false;
                                                            error = link == null
                                                                ? loc
                                                                    .myLinksCreateError
                                                                : loc
                                                                    .myLinksUpdateError;
                                                          });
                                                        }
                                                      }
                                                    },
                                              style: FilledButton.styleFrom(
                                                  backgroundColor: _blue,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 16,
                                                      horizontal: 16),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14))),
                                              child: saving
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2))
                                                  : Text(link == null
                                                      ? loc.myLinksAddLink
                                                      : loc
                                                          .myLinksUpdateButton))),
                                    ],
                                  ])))));
            });
          });
    } finally {
      await route?.completed;
      title.dispose();
      url.dispose();
      _formOpen = false;
    }
  }

  Widget _card(Map<String, dynamic> link, int index) {
    final type = _lookup(_types, _typeId(link)),
        color = _lookup(_colors, _colorId(link));
    final name = link['title']?.toString().trim() ?? '';
    final title = name.isEmpty ? _name(type) : name;
    return Container(
        key: ValueKey('link-${link['id']}'),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FF),
                        borderRadius: BorderRadius.circular(14)),
                    child:
                        const Icon(Icons.link_rounded, color: _blue, size: 22)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title.isEmpty ? loc.myLinksLinkType : title,
                          style: const TextStyle(
                              color: _ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      if (_name(type).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(_name(type),
                            style: const TextStyle(color: _muted, fontSize: 12))
                      ]
                    ])),
                if (_deleting.contains(_id(link['id'])))
                  const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)))
                else
                  PopupMenuButton<String>(
                      key: ValueKey('link-menu-${link['id']}'),
                      enabled: !_busy,
                      tooltip: loc.linksActions,
                      icon: const Icon(Icons.more_horiz, color: _muted),
                      onSelected: (action) {
                        switch (action) {
                          case 'edit':
                            _openForm(link: link);
                          case 'delete':
                            _delete(link);
                          case 'up':
                            _reorder(index, index - 1);
                          case 'down':
                            _reorder(index, index + 2);
                        }
                      },
                      itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'edit',
                                child: Text(loc.myLinksEditTitle)),
                            if (index > 0)
                              PopupMenuItem(
                                  value: 'up', child: Text(loc.linksMoveUp)),
                            if (index < _links.length - 1)
                              PopupMenuItem(
                                  value: 'down',
                                  child: Text(loc.linksMoveDown)),
                            PopupMenuItem(
                                value: 'delete',
                                child: Text(loc.customersDelete,
                                    style: const TextStyle(
                                        color: Color(0xFFCF354D)))),
                          ]),
              ]),
              const SizedBox(height: 14),
              Text(link['url']?.toString() ?? '',
                  style: const TextStyle(
                      color: _muted, fontSize: 13, height: 1.5)),
              const SizedBox(height: 14),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: Row(children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: _color(color['color']),
                          shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Expanded(
                      child: Text(_name(color),
                          style: const TextStyle(color: _muted, fontSize: 12)))
                ])),
                if (!_busy)
                  ReorderableDragStartListener(
                      index: index,
                      child: Tooltip(
                          message: loc.linksDrag,
                          child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.drag_indicator_rounded,
                                  color: _muted, size: 22))))
              ]),
            ])));
  }

  Widget _message(IconData icon, String title, String subtitle,
          {bool retry = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, color: _blue, size: 34)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _ink, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, height: 1.5)),
            if (retry) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(loc.customersRetry))
            ]
          ]));

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
          backgroundColor: _background,
          foregroundColor: _ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
              onPressed: _back,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back_rounded)),
          title: Text(loc.myLinksTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
                onPressed: _busy ? null : _refresh,
                tooltip: loc.refresh,
                icon: const Icon(Icons.refresh_rounded))
          ]),
      body: SafeArea(
          child: RefreshIndicator(
              onRefresh: _refresh,
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
                              Text(loc.myLinksTitle,
                                  style: const TextStyle(
                                      color: _ink,
                                      fontSize: 30,
                                      height: 1.15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1)),
                              const SizedBox(height: 9),
                              Text(loc.linksSubtitle,
                                  style: const TextStyle(
                                      color: _muted,
                                      fontSize: 14,
                                      height: 1.5)),
                              const SizedBox(height: 20),
                              SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                      onPressed: _busy || _loading
                                          ? null
                                          : () => _openForm(),
                                      icon: const Icon(Icons.add_rounded,
                                          size: 20),
                                      label: Text(loc.myLinksNewLink),
                                      style: FilledButton.styleFrom(
                                          backgroundColor: _blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14))))),
                              const SizedBox(height: 20),
                              Text(
                                  _ordering
                                      ? loc.myLinksOrderSaving
                                      : loc.linksOrderHint,
                                  style: const TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                      height: 1.5)),
                            ]))),
                    if (_loading)
                      const SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                  child:
                                      CircularProgressIndicator(color: _blue))))
                    else if (_loadError != null)
                      SliverToBoxAdapter(
                          child: _message(Icons.cloud_off_outlined,
                              loc.linksLoadError, loc.linksRetryHint,
                              retry: true))
                    else if (_links.isEmpty)
                      SliverToBoxAdapter(
                          child: _message(
                              Icons.add_link_rounded,
                              loc.myLinksNoLinksTitle,
                              loc.myLinksNoLinksSubtitle))
                    else
                      SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverReorderableList(
                              itemCount: _links.length,
                              onReorderItem: (oldIndex, newIndex) => _reorder(
                                  oldIndex,
                                  newIndex > oldIndex
                                      ? newIndex + 1
                                      : newIndex),
                              itemBuilder: (_, index) =>
                                  _card(_links[index], index))),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ]))));
}
