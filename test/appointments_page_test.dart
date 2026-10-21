import 'dart:convert';
import 'package:bagla_mobile/app_locale.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import 'package:bagla_mobile/pages/appointments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sampleAppointment = {
  'id': 11,
  'share_code': 'Xc6Tsx',
  'share_url': 'https://liik.test/apo/Xc6Tsx',
  'timezone': 'America/Sao_Paulo',
  'customer_id': 7,
  'appointment_status_id': 2,
  'customer': {'name': 'Alex Morgan', 'phone': '+5511987654321'},
  'date': '2026-10-20',
  'time': '10:30:00',
  'notes': 'Initial consultation',
  'appointment_status': {
    'id': 2,
    'alias': 'confirmed',
    'name': 'Confirmed',
    'color': '#008577'
  },
  'no_sms': false,
  'no_reminder': false,
};
http.Response appointmentResponse(http.Request request, {bool empty = false}) {
  final path = request.url.path;
  final dynamic data;
  if (path == '/api/appointments') {
    data = empty ? [] : [sampleAppointment];
  } else if (path == '/api/customers') {
    data = [
      {'id': 7, 'name': 'Alex', 'lastname': 'Morgan', 'phone': '+5511987654321'}
    ];
  } else if (path.endsWith('/appointment-defaults')) {
    data = {'last_note': 'Previous consultation'};
  } else if (path == '/api/settings/countries') {
    data = [
      {'id': 1, 'name': 'Brazil', 'phone_code': '55'}
    ];
  } else if (path == '/api/settings/appointment-statuses') {
    data = [
      {'id': 1, 'alias': 'pending', 'name': 'Pending'},
      {'id': 2, 'alias': 'confirmed', 'name': 'Confirmed'}
    ];
  } else if (path == '/api/appointments/time-slots') {
    data = [
      {'time': '10:30', 'is_available': true}
    ];
  } else if (path == '/api/appointments/customer-info') {
    data = {
      'customer_name': 'Alex Morgan',
      'customer_phone': '+5511987654321',
      'appointments': []
    };
  } else {
    data = {};
  }
  return http.Response(jsonEncode({'data': data, 'user_pack': true}), 200);
}

Widget appointmentsApp(Locale locale, {double scale = 1, bool quick = false}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: liikLocales,
      debugShowCheckedModeBanner: false,
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
      home: AppointmentsPage(
          autoShowQuick: quick,
          initialQuickDate: quick ? '2026-10-20' : null,
          showBottomNav: false),
    );
Finder fieldWithLabel(String label) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label);

