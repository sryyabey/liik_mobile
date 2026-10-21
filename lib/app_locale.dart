import 'package:flutter/material.dart';

/// Markets supported by Liik. Persist the full tag to preserve US/UK choice.
const liikLocales = [
  Locale('en', 'US'),
  Locale('en', 'GB'),
  Locale('pt', 'BR'),
  Locale('id', 'ID')
];
const defaultLiikLocale = Locale('en', 'US');

Locale resolveLiikLocale(Locale? locale) {
  switch (locale?.languageCode) {
    case 'en':
      return locale?.countryCode == 'GB' ? liikLocales[1] : liikLocales[0];
    case 'pt':
      return liikLocales[2];
    case 'id':
      return liikLocales[3];
    default:
      return defaultLiikLocale;
  }
}

Locale parseLiikLocale(String tag) {
  if (tag.trim().isEmpty) return defaultLiikLocale;
  final parts = tag.replaceAll('_', '-').split('-');
  return resolveLiikLocale(
      Locale(parts.first, parts.length > 1 ? parts.last : null));
}

String liikLocaleLabel(Locale locale) =>
    switch (resolveLiikLocale(locale).toLanguageTag()) {
      'en-GB' => 'English (UK)',
      'pt-BR' => 'Português (Brasil)',
      'id-ID' => 'Bahasa Indonesia',
      _ => 'English (US)',
    };

class LiikLanguagePicker extends StatelessWidget {
  final ValueChanged<Locale> onChanged;
  final Color? foregroundColor;
  const LiikLanguagePicker(
      {super.key, required this.onChanged, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    final current = resolveLiikLocale(Localizations.localeOf(context));
    final short = switch (current.toLanguageTag()) {
      'en-GB' => 'EN · UK',
      'pt-BR' => 'PT · BR',
      'id-ID' => 'ID',
      _ => 'EN · US',
    };
    return PopupMenuButton<Locale>(
      tooltip: liikLocaleLabel(current),
      initialValue: current,
      onSelected: onChanged,
      itemBuilder: (_) => liikLocales
          .map((locale) => PopupMenuItem(
                value: locale,
                child: Row(children: [
                  Expanded(child: Text(liikLocaleLabel(locale))),
                  if (locale == current)
                    const Icon(Icons.check_rounded, size: 18),
                ]),
              ))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.language_rounded, size: 17, color: foregroundColor),
          const SizedBox(width: 6),
          Flexible(
              child: Text(short,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor))),
          Icon(Icons.expand_more_rounded, size: 16, color: foregroundColor),
        ]),
      ),
    );
  }
}

const liikAlphabet = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z'
];
