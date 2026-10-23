import 'package:flutter/material.dart';

import '../dashboard_page.dart';
import '../pages/appointments.dart';
import '../pages/calendar.dart';
import '../pages/customers.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';

class MainNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onIndexSelected;
  final bool allowReselectCurrent;

  const MainNavBar({
    super.key,
    required this.currentIndex,
    this.onIndexSelected,
    this.allowReselectCurrent = false,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex && !allowReselectCurrent) return;
    Feedback.forTap(context);
    if (onIndexSelected != null) {
      onIndexSelected!(index);
      return;
    }
    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const AppointmentsPage();
        break;
      case 2:
        page = const CalendarPage();
        break;
      case 3:
      default:
        page = const CustomersPage();
        break;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF1FF),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(
            color: Color(0xFF0C2032),
            fontSize: 11,
            fontWeight: FontWeight.w600)),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF0866EB)
                : const Color(0xFF7A8798),
            size: 23)),
      ),
      child: NavigationBar(
        elevation: 0,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: loc.dashboardHome),
          NavigationDestination(
              icon: const Icon(Icons.event_note_outlined),
              selectedIcon: const Icon(Icons.event_note_rounded),
              label: loc.appointmentsTitle),
          NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: loc.dashboardCalendar),
          NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded),
              selectedIcon: const Icon(Icons.people_rounded),
              label: loc.customersTitle),
        ],
      ),
    );
  }
}
