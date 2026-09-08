import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_viewport_geometry.dart';
import 'package:flutter/material.dart';

typedef CatchViewportSliverBuilder =
    Widget Function(BuildContext context, CatchViewportGeometry viewport);

/// Supplies cross-axis viewport geometry to a sliver without features reading
/// global window metrics.
class CatchViewportSliver extends StatelessWidget {
  const CatchViewportSliver({super.key, required this.sliverBuilder});

  final CatchViewportSliverBuilder sliverBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        return sliverBuilder(
          context,
          CatchViewportGeometry(
            width: width,
            sizeClass: CatchWindowSize.fromWidth(width),
          ),
        );
      },
    );
  }
}
