import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class ProfileCardPalette {
  const ProfileCardPalette({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.chipFill,
    required this.chipBorder,
    required this.accent,
    required this.accentSoft,
    required this.shadow,
    required this.photoPlaceholder,
  });

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color chipFill;
  final Color chipBorder;
  final Color accent;
  final Color accentSoft;
  final Color shadow;
  final Gradient photoPlaceholder;

  static ProfileCardPalette of(BuildContext context) {
    final t = CatchTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF090706) : const Color(0xFF11100E);
    final surface = isDark ? const Color(0xFF18100D) : const Color(0xFF1C1713);
    final raised = isDark ? const Color(0xFF241914) : const Color(0xFF2A2019);

    return ProfileCardPalette(
      background: Color.alphaBlend(t.primary.withValues(alpha: 0.06), base),
      surface: surface,
      surfaceRaised: raised,
      border: Colors.white.withValues(alpha: isDark ? 0.12 : 0.16),
      textPrimary: const Color(0xFFFFF8F0),
      textSecondary: const Color(0xFFD8C8B6),
      textMuted: const Color(0xFF9E8B79),
      chipFill: Colors.white.withValues(alpha: isDark ? 0.07 : 0.09),
      chipBorder: Colors.white.withValues(alpha: isDark ? 0.14 : 0.17),
      accent: t.primary,
      accentSoft: t.primary.withValues(alpha: isDark ? 0.22 : 0.26),
      shadow: Colors.black.withValues(alpha: isDark ? 0.34 : 0.26),
      photoPlaceholder: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(t.primary.withValues(alpha: 0.24), raised),
          Color.alphaBlend(t.accent.withValues(alpha: 0.12), base),
        ],
      ),
    );
  }
}
