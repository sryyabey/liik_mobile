import 'dart:convert';
import 'package:bagla_mobile/widgets/theme_tier_badge.dart';
import 'package:bagla_mobile/app_locale.dart';
import 'package:bagla_mobile/config.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import 'package:bagla_mobile/pages/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class ThemeTestWebView extends WebViewPlatform {
  final controllers = <ThemeTestController>[];
  @override
  PlatformWebViewController createPlatformWebViewController(
      PlatformWebViewControllerCreationParams params) {
    final controller = ThemeTestController(params);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
          PlatformNavigationDelegateCreationParams params) =>
      ThemeTestDelegate(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      ThemeTestWidget(params);
}

class ThemeTestController extends PlatformWebViewController {
  ThemeTestController(super.params) : super.implementation();
  ThemeTestDelegate? delegate;
  Uri? requested;
  Map<String, String> headers = {};
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate delegate) async {
    this.delegate = delegate as ThemeTestDelegate;
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    requested = params.uri;
    headers = params.headers;
    delegate?.finished?.call(params.uri.toString());
  }
}

class ThemeTestDelegate extends PlatformNavigationDelegate {
  ThemeTestDelegate(super.params) : super.implementation();
  PageEventCallback? started, finished;
  WebResourceErrorCallback? error;
  HttpResponseErrorCallback? httpError;
  NavigationRequestCallback? navigation;
  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    started = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    finished = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    error = callback;
  }

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback callback) async {
    httpError = callback;
  }

  @override
  Future<void> setOnNavigationRequest(
      NavigationRequestCallback callback) async {
    navigation = callback;
  }
}

class ThemeTestWidget extends PlatformWebViewWidget {
  ThemeTestWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const ColoredBox(
      color: Colors.white,
      child: Center(
          child: Icon(Icons.phone_iphone_outlined,
              color: Color(0xFF0866EB), size: 48)));
}

http.Response themesResponse(http.Request request, {bool empty = false}) {
  if (request.url.path == '/api/settings/themes') {
    return http.Response(
        jsonEncode({
          'meta': {'selected_theme_name': 'aurora'},
          'data': empty
              ? []
              : [
                  {'id': 1, 'name': 'aurora', 'is_premium': false},
                  {'id': 2, 'name': 'minimalpro', 'is_premium': true}
                ]
        }),
        200);
  }
  return http.Response('{"data":{"id":42}}', 200);
}

Widget themesApp(Locale locale, {double scale = 1}) => MaterialApp(
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
    home: const ThemesPage());
