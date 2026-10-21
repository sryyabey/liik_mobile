import 'package:bagla_mobile/user_timezone.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserTimeZone.clear();
  });
  test('New York uses winter and summer offsets automatically', () async {
    await UserTimeZone.set('America/New_York');
    expect(UserTimeZone.at(DateTime.utc(2026, 1, 1, 12)).hour, 7);
    expect(UserTimeZone.at(DateTime.utc(2026, 7, 1, 12)).hour, 8);
    expect(UserTimeZone.at(DateTime.utc(2026, 1, 1, 2)).day, 31);
  });
  test('London DST and Indonesia fractional date changes use profile zone',
      () async {
    await UserTimeZone.set('Europe/London');
    expect(UserTimeZone.at(DateTime.utc(2026, 7, 1, 12)).hour, 13);
    await UserTimeZone.set('Asia/Jakarta');
    expect(UserTimeZone.at(DateTime.utc(2026, 10, 19, 20)).day, 20);
    expect(UserTimeZone.at(DateTime.utc(2026, 10, 19, 20)).hour, 3);
    await UserTimeZone.set('America/Sao_Paulo');
    expect(UserTimeZone.at(DateTime.utc(2026, 10, 19, 2)).day, 18);
  });
  test('Choice persists and logout removes the previous account zone',
      () async {
    await UserTimeZone.set('Asia/Jakarta');
    expect(
        (await SharedPreferences.getInstance()).getString('profile_timezone'),
        'Asia/Jakarta');
    await UserTimeZone.clear();
    expect(UserTimeZone.name, isNull);
    expect(
        (await SharedPreferences.getInstance()).containsKey('profile_timezone'),
        false);
    await UserTimeZone.set('Invalid/Zone');
    expect(UserTimeZone.name, 'UTC');
  });
}
