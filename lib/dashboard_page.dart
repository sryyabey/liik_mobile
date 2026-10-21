import 'widgets/studio_page.dart';
import 'pages/analytics.dart';
import 'user_timezone.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'main.dart' show BaglaAppState;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bagla_mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config.dart';
import 'login_page.dart';
import 'auth.dart';
import 'pages/themes.dart';
import 'pages/my_links.dart';
import 'pages/customers.dart';
import 'pages/profile.dart';
import 'pages/support.dart';
import 'pages/working_preferences.dart';
import 'pages/appointments.dart';
import 'pages/calendar.dart';
import 'pages/ai_profile_page.dart';
import 'pages/announcements_page.dart';
import 'pages/blog_page.dart';
import 'widgets/main_nav.dart';
import 'package:in_app_review/in_app_review.dart';

class DashboardPage extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onTabSelected;

  const DashboardPage({
    super.key,
    this.showBottomNav = true,
    this.onTabSelected,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const int _maxDashboardTopLinks = 8;
  static const int _maxDashboardAppointments = 6;
  bool _loading = true;
  String? _error;
  bool _hasDashboardLoaded = false;
  bool _noInternet = false;
  String _totalClicks = '0';
  String? _bioPageLink;
  Map<String, dynamic>? _dailyClicks;
  List<_DashboardTopLink> _topLinks = const [];
  int _todayAppointmentCount = 0;
  List<_DashboardAppointment> _todayAppointments = const [];
  bool _hasAiProfileContent = false; // true → AI banner gizlenir
  int _unreadAnnouncementCount = 0;
  bool _showRatingCard = false;

  @override
  void initState() {
    super.initState();
    UserTimeZone.changes.addListener(_onTimezoneChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchDashboard();
      await _checkRatingPrompt();
    });
  }

  void _onTimezoneChanged() {
    if (mounted && !_loading && UserTimeZone.name != null)
      _fetchDashboard(force: true);
  }

  @override
  void dispose() {
    UserTimeZone.changes.removeListener(_onTimezoneChanged);
    super.dispose();
  }

  Future<void> _checkRatingPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    final firstOpen = prefs.getString('first_open_date');
    if (firstOpen == null) {
      await prefs.setString(
          'first_open_date', DateTime.now().toIso8601String());
      return;
    }

    final firstDate = DateTime.tryParse(firstOpen);
    if (firstDate == null) return;

    if (DateTime.now().difference(firstDate).inDays < 3) return;

    if (prefs.getBool('rating_declined') == true) return;

    final lastAsked = prefs.getString('rating_last_asked');
    if (lastAsked != null) {
      final lastDate = DateTime.tryParse(lastAsked);
      if (lastDate != null && DateTime.now().difference(lastDate).inDays < 30) {
        return;
      }
    }

    if (mounted) setState(() => _showRatingCard = true);
  }

  Future<void> _declineReview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rating_declined', true);
    setState(() => _showRatingCard = false);
  }

  void _openRatingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RatingModal(
        onSubmit: (stars, comment) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'rating_last_asked', DateTime.now().toIso8601String());
          if (mounted) setState(() => _showRatingCard = false);

          // 4+ yıldızda native store rating'i aç
          if (stars >= 4) {
            final inAppReview = InAppReview.instance;
            if (await inAppReview.isAvailable()) {
              await inAppReview.requestReview();
            } else {
              await inAppReview.openStoreListing(appStoreId: appleAppStoreId);
            }
          }
        },
        onDecline: _declineReview,
      ),
    );
  }

  Future<String?> _getToken() async {
    return getAccessToken();
  }

  Future<void> _fetchDashboard({bool force = false}) async {
    final loc = AppLocalizations.of(context);
    if (_hasDashboardLoaded && !force) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _noInternet = false;
    });

    String? nextError;
    bool nextNoInternet = false;
    Map<String, dynamic>? nextParsedData;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      nextError = loc.dashboardSessionMissing;
    } else {
      try {
        final response = await authGet(
          Uri.parse('$apiBaseUrl/api/dashboard'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final data = decoded['data'] ?? decoded;
          if (data is Map && data['timezone'] is String)
            await UserTimeZone.set(data['timezone']);
          if (data is Map<String, dynamic>) {
            nextParsedData = data;
          } else if (data is Map) {
            nextParsedData = Map<String, dynamic>.from(data);
          } else {
            nextError = loc.dashboardLoadFailed('Invalid payload');
          }
        } else {
          String message =
              loc.dashboardLoadFailedWithStatus(response.statusCode.toString());
          try {
            final decoded = jsonDecode(response.body);
            message = decoded['message']?.toString() ?? message;
          } catch (_) {}
          nextError = message;
        }
      } catch (e) {
        nextNoInternet = e is SocketException ||
            e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup');
        nextError = nextNoInternet
            ? loc.dashboardNoInternet
            : loc.dashboardLoadFailed(e.toString());
      }
    }

    if (!mounted) return;
    setState(() {
      if (nextParsedData != null) {
        _applyDashboardData(nextParsedData);
        _hasDashboardLoaded = true;
      }
      _error = nextError;
      _noInternet = nextNoInternet;
      _loading = false;
    });
  }

  void _applyDashboardData(Map<String, dynamic> data) {
    _totalClicks = data['total_clicks']?.toString() ?? '0';
    final shortBioPage = data['short_bio_page']?.toString().trim();
    final bioPage = data['bio_page']?.toString().trim();
    _bioPageLink = shortBioPage != null && shortBioPage.isNotEmpty
        ? shortBioPage
        : bioPage;
    final profileDesc = data['profile_description']?.toString() ?? '';
    _hasAiProfileContent = profileDesc.isNotEmpty;
    _unreadAnnouncementCount =
        (data['unread_announcements_count'] as int? ?? 0);
    _dailyClicks = data['daily_clicks'] is Map<String, dynamic>
        ? data['daily_clicks'] as Map<String, dynamic>
        : (data['daily_clicks'] is Map
            ? Map<String, dynamic>.from(data['daily_clicks'] as Map)
            : null);

    final rawTopLinks = data['top_links'] as List?;
    final parsedTopLinks = <_DashboardTopLink>[];
    if (rawTopLinks != null) {
      for (final item in rawTopLinks) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final rawClicks = map['clicks'];
        final clicks = rawClicks is num
            ? rawClicks.toDouble()
            : double.tryParse(rawClicks?.toString() ?? '') ?? 0;
        final title = map['title']?.toString().trim() ?? '';
        parsedTopLinks.add(
          _DashboardTopLink(
            title: title.isNotEmpty ? title : '-',
            clicks: clicks,
          ),
        );
      }
    }
    _topLinks =
        parsedTopLinks.take(_maxDashboardTopLinks).toList(growable: false);

    final apptInfo = data['appointment_info'] as Map?;
    final todayCountRaw =
        apptInfo?['todayAppointments'] ?? apptInfo?['today_appointments'] ?? 0;
    _todayAppointmentCount = int.tryParse(todayCountRaw.toString()) ?? 0;
    final parsedAppointments = <_DashboardAppointment>[];
    final apptList = apptInfo?['appointments'] as List?;
    if (apptList != null) {
      for (final item in apptList) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final customer = map['customer'] is Map
            ? Map<String, dynamic>.from(map['customer'] as Map)
            : null;
        final status = map['appointment_status'] is Map
            ? Map<String, dynamic>.from(map['appointment_status'] as Map)
            : null;
        final customerName = customer?['name']?.toString().trim();
        parsedAppointments.add(
          _DashboardAppointment(
            customerId: map['customer_id']?.toString() ?? '',
            customerName:
                (customerName?.isNotEmpty == true) ? customerName! : null,
            phone: customer?['phone']?.toString() ?? '',
            date: map['date']?.toString(),
            time: map['time']?.toString(),
            statusName: status?['name']?.toString() ??
                status?['alias']?.toString() ??
                '',
          ),
        );
      }
    }
    _todayAppointments = parsedAppointments
        .take(_maxDashboardAppointments)
        .toList(growable: false);
  }

  void _navigateToPage(Widget page, String routeName) {
    // Keep the dashboard in place when opening a detail page.
    if (widget.onTabSelected != null) {
      if (page is DashboardPage) {
        widget.onTabSelected!(0);
        return;
      }
      if (page is AppointmentsPage) {
        widget.onTabSelected!(1);
        return;
      }
      if (page is CalendarPage) {
        widget.onTabSelected!(2);
        return;
      }
      if (page is CustomersPage) {
        widget.onTabSelected!(3);
        return;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: routeName),
      ),
    );
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

  Future<void> _downloadQr(BuildContext sourceContext, String link) async {
    final loc = AppLocalizations.of(context);
    final origin = _shareOrigin(sourceContext);
    try {
      final painter = QrPainter(
        data: link,
        version: QrVersions.auto,
        gapless: true,
      );
      final imageData =
          await painter.toImageData(600, format: ui.ImageByteFormat.png);
      final bytes = imageData?.buffer.asUint8List();
      if (bytes == null) throw loc.dashboardImageFailed;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/liik_qr.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: loc.dashboardShareBio,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      _showSnack(loc.dashboardQrDownloadFailed(e.toString()));
    }
  }

  Future<void> _openBioLink(String link) async {
    final loc = AppLocalizations.of(context);
    final trimmed = link.trim();
    if (trimmed.isEmpty) return;
    Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) {
      _showSnack(loc.dashboardLinkOpenFailed);
      return;
    }
    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$trimmed');
    }
    if (uri == null) {
      _showSnack(loc.dashboardLinkOpenFailed);
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showSnack(loc.dashboardLinkOpenFailed);
      }
    } catch (_) {
      _showSnack(loc.dashboardLinkOpenFailed);
    }
  }

  Rect _shareOrigin(BuildContext sourceContext) {
    final box = sourceContext.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final overlayBox = Overlay.of(context).context.findRenderObject();
    if (overlayBox is RenderBox && overlayBox.hasSize) {
      return overlayBox.localToGlobal(Offset.zero) & overlayBox.size;
    }
    return const Rect.fromLTWH(0, 0, 1, 1);
  }

  Future<void> _shareBioSystem(BuildContext sourceContext, String link) async {
    final loc = AppLocalizations.of(context);
    try {
      final origin = _shareOrigin(sourceContext);
      await Share.share(
        link,
        subject: loc.dashboardShareBio,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      _showSnack(loc.dashboardShareFailed(e.toString()));
    }
  }

  void _showQrModal(String link) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                loc.dashboardQrTitle,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              QrImageView(
                data: link,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                link,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final navigator = Navigator.of(ctx);
                        await _shareBioSystem(ctx, link);
                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                      },
                      icon: const Icon(Icons.share),
                      label: Text(loc.dashboardShare),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final navigator = Navigator.of(ctx);
                        await _downloadQr(ctx, link);
                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                      },
                      icon: const Icon(Icons.download),
                      label: Text(loc.dashboardDownload),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openTabOrPush(int tabIndex, Widget page) {
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(tabIndex);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _tabPageForIndex(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const AppointmentsPage();
      case 2:
        return const CalendarPage();
      case 3:
      default:
        return const CustomersPage();
    }
  }

  void _navigateFromDrawer({
    int? tabIndex,
    Widget? page,
    String? routeName,
  }) {
    Navigator.pop(context); // close drawer first

    if (tabIndex != null) {
      if (widget.onTabSelected != null) {
        widget.onTabSelected!(tabIndex);
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _tabPageForIndex(tabIndex),
          settings: routeName != null ? RouteSettings(name: routeName) : null,
        ),
      );
      return;
    }

    if (page == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
        settings: routeName != null ? RouteSettings(name: routeName) : null,
      ),
    );
  }

  static const _ink = Color(0xFF0C2032);
  static const _blue = Color(0xFF0866EB);
  static const _teal = Color(0xFF00BFAE);
  static const _muted = Color(0xFF627183);

  Widget _heroSection(String totalClicks) {
    final loc = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString())
              .format(DateTime.now()),
          style: const TextStyle(
              color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text(loc.dashboardWelcome,
          style: const TextStyle(
              color: _ink,
              fontSize: 30,
              height: 1.15,
              letterSpacing: -1,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(loc.dashboardHeroSubtitle,
          style: const TextStyle(color: _muted, fontSize: 14, height: 1.5)),
      const SizedBox(height: 22),
      LayoutBuilder(builder: (_, constraints) {
        final narrow = MediaQuery.textScalerOf(context).scale(14) > 21;
        final cards = [
          _statCard(loc.dashboardTopClicks, totalClicks,
              Icons.touch_app_outlined, _blue),
          _statCard(loc.dashboardTodayAppointments, '$_todayAppointmentCount',
              Icons.event_available_outlined, _teal),
        ];
        return narrow
            ? Column(children: [cards[0], const SizedBox(height: 10), cards[1]])
            : Row(children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1])
              ]);
      }),
      const SizedBox(height: 20),
      _buildHeroBioSection(loc),
    ]);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EDF3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 21, color: color)),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(
                  color: _ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.1)),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.4)),
        ]),
      );

  Widget _buildHeroBioSection(AppLocalizations loc) {
    final link = _bioPageLink;
    final hasLink = link != null && link.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.link_rounded,
                  color: Colors.white, size: 22)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(loc.dashboardBioPage,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15))),
          IconButton(
              onPressed: () =>
                  _navigateToPage(const AiProfilePage(), 'ai_profile'),
              tooltip: loc.aiProfileTabProfile,
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white70, size: 20)),
        ]),
        const SizedBox(height: 16),
        if (hasLink) ...[
          InkWell(
              onTap: () => _openBioLink(link),
              child: Text(link.replaceFirst(RegExp(r'^https?://'), ''),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(height: 8),
          Text(loc.dashboardBioHint,
              style: const TextStyle(
                  color: Color(0xFFB8C7D7), fontSize: 13, height: 1.5)),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _bioAction(Icons.copy_outlined, loc.dashboardCopyLink, () async {
              await Clipboard.setData(ClipboardData(text: link));
              _showSnack(loc.dashboardLinkCopied, success: true);
            }),
            Builder(
                builder: (ctx) => _bioAction(Icons.ios_share_rounded,
                    loc.dashboardShare, () => _shareBioSystem(ctx, link))),
            _bioAction(Icons.qr_code_rounded, loc.dashboardQr,
                () => _showQrModal(link)),
          ]),
        ] else ...[
          Text(loc.dashboardBioEmptyTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(loc.dashboardBioEmptyHint,
              style: const TextStyle(
                  color: Color(0xFFB8C7D7), fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          _bioAction(Icons.add_rounded, loc.aiProfileBannerTitle,
              () => _navigateToPage(const AiProfilePage(), 'ai_profile')),
        ],
      ]),
    );
  }

  Widget _bioAction(IconData icon, String label, VoidCallback onPressed) =>
      TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: .09),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      );

  Widget _buildDailyClicks(Map<String, dynamic>? dailyClicks) {
    final loc = AppLocalizations.of(context);
    final labels =
        (dailyClicks?['labels'] as List?)?.map((e) => e.toString()).toList() ??
            [];
    final datasets = dailyClicks?['datasets'] as List?;
    final firstDataset = datasets != null && datasets.isNotEmpty
        ? datasets.first as Map<String, dynamic>?
        : null;
    final values =
        (firstDataset?['data'] as List?)?.map((e) => e ?? 0).toList() ?? [];

    if (labels.isEmpty || values.isEmpty) {
      return Text(loc.dashboardNoClicks);
    }

    final limitedLabels = labels.take(6).toList();
    final limitedValues = List<double>.generate(
      limitedLabels.length,
      (index) {
        final raw = index < values.length ? values[index] : 0;
        if (raw is num) return raw.toDouble();
        return double.tryParse(raw.toString()) ?? 0;
      },
    );
    final maxValue = limitedValues.isEmpty
        ? 1.0
        : limitedValues
            .reduce((a, b) => a > b ? a : b)
            .clamp(1.0, double.infinity);

    return Column(
      children: List.generate(limitedLabels.length, (index) {
        final label = limitedLabels[index];
        final value = limitedValues[index];
        final ratio = (value / maxValue).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: ratio,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF0866EB)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopLinks(List<_DashboardTopLink> topLinks) {
    final loc = AppLocalizations.of(context);
    if (topLinks.isEmpty) {
      return Text(loc.dashboardNoLinkClicks);
    }
    final maxClicks = topLinks.isEmpty
        ? 1.0
        : topLinks
            .map((e) => e.clicks)
            .reduce((a, b) => a > b ? a : b)
            .clamp(1.0, double.infinity);

    return Column(
      children: List.generate(topLinks.length, (index) {
        final link = topLinks[index];
        final value = link.clicks;
        final ratio = (value / maxClicks).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      link.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: ratio,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _fmtDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final d = DateTime.parse(date);
      return DateFormat.yMMMd(Localizations.localeOf(context).toString())
          .format(d);
    } catch (_) {
      return date;
    }
  }

  String _fmtTime(String? time) {
    if (time == null) return '-';
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return time;
  }

  Widget _buildTodayAppointments(BuildContext context,
      {required int todayCount,
      required List<_DashboardAppointment> appointments}) {
    final loc = AppLocalizations.of(context);
    if (appointments.isEmpty) {
      return Column(children: [
        Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
                color: Color(0xFFEAF9F6), shape: BoxShape.circle),
            child: const Icon(Icons.event_available_outlined,
                color: Color(0xFF008577), size: 30)),
        const SizedBox(height: 14),
        Text(
            todayCount == 0
                ? loc.dashboardNoAppointments
                : loc.dashboardNoAppointmentsData,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _ink, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Text(loc.dashboardScheduleEmptyHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.5)),
        const SizedBox(height: 14),
        TextButton.icon(
            onPressed: _openQuickAppointment,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(loc.quickAppointment)),
      ]);
    }
    return Column(children: [
      for (final appt in appointments)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 66,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(_fmtTime(appt.time),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      appt.customerName ??
                          loc.dashboardCustomerFallback(appt.customerId),
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_fmtDate(appt.date),
                      style: const TextStyle(color: _muted, fontSize: 12)),
                  if (appt.phone.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(appt.phone,
                            style:
                                const TextStyle(color: _muted, fontSize: 12))),
                  if (appt.statusName.isNotEmpty)
                    Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE4F5EF),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(appt.statusName,
                            style: const TextStyle(
                                color: Color(0xFF14765A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600))),
                ])),
          ]),
        ),
      Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
              onPressed: () => _openTabOrPush(1, const AppointmentsPage()),
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: Text(loc.dashboardViewAppointments))),
    ]);
  }

  Widget _buildSectionCard(
          {required IconData icon,
          required String title,
          required Widget child}) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8EDF3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: _blue, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)))
          ]),
          const SizedBox(height: 18),
          child,
        ]),
      );

  Widget _buildAiProfileBanner() {
    final loc = AppLocalizations.of(context);
    return Material(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToPage(const AiProfilePage(), 'ai_profile'),
          child: Padding(
              padding: const EdgeInsets.all(18),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.auto_awesome_rounded, color: _blue, size: 25),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(loc.aiProfileBannerTitle,
                          style: const TextStyle(
                              color: _ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(loc.aiProfileBannerDesc,
                          style: const TextStyle(
                              color: _muted, fontSize: 12, height: 1.5)),
                    ])),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: _blue, size: 18),
              ])),
        ));
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('⭐', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).dashboardReviewTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppLocalizations.of(context).dashboardReviewHint,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton(
                onPressed: _openRatingModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(AppLocalizations.of(context).dashboardReviewAction,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: _declineReview,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9CA3AF),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(AppLocalizations.of(context).appointmentsClose,
                    style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementBanner() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
        );
        // Geri dönünce sayacı sıfırla (okudular)
        if (mounted) setState(() => _unreadAnnouncementCount = 0);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0866EB), Color(0xFF00A69A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)
                    .dashboardAnnouncements(_unreadAnnouncementCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(AppLocalizations.of(context).commonView,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final loc = AppLocalizations.of(context);
    final actions =
        <({IconData icon, String label, Color color, VoidCallback onTap})>[
      (
        icon: Icons.link_rounded,
        label: loc.myLinks,
        color: _blue,
        onTap: () => _navigateToPage(const MyLinksPage(), 'my_links')
      ),
      (
        icon: Icons.palette_outlined,
        label: loc.themes,
        color: const Color(0xFFD65247),
        onTap: () => _navigateToPage(const ThemesPage(), 'themes')
      ),
      (
        icon: Icons.schedule_rounded,
        label: loc.dashboardWorkingHours,
        color: const Color(0xFF008577),
        onTap: () => _navigateToPage(
            const WorkingPreferencesPage(), 'working_preferences')
      ),
      (
        icon: Icons.person_outline_rounded,
        label: loc.profileTitle,
        color: const Color(0xFFA76B00),
        onTap: () => _navigateToPage(const ProfilePage(), 'profile')
      ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.dashboardQuickActions,
          style: const TextStyle(
              color: _ink, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 13),
      LayoutBuilder(builder: (_, constraints) {
        final single = MediaQuery.textScalerOf(context).scale(14) > 21;
        final width =
            single ? constraints.maxWidth : (constraints.maxWidth - 12) / 2;
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions
                .map((action) => SizedBox(
                    width: width,
                    child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Color(0xFFE8EDF3))),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: action.onTap,
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(children: [
                                Icon(action.icon,
                                    color: action.color, size: 21),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(action.label,
                                        style: const TextStyle(
                                            color: _ink,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600))),
                              ]))),
                    )))
                .toList());
      }),
    ]);
  }

  Future<void> _openQuickAppointment() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const AppointmentsPage(autoShowQuick: true),
    ));
    if (mounted) await _fetchDashboard(force: true);
  }

  Widget _buildDashboardBody() {
    final loc = AppLocalizations.of(context);
    return RefreshIndicator(
      color: _blue,
      onRefresh: () => _fetchDashboard(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _heroSection(_totalClicks),
          const SizedBox(height: 22),
          SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openQuickAppointment,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(loc.quickAppointment, textAlign: TextAlign.center),
                style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 17, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              )),
          const SizedBox(height: 22),
          if (_unreadAnnouncementCount > 0) ...[
            _buildAnnouncementBanner(),
            const SizedBox(height: 20)
          ],
          _buildSectionCard(
              icon: Icons.event_available_outlined,
              title: loc.dashboardTodayAppointments,
              child: _buildTodayAppointments(context,
                  todayCount: _todayAppointmentCount,
                  appointments: _todayAppointments)),
          const SizedBox(height: 22),
          _buildQuickActions(),
          const SizedBox(height: 22),
          if (!_hasAiProfileContent) ...[
            _buildAiProfileBanner(),
            const SizedBox(height: 22)
          ],
          _buildSectionCard(
              icon: Icons.bar_chart_rounded,
              title: loc.dashboardDailyClicks,
              child: _buildDailyClicks(_dailyClicks)),
          const SizedBox(height: 16),
          _buildSectionCard(
              icon: Icons.link_rounded,
              title: loc.dashboardTopLinks,
              child: Column(children: [
                _buildTopLinks(_topLinks),
                if (_topLinks.isNotEmpty)
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                          onPressed: () =>
                              _navigateToPage(const MyLinksPage(), 'my_links'),
                          icon:
                              const Icon(Icons.arrow_forward_rounded, size: 17),
                          label: Text(loc.myLinks))),
              ])),
          const SizedBox(height: 22),
          const BlogHighlightsStrip(),
          if (_showRatingCard) ...[
            const SizedBox(height: 20),
            _buildRatingCard()
          ],
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: _muted, size: 21),
        title: Text(label,
            style: const TextStyle(
                color: _ink, fontSize: 14, fontWeight: FontWeight.w500)),
        onTap: onTap,
      );

  Future<void> _logout() async {
    final appState = context.findAncestorStateOfType<BaglaAppState>();
    await clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    try {
      final google = GoogleSignIn(
          scopes: const ['email'], serverClientId: googleWebServerClientId);
      await google.signOut();
      await google.disconnect();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => LoginPage(
                onLocaleChange: (locale) => appState?.setLocale(locale))),
        (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: StudioPageStyle.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StudioPageStyle.background,
        foregroundColor: _ink,
        title: Image.asset('assets/liik-logo-2.png',
            width: 100, height: 53, fit: BoxFit.contain, semanticLabel: 'Liik'),
        actions: [
          IconButton(
              tooltip: loc.announcementsTitle,
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AnnouncementsPage()));
                if (mounted) setState(() => _unreadAnnouncementCount = 0);
              },
              icon: Badge(
                  isLabelVisible: _unreadAnnouncementCount > 0,
                  backgroundColor: const Color(0xFFFF6055),
                  child: const Icon(Icons.notifications_none_rounded))),
          IconButton(
              tooltip: loc.profile,
              onPressed: () => _navigateToPage(const ProfilePage(), 'profile'),
              icon: const Icon(Icons.account_circle_outlined)),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
              child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/liik-logo-2.png',
                              width: 148,
                              height: 74,
                              fit: BoxFit.contain,
                              semanticLabel: 'Liik'),
                          const SizedBox(height: 14),
                          Text(loc.dashboardDrawerSubtitle,
                              style: const TextStyle(
                                  color: _muted, fontSize: 13, height: 1.5)),
                        ])),
                _drawerItem(
                    Icons.home_outlined,
                    loc.dashboardHome,
                    () => _navigateFromDrawer(
                        tabIndex: 0, routeName: 'dashboard')),
                _drawerItem(
                    Icons.event_note_outlined,
                    loc.dashboardAppointments,
                    () => _navigateFromDrawer(
                        tabIndex: 1, routeName: 'appointments')),
                _drawerItem(
                    Icons.calendar_today_outlined,
                    loc.dashboardCalendar,
                    () => _navigateFromDrawer(
                        tabIndex: 2, routeName: 'calendar')),
                _drawerItem(
                    Icons.groups_outlined,
                    loc.customersTitle,
                    () => _navigateFromDrawer(
                        tabIndex: 3, routeName: 'customers')),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: Color(0xFFE8EDF3))),
                _drawerItem(
                    Icons.link_rounded,
                    loc.myLinks,
                    () => _navigateFromDrawer(
                        page: const MyLinksPage(), routeName: 'my_links')),
                _drawerItem(
                    Icons.insights_rounded,
                    loc.analyticsTitle,
                    () => _navigateFromDrawer(
                        page: const AnalyticsPage(), routeName: 'analytics')),
                _drawerItem(
                    Icons.palette_outlined,
                    loc.themes,
                    () => _navigateFromDrawer(
                        page: const ThemesPage(), routeName: 'themes')),
                _drawerItem(
                    Icons.auto_awesome_outlined,
                    loc.aiProfileTitle,
                    () => _navigateFromDrawer(
                        page: const AiProfilePage(), routeName: 'ai_profile')),
                _drawerItem(
                    Icons.schedule_outlined,
                    loc.dashboardWorkingHours,
                    () => _navigateFromDrawer(
                        page: const WorkingPreferencesPage(),
                        routeName: 'working_preferences')),
                _drawerItem(
                    Icons.person_outline,
                    loc.profile,
                    () => _navigateFromDrawer(
                        page: const ProfilePage(), routeName: 'profile')),
                _drawerItem(
                    Icons.menu_book_outlined,
                    loc.blogTitle,
                    () => _navigateFromDrawer(
                        page: const BlogPage(), routeName: 'blog')),
                _drawerItem(
                    Icons.support_agent_outlined,
                    loc.support,
                    () => _navigateFromDrawer(
                        page: const SupportPage(), routeName: 'support')),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: Color(0xFFE8EDF3))),
                _drawerItem(Icons.logout_rounded, loc.exit, _logout),
              ]))),
      body: StudioPageBackground(
          child: SafeArea(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _blue))
                  : _error != null
                      ? Center(
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        _noInternet
                                            ? Icons.wifi_off_rounded
                                            : Icons.cloud_off_outlined,
                                        size: 48,
                                        color: _muted),
                                    const SizedBox(height: 16),
                                    Text(_error!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: _muted,
                                            fontSize: 14,
                                            height: 1.5)),
                                    const SizedBox(height: 20),
                                    FilledButton.icon(
                                        onPressed: () =>
                                            _fetchDashboard(force: true),
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: Text(loc.dashboardRetry),
                                        style: FilledButton.styleFrom(
                                            backgroundColor: _ink)),
                                  ])))
                      : _buildDashboardBody())),
      bottomNavigationBar: widget.showBottomNav
          ? MainNavBar(currentIndex: 0, onIndexSelected: widget.onTabSelected)
          : null,
    );
  }
}

