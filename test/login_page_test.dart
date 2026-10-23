import 'package:liik_mobile/app_locale.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const appleChannel =
      MethodChannel('com.aboutyou.dart_packages.sign_in_with_apple');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            appleChannel, (call) async => call.method == 'isAvailable');
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appleChannel, null);
  });
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Login fits $locale with text scale $scale and keyboard',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
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
          home: LoginPage(onLocaleChange: (_) {}),
        ));
        await tester.pumpAndSettle();
        final loc = AppLocalizations.of(tester.element(find.byType(LoginPage)));
        expect(find.text(loc.loginWelcome), findsOneWidget);
        expect(find.text(loc.loginApple), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text(loc.loginButton));
        await tester.tap(find.text(loc.loginButton));
        await tester.pumpAndSettle();
        expect(find.text(loc.loginEmailValidation), findsOneWidget);
        expect(find.text(loc.loginPasswordValidation), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.enterText(
            find.byType(TextFormField).first, 'alex@example.com');
        await tester.enterText(
            find.byType(TextFormField).last, 'secret-password');
        await tester.ensureVisible(find.byTooltip(loc.loginShowPassword));
        await tester.tap(find.byTooltip(loc.loginShowPassword));
        await tester.pumpAndSettle();
        expect(
            tester.widget<TextField>(find.byType(TextField).last).obscureText,
            isFalse);
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(TextFormField).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
