import 'dart:convert';
import 'package:bagla_mobile/app_locale.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import 'package:bagla_mobile/pages/support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response supportJson(dynamic body, [int status = 200]) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json; charset=utf-8'});
Map<String, dynamic> supportFixture(
        {String status = 'open', List<Map<String, dynamic>>? messages}) =>
    {
      'id': 7,
      'title': 'Help with my Liik page',
      'status': status,
      'status_label': 'Açık',
      'priority': 'medium',
      'message_count': 2,
      'created_at': '2026-10-19T10:30:00Z',
      'messages': messages ??
          [
            {
              'id': 1,
              'message': 'Please help me update my page.',
              'created_at': '2026-10-19T10:30:00Z',
              'sender': {'name': 'Alex', 'is_owner': true}
            },
            {
              'id': 2,
              'message': 'We can help with that.',
              'created_at': '2026-10-19T10:35:00Z',
              'sender': {'name': 'Liik Support', 'is_owner': false}
            }
          ]
    };
http.Response supportResponse(http.Request request) {
  final dynamic data = request.url.path.endsWith('/tickets')
      ? [supportFixture()]
      : supportFixture();
  return supportJson({'data': data});
}

Widget supportApp(Locale locale, {double scale = 1}) => MaterialApp(
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
    home: const SupportPage());
Future<void> openTicket(WidgetTester tester) async {
  final ticket = find.byKey(const ValueKey('ticket-7'));
  await tester.scrollUntilVisible(ticket, 200,
      scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(ticket);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'}));
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Support list, conversation and form $locale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await http.runWithClient(() async {
          await tester.pumpWidget(supportApp(locale, scale: scale));
          await tester.pumpAndSettle();
          final loc =
              AppLocalizations.of(tester.element(find.byType(SupportPage)));
          expect(find.text('Açık'), findsNothing);
          expect(tester.takeException(), isNull);
          await openTicket(tester);
          final conversation = find.descendant(of:find.byType(BottomSheet),matching:find.byType(Scrollable)).first;
          for(final message in ['Please help me update my page.','We can help with that.']) {
            await tester.scrollUntilVisible(find.text(message),150,scrollable:conversation);
            await tester.pumpAndSettle();
            expect(find.text(message),findsOneWidget);
          }
          expect(find.text(loc.supportStatusOpen), findsWidgets);
          expect(find.text('Açık'), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.enterText(
              find.byKey(const ValueKey('support-reply')), 'Please help');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle();
          final add = find.widgetWithText(FilledButton, loc.supportNewTicket);
          await tester.scrollUntilVisible(add, -200,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          await tester.tap(add);
          await tester.pumpAndSettle();
          await tester.enterText(
              find.byKey(const ValueKey('support-title')), 'My request');
          await tester.enterText(find.byKey(const ValueKey('support-message')),
              'Please help with my page.');
          final send = find.widgetWithText(FilledButton, loc.supportSend);
          await tester.ensureVisible(send);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }, () => MockClient((r) async => supportResponse(r)));
      });
    }
  }
  testWidgets('Ticket creation validates and preserves text on a failed send',
      (tester) async {
    var attempts = 0;
    Map<String, dynamic>? payload;
    await http.runWithClient(() async {
      await tester.pumpWidget(supportApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(SupportPage)));
      await tester.tap(find.widgetWithText(FilledButton, loc.supportNewTicket));
      await tester.pumpAndSettle();
      final send = find.widgetWithText(FilledButton, loc.supportSend);
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(attempts, 0);
      await tester.enterText(
          find.byKey(const ValueKey('support-title')), 'Page issue');
      await tester.enterText(find.byKey(const ValueKey('support-message')),
          'Please help with my page.');
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(find.text('Please retry'), findsOneWidget);
      expect(
          tester
              .widget<TextFormField>(
                  find.byKey(const ValueKey('support-message')))
              .controller!
              .text,
          'Please help with my page.');
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(payload!['title'], 'Page issue');
      expect(payload!['message'], 'Please help with my page.');
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.method == 'POST') {
                attempts++;
                payload = jsonDecode(r.body);
                return attempts == 1
                    ? http.Response('{"message":"Please retry"}', 422)
                    : supportJson({'data': supportFixture()}, 201);
              }
              return supportResponse(r);
            }));
  });
  testWidgets(
      'Replies retry without losing text, and closing needs confirmation',
      (tester) async {
    var replyAttempts = 0, closed = false;
    String? sent;
    await http.runWithClient(() async {
      await tester.pumpWidget(supportApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(SupportPage)));
      await openTicket(tester);
      final input = find.byKey(const ValueKey('support-reply'));
      await tester.enterText(input, 'Thank you for your help.');
      await tester.tap(find.byTooltip(loc.supportReplySend));
      await tester.pumpAndSettle();
      expect(find.text('Please retry'), findsOneWidget);
      expect(tester.widget<TextField>(input).controller!.text,
          'Thank you for your help.');
      await tester.tap(find.byTooltip(loc.supportReplySend));
      await tester.pumpAndSettle();
      expect(replyAttempts, 2);
      expect(sent, 'Thank you for your help.');
      expect(tester.widget<TextField>(input).controller!.text, '');
      expect(find.text('Thank you for your help.'), findsOneWidget);
      final close = find.widgetWithText(TextButton, loc.supportCloseTicket);
      await tester.ensureVisible(close);
      await tester.pumpAndSettle();
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(closed, false);
      await tester.tap(find.text(loc.customersCancel));
      await tester.pumpAndSettle();
      expect(closed, false);
      await tester.tap(close);
      await tester.pumpAndSettle();
      await tester
          .tap(find.widgetWithText(FilledButton, loc.supportCloseTicket));
      await tester.pumpAndSettle();
      expect(closed, true);
      expect(find.text(loc.supportReplyClosed), findsOneWidget);
      expect(find.byKey(const ValueKey('support-reply')), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.url.path.endsWith('/reply')) {
                replyAttempts++;
                sent = jsonDecode(r.body)['message'];
                return replyAttempts == 1
                    ? http.Response('{"message":"Please retry"}', 422)
                    : supportJson({
                        'data': supportFixture(messages: [
                          {
                            'message': sent,
                            'created_at': '2026-10-19T11:00:00Z',
                            'sender': {'is_owner': true}
                          }
                        ])
                      }, 201);
              }
              if (r.url.path.endsWith('/close')) {
                closed = true;
                return supportJson({'data': supportFixture(status: 'closed')});
              }
              return supportResponse(r);
            }));
  });
  testWidgets('List load retries and empty filters remain usable',
      (tester) async {
    var attempts = 0;
    await http.runWithClient(() async {
      await tester.pumpWidget(supportApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(SupportPage)));
      final retry = find.text(loc.supportRetry);
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry);
      await tester.pumpAndSettle();
      final finished = find.widgetWithText(ChoiceChip, loc.supportFinished);
      await tester.ensureVisible(finished);
      await tester.pumpAndSettle();
      await tester.tap(finished);
      await tester.pumpAndSettle();
      expect(find.text(loc.supportFilterEmpty), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              attempts++;
              return attempts == 1
                  ? http.Response('{}', 500)
                  : supportResponse(r);
            }));
  });
}
