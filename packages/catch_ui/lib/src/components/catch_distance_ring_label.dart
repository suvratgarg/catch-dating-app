import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

/// Branded edge label shared by Flutter and native geographic distance rings.
///
/// A native map owns the radius geometry in metres; this Flutter overlay keeps
/// the readable label, tappable affordance, and typography identical to the
/// static distance-ring contract.
class CatchDistanceRingLabel extends StatelessWidget {
  const CatchDistanceRingLabel({
    super.key,
    required this.label,
    this.semanticLabel,
    this.semanticHint,
    this.onTap,
  });

  final String label;
  final String? semanticLabel;
  final String? semanticHint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? label,
      hint: semanticHint,
      onTap: onTap,
      child: ExcludeSemantics(
        child: CatchSurface(
          onTap: onTap,
          radius: CatchRadius.pill,
          borderRole: CatchBorderRole.control,
          backgroundColor: t.surface.withValues(
            alpha: CatchOpacity.distanceRingLabelFill,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: CatchPlatformTokens.minimumInteractiveExtent,
              minWidth: CatchPlatformTokens.minimumInteractiveExtent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchLayout.distanceRingLabelHorizontal,
                vertical: CatchSpacing.s1,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  style: CatchTextStyles.control(context, color: t.ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
