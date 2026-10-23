import '../widgets/studio_page.dart';
import '../user_timezone.dart';
import 'dart:convert';

import 'package:liik_mobile/auth.dart';
import 'package:liik_mobile/config.dart';
import 'package:liik_mobile/login_page.dart';
import 'package:liik_mobile/pages/working_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../utils/appointment_date_utils.dart';
import '../widgets/main_nav.dart';
import '../widgets/appointment_booking_flow.dart';
import '../widgets/appointment_details.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';

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

DateTime _startOfWeek(DateTime date) {
  final weekday = date.weekday; // 1 = Mon
  return DateTime(date.year, date.month, date.day).subtract(
    Duration(days: weekday - 1),
  );
}

Future<String?> _getToken() async {
  return getAccessToken();
}

const _authRetriedKey = '__auth_retried__';

Future<Dio> _buildAuthedDio({bool includeJsonContentType = false}) async {
  final token = await _getToken();
  if (token == null || token.isEmpty) {
    throw const AuthRequiredException();
  }

  final headers = <String, dynamic>{
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };
  if (includeJsonContentType) {
    headers['Content-Type'] = 'application/json';
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      headers: headers,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (err, handler) async {
        final alreadyRetried =
            err.requestOptions.extra[_authRetriedKey] == true;
        if (err.response?.statusCode != 401 || alreadyRetried) {
          return handler.next(err);
        }

        final refreshed = await refreshAccessToken();
        if (refreshed == null || refreshed.isEmpty) {
          return handler.next(err);
        }

        final req = err.requestOptions;
        req.extra[_authRetriedKey] = true;
        req.headers['Authorization'] = 'Bearer $refreshed';
        try {
          final retryResp = await dio.fetch(req);
          return handler.resolve(retryResp);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      },
    ),
  );

  return dio;
}

Color _bootstrapColor(String? alias) {
  switch (alias) {
    case 'primary':
      return const Color(0xFF0D6EFD);
    case 'secondary':
      return const Color(0xFF6C757D);
    case 'success':
      return const Color(0xFF198754);
    case 'danger':
      return const Color(0xFFDC3545);
    case 'warning':
      return const Color(0xFFFFC107);
    case 'info':
      return const Color(0xFF0DCAF0);
    case 'light':
      return const Color(0xFFF8F9FA);
    case 'dark':
      return const Color(0xFF212529);
    default:
      return Colors.blueGrey;
  }
}

class WeekDayInfo {
  final String date; // YYYY-MM-DD
  final int dayOfWeekIso;
  final String label;
  final String shortLabel;
  final String displayDate; // e.g. 27.05
  final bool isToday;
  final bool isWorking;

  const WeekDayInfo({
    required this.date,
    required this.dayOfWeekIso,
    required this.label,
    required this.shortLabel,
    required this.displayDate,
    required this.isToday,
    required this.isWorking,
  });

  factory WeekDayInfo.fromJson(Map<String, dynamic> json) {
    return WeekDayInfo(
      date: json['date']?.toString() ?? '',
      dayOfWeekIso: json['day_of_week_iso'] is int
          ? json['day_of_week_iso'] as int
          : int.tryParse(json['day_of_week_iso']?.toString() ?? '') ?? 1,
      label: json['label']?.toString() ?? '',
      shortLabel: json['short_label']?.toString() ?? '',
      displayDate: json['display_date']?.toString() ?? '',
      isToday: json['is_today'] == true || json['is_today'] == 1,
      isWorking: json['is_working'] == true || json['is_working'] == 1,
    );
  }
}

class SlotInfo {
  final String time; // HH:MM
  final bool booked;
  final int slotIndex;
  final int period;

  const SlotInfo({
    required this.time,
    required this.booked,
    required this.slotIndex,
    required this.period,
  });

  factory SlotInfo.fromJson(Map<String, dynamic> json) {
    return SlotInfo(
      time: json['time']?.toString() ?? '',
      booked: json['booked'] == true || json['booked'] == 1,
      slotIndex: json['slot_index'] is int
          ? json['slot_index'] as int
          : int.tryParse(json['slot_index']?.toString() ?? '') ?? 0,
      period: json['period'] is int
          ? json['period'] as int
          : int.tryParse(json['period']?.toString() ?? '') ?? 0,
    );
  }
}

class WeeklyCalendarData {
  final DateTime weekStart;
  final DateTime weekEnd;
  final String weekRangeText;
  final List<WeekDayInfo> weekDays;
  final Map<String, List<SlotInfo>> timeSlotsByDay;
  final List<String> timeGrid;
  final Map<String, List<Map<String, dynamic>>> appointmentsBySlot;
  final Map<String, String> statusColors;
  final Map<String, dynamic> workingPreferences;
  final bool hasTimeSlots;
  final bool? hasUserPack;

  WeeklyCalendarData({
    required this.weekStart,
    required this.weekEnd,
    required this.weekRangeText,
    required this.weekDays,
    required this.timeSlotsByDay,
    required this.timeGrid,
    required this.appointmentsBySlot,
    required this.statusColors,
    required this.workingPreferences,
    required this.hasTimeSlots,
    required this.hasUserPack,
  });

