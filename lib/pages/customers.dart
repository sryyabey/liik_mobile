import '../widgets/studio_page.dart';
import '../user_timezone.dart';
import '../app_locale.dart';
import 'dart:async';
import 'dart:convert';

import 'package:bagla_mobile/auth.dart';
import 'package:bagla_mobile/config.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import '../widgets/appointment_booking_flow.dart';
import '../login_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  AppLocalizations get loc => AppLocalizations.of(context);

  // Modern Color Palette
  static const Color _backgroundColor = StudioPageStyle.background;
  static const Color _primaryColor = Color(0xFF0866EB);
  static const Color _primaryLight = Color(0xFFEAF1FF);
  static const Color _textPrimary = Color(0xFF0C2032);
  static const Color _textSecondary = Color(0xFF627183);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _dangerColor = Color(0xFFEF4444);

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _loading = true;
  bool _loadingMore = false;
  bool _formOpen = false;
  int _requestVersion = 0;
  int _totalCustomers = 0;
  String? _error;

  int _currentPage = 1;
  int _lastPage = 1;
  final int _perPage = 20;
  final List<Map<String, dynamic>> _customers = [];
  String _selectedLetter = '#';
  static const List<String> _alphabetLetters = ['#', ...liikAlphabet];
  static const Set<String> _alphabetLetterSet = {'#', ...liikAlphabet};

  List<Map<String, dynamic>>? _visibleCustomersCache;
  int _visibleCustomersCacheStamp = -1;
  String _visibleCustomersCacheLetter = '';
  int _customersMutationStamp = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCustomers(reset: true);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    return getAccessToken();
  }

  void _showSnack(String message, {bool success = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? _successColor : _dangerColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _customerName(Map<String, dynamic> customer) {
    return customer['name']?.toString().trim() ?? '';
  }

  String _normalizeInitial(String char) {
    const map = {
      'á': 'A',
      'à': 'A',
      'â': 'A',
      'ã': 'A',
      'ä': 'A',
      'é': 'E',
      'è': 'E',
      'ê': 'E',
      'ë': 'E',
      'í': 'I',
      'ì': 'I',
      'î': 'I',
      'ï': 'I',
      'ó': 'O',
      'ò': 'O',
      'ô': 'O',
      'õ': 'O',
      'ö': 'O',
      'ú': 'U',
      'ù': 'U',
      'û': 'U',
      'ü': 'U',
      'ç': 'C',
      'ñ': 'N',
    };
    final lower = char.toLowerCase();
    return map[lower] ?? char.toUpperCase();
  }

  String _initialForName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    for (int i = 0; i < trimmed.length; i++) {
      final ch = trimmed[i];
      final normalized = _normalizeInitial(ch);
      if (_alphabetLetterSet.contains(normalized) && normalized != '#') {
        return normalized;
      }
    }
    return '#';
  }

  List<Map<String, dynamic>> _visibleCustomers() {
    if (_visibleCustomersCache != null &&
        _visibleCustomersCacheStamp == _customersMutationStamp &&
        _visibleCustomersCacheLetter == _selectedLetter) {
      return _visibleCustomersCache!;
    }
    final sorted = [..._customers];
    sorted.sort((a, b) {
      final an = _customerName(a).toLowerCase();
      final bn = _customerName(b).toLowerCase();
      return an.compareTo(bn);
    });
    final result = _selectedLetter == '#'
        ? sorted
        : sorted
            .where((c) => _initialForName(_customerName(c)) == _selectedLetter)
            .toList();
    _visibleCustomersCache = result;
    _visibleCustomersCacheStamp = _customersMutationStamp;
    _visibleCustomersCacheLetter = _selectedLetter;
    return result;
  }

  Future<void> _fetchCustomers({required bool reset}) async {
    final version = ++_requestVersion;
    final token = await _getToken();
    if (!mounted || version != _requestVersion) return;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = loc.customersSessionMissing;
      });
      return;
    }

    final pageToLoad = reset ? 1 : (_currentPage + 1);
    if (reset) {
      setState(() {
        _loading = true;
        _loadingMore = false;
        _error = null;
      });
    } else {
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      final response = await authGet(
        Uri.parse('$apiBaseUrl/api/customers').replace(
          queryParameters: {
            'search': _searchController.text.trim(),
            'per_page': _perPage.toString(),
            'sort_field': 'name',
            'sort_direction': 'asc',
            if (_selectedLetter != '#') 'starts_with': _selectedLetter,
            'page': pageToLoad.toString(),
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted || version != _requestVersion) return;
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? [];
        final Map<String, dynamic> meta =
            (decoded['meta'] is Map<String, dynamic>)
                ? Map<String, dynamic>.from(decoded['meta'])
                : <String, dynamic>{};

        final fetched =
            dataList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        if (!mounted) return;
        setState(() {
          if (reset) {
            _customers
              ..clear()
              ..addAll(fetched);
          } else {
            _customers.addAll(fetched);
          }
          _customersMutationStamp++;
          _totalCustomers = (meta['total'] as int?) ?? fetched.length;
          _currentPage = (meta['current_page'] as int?) ?? pageToLoad;
          _lastPage = (meta['last_page'] as int?) ?? _currentPage;
          _loading = false;
          _loadingMore = false;
        });
      } else {
        setState(() {
          _error = loc.customersLoadFailedStatus(response.statusCode);
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _error = loc.contactsLoadError;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    final id = customer['id'];
    if (id == null) return;
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      _showSnack(loc.customersSessionMissing);
      return;
    }

    try {
      final response = await authDelete(
        Uri.parse('$apiBaseUrl/api/customers/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        _showSnack(loc.customersDeleteSuccess, success: true);
        await _fetchCustomers(reset: true);
      } else {
        String message = loc.customersDeleteFailedStatus(response.statusCode);
        try {
          final decoded = jsonDecode(response.body);
          message = decoded['message']?.toString() ?? message;
        } catch (_) {}
        _showSnack(message);
      }
    } catch (e) {
      _showSnack(loc.customersDeleteFailed(e.toString()));
    }
  }

  Future<bool> _saveCustomer({
    Map<String, dynamic>? existing,
    required String name,
    required String phone,
    required String email,
    required String address,
    required String notes,
    required ValueChanged<String> onError,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      onError(loc.customersSessionMissing);
      return false;
    }

    final payload = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim().isEmpty ? null : email.trim(),
      'address': address.trim().isEmpty ? null : address.trim(),
      'notes': notes.trim().isEmpty ? null : notes.trim(),
      if (existing?['country_id'] != null)
        'country_id': existing!['country_id'],
    };

    final customerId = existing?['id'];

    try {
      final response = existing == null
          ? await authPost(
              Uri.parse('$apiBaseUrl/api/customers'),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
          : await authPut(
              Uri.parse('$apiBaseUrl/api/customers/$customerId'),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(
          existing == null
              ? loc.customersCreateSuccess
              : loc.customersUpdateSuccess,
          success: true,
        );
        await _fetchCustomers(reset: true);
        return true;
      } else {
        String message = loc.customersSaveFailedStatus(response.statusCode);
        try {
          final decoded = jsonDecode(response.body);
          message = decoded['message']?.toString() ?? message;
        } catch (_) {}
        onError(message);
      }
    } catch (_) {
      onError(loc.contactsSaveError);
    }
    return false;
  }

  Future<void> _openCustomerForm({Map<String, dynamic>? customer}) async {
    if (_formOpen) return;
    _formOpen = true;
    final fields = {
      for (final key in ['name', 'phone', 'email', 'address', 'notes'])
        key: TextEditingController(text: customer?[key]?.toString() ?? '')
    };
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    String? error;
    ModalRoute<dynamic>? route;
    try {
      await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: _backgroundColor,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .94),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (ctx) {
            route = ModalRoute.of(ctx);
            return StatefulBuilder(builder: (ctx, update) {
              return PopScope(
                  canPop: !saving,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, 16, 20, MediaQuery.viewInsetsOf(ctx).bottom + 24),
                      child: SingleChildScrollView(
                          child: Form(
                              key: formKey,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                        child: Container(
                                            width: 36,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                color: _borderColor,
                                                borderRadius:
                                                    BorderRadius.circular(4)))),
                                    const SizedBox(height: 18),
                                    Row(children: [
                                      Expanded(
                                          child: Text(
                                              customer == null
                                                  ? loc.customersAdd
                                                  : loc.customersEdit,
                                              style: const TextStyle(
                                                  color: _textPrimary,
                                                  fontSize: 24,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      IconButton(
                                          tooltip: loc.appointmentsClose,
                                          onPressed: saving
                                              ? null
                                              : () => Navigator.of(ctx).pop(),
                                          icon: const Icon(Icons.close_rounded))
                                    ]),
                                    const SizedBox(height: 6),
                                    Text(
                                        customer == null
                                            ? loc.customersAddSubtitle
                                            : loc.customersEditSubtitle,
                                        style: const TextStyle(
                                            color: _textSecondary)),
                                    const SizedBox(height: 24),
                                    for (final entry in {
                                      'name': loc.customersName,
                                      'phone': loc.customersPhone,
                                      'email': loc.customersEmail,
                                      'address': loc.customersAddress,
                                      'notes': loc.customersNotes
                                    }.entries) ...[
                                      TextFormField(
                                          key: ValueKey('contact-${entry.key}'),
                                          controller: fields[entry.key],
                                          enabled: !saving,
                                          keyboardType: entry.key == 'phone'
                                              ? TextInputType.phone
                                              : entry.key == 'email'
                                                  ? TextInputType.emailAddress
                                                  : entry.key == 'notes'
                                                      ? TextInputType.multiline
                                                      : TextInputType.text,
                                          textCapitalization:
                                              entry.key == 'name' ||
                                                      entry.key == 'address'
                                                  ? TextCapitalization.words
                                                  : TextCapitalization.none,
                                          inputFormatters: entry.key == 'phone'
                                              ? [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'[0-9+() -]')),
                                                  LengthLimitingTextInputFormatter(
                                                      30)
                                                ]
                                              : null,
                                          minLines:
                                              entry.key == 'notes' ? 3 : 1,
                                          maxLines:
                                              entry.key == 'notes' ? 5 : 1,
                                          validator: (value) {
                                            final text = value?.trim() ?? '';
                                            if ((entry.key == 'name' ||
                                                    entry.key == 'phone') &&
                                                text.isEmpty)
                                              return loc.customersValidation;
                                            if (entry.key == 'phone' &&
                                                (text
                                                        .replaceAll(
                                                            RegExp(r'\D'), '')
                                                        .isEmpty ||
                                                    text
                                                            .replaceAll(
                                                                RegExp(r'\D'),
                                                                '')
                                                            .length >
                                                        15))
                                              return loc.contactsPhoneInvalid;
                                            if (entry.key == 'email' &&
                                                text.isNotEmpty &&
                                                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                                    .hasMatch(text))
                                              return loc.contactsEmailInvalid;
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              labelText: entry.value,
                                              alignLabelWithHint:
                                                  entry.key == 'notes',
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.all(16),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                      color: _borderColor)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                      color: _borderColor)))),
                                      const SizedBox(height: 16),
                                    ],
                                    if (error != null) ...[
                                      Text(error!,
                                          style: const TextStyle(
                                              color: _dangerColor)),
                                      const SizedBox(height: 16)
                                    ],
                                    SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                            onPressed: saving
                                                ? null
                                                : () async {
                                                    if (!formKey.currentState!
                                                        .validate()) return;
                                                    FocusScope.of(ctx)
                                                        .unfocus();
                                                    update(() {
                                                      saving = true;
                                                      error = null;
                                                    });
                                                    final success =
                                                        await _saveCustomer(
                                                            existing: customer,
                                                            name:
                                                                fields['name']!
                                                                    .text,
                                                            phone:
                                                                fields['phone']!
                                                                    .text,
                                                            email:
                                                                fields['email']!
                                                                    .text,
                                                            address: fields[
                                                                    'address']!
                                                                .text,
                                                            notes:
                                                                fields['notes']!
                                                                    .text,
                                                            onError: (message) {
                                                              error = message;
                                                            });
                                                    if (!ctx.mounted) return;
                                                    update(
                                                        () => saving = false);
                                                    if (success)
                                                      Navigator.of(ctx).pop();
                                                  },
                                            style: FilledButton.styleFrom(
                                                backgroundColor: _primaryColor,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
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
                                                            color: Colors.white,
                                                            strokeWidth: 2))
                                                : Text(loc.customersSave))),
                                  ])))));
            });
          });
    } finally {
      await route?.completed;
      for (final controller in fields.values) {
        controller.dispose();
      }
      _formOpen = false;
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> customer) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _dangerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_outlined, color: _dangerColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.customersDeleteConfirmTitle,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(loc.customersDeleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                loc.customersCancel,
                style: const TextStyle(color: _textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(loc.customersDelete),
            ),
          ],
        );
      },
    );
    if (approved == true) {
      await _deleteCustomer(customer);
    }
  }

  Widget _customerCard(Map<String, dynamic> customer) {
    final name =
        '${customer['name'] ?? ''} ${customer['lastname'] ?? ''}'.trim();
    final phone = customer['phone']?.toString() ?? '';
    final email = customer['email']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor)),
      child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _primaryLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(_initialForName(name),
                      style: const TextStyle(
                          color: _primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(name.isEmpty ? '—' : name,
                        style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(phone,
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12))
                    ],
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(email,
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12))
                    ],
                  ])),
              PopupMenuButton<String>(
                  tooltip: loc.customersEdit,
                  icon: const Icon(Icons.more_horiz, color: _textSecondary),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openCustomerForm(customer: customer);
                    } else {
                      _confirmDelete(customer);
                    }
                  },
                  itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'edit', child: Text(loc.customersEdit)),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text(loc.customersDelete,
                                style: const TextStyle(color: _dangerColor))),
                      ]),
            ]),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _borderColor),
            const SizedBox(height: 6),
            TextButton.icon(
                onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _CustomerAppointmentsSheet(
                        customer: customer, tokenGetter: _getToken)),
                icon: const Icon(Icons.event_note_outlined, size: 18),
                label: Text(loc.customersAppointments),
                style: TextButton.styleFrom(foregroundColor: _primaryColor)),
          ])),
    );
  }

  Widget _stateMessage(IconData icon, String message, {VoidCallback? retry}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: _primaryColor, size: 34)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, height: 1.5)),
            if (retry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                  onPressed: retry,
                  icon: const Icon(Icons.refresh),
                  label: Text(loc.customersRetry))
            ],
          ]));

  @override
  Widget build(BuildContext context) {
    final visible = _visibleCustomers();
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: StudioPageStyle.appBar(
          title: loc.customersTitle,
          icon: Icons.people_outline,
          refreshLabel: loc.customersRefresh,
          onRefresh: () => _fetchCustomers(reset: true)),
      body: StudioPageBackground(
          child: SafeArea(
              child: RefreshIndicator(
                  onRefresh: () => _fetchCustomers(reset: true),
                  color: _primaryColor,
                  child: CustomScrollView(
                      key: const PageStorageKey('contacts-list'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            sliver: SliverToBoxAdapter(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  StudioPageIntro(loc.contactsSubtitle),
                                  SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                          onPressed: () => _openCustomerForm(),
                                          icon: const Icon(
                                              Icons.person_add_alt_1_outlined,
                                              size: 20),
                                          label: Text(loc.customersAdd),
                                          style: FilledButton.styleFrom(
                                              backgroundColor: _primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 15),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12))))),
                                  const SizedBox(height: 16),
                                  TextField(
                                      controller: _searchController,
                                      onChanged: (_) {
                                        setState(() => _selectedLetter = '#');
                                        _requestVersion++;
                                        _searchDebounce?.cancel();
                                        _searchDebounce = Timer(
                                            const Duration(milliseconds: 350),
                                            () => _fetchCustomers(reset: true));
                                      },
                                      decoration: InputDecoration(
                                          hintText: loc.customersSearchHint,
                                          prefixIcon: const Icon(
                                              Icons.search_rounded,
                                              color: _textSecondary),
                                          suffixIcon: _searchController
                                                  .text.isEmpty
                                              ? null
                                              : IconButton(
                                                  tooltip:
                                                      loc.appointmentsClear,
                                                  onPressed: () {
                                                    _searchDebounce?.cancel();
                                                    _searchController.clear();
                                                    setState(() =>
                                                        _selectedLetter = '#');
                                                    _fetchCustomers(
                                                        reset: true);
                                                  },
                                                  icon: const Icon(
                                                      Icons.close_rounded,
                                                      size: 18)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: _borderColor)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: _borderColor)))),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                      height: 48,
                                      child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _alphabetLetters.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 6),
                                          itemBuilder: (_, i) {
                                            final letter = _alphabetLetters[i];
                                            return ChoiceChip(
                                                label: Text(letter == '#'
                                                    ? loc.contactsAll
                                                    : letter),
                                                selected:
                                                    _selectedLetter == letter,
                                                onSelected: (_) {
                                                  _searchDebounce?.cancel();
                                                  setState(() =>
                                                      _selectedLetter = letter);
                                                  _fetchCustomers(reset: true);
                                                },
                                                selectedColor: _primaryLight,
                                                labelStyle: TextStyle(
                                                    color: _selectedLetter ==
                                                            letter
                                                        ? _primaryColor
                                                        : _textSecondary,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                side: const BorderSide(
                                                    color: _borderColor),
                                                showCheckmark: false);
                                          })),
                                  const SizedBox(height: 14),
                                  if (!_loading && _error == null)
                                    Text(loc.contactsCount(_totalCustomers),
                                        style: const TextStyle(
                                            color: _textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                ]))),
                        if (_loading)
                          const SliverToBoxAdapter(
                              child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: _primaryColor))))
                        else if (_error != null)
                          SliverToBoxAdapter(
                              child: _stateMessage(
                                  Icons.cloud_off_outlined, _error!,
                                  retry: () => _fetchCustomers(reset: true)))
                        else if (visible.isEmpty)
                          SliverToBoxAdapter(
                              child: _stateMessage(
                                  Icons.people_outline,
                                  _selectedLetter != '#'
                                      ? loc.customersEmptyForLetter(
                                          _selectedLetter)
                                      : _searchController.text.trim().isNotEmpty
                                          ? loc.contactsNoResults
                                          : loc.customersEmpty))
                        else
                          SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList.builder(
                                  itemCount: visible.length,
                                  itemBuilder: (_, i) =>
                                      _customerCard(visible[i]))),
                        if (!_loading && _currentPage < _lastPage)
                          SliverToBoxAdapter(
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: OutlinedButton(
                                      onPressed: _loadingMore
                                          ? null
                                          : () => _fetchCustomers(reset: false),
                                      child: Text(_loadingMore
                                          ? loc.calendarLoading
                                          : loc.customersLoadMore)))),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ])))),
    );
  }
}

