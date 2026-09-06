import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Turns a real content composition into its loading skeleton.
///
/// Unlike hand-authored placeholder layouts, this wrapper keeps the loaded
/// widget tree as the single source of truth. Callers provide representative
/// placeholder data only for branches that need a shape while loading.
class CatchSkeletonized extends StatelessWidget {
  const CatchSkeletonized({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations == true;
    final effect = reduceMotion
        ? SolidColorEffect(color: t.raised)
        : ShimmerEffect(
            baseColor: t.raised,
            highlightColor: t.surface,
            duration: CatchMotion.skeletonShimmer,
          );

    return ExcludeSemantics(
      excluding: enabled,
      child: Skeletonizer(
        enabled: enabled,
        effect: effect,
        ignoreContainers: true,
        child: child,
      ),
    );
  }
}
