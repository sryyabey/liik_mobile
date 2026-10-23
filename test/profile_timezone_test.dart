import 'dart:convert';
import 'package:liik_mobile/app_locale.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/pages/profile.dart';
import 'package:liik_mobile/user_timezone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget profileApp(Locale locale, {double scale = 1}) => MaterialApp(
    locale: locale,
    supportedLocales: liikLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ],
    builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!),
    home: const ProfilePage(showBottomNav: false));
http.Response profileResponse(String zone) => http.Response(
    jsonEncode({
      'data': {'name': 'Alex', 'username': 'alex', 'timezone': zone, 'seo': {}}
    }),
    200);
http.Response zonesResponse() => http.Response(
    jsonEncode({
      'data': [
        {
          'id': 'America/New_York',
          'label': 'America/New York',
          'utc_offset': '-04:00'
        },
        {
          'id': 'America/Sao_Paulo',
          'label': 'America/Sao Paulo',
          'utc_offset': '-03:00'
        },
        {'id': 'Asia/Jakarta', 'label': 'Asia/Jakarta', 'utc_offset': '+07:00'}
      ]
    }),
    200);
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'});
    await UserTimeZone.clear();
  });
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Search and choose a profile timezone $locale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await http.runWithClient(() async {
          await tester.pumpWidget(profileApp(locale, scale: scale));
          await tester.pumpAndSettle();
          final selector = find.byKey(const ValueKey('profile-timezone'));
          await tester.ensureVisible(selector);
          await tester.pumpAndSettle();
          await tester.tap(selector);
          await tester.pumpAndSettle();
          await tester.enterText(
              find.byKey(const ValueKey('timezone-search')), 'New York');
          await tester.pumpAndSettle();
          expect(find.widgetWithText(ListTile, 'America/New York'),
              findsOneWidget);
          expect(find.widgetWithText(ListTile, 'Asia/Jakarta'), findsNothing);
          await tester.tap(find.widgetWithText(ListTile, 'America/New York'));
          await tester.pumpAndSettle();
          expect(
              find.descendant(
                  of: selector, matching: find.text('America/New York')),
              findsOneWidget);
          expect(UserTimeZone.name, 'America/Sao_Paulo');
          expect(tester.takeException(), isNull);
        },
            () => MockClient((r) async => r.url.path.contains('/timezones')
                ? zonesResponse()
                : profileResponse('America/Sao_Paulo')));
      });
    }
  }
  for (final locale in liikLocales) {
    testWidgets('Profile sections retain edits and fit large text $locale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(() async {
        await tester.pumpWidget(profileApp(locale, scale: 1.8));
        await tester.pumpAndSettle();
        final loc =
            AppLocalizations.of(tester.element(find.byType(ProfilePage)));
        final save = find.widgetWithText(ElevatedButton, loc.save);
        expect(save.hitTestable(), findsOneWidget);
        final seo = find.text(loc.profileSeoSectionTitle);
        await tester.ensureVisible(seo);
        await tester.tap(seo);
        await tester.pumpAndSettle();
        final title = find.byWidgetPredicate((widget) =>
            widget is TextField &&
            widget.decoration?.labelText == loc.profileSeoTitleLabel);
        await tester.ensureVisible(title);
        await tester.enterText(title, 'My profile title');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(seo);
        await tester.tap(seo);
        await tester.pumpAndSettle();
        await tester.tap(seo);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(title).controller!.text,
            'My profile title');
        final password = find.text(loc.profilePasswordSectionTitle);
        await tester.ensureVisible(password);
        await tester.tap(password);
        await tester.pumpAndSettle();
        final change = find.widgetWithText(
            ElevatedButton, loc.profileChangePasswordButton);
        await tester.ensureVisible(change);
        expect(tester.takeException(), isNull);
        expect(save.hitTestable(), findsOneWidget);
      },
          () => MockClient(
              (request) async => profileResponse('America/Sao_Paulo')));
    });
  }
  testWidgets(
      'Profile saves selected zone and only then updates the local clock',
      (tester) async {
    var stored = 'America/Sao_Paulo';
    String? posted;
    await http.runWithClient(() async {
      await tester.pumpWidget(profileApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(ProfilePage)));
      final selector = find.byKey(const ValueKey('profile-timezone'));
      await tester.ensureVisible(selector);
      await tester.pumpAndSettle();
      await tester.tap(selector);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Asia/Jakarta'));
      await tester.pumpAndSettle();
      expect(UserTimeZone.name, 'America/Sao_Paulo');
      final save = find.widgetWithText(ElevatedButton, loc.save).first;
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(posted, contains('name="timezone"\r\n\r\nAsia/Jakarta'));
      expect(UserTimeZone.name, 'Asia/Jakarta');
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.method == 'POST') {
                posted = r.body;
                stored = 'Asia/Jakarta';
                return profileResponse(stored);
              }
              return r.url.path.contains('/timezones')
                  ? zonesResponse()
                  : profileResponse(stored);
            }));
  });
  testWidgets('Failed save keeps the existing clock and selected form value',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(profileApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(ProfilePage)));
      final selector = find.byKey(const ValueKey('profile-timezone'));
      await tester.ensureVisible(selector);
      await tester.pumpAndSettle();
      await tester.tap(selector);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Asia/Jakarta'));
      await tester.pumpAndSettle();
      final save = find.widgetWithText(ElevatedButton, loc.save).first;
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(UserTimeZone.name, 'America/Sao_Paulo');
      expect(find.descendant(of: selector, matching: find.text('Asia/Jakarta')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async => r.method == 'POST'
            ? http.Response('{"message":"Try again"}', 422)
            : r.url.path.contains('/timezones')
                ? zonesResponse()
                : profileResponse('America/Sao_Paulo')));
  });
}