void main() {
  test('Premium metadata accepts API booleans and legacy values', () {
    for (final value in [true, 1, '1', 'true']) {
      expect(isPremiumTheme({'is_premium': value}), isTrue);
    }
    for (final value in [false, 0, '0', 'false', null]) {
      expect(isPremiumTheme({'is_premium': value}), isFalse);
    }
    expect(isPremiumTheme({}), isFalse);
  });
  late ThemeTestWebView web;
  setUp(() {
    SharedPreferences.setMockInitialValues({'bearer_token': 'test-token'});
    web = ThemeTestWebView();
    WebViewPlatform.instance = web;
  });
  for (final locale in liikLocales) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Theme gallery, selection and preview $locale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await http.runWithClient(() async {
          await tester.pumpWidget(themesApp(locale, scale: scale));
          await tester.pumpAndSettle();
          final loc =
              AppLocalizations.of(tester.element(find.byType(ThemesPage)));
          expect(find.widgetWithText(FilledButton, loc.themesApplied),
              findsOneWidget);
          expect(find.text(loc.themesFree), findsOneWidget);
          expect(find.text(loc.themesPremium), findsOneWidget);
          expect(web.controllers.last.headers['Accept-Language'],
              locale.toLanguageTag());
          expect(tester.takeException(), isNull);
          final card = find.byKey(const ValueKey('theme-2'));
          await tester.ensureVisible(card);
          await tester.pumpAndSettle();
          await tester.tap(card);
          await tester.pumpAndSettle();
          expect(find.text(loc.themesUnsaved), findsOneWidget);
          expect(web.controllers.last.requested,
              Uri.parse('$apiBaseUrl/bio-pages/preview/42?theme=2'));
          await tester.tap(find.byTooltip(loc.themesViewPreview));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }, () => MockClient((r) async => themesResponse(r)));
      });
    }
  }
  testWidgets(
      'Failed save retains selection and retry applies the selected theme',
      (tester) async {
    var attempts = 0;
    Map<String, dynamic>? saved;
    await http.runWithClient(() async {
      await tester.pumpWidget(themesApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(ThemesPage)));
      expect(
          tester
              .widget<FilledButton>(
                  find.widgetWithText(FilledButton, loc.themesApplied))
              .onPressed,
          isNull);
      final card = find.byKey(const ValueKey('theme-2'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      final save = find.widgetWithText(FilledButton, loc.themesSaveButton);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Please try again'), findsOneWidget);
      expect(find.text(loc.themesUnsaved), findsOneWidget);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(saved!['theme_id'], 2);
      expect(
          tester
              .widget<FilledButton>(
                  find.widgetWithText(FilledButton, loc.themesApplied))
              .onPressed,
          isNull);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.method == 'POST') {
                attempts++;
                saved = jsonDecode(r.body);
                return attempts == 1
                    ? http.Response('{"message":"Please try again"}', 422)
                    : http.Response('{}', 200);
              }
              return themesResponse(r);
            }));
  });
  testWidgets(
      'Preview errors ignore old themes and subresources, then retry current theme',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(themesApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(ThemesPage)));
      final old = web.controllers.first;
      final card = find.byKey(const ValueKey('theme-2'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      old.delegate!.error!(const WebResourceError(
          errorCode: -2, description: 'old error', isForMainFrame: true));
      web.controllers.last.delegate!.error!(const WebResourceError(
          errorCode: -2, description: 'image error', isForMainFrame: false));
      await tester.pumpAndSettle();
      expect(find.text(loc.themesPreviewError), findsNothing);
      web.controllers.last.delegate!.error!(const WebResourceError(
          errorCode: -2, description: 'network error', isForMainFrame: true));
      await tester.pumpAndSettle();
      expect(find.text(loc.themesPreviewError), findsOneWidget);
      final retry = find.text(loc.themesRetry);
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(find.text(loc.themesPreviewError), findsNothing);
      expect(web.controllers.last.requested!.queryParameters['theme'], '2');
      final decision = await web.controllers.last.delegate!.navigation!(
          const NavigationRequest(
              url: 'mailto:hello@example.com', isMainFrame: true));
      expect(decision, NavigationDecision.prevent);
      expect(tester.takeException(), isNull);
    }, () => MockClient((r) async => themesResponse(r)));
  });
  testWidgets('Failed list loads can retry; empty list cannot apply a theme',
      (tester) async {
    var attempts = 0;
    await http.runWithClient(() async {
      await tester.pumpWidget(themesApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(tester.element(find.byType(ThemesPage)));
      expect(find.text(loc.themesLoadError), findsOneWidget);
      await tester.tap(find.text(loc.themesRetry));
      await tester.pumpAndSettle();
      expect(find.text(loc.themesNoThemes), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((r) async {
              if (r.url.path == '/api/settings/themes') {
                attempts++;
                if (attempts == 1) return http.Response('{}', 500);
              }
              return themesResponse(r, empty: true);
            }));
  });
  testWidgets('Fifty themes can be browsed horizontally in both directions',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(themesApp(defaultLiikLocale));
      await tester.pumpAndSettle();
      final carousel = find.descendant(
          of: find.byKey(const PageStorageKey('theme-carousel')),
          matching: find.byType(Scrollable));
      expect(tester.widget<Scrollable>(carousel).axisDirection,
          AxisDirection.right);
      final last = find.byKey(const ValueKey('theme-50'));
      await tester.scrollUntilVisible(last, 400,
          scrollable: carousel, maxScrolls: 40);
      await tester.pumpAndSettle();
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(web.controllers.last.requested!.queryParameters['theme'], '50');
      final first = find.byKey(const ValueKey('theme-1'));
      await tester.scrollUntilVisible(first, -400,
          scrollable: carousel, maxScrolls: 40);
      await tester.pumpAndSettle();
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(web.controllers.last.requested!.queryParameters['theme'], '1');
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.url.path == '/api/settings/themes')
                return http.Response(
                    jsonEncode({
                      'selected_theme_name': 'aurora',
                      'data': List.generate(
                          50,
                          (i) => {
                                'id': i + 1,
                                'name': i == 0 ? 'aurora' : 'Theme ${i + 1}'
                              })
                    }),
                    200);
              return themesResponse(request);
            }));
  });
}
