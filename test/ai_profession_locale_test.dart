import 'dart:convert';
import 'package:liik_mobile/app_locale.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/pages/ai_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final locale in liikLocales) {
    testWidgets('AI profession request uses $locale', (tester) async {
      SharedPreferences.setMockInitialValues({'bearer_token': 'test'});
      final label = switch (locale.languageCode) {
        'pt' => 'Nutricionista',
        'id' => 'Dietisien',
        _ => 'Dietitian'
      };
      final requests = <Uri>[];
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp(
            locale: locale,
            supportedLocales: liikLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            home: const AiProfilePage()));
        for (int i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(
            requests
                .where((r) => r.path == '/api/ai-profile')
                .single
                .queryParameters['locale'],
            locale.toLanguageTag());
        final dropdown = find.byWidgetPredicate((w) =>
            w is DropdownButton<String> &&
            w.items!.any((item) => item.value == label));
        for (int i = 0; i < 8 && dropdown.evaluate().isEmpty; i++) {
          await tester.drag(
              find.byType(Scrollable).last, const Offset(0, -250));
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(dropdown, findsOneWidget);
        expect(find.text('Diyetisyen'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      },
          () => MockClient((r) async {
                requests.add(r.url);
                return http.Response(
                    jsonEncode({
                      'data': r.url.path == '/api/ai-profile'
                          ? {
                              'profile': {},
                              'seo': {},
                              'themes': [],
                              'professions': [label],
                              'remaining_generations': 5,
                              'existing_links': {}
                            }
                          : {}
                    }),
                    200,
                    headers: {
                      'content-type': 'application/json; charset=utf-8'
                    });
              }));
    });
  }
}
