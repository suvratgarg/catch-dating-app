import 'package:catch_tokens/catch_tokens.dart';

/// Immutable shell geometry supplied to sliver features.
class CatchViewportGeometry {
  const CatchViewportGeometry({required this.width, required this.sizeClass});

  final double width;
  final CatchWindowSize sizeClass;
}
