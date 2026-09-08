import 'dart:math' as math;

import 'package:flutter/material.dart';

class CatchSceneViewportData {
  const CatchSceneViewportData({
    required this.width,
    required this.height,
    required this.mediaPadding,
  });

  final double width;
  final double height;
  final EdgeInsets mediaPadding;
}

typedef CatchSceneViewportBuilder =
    Widget Function(BuildContext context, CatchSceneViewportData viewport);

/// Provides bounded full-screen geometry to a choreographed scene.
///
/// Animation features receive one immutable viewport description instead of
/// mixing global MediaQuery size with local box constraints.
class CatchSceneViewport extends StatelessWidget {
  const CatchSceneViewport({
    super.key,
    required this.maxWidth,
    required this.builder,
  });

  final double maxWidth;
  final CatchSceneViewportBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : media.size.width;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : media.size.height;
        final width = math.min(availableWidth, maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: height,
            child: builder(
              context,
              CatchSceneViewportData(
                width: width,
                height: height,
                mediaPadding: media.padding,
              ),
            ),
          ),
        );
      },
    );
  }
}
