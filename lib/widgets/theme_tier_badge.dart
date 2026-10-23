import 'package:flutter/material.dart';
import 'package:liik_mobile/l10n/app_localizations.dart';

/// Older API responses may omit the field or encode booleans as 0/1.
bool isPremiumTheme(Map<String, dynamic> theme) {
  final value = theme['is_premium'];
  return value == true || value == 1 || value == '1' || value == 'true';
}

class ThemeTierBadge extends StatelessWidget {
  const ThemeTierBadge({super.key, required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        isPremium ? loc.themesPremium : loc.themesFree,
        style: TextStyle(
          color: isPremium ? const Color(0xFF92400E) : const Color(0xFF166534),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
