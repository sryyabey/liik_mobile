import 'dart:async';
import 'dart:convert';
import 'package:bagla_mobile/app_locale.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import 'package:bagla_mobile/pages/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> fixture(int period, {bool empty = false}) => {
      'timezone': 'UTC',
      'from': '2026-10-13',
      'to': '2026-10-19',
      'summary': {
        'unique_views': empty ? 0 : 10,
        'total_clicks': empty ? 0 : 20,
        'unique_clicks': empty ? 0 : 5,
        'conversion_rate': empty ? null : 50,
        'redirect_views': 2
      },
      'changes': {
        'unique_views': null,
        'total_clicks': 100,
        'unique_clicks': 0,
        'conversion_rate': -10
      },
      'daily': List.generate(
          period,
          (i) => {
                'date': DateTime(2026, 10, 19)
                    .subtract(Duration(days: period - 1 - i))
                    .toIso8601String()
                    .substring(0, 10),
                'clicks': empty ? 0 : i % 3,
                'unique_clicks': empty ? 0 : i % 2
              }),
      'top_links': empty
          ? []
          : [
              {
                'title': 'Portfolio',
                'url': 'https://example.com/portfolio',
                'clicks': 20,
                'unique_clicks': 5,
                'ctr': 50
              }
            ],
      'navigation': {'manual': 15, 'automatic': 4, 'unknown': 1},
      'audience': {
        'devices': [
          {'name': 'mobile', 'total': 10}
        ],
        'platforms': [
          {'name': 'iOS', 'total': 10}
        ],
        'browsers': [
          {'name': 'Safari', 'total': 10}
        ],
        'countries': [
          {'name': 'US', 'total': 10}
        ],
        'sources': [
          {'name': 'instagram', 'views': 10, 'clicks': 5, 'ctr': 50}
        ],
        'hours': List.generate(24, (i) => {'hour': i, 'total': i % 3}),
        'weekdays': List.generate(7, (i) => {'weekday': i, 'total': i})
      }
    };
http.Response response(Map<String, dynamic> data) =>
    http.Response(jsonEncode({'data': data}), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
Widget app(Locale locale, {double scale = 1}) => MaterialApp(
    locale: locale,
    supportedLocales: liikLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ],
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!),
    home: const AnalyticsPage());
Future<void> select(WidgetTester tester, String title) async {
  tester.state<ScrollableState>(find.byType(Scrollable).first).position.jumpTo(0);
  await tester.pumpAndSettle();
  final chip = find.widgetWithText(ChoiceChip, title);
  if (chip.evaluate().isEmpty) {
    await tester.scrollUntilVisible(chip, 100, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'}));
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('All analytics tabs $locale $scale', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final requests = <Uri>[];
        await http.runWithClient(() async {
          await tester.pumpWidget(app(locale, scale: scale));
          await tester.pumpAndSettle();
          final loc =
              AppLocalizations.of(tester.element(find.byType(AnalyticsPage)));
          expect(tester.takeException(), isNull);
          for (final tab in [
            loc.analyticsLinks,
            loc.analyticsAudience,
            loc.analyticsConversions,
            loc.analyticsOverview
          ]) {
            await select(tester, tab);
            expect(tester.takeException(), isNull);
          }
          await select(tester, loc.analyticsDays(90));
          expect(requests.last.queryParameters['period'], '90');
          expect(tester.takeException(), isNull);
        },
            () => MockClient((request) async {
                  requests.add(request.url);
                  expect(request.headers['Authorization'], 'Bearer test-token');
                  return response(fixture(
                      int.parse(request.url.queryParameters['period']!)));
                }));
      });
    }
  }
  testWidgets('Retry then empty report', (tester) async {
    int calls = 0;
    await http.runWithClient(() async {
      await tester.pumpWidget(app(const Locale('en', 'US')));
      await tester.pumpAndSettle();
      expect(find.text('Could not load analytics. Please try again.'),
          findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      await tester.ensureVisible(find.text('No activity in this period'));
      expect(find.text('No activity in this period'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((_) async {
              calls++;
              return calls == 1
                  ? http.Response('Unavailable', 503)
                  : response(fixture(7, empty: true));
            }));
  });
  testWidgets('New period wins over stale response', (tester) async {
    final old = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(app(const Locale('en', 'US')));
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, '30 days'));
      await tester.pumpAndSettle();
      old.complete(response(fixture(7, empty: true)));
      await tester.pumpAndSettle();
      expect(find.text('No activity in this period'), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) => r.url.queryParameters['period'] == '7'
            ? old.future
            : Future.value(response(fixture(30)))));
  });
}
