import 'package:liik_mobile/app_locale.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Onboarding fits compact screens: $locale, scale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Locale? selected;
        await tester.pumpWidget(MaterialApp(
          locale: locale,
          supportedLocales: liikLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: OnboardingScreen(onLocaleChange: (value) => selected = value),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(OnboardingScreen));
        final loc = AppLocalizations.of(context);
        expect(loc.localeName, locale.toString());
        await tester.tap(find.byType(LiikLanguagePicker));
        await tester.pumpAndSettle();
        expect(find.text('Türkçe'), findsNothing);
        expect(find.text('English (UK)'), findsOneWidget);
        expect(find.text('Português (Brasil)'), findsOneWidget);
        expect(find.text('Bahasa Indonesia'), findsOneWidget);
        await tester.tap(find.text('English (UK)'));
        await tester.pumpAndSettle();
        expect(selected, const Locale('en', 'GB'));
        for (var step = 0; step < 2; step++) {
          await tester.tap(find.text(loc.onboardContinue));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(find.text(loc.onboardStart), findsOneWidget);
      });
    }
  }
}
