import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

/// Calendar values remain local wall times; only "now" uses the profile's zone.
class UserTimeZone {
  static const _key = 'profile_timezone';
  static final changes = ValueNotifier<String?>(null);
  static bool _initialized = false;
  static tz.Location? _location;
  static String? get name => _location?.name;
  static void _initialize() {
    if (!_initialized) {
      data.initializeTimeZones();
      _initialized = true;
    }
  }

  static void _use(String name) {
    _initialize();
    try {
      _location = tz.getLocation(name);
    } catch (_) {
      _location = tz.getLocation('UTC');
    }
    changes.value = _location!.name;
  }

  static Future<void> load() async {
    final name = (await SharedPreferences.getInstance()).getString(_key);
    if (name != null) _use(name);
  }

  static Future<void> set(String name) async {
    _use(name);
    final zone = _location!.name;
    await (await SharedPreferences.getInstance()).setString(_key, zone);
  }

  static Future<void> clear() async {
    _location = null;
    changes.value = null;
    await (await SharedPreferences.getInstance()).remove(_key);
  }

  static DateTime now() =>
      _location == null ? DateTime.now() : tz.TZDateTime.now(_location!);
  static DateTime at(DateTime instant) => _location == null
      ? instant.toLocal()
      : tz.TZDateTime.from(instant, _location!);
}
