import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/widgets.dart';

/// Immutable shell geometry supplied to sliver features.
class CatchViewportGeometry {
  const CatchViewportGeometry({required this.width, required this.sizeClass});

  final double width;
  final CatchWindowSize sizeClass;
}

typedef CatchViewportSliverBuilder =
    Widget Function(BuildContext context, CatchViewportGeometry viewport);
