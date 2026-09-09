import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_viewport_geometry.dart';
import 'package:catch_ui/src/patterns/catch_viewport_scene_data.dart';
import 'package:flutter/material.dart';

/// Local viewport measurement and caller-owned layout selection.
///
/// The default uses Material size classes, with medium falling back to compact
/// and expanded falling back to medium then compact. Named constructors select
/// a caller-owned threshold, supply sliver geometry, or bound a scene's geometry.
class CatchViewport extends StatelessWidget {
  const CatchViewport({
    super.key,
    required WidgetBuilder compactBuilder,
    WidgetBuilder? mediumBuilder,
    WidgetBuilder? expandedBuilder,
  }) : _selection = (
         compactBuilder: compactBuilder,
         mediumBuilder: mediumBuilder,
         expandedBuilder: expandedBuilder,
         breakpoint: null,
       ),
       _sliverBuilder = null,
       _scene = null;

  const CatchViewport.atWidth({
    super.key,
    required double breakpoint,
    required WidgetBuilder compactBuilder,
    required WidgetBuilder expandedBuilder,
  }) : _selection = (
         compactBuilder: compactBuilder,
         mediumBuilder: null,
         expandedBuilder: expandedBuilder,
         breakpoint: breakpoint,
       ),
       _sliverBuilder = null,
       _scene = null;

  const CatchViewport.sliver({
    super.key,
    required CatchViewportSliverBuilder sliverBuilder,
  }) : _selection = null,
       _sliverBuilder = sliverBuilder,
       _scene = null;

  const CatchViewport.scene({
    super.key,
    required double maxWidth,
    required CatchViewportSceneBuilder builder,
  }) : _selection = null,
       _sliverBuilder = null,
       _scene = (maxWidth: maxWidth, builder: builder);

  final ({
    WidgetBuilder compactBuilder,
    WidgetBuilder? mediumBuilder,
    WidgetBuilder? expandedBuilder,
    double? breakpoint,
  })?
  _selection;
  final CatchViewportSliverBuilder? _sliverBuilder;
  final ({double maxWidth, CatchViewportSceneBuilder builder})? _scene;

  @override
  Widget build(BuildContext context) {
    final sliverBuilder = _sliverBuilder;
    if (sliverBuilder != null) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final scene = _scene;
        if (scene != null) {
          final media = MediaQuery.of(context);
          final availableWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : media.size.width;
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : media.size.height;
          final width = math.min(availableWidth, scene.maxWidth);
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: height,
              child: scene.builder(
                context,
                CatchViewportSceneData(
                  width: width,
                  height: height,
                  mediaPadding: media.padding,
                ),
              ),
            ),
          );
        }
        final selection = _selection!;
        final breakpoint = selection.breakpoint;
        if (breakpoint != null) {
          return constraints.maxWidth < breakpoint
              ? selection.compactBuilder(context)
              : selection.expandedBuilder!(context);
        }
        return switch (CatchWindowSize.fromWidth(constraints.maxWidth)) {
          CatchWindowSize.compact => selection.compactBuilder(context),
          CatchWindowSize.medium =>
            (selection.mediumBuilder ?? selection.compactBuilder)(context),
          CatchWindowSize.expanded =>
            (selection.expandedBuilder ??
                selection.mediumBuilder ??
                selection.compactBuilder)(context),
        };
      },
    );
  }
}