  factory WeeklyCalendarData.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value, {bool defaultValue = false}) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is num) return value != 0;
      final str = value.toString().trim().toLowerCase();
      return str == 'true' || str == '1' || str == 'yes';
    }

    final weekDays = (json['week_days'] as List? ?? [])
        .map((e) => WeekDayInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final slotsMap = <String, List<SlotInfo>>{};
    final rawSlotsAny = json['time_slots_by_day'];
    if (rawSlotsAny is Map) {
      rawSlotsAny.forEach((key, value) {
        if (value is List) {
          slotsMap[key.toString()] = value
              .map((e) => SlotInfo.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          slotsMap[key.toString()] = const <SlotInfo>[];
        }
      });
    }
    final appointmentsBySlot = <String, List<Map<String, dynamic>>>{};
    final rawApptsAny = json['appointments_by_slot'];
    if (rawApptsAny is Map) {
      rawApptsAny.forEach((key, value) {
        if (value is List) {
          appointmentsBySlot[key.toString()] = value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      });
    }

    DateTime parseDate(String v) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return UserTimeZone.now();
      }
    }

    final statusColorsMap = <String, String>{};
    final rawColors = json['status_colors'];
    if (rawColors is Map) {
      rawColors.forEach((k, v) {
        statusColorsMap[k.toString()] = v?.toString() ?? '';
      });
    }
    final timeGrid = (json['time_grid'] as List? ?? [])
        .map((e) => e?.toString() ?? '')
        .toList();

    final rawTimeSlot = json['time_slot'];
    bool hasTimeSlots = parseBool(rawTimeSlot, defaultValue: true);
    bool? hasUserPack;
    final rawUserPack = json['user_pack'] ?? json['userPack'];
    if (rawUserPack != null) {
      hasUserPack = parseBool(rawUserPack);
    }

    // Eğer API boş zaman aralığı haritası döndüyse uyarıyı göster
    final hasAnySlot = slotsMap.values.any((slots) => slots.isNotEmpty);
    if (!hasAnySlot || timeGrid.isEmpty) {
      hasTimeSlots = false;
    }

    return WeeklyCalendarData(
      weekStart: parseDate(json['week_start_date']?.toString() ?? ''),
      weekEnd: parseDate(json['week_end_date']?.toString() ?? ''),
      weekRangeText: json['week_range_text']?.toString() ?? '',
      weekDays: weekDays,
      timeSlotsByDay: slotsMap,
      timeGrid: timeGrid,
      appointmentsBySlot: appointmentsBySlot,
      statusColors: statusColorsMap,
      workingPreferences: json['working_preferences'] is Map
          ? Map<String, dynamic>.from(json['working_preferences'])
          : <String, dynamic>{},
      hasTimeSlots: hasTimeSlots,
      hasUserPack: hasUserPack,
    );
  }
}

final weeklyCalendarProvider =
    FutureProvider.autoDispose.family<WeeklyCalendarData, DateTime>(
  (ref, weekStart) async {
    Dio dio;
    try {
      dio = await _buildAuthedDio();
    } on AuthRequiredException {
      throw Exception('Session not found.');
    }

    final weekStartStr =
        '${weekStart.year.toString().padLeft(4, '0')}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    Response resp;
    try {
      resp = await dio.get(
        '/api/appointments/weekly',
        queryParameters: {'week_start_date': weekStartStr},
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString())
          : null;
      throw Exception(
          'Could not load weekly calendar${status != null ? ' (HTTP $status)' : ''}${msg != null ? ': $msg' : ''}');
    }

    if (resp.statusCode == 401) {
      throw DioException(
        requestOptions: resp.requestOptions,
        response: resp,
        message: 'unauthorized',
      );
    }

    if (resp.statusCode != 200) {
      throw Exception(
          'Could not load weekly calendar (HTTP ${resp.statusCode ?? '??'}).');
    }

    final data = resp.data is Map
        ? resp.data
        : (resp.data is String ? jsonDecode(resp.data) : {});
    final payload = data['data'] ?? data;
    if (payload is! Map) {
      throw Exception('Unexpected response format.');
    }
    return WeeklyCalendarData.fromJson(Map<String, dynamic>.from(payload));
  },
);

