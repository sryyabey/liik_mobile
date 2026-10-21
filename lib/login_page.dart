import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'config.dart';
import 'auth.dart';
import 'app_locale.dart';
import 'services/apple_auth_service.dart';
import 'register_page.dart';
import 'main_tabs_page.dart';

class LoginPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const LoginPage({super.key, required this.onLocaleChange});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AppLocalizations get loc => AppLocalizations.of(context);
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    // Use the Web client ID here so the backend can verify idToken audience.
    serverClientId: googleWebServerClientId,
    // On iOS, the native clientId is read from GoogleService-Info.plist.
  );
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isAppleAvailable = false;
  String? _error;
  final AppleAuthService _appleAuthService = AppleAuthService();

  @override
  void initState() {
    super.initState();
    _checkAppleAvailability();
  }

  Future<void> _checkAppleAvailability() async {
    bool available;
    try {
      available = await SignInWithApple.isAvailable();
    } catch (_) {
      available = false;
    }
    if (!mounted) return;
    setState(() {
      _isAppleAvailable = available;
    });
  }

  Future<void> _storeToken(String token, {String? refresh}) async {
    await saveTokens(accessToken: token, refreshToken: refresh);
  }

  Future<void> _handleLoginSuccess(String token) async {
    await _storeToken(token);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainTabsPage(),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ??
            (data['data'] != null ? data['data']['token'] : null) ??
            data['access_token'];
        final refresh = data['refresh_token'] ??
            data['refreshToken'] ??
            (data['data'] != null ? data['data']['refresh_token'] : null);
        if (token != null) {
          await _storeToken(token, refresh: refresh?.toString());
          await _handleLoginSuccess(token);
        } else {
          _showError(loc.authTokenMissing);
        }
      } else if (response.statusCode == 401) {
        final msg = _extractMessage(response.body) ?? loc.authUnauthorized;
        _showError(msg);
      } else {
        final msg = _extractMessage(response.body) ??
            loc.authLoginFailed(response.statusCode);
        _showError(msg);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(loc.authConnectionFailed(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _error = null;
    });
    try {
      final account = await _googleSignIn.signIn();
      if (!mounted) return;
      if (account == null) {
        _showError(loc.authGoogleCancelled);
        return;
      }
      final auth = await account.authentication;
      if (!mounted) return;
      final idToken = auth.idToken;
      if (idToken == null) {
        _showError(loc.authGoogleTokenMissing);
        return;
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/login/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_token': idToken,
          'device_name': 'bagla_mobile',
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ??
            (data['data'] != null ? data['data']['token'] : null) ??
            data['access_token'];
        if (token != null) {
          await _handleLoginSuccess(token);
        } else {
          _showError(loc.authTokenMissing);
        }
      } else {
        final msg = _extractMessage(response.body) ??
            loc.authGoogleFailed(response.statusCode);
        _showError(msg);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(loc.authGoogleError(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithApple() async {
    setState(() {
      _isAppleLoading = true;
      _error = null;
    });

    try {
      final result = await _appleAuthService.login();
      await _handleLoginSuccess(result.token);
    } on AppleAuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError(loc.authAppleError(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isAppleLoading = false;
        });
      }
    }
  }

  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return null;
  }

  static const _ink = Color(0xFF0C2032);
  static const _blue = Color(0xFF0866EB);
  static const _muted = Color(0xFF627183);
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool get _busy => _isLoading || _isGoogleLoading || _isAppleLoading;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_busy || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _loginWithEmail();
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8B98A8), fontSize: 14),
      prefixIcon: Icon(icon, color: _muted, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5EAF1))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _blue, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC94036))),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC94036), width: 1.5)),
      errorMaxLines: 3,
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 9),
        child: Text(text,
            style: const TextStyle(
                color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 32)
                            .clamp(0.0, double.infinity)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset('assets/liik-logo-2.png',
                                        width: 112,
                                        height: 56,
                                        fit: BoxFit.contain,
                                        semanticLabel: 'Liik'))),
                            Flexible(
                                child: LiikLanguagePicker(
                                    onChanged: widget.onLocaleChange,
                                    foregroundColor: _ink)),
                          ]),
                          const SizedBox(height: 30),
                          Row(
                              children: List.generate(
                                  4,
                                  (index) => Container(
                                        width: index == 0 ? 32 : 12,
                                        height: 5,
                                        margin: const EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                            color: const [
                                              _blue,
                                              Color(0xFF00BFAE),
                                              Color(0xFFFF6055),
                                              Color(0xFFFFB614)
                                            ][index],
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ))),
                          const SizedBox(height: 18),
                          Text(loc.loginWelcome,
                              style: const TextStyle(
                                  color: _ink,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  height: 1.12,
                                  letterSpacing: -1.3)),
                          const SizedBox(height: 12),
                          Text(loc.loginWelcomeDescription,
                              style: const TextStyle(
                                  color: _muted, fontSize: 15, height: 1.6)),
                          const SizedBox(height: 30),
                          AutofillGroup(
                              child: Form(
                            key: _formKey,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label(loc.emailLabel),
                                  TextFormField(
                                    controller: emailController,
                                    enabled: !_busy,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.username,
                                      AutofillHints.email
                                    ],
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    style: const TextStyle(
                                        color: _ink, fontSize: 15),
                                    cursorColor: _blue,
                                    decoration: _decoration(loc.loginEmailHint,
                                        Icons.mail_outline_rounded),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      if (email.isEmpty ||
                                          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                              .hasMatch(email)) {
                                        return loc.loginEmailValidation;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _label(loc.passwordLabel),
                                  TextFormField(
                                    controller: passwordController,
                                    enabled: !_busy,
                                    obscureText: _hidePassword,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    style: const TextStyle(
                                        color: _ink, fontSize: 15),
                                    cursorColor: _blue,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: _decoration(
                                        loc.loginPasswordHint,
                                        Icons.lock_outline_rounded,
                                        suffix: IconButton(
                                          onPressed: _busy
                                              ? null
                                              : () => setState(() =>
                                                  _hidePassword =
                                                      !_hidePassword),
                                          tooltip: _hidePassword
                                              ? loc.loginShowPassword
                                              : loc.loginHidePassword,
                                          icon: Icon(
                                              _hidePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              size: 20,
                                              color: _muted),
                                        )),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? loc.loginPasswordValidation
                                            : null,
                                  ),
                                  if (_error != null)
                                    Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Semantics(
                                          liveRegion: true,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFFFF0EE),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .error_outline_rounded,
                                                      color: Color(0xFFC94036),
                                                      size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                      child: Text(_error!,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFFC94036),
                                                              fontSize: 13,
                                                              height: 1.4))),
                                                ]),
                                          ),
                                        )),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _busy ? null : _submit,
                                        style: FilledButton.styleFrom(
                                            backgroundColor: _ink,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 18, horizontal: 20),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16))),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white))
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                      child: Text(
                                                          loc.loginButton,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700))),
                                                  const SizedBox(width: 10),
                                                  const Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      size: 19)
                                                ],
                                              ),
                                      )),
                                ]),
                          )),
                          const SizedBox(height: 25),
                          Row(children: [
                            const Expanded(
                                child: Divider(color: Color(0xFFE2E8F0))),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(loc.loginOr,
                                    style: const TextStyle(
                                        color: _muted, fontSize: 13))),
                            const Expanded(
                                child: Divider(color: Color(0xFFE2E8F0)))
                          ]),
                          const SizedBox(height: 25),
                          SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _busy ? null : _loginWithGoogle,
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: _ink,
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    side: const BorderSide(
                                        color: Color(0xFFDFE5ED)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16))),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _isGoogleLoading
                                          ? const SizedBox(
                                              width: 21,
                                              height: 21,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2))
                                          : Image.asset(
                                              'assets/google_icon.png',
                                              width: 21,
                                              height: 21),
                                      const SizedBox(width: 12),
                                      Flexible(
                                          child: Text(
                                              _isGoogleLoading
                                                  ? loc.googleConnecting
                                                  : loc.googleLogin,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ]),
                              )),
                          if (_isAppleAvailable ||
                              kIsWeb ||
                              defaultTargetPlatform ==
                                  TargetPlatform.android) ...[
                            const SizedBox(height: 12),
                            AbsorbPointer(
                                absorbing: _busy,
                                child: Opacity(
                                  opacity: _busy ? .55 : 1,
                                  child: SignInWithAppleButton(
                                    onPressed: _loginWithApple,
                                    text: _isAppleLoading
                                        ? loc.googleConnecting
                                        : loc.loginApple,
                                    style: SignInWithAppleButtonStyle.black,
                                    height: 50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                )),
                          ],
                          const SizedBox(height: 25),
                          Center(
                              child: Text(loc.loginNoAccount,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: _muted, fontSize: 13))),
                          Center(
                              child: TextButton(
                            onPressed: _busy
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterPage())),
                            child: Text(loc.registerTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: _blue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          )),
                        ]),
                  ),
                )),
      ))),
    );
  }
}
