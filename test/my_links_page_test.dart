import 'dart:convert';
import 'package:bagla_mobile/app_locale.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import 'package:bagla_mobile/pages/my_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final linkFixtures = [
  {
    'id': 11,
    'title': 'My portfolio',
    'url': 'https://example.com/portfolio',
    'type_id': 1,
    'color_id': 1
  },
  {
    'id': 12,
    'title': 'Book a consultation',
    'url': 'https://example.com/book',
    'type_id': 1,
    'color_id': 1
  }
];
http.Response linksResponse(http.Request request, {bool empty = false}) {
  final dynamic data = switch (request.url.path) {
    '/api/user/profile' => {'links': empty ? [] : linkFixtures},
    '/api/settings/link-types' => [
        {'id': 1, 'name': 'Website', 'type': 'link'},
        {'id': 2, 'name': 'Email', 'type': 'email'}
      ],
    '/api/settings/colors' => [
        {'id': 1, 'name': 'Ocean blue', 'color': '#0866EB'},
        {'id': 2, 'name': 'Forest green', 'color': '#008577'}
      ],
    _ => {},
  };
  return http.Response(jsonEncode({'data': data}), 200);
}

Widget linksApp(Locale locale, {double scale = 1}) => MaterialApp(
    debugShowCheckedModeBanner: false,
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
    home: const MyLinksPage());
