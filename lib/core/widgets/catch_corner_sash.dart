import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Small top-corner status mark used on event/club hero cards in place of a
/// chip cluster. One sash per card; it picks the most semantically dominant
/// status (e.g. `You're in`, `Saved`, `Hosted`) so the card reads with a
/// clear hierarchy instead of three competing pills.
class CatchCornerSash extends StatelessWidget {
  const CatchCornerSash({
    super.key,
    required this.label,
    this.icon,
    this.tone = CatchSashTone.brand,
    this.alignment = CatchSashAlignment.topStart,
  });

  final String label;
  final IconData? icon;
  final CatchSashTone tone;
  final CatchSashAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = _palette(t);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s2,
          vertical: CatchSpacing.micro3,
        ),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: _borderRadius(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: palette.foreground),
              gapW4,
            ],
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.statusLabel(
                context,
                color: palette.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius _borderRadius() {
    const corner = Radius.circular(CatchRadius.pill);
    const sharp = Radius.zero;
    return switch (alignment) {
      CatchSashAlignment.topStart => const BorderRadius.only(
        topLeft: sharp,
        bottomRight: corner,
        bottomLeft: sharp,
        topRight: corner,
      ),
      CatchSashAlignment.topEnd => const BorderRadius.only(
        topRight: sharp,
        bottomLeft: corner,
        bottomRight: sharp,
        topLeft: corner,
      ),
    };
  }

  _SashPalette _palette(CatchTokens t) {
    return switch (tone) {
      CatchSashTone.brand =>
        _SashPalette(background: t.primary, foreground: t.primaryInk),
      CatchSashTone.success => _SashPalette(
        background: t.success,
        foreground: Colors.white,
      ),
      CatchSashTone.solid =>
        _SashPalette(background: t.ink, foreground: t.surface),
      CatchSashTone.surface => _SashPalette(
        background: Colors.white.withValues(alpha: 0.92),
        foreground: t.ink,
      ),
    };
  }
}

class _SashPalette {
  const _SashPalette({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}

enum CatchSashTone { brand, success, solid, surface }

enum CatchSashAlignment { topStart, topEnd }