class _DashboardTopLink {
  const _DashboardTopLink({
    required this.title,
    required this.clicks,
  });

  final String title;
  final double clicks;
}

class _DashboardAppointment {
  const _DashboardAppointment({
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.date,
    required this.time,
    required this.statusName,
  });

  final String customerId;
  final String? customerName;
  final String phone;
  final String? date;
  final String? time;
  final String statusName;
}

// ── Rating Modal ──────────────────────────────────────────────────────────────

class _RatingModal extends StatefulWidget {
  final Future<void> Function(int stars, String comment) onSubmit;
  final VoidCallback onDecline;

  const _RatingModal({required this.onSubmit, required this.onDecline});

  @override
  State<_RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<_RatingModal> {
  int _selectedStars = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedStars == 0) return;
    setState(() => _submitting = true);
    await widget.onSubmit(_selectedStars, _commentCtrl.text.trim());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Emoji + başlık
          const Text('😊', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).dashboardFeedbackTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).dashboardFeedbackHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // Yıldızlar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _selectedStars;
              return GestureDetector(
                onTap: () => setState(() => _selectedStars = i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: filled
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Yıldız etiketi
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _starLabel(_selectedStars),
              key: ValueKey(_selectedStars),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _selectedStars > 0
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Yorum alanı
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).dashboardFeedbackComment,
              hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF6366F1), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
              counterStyle:
                  const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ),
          const SizedBox(height: 20),

          // Butonlar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedStars > 0 && !_submitting) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppLocalizations.of(context).dashboardFeedbackSubmit,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              widget.onDecline();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9CA3AF),
            ),
            child: Text(AppLocalizations.of(context).commonNotNow,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1:
        return AppLocalizations.of(context).ratingVeryBad;
      case 2:
        return AppLocalizations.of(context).ratingBad;
      case 3:
        return AppLocalizations.of(context).ratingAverage;
      case 4:
        return AppLocalizations.of(context).ratingGood;
      case 5:
        return AppLocalizations.of(context).ratingExcellent;
      default:
        return AppLocalizations.of(context).ratingSelect;
    }
  }
}
