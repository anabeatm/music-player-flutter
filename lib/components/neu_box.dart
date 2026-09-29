import 'package:flutter/material.dart';

class NeuBox extends StatelessWidget {
  final Widget? child;
  const NeuBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Blend black/white into the current surface color (instead of a fixed
    // grey) so the neumorphic shadows match whichever theme preset/color is
    // active, in both light and dark mode.
    final darkShadow = Color.alphaBlend(
      Colors.black.withValues(alpha: isDarkMode ? 0.55 : 0.25),
      surface,
    );
    final lightShadow = Color.alphaBlend(
      Colors.white.withValues(alpha: isDarkMode ? 0.12 : 0.9),
      surface,
    );

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // darker shadow on bottom right
          BoxShadow(color: darkShadow, blurRadius: 15, offset: const Offset(4, 4)),

          // lighter shadow on top left
          BoxShadow(color: lightShadow, blurRadius: 15, offset: const Offset(-4, -4)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
