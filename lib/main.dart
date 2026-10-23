import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added import for SharedPreferences
import 'auth.dart';
import 'user_timezone.dart';
import 'app_locale.dart';
import 'login_page.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'main_tabs_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserTimeZone.load();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: LiikApp()));
}

class LiikApp extends StatefulWidget {
  const LiikApp({super.key});

  @override
  State<LiikApp> createState() => LiikAppState();
}

class LiikAppState extends State<LiikApp> {
  Locale? _locale;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initLocale();
    _checkLoginStatus();
  }

  Future<void> _initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('preferred_locale');
    final locale = saved != null && saved.isNotEmpty
        ? parseLiikLocale(saved)
        : resolveLiikLocale(WidgetsBinding.instance.platformDispatcher.locale);
    if (!mounted) return;
    setState(() => _locale = locale);
    await prefs.setString('preferred_locale', locale.toLanguageTag());
  }

  void _checkLoginStatus() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  void setLocale(Locale locale) async {
    final supported = resolveLiikLocale(locale);
    setState(() => _locale = supported);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_locale', supported.toLanguageTag());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0866EB)),
        scaffoldBackgroundColor: const Color(0xFFF0F5FF),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: liikLocales,
      locale: _locale ?? defaultLiikLocale,
      home: _isLoggedIn
          ? const MainTabsPage()
          : SplashScreen(onLocaleChange: setLocale),
    );
  }
}

// Liik welcome flow.
class SplashScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const SplashScreen({super.key, required this.onLocaleChange});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OnboardingScreen(onLocaleChange: widget.onLocaleChange),
          ));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(40),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Image.asset('assets/liik-logo-2.png',
                  semanticLabel: 'Liik — Link, Identity, Interaction, Key')),
        )),
      );
}

const _ink = Color(0xFF0C2032);
const _blue = Color(0xFF0866EB);
const _teal = Color(0xFF00BFAE);
const _coral = Color(0xFFFF6055);

class OnboardingScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const OnboardingScreen({super.key, required this.onLocaleChange});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  void _goToLogin() => Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(onLocaleChange: widget.onLocaleChange),
      ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final titles = [loc.onboardTitle1, loc.onboardTitle2, loc.onboardTitle3];
    final descriptions = [loc.onboardDesc1, loc.onboardDesc2, loc.onboardDesc3];
    final labels = [loc.onboardBadge1, loc.onboardBadge2, loc.onboardBadge3];
    final colors = [_blue, _teal, _coral];
    final accent = colors[_current];
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 4),
              child: Row(children: [
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Image.asset('assets/liik-logo-2.png',
                                  width: 100,
                                  height: 54,
                                  fit: BoxFit.contain,
                                  semanticLabel: 'Liik'),
                            ])))),
                Flexible(
                    flex: 2,
                    child:
                        LiikLanguagePicker(onChanged: widget.onLocaleChange)),
                TextButton(
                    onPressed: _goToLogin,
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: Text(loc.onboardSkip,
                        style: const TextStyle(
                            color: Color(0xFF667585), fontSize: 12))),
              ])),
          Expanded(
              child: PageView.builder(
            controller: _controller,
            itemCount: 3,
            onPageChanged: (value) => setState(() => _current = value),
            itemBuilder: (context, index) => LayoutBuilder(
                builder: (context, size) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: size.maxHeight - 36),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: (size.maxHeight * .49)
                                        .clamp(230.0, 340.0),
                                    width: double.infinity,
                                    child: _LiikPreview(
                                        index: index, accent: colors[index])),
                                const SizedBox(height: 32),
                                Text(labels[index],
                                    style: TextStyle(
                                        color: colors[index] == _teal
                                            ? const Color(0xFF008577)
                                            : colors[index] == _coral
                                                ? const Color(0xFFC94036)
                                                : _blue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2)),
                                const SizedBox(height: 13),
                                Text(titles[index],
                                    style: const TextStyle(
                                        color: _ink,
                                        fontSize: 34,
                                        height: 1.12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1.3)),
                                const SizedBox(height: 16),
                                Text(descriptions[index],
                                    style: const TextStyle(
                                        color: Color(0xFF627183),
                                        fontSize: 16,
                                        height: 1.6)),
                              ])),
                    )),
          )),
          Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 6,
                              width: i == _current ? 28 : 7,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                  color: i == _current
                                      ? accent
                                      : const Color(0xFFDCE2EA),
                                  borderRadius: BorderRadius.circular(12)),
                            ))),
                const SizedBox(height: 24),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_current == 2) {
                          _goToLogin();
                        } else {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic);
                        }
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: _ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                                child: Text(
                                    _current == 2
                                        ? loc.onboardStart
                                        : loc.onboardContinue,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center)),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ]),
                    )),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: _goToLogin,
                    child: Text(loc.onboardLogin,
                        style: const TextStyle(
                            color: Color(0xFF627183), fontSize: 13))),
              ])),
        ]),
      ))),
    );
  }
}

