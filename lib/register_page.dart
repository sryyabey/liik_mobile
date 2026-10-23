import 'package:liik_mobile/l10n/app_localizations.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth.dart';
import 'config.dart';
import 'email_verification_page.dart';
import 'main_tabs_page.dart';
import 'services/apple_auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  AppLocalizations get loc => AppLocalizations.of(context);
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _usernameController = TextEditingController();
  final String _deviceName = 'liik_mobile';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId:
        googleWebServerClientId.isEmpty ? null : googleWebServerClientId,
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
    final available = await SignInWithApple.isAvailable();
    if (!mounted) return;
    setState(() {
      _isAppleAvailable = available;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _storeToken(String token, {String? refresh}) async {
    await saveTokens(accessToken: token, refreshToken: refresh);
  }

  // E-posta ile kayıt: doğrulama ekranına yönlendir
  Future<void> _handleEmailRegisterSuccess(String token, String email) async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EmailVerificationPage(email: email, token: token),
      ),
    );
  }

  // Google / Apple ile kayıt: direkt ana sayfaya
  Future<void> _handleSocialRegisterSuccess(String token) async {
    await _storeToken(token);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainTabsPage()),
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

  String _formatValidationErrors(dynamic errors) {
    if (errors is Map) {
      final messages = <String>[];
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List) {
          messages.addAll(value.map((e) => e.toString()));
        } else if (value != null) {
          messages.add(value.toString());
        }
      }
      if (messages.isNotEmpty) return messages.join('\n');
    }
    return loc.registerError;
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;
    final username = _usernameController.text.trim();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirm,
      };
      if (username.isNotEmpty) {
        body['username'] = username;
      }
      body['device_name'] = _deviceName;

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'] ??
            (data['data'] != null ? data['data']['token'] : null) ??
            data['access_token'];
        if (token != null) {
          await _handleEmailRegisterSuccess(token.toString(), email);
        } else {
          _showError(loc.authTokenMissing);
        }
      } else if (response.statusCode == 422) {
        final decoded = jsonDecode(response.body);
        final message = decoded['message']?.toString();
        final errors = decoded['errors'];
        _showError(message ?? _formatValidationErrors(errors));
      } else {
        _showError(loc.authRegisterFailed(response.statusCode));
      }
    } catch (e) {
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
          'device_name': _deviceName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ??
            (data['data'] != null ? data['data']['token'] : null) ??
            data['access_token'];
        if (token != null) {
          await _handleSocialRegisterSuccess(token.toString());
        } else {
          _showError(loc.authTokenMissing);
        }
      } else {
        final decoded = jsonDecode(response.body);
        final message = decoded is Map ? decoded['message']?.toString() : null;
        _showError(
          message ?? loc.authGoogleFailed(response.statusCode),
        );
      }
    } catch (e) {
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
      await _handleSocialRegisterSuccess(result.token);
    } on AppleAuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(loc.authAppleError(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isAppleLoading = false;
        });
      }
    }
  }

  static const _ink = Color(0xFF172B4D);
  static const _muted = Color(0xFF64748B);
  static const _blue = Color(0xFF2575FC);
  bool _hidePassword = true;
  bool get _busy => _isLoading || _isGoogleLoading || _isAppleLoading;

  Widget _field(TextEditingController controller, String label, IconData icon,
      {bool password = false,
      bool email = false,
      bool last = false,
      Iterable<String>? autofillHints}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 9),
          child: Text(label,
              style: const TextStyle(
                  color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        TextField(
          controller: controller,
          enabled: !_busy,
          obscureText: password && _hidePassword,
          keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
          textInputAction: last ? TextInputAction.done : TextInputAction.next,
          autofillHints: autofillHints,
          autocorrect: !email && !password,
          enableSuggestions: !email && !password,
          onSubmitted: last
              ? (_) {
                  if (!_busy) _register();
                }
              : null,
          style: const TextStyle(color: _ink, fontSize: 15),
          cursorColor: _blue,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _muted, size: 20),
            suffixIcon: password
                ? IconButton(
                    tooltip: _hidePassword
                        ? loc.loginShowPassword
                        : loc.loginHidePassword,
                    onPressed: _busy
                        ? null
                        : () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _muted,
                        size: 20),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF7F9FC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5EAF1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _blue, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
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
                      IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: _ink)),
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
                                      borderRadius: BorderRadius.circular(4)),
                                ))),
                    const SizedBox(height: 18),
                    Text(loc.registerTitle,
                        style: const TextStyle(
                            color: _ink,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                            letterSpacing: -1.3)),
                    const SizedBox(height: 30),
                    AutofillGroup(
                        child: Column(children: [
                      _field(_nameController, loc.customersName,
                          Icons.person_outline_rounded,
                          autofillHints: const [AutofillHints.name]),
                      _field(_emailController, loc.emailLabel,
                          Icons.mail_outline_rounded,
                          email: true,
                          autofillHints: const [AutofillHints.email]),
                      _field(_passwordController, loc.passwordLabel,
                          Icons.lock_outline_rounded,
                          password: true,
                          autofillHints: const [AutofillHints.newPassword]),
                      _field(
                          _passwordConfirmController,
                          loc.registerConfirmPassword,
                          Icons.lock_outline_rounded,
                          password: true),
                      _field(_usernameController, loc.registerUsername,
                          Icons.alternate_email,
                          last: true,
                          autofillHints: const [AutofillHints.newUsername]),
                    ])),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Semantics(
                            liveRegion: true,
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: Color(0xFFC94036), height: 1.5))),
                      ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _register,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(loc.registerSubmit,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                        )),
                    const SizedBox(height: 25),
                    Row(children: [
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(loc.loginOr,
                              style: const TextStyle(
                                  color: _muted, fontSize: 13))),
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
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
                              side: const BorderSide(color: Color(0xFFDFE5ED)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isGoogleLoading
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : Image.asset('assets/google_icon.png',
                                        width: 21, height: 21),
                                const SizedBox(width: 12),
                                Flexible(
                                    child: Text(
                                        _isGoogleLoading
                                            ? loc.googleConnecting
                                            : loc.googleLogin,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600))),
                              ]),
                        )),
                    if (_isAppleAvailable ||
                        kIsWeb ||
                        defaultTargetPlatform == TargetPlatform.android) ...[
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
                                  borderRadius: BorderRadius.circular(16)))),
                    ],
                    const SizedBox(height: 25),
                    Center(
                        child: TextButton(
                      onPressed:
                          _busy ? null : () => Navigator.of(context).maybePop(),
                      child: Text(loc.onboardLogin,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: _blue,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    )),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
