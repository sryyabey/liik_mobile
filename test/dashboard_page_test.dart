import 'dart:convert';
import 'package:liik_mobile/app_locale.dart';
import 'package:liik_mobile/dashboard_page.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> dashboardFixture({bool empty = false}) => {
      'total_clicks': empty ? 0 : 248,
      'short_bio_page': empty ? '' : 'https://liik.example/alex',
      'profile_description': empty ? '' : 'A profile',
      'unread_announcements_count': empty ? 0 : 2,
      'daily_clicks': empty
          ? {}
          : {
              'labels': ['Mon', 'Tue', 'Wed'],
              'datasets': [
                {
                  'data': [12, 24, 8]
                }
              ]
            },
      'top_links': empty
          ? []
          : [
              {'title': 'Instagram', 'clicks': 42}
            ],
      'appointment_info': {
        'todayAppointments': empty ? 0 : 1,
        'appointments': empty
            ? []
            : [
                {
                  'customer_id': 7,
                  'customer': {'name': 'Alex Morgan', 'phone': '+15551234567'},
                  'date': '2026-10-19',
                  'time': '10:30:00',
                  'appointment_status': {'name': 'Confirmed'}
                }
              ]
      },
    };

Widget dashboardApp(Locale locale,
        {double scale = 1, ValueChanged<int>? onTab}) =>
    MaterialApp(
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
      home: DashboardPage(onTabSelected: onTab),
    );

void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'}));
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Dashboard retains data and has no SMS: $locale at $scale',
          (tester) async {
        final requested = <String>[];
        int? selectedTab;
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await http.runWithClient(() async {
          await tester.pumpWidget(dashboardApp(locale,
              scale: scale, onTab: (value) => selectedTab = value));
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(DashboardPage));
          final loc = AppLocalizations.of(context);
          expect(find.text('248'), findsOneWidget);
          expect(find.textContaining('SMS'), findsNothing);
          expect(tester.takeException(), isNull);
          for (var i = 0; i < 12; i++) {
            await tester.drag(
                find.byType(ListView).first, const Offset(0, -400));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          await tester.tap(find.byTooltip(
              MaterialLocalizations.of(context).openAppDrawerTooltip));
          await tester.pumpAndSettle();
          expect(find.textContaining('SMS'), findsNothing);
          expect(find.text(loc.dashboardAppointments), findsWidgets);
          await tester.tap(find.text(loc.dashboardAppointments).last);
          await tester.pumpAndSettle();
          expect(selectedTab, 1);
          expect(requested, contains('/api/dashboard'));
          expect(
              requested.where(
                  (path) => path.contains('welcome') || path.contains('sms')),
              isEmpty);
        },
            () => MockClient((request) async {
                  requested.add(request.url.path);
                  if (request.url.path == '/api/dashboard') {
                    return http.Response(
                        jsonEncode({'data': dashboardFixture()}), 200);
                  }
                  if (request.url.path == '/api/packs/active') {
                    return http.Response(
                        jsonEncode({
                          'data': {
                            'pack': {
                              'pack_name': 'Pro',
                              'remaining_sms': 100,
                              'activated_at': '2026-10-01',
                              'expired_at': '2026-11-01'
                            }
                          }
                        }),
                        200);
                  }
                  return http.Response('{"data":[]}', 200);
                }));
      });
    }
  }
  testWidgets('Empty dashboard lets the user create a profile and book',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(dashboardApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(DashboardPage)));
      expect(find.text(loc.dashboardBioEmptyTitle), findsOneWidget);
      await tester.scrollUntilVisible(
          find.text(loc.dashboardNoAppointments), 300);
      expect(find.text(loc.dashboardNoAppointments), findsOneWidget);
      expect(find.textContaining('SMS'), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async => http.Response(
            jsonEncode({
              'data': request.url.path == '/api/dashboard'
                  ? dashboardFixture(empty: true)
                  : request.url.path == '/api/packs/active'
                      ? {'pack': null}
                      : []
            }),
            200)));
  });
  testWidgets('Dashboard retries after a server failure', (tester) async {
    var requests = 0;
    await http.runWithClient(() async {
      await tester.pumpWidget(dashboardApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(DashboardPage)));
      expect(find.text(loc.dashboardRetry), findsOneWidget);
      await tester.tap(find.text(loc.dashboardRetry));
      await tester.pumpAndSettle();
      expect(find.text('248'), findsOneWidget);
      expect(requests, 2);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.url.path == '/api/dashboard') {
                requests++;
                return requests == 1
                    ? http.Response('{}', 500)
                    : http.Response(
                        jsonEncode({'data': dashboardFixture()}), 200);
              }
              return http.Response(
                  jsonEncode({
                    'data': request.url.path == '/api/packs/active'
                        ? {'pack': null}
                        : []
                  }),
                  200);
            }));
  });
}
