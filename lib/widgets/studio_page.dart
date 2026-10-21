import 'package:flutter/material.dart';

/// Shared layout primitives for the three scheduling tabs.
class StudioPageStyle {
  static const background = Color(0xFFF0F5FF);
  static const ink = Color(0xFF0C2032);
  static const secondary = Color(0xFF627183);
  static const primary = Color(0xFF0866EB);
  static const border = Color(0xFFE5E7EB);
  static const radius = 16.0;
  static const gutter = 16.0;

  static AppBar appBar(
          {required String title,
          required IconData icon,
          required String refreshLabel,
          required VoidCallback onRefresh}) =>
      AppBar(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: gutter,
        title: Row(children: [
          Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: primary)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.2))),
        ]),
        actions: [
          IconButton(
              tooltip: refreshLabel,
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, color: secondary)),
          const SizedBox(width: 4)
        ],
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: border)),
      );
}

class StudioPageIntro extends StatelessWidget {
  final String text;
  const StudioPageIntro(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, height: 1.5, color: StudioPageStyle.secondary)),
      );
}

/// A quiet brand tint behind white content cards; it never intercepts gestures.
class StudioPageBackground extends StatelessWidget {
  final Widget child;
  const StudioPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F5FF), Color(0xFFF3F6FB), Color(0xFFEDF7F5)],
              stops: [0, .6, 1],
            ),
          ),
          child: child,
        ),
      );
}
