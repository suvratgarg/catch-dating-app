import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Accent-to-ink diagonal gradient hero shell for event_success surfaces.
class EventSuccessHeroSurface extends StatelessWidget {
  const EventSuccessHeroSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.accent, t.ink],
      ),
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      padding: CatchInsets.contentRelaxed,
      child: child,
    );
  }
}

class EventSuccessDarkPill extends StatelessWidget {
  const EventSuccessDarkPill({
    super.key,
    required this.label,
    this.foregroundColor,
  });

  final String label;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? CatchTokens.editorialWhite;
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.revealSurfaceFill,
      ),
      borderColor: CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.eventSuccessSubtleBorder,
      ),
      padding: CatchInsets.compactControlContent,
      child: Text(label, style: CatchTextStyles.labelL(context, color: color)),
    );
  }
}
