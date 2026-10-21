import '../widgets/studio_page.dart';
import '../user_timezone.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bagla_mobile/config.dart';
import '../auth.dart';
import '../widgets/main_nav.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import '../main.dart';
import '../app_locale.dart';
import '../login_page.dart';
import '../dashboard_page.dart';

class ProfilePage extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onTabSelected;

  const ProfilePage({
    super.key,
    this.showBottomNav = true,
    this.onTabSelected,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppLocalizations get loc => AppLocalizations.of(context);
  // Form controller'ları: profil & SEO
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  final TextEditingController _seoTitleController = TextEditingController();
  final TextEditingController _seoDescriptionController =
      TextEditingController();
  final TextEditingController _seoKeywordsController = TextEditingController();

  // Form controller'ları: parola
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _profileSavedRecently = false;
  bool _passwordSavedRecently = false;
  bool _deletingAccount = false;

  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _savingPassword = false;
  String _timezone = 'UTC';
  String? _avatarUrl;
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  Map<String, dynamic>? _packInfo;
  static const Color _backgroundColor = StudioPageStyle.background;
  static const Color _primaryColor = Color(0xFF0866EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    _footerController.dispose();
    _seoTitleController.dispose();
    _seoDescriptionController.dispose();
    _seoKeywordsController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    return getAccessToken();
  }

  // Profil verisini API'den çekip formu doldurur
  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
    });

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      _showSnack(loc.profileSessionMissing);
      setState(() {
        _loadingProfile = false;
      });
      return;
    }

    try {
      final response = await authGet(
        Uri.parse('$apiBaseUrl/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] ?? decoded;

        if (!mounted) return;
        final timezone = data['timezone']?.toString() ?? 'UTC';
        await UserTimeZone.set(timezone);
        if (!mounted) return;
        setState(() {
          _timezone = timezone;
          _nameController.text = data['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _footerController.text = data['footer'] ?? '';
          final seo = data['seo'] as Map<String, dynamic>?;
          _seoTitleController.text = seo?['title'] ?? '';
          _seoDescriptionController.text = seo?['description'] ?? '';
          _seoKeywordsController.text = seo?['keywords'] ?? '';
          _avatarUrl = data['avatar']?.toString();
          _packInfo = data['pack_info'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['pack_info'])
              : null;
        });
      } else {
        _showSnack(loc.profileFetchFailedStatus(response.statusCode));
      }
    } catch (e) {
      _showSnack(loc.profileFetchFailed(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  // Avatar seçer ve bytes'ı hazırlar (ham halde gönderiyoruz)
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    try {
      Uint8List bytes;
      String fileName;

      if (kIsWeb) {
        bytes = await picked.readAsBytes();
        final ext = picked.name.split('.').last.toLowerCase();
        fileName = picked.name.isNotEmpty
            ? picked.name
            : 'avatar.${ext.isNotEmpty ? ext : 'jpg'}';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final originalBytes = await picked.readAsBytes();
        final decoded = img.decodeImage(originalBytes);
        if (decoded == null) {
          _showSnack(loc.profileAvatarInvalidFormat);
          return;
        }
        final size =
            decoded.width < decoded.height ? decoded.width : decoded.height;
        final offsetX = ((decoded.width - size) / 2).round();
        final offsetY = ((decoded.height - size) / 2).round();
        final cropped = img.copyCrop(
          decoded,
          x: offsetX,
          y: offsetY,
          width: size,
          height: size,
        );
        bytes = Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
        fileName = 'avatar.jpg';
      } else {
        final cropped = await ImageCropper().cropImage(
          sourcePath: picked.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              lockAspectRatio: true,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (cropped == null) return;

        bytes = await cropped.readAsBytes();
        fileName = cropped.path.split('/').last;
      }

      const maxSize = 3 * 1024 * 1024; // 3MB
      if (bytes.lengthInBytes > maxSize) {
        _showSnack(loc.profileAvatarTooLarge);
        return;
      }

      setState(() {
        _avatarBytes = null;
      });
      setState(() {
        _avatarBytes = bytes;
        _avatarFileName = fileName;
      });
    } catch (e) {
      _showSnack(loc.profileAvatarPrepareFailed(e.toString()));
    }
  }

  // Profil bilgilerini ve avatarı multipart POST ile gönderir
  Future<void> _saveProfile() async {
    if (_savingProfile) return;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      _showSnack(loc.profileSessionMissing);
      return;
    }

    setState(() {
      _savingProfile = true;
    });

    try {
      final response = await authMultipart((authToken) async {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$apiBaseUrl/api/user/profile'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        });

        request.fields.addAll({
          'name': _nameController.text,
          'username': _usernameController.text,
          'description': _descriptionController.text,
          'footer': _footerController.text,
          'timezone': _timezone,
          'seo_title': _seoTitleController.text,
          'seo_description': _seoDescriptionController.text,
          'seo_keywords': _seoKeywordsController.text,
        });

        if (_avatarBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'avatar',
              _avatarBytes!,
              filename: _avatarFileName ?? 'avatar.jpg',
            ),
          );
        }
        return request;
      });

      if (response.statusCode == 200) {
        await UserTimeZone.set(_timezone);
        if (!mounted) return;
        _showSnack(loc.profileSaved, success: true);
        _avatarBytes = null;
        setState(() {
          _profileSavedRecently = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _profileSavedRecently = false;
            });
          }
        });
        await _loadProfile();
      } else {
        String message = loc.profileUpdateFailedGeneric;
        try {
          final body = jsonDecode(response.body);
          message = body['message']?.toString() ?? message;
        } catch (_) {}
        _showSnack('$message (${response.statusCode})');
      }
    } catch (e) {
      _showSnack(loc.profileUpdateFailed(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _savingProfile = false;
        });
      }
    }
  }

  // Parola güncelleme isteği
  Future<void> _changePassword() async {
    if (_savingPassword) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack(loc.profilePasswordMismatch);
      return;
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      _showSnack(loc.profileSessionMissing);
      return;
    }

    setState(() {
      _savingPassword = true;
    });

    try {
      final response = await authPost(
        Uri.parse('$apiBaseUrl/api/user/password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'current_password': _currentPasswordController.text,
          'password': _newPasswordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSnack(loc.profilePasswordUpdated, success: true);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _passwordSavedRecently = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _passwordSavedRecently = false;
            });
          }
        });
      } else {
        String message = loc.profilePasswordUpdateFailed;
        try {
          final decoded = jsonDecode(response.body);
          message = decoded['message']?.toString() ?? message;
        } catch (_) {}
        _showSnack('$message (${response.statusCode})');
      }
    } catch (e) {
      _showSnack(loc.profilePasswordUpdateFailedWithError(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _savingPassword = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_deletingAccount) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.profileDeleteConfirmTitle),
        content: Text(
          loc.profileDeleteConfirmBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.profileDeleteCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.profileDeleteAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      _showSnack(loc.profileSessionMissing);
      return;
    }

    setState(() {
      _deletingAccount = true;
    });

    try {
      final response = await authDelete(
        Uri.parse('$apiBaseUrl/api/trash-users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showSnack(loc.profileDeleteSuccess, success: true);
        await clearTokens();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('authToken');
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                onLocaleChange: (locale) {},
              ),
            ),
            (route) => false,
          );
        }
      } else {
        String message = loc.profileDeleteFailed;
        try {
          final decoded = jsonDecode(response.body);
          message = decoded['message']?.toString() ?? message;
        } catch (_) {}
        _showSnack('$message (${response.statusCode})');
      }
    } catch (e) {
      _showSnack(loc.profileDeleteError(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _deletingAccount = false;
        });
      }
    }
  }

  void _showSnack(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
    String? title,
    String? subtitle,
    IconData icon = Icons.person_outline_rounded,
    bool collapsible = false,
    bool danger = false,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    final accent = danger ? const Color(0xFFB84444) : _primaryColor;
    final heading = Row(children: [
      Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: accent.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: accent, size: 19)),
      const SizedBox(width: 12),
      Expanded(
          child: Text(title ?? '',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: danger ? accent : const Color(0xFF0C2032)))),
    ]);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  danger ? const Color(0xFFF1DCDC) : StudioPageStyle.border)),
      child: collapsible
          ? ExpansionTile(
              key: PageStorageKey(title),
              maintainState: true,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              childrenPadding: padding,
              shape: const Border(),
              collapsedShape: const Border(),
              title: heading,
              subtitle: subtitle == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: StudioPageStyle.secondary))),
              children: [child],
            )
          : Padding(
              padding: padding,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[heading, const SizedBox(height: 16)],
                    if (subtitle != null) ...[
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: StudioPageStyle.secondary)),
                      const SizedBox(height: 16)
                    ],
                    child,
                  ])),
    );
  }

  Widget _buildAvatar() {
    final fallback = Container(
        color: const Color(0xFFEAF1FF),
        alignment: Alignment.center,
        child: Text(
            _nameController.text.trim().isEmpty
                ? 'L'
                : _nameController.text.trim().characters.first.toUpperCase(),
            style: const TextStyle(
                fontSize: 32,
                color: _primaryColor,
                fontWeight: FontWeight.w800)));
    final Widget avatar = _avatarBytes != null
        ? Image.memory(_avatarBytes!, fit: BoxFit.cover)
        : (_avatarUrl?.isNotEmpty ?? false)
            ? Image.network(_avatarUrl!,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback)
            : fallback;
    return SizedBox(
        width: 88,
        height: 88,
        child: Stack(children: [
          Positioned.fill(
              child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFD9E6FA))),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(24), child: avatar))),
          Positioned(
              right: 0,
              bottom: 0,
              child: IconButton.filled(
                  tooltip: loc.profileAvatarUpload,
                  onPressed: _savingProfile ? null : _pickAvatar,
                  style: IconButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(44, 44)),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18))),
        ]));
  }

  Widget _buildHeader() {
    final details =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          _nameController.text.isEmpty
              ? loc.profileNameMissing
              : _nameController.text,
          style: const TextStyle(
              fontSize: 23,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
              color: StudioPageStyle.ink)),
      const SizedBox(height: 6),
      Text(
          _usernameController.text.isEmpty
              ? loc.profileUsernamePlaceholder
              : '@${_usernameController.text}',
          style: const TextStyle(
              fontSize: 13, color: _primaryColor, fontWeight: FontWeight.w600)),
      if (_packInfo?['active_pack'] != null ||
          _packInfo?['expiry_date'] != null) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (_packInfo?['active_pack'] != null)
            _infoChip(Icons.workspace_premium_outlined,
                _packInfo!['active_pack'].toString()),
          if (_packInfo?['expiry_date'] != null)
            _infoChip(
                Icons.schedule_outlined, _packInfo!['expiry_date'].toString()),
        ]),
      ],
    ]);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFEAF1FF), Color(0xFFF2FBFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFDCE7F5))),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(14) > 20) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildAvatar(), const SizedBox(height: 16), details]);
        }
        return Row(children: [
          _buildAvatar(),
          const SizedBox(width: 18),
          Expanded(child: details)
        ]);
      }),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: _primaryColor),
      label: Text(text),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _primaryColor.withValues(alpha: 0.2)),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      labelStyle:
          const TextStyle(color: StudioPageStyle.secondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: StudioPageStyle.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: StudioPageStyle.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 1.2),
      ),
    );
  }

  Widget _timezoneSelector() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
            key: const ValueKey('profile-timezone'),
            onTap: _savingProfile ? null : _pickTimezone,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
                decoration: _inputDecoration(loc.profileTimezone).copyWith(
                    prefixIcon: const Icon(Icons.public_outlined),
                    suffixIcon: const Icon(Icons.expand_more_rounded)),
                child: Text(_timezone.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 14)))),
        const SizedBox(height: 8),
        Text(loc.profileTimezoneHint,
            style: const TextStyle(
                color: Color(0xFF627183), fontSize: 12, height: 1.5)),
      ]);

  Future<void> _pickTimezone() async {
    List<Map<String, dynamic>> zones = [];
    String query = '';
    bool loading = true;
    bool started = false;
    String? error;
    Future<void> fetch(StateSetter update, BuildContext sheet) async {
      update(() {
        loading = true;
        error = null;
      });
      try {
        final response = await authGet(
            Uri.parse('$apiBaseUrl/api/settings/timezones'),
            headers: {'Accept': 'application/json'});
        if (response.statusCode != 200) throw Exception();
        final body = jsonDecode(response.body);
        zones = (body['data'] as List)
            .map((zone) => Map<String, dynamic>.from(zone as Map))
            .toList();
        if (zones.isEmpty) throw Exception();
      } catch (_) {
        error = loc.profileTimezoneLoadError;
      }
      if (sheet.mounted) update(() => loading = false);
    }

    final selected = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: StudioPageStyle.background,
        builder: (ctx) => FractionallySizedBox(
            heightFactor: .9,
            child: StatefulBuilder(builder: (ctx, update) {
              if (!started) {
                started = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (ctx.mounted) fetch(update, ctx);
                });
              }
              final filtered = zones
                  .where((zone) =>
                      ('${zone['id'].toString().replaceAll('_', ' ')} ${zone['utc_offset']}')
                          .toLowerCase()
                          .contains(query.toLowerCase().trim()))
                  .toList();
              return Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 16, 20, MediaQuery.viewInsetsOf(ctx).bottom + 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(loc.profileTimezone,
                                  style: const TextStyle(
                                      color: Color(0xFF0C2032),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700))),
                          IconButton(
                              tooltip: loc.appointmentsClose,
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: const Icon(Icons.close_rounded))
                        ]),
                        const SizedBox(height: 12),
                        TextField(
                            key: const ValueKey('timezone-search'),
                            onChanged: (value) => update(() => query = value),
                            decoration:
                                _inputDecoration(loc.profileTimezoneSearch)
                                    .copyWith(
                                        prefixIcon:
                                            const Icon(Icons.search_rounded))),
                        const SizedBox(height: 16),
                        Expanded(
                            child: loading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : error != null
                                    ? SingleChildScrollView(
                                        child: Column(children: [
                                        Text(error!),
                                        const SizedBox(height: 12),
                                        OutlinedButton.icon(
                                            onPressed: () => fetch(update, ctx),
                                            icon: const Icon(Icons.refresh),
                                            label: Text(loc.customersRetry))
                                      ]))
                                    : filtered.isEmpty
                                        ? Center(
                                            child: Text(loc.myLinksNoResults))
                                        : ListView.separated(
                                            itemCount: filtered.length,
                                            separatorBuilder: (_, __) =>
                                                const Divider(
                                                    height: 1,
                                                    color: Color(0xFFE5EAF1)),
                                            itemBuilder: (_, index) {
                                              final zone = filtered[index];
                                              final id = zone['id'].toString();
                                              return ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: Text(zone['label']
                                                          ?.toString() ??
                                                      id.replaceAll('_', ' ')),
                                                  subtitle: Text(
                                                      'UTC${zone['utc_offset'] ?? ''}'),
                                                  trailing: id == _timezone
                                                      ? const Icon(
                                                          Icons
                                                              .check_circle_rounded,
                                                          color:
                                                              Color(0xFF0866EB))
                                                      : null,
                                                  onTap: () => Navigator.of(ctx)
                                                      .pop(id));
                                            })),
                      ]));
            })));
    if (selected != null && mounted) {
      setState(() {
        _timezone = selected;
        _profileSavedRecently = false;
      });
    }
  }

  Widget _buildProfileForm() {
    return _sectionCard(
      title: loc.profileInfoTitle,
      icon: Icons.badge_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: _inputDecoration(loc.profileFieldName),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usernameController,
            decoration: _inputDecoration(loc.profileFieldUsername),
          ),
          const SizedBox(height: 12),
          _timezoneSelector(),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: _inputDecoration(loc.profileFieldDescription),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _footerController,
            decoration: _inputDecoration(loc.profileFieldFooter),
          ),
        ],
      ),
    );
  }

  Widget _buildSeoForm() {
    return _sectionCard(
      title: loc.profileSeoSectionTitle,
      icon: Icons.travel_explore_rounded,
      collapsible: true,
      subtitle: loc.profileSeoSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _seoTitleController,
            decoration: _inputDecoration(loc.profileSeoTitleLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _seoDescriptionController,
            maxLines: 2,
            decoration: _inputDecoration(loc.profileSeoDescriptionLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _seoKeywordsController,
            decoration: _inputDecoration(loc.profileSeoKeywordsLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return _sectionCard(
      title: loc.profilePasswordSectionTitle,
      icon: Icons.lock_outline_rounded,
      collapsible: true,
      subtitle:
          _passwordSavedRecently ? loc.profilePasswordUpdatedSubtitle : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: _inputDecoration(loc.profileCurrentPassword),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: _inputDecoration(loc.profileNewPassword),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: _inputDecoration(loc.profileConfirmPassword),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _savingPassword ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _savingPassword
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_reset),
                  label: Text(_savingPassword
                      ? loc.profileChangePasswordSaving
                      : loc.profileChangePasswordButton),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _passwordSavedRecently
                    ? const Icon(Icons.check_circle,
                        key: ValueKey('password_saved'),
                        color: Colors.green,
                        size: 28)
                    : const SizedBox(
                        key: ValueKey('password_unsaved'),
                        width: 28,
                        height: 28,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountSection() {
    return _sectionCard(
      title: loc.profileDeleteSectionTitle,
      icon: Icons.manage_accounts_outlined,
      collapsible: true,
      danger: true,
      subtitle: loc.profileDeleteSectionSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: _deletingAccount ? null : _deleteAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _deletingAccount
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_forever),
            label: Text(
              _deletingAccount
                  ? loc.profileDeleteProcessing
                  : loc.profileDeleteAction,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _backgroundColor,
        foregroundColor: StudioPageStyle.ink,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(children: [
          Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_outline_rounded,
                  size: 18, color: _primaryColor)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(loc.profileTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700))),
        ]),
        actions: [
          IconButton(
            tooltip: loc.dashboardHome,
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StudioPageBackground(
          child: _loadingProfile
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_profileSavedRecently)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    loc.profileSaved,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        StudioPageIntro(loc.profileDesignIntro),
                        _buildHeader(),
                        const SizedBox(height: 12),
                        _buildProfileForm(),
                        const SizedBox(height: 12),
                        _buildSeoForm(),
                        const SizedBox(height: 12),
                        _sectionCard(
                            title: loc.profileLanguage,
                            icon: Icons.language_rounded,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: LiikLanguagePicker(onChanged: (locale) {
                                  context
                                      .findAncestorStateOfType<BaglaAppState>()
                                      ?.setLocale(locale);
                                }))),
                        const SizedBox(height: 12),
                        _buildPasswordForm(),
                        const SizedBox(height: 12),
                        _buildDeleteAccountSection(),
                      ],
                    ),
                  ),
                )),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!_loadingProfile)
          Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: StudioPageStyle.border))),
              child: SafeArea(
                  top: false,
                  bottom: !widget.showBottomNav,
                  minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _savingProfile ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        icon: _savingProfile
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Icon(
                                _profileSavedRecently
                                    ? Icons.check_circle_outline
                                    : Icons.save_outlined,
                                size: 20),
                        label: Text(
                            _savingProfile ? loc.profileSaving : loc.save,
                            textAlign: TextAlign.center),
                      )))),
        if (widget.showBottomNav)
          MainNavBar(
              currentIndex: 3,
              onIndexSelected: widget.onTabSelected,
              allowReselectCurrent: true),
      ]),
    );
  }
}