class CalendarPage extends ConsumerStatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onTabSelected;

  const CalendarPage({
    super.key,
    this.showBottomNav = true,
    this.onTabSelected,
  });

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage>
    with AppointmentBookingFlow<CalendarPage> {
  late DateTime _weekStart;
  String? _expandedDayDate;
  String? _autoFocusedWeekKey;
  String? _autoExpandedWeekKey;
  final Map<String, GlobalKey> _daySectionKeys = {};
  bool _slotActionBusy = false;
  String? _appointmentsLookupCacheKey;
  Map<String, List<Map<String, dynamic>>> _appointmentsLookupCache =
      const <String, List<Map<String, dynamic>>>{};
  static final RegExp _timeKeyPattern = RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?$');
  static const Color _primaryColor = Color(0xFF0866EB);
  bool? _hasUserPack;

  @override
  AppLocalizations get loc => AppLocalizations.of(context);
  bool _asBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final str = value.toString().trim().toLowerCase();
    return str == '1' || str == 'true' || str == 'yes';
  }

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

  Future<void> _redirectToLogin() async {
    await clearTokens();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage(onLocaleChange: (_) {})),
      (_) => false,
    );
  }

  Future<bool> _handleIssueByCode(
    _ApiEnvelope envelope, {
    bool allowPackageNavigation = true,
    bool firstAppointmentFlow = false,
    VoidCallback? onSlotBusy,
  }) async {
    final code = _normalizedIssueCode(envelope);
    if (code.isEmpty &&
        envelope.statusCode >= 200 &&
        envelope.statusCode < 300) {
      return false;
    }
    switch (code) {
      case 'NO_PACKAGE':
        _hasUserPack = false;
        _showSnack(loc.appointmentsPlanRequired);

        return true;
      case 'HOLIDAY':
        _showSnack(_holidayWarningMessage(envelope));
        return true;
      case 'SLOT_BUSY':
        onSlotBusy?.call();
        final message = envelope.message?.trim();
        _showSnack(
          message != null && message.isNotEmpty
              ? message
              : (firstAppointmentFlow
                  ? loc.appointmentsConsecutiveSlotsUnavailable
                  : loc.calendarSlotBusy),
        );
        return true;
      case 'VALIDATION_ERROR':
        _showSnack(
          _firstFieldError(envelope.errors) ??
              envelope.message ??
              loc.calendarDateTimeRequired,
        );
        return true;
      case 'UNAUTHORIZED':
        _showSnack(loc.calendarSessionExpired);
        await _redirectToLogin();
        return true;
      case 'FORBIDDEN':
        _showSnack(loc.commonForbiddenAction);
        return true;
      default:
        if (envelope.statusCode == 401) {
          _showSnack(loc.calendarSessionExpired);
          await _redirectToLogin();
          return true;
        }
        if (envelope.statusCode == 403) {
          _showSnack(loc.commonForbiddenAction);
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

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(UserTimeZone.now());
    UserTimeZone.changes.addListener(_onTimezoneChanged);
  }

  void _onTimezoneChanged() {
    if (!mounted || UserTimeZone.name == null) return;
    _setWeekStartFromDate(UserTimeZone.now());
    ref.invalidate(weeklyCalendarProvider(_weekStart));
  }

  @override
  void dispose() {
    UserTimeZone.changes.removeListener(_onTimezoneChanged);
    super.dispose();
  }

  void _showSnack(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<bool> _ensurePackageForAppointmentActions() async {
    _hasUserPack = await _fetchUserPackStatus();
    if (_hasUserPack == true) return true;
    if (!mounted) return false;

    _showSnack(loc.appointmentsPlanRequired);
    return false;
  }

  Future<bool> _fetchUserPackStatus() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return true;
    try {
      final response = await authGet(
        Uri.parse('$apiBaseUrl/api/appointments')
            .replace(queryParameters: {'per_page': '1'}),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      final envelope = _parseEnvelope(
        response.body,
        statusCode: response.statusCode,
      );
      final code = (envelope.code ?? '').toUpperCase();
      if (code == 'NO_PACKAGE') return false;
      if (code == 'UNAUTHORIZED' || response.statusCode == 401) {
        await _redirectToLogin();
        return false;
      }
      if (!envelope.isSuccess) return true;

      final rawData = envelope.data;
      dynamic candidate;
      candidate = envelope.payload['user_pack'] ?? envelope.payload['userPack'];
      if (candidate == null && rawData is Map) {
        candidate = rawData['user_pack'] ?? rawData['userPack'];
      }
      if (candidate == null) return true;
      return _asBool(candidate);
    } catch (_) {
      return true;
    }
  }

  void _changeWeek(int deltaWeeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * deltaWeeks));
      _expandedDayDate = null;
      _autoFocusedWeekKey = null;
      _autoExpandedWeekKey = null;
      _daySectionKeys.clear();
    });
  }

  void _setWeekStartFromDate(DateTime date) {
    setState(() {
      _weekStart = _startOfWeek(date);
      _expandedDayDate = null;
      _autoFocusedWeekKey = null;
      _autoExpandedWeekKey = null;
      _daySectionKeys.clear();
    });
  }

  Future<void> _pickWeekFromCalendar() async {
    final now = UserTimeZone.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (picked == null) return;
    _setWeekStartFromDate(picked);
  }

  String _toIsoDate(DateTime dt) {
    return AppointmentDateUtils.toIsoDate(dt);
  }

  String _formatDateDisplay(DateTime date) {
    return AppointmentDateUtils.formatDateDisplay(date);
  }

  DateTime _parseInputDateOrNow(String value) {
    return AppointmentDateUtils.parseInputDateOrNow(value);
  }

  String _normalizeSlotDate(String rawDate) {
    return AppointmentDateUtils.normalizeSlotDate(rawDate);
  }

  DateTime _clampDate(DateTime date, DateTime min, DateTime max) {
    if (date.isBefore(min)) return min;
    if (date.isAfter(max)) return max;
    return date;
  }

  String? _normalizeDateToApi(String input) {
    return AppointmentDateUtils.normalizeDateToApi(input);
  }

  String _weekIdentity(WeeklyCalendarData data) => _toIsoDate(data.weekStart);

  void _syncExpandedDayAndFocus(WeeklyCalendarData data) {
    if (data.weekDays.isEmpty) return;

    final weekKey = _weekIdentity(data);
    final dates = data.weekDays.map((d) => d.date).toSet();
    final hasValidExpanded =
        _expandedDayDate != null && dates.contains(_expandedDayDate);

    String? selected = hasValidExpanded ? _expandedDayDate : null;
    if (!hasValidExpanded && _autoExpandedWeekKey != weekKey) {
      final todayIso = _toIsoDate(UserTimeZone.now());
      selected = dates.contains(todayIso) ? todayIso : data.weekDays.first.date;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _expandedDayDate = selected;
          _autoExpandedWeekKey = weekKey;
        });
      });
    }

    if (_autoFocusedWeekKey == weekKey) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || selected == null) return;
      final targetKey = _daySectionKeys[selected];
      final targetContext = targetKey?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      }
      _autoFocusedWeekKey = weekKey;
    });
  }

  String? _nearestUpcomingSlotTime(
    List<SlotInfo> slots,
    String dayIso, {
    String? currentTime,
  }) {
    if (slots.isEmpty) return null;
    final todayIso = _toIsoDate(UserTimeZone.now());
    if (dayIso != todayIso) return null;
    final now = currentTime ?? DateFormat('HH:mm').format(UserTimeZone.now());
    for (final slot in slots) {
      if (slot.time.compareTo(now) >= 0) return slot.time;
    }
    return slots.first.time;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  int? _resolveStatusId(Map<String, dynamic> appointment) {
    final topLevel = _asInt(appointment['appointment_status_id']);
    if (topLevel != null) return topLevel;
    if (appointment['appointment_status'] is Map) {
      return _asInt((appointment['appointment_status'] as Map)['id']);
    }
    return null;
  }

  String _localizedStatusLabel(Map<String, dynamic> status) {
    final alias = status['alias']?.toString();
    final trMap = {
      'pending': loc.statusPending,
      'confirmed': loc.statusConfirmed,
      'rescheduled': loc.statusRescheduled,
      'completed': loc.statusCompleted,
      'cancelled': loc.statusCancelled,
      'no_show': loc.statusNoShow,
    };
    if (alias != null && trMap.containsKey(alias)) {
      return trMap[alias]!;
    }
    return status['name']?.toString() ?? (alias ?? loc.status);
  }

  Future<void> _refreshWeek() async {
    final refreshFuture =
        ref.refresh(weeklyCalendarProvider(_weekStart).future);
    try {
      await refreshFuture;
    } catch (_) {/* Provider displays the retry state. */}
  }

  @override
  Future<bool> ensureBookingAccess() => _ensurePackageForAppointmentActions();
  @override
  Future<void> refreshAfterBooking() => _refreshWeek();
  @override
  Future<void> handleBookingSessionExpired() => _redirectToLogin();
  @override
  void showBookingMessage(String message, {bool success = false}) =>
      _showSnack(message, success: success);

  Future<void> _showSlotActionSheet({
    required Map<String, dynamic> appointment,
    required String initialDate,
    required String initialTime,
    required bool createNewForCustomer,
  }) async {
    if (!await _ensurePackageForAppointmentActions()) return;

    final appointmentId = _asInt(appointment['id']);
    final customerId = _asInt(appointment['customer_id']);
    final statusId = _resolveStatusId(appointment);
    if (customerId == null) {
      _showSnack(loc.calendarCustomerInfoMissing);
      return;
    }
    if (!createNewForCustomer && appointmentId == null) {
      _showSnack(loc.calendarAppointmentInfoMissing);
      return;
    }
    if (statusId == null) {
      _showSnack(loc.calendarAppointmentStatusMissing);
      return;
    }

    final parsedInitialDate = _parseInputDateOrNow(initialDate);
    final dateCtrl = TextEditingController(
      text: _formatDateDisplay(parsedInitialDate),
    );
    final timeCtrl = TextEditingController(text: initialTime);
    final notesCtrl =
        TextEditingController(text: appointment['notes']?.toString() ?? '');
    int? localSelectedStatusId = statusId;
    List<Map<String, dynamic>> localStatuses = [];
    bool localLoadingStatuses = false;
    String? localStatusesError;
    bool statusesInitialized = false;
    List<Map<String, dynamic>> localSlots = [];
    bool localLoadingSlots = false;
    String? localSlotsError;
    String? localSelectedTime = initialTime;
    const bg = Color(0xFFF9F9F9);
    const surface = Colors.white;
    const accent = Color(0xFF111111);
    const muted = Color(0xFF8A8A8A);
    const border = Color(0xFFE8E8E8);
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
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> loadSlots() async {
              final rawDate = dateCtrl.text.trim();
              if (rawDate.isEmpty) {
                _showSnack(loc.calendarSelectDateFirst);
                return;
              }
              final date = _normalizeSlotDate(rawDate);

              setModalState(() {
                localLoadingSlots = true;
                localSlotsError = null;
                localSlots = [];
              });

              try {
                final dio = await _buildAuthedDio();
                final resp = await dio.get(
                  '/api/appointments/time-slots',
                  queryParameters: {'date': date},
                );
                final envelope = _parseEnvelope(
                  resp.data,
                  statusCode: resp.statusCode ?? 200,
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
                      (s) => (s['time']?.toString() ?? '') == localSelectedTime,
                    );
                    if (!hasSelected) {
                      localSelectedTime = null;
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
              } on DioException catch (e) {
                final status = e.response?.statusCode;
                final msg = e.response?.data is Map
                    ? (e.response?.data['message']?.toString() ??
                        e.response?.data['error']?.toString())
                    : null;
                setModalState(() {
                  localLoadingSlots = false;
                  localSlotsError =
                      '${loc.calendarFetchFailedStatus(status ?? '??')}${msg != null ? ': $msg' : ''}';
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
                localSelectedTime = null;
                timeCtrl.clear();
              });
              await loadSlots();
            }

            Future<void> loadStatuses() async {
              setModalState(() {
                localLoadingStatuses = true;
                localStatusesError = null;
              });

              try {
                final dio = await _buildAuthedDio();
                final resp =
                    await dio.get('/api/settings/appointment-statuses');
                final envelope = _parseEnvelope(
                  resp.data,
                  statusCode: resp.statusCode ?? 200,
                );
                final handled = await _handleIssueByCode(
                  envelope,
                  allowPackageNavigation: false,
                );
                if (handled) {
                  setModalState(() {
                    localLoadingStatuses = false;
                    localStatusesError = _issueMessageForCode(
                      envelope,
                      fallback: loc.calendarFetchFailed(''),
                    );
                  });
                  return;
                }
                final raw = envelope.data;
                final fetched = raw is List
                    ? raw
                        .map((e) => Map<String, dynamic>.from(e as Map))
                        .toList()
                    : <Map<String, dynamic>>[];
                setModalState(() {
                  localStatuses = fetched;
                  localLoadingStatuses = false;
                  localStatusesError = null;
                  final hasSelected = localStatuses.any(
                    (s) => _asInt(s['id']) == localSelectedStatusId,
                  );
                  if (!hasSelected && localSelectedStatusId != null) {
                    localStatuses.insert(0, {
                      'id': localSelectedStatusId,
                      'alias': appointment['appointment_status']?['alias']
                          ?.toString(),
                      'name': appointment['appointment_status']?['name']
                              ?.toString() ??
                          loc.status,
                    });
                  }
                });
              } on DioException catch (e) {
                final status = e.response?.statusCode;
                final msg = e.response?.data is Map
                    ? (e.response?.data['message']?.toString() ??
                        e.response?.data['error']?.toString())
                    : null;
                setModalState(() {
                  localLoadingStatuses = false;
                  localStatusesError =
                      '${loc.calendarFetchFailedStatus(status ?? '??')}${msg != null ? ': $msg' : ''}';
                });
              } on AuthRequiredException {
                setModalState(() {
                  localLoadingStatuses = false;
                  localStatusesError = loc.calendarSessionMissing;
                });
              } catch (e) {
                setModalState(() {
                  localLoadingStatuses = false;
                  localStatusesError = loc.calendarFetchFailed(e.toString());
                });
              }
            }

            Future<void> submit() async {
              if (_slotActionBusy) return;
              final dateInput = dateCtrl.text.trim();
              final time =
                  _normalizeTimeToApi(localSelectedTime ?? timeCtrl.text) ?? '';
              final apiDate = _normalizeDateToApi(dateInput);
              final createDate = _normalizeSlotDate(dateInput);
              final initialDateNormalized = _normalizeDateToApi(initialDate) ??
                  _normalizeSlotDate(initialDate);
              final initialTimeNormalized =
                  _normalizeTimeToApi(initialTime) ?? initialTime.trim();
              if (localSelectedStatusId == null) {
                _showSnack(loc.appointmentsStatusSelectHint);
                return;
              }
              if ((apiDate == null && !createNewForCustomer) ||
                  createDate.isEmpty ||
                  time.isEmpty) {
                _showSnack(loc.calendarDateTimeRequired);
                return;
              }

              setState(() {
                _slotActionBusy = true;
              });

              try {
                final dio = await _buildAuthedDio(includeJsonContentType: true);
                final payload = {
                  'customer_id': customerId,
                  'appointment_status_id': localSelectedStatusId,
                  'date': createNewForCustomer ? createDate : apiDate,
                  'time': time,
                  'notes': notesCtrl.text.trim(),
                  'no_sms': true,
                  'no_reminder': true,
                };

                final selectedDateForValidation =
                    createNewForCustomer ? createDate : (apiDate ?? createDate);
                final shouldValidateSlot = createNewForCustomer ||
                    selectedDateForValidation != initialDateNormalized ||
                    time != initialTimeNormalized;

                if (shouldValidateSlot) {
                  final validateResp = await dio.post(
                    '/api/appointments/validate',
                    data: {
                      'customer_id': customerId,
                      'date': selectedDateForValidation,
                      'time': time,
                    },
                  );
                  final validateEnvelope = _parseEnvelope(
                    validateResp.data,
                    statusCode: validateResp.statusCode ?? 200,
                  );
                  if (!validateEnvelope.isSuccess) {
                    final handled = await _handleIssueByCode(
                      validateEnvelope,
                      allowPackageNavigation: false,
                      onSlotBusy: () {
                        setModalState(() {
                          localSelectedTime = null;
                          timeCtrl.clear();
                        });
                      },
                    );
                    if (!handled) {
                      _showSnack(
                        _issueMessageForCode(
                          validateEnvelope,
                          fallback: loc.calendarSlotBusy,
                        ),
                      );
                    }
                    return;
                  }
                }

                if (createNewForCustomer) {
                  final createResp =
                      await dio.post('/api/appointments', data: payload);
                  final createEnvelope = _parseEnvelope(
                    createResp.data,
                    statusCode: createResp.statusCode ?? 200,
                  );
                  if (!createEnvelope.isSuccess) {
                    final handled = await _handleIssueByCode(
                      createEnvelope,
                      allowPackageNavigation: false,
                    );
                    if (!handled) {
                      _showSnack(
                        _issueMessageForCode(
                          createEnvelope,
                          fallback: loc.calendarCreateFailed,
                        ),
                      );
                    }
                    return;
                  }
                  _showSnack(loc.calendarCreateSuccess, success: true);
                } else {
                  final updateResp = await dio
                      .put('/api/appointments/$appointmentId', data: payload);
                  final updateEnvelope = _parseEnvelope(
                    updateResp.data,
                    statusCode: updateResp.statusCode ?? 200,
                  );
                  if (!updateEnvelope.isSuccess) {
                    final handled = await _handleIssueByCode(
                      updateEnvelope,
                      allowPackageNavigation: false,
                    );
                    if (!handled) {
                      _showSnack(
                        _issueMessageForCode(
                          updateEnvelope,
                          fallback: loc.calendarUpdateFailed,
                        ),
                      );
                    }
                    return;
                  }
                  _showSnack(loc.calendarUpdateSuccess, success: true);
                }

                if (ctx.mounted) Navigator.of(ctx).pop();
                await _refreshWeek();
              } on DioException catch (e) {
                final envelope = _parseEnvelope(
                  e.response?.data,
                  statusCode: e.response?.statusCode ?? 0,
                );
                final handled = await _handleIssueByCode(
                  envelope,
                  allowPackageNavigation: false,
                  onSlotBusy: () {
                    setModalState(() {
                      localSelectedTime = null;
                      timeCtrl.clear();
                    });
                  },
                );
                if (!handled) {
                  _showSnack(
                    _issueMessageForCode(
                      envelope,
                      fallback: createNewForCustomer
                          ? loc.calendarCreateFailed
                          : loc.calendarUpdateFailed,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _slotActionBusy = false;
                  });
                }
              }
            }

            final media = MediaQuery.of(ctx);
            final bottomInset =
                media.viewInsets.bottom + media.viewPadding.bottom + 24;
            if (!statusesInitialized) {
              statusesInitialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                loadStatuses();
              });
            }

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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            createNewForCustomer
                                ? loc.rescheduleAppointment
                                : loc.editAppointment,
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
                    const SizedBox(height: 20),
                    _SectionLabel(text: loc.calendarDateTimeSection),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dateCtrl,
                            readOnly: true,
                            onTap: pickDate,
                            decoration: field(
                              label: loc.date,
                              hint: loc.calendarDateHint,
                              prefix: const Icon(Icons.calendar_today_outlined,
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
                                  Text(
                                    loc.calendarFetchAvailableSlots,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                          border:
                              Border.all(color: danger.withValues(alpha: 0.2)),
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
                    if (localSlots.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: localSlots.map((slot) {
                          final slotTime = slot['time']?.toString() ?? '';
                          final booked =
                              slot['booked'] == true || slot['booked'] == 1;
                          final canUseBooked =
                              !createNewForCustomer && slotTime == initialTime;
                          final disabled = booked && !canUseBooked;
                          final selected = localSelectedTime == slotTime;
                          return GestureDetector(
                            onTap: disabled
                                ? null
                                : () {
                                    setModalState(() {
                                      localSelectedTime = slotTime;
                                      timeCtrl.text = slotTime;
                                      localSlotsError = null;
                                    });
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: disabled
                                    ? const Color(0xFFF3F3F3)
                                    : selected
                                        ? success
                                        : surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: disabled
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
                                  color: disabled
                                      ? muted
                                      : selected
                                          ? Colors.white
                                          : accent,
                                  decoration: disabled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    const _ThinDivider(),
                    const SizedBox(height: 20),
                    _SectionLabel(text: loc.status),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: localSelectedStatusId,
                      isExpanded: true,
                      decoration: field(
                        label: loc.status,
                        hint: localLoadingStatuses
                            ? loc.calendarLoading
                            : loc.appointmentsStatusSelectHint,
                        prefix: const Icon(Icons.flag_outlined, size: 18),
                      ),
                      items: localStatuses
                          .map(
                            (s) => DropdownMenuItem<int>(
                              value: _asInt(s['id']),
                              child: Text(_localizedStatusLabel(s)),
                            ),
                          )
                          .toList(),
                      onChanged: localLoadingStatuses
                          ? null
                          : (val) => setModalState(() {
                                localSelectedStatusId = val;
                                localStatusesError = null;
                              }),
                    ),
                    if (localStatusesError != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: localLoadingStatuses ? null : loadStatuses,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text(
                          localStatusesError!,
                          style: const TextStyle(fontSize: 12),
                        ),
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
                      decoration:
                          field(label: '', hint: loc.calendarNoteHint).copyWith(
                        labelText: null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _ThinDivider(),
                    const SizedBox(height: 8),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _slotActionBusy ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              accent.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                        ),
                        child: _slotActionBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
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
  }

  bool _dayWorking(WeekDayInfo day, Map<String, dynamic> prefs) {
    final pref = prefs[day.dayOfWeekIso.toString()];
    final prefWorking = pref is Map
        ? (pref['is_working'] == true || pref['is_working'] == 1)
        : true;
    return day.isWorking && prefWorking;
  }

  String _dayFullLabel(WeekDayInfo day) {
    switch (day.dayOfWeekIso) {
      case 1:
        return loc.dayMonFull;
      case 2:
        return loc.dayTueFull;
      case 3:
        return loc.dayWedFull;
      case 4:
        return loc.dayThuFull;
      case 5:
        return loc.dayFriFull;
      case 6:
        return loc.daySatFull;
      case 7:
      default:
        return loc.daySunFull;
    }
  }

  String _monthTitle() {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat('MMMM yyyy', localeTag);
    final text = formatter.format(_weekStart);
    return text[0].toUpperCase() + text.substring(1);
  }

  String _localizedWeekRangeText(WeeklyCalendarData data) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat('d MMM', localeTag);
    return '${formatter.format(data.weekStart)} - ${formatter.format(data.weekEnd)}';
  }

  int _dayNumber(WeekDayInfo day) {
    final parts = day.date.split('-');
    if (parts.length == 3) {
      return int.tryParse(parts[2]) ?? 0;
    }
    return 0;
  }

  String _normalizeDateKey(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;
    if (value.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value)) {
      return value.substring(0, 10);
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _normalizeTimeKey(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;
    final match = _timeKeyPattern.firstMatch(value);
    if (match != null) {
      return '${match.group(1)}:${match.group(2)}';
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final h = parsed.hour.toString().padLeft(2, '0');
    final m = parsed.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, List<Map<String, dynamic>>> _appointmentsLookupFor(
      WeeklyCalendarData data) {
    final key =
        '${_weekIdentity(data)}:${data.appointmentsBySlot.length}:${data.appointmentsBySlot.hashCode}';
    if (_appointmentsLookupCacheKey == key) return _appointmentsLookupCache;

    final lookup = <String, List<Map<String, dynamic>>>{};
    data.appointmentsBySlot.forEach((slotKey, list) {
      lookup[slotKey] = list;
      final idx = slotKey.lastIndexOf('_');
      if (idx <= 0) return;
      final normalizedKey =
          '${_normalizeDateKey(slotKey.substring(0, idx))}_${_normalizeTimeKey(slotKey.substring(idx + 1))}';
      lookup.putIfAbsent(normalizedKey, () => list);
    });

    _appointmentsLookupCacheKey = key;
    _appointmentsLookupCache = lookup;
    return lookup;
  }

  Widget _buildDayList(WeeklyCalendarData data) {
    _syncExpandedDayAndFocus(data);
    final appointmentsLookup = _appointmentsLookupFor(data);
    final statusColors = data.statusColors;
    final workingPrefs = data.workingPreferences;
    final currentTimeLabel = DateFormat('HH:mm').format(UserTimeZone.now());

    List<Map<String, dynamic>> appointmentsForSlot(
      String dayDate,
      String slotTime,
    ) {
      final rawKey = '${dayDate}_$slotTime';
      return appointmentsLookup[rawKey] ??
          appointmentsLookup[
              '${_normalizeDateKey(dayDate)}_${_normalizeTimeKey(slotTime)}'] ??
          const [];
    }

    Color statusColorFor(Map<String, dynamic>? appointment) {
      final alias =
          appointment?['appointment_status']?['alias']?.toString() ?? '';
      final mapped = statusColors[alias] ?? '';
      return _bootstrapColor(mapped);
    }

    Widget appointmentAction({
      required IconData icon,
      required String label,
      required VoidCallback? onPressed,
    }) =>
        Expanded(
          child: SizedBox(
            height: 44,
            child: IconButton(
              tooltip: label,
              onPressed: onPressed,
              style: IconButton.styleFrom(
                foregroundColor: _primaryColor,
                backgroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFFB0B7C3),
                side: const BorderSide(color: Color(0xFFE1E8F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.zero,
              ),
              icon: Icon(icon, size: 20),
            ),
          ),
        );

    Widget buildSlotCard(
      WeekDayInfo day,
      String time, {
      List<Map<String, dynamic>>? appts,
      bool isNowFocus = false,
    }) {
      final working = _dayWorking(day, workingPrefs);
      if (!working) {
        return const SizedBox.shrink();
      }

      final slotAppts = appts ?? appointmentsForSlot(day.date, time);
      final appointment = slotAppts.isNotEmpty ? slotAppts.first : null;

      if (appointment != null) {
        final customer = appointment['customer'] is Map<String, dynamic>
            ? appointment['customer'] as Map<String, dynamic>
            : (appointment['customer'] is Map
                ? (appointment['customer'] as Map).cast<String, dynamic>()
                : null);
        final fullName =
            '${customer?['name'] ?? ''} ${customer?['lastname'] ?? ''}'.trim();
        final phone = customer?['phone']?.toString() ?? '';
        final color = statusColorFor(appointment);
        final statusMap =
            appointment['appointment_status'] is Map<String, dynamic>
                ? appointment['appointment_status'] as Map<String, dynamic>
                : (appointment['appointment_status'] is Map
                    ? (appointment['appointment_status'] as Map)
                        .cast<String, dynamic>()
                    : null);
        final statusName = statusMap == null
            ? loc.appointmentsTitle
            : _localizedStatusLabel(statusMap);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              border: Border.all(
                  color: isNowFocus
                      ? _primaryColor.withValues(alpha: .3)
                      : const Color(0xFFE8EDF3)),
              borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(time,
                      style: const TextStyle(
                          color: _primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    InkWell(
                        onTap: () => showAppointmentDetails(
                            context, appointment,
                            statusLabel: statusName,
                            onEdit: () => _showSlotActionSheet(
                                appointment: appointment,
                                initialDate: day.date,
                                initialTime: time,
                                createNewForCustomer: false),
                            onRebook: () => _showSlotActionSheet(
                                appointment: appointment,
                                initialDate: day.date,
                                initialTime: time,
                                createNewForCustomer: true)),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                                fullName.isNotEmpty
                                    ? fullName
                                    : loc.calendarPerson,
                                style: const TextStyle(
                                    color: Color(0xFF0C2032),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)))),
                    if (phone.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(phone,
                              style: const TextStyle(
                                  color: Color(0xFF627183), fontSize: 12))),
                    Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(statusName,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700))),
                  ])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              appointmentAction(
                icon: Icons.event_repeat_rounded,
                label: loc.calendarActionNew,
                onPressed: _slotActionBusy
                    ? null
                    : () => _showSlotActionSheet(
                        appointment: appointment,
                        initialDate: day.date,
                        initialTime: time,
                        createNewForCustomer: true),
              ),
              const SizedBox(width: 8),
              appointmentAction(
                icon: Icons.edit_outlined,
                label: loc.calendarActionEdit,
                onPressed: _slotActionBusy
                    ? null
                    : () => _showSlotActionSheet(
                        appointment: appointment,
                        initialDate: day.date,
                        initialTime: time,
                        createNewForCustomer: false),
              ),
              const SizedBox(width: 8),
              Builder(
                  builder: (source) => appointmentAction(
                        icon: Icons.share_outlined,
                        label: loc.appointmentShare,
                        onPressed: appointmentShareUrl(appointment) == null
                            ? null
                            : () => shareAppointment(source, appointment),
                      )),
            ]),
          ]),
        );
      }

      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showBookingSheet(
          initialDate: day.date,
          initialTime: time,
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.calendarAddAppointment,
                  style: TextStyle(
                    color: _primaryColor.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.add_circle_outline, color: _primaryColor),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _refreshWeek,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: widget.showBottomNav ? 96 : 20),
          itemCount: data.weekDays.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return StudioPageIntro(loc.calendarSubtitle);
            final day = data.weekDays[index - 1];
            final sectionKey =
                _daySectionKeys.putIfAbsent(day.date, () => GlobalKey());
            final slots = data.timeSlotsByDay[day.date] ?? const <SlotInfo>[];
            final dayApptsByTime = <String, List<Map<String, dynamic>>>{};
            for (final slot in slots) {
              dayApptsByTime[slot.time] =
                  appointmentsForSlot(day.date, slot.time);
            }
            final working = _dayWorking(day, workingPrefs);
            final isExpanded = _expandedDayDate == day.date;
            final focusSlot = _nearestUpcomingSlotTime(
              slots,
              day.date,
              currentTime: currentTimeLabel,
            );
            final bookedCount =
                dayApptsByTime.values.where((appts) => appts.isNotEmpty).length;

            return _CalendarDaySection(
              key: ValueKey('day_${day.date}'),
              anchorKey: sectionKey,
              day: day,
              slots: slots,
              working: working,
              isExpanded: isExpanded,
              dayNumber: _dayNumber(day),
              dayLabel: _dayFullLabel(day),
              slotsFilledLabel:
                  loc.calendarSlotsFilled(bookedCount, slots.length),
              closedLabel: loc.calendarClosed,
              noDataLabel: loc.calendarNoData,
              primaryColor: _primaryColor,
              onToggle: () {
                setState(() {
                  _expandedDayDate =
                      _expandedDayDate == day.date ? null : day.date;
                });
              },
              slotBuilder: (slot) => buildSlotCard(
                day,
                slot.time,
                appts: dayApptsByTime[slot.time],
                isNowFocus: slot.time == focusSlot,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkingPrefCallout() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: _primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.calendarWorkingHoursPrompt,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WorkingPreferencesPage(),
                ),
              );
            },
            child: Text(loc.calendarWorkingHoursButton),
          ),
        ],
      ),
    );
  }

  Widget _weekControls(AsyncValue<WeeklyCalendarData> data) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF1))),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickWeekFromCalendar,
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: _primaryColor, size: 20),
                          const SizedBox(width: 9),
                          Expanded(
                              child: Text(_monthTitle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF0C2032),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700))),
                          const Icon(Icons.expand_more_rounded,
                              color: Color(0xFF627183), size: 20),
                        ])))),
            IconButton(
                onPressed: () => _setWeekStartFromDate(UserTimeZone.now()),
                tooltip: loc.calendarToday,
                icon: const Icon(Icons.today_outlined, color: _primaryColor)),
          ]),
          const Divider(height: 12, color: Color(0xFFE8EDF3)),
          Row(children: [
            IconButton(
                onPressed: () => _changeWeek(-1),
                tooltip: loc.calendarPrev,
                icon: const Icon(Icons.chevron_left_rounded)),
            Expanded(
                child: Text(
                    data.when(
                        data: _localizedWeekRangeText,
                        loading: () => loc.calendarLoading,
                        error: (_, __) => ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF627183),
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            IconButton(
                onPressed: () => _changeWeek(1),
                tooltip: loc.calendarNext,
                icon: const Icon(Icons.chevron_right_rounded)),
          ]),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<WeeklyCalendarData>>(
        weeklyCalendarProvider(_weekStart), (previous, next) {
      _hasUserPack = next.asData?.value.hasUserPack ?? _hasUserPack;
    });
    final asyncData = ref.watch(weeklyCalendarProvider(_weekStart));
    return Scaffold(
      backgroundColor: StudioPageStyle.background,
      appBar: StudioPageStyle.appBar(
          title: loc.calendarTitle,
          icon: Icons.calendar_month_outlined,
          refreshLabel: loc.refresh,
          onRefresh: _refreshWeek),
      body: StudioPageBackground(
          child: SafeArea(
              child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 350) {
            _changeWeek(-1);
          } else if (velocity < -350) {
            _changeWeek(1);
          }
        },
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _weekControls(asyncData),
              asyncData.when(
                  data: (data) => data.hasTimeSlots
                      ? const SizedBox.shrink()
                      : _buildWorkingPrefCallout(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink()),
              asyncData.when(
                  data: (data) {
                    if (data.weekDays.isEmpty) {
                      return Expanded(
                          child: RefreshIndicator(
                              onRefresh: _refreshWeek,
                              child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 40),
                                        child: Column(children: [
                                          const Icon(
                                              Icons.calendar_month_outlined,
                                              color: Color(0xFF7A8798),
                                              size: 40),
                                          const SizedBox(height: 14),
                                          Text(loc.calendarNoData,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Color(0xFF627183))),
                                        ])),
                                  ])));
                    }
                    return _buildDayList(data);
                  },
                  loading: () => const Expanded(
                      child: Center(
                          child:
                              CircularProgressIndicator(color: _primaryColor))),
                  error: (error, _) => Expanded(
                      child: RefreshIndicator(
                          onRefresh: _refreshWeek,
                          child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 32, horizontal: 12),
                                    child: Column(children: [
                                      const Icon(Icons.cloud_off_outlined,
                                          color: Color(0xFF7A8798), size: 40),
                                      const SizedBox(height: 14),
                                      Text(loc.calendarLoadError,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Color(0xFF627183),
                                              height: 1.5)),
                                      const SizedBox(height: 18),
                                      FilledButton.icon(
                                          onPressed: _refreshWeek,
                                          icon:
                                              const Icon(Icons.refresh_rounded),
                                          label: Text(loc.dashboardRetry),
                                          style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF0C2032))),
                                    ])),
                              ])))),
            ])),
      ))),
      bottomNavigationBar: widget.showBottomNav
          ? MainNavBar(currentIndex: 2, onIndexSelected: widget.onTabSelected)
          : null,
    );
  }
}