void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'}));
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Appointment list, filters and form: $locale at $scale',
          (tester) async {
        final requested = <String>[];
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await http.runWithClient(() async {
          await tester.pumpWidget(appointmentsApp(locale, scale: scale));
          await tester.pumpAndSettle();
          final loc = AppLocalizations.of(
              tester.element(find.byType(AppointmentsPage)));
          expect(find.text('Alex Morgan'), findsOneWidget);
          expect(find.textContaining('SMS'), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text(loc.showFilter));
          await tester.tap(find.text(loc.showFilter));
          await tester.pumpAndSettle();
          expect(fieldWithLabel(loc.appointmentsFieldName), findsOneWidget);
          await tester.enterText(
              fieldWithLabel(loc.appointmentsFieldName), 'Alex');
          final filterButton =
              find.widgetWithText(ElevatedButton, loc.showFilter);
          await tester.ensureVisible(filterButton);
          await tester.tap(filterButton);
          await tester.pumpAndSettle();
          expect(requested.any((url) => url.contains('customer_name=Alex')),
              isTrue);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(
              find.widgetWithText(ElevatedButton, loc.quickAppointment));
          await tester
              .tap(find.widgetWithText(ElevatedButton, loc.quickAppointment));
          await tester.pumpAndSettle();
          for (var i = 0; i < 9; i++) {
            await tester.drag(
                find
                    .descendant(
                        of: find.byType(BottomSheet),
                        matching: find.byType(SingleChildScrollView))
                    .last,
                const Offset(0, -350));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          expect(find.textContaining('SMS'), findsNothing);
          expect(requested.any((path) => path.contains('/api/dashboard')),
              isFalse);
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle();
          await tester
              .ensureVisible(find.byTooltip(loc.appointmentsEditTooltip));
          await tester.tap(find.byTooltip(loc.appointmentsEditTooltip));
          await tester.pumpAndSettle();
          await tester
              .ensureVisible(find.widgetWithText(ElevatedButton, loc.save));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.textContaining('SMS'), findsNothing);
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle();
          await tester
              .ensureVisible(find.byTooltip(loc.appointmentsRebookTooltip));
          await tester.tap(find.byTooltip(loc.appointmentsRebookTooltip));
          await tester.pumpAndSettle();
          await tester.ensureVisible(
              find.widgetWithText(ElevatedButton, loc.rescheduleAppointment));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.textContaining('SMS'), findsNothing);
        },
            () => MockClient((request) async {
                  requested.add(request.url.toString());
                  return appointmentResponse(request);
                }));
      });
    }
  }
  testWidgets('Quick creation preserves long phone numbers and disables SMS',
      (tester) async {
    Map<String, dynamic>? saved;
    await http.runWithClient(() async {
      await tester.pumpWidget(appointmentsApp(defaultLiikLocale, quick: true));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(AppointmentsPage)));
      await tester.tap(find.text(loc.calendarNewPerson));
      await tester.pumpAndSettle();
      await tester.enterText(fieldWithLabel(loc.appointmentsFieldName), 'Alex');
      await tester.enterText(
          fieldWithLabel(loc.appointmentsFieldLastName), 'Morgan');
      await tester.enterText(
          fieldWithLabel(loc.appointmentsFieldPhone), '11987654321');
      expect(
          tester
              .widget<TextField>(fieldWithLabel(loc.appointmentsFieldPhone))
              .controller!
              .text,
          '11987654321');
      final fetchSlots = find.text(loc.calendarFetchAvailableSlots);
      await tester.ensureVisible(fetchSlots);
      await tester.tap(fetchSlots);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find
          .descendant(
              of: find.byType(BottomSheet), matching: find.text('10:30'))
          .last);
      await tester.tap(find
          .descendant(
              of: find.byType(BottomSheet), matching: find.text('10:30'))
          .last);
      await tester.pumpAndSettle();
      final save = find.widgetWithText(ElevatedButton, loc.save).last;
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(saved, isNotNull);
      expect(saved!['phone'], '11987654321');
      expect(saved!['no_sms'], isTrue);
      expect(saved!['no_reminder'], isTrue);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.method == 'POST' &&
                  request.url.path.endsWith('quick_appointment')) {
                saved = jsonDecode(request.body) as Map<String, dynamic>;
                return http.Response('{"data":{},"code":"CREATED"}', 201);
              }
              return appointmentResponse(request);
            }));
  });
  testWidgets('Editing an appointment sends no SMS flags', (tester) async {
    Map<String, dynamic>? updated;
    await http.runWithClient(() async {
      await tester.pumpWidget(appointmentsApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(AppointmentsPage)));
      await tester.ensureVisible(find.byTooltip(loc.appointmentsEditTooltip));
      await tester.tap(find.byTooltip(loc.appointmentsEditTooltip));
      await tester.pumpAndSettle();
      expect(find.textContaining('SMS'), findsNothing);
      final save = find.widgetWithText(ElevatedButton, loc.save);
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(updated, isNotNull);
      expect(updated!['no_sms'], isTrue);
      expect(updated!['no_reminder'], isTrue);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.method == 'PUT') {
                updated = jsonDecode(request.body) as Map<String, dynamic>;
                return http.Response('{"data":{},"code":"UPDATED"}', 200);
              }
              return appointmentResponse(request);
            }));
  });

  testWidgets('Rescheduling validates the slot and disables SMS',
      (tester) async {
    Map<String, dynamic>? created;
    var validated = false;
    await http.runWithClient(() async {
      await tester.pumpWidget(appointmentsApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(AppointmentsPage)));
      await tester.ensureVisible(find.byTooltip(loc.appointmentsRebookTooltip));
      await tester.tap(find.byTooltip(loc.appointmentsRebookTooltip));
      await tester.pumpAndSettle();
      final dateField = find.descendant(
          of: find.byType(BottomSheet), matching: fieldWithLabel(loc.date));
      tester.widget<TextField>(dateField).controller!.text = '2026-10-20';
      final times = find.widgetWithText(OutlinedButton, loc.getAvailableTimes);
      await tester.ensureVisible(times);
      await tester.tap(times);
      await tester.pumpAndSettle();
      final time = find.descendant(
          of: find.byType(BottomSheet), matching: find.text('10:30'));
      await tester.ensureVisible(time);
      await tester.tap(time);
      await tester.pumpAndSettle();
      final save =
          find.widgetWithText(ElevatedButton, loc.rescheduleAppointment);
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(validated, isTrue);
      expect(created, isNotNull);
      expect(created!['no_sms'], isTrue);
      expect(created!['no_reminder'], isTrue);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.method == 'POST' &&
                  request.url.path.endsWith('/validate')) {
                validated = true;
                return http.Response('{"data":{},"code":"OK"}', 200);
              }
              if (request.method == 'POST' &&
                  request.url.path == '/api/appointments') {
                created = jsonDecode(request.body) as Map<String, dynamic>;
                return http.Response('{"data":{},"code":"CREATED"}', 201);
              }
              return appointmentResponse(request);
            }));
  });
}
