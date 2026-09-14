// ignore_for_file: prefer_initializing_formals

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_primary_rail.dart';
import 'package:catch_ui/src/patterns/catch_page_body_mode.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_scroll_view.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_scroll_view_placement.dart';
import 'package:catch_ui/src/patterns/catch_scaffold.dart';
import 'package:flutter/material.dart';

/// Full-screen owner for a root destination with scroll-content title chrome.
///
/// Root feature screens provide semantic header content and body sliver children. This
/// scaffold owns the page surface, safe area, vertical scroll owner, body
/// geometry, responsive content lane, field obstruction, refresh behavior,
/// and terminal clearance above adaptive shell navigation.
class CatchRootScreenScaffold extends StatelessWidget {
  const CatchRootScreenScaffold.standard({
    super.key,
    required Widget title,
    required List<Widget> children,
    this.scrollKey,
    this.controller,
    this.physics,
    this.primary,
    this.onRefresh,
    this.maxContentExtent = CatchLayout.screenPageMaxExtent,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenScrollViewPlacement.safeArea,
  }) : _title = title,
       _primaryRailHeader = null,
       bodyLayout = CatchPageBodyMode.standard,
       children = children,
       actions = null,
       body = null,
       constrainToContentWidth = true,
       assert(children.length > 0),
       assert(maxContentExtent > 0);

  const CatchRootScreenScaffold.fullBleed({
    super.key,
    required Widget title,
    required List<Widget> children,
    this.scrollKey,
    this.controller,
    this.physics,
    this.primary,
    this.onRefresh,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenScrollViewPlacement.safeArea,
  }) : _title = title,
       _primaryRailHeader = null,
       bodyLayout = CatchPageBodyMode.fullBleed,
       children = children,
       actions = null,
       body = null,
       constrainToContentWidth = false,
       maxContentExtent = CatchLayout.screenPageMaxExtent,
       assert(children.length > 0);

  /// Root composition with a scroll-away header and pinned primary rail.
  /// [actions] accepts only a typed primary control rail.
  ///
  /// The rail is optional at the root-system level but required by this named
  /// constructor, which closes the body over root-page scroll owners and keeps
  /// invalid rail/body combinations unrepresentable at route call sites.
  const CatchRootScreenScaffold.withPrimaryRail({
    super.key,
    required CatchRootScreenHeader header,
    required CatchPrimaryRail actions,
    required this.body,
    this.scrollKey,
    this.controller,
    this.physics,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenScrollViewPlacement.safeArea,
  }) : _title = null,
       _primaryRailHeader = header,
       actions = actions,
       bodyLayout = null,
       children = null,
       primary = null,
       onRefresh = null,
       constrainToContentWidth = false,
       maxContentExtent = CatchLayout.screenPageMaxExtent;

  final Widget? _title;
  final CatchRootScreenHeader? _primaryRailHeader;
  final CatchPageBodyMode? bodyLayout;

  /// Sliver children of the standard/fullBleed recipes; the rail recipe uses body.
  final List<Widget>? children;
  final CatchPrimaryRail? actions;
  final CatchRootScreenBody? body;
  final Key? scrollKey;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool? primary;
  final Future<void> Function()? onRefresh;
  final bool constrainToContentWidth;
  final double maxContentExtent;
  final String? semanticsLabel;
  final String? semanticsHint;
  final CatchRootScreenScrollViewPlacement topEdge;

  @override
  Widget build(BuildContext context) {
    if (actions != null) {
      return CatchScaffold.workspace(
        body: CatchRootScreenScrollView.withPrimaryRail(
          header: _primaryRailHeader!,
          actions: actions!,
          body: body!,
          scrollKey: scrollKey,
          controller: controller,
          physics: physics,
          semanticsLabel: semanticsLabel,
          semanticsHint: semanticsHint,
          topEdge: topEdge,
        ),
      );
    }
    return CatchScaffold.workspace(
      body: switch (bodyLayout!) {
        CatchPageBodyMode.standard => CatchRootScreenScrollView.standard(
          title: _title!,
          scrollKey: scrollKey,
          controller: controller,
          physics: physics,
          primary: primary,
          onRefresh: onRefresh,
          maxContentExtent: maxContentExtent,
          semanticsLabel: semanticsLabel,
          semanticsHint: semanticsHint,
          topEdge: topEdge,
          children: children!,
        ),
        CatchPageBodyMode.fullBleed => CatchRootScreenScrollView.fullBleed(
          title: _title!,
          scrollKey: scrollKey,
          controller: controller,
          physics: physics,
          primary: primary,
          onRefresh: onRefresh,
          semanticsLabel: semanticsLabel,
          semanticsHint: semanticsHint,
          topEdge: topEdge,
          children: children!,
        ),
      },
    );
  }
}
