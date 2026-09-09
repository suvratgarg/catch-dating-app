// ignore_for_file: prefer_initializing_formals

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_primary_rail.dart';
import 'package:catch_ui/src/patterns/catch_page_body_mode.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_scroll_view.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_top_edge.dart';
import 'package:catch_ui/src/patterns/catch_screen_scaffold.dart';
import 'package:flutter/material.dart';

/// Full-screen owner for a root destination with scroll-content title chrome.
///
/// Root feature screens provide semantic header content and body slivers. This
/// scaffold owns the page surface, safe area, vertical scroll owner, body
/// geometry, responsive content lane, field obstruction, refresh behavior,
/// and terminal clearance above adaptive shell navigation.
class CatchRootScreenScaffold extends StatelessWidget {
  const CatchRootScreenScaffold.standard({
    super.key,
    required Widget header,
    required List<Widget> slivers,
    this.scrollKey,
    this.controller,
    this.physics,
    this.primary,
    this.onRefresh,
    this.maxContentExtent = CatchLayout.screenPageMaxExtent,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenTopEdge.safeArea,
  }) : _header = header,
       _primaryRailHeader = null,
       bodyLayout = CatchPageBodyMode.standard,
       slivers = slivers,
       primaryRail = null,
       body = null,
       constrainToContentWidth = true,
       assert(slivers.length > 0),
       assert(maxContentExtent > 0);

  const CatchRootScreenScaffold.fullBleed({
    super.key,
    required Widget header,
    required List<Widget> slivers,
    this.scrollKey,
    this.controller,
    this.physics,
    this.primary,
    this.onRefresh,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenTopEdge.safeArea,
  }) : _header = header,
       _primaryRailHeader = null,
       bodyLayout = CatchPageBodyMode.fullBleed,
       slivers = slivers,
       primaryRail = null,
       body = null,
       constrainToContentWidth = false,
       maxContentExtent = CatchLayout.screenPageMaxExtent,
       assert(slivers.length > 0);

  /// Root composition with a scroll-away header and pinned primary rail.
  ///
  /// The rail is optional at the root-system level but required by this named
  /// constructor, which closes the body over root-page scroll owners and keeps
  /// invalid rail/body combinations unrepresentable at route call sites.
  const CatchRootScreenScaffold.withPrimaryRail({
    super.key,
    required CatchRootScreenHeader header,
    required this.primaryRail,
    required this.body,
    this.scrollKey,
    this.controller,
    this.physics,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenTopEdge.safeArea,
  }) : _header = null,
       _primaryRailHeader = header,
       bodyLayout = null,
       slivers = null,
       primary = null,
       onRefresh = null,
       constrainToContentWidth = false,
       maxContentExtent = CatchLayout.screenPageMaxExtent;

  final Widget? _header;
  final CatchRootScreenHeader? _primaryRailHeader;
  final CatchPageBodyMode? bodyLayout;
  final List<Widget>? slivers;
  final CatchPrimaryRail? primaryRail;
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
  final CatchRootScreenTopEdge topEdge;

  @override
  Widget build(BuildContext context) {
    if (primaryRail != null) {
      return CatchScreenScaffold.workspace(
        body: CatchRootScreenScrollView.withPrimaryRail(
          header: _primaryRailHeader!,
          primaryRail: primaryRail!,
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
    return CatchScreenScaffold.workspace(
      body: switch (bodyLayout!) {
        CatchPageBodyMode.standard => CatchRootScreenScrollView.standard(
          header: _header!,
          slivers: slivers!,
          scrollKey: scrollKey,
          controller: controller,
          physics: physics,
          primary: primary,
          onRefresh: onRefresh,
          maxContentExtent: maxContentExtent,
          semanticsLabel: semanticsLabel,
          semanticsHint: semanticsHint,
          topEdge: topEdge,
        ),
        CatchPageBodyMode.fullBleed => CatchRootScreenScrollView.fullBleed(
          header: _header!,
          slivers: slivers!,
          scrollKey: scrollKey,
          controller: controller,
          physics: physics,
          primary: primary,
          onRefresh: onRefresh,
          semanticsLabel: semanticsLabel,
          semanticsHint: semanticsHint,
          topEdge: topEdge,
        ),
      },
    );
  }
}
