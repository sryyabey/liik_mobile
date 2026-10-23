import 'dart:convert';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/widgets/appointment_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Sharing accepts only web URLs from the API', () {
    expect(appointmentShareUrl({'share_url': 'https://liik.test/apo/Xc6Tsx'}),
        'https://liik.test/apo/Xc6Tsx');
    expect(appointmentShareUrl({'share_url': 'javascript:alert(1)'}), isNull);
    expect(appointmentShareUrl({}), isNull);
  });
  testWidgets(
      'Details loads current data, history and copyable short link at large text size',
      (tester) async {
    SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'});
    final appointment = {
      'id': 5,
      'share_code': 'Xc6Tsx',
      'share_url': 'https://liik.test/apo/Xc6Tsx',
      'date': '2026-10-20T00:00:00.000000Z',
      'time': '14:00:00',
      'timezone': 'America/New_York',
      'customer': {'name': 'Jamie Taylor', 'email': 'jamie@example.com'},
      'notes': 'Bring documents',
      'appointment_status': {'alias': 'confirmed'}
    };
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData')
        copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await http.runWithClient(() async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.8)),
            child: child!),
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () => showAppointmentDetails(context, {'id': 5}),
                    child: const Text('Open')))),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Jamie Taylor'), findsOneWidget);
      expect(find.text('America/New_York'), findsOneWidget);
      expect(find.text('Xc6Tsx'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Copy link'));
      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();
      expect(copied, 'https://liik.test/apo/Xc6Tsx');
      await tester.ensureVisible(find.text('Appointment history'));
      expect(find.text('Appointment history'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async => http.Response(
            jsonEncode({
              'data': appointment,
              'meta': {
                'recent_appointments': [appointment]
              }
            }),
            200)));
  });
}
