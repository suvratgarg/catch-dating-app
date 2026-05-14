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
    final base = isDark ? const Color(0xFF120F0C) : const Color(0xFFFFF7EC);
    final surface = isDark ? const Color(0xFF1B1713) : const Color(0xFFFFFCF7);
    final raised = isDark ? const Color(0xFF251E19) : const Color(0xFFFFF4E8);

    return ProfileCardPalette(
      background: Color.alphaBlend(t.primary.withValues(alpha: 0.04), base),
      surface: surface,
      surfaceRaised: raised,
      border: isDark
          ? Colors.white.withValues(alpha: 0.11)
          : const Color(0xFFEADDD0),
      textPrimary: isDark ? const Color(0xFFFFF8F0) : const Color(0xFF201712),
      textSecondary: isDark
          ? const Color(0xFFD8C8B6)
          : const Color(0xFF665447),
      textMuted: isDark ? const Color(0xFF9E8B79) : const Color(0xFF9A8777),
      chipFill: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFFFFF6EC),
      chipBorder: isDark
          ? Colors.white.withValues(alpha: 0.14)
          : const Color(0xFFE7D6C8),
      accent: t.primary,
      accentSoft: t.primary.withValues(alpha: isDark ? 0.22 : 0.10),
      shadow: Colors.black.withValues(alpha: isDark ? 0.34 : 0.10),
      photoPlaceholder: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(t.primary.withValues(alpha: 0.16), raised),
          Color.alphaBlend(t.accent.withValues(alpha: 0.08), base),
        ],
      ),
    );
  }
}
