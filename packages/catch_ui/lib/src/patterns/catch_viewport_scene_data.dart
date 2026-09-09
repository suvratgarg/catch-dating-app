import 'package:flutter/widgets.dart';

/// Bounded scene dimensions and the inherited safe-area insets.
class CatchViewportSceneData {
  const CatchViewportSceneData({
    required this.width,
    required this.height,
    required this.mediaPadding,
  });

  final double width;
  final double height;
  final EdgeInsets mediaPadding;
}

typedef CatchViewportSceneBuilder =
    Widget Function(BuildContext context, CatchViewportSceneData viewport);
