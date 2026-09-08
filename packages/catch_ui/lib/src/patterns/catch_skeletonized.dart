import 'package:catch_ui/src/patterns/catch_skeleton_effect.dart';
import 'package:flutter/widgets.dart';
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
    return ExcludeSemantics(
      excluding: enabled,
      child: Skeletonizer(
        enabled: enabled,
        effect: catchSkeletonEffect(context),
        ignoreContainers: true,
        child: child,
      ),
    );
  }
}
