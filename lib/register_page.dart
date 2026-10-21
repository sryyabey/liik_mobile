import 'package:bagla_mobile/l10n/app_localizations.dart';
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
  final String _deviceName = 'bagla_mobile';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId: googleWebServerClientId,
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
      if (account == null) {
        _showError(loc.authGoogleCancelled);
        return;
      }
      final auth = await account.authentication;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0A84FF),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.registerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: loc.customersName,
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: loc.emailLabel,
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: loc.passwordLabel,
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordConfirmController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: loc.registerConfirmPassword,
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: loc.registerUsername,
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.alternate_email,
                        color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.yellowAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            loc.registerSubmit,
                            style: const TextStyle(
                              color: Color(0xFF2575FC),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGoogleLoading ? null : _loginWithGoogle,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                            ),
                          )
                        : Image.asset(
                            'assets/google_icon.png',
                            height: 24,
                            width: 24,
                          ),
                    label: Text(
                      _isGoogleLoading
                          ? loc.googleConnecting
                          : loc.googleLogin,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_isAppleAvailable ||
                    kIsWeb ||
                    defaultTargetPlatform == TargetPlatform.android) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SignInWithAppleButton(
                      onPressed: () {
                        if (_isAppleLoading) return;
                        _loginWithApple();
                      },
                      style: SignInWithAppleButtonStyle.black,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    loc.onboardLogin,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