Finder linkField(String key) => find.byKey(ValueKey('link-$key'));
Future<void> showLinkForm(WidgetTester tester, AppLocalizations loc) async {
  final add = find.widgetWithText(FilledButton, loc.myLinksNewLink);
  await tester.scrollUntilVisible(add, -200,
      scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(add);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'}));
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('My links list, create and edit $locale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await http.runWithClient(() async {
          await tester.pumpWidget(linksApp(locale, scale: scale));
          await tester.pumpAndSettle();
          final loc =
              AppLocalizations.of(tester.element(find.byType(MyLinksPage)));
          await tester.scrollUntilVisible(find.text('My portfolio'), 200,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await showLinkForm(tester, loc);
          await tester.enterText(linkField('title'), 'My shop');
          await tester.enterText(linkField('url'), 'https://example.com/shop');
          final save = find.widgetWithText(FilledButton, loc.myLinksAddLink);
          await tester.ensureVisible(save);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle();
          final menu = find.byKey(const ValueKey('link-menu-11'));
          await tester.scrollUntilVisible(menu, 200,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          await tester.tap(menu);
          await tester.pumpAndSettle();
          await tester.tap(find.text(loc.myLinksEditTitle));
          await tester.pumpAndSettle();
          expect(
              tester.widget<TextFormField>(linkField('url')).controller!.text,
              'https://example.com/portfolio');
          await tester.ensureVisible(
              find.widgetWithText(FilledButton, loc.myLinksUpdateButton));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }, () => MockClient((r) async => linksResponse(r)));
      });
    }
  }
  testWidgets('Create validates destination, retains failed values and retries',
      (tester) async {
    var attempts = 0;
    Map<String, dynamic>? payload;
    await http.runWithClient(() async {
      await tester.pumpWidget(linksApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(MyLinksPage)));
      await showLinkForm(tester, loc);
      final save = find.widgetWithText(FilledButton, loc.myLinksAddLink);
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(attempts, 0);
      expect(find.text(loc.linksDestinationRequired), findsOneWidget);
      await tester.enterText(linkField('title'), 'New link');
      await tester.enterText(linkField('url'), 'https://example.com/new');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Try again'), findsOneWidget);
      expect(tester.widget<TextFormField>(linkField('title')).controller!.text,
          'New link');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(payload!['url'], 'https://example.com/new');
      expect(payload!['type_id'], 1);
      expect(payload!['color_id'], 1);
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.method == 'POST' && r.url.path == '/api/links') {
                attempts++;
                payload = jsonDecode(r.body);
                return attempts == 1
                    ? http.Response('{"message":"Try again"}', 422)
                    : http.Response('{}', 201);
              }
              return linksResponse(r);
            }));
  });
  testWidgets('Search type, update link and confirm deletion', (tester) async {
    Map<String, dynamic>? payload;
    var deleted = false;
    await http.runWithClient(() async {
      await tester.pumpWidget(linksApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(MyLinksPage)));
      Future<void> menu() async {
        final menu = find.byKey(const ValueKey('link-menu-11'));
        await tester.scrollUntilVisible(menu, 200,
            scrollable: find.byType(Scrollable).first);
        await tester.pumpAndSettle();
        await tester.tap(menu);
        await tester.pumpAndSettle();
      }

      await menu();
      await tester.tap(find.text(loc.myLinksEditTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(loc.myLinksSearchType));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('link-type-search')), 'Email');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Email'));
      await tester.pumpAndSettle();
      await tester.enterText(linkField('url'), 'hello@example.com');
      final update = find.widgetWithText(FilledButton, loc.myLinksUpdateButton);
      await tester.ensureVisible(update);
      await tester.pumpAndSettle();
      await tester.tap(update);
      await tester.pumpAndSettle();
      expect(payload!['type_id'], 2);
      expect(payload!['url'], 'hello@example.com');
      await menu();
      await tester.tap(find.text(loc.customersDelete));
      await tester.pumpAndSettle();
      expect(deleted, false);
      await tester.tap(find.text(loc.customersCancel));
      await tester.pumpAndSettle();
      expect(deleted, false);
      await menu();
      await tester.tap(find.text(loc.customersDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, loc.customersDelete));
      await tester.pumpAndSettle();
      expect(deleted, true);
      expect(find.text('My portfolio'), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.method == 'PUT') {
                payload = jsonDecode(r.body);
                return http.Response('{}', 200);
              }
              if (r.method == 'DELETE') {
                deleted = true;
                return http.Response('', 204);
              }
              return linksResponse(r);
            }));
  });
  testWidgets('Reordering saves and restores the original order on failure',
      (tester) async {
    var attempts = 0;
    Map<String, dynamic>? order;
    await http.runWithClient(() async {
      await tester.pumpWidget(linksApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(MyLinksPage)));
      Future<void> move() async {
        final menu = find.byKey(const ValueKey('link-menu-11'));
        await tester.ensureVisible(menu);
        await tester.pumpAndSettle();
        await tester.tap(menu);
        await tester.pumpAndSettle();
        await tester.tap(find.text(loc.linksMoveDown));
        await tester.pumpAndSettle();
      }

      await move();
      expect(find.text(loc.linksOrderError), findsOneWidget);
      expect(tester.getTopLeft(find.text('My portfolio')).dy,
          lessThan(tester.getTopLeft(find.text('Book a consultation')).dy));
      await move();
      expect(attempts, 2);
      expect(order!['orders'][0]['id'], 12);
      expect(order!['orders'][1]['id'], 11);
      expect(tester.getTopLeft(find.text('Book a consultation')).dy,
          lessThan(tester.getTopLeft(find.text('My portfolio')).dy));
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.url.path.endsWith('/reorder')) {
                attempts++;
                order = jsonDecode(r.body);
                return http.Response('{}', attempts == 1 ? 500 : 200);
              }
              return linksResponse(r);
            }));
  });
  testWidgets('Load errors can retry and settings failure keeps form usable',
      (tester) async {
    var attempts = 0;
    var settingsAttempts = 0;
    await http.runWithClient(() async {
      await tester.pumpWidget(linksApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(MyLinksPage)));
      await tester.tap(find.text(loc.customersRetry));
      await tester.pumpAndSettle();
      expect(find.text(loc.myLinksNoLinksTitle), findsOneWidget);
      await showLinkForm(tester, loc);
      expect(find.text(loc.linksSettingsError), findsOneWidget);
      await tester.tap(find.text(loc.customersRetry));
      await tester.pumpAndSettle();
      expect(linkField('url'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.url.path == '/api/user/profile') {
                attempts++;
                return attempts == 1
                    ? http.Response('{}', 500)
                    : linksResponse(r, empty: true);
              }
              if (r.url.path.contains('/settings/')) {
                settingsAttempts++;
                return settingsAttempts <= 4
                    ? http.Response('{}', 500)
                    : linksResponse(r);
              }
              return linksResponse(r);
            }));
  });
}