class _LiikPreview extends StatelessWidget {
  final int index;
  final Color accent;
  const _LiikPreview({required this.index, required this.accent});

  Widget _tile(IconData icon, String title,
          {String? subtitle, bool selected = false}) =>
      Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: .09)
                : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: selected ? accent : const Color(0xFFE9EDF2))),
        child: Row(children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF627183), fontSize: 11)),
              ])),
          Icon(selected ? Icons.check_circle_rounded : Icons.north_east_rounded,
              color: selected ? accent : const Color(0xFF8291A2), size: 17),
        ]),
      );

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: accent.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(32)),
        child: Transform.rotate(
            angle: index == 0 ? -.035 : .025,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 310),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8ECF2)),
                  boxShadow: [
                    BoxShadow(
                        color: _ink.withValues(alpha: .07),
                        blurRadius: 25,
                        offset: const Offset(0, 12))
                  ]),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                      width: 240,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        if (index == 0) ...[
                          Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: accent.withValues(alpha: .1),
                                  shape: BoxShape.circle),
                              child: Icon(Icons.person_outline_rounded,
                                  color: accent, size: 30)),
                          const SizedBox(height: 10),
                          Text(AppLocalizations.of(context).onboardPreviewName,
                              style: const TextStyle(
                                  color: _ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                              AppLocalizations.of(context)
                                  .onboardPreviewTagline,
                              style: const TextStyle(
                                  color: Color(0xFF627183), fontSize: 11)),
                          _tile(
                              Icons.public_rounded,
                              AppLocalizations.of(context)
                                  .onboardPreviewExplore),
                          _tile(Icons.calendar_today_rounded,
                              AppLocalizations.of(context).onboardPreviewBook),
                        ] else if (index == 1) ...[
                          Row(children: [
                            Icon(Icons.calendar_month_rounded, color: accent),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    AppLocalizations.of(context)
                                        .onboardPreviewCall,
                                    style: const TextStyle(
                                        color: _ink,
                                        fontWeight: FontWeight.w800)))
                          ]),
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  AppLocalizations.of(context)
                                      .onboardPreviewDuration,
                                  style: const TextStyle(
                                      color: Color(0xFF627183), fontSize: 12))),
                          const SizedBox(height: 16),
                          Row(
                              children: List.generate(
                                  5,
                                  (i) => Expanded(
                                          child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                            color: i == 2
                                                ? accent
                                                : const Color(0xFFF5F7FA),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text('${18 + i}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: i == 2
                                                    ? Colors.white
                                                    : _ink,
                                                fontWeight: FontWeight.w700)),
                                      )))),
                          _tile(Icons.schedule_rounded, '10:30 – 11:00',
                              selected: true),
                          _tile(Icons.schedule_rounded, '14:00 – 14:30'),
                        ] else ...[
                          Image.asset('assets/liik-logo-2.png',
                              width: 230, height: 115, fit: BoxFit.contain),
                          _tile(Icons.link_rounded,
                              AppLocalizations.of(context).onboardPreviewReady,
                              subtitle: AppLocalizations.of(context)
                                  .onboardPreviewShareHint),
                          _tile(
                              Icons.ios_share_rounded,
                              AppLocalizations.of(context)
                                  .onboardPreviewConnections,
                              selected: true),
                        ],
                      ]))),
            )),
      );
}
