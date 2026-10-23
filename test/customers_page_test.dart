import 'dart:async';
import 'dart:convert';
import 'package:liik_mobile/app_locale.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/pages/customers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final contactFixture = {
  'id': 7,
  'name': 'Alex Morgan',
  'phone': '+5511987654321',
  'country_id': 1,
  'email': 'alex.morgan.with.a.long.address@example.com',
  'address': '123 Main Street',
  'notes': 'Prefers mornings'
};
http.Response contactsResponse(http.Request request) {
  if (request.url.path == '/api/customers')
    return http.Response(
        jsonEncode({
          'data': [contactFixture],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1}
        }),
        200);
  if (request.url.path == '/api/appointments')
    return http.Response('{"data":[],"user_pack":true}', 200);
  return http.Response('{"data":[]}', 200);
}

Widget contactsApp(Locale locale, {double scale = 1}) => MaterialApp(
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
    home: const CustomersPage());
Finder contactField(String key) => find.byKey(ValueKey('contact-$key'));
void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'}));
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Contacts, search, edit and appointment form $locale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final requests = <Uri>[];
        await http.runWithClient(() async {
          await tester.pumpWidget(contactsApp(locale, scale: scale));
          await tester.pumpAndSettle();
          final loc =
              AppLocalizations.of(tester.element(find.byType(CustomersPage)));
          await tester.scrollUntilVisible(find.text('Alex Morgan'), 200,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          expect(find.text('Alex Morgan'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.scrollUntilVisible(find.byType(TextField), -200,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField).first, 'Alex');
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpAndSettle();
          expect(requests.any((uri) => uri.queryParameters['search'] == 'Alex'),
              true);
          final alphabet = find.widgetWithText(ChoiceChip, 'A');
          await tester.ensureVisible(alphabet);
          await tester.tap(alphabet);
          await tester.pumpAndSettle();
          expect(requests.last.queryParameters['starts_with'], 'A');
          final edit = find.byType(PopupMenuButton<String>);
          await tester.scrollUntilVisible(edit, 200,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          await tester.tap(edit);
          await tester.pumpAndSettle();
          await tester.tap(find.text(loc.customersEdit).last);
          await tester.pumpAndSettle();
          expect(
              tester
                  .widget<TextFormField>(contactField('phone'))
                  .controller!
                  .text,
              '+5511987654321');
          await tester.ensureVisible(contactField('notes'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle();
          final appointments = find.text(loc.customersAppointments);
          await tester.ensureVisible(appointments);
          await tester.pumpAndSettle();
          await tester.tap(appointments);
          await tester.pumpAndSettle();
          expect(find.text(loc.customersNoAppointments), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(loc.customersCreateAppointment));
          await tester.pumpAndSettle();
          expect(find.text(loc.calendarExistingPerson), findsOneWidget);
          expect(find.text('Alex Morgan').last, findsOneWidget);
          expect(find.textContaining('SMS'), findsNothing);
          expect(tester.takeException(), isNull);
        },
            () => MockClient((r) async {
                  requests.add(r.url);
                  return contactsResponse(r);
                }));
      });
    }
  }
  testWidgets(
      'Failed save retains values and retry preserves international phone',
      (tester) async {
    var attempts = 0;
    Map<String, dynamic>? saved;
    await http.runWithClient(() async {
      await tester.pumpWidget(contactsApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(CustomersPage)));
      await tester.tap(find.text(loc.customersAdd));
      await tester.pumpAndSettle();
      await tester.enterText(contactField('name'), 'Jamie Lee');
      await tester.enterText(contactField('phone'), '+62812345678901');
      final save = find.widgetWithText(FilledButton, loc.customersSave);
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Please try again'), findsOneWidget);
      expect(
          tester.widget<TextFormField>(contactField('phone')).controller!.text,
          '+62812345678901');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(saved!['phone'], '+62812345678901');
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.method == 'POST') {
                attempts++;
                saved = jsonDecode(r.body);
                return attempts == 1
                    ? http.Response('{"message":"Please try again"}', 422)
                    : http.Response('{"data":{}}', 201);
              }
              return contactsResponse(r);
            }));
  });
  testWidgets('Newest search response wins', (tester) async {
    final slow = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(contactsApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'slow');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField).first, 'fast');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      slow.complete(http.Response('{"data":[{"name":"Stale contact"}]}', 200));
      await tester.pumpAndSettle();
      expect(find.text('Stale contact'), findsNothing);
      expect(find.text('Alex Morgan'), findsOneWidget);
    },
        () => MockClient((r) async => r.url.queryParameters['search'] == 'slow'
            ? await slow.future
            : contactsResponse(r)));
  });
  testWidgets('Empty and failed loads remain refreshable', (tester) async {
    var attempts = 0;
    await http.runWithClient(() async {
      await tester.pumpWidget(contactsApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(CustomersPage)));
      final retry = find.text(loc.customersRetry);
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(find.text(loc.customersEmpty), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              attempts++;
              return attempts == 1
                  ? http.Response('{}', 500)
                  : http.Response('{"data":[]}', 200);
            }));
  });
  testWidgets('Editing preserves country and deleting requires confirmation',
      (tester) async {
    Map<String, dynamic>? saved;
    var deleted = false;
    await http.runWithClient(() async {
      await tester.pumpWidget(contactsApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(CustomersPage)));
      Future<void> menu() async {
        await tester.ensureVisible(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
      }

      await menu();
      await tester.tap(find.text(loc.customersEdit).last);
      await tester.pumpAndSettle();
      await tester.enterText(contactField('phone'), '+5511987654321');
      final save = find.widgetWithText(FilledButton, loc.customersSave);
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(saved!['country_id'], 1);
      expect(saved!['phone'], '+5511987654321');
      await menu();
      await tester.tap(find.text(loc.customersDelete).last);
      await tester.pumpAndSettle();
      expect(deleted, false);
      await tester.tap(find.text(loc.customersCancel));
      await tester.pumpAndSettle();
      expect(deleted, false);
      await menu();
      await tester.tap(find.text(loc.customersDelete).last);
      await tester.pumpAndSettle();
      await tester
          .tap(find.widgetWithText(ElevatedButton, loc.customersDelete));
      await tester.pumpAndSettle();
      expect(deleted, true);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.method == 'PUT') {
                saved = jsonDecode(r.body);
                return http.Response('{}', 200);
              }
              if (r.method == 'DELETE') {
                deleted = true;
                return http.Response('{}', 200);
              }
              return contactsResponse(r);
            }));
  });
}