class _CalendarDaySection extends StatelessWidget {
  final GlobalKey anchorKey;
  final WeekDayInfo day;
  final List<SlotInfo> slots;
  final bool working;
  final bool isExpanded;
  final int dayNumber;
  final String dayLabel;
  final String slotsFilledLabel;
  final String closedLabel;
  final String noDataLabel;
  final Color primaryColor;
  final VoidCallback onToggle;
  final Widget Function(SlotInfo slot) slotBuilder;

  const _CalendarDaySection({
    super.key,
    required this.anchorKey,
    required this.day,
    required this.slots,
    required this.working,
    required this.isExpanded,
    required this.dayNumber,
    required this.dayLabel,
    required this.slotsFilledLabel,
    required this.closedLabel,
    required this.noDataLabel,
    required this.primaryColor,
    required this.onToggle,
    required this.slotBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: anchorKey,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: Radius.circular(isExpanded ? 0 : 16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color:
                          day.isToday ? primaryColor : const Color(0xFFF1F5FA),
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: day.isToday
                              ? Colors.white
                              : const Color(0xFF0C2032),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slotsFilledLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: isExpanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: !isExpanded
                  ? const SizedBox.shrink()
                  : (!working)
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              closedLabel,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      : (slots.isEmpty)
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  noDataLabel,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 10, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: slots.map((slot) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: slotBuilder(slot),
                                  );
                                }).toList(),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
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
          color: Color(0xFF8A8A8A),
        ),
      );
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));
}
