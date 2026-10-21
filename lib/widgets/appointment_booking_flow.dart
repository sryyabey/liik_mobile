import 'appointment_details.dart';
import '../user_timezone.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../app_locale.dart';
import '../auth.dart';
import '../config.dart';
import '../l10n/app_localizations.dart';
import '../utils/appointment_date_utils.dart';

class _ApiEnvelope {
  final int statusCode;
  final Map<String, dynamic> payload;
  final String? code;
  final String? message;
  final String? type;
  final dynamic data;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? errors;

  const _ApiEnvelope({
    required this.statusCode,
    required this.payload,
    required this.code,
    required this.message,
    required this.type,
    required this.data,
    required this.meta,
    required this.errors,
  });

  bool get isSuccessType => (type ?? '').toLowerCase() == 'success';
  bool get isSuccess {
    if (isSuccessType) return true;
    final c = (code ?? '').toUpperCase();
    if (c == 'OK' || c == 'CREATED' || c == 'UPDATED') return true;
    return statusCode >= 200 && statusCode < 300;
  }
}

class _BookingResponse {
  final dynamic data;
  final int statusCode;
  const _BookingResponse(this.data, this.statusCode);
}

class _BookingException implements Exception {
  final _BookingResponse response;
  const _BookingException(this.response);
  @override
  String toString() => response.data is Map
      ? (response.data['message']?.toString() ?? 'HTTP ${response.statusCode}')
      : 'HTTP ${response.statusCode}';
}

class _BookingClient {
  Future<_BookingResponse> _read(Future<http.Response> request) async {
    final http.Response response;
    try {
      response = await request;
    } on AuthRequiredException {
      rethrow;
    } catch (_) {
      throw const _BookingException(_BookingResponse({}, 0));
    }
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {'message': response.body};
    }
    final result = _BookingResponse(data, response.statusCode);
    if (response.statusCode >= 400) throw _BookingException(result);
    return result;
  }

  Future<_BookingResponse> get(String path,
      {Map<String, dynamic>? queryParameters}) {
    var uri = Uri.parse('$apiBaseUrl$path');
    if (queryParameters != null) {
      uri = uri.replace(
          queryParameters: queryParameters
              .map((key, value) => MapEntry(key, value.toString())));
    }
    return _read(authGet(uri, headers: {'Accept': 'application/json'}));
  }

  Future<_BookingResponse> post(String path, {dynamic data}) =>
      _read(authPost(Uri.parse('$apiBaseUrl$path'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(data)));
}

Future<_BookingClient> _buildBookingClient(
    {bool includeJsonContentType = false}) async {
  final token = await getAccessToken();
  if (token == null || token.isEmpty) throw const AuthRequiredException();
  return _BookingClient();
}

