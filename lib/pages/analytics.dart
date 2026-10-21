import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../auth.dart';
import '../config.dart';
import '../main_tabs_page.dart';
import '../l10n/app_localizations.dart';

const _blue = Color(0xFF0866EB),
    _ink = Color(0xFF0C2032),
    _muted = Color(0xFF627183);

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _period = 7, _version = 0;
  String _tab = 'overview';
  Map<String, dynamic>? _data;
  bool _loading = true, _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final version = ++_version;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final response = await authGet(
          Uri.parse('$apiBaseUrl/api/analytics')
              .replace(queryParameters: {'period': '$_period', 'tab': _tab}),
          headers: {'Accept': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception();
      }
      final data =
          Map<String, dynamic>.from(jsonDecode(response.body)['data'] as Map);
      if (!mounted || version != _version) {
        return;
      }
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || version != _version) {
        return;
      }
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const MainTabsPage(initialIndex: 0)));
    }
  }

  AppLocalizations get loc => AppLocalizations.of(context);
  String get locale => Localizations.localeOf(context).toString();
  String number(dynamic value, {bool percent = false}) => value == null
      ? '—'
      : '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: percent ? 1 : 0).format(value)}${percent ? '%' : ''}';
  String date(dynamic value) =>
      DateFormat.yMMMd(locale).format(DateTime.parse(value.toString()));
  Widget panel(String title, List<Widget> children, {String? hint}) =>
      Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5EAF1))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
            if (hint != null)
              Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(hint,
                      style: const TextStyle(color: _muted, height: 1.5))),
            const SizedBox(height: 16),
            ...children
          ]));

  Widget metric(String title, dynamic value, dynamic change,
          {bool percent = false}) =>
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5EAF1))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: _muted)),
            const SizedBox(height: 8),
            Text(number(value, percent: percent),
                style: const TextStyle(
                    fontSize: 27, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 5),
            Text(
                change == null
                    ? loc.analyticsNoPrevious
                    : change == 0
                        ? loc.analyticsUnchanged
                        : '${change > 0 ? '+' : ''}${number(change, percent: true)} · ${loc.analyticsPrevious}',
                style: TextStyle(
                    fontSize: 12,
                    color: change == null || change == 0
                        ? _muted
                        : change > 0
                            ? const Color(0xFF008577)
                            : const Color(0xFFB04D35)))
          ]));

  Widget distribution(String title, List items, String Function(Map) label,
      {String valueKey = 'total'}) {
    final total = items.fold<double>(
        0, (sum, item) => sum + ((item[valueKey] as num?)?.toDouble() ?? 0));
    return panel(
        title,
        items.isEmpty
            ? [Text(loc.analyticsEmpty, style: const TextStyle(color: _muted))]
            : items.map<Widget>((raw) {
                final item = raw as Map;
                final value = (item[valueKey] as num?)?.toDouble() ?? 0;
                return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(label(item),
                                    style: const TextStyle(color: _ink))),
                            const SizedBox(width: 10),
                            Text(number(value))
                          ]),
                      const SizedBox(height: 7),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                              value:
                                  total == 0 ? 0 : (value / total).clamp(0, 1),
                              color: _blue,
                              backgroundColor: const Color(0xFFEDF3FE),
                              minHeight: 5))
                    ]));
              }).toList());
  }

  String dimension(Map item) => switch (item['name']) {
        'unknown' => loc.analyticsUnknown,
        'mobile' => loc.analyticsMobile,
        'desktop' => loc.analyticsDesktop,
        'tablet' => loc.analyticsTablet,
        _ => item['name'].toString().replaceAll('_', ' '),
      };

  Widget chart() {
    final days = _data!['daily'] as List;
    final peak = days.fold<double>(
        1, (value, day) => math.max(value, (day['clicks'] as num).toDouble()));
    return panel(
        loc.analyticsTrend,
        [
          Wrap(spacing: 18, runSpacing: 8, children: [
            Text('● ${loc.analyticsClicks}',
                style: const TextStyle(color: _blue)),
            Text('● ${loc.analyticsUniqueClicks}',
                style: const TextStyle(color: Color(0xFF00A895)))
          ]),
          const SizedBox(height: 18),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: days
                      .map<Widget>((day) => Tooltip(
                          message:
                              '${date(day['date'])}\n${loc.analyticsClicks}: ${number(day['clicks'])}\n${loc.analyticsUniqueClicks}: ${number(day['unique_clicks'])}',
                          triggerMode: TooltipTriggerMode.tap,
                          child: SizedBox(
                              width: 45,
                              child: Column(children: [
                                SizedBox(
                                    height: 125,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                              width: 12,
                                              height: 125 *
                                                  (day['clicks'] as num) /
                                                  peak,
                                              decoration: BoxDecoration(
                                                  color: _blue,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          const SizedBox(width: 3),
                                          Container(
                                              width: 8,
                                              height: 125 *
                                                  (day['unique_clicks']
                                                      as num) /
                                                  peak,
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF00A895),
                                                  borderRadius:
                                                      BorderRadius.circular(4)))
                                        ])),
                                const SizedBox(height: 10),
                                Text(
                                    DateFormat.Md(locale)
                                        .format(DateTime.parse(day['date'])),
                                    style: const TextStyle(
                                        fontSize: 10, color: _muted))
                              ]))))
                      .toList()))
        ],
        hint: loc.analyticsTrendHint);
  }

  List<Widget> report() {
    final d = _data!,
        summary = d['summary'] as Map,
        changes = d['changes'] as Map;
    final links = d['top_links'] as List;
    final metrics = [
      metric(loc.analyticsVisitors, summary['unique_views'],
          changes['unique_views']),
      metric(loc.analyticsClicks, summary['total_clicks'],
          changes['total_clicks']),
      metric(loc.analyticsUniqueClicks, summary['unique_clicks'],
          changes['unique_clicks']),
      metric(loc.analyticsRate, summary['conversion_rate'],
          changes['conversion_rate'],
          percent: true)
    ];
    return [
      Text('${date(d['from'])} – ${date(d['to'])}',
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(loc.analyticsTimezone(d['timezone']),
          style: const TextStyle(color: _muted, fontSize: 12)),
      const SizedBox(height: 18),
      LayoutBuilder(builder: (context, constraints) {
        final columns = MediaQuery.textScalerOf(context).scale(14) > 20 ||
                constraints.maxWidth < 330
            ? 1
            : 2;
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: metrics
                .map((m) => SizedBox(
                    width:
                        (constraints.maxWidth - (columns - 1) * 12) / columns,
                    child: m))
                .toList());
      }),
      const SizedBox(height: 20),
      if (summary['total_clicks'] == 0 && summary['unique_views'] == 0)
        panel(loc.analyticsEmpty, [
          Text(loc.analyticsEmptyText, style: const TextStyle(color: _muted))
        ]),
      if (_tab == 'overview') chart(),
      if (_tab == 'overview' || _tab == 'links')
        panel(
            loc.analyticsTopLinks,
            links.isEmpty
                ? [Text(loc.analyticsNoLinks)]
                : links.asMap().entries.map<Widget>((entry) {
                    final link = entry.value as Map;
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  radius: 15,
                                  backgroundColor: const Color(0xFFEDF3FE),
                                  child: Text('${entry.key + 1}',
                                      style: const TextStyle(
                                          fontSize: 12, color: _blue))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        (link['title'] as String?)
                                                    ?.isNotEmpty ==
                                                true
                                            ? link['title']
                                            : loc.analyticsLink,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    Text(link['url'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: _muted, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Text(
                                        '${loc.analyticsUniqueClicks}: ${number(link['unique_clicks'])} · CTR ${number(link['ctr'], percent: true)}',
                                        style: const TextStyle(
                                            fontSize: 12, color: _muted))
                                  ])),
                              const SizedBox(width: 8),
                              Text(number(link['clicks']),
                                  style: const TextStyle(
                                      color: _blue,
                                      fontWeight: FontWeight.w800))
                            ]));
                  }).toList()),
      if (_tab == 'audience' && d['audience'] is Map)
        ...audience(Map<String, dynamic>.from(d['audience'])),
      if (_tab == 'conversions') ...[
        panel(
            loc.analyticsFunnel,
            [
              metric(loc.analyticsVisitors, summary['unique_views'], null),
              const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.south_rounded, color: _blue)),
              metric(loc.analyticsUniqueClicks, summary['unique_clicks'], null),
              const SizedBox(height: 12),
              Text(loc.analyticsRateNote, style: const TextStyle(color: _muted))
            ],
            hint: loc.analyticsFunnelHint),
        panel(
            loc.analyticsNavigation,
            [
              for (final entry in [
                (loc.analyticsManual, d['navigation']['manual']),
                (loc.analyticsAutomatic, d['navigation']['automatic']),
                (loc.analyticsUnknown, d['navigation']['unknown']),
                (loc.analyticsRedirects, summary['redirect_views'])
              ])
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Expanded(child: Text(entry.$1)),
                      Text(number(entry.$2),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: _blue))
                    ]))
            ],
            hint: loc.analyticsNavigationHint)
      ],
      Text(loc.analyticsDataNote,
          style: const TextStyle(color: _muted, fontSize: 12, height: 1.5)),
      const SizedBox(height: 20)
    ];
  }

  List<Widget> audience(Map<String, dynamic> data) => [
        for (final pair in [
          ('devices', loc.analyticsDevices),
          ('platforms', loc.analyticsPlatforms),
          ('browsers', loc.analyticsBrowsers),
          ('countries', loc.analyticsCountries)
        ])
          distribution(pair.$2, data[pair.$1] as List, dimension),
        panel(
            loc.analyticsSources,
            (data['sources'] as List).isEmpty
                ? [Text(loc.analyticsEmpty)]
                : (data['sources'] as List)
                    .map<Widget>((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dimension(item),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  '${loc.analyticsVisitors}: ${number(item['views'])} · ${loc.analyticsUniqueClicks}: ${number(item['clicks'])}',
                                  style: const TextStyle(color: _muted)),
                              Text('CTR ${number(item['ctr'], percent: true)}',
                                  style: const TextStyle(color: _blue))
                            ])))
                    .toList()),
        distribution(loc.analyticsHours, data['hours'] as List,
            (item) => '${item['hour'].toString().padLeft(2, '0')}:00'),
        distribution(
            loc.analyticsWeekdays,
            data['weekdays'] as List,
            (item) => DateFormat.EEEE(locale).format(DateTime(2026, 10, 18)
                .add(Duration(days: item['weekday'] as int)))),
      ];

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      appBar: AppBar(
          leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_rounded)),
          title: Text(loc.analyticsTitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          backgroundColor: const Color(0xFFFAFBFD),
          foregroundColor: _ink,
          actions: [
            IconButton(
                onPressed: _loading ? null : _load,
                tooltip: loc.dashboardRetry,
                icon: const Icon(Icons.refresh_rounded))
          ]),
      body: SafeArea(
          child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(loc.analyticsIntro,
                                  style: const TextStyle(
                                      color: _muted, height: 1.5)),
                              const SizedBox(height: 14),
                              Wrap(spacing: 8, children: [
                                for (final days in [7, 30, 90])
                                  ChoiceChip(
                                      label: Text(loc.analyticsDays(days)),
                                      selected: _period == days,
                                      selectedColor: const Color(0xFFE5EFFF),
                                      onSelected: (_) {
                                        if (_period == days) {
                                          return;
                                        }
                                        setState(() => _period = days);
                                        _load();
                                      })
                              ])
                            ])),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: [
                          for (final tab in [
                            ('overview', loc.analyticsOverview),
                            ('links', loc.analyticsLinks),
                            ('audience', loc.analyticsAudience),
                            ('conversions', loc.analyticsConversions)
                          ])
                            Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                    label: Text(tab.$2),
                                    selected: _tab == tab.$1,
                                    selectedColor: const Color(0xFFE5EFFF),
                                    onSelected: (_) {
                                      if (_tab == tab.$1) {
                                        return;
                                      }
                                      setState(() => _tab = tab.$1);
                                      _load();
                                    }))
                        ])),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(
                              child: CircularProgressIndicator(color: _blue)))
                    else if (_failed)
                      Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(children: [
                            Text(loc.analyticsLoadError,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                                onPressed: _load,
                                child: Text(loc.dashboardRetry))
                          ]))
                    else
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: report())),
                  ]))));
}
