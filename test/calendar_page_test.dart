import 'dart:convert';
import 'package:liik_mobile/app_locale.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/pages/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointments_page_test.dart' show appointmentResponse;

String iso(DateTime date) => date.toIso8601String().substring(0, 10);
WeeklyCalendarData calendarFixture(DateTime week) {
  final days = List.generate(7, (i) {
    final date = week.add(Duration(days: i));
    return WeekDayInfo(
        date: iso(date),
        dayOfWeekIso: date.weekday,
        label: '',
        shortLabel: '',
        displayDate: '',
        isToday: iso(date) == iso(DateTime.now()),
        isWorking: true);
  });
  return WeeklyCalendarData(
      weekStart: week,
      weekEnd: week.add(const Duration(days: 6)),
      weekRangeText: '',
      weekDays: days,
      timeSlotsByDay: {
        for (final day in days)
          day.date: const [
            SlotInfo(time: '10:30', booked: true, slotIndex: 0, period: 30),
            SlotInfo(time: '11:00', booked: false, slotIndex: 1, period: 30)
          ]
      },
      timeGrid: ['10:30', '11:00'],
      appointmentsBySlot: {
        for (final day in days)
          '${day.date}_10:30': [
            {
              'id': 11,
              'customer_id': 7,
              'customer': {
                'name': 'Alex',
                'lastname': 'Morgan',
                'phone': '+5511987654321'
              },
              'customer_phone': '+5511987654321',
              'date': day.date,
              'time': '10:30',
              'status_alias': 'confirmed',
              'appointment_status': {'id': 2, 'alias': 'confirmed'}
            }
          ]
      },
      statusColors: {'confirmed': 'success'},
      workingPreferences: {},
      hasTimeSlots: true,
      hasUserPack: true);
}

Widget calendarApp(Locale locale,
        {double scale = 1, ValueChanged<DateTime>? onWeek}) =>
    ProviderScope(
        overrides: [
          weeklyCalendarProvider.overrideWith((ref, week) async {
            onWeek?.call(week);
            return calendarFixture(week);
          })
        ],
        child: MaterialApp(
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
            home: const CalendarPage(showBottomNav: false)));
void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'}));
  testWidgets(
      'Tapping calendar client opens appointment information and sharing',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await http.runWithClient(() async {
      await tester.pumpWidget(calendarApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final name = find.text('Alex Morgan').first;
      await tester.ensureVisible(name);
      await tester.tap(name);
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(CalendarPage)));
      expect(find.text(loc.appointmentDetails), findsOneWidget);
      await tester.ensureVisible(find.text(loc.appointmentCopyLink));
      expect(find.text('https://liik.test/apo/Xc6Tsx'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.url.path == '/api/appointments/11') {
                return http.Response(
                    jsonEncode({
                      'data': {
                        'id': 11,
                        'customer': {'name': 'Alex Morgan'},
                        'date': '2026-10-20',
                        'time': '10:30',
                        'share_url': 'https://liik.test/apo/Xc6Tsx',
                        'share_code': 'Xc6Tsx'
                      },
                      'meta': {'recent_appointments': []}
                    }),
                    200);
              }
              return appointmentResponse(request);
            }));
  });
  testWidgets('Calendar actions have equal widths, heights and spacing',
      (tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await http.runWithClient(() async {
      await tester.pumpWidget(calendarApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(CalendarPage)));
      final buttons = [
        loc.calendarActionNew,
        loc.calendarActionEdit,
        loc.appointmentShare
      ].map((label) => find.byTooltip(label).first).toList();
      await tester.ensureVisible(buttons.first);
      await tester.pumpAndSettle();
      final rects = buttons.map(tester.getRect).toList();
      for (final rect in rects) {
        expect(rect.width, closeTo(rects.first.width, .01));
        expect(rect.height, 44);
        expect(rect.top, closeTo(rects.first.top, .01));
      }
      expect(rects[1].left - rects[0].right, closeTo(8, .01));
      expect(rects[2].left - rects[1].right, closeTo(8, .01));
      expect(tester.takeException(), isNull);
    }, () => MockClient((request) async => appointmentResponse(request)));
  });
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Weekly calendar and shared form $locale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final weeks = <DateTime>[];
        await http.runWithClient(() async {
          await tester
              .pumpWidget(calendarApp(locale, scale: scale, onWeek: weeks.add));
          await tester.pumpAndSettle();
          final loc =
              AppLocalizations.of(tester.element(find.byType(CalendarPage)));
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip(loc.calendarNext));
          await tester.pumpAndSettle();
          expect(weeks.last.difference(weeks.first).inDays, 7);
          final add = find.text(loc.calendarAddAppointment).first;
          await tester.ensureVisible(add);
          await tester.pumpAndSettle();
          await tester.tap(add);
          await tester.pumpAndSettle();
          expect(find.text(loc.calendarExistingPerson), findsOneWidget);
          expect(find.text(loc.calendarNewPerson), findsOneWidget);
          expect(find.textContaining('SMS'), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(loc.calendarNewPerson));
          await tester.pumpAndSettle();
          final phone = find.byWidgetPredicate((w) =>
              w is TextField &&
              w.decoration?.labelText == loc.appointmentsFieldPhone);
          await tester.ensureVisible(phone);
          await tester.enterText(phone, '11987654321');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }, () => MockClient((request) async => appointmentResponse(request)));
      });
    }
  }
  testWidgets(
      'Existing contact booking uses the directory and saves without SMS',
      (tester) async {
    Map<String, dynamic>? saved;
    await http.runWithClient(() async {
      await tester.pumpWidget(calendarApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc =
          AppLocalizations.of(tester.element(find.byType(CalendarPage)));
      final add = find.text(loc.calendarAddAppointment).first;
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.tap(find.text(loc.calendarSelectPerson));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alex Morgan').last);
      await tester.pumpAndSettle();
      final save = find.widgetWithText(ElevatedButton, loc.save).last;
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(saved, isNotNull);
      expect(saved!['customer_id'], 7);
      expect(saved!['no_sms'], true);
      expect(saved!['no_reminder'], true);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.method == 'POST') {
                if (request.url.path == '/api/appointments')
                  saved = jsonDecode(request.body) as Map<String, dynamic>;
                return http.Response('{"code":"CREATED","data":{}}', 200);
              }
              return appointmentResponse(request);
            }));
  });
}
