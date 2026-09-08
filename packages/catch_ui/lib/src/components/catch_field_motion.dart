import 'package:flutter/widgets.dart';

/// Resolves field motion against the caller's accessibility settings.
Duration catchFieldMotionDuration(BuildContext context, Duration duration) {
  final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
  return disableAnimations == true ? Duration.zero : duration;
}
