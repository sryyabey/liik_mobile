import 'dart:convert';
import 'package:liik_mobile/widgets/theme_tier_badge.dart';

import 'package:liik_mobile/auth.dart';
import 'package:liik_mobile/config.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';
import 'package:liik_mobile/main_tabs_page.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  AppLocalizations get loc => AppLocalizations.of(context);
  List<Map<String, dynamic>> _themes = [];
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;
  int? _selectedThemeId;
  int? _savedThemeId;
  int _previewVersion = 0;
  int _loadVersion = 0;
  final _previewAnchor = GlobalKey();
  final _themeScroll = ScrollController();
  double get _themeCardWidth =>
      MediaQuery.textScalerOf(context).scale(15) > 21 ? 180 : 160;

  @override
  void dispose() {
    _themeScroll.dispose();
    super.dispose();
  }

  String? _selectedThemeName;
  int? _userId;
  WebViewController? _previewController;
  bool _previewLoading = false;
  String? _previewUrl;
  String? _previewError;

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainTabsPage(initialIndex: 0),
      ),
      (_) => false,
    );
  }

  void _goBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    _goHome();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchThemesAndProfile();
    });
  }

  Future<String?> _getToken() async {
    return getAccessToken();
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _findThemeIdByName(String? name) {
    if (name == null) return null;
    for (final theme in _themes) {
      final themeName =
          theme['name']?.toString() ?? theme['title']?.toString() ?? '';
      if (themeName == name) {
        return _parseInt(theme['id']);
      }
    }
    return null;
  }

  String? _resolveThemeNameById(int? id) {
    if (id == null) return null;
    final match = _themes.firstWhere(
      (theme) => _parseInt(theme['id']) == id,
      orElse: () => {},
    );
    if (match.isEmpty) return null;
    return match['name']?.toString() ??
        match['title']?.toString() ??
        match['slug']?.toString();
  }

  Future<void> _fetchThemesAndProfile() async {
    if (_saving || !mounted) return;
    final version = ++_loadVersion;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final token = await _getToken();
    if (!mounted || version != _loadVersion) return;
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = loc.themesSessionMissing;
        _loading = false;
      });
      return;
    }

    try {
      final responses = await Future.wait([
        authGet(
          Uri.parse('$apiBaseUrl/api/settings/themes'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        authGet(
          Uri.parse('$apiBaseUrl/api/user/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      ]);

      if (!mounted || version != _loadVersion) return;
      final themesResponse = responses[0];
      final profileResponse = responses[1];

      if (themesResponse.statusCode == 401 ||
          profileResponse.statusCode == 401) {
        if (!mounted) return;
        setState(() {
          _errorMessage = loc.themesSessionExpired;
          _loading = false;
        });
        return;
      }

      if (themesResponse.statusCode != 200 ||
          profileResponse.statusCode != 200) {
        throw const FormatException();
      }
      List<Map<String, dynamic>> fetchedThemes = [];
      String? selectedThemeNameFromThemes;
      if (themesResponse.statusCode == 200) {
        final decoded = jsonDecode(themesResponse.body);
        final data = decoded is Map<String, dynamic>
            ? decoded['data'] ?? decoded['themes'] ?? decoded['results']
            : decoded;
        if (decoded is Map<String, dynamic>) {
          selectedThemeNameFromThemes = (decoded['selected_theme_name'] ??
                  (decoded['meta'] is Map
                      ? decoded['meta']['selected_theme_name']
                      : null))
              ?.toString();
        }
        if (data is List) {
          fetchedThemes = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          fetchedThemes = [data];
        }
      }

      int? userId;
      int? currentThemeId;
      String? currentThemeName;
      if (profileResponse.statusCode == 200) {
        final decoded = jsonDecode(profileResponse.body);
        final data = decoded['data'] ?? decoded;
        userId = _parseInt(data['id'] ?? data['user_id']);
        currentThemeId =
            _parseInt(data['theme_id'] ?? data['selected_theme_id']);
        currentThemeName = (data['theme'] is Map
                ? data['theme']['name']?.toString()
                : data['theme']?.toString()) ??
            data['theme_name']?.toString() ??
            data['selected_theme']?.toString();
      }

      if (!mounted) return;
      setState(() {
        _themes = fetchedThemes;
        _userId = userId;
        final currentName = currentThemeName ?? selectedThemeNameFromThemes;
        final currentId = currentThemeId ?? _findThemeIdByName(currentName);
        _savedThemeId =
            fetchedThemes.any((theme) => _parseInt(theme['id']) == currentId)
                ? currentId
                : null;
        _selectedThemeId = _savedThemeId ??
            (fetchedThemes.isNotEmpty
                ? _parseInt(fetchedThemes.first['id'])
                : null);
        _selectedThemeName = _resolveThemeNameById(_selectedThemeId);
        _loading = false;
      });

      _updatePreview();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_themeScroll.hasClients) return;
        final index = _themes
            .indexWhere((theme) => _parseInt(theme['id']) == _selectedThemeId);
        if (index >= 0)
          _themeScroll.jumpTo((index * (_themeCardWidth + 12))
              .clamp(0.0, _themeScroll.position.maxScrollExtent));
      });
    } catch (e) {
      if (!mounted || version != _loadVersion) return;
      setState(() {
        _errorMessage = loc.themesLoadError;
        _loading = false;
      });
    }
  }

  String? _buildPreviewUrl() {
    if (_userId == null || _selectedThemeId == null) {
      return null;
    }

    final uri = Uri.parse('$apiBaseUrl/bio-pages/preview/$_userId').replace(
      queryParameters: {
        'theme': _selectedThemeId!.toString(),
      },
    );
    return uri.toString();
  }

  Future<void> _updatePreview() async {
    final version = ++_previewVersion;
    final url = _buildPreviewUrl();
    if (!mounted) return;
    setState(() {
      _previewUrl = url;
      _previewController = null;
      _previewError = null;
      _previewLoading = url != null;
    });
    if (url == null) return;
    bool current() => mounted && version == _previewVersion;
    void fail() {
      if (current()) {
        setState(() {
          _previewLoading = false;
          _previewError = loc.themesPreviewError;
        });
      }
    }

    final previewLanguage = Localizations.localeOf(context).toLanguageTag();
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.white);
      await controller.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (!request.isMainFrame) return NavigationDecision.navigate;
          final target = Uri.tryParse(request.url), initial = Uri.parse(url);
          return target != null &&
                  (target.scheme == 'http' || target.scheme == 'https') &&
                  target.origin == initial.origin &&
                  target.path == initial.path
              ? NavigationDecision.navigate
              : NavigationDecision.prevent;
        },
        onPageStarted: (_) {
          if (current()) setState(() => _previewLoading = true);
        },
        onPageFinished: (_) {
          if (current()) setState(() => _previewLoading = false);
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame != false) fail();
        },
        onHttpError: (error) {
          if (error.request == null || error.request!.uri == Uri.parse(url)) {
            fail();
          }
        },
      ));
      if (!current()) return;
      setState(() => _previewController = controller);
      await controller.loadRequest(Uri.parse(url), headers: {
        'Accept-Language': previewLanguage,
      });
    } catch (_) {
      fail();
    }
  }

  Future<void> _saveTheme() async {
    if (_saving || _selectedThemeId == _savedThemeId) return;
    final themeId = _selectedThemeId;
    final token = await _getToken();
    if (!mounted) return;

    if (themeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.themesSelectTheme),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.themesSessionMissing),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final response = await authPost(
        Uri.parse('$apiBaseUrl/api/settings/user-theme'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'theme_id': themeId}),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _savedThemeId = themeId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.themesSaveSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String message = loc.themesSaveFailedStatus(response.statusCode);
        try {
          final decoded = jsonDecode(response.body);
          message = decoded['message']?.toString() ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.themesSaveErrorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _onThemeTap(Map<String, dynamic> theme) {
    if (_saving) return;
    final id = _parseInt(theme['id']);
    if (id == null || id == _selectedThemeId) return;
    final name = theme['name']?.toString() ??
        theme['title']?.toString() ??
        theme['slug']?.toString();
    setState(() {
      _selectedThemeId = id;
      _selectedThemeName = name;
    });
    _updatePreview();
  }

  String _themeName(Map<String, dynamic> theme) {
    final name =
        (theme['name'] ?? theme['title'] ?? theme['slug'])?.toString().trim() ??
            '';
    if (name == 'bagla') return loc.themesClassic;
    return name.isEmpty
        ? loc.themesFallbackName
        : name[0].toUpperCase() + name.substring(1);
  }

  String? _imageUrl(Map<String, dynamic> theme) {
    final image = theme['image']?.toString().trim();
    if (image == null || image.isEmpty) return null;
    final uri = Uri.tryParse(image);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return image;
    }
    final path = image.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse(apiBaseUrl)
        .resolve(path.startsWith('storage/') ? '/$path' : '/storage/$path')
        .toString();
  }

  Widget _themeCard(Map<String, dynamic> theme) {
    final id = _parseInt(theme['id']);
    final selected = id != null && id == _selectedThemeId;
    final active = id != null && id == _savedThemeId;
    final image = _imageUrl(theme);
    Widget fallback() => const ColoredBox(
        color: Color(0xFFF1F5FA),
        child: Center(
            child: Icon(Icons.palette_outlined,
                color: Color(0xFF8CA1B8), size: 36)));
    return Semantics(
        selected: selected,
        button: true,
        label: _themeName(theme),
        child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: selected
                        ? const Color(0xFF0866EB)
                        : const Color(0xFFE5EAF1),
                    width: selected ? 2 : 1)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                key: ValueKey('theme-$id'),
                onTap: _saving || id == null ? null : () => _onThemeTap(theme),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Stack(fit: StackFit.expand, children: [
                            image == null
                                ? fallback()
                                : Image.network(image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => fallback()),
                            PositionedDirectional(
                                top: 8,
                                start: 8,
                                child: ThemeTierBadge(
                                    isPremium: isPremiumTheme(theme))),
                          ])),
                      Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(_themeName(theme),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Color(0xFF0C2032),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700)),
                                      if (active) ...[
                                        const SizedBox(height: 4),
                                        Text(loc.themesCurrent,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Color(0xFF008577),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600))
                                      ]
                                    ])),
                                const SizedBox(width: 8),
                                Icon(
                                    selected
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: selected
                                        ? const Color(0xFF0866EB)
                                        : const Color(0xFFCBD5E1),
                                    size: 22)
                              ])),
                    ]))));
  }

  Widget _previewMessage(String message, {bool retry = false}) => Center(
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(retry ? Icons.cloud_off_outlined : Icons.phone_iphone_rounded,
                color: const Color(0xFF8CA1B8), size: 34),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF627183), height: 1.5)),
            if (retry) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                  onPressed: _updatePreview,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(loc.themesRetry))
            ]
          ])));
  Widget _buildPreview() => Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE5EAF1), width: 6)),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                  aspectRatio: 9 / 19.5,
                  child: Stack(children: [
                    if (_previewController != null)
                      Positioned.fill(
                          child: WebViewWidget(
                              key: ValueKey(_previewController),
                              controller: _previewController!)),
                    if (_previewUrl == null)
                      Positioned.fill(
                          child: _previewMessage(loc.themesPreviewPlaceholder)),
                    if (_previewLoading)
                      const Positioned.fill(
                          child: ColoredBox(
                              color: Colors.white,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF0866EB))))),
                    if (_previewError != null)
                      Positioned.fill(
                          child: ColoredBox(
                              color: Colors.white,
                              child: _previewMessage(_previewError!,
                                  retry: true))),
                  ])))));

  Widget _stateMessage(String message, {bool retry = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(children: [
        Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(20)),
            child: Icon(
                retry ? Icons.cloud_off_outlined : Icons.palette_outlined,
                color: const Color(0xFF0866EB),
                size: 34)),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF627183), height: 1.5)),
        if (retry) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
              onPressed: _fetchThemesAndProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(loc.themesRetry))
        ]
      ]));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFAFBFD),
        appBar: AppBar(
            backgroundColor: const Color(0xFFFAFBFD),
            foregroundColor: const Color(0xFF0C2032),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_rounded)),
            title: Text(loc.themesTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                  onPressed:
                      _loading || _saving ? null : _fetchThemesAndProfile,
                  tooltip: loc.themesRefreshTooltip,
                  icon: const Icon(Icons.refresh_rounded))
            ]),
        body: SafeArea(
            child: RefreshIndicator(
                onRefresh: _fetchThemesAndProfile,
                color: const Color(0xFF0866EB),
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.themesTitle,
                              style: const TextStyle(
                                  color: Color(0xFF0C2032),
                                  fontSize: 30,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1)),
                          const SizedBox(height: 9),
                          Text(loc.themesSubtitle,
                              style: const TextStyle(
                                  color: Color(0xFF627183),
                                  fontSize: 14,
                                  height: 1.5)),
                          const SizedBox(height: 24),
                          if (_loading)
                            const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF0866EB))))
                          else if (_errorMessage != null)
                            _stateMessage(_errorMessage!, retry: true)
                          else if (_themes.isEmpty)
                            _stateMessage(loc.themesNoThemes, retry: true)
                          else ...[
                            SizedBox(
                              height: _themeCardWidth * .75 +
                                  40 +
                                  MediaQuery.textScalerOf(context).scale(15) *
                                      1.4 +
                                  MediaQuery.textScalerOf(context).scale(12) *
                                      1.4,
                              child: ListView.separated(
                                key: const PageStorageKey('theme-carousel'),
                                controller: _themeScroll,
                                scrollDirection: Axis.horizontal,
                                itemCount: _themes.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (_, index) => SizedBox(
                                    width: _themeCardWidth,
                                    child: _themeCard(_themes[index])),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(key: _previewAnchor, children: [
                              Expanded(
                                  child: Text(loc.themesLivePreview,
                                      style: const TextStyle(
                                          color: Color(0xFF0C2032),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700))),
                              IconButton(
                                  onPressed: _previewUrl == null
                                      ? null
                                      : _updatePreview,
                                  tooltip: loc.themesRefreshPreview,
                                  icon: const Icon(Icons.refresh_rounded,
                                      color: Color(0xFF627183)))
                            ]),
                            if (_selectedThemeName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                  _selectedThemeName == 'bagla'
                                      ? loc.themesClassic
                                      : _selectedThemeName!,
                                  style: const TextStyle(
                                      color: Color(0xFF627183), fontSize: 13))
                            ],
                            const SizedBox(height: 16),
                            _buildPreview(),
                          ],
                        ])))),
        bottomNavigationBar: _loading ||
                _errorMessage != null ||
                _themes.isEmpty
            ? null
            : SafeArea(
                top: false,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        border:
                            Border(top: BorderSide(color: Color(0xFFE5EAF1)))),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(
                                    _selectedThemeId == _savedThemeId
                                        ? loc.themesCurrent
                                        : loc.themesUnsaved,
                                    style: TextStyle(
                                        color: _selectedThemeId == _savedThemeId
                                            ? const Color(0xFF008577)
                                            : const Color(0xFF627183),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600))),
                            IconButton(
                                tooltip: loc.themesViewPreview,
                                onPressed: () {
                                  final anchor = _previewAnchor.currentContext;
                                  if (anchor != null) {
                                    Scrollable.ensureVisible(anchor,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic);
                                  }
                                },
                                icon: const Icon(Icons.visibility_outlined,
                                    color: Color(0xFF0866EB))),
                          ]),
                          const SizedBox(height: 10),
                          SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                  onPressed: _saving ||
                                          _selectedThemeId == null ||
                                          _selectedThemeId == _savedThemeId
                                      ? null
                                      : _saveTheme,
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : Icon(
                                          _selectedThemeId == _savedThemeId
                                              ? Icons
                                                  .check_circle_outline_rounded
                                              : Icons.check_rounded,
                                          size: 20),
                                  label: Text(_saving
                                      ? loc.themesSaving
                                      : _selectedThemeId == _savedThemeId
                                          ? loc.themesApplied
                                          : loc.themesSaveButton),
                                  style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF0866EB),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14))))),
                        ]))),
      );
}