class _CustomerAppointmentsSheet extends StatefulWidget {
  const _CustomerAppointmentsSheet({
    required this.customer,
    required this.tokenGetter,
  });

  final Map<String, dynamic> customer;
  final Future<String?> Function() tokenGetter;

  @override
  State<_CustomerAppointmentsSheet> createState() =>
      _CustomerAppointmentsSheetState();
}

class _CustomerAppointmentsSheetState extends State<_CustomerAppointmentsSheet>
    with AppointmentBookingFlow<_CustomerAppointmentsSheet> {
  @override
  AppLocalizations get loc => AppLocalizations.of(context);

  static const Color _primaryColor = Color(0xFF0866EB);
  static const Color _primaryLight = Color(0xFFEAF1FF);
  static const Color _textPrimary = Color(0xFF0C2032);
  static const Color _textSecondary = Color(0xFF627183);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _dangerColor = Color(0xFFEF4444);

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAppointments();
    });
  }

  String _fmtDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final d = DateTime.parse(value);
      return DateFormat.yMMMd(Localizations.localeOf(context).toString())
          .format(d);
    } catch (_) {
      return value;
    }
  }

  String _fmtTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  void _showSnack(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? _successColor : _dangerColor,
      ),
    );
  }

  @override
  Future<bool> ensureBookingAccess() async {
    final response = await authGet(Uri.parse('$apiBaseUrl/api/appointments')
        .replace(queryParameters: {'per_page': '1'}));
    if (response.statusCode == 401) {
      await handleBookingSessionExpired();
      return false;
    }
    if (response.statusCode != 200) {
      if (mounted) _showSnack(loc.contactsLoadError);
      return false;
    }
    final body = jsonDecode(response.body);
    final pack = body['user_pack'] ?? body['userPack'];
    final allowed = body['code'] != 'NO_PACKAGE' &&
        pack != false &&
        pack != 0 &&
        pack != '0';
    if (!allowed) _showSnack(loc.appointmentsPlanRequired);
    return allowed;
  }

  @override
  Future<void> refreshAfterBooking() => _fetchAppointments();
  @override
  Future<void> handleBookingSessionExpired() async {
    if (mounted)
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage(onLocaleChange: (_) {})),
          (_) => false);
  }

  @override
  void showBookingMessage(String message, {bool success = false}) =>
      _showSnack(message, success: success);

  Future<void> _fetchAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await widget.tokenGetter();
    final customerId = widget.customer['id'];
    if (token == null || token.isEmpty || customerId == null) {
      setState(() {
        _loading = false;
        _error = loc.customersSessionMissing;
      });
      return;
    }

    try {
      final response = await authGet(
        Uri.parse('$apiBaseUrl/api/customers/$customerId/appointments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List? ?? [];
        if (!mounted) return;
        setState(() {
          _appointments =
              list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              loc.customersAppointmentsLoadFailedStatus(response.statusCode);
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = loc.customersAppointmentsLoadFailed(e.toString());
        _loading = false;
      });
    }
  }

  Future<void> _openCreateAppointmentDialog() => showBookingSheet(
      initialDate: UserTimeZone.now().toIso8601String().substring(0, 10),
      initialTime: '',
      initialCustomer: widget.customer);

  @override
  Widget build(BuildContext context) {
    final customerName =
        '${widget.customer['name'] ?? ''} ${widget.customer['lastname'] ?? ''}'
            .trim();
    return FractionallySizedBox(
        heightFactor: .9,
        child: Material(
            color: const Color(0xFFFAFBFD),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
                top: false,
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius:
                                            BorderRadius.circular(4)))),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: Text(loc.customersAppointments,
                                      style: const TextStyle(
                                          color: _textPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800))),
                              IconButton(
                                  tooltip: loc.appointmentsClose,
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close_rounded,
                                      color: _textSecondary))
                            ]),
                            Text(customerName,
                                style: const TextStyle(
                                    color: _textSecondary, fontSize: 14)),
                            const SizedBox(height: 16),
                            SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                    onPressed: _openCreateAppointmentDialog,
                                    icon:
                                        const Icon(Icons.add_rounded, size: 20),
                                    label: Text(loc.customersCreateAppointment),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: _primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))))),
                          ])),
                  Expanded(
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: _primaryColor))
                          : RefreshIndicator(
                              onRefresh: _fetchAppointments,
                              child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                  children: [
                                    if (_error != null) ...[
                                      Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(_error!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: _textSecondary))),
                                      OutlinedButton.icon(
                                          onPressed: _fetchAppointments,
                                          icon: const Icon(Icons.refresh),
                                          label: Text(loc.customersRetry))
                                    ] else if (_appointments.isEmpty)
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 36),
                                          child: Column(children: [
                                            const Icon(
                                                Icons.event_note_outlined,
                                                size: 36,
                                                color: _primaryColor),
                                            const SizedBox(height: 16),
                                            Text(loc.customersNoAppointments,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: _textSecondary,
                                                    height: 1.5))
                                          ]))
                                    else
                                      for (final appointment in _appointments)
                                        Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFE5E7EB))),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Wrap(
                                                      spacing: 12,
                                                      runSpacing: 8,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        8),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    _primaryLight,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Text(
                                                                _fmtTime(appointment[
                                                                        'time']
                                                                    ?.toString()),
                                                                style: const TextStyle(
                                                                    color:
                                                                        _primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700))),
                                                        Text(
                                                            _fmtDate(appointment[
                                                                    'date']
                                                                ?.toString()),
                                                            style: const TextStyle(
                                                                color:
                                                                    _textPrimary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))
                                                      ]),
                                                  if (appointment[
                                                          'appointment_status']
                                                      is Map) ...[
                                                    const SizedBox(height: 10),
                                                    Text(
                                                        _statusLabel(Map<String,
                                                                dynamic>.from(
                                                            appointment[
                                                                'appointment_status'])),
                                                        style: const TextStyle(
                                                            color:
                                                                _textSecondary,
                                                            fontSize: 12))
                                                  ],
                                                  if ((appointment['notes']
                                                              ?.toString()
                                                              .trim() ??
                                                          '')
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 10),
                                                    Text(
                                                        appointment['notes']
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color:
                                                                _textSecondary,
                                                            height: 1.4))
                                                  ],
                                                ])),
                                  ]))),
                ]))));
  }

  String _statusLabel(Map<String, dynamic> status) => switch (status['alias']) {
        'pending' => loc.statusPending,
        'confirmed' => loc.statusConfirmed,
        'completed' => loc.statusCompleted,
        'cancelled' => loc.statusCancelled,
        'no_show' => loc.statusNoShow,
        _ => status['name']?.toString() ?? '',
      };
}