/// The same directory/new-person booking flow is used by Calendar and Appointments.
mixin AppointmentBookingFlow<T extends StatefulWidget> on State<T> {
  AppLocalizations get loc;
  Future<bool> ensureBookingAccess();
  Future<void> refreshAfterBooking();
  Future<void> handleBookingSessionExpired();
  void showBookingMessage(String message, {bool success = false});
  bool _bookingBusy = false;
  bool _bookingOpen = false;
  int? _bookingDefaultStatusId;
  static const _bookingBlue = Color(0xFF0866EB);
  int? _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');
  String _normalizeSlotDate(String value) =>
      AppointmentDateUtils.normalizeSlotDate(value);
  String _formatDateDisplay(DateTime value) =>
      AppointmentDateUtils.formatDateDisplay(value);
  DateTime _parseInputDateOrNow(String value) =>
      AppointmentDateUtils.parseInputDateOrNow(value);
  DateTime _clampDate(DateTime value, DateTime min, DateTime max) =>
      value.isBefore(min)
          ? min
          : value.isAfter(max)
              ? max
              : value;

  _ApiEnvelope _parseEnvelope(
    dynamic body, {
    int statusCode = 200,
  }) {
    Map<String, dynamic> payload = <String, dynamic>{};
    if (body is Map) {
      payload = Map<String, dynamic>.from(body);
    } else if (body is String) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          payload = Map<String, dynamic>.from(decoded);
        } else {
          payload = <String, dynamic>{'data': decoded};
        }
      } catch (_) {
        payload = <String, dynamic>{'message': body};
      }
    } else {
      payload = <String, dynamic>{'data': body};
    }

    final rawErrors = payload['errors'];
    final rawMeta = payload['meta'];
    return _ApiEnvelope(
      statusCode: statusCode,
      payload: payload,
      code: payload['code']?.toString(),
      message: payload['message']?.toString(),
      type: payload['type']?.toString(),
      data: payload.containsKey('data') ? payload['data'] : payload,
      meta: rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null,
      errors: rawErrors is Map ? Map<String, dynamic>.from(rawErrors) : null,
    );
  }

  String? _firstFieldError(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return null;
    final first = errors.values.first;
    if (first is List && first.isNotEmpty) return first.first?.toString();
    return first?.toString();
  }

  String _holidayWarningMessage(_ApiEnvelope envelope) {
    final holiday = envelope.meta?['holiday'] ??
        (envelope.data is Map ? envelope.data['holiday'] : null) ??
        envelope.payload['holiday'];
    if (holiday is Map) {
      final msg = holiday['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
      final name = holiday['name']?.toString() ?? '';
      final date = holiday['date']?.toString() ?? '';
      final joined = [name, date].where((e) => e.isNotEmpty).join(' - ');
      if (joined.isNotEmpty) return joined;
    } else if (holiday != null && holiday.toString().trim().isNotEmpty) {
      return holiday.toString();
    }
    return envelope.message?.trim().isNotEmpty == true
        ? envelope.message!
        : loc.commonHolidayDateUnavailable;
  }

  Future<bool> _handleIssueByCode(
    _ApiEnvelope envelope, {
    bool allowPackageNavigation = true,
    bool firstAppointmentFlow = false,
    VoidCallback? onSlotBusy,
  }) async {
    if (!mounted) return true;
    final code = _normalizedIssueCode(envelope);
    if (code.isEmpty &&
        envelope.statusCode >= 200 &&
        envelope.statusCode < 300) {
      return false;
    }
    switch (code) {
      case 'NO_PACKAGE':
        showBookingMessage(loc.appointmentsPlanRequired);

        return true;
      case 'HOLIDAY':
        showBookingMessage(_holidayWarningMessage(envelope));
        return true;
      case 'SLOT_BUSY':
        onSlotBusy?.call();
        final message = envelope.message?.trim();
        showBookingMessage(
          message != null && message.isNotEmpty
              ? message
              : (firstAppointmentFlow
                  ? loc.appointmentsConsecutiveSlotsUnavailable
                  : loc.calendarSlotBusy),
        );
        return true;
      case 'VALIDATION_ERROR':
        showBookingMessage(
          _firstFieldError(envelope.errors) ??
              envelope.message ??
              loc.calendarDateTimeRequired,
        );
        return true;
      case 'UNAUTHORIZED':
        showBookingMessage(loc.calendarSessionExpired);
        await handleBookingSessionExpired();
        return true;
      case 'FORBIDDEN':
        showBookingMessage(loc.commonForbiddenAction);
        return true;
      default:
        if (envelope.statusCode == 401) {
          showBookingMessage(loc.calendarSessionExpired);
          await handleBookingSessionExpired();
          return true;
        }
        if (envelope.statusCode == 403) {
          showBookingMessage(loc.commonForbiddenAction);
          return true;
        }
        return false;
    }
  }

  String _issueMessageForCode(
    _ApiEnvelope envelope, {
    bool firstAppointmentFlow = false,
    String? fallback,
  }) {
    final code = _normalizedIssueCode(envelope);
    switch (code) {
      case 'NO_PACKAGE':
        return loc.appointmentsPlanRequired;
      case 'HOLIDAY':
        return _holidayWarningMessage(envelope);
      case 'SLOT_BUSY':
        final msg = envelope.message?.trim();
        if (msg != null && msg.isNotEmpty) return msg;
        return firstAppointmentFlow
            ? loc.appointmentsConsecutiveSlotsUnavailable
            : loc.calendarSlotBusy;
      case 'VALIDATION_ERROR':
        return _firstFieldError(envelope.errors) ??
            envelope.message ??
            fallback ??
            loc.calendarDateTimeRequired;
      case 'UNAUTHORIZED':
        return loc.calendarSessionExpired;
      case 'FORBIDDEN':
        return loc.commonForbiddenAction;
      default:
        return envelope.message ??
            _firstFieldError(envelope.errors) ??
            fallback ??
            loc.calendarFetchFailed('');
    }
  }

  String _normalizedIssueCode(_ApiEnvelope envelope) {
    final rawCode = (envelope.code ?? '').toUpperCase().trim();
    if (rawCode.isNotEmpty) return rawCode;

    if (envelope.statusCode == 409) return 'SLOT_BUSY';
    if (envelope.statusCode == 422) return 'VALIDATION_ERROR';
    if (envelope.statusCode == 401) return 'UNAUTHORIZED';
    if (envelope.statusCode == 403) {
      final msg = (envelope.message ?? '').toLowerCase();
      if (msg.contains('package')) return 'NO_PACKAGE';
      return 'FORBIDDEN';
    }
    return '';
  }

  String? _normalizeTimeToApi(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final reg = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)(?::[0-5]\d)?$');
    final m = reg.firstMatch(trimmed);
    if (m == null) return null;
    return '${m.group(1)}:${m.group(2)}';
  }

  InputDecoration _modalInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _bookingBlue, width: 1.2),
      ),
    );
  }

  Future<int?> resolveBookingStatusId() async {
    if (_bookingDefaultStatusId != null) return _bookingDefaultStatusId;
    _BookingClient dio;
    try {
      dio = await _buildBookingClient();
    } on AuthRequiredException {
      return null;
    }

    try {
      final resp = await dio.get('/api/settings/appointment-statuses');
      final raw = resp.data is Map
          ? ((resp.data as Map)['data'] ?? resp.data)
          : resp.data;
      if (raw is! List) return null;
      final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (list.isEmpty) return null;

      int? parseId(Map<String, dynamic> s) {
        final id = s['id'];
        if (id is int) return id;
        return int.tryParse(id?.toString() ?? '');
      }

      for (final s in list) {
        final alias = s['alias']?.toString().toLowerCase();
        final id = parseId(s);
        if (alias == 'pending' && id != null) {
          _bookingDefaultStatusId = id;
          return id;
        }
      }
      final fallback = parseId(list.first);
      _bookingDefaultStatusId = fallback;
      return fallback;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _showCustomerPickerSheet() async {
    _BookingClient dio;
    try {
      dio = await _buildBookingClient();
    } on AuthRequiredException {
      showBookingMessage(loc.calendarSessionMissing);
      return null;
    }
    if (!mounted) return null;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.9;

    ModalRoute<dynamic>? pickerRoute;
    final searchCtrl = TextEditingController();
    const letters = ['#', ...liikAlphabet];
    List<Map<String, dynamic>> customers = [];
    bool loading = false;
    String? error;
    int page = 1;
    int lastPage = 1;
    String selectedLetter = '#';
    bool initialized = false;
    int requestVersion = 0;

    Future<void> load(StateSetter setModalState, {bool reset = false}) async {
      final version = ++requestVersion;
      if (reset) {
        page = 1;
        lastPage = 1;
        customers = [];
      } else if (page > lastPage) {
        return;
      }

      setModalState(() {
        loading = true;
        error = null;
      });

      try {
        final resp = await dio.get(
          '/api/customers',
          queryParameters: {
            'search': searchCtrl.text.trim(),
            if (selectedLetter != '#') 'starts_with': selectedLetter,
            'sort_field': 'name',
            'sort_direction': 'asc',
            'per_page': 30,
            'page': page,
          },
        );
        if (version != requestVersion) return;
        final body = resp.data;
        final data = body is Map ? (body['data'] ?? const []) : const [];
        final meta = body is Map && body['meta'] is Map
            ? Map<String, dynamic>.from(body['meta'] as Map)
            : <String, dynamic>{};
        final fetched = data is List
            ? data.map((e) => Map<String, dynamic>.from(e as Map)).toList()
            : <Map<String, dynamic>>[];

        setModalState(() {
          customers.addAll(fetched);
          page = (meta['current_page'] as int?) != null
              ? (meta['current_page'] as int) + 1
              : page + 1;
          lastPage = (meta['last_page'] as int?) ?? 1;
          loading = false;
        });
      } catch (e) {
        if (version != requestVersion) return;
        setModalState(() {
          loading = false;
          error = loc.calendarLoadError;
        });
      }
    }

    try {
      return await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxHeight: maxSheetHeight,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          pickerRoute = ModalRoute.of(ctx);
          return StatefulBuilder(
            builder: (ctx, rawSetModalState) {
              void setModalState(VoidCallback update) {
                if (mounted && ctx.mounted) rawSetModalState(update);
              }

              if (!initialized) {
                initialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  load(setModalState, reset: true);
                });
              }

              final bottomInset = MediaQuery.of(ctx).viewInsets.bottom + 12;
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          loc.calendarGuideTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    TextField(
                      controller: searchCtrl,
                      decoration: _modalInputDecoration(
                        labelText: loc.calendarPerson,
                        hintText: loc.customersSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: () => load(setModalState, reset: true),
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                      onSubmitted: (_) => load(setModalState, reset: true),
                      onChanged: (_) => load(setModalState, reset: true),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              children: letters.map((letter) {
                                final active = selectedLetter == letter;
                                return InkWell(
                                  onTap: () {
                                    if (selectedLetter == letter) return;
                                    setModalState(() {
                                      selectedLetter = letter;
                                    });
                                    load(setModalState, reset: true);
                                  },
                                  child: Container(
                                    height: 20,
                                    alignment: Alignment.center,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 1),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? _bookingBlue.withValues(alpha: 0.14)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: active
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: active
                                            ? _bookingBlue
                                            : Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Expanded(
                            child: loading && customers.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : error != null
                                    ? Center(
                                        child: Text(
                                          error!,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: customers.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == customers.length) {
                                            if (page > lastPage) {
                                              return const SizedBox(height: 12);
                                            }
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: OutlinedButton(
                                                onPressed: loading
                                                    ? null
                                                    : () => load(setModalState),
                                                child: loading
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : Text(
                                                        loc.customersLoadMore),
                                              ),
                                            );
                                          }
                                          final c = customers[index];
                                          final name =
                                              c['name']?.toString().trim() ??
                                                  '-';
                                          final lastname = c['lastname']
                                                  ?.toString()
                                                  .trim() ??
                                              '';
                                          final phone =
                                              c['phone']?.toString().trim() ??
                                                  '';
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: Material(
                                                color: Colors.transparent,
                                                child: ListTile(
                                                  title: Text(
                                                    '$name $lastname'.trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: phone.isEmpty
                                                      ? null
                                                      : Text(phone),
                                                  trailing: const Icon(
                                                    Icons.chevron_right,
                                                    size: 18,
                                                  ),
                                                  onTap: () =>
                                                      Navigator.of(ctx).pop(c),
                                                )),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      await pickerRoute?.completed;
      searchCtrl.dispose();
    }
  }

  Future<void> showBookingSheet({
    required String initialDate,
    required String initialTime,
    Map<String, dynamic>? initialCustomer,
  }) async {
    if (_bookingOpen || !mounted) return;
    _bookingOpen = true;
    final loc = this.loc;
    try {
      if (!await ensureBookingAccess() || !mounted) {
        _bookingOpen = false;
        return;
      }
    } catch (_) {
      _bookingOpen = false;
      if (mounted) showBookingMessage(loc.calendarCreateFailed);
      return;
    }

    final dateCtrl = TextEditingController(
      text: _formatDateDisplay(_parseInputDateOrNow(initialDate)),
    );
    final timeCtrl = TextEditingController(text: initialTime);
    final notesCtrl = TextEditingController();
    final newNameCtrl = TextEditingController();
    final newLastNameCtrl = TextEditingController();
    final newPhoneCtrl = TextEditingController();
    final newEmailCtrl = TextEditingController();
    String? selectedTime = initialTime;
    Map<String, dynamic>? selectedCustomer = initialCustomer;
    bool createForNewCustomer = false;
    bool localIsFirstAppointment = false;
    List<Map<String, dynamic>> localSlots = [];
    List<Map<String, dynamic>> localCountries = [];
    int? localSelectedCountryId;
    bool localLoadingSlots = false;
    bool localLoadingCountries = false;
    String? localSlotsError;
    String? localCountriesError;
    String? localSaveError;
    bool countriesInitialized = false;
    // ── Design tokens ────────────────────────────────────────────────────────
    const bg = Color(0xFFFAFBFD);
    const surface = Colors.white;
    const accent = Color(0xFF0C2032);
    const muted = Color(0xFF627183);
    const border = Color(0xFFE5EAF1);
    const success = Color(0xFF18A058);
    const danger = Color(0xFFE53935);
    const radius = 14.0;

    InputDecoration field({
      required String label,
      String? hint,
      Widget? prefix,
    }) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefix,
          labelStyle: const TextStyle(fontSize: 13, color: muted),
          hintStyle: const TextStyle(fontSize: 13, color: muted),
          filled: true,
          fillColor: surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
        );

    if (!mounted) {
      return;
    }
    final viewportHeight = MediaQuery.sizeOf(context).height;
    ModalRoute<dynamic>? bookingRoute;
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: bg,
        constraints: BoxConstraints(
          maxHeight: viewportHeight * 0.96,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          bookingRoute = ModalRoute.of(ctx);
          return StatefulBuilder(
            builder: (ctx, rawSetModalState) {
              void setModalState(VoidCallback update) {
                if (mounted && ctx.mounted) rawSetModalState(update);
              }

              Future<void> loadSlots() async {
                final rawDate = dateCtrl.text.trim();
                if (rawDate.isEmpty) {
                  showBookingMessage(loc.calendarSelectDateFirst);
                  return;
                }
                final date = _normalizeSlotDate(rawDate);
                setModalState(() {
                  localLoadingSlots = true;
                  localSlotsError = null;
                  localSlots = [];
                });
                try {
                  final dio = await _buildBookingClient();
                  final resp = await dio.get(
                    '/api/appointments/time-slots',
                    queryParameters: {'date': date},
                  );
                  final envelope = _parseEnvelope(
                    resp.data,
                    statusCode: resp.statusCode,
                  );
                  final handled = await _handleIssueByCode(
                    envelope,
                    allowPackageNavigation: false,
                  );
                  if (handled) {
                    setModalState(() {
                      localLoadingSlots = false;
                      localSlotsError = _issueMessageForCode(
                        envelope,
                        fallback: loc.calendarFetchFailed(''),
                      );
                    });
                    return;
                  }
                  if (envelope.isSuccess) {
                    final raw = envelope.data;
                    final slots = raw is List
                        ? raw
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList()
                        : <Map<String, dynamic>>[];
                    setModalState(() {
                      localSlots = slots;
                      localLoadingSlots = false;
                      localSlotsError = null;
                      final hasSelected = localSlots.any(
                          (s) => (s['time']?.toString() ?? '') == selectedTime);
                      if (!hasSelected) {
                        selectedTime = null;
                        timeCtrl.clear();
                      }
                    });
                  } else {
                    setModalState(() {
                      localLoadingSlots = false;
                      localSlotsError = _issueMessageForCode(
                        envelope,
                        fallback: loc.calendarFetchFailed(''),
                      );
                    });
                  }
                } on AuthRequiredException {
                  setModalState(() {
                    localLoadingSlots = false;
                    localSlotsError = loc.calendarSessionMissing;
                  });
                } catch (e) {
                  setModalState(() {
                    localLoadingSlots = false;
                    localSlotsError = loc.calendarFetchFailed(e.toString());
                  });
                }
              }

              Future<void> pickDate() async {
                final now = UserTimeZone.now();
                final minDate = DateTime(now.year, now.month, now.day);
                final maxDate = DateTime(now.year + 5, 12, 31);
                final initial = _clampDate(
                  _parseInputDateOrNow(dateCtrl.text.trim()),
                  minDate,
                  maxDate,
                );
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: initial,
                  firstDate: minDate,
                  lastDate: maxDate,
                );
                if (picked == null) return;
                setModalState(() {
                  dateCtrl.text = _formatDateDisplay(picked);
                  localSlots = [];
                  localSlotsError = null;
                  selectedTime = null;
                  timeCtrl.clear();
                });
                await loadSlots();
              }

              Future<void> pickCustomer() async {
                final picked = await _showCustomerPickerSheet();
                if (picked == null) return;
                setModalState(() => selectedCustomer = picked);
                final customerId = _asInt(picked['id']);
                if (customerId == null) return;
                try {
                  final dio = await _buildBookingClient();
                  final resp = await dio
                      .get('/api/customers/$customerId/appointment-defaults');
                  final envelope = _parseEnvelope(
                    resp.data,
                    statusCode: resp.statusCode,
                  );
                  if (!envelope.isSuccess) {
                    await _handleIssueByCode(
                      envelope,
                      allowPackageNavigation: false,
                    );
                    return;
                  }
                  final raw = envelope.data;
                  if (raw is Map) {
                    setModalState(() {
                      if ((raw['last_note']?.toString().trim() ?? '')
                          .isNotEmpty) {
                        notesCtrl.text = raw['last_note'].toString();
                      }
                    });
                  }
                } catch (_) {}
              }

              Future<void> loadCountries() async {
                setModalState(() {
                  localLoadingCountries = true;
                  localCountriesError = null;
                });
                try {
                  final dio = await _buildBookingClient();
                  final resp = await dio.get('/api/settings/countries');
                  final envelope = _parseEnvelope(
                    resp.data,
                    statusCode: resp.statusCode,
                  );
                  final handled = await _handleIssueByCode(
                    envelope,
                    allowPackageNavigation: false,
                  );
                  if (handled) {
                    setModalState(() {
                      localLoadingCountries = false;
                      localCountriesError = _issueMessageForCode(
                        envelope,
                        fallback: loc.calendarFetchFailed(''),
                      );
                    });
                    return;
                  }
                  final raw = envelope.data;
                  final countries = raw is List
                      ? raw
                          .map((e) => Map<String, dynamic>.from(e as Map))
                          .toList()
                      : <Map<String, dynamic>>[];
                  setModalState(() {
                    localCountries = countries;
                    localLoadingCountries = false;
                    localCountriesError = null;
                    if (localSelectedCountryId == null &&
                        countries.isNotEmpty) {
                      localSelectedCountryId = _asInt(countries.first['id']);
                    }
                  });
                } on AuthRequiredException {
                  setModalState(() {
                    localLoadingCountries = false;
                    localCountriesError = loc.calendarSessionMissing;
                  });
                } catch (e) {
                  setModalState(() {
                    localLoadingCountries = false;
                    localCountriesError = loc.calendarFetchFailed(e.toString());
                  });
                }
              }

              Future<void> submit() async {
                if (_bookingBusy) return;
                setModalState(() => localSaveError = null);
                final token = await getAccessToken();
                if (token == null || token.isEmpty) {
                  setModalState(
                      () => localSaveError = loc.calendarSessionMissing);
                  return;
                }
                final dateInput = dateCtrl.text.trim();
                final createDate = _normalizeSlotDate(dateInput);
                final time =
                    _normalizeTimeToApi(selectedTime ?? timeCtrl.text) ?? '';
                if (createDate.isEmpty || time.isEmpty) {
                  setModalState(
                      () => localSaveError = loc.calendarDateTimeRequired);
                  return;
                }
                setModalState(() => _bookingBusy = true);
                Map<String, dynamic>? createdAppointment;
                try {
                  final dio =
                      await _buildBookingClient(includeJsonContentType: true);
                  if (createForNewCustomer) {
                    final firstName = newNameCtrl.text.trim();
                    final lastName = newLastNameCtrl.text.trim();
                    final phone = newPhoneCtrl.text.trim();
                    final email = newEmailCtrl.text.trim();
                    if (firstName.isEmpty ||
                        lastName.isEmpty ||
                        phone.isEmpty ||
                        localSelectedCountryId == null) {
                      setModalState(() =>
                          localSaveError = loc.appointmentsRequiredFields);
                      return;
                    }
                    final quickResp = await dio
                        .post('/api/appointments/quick_appointment', data: {
                      'customer_name': firstName,
                      'customer_lastname': lastName,
                      'country_id': localSelectedCountryId,
                      'phone': phone,
                      'email': email.isEmpty ? null : email,
                      'date': createDate,
                      'time': time,
                      'note': notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                      'is_first_appointment': localIsFirstAppointment,
                      'no_sms': true,
                      'no_reminder': true,
                    });
                    final quickEnvelope = _parseEnvelope(
                      quickResp.data,
                      statusCode: quickResp.statusCode,
                    );
                    if (quickEnvelope.isSuccess && quickEnvelope.data is Map) {
                      final appointments =
                          (quickEnvelope.data as Map)['appointments'];
                      if (appointments is List &&
                          appointments.isNotEmpty &&
                          appointments.first is Map) {
                        createdAppointment = Map<String, dynamic>.from(
                            appointments.first as Map);
                      }
                    }
                    if (!quickEnvelope.isSuccess) {
                      final handled = await _handleIssueByCode(
                        quickEnvelope,
                        allowPackageNavigation: false,
                        firstAppointmentFlow: localIsFirstAppointment,
                        onSlotBusy: () {
                          setModalState(() {
                            selectedTime = null;
                            timeCtrl.clear();
                          });
                        },
                      );
                      if (!handled) {
                        setModalState(() {
                          localSaveError = _issueMessageForCode(
                            quickEnvelope,
                            firstAppointmentFlow: localIsFirstAppointment,
                            fallback: loc.calendarCreateFailed,
                          );
                        });
                      }
                      return;
                    }
                  } else {
                    final customerId = _asInt(selectedCustomer?['id']);
                    if (customerId == null) {
                      setModalState(
                          () => localSaveError = loc.calendarSelectPerson);
                      return;
                    }
                    final defaultStatusId = await resolveBookingStatusId();
                    if (defaultStatusId == null) {
                      setModalState(
                          () => localSaveError = loc.appointmentsStatusMissing);
                      return;
                    }
                    try {
                      final validateResp = await dio.post(
                        '/api/appointments/validate',
                        data: {
                          'customer_id': customerId,
                          'date': createDate,
                          'time': time,
                        },
                      );
                      final validateEnvelope = _parseEnvelope(
                        validateResp.data,
                        statusCode: validateResp.statusCode,
                      );
                      if (!validateEnvelope.isSuccess) {
                        final handled = await _handleIssueByCode(
                          validateEnvelope,
                          allowPackageNavigation: false,
                          firstAppointmentFlow: localIsFirstAppointment,
                          onSlotBusy: () {
                            setModalState(() {
                              selectedTime = null;
                              timeCtrl.clear();
                            });
                          },
                        );
                        if (!handled) {
                          setModalState(() {
                            localSaveError = _issueMessageForCode(
                              validateEnvelope,
                              firstAppointmentFlow: localIsFirstAppointment,
                              fallback: loc.calendarDateTimeRequired,
                            );
                          });
                        } else if (_normalizedIssueCode(validateEnvelope) ==
                            'SLOT_BUSY') {
                          setModalState(() {
                            localSaveError = localIsFirstAppointment
                                ? loc.appointmentsConsecutiveSlotsUnavailable
                                : loc.calendarSlotBusy;
                          });
                        } else {
                          setModalState(() {
                            localSaveError = _issueMessageForCode(
                              validateEnvelope,
                              firstAppointmentFlow: localIsFirstAppointment,
                              fallback: loc.calendarDateTimeRequired,
                            );
                          });
                        }
                        return;
                      }
                    } on _BookingException catch (e) {
                      final envelope = _parseEnvelope(
                        e.response.data,
                        statusCode: e.response.statusCode,
                      );
                      final handled = await _handleIssueByCode(
                        envelope,
                        allowPackageNavigation: false,
                        firstAppointmentFlow: localIsFirstAppointment,
                        onSlotBusy: () {
                          setModalState(() {
                            selectedTime = null;
                            timeCtrl.clear();
                          });
                        },
                      );
                      if (!handled) {
                        setModalState(() {
                          localSaveError = _issueMessageForCode(
                            envelope,
                            firstAppointmentFlow: localIsFirstAppointment,
                            fallback: loc.calendarSlotBusy,
                          );
                        });
                      }
                      return;
                    }
                    final createResp =
                        await dio.post('/api/appointments', data: {
                      'customer_id': customerId,
                      'appointment_status_id': defaultStatusId,
                      'date': createDate,
                      'time': time,
                      'notes': notesCtrl.text.trim(),
                      'is_first_appointment': localIsFirstAppointment,
                      'no_sms': true,
                      'no_reminder': true,
                    });
                    final createEnvelope = _parseEnvelope(
                      createResp.data,
                      statusCode: createResp.statusCode,
                    );
                    if (createEnvelope.isSuccess &&
                        createEnvelope.data is Map) {
                      createdAppointment =
                          Map<String, dynamic>.from(createEnvelope.data as Map);
                    }
                    if (!createEnvelope.isSuccess) {
                      await _handleIssueByCode(
                        createEnvelope,
                        allowPackageNavigation: false,
                        firstAppointmentFlow: localIsFirstAppointment,
                      );
                      setModalState(() {
                        localSaveError = _issueMessageForCode(
                          createEnvelope,
                          firstAppointmentFlow: localIsFirstAppointment,
                          fallback: loc.calendarCreateFailed,
                        );
                      });
                      return;
                    }
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                  showBookingMessage(loc.calendarCreateSuccess, success: true);
                  try {
                    await refreshAfterBooking();
                  } catch (_) {}
                  if (mounted &&
                      createdAppointment != null &&
                      appointmentShareUrl(createdAppointment) != null) {
                    await showAppointmentDetails(context, createdAppointment);
                  }
                } on AuthRequiredException {
                  await handleBookingSessionExpired();
                } on _BookingException catch (e) {
                  final envelope = _parseEnvelope(
                    e.response.data,
                    statusCode: e.response.statusCode,
                  );
                  final handled = await _handleIssueByCode(
                    envelope,
                    allowPackageNavigation: false,
                    firstAppointmentFlow: localIsFirstAppointment,
                  );
                  final msg = _issueMessageForCode(
                    envelope,
                    firstAppointmentFlow: localIsFirstAppointment,
                    fallback: loc.calendarCreateFailed,
                  );
                  if (handled && msg.isNotEmpty) {
                    setModalState(() => localSaveError = msg);
                    return;
                  }
                  setModalState(() {
                    localSaveError = msg;
                  });
                } finally {
                  _bookingBusy = false;
                  setModalState(() {});
                }
              }

              if (createForNewCustomer && !countriesInitialized) {
                countriesInitialized = true;
                Future.microtask(loadCountries);
              }

              final media = MediaQuery.of(ctx);
              final bottomInset =
                  media.viewInsets.bottom + media.viewPadding.bottom + 24;
              final selectedCustomerName = selectedCustomer == null
                  ? ''
                  : '${selectedCustomer!['name'] ?? ''} ${selectedCustomer!['lastname'] ?? ''}'
                      .trim();

              return SafeArea(
                top: false,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: border,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.calendarAddAppointment,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: accent,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: loc.appointmentsClose,
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SectionLabel(text: loc.calendarPerson),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          children: [
                            _TabButton(
                              label: loc.calendarExistingPerson,
                              selected: !createForNewCustomer,
                              onTap: () => setModalState(() {
                                createForNewCustomer = false;
                              }),
                            ),
                            _TabButton(
                              label: loc.calendarNewPerson,
                              selected: createForNewCustomer,
                              onTap: () => setModalState(() {
                                createForNewCustomer = true;
                                selectedCustomer = null;
                                if (!countriesInitialized) {
                                  countriesInitialized = true;
                                  Future.microtask(loadCountries);
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!createForNewCustomer) ...[
                        GestureDetector(
                          onTap: pickCustomer,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(radius),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline,
                                    size: 18, color: muted),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedCustomerName.isEmpty
                                        ? loc.calendarSelectPerson
                                        : selectedCustomerName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedCustomerName.isEmpty
                                          ? muted
                                          : accent,
                                      fontWeight: selectedCustomerName.isEmpty
                                          ? FontWeight.w400
                                          : FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    size: 18, color: muted),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        _BookingFieldRow(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: newNameCtrl,
                                decoration: field(
                                  label: loc.appointmentsFieldName,
                                  hint: loc.appointmentsFieldNameHint,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: newLastNameCtrl,
                                decoration: field(
                                  label: loc.appointmentsFieldLastName,
                                  hint: loc.appointmentsFieldLastNameHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: localCountries.any((c) =>
                                  _asInt(c['id']) == localSelectedCountryId)
                              ? localSelectedCountryId
                              : null,
                          isExpanded: true,
                          decoration: field(
                            label: loc.appointmentsCountry,
                            hint: localLoadingCountries
                                ? loc.calendarLoading
                                : loc.appointmentsSelectCountry,
                            prefix: const Icon(Icons.public, size: 18),
                          ),
                          items: localCountries
                              .map((c) {
                                final id = _asInt(c['id']);
                                if (id == null) return null;
                                final name =
                                    (c['name']?.toString().trim().isNotEmpty ==
                                            true)
                                        ? c['name'].toString()
                                        : id.toString();
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(name),
                                );
                              })
                              .whereType<DropdownMenuItem<int>>()
                              .toList(),
                          onChanged: localLoadingCountries
                              ? null
                              : (value) => setModalState(() {
                                    localSelectedCountryId = value;
                                    localCountriesError = null;
                                  }),
                        ),
                        if (localCountriesError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            localCountriesError!,
                            style: const TextStyle(fontSize: 12, color: danger),
                          ),
                        ],
                        const SizedBox(height: 10),
                        TextField(
                          controller: newPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          decoration: field(
                            label: loc.appointmentsFieldPhone,
                            hint: loc.appointmentsFieldPhoneHint,
                            prefix: const Icon(Icons.phone_outlined, size: 18),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: newEmailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: field(
                            label: loc.customersEmail,
                            hint: loc.appointmentsFieldEmailHint,
                            prefix: const Icon(Icons.mail_outline, size: 18),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const _ThinDivider(),
                      const SizedBox(height: 20),
                      _SectionLabel(text: loc.calendarDateTimeSection),
                      const SizedBox(height: 10),
                      _BookingFieldRow(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dateCtrl,
                              readOnly: true,
                              onTap: pickDate,
                              decoration: field(
                                label: loc.date,
                                hint: loc.calendarDateHint,
                                prefix: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: timeCtrl,
                              readOnly: true,
                              decoration: field(
                                label: loc.timeSelect,
                                hint: loc.calendarTimeSlotHint,
                                prefix: const Icon(Icons.access_time, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: localLoadingSlots ? null : loadSlots,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: const BorderSide(color: border, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: localLoadingSlots
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.schedule, size: 16),
                                    const SizedBox(width: 6),
                                    Flexible(
                                        child: Text(
                                      loc.calendarFetchAvailableSlots,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                                  ],
                                ),
                        ),
                      ),
                      if (localSlotsError != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: danger.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: danger.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 14, color: danger),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  localSlotsError!,
                                  style: const TextStyle(
                                      fontSize: 12, color: danger),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (localSlots.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: localSlots.map((slot) {
                            final slotTime = slot['time']?.toString() ?? '';
                            final booked =
                                slot['booked'] == true || slot['booked'] == 1;
                            final selected = selectedTime == slotTime;
                            return GestureDetector(
                              onTap: booked
                                  ? null
                                  : () => setModalState(() {
                                        selectedTime = slotTime;
                                        timeCtrl.text = slotTime;
                                        localSlotsError = null;
                                      }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: booked
                                      ? const Color(0xFFF3F3F3)
                                      : selected
                                          ? success
                                          : surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: booked
                                        ? border
                                        : selected
                                            ? success
                                            : border,
                                  ),
                                ),
                                child: Text(
                                  slotTime,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: booked
                                        ? muted
                                        : selected
                                            ? Colors.white
                                            : accent,
                                    decoration: booked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const _ThinDivider(),
                      const SizedBox(height: 20),
                      _SectionLabel(text: loc.note),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: field(label: '', hint: loc.calendarNoteHint)
                            .copyWith(labelText: null),
                      ),
                      const SizedBox(height: 20),
                      const _ThinDivider(),
                      const SizedBox(height: 8),
                      _MinimalSwitch(
                        label: loc.appointmentsFirstAppointment,
                        value: localIsFirstAppointment,
                        onChanged: (v) =>
                            setModalState(() => localIsFirstAppointment = v),
                      ),
                      if (localSaveError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: danger.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 14,
                                  color: danger,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  localSaveError!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: danger,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _bookingBusy ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.black26,
                            disabledForegroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: _bookingBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  loc.save,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      await bookingRoute?.completed;
      _bookingOpen = false;
      for (final controller in [
        dateCtrl,
        timeCtrl,
        notesCtrl,
        newNameCtrl,
        newLastNameCtrl,
        newPhoneCtrl,
        newEmailCtrl
      ]) {
        controller.dispose();
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFF627183),
        ),
      );
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color:
                  selected ? const Color(0xFF0C2032) : const Color(0xFF627183),
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MinimalSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0C2032),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _BookingFieldRow extends StatelessWidget {
  final List<Widget> children;
  const _BookingFieldRow({required this.children});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(14) > 20) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children
                  .map((child) => child is Expanded
                      ? child.child
                      : child is SizedBox && child.width != null
                          ? const SizedBox(height: 12)
                          : child)
                  .toList());
        }
        return Row(children: children);
      });
}
