import 'package:liik_mobile/app_locale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Supported markets preserve their region when saved and restored', () {
    expect(liikLocales, [
      const Locale('en', 'US'),
      const Locale('en', 'GB'),
      const Locale('pt', 'BR'),
      const Locale('id', 'ID')
    ]);
    for (final locale in liikLocales) {
      expect(parseLiikLocale(locale.toLanguageTag()), locale);
    }
    expect(parseLiikLocale('en_GB'), const Locale('en', 'GB'));
  });
  test('Legacy Turkish and unsupported settings migrate to US English', () {
    for (final tag in ['tr', 'tr-TR', 'de-DE', '']) {
      expect(parseLiikLocale(tag), defaultLiikLocale);
    }
  });
  test('Language-only device locales map to the target markets', () {
    expect(resolveLiikLocale(const Locale('en')), const Locale('en', 'US'));
    expect(resolveLiikLocale(const Locale('pt')), const Locale('pt', 'BR'));
    expect(resolveLiikLocale(const Locale('id')), const Locale('id', 'ID'));
  });
}
