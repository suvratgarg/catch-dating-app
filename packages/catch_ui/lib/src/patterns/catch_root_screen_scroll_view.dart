// ignore_for_file: prefer_initializing_formals

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_choice_input_variant.dart';
import 'package:catch_ui/src/components/catch_field_visibility_scope.dart';
import 'package:catch_ui/src/components/catch_page_tab_bar.dart';
import 'package:catch_ui/src/components/catch_primary_rail.dart';
import 'package:catch_ui/src/components/catch_screen_header.dart';
import 'package:catch_ui/src/components/catch_screen_top_bar.dart';
import 'package:catch_ui/src/components/catch_status_strip.dart';
import 'package:catch_ui/src/components/catch_status_strip_scope.dart';
import 'package:catch_ui/src/components/catch_top_bar_search.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_top_edge.dart';
import 'package:catch_ui/src/patterns/catch_screen_body_layout.dart';
import 'package:catch_ui/src/patterns/catch_sliver_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_sliver_terminal_padding.dart';
import 'package:catch_ui/src/patterns/catch_tab_viewport_scope.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

part 'catch_root_screen_header.dart';

/// Root-screen scroll composition for a pane whose parent already owns the
/// [Scaffold], such as an adaptive master-detail workspace.
class CatchRootScreenScrollView extends StatelessWidget {
  const CatchRootScreenScrollView.standard({
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
       bodyLayout = CatchScreenBodyLayout.standard,
       slivers = slivers,
       primaryRail = null,
       body = null,
       constrainToContentWidth = true,
       assert(slivers.length > 0),
       assert(maxContentExtent > 0);

  const CatchRootScreenScrollView.fullBleed({
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
       bodyLayout = CatchScreenBodyLayout.fullBleed,
       slivers = slivers,
       primaryRail = null,
       body = null,
       constrainToContentWidth = false,
       maxContentExtent = CatchLayout.screenPageMaxExtent,
       assert(slivers.length > 0);

  /// Embedded root composition with a scroll-away header and pinned rail.
  const CatchRootScreenScrollView.withPrimaryRail({
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
  final CatchScreenBodyLayout? bodyLayout;
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
    final obstruction = CatchTabViewportScope.bottomOverlayInsetOf(context);
    final statuses = CatchStatusStripScope.of(context);
    Widget scrollView;
    if (primaryRail == null) {
      scrollView = CustomScrollView(
        key: scrollKey,
        controller: controller,
        primary: primary,
        physics: onRefresh == null
            ? physics
            : AlwaysScrollableScrollPhysics(parent: physics),
        slivers: [
          SliverToBoxAdapter(child: _header!),
          if (statuses.isNotEmpty)
            PinnedHeaderSliver(child: CatchStatusStrip(statuses: statuses)),
          CatchSliverScreenBody(
            layout: bodyLayout!,
            constrainToContentWidth: constrainToContentWidth,
            maxContentExtent: maxContentExtent,
            slivers: slivers!,
          ),
          const CatchSliverTerminalPadding(),
        ],
      );
    } else {
      _validatePrimaryRailGeometry(context);
      scrollView = NestedScrollView(
        key: scrollKey,
        controller: controller,
        physics: physics,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _primaryRailHeader!._build(context)),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              // Keep rail and status in one intrinsic pinned unit so the
              // inner page absorbs their complete height at every text scale.
              sliver: PinnedHeaderSliver(
                child: ColoredBox(
                  color: CatchTokens.of(context).bg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: switch (primaryRail) {
                          final CatchScaledPreferredSize scaled =>
                            scaled.preferredSizeFor(context).height,
                          _ => CatchPageTabBar.heightFor(context),
                        },
                        child: primaryRail,
                      ),
                      CatchStatusStrip(statuses: statuses),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: body!.build(),
      );
    }
    if (primaryRail == null && onRefresh != null) {
      scrollView = RefreshIndicator.adaptive(
        onRefresh: onRefresh!,
        child: scrollView,
      );
    }
    if (semanticsLabel != null || semanticsHint != null) {
      scrollView = Semantics(
        label: semanticsLabel,
        hint: semanticsHint,
        child: scrollView,
      );
    }
    return CatchStatusStripScope(
      statuses: const [],
      child: CatchFieldVisibilityScope(
        bottomObstruction: obstruction,
        child: SafeArea(
          // While status is pinned, this viewport owns the physical inset.
          // SafeArea removes it from MediaQuery so an edge-owned hero cannot
          // apply it twice or let the pinned status move under system chrome.
          top:
              topEdge == CatchRootScreenTopEdge.safeArea || statuses.isNotEmpty,
          bottom: false,
          child: scrollView,
        ),
      ),
    );
  }

  void _validatePrimaryRailGeometry(BuildContext context) {
    final declaredHeight = primaryRail!.preferredSize.height;
    // Canonical variants own their insets as well as their target floor.
    // Feature adapters must forward the same unscaled minimum, never restate
    // the old 44-point constant or substitute local geometry.
    final variant = primaryRail is CatchPageTabBar
        ? (primaryRail as CatchPageTabBar).variant
        : CatchChoiceInputVariant.label;
    final expectedMinimum = CatchPageTabBar.minimumHeightFor(variant);
    final expectedScaled = CatchPageTabBar.heightFor(context, variant: variant);
    final declaredScaled = switch (primaryRail) {
      final CatchScaledPreferredSize scaled =>
        scaled.preferredSizeFor(context).height,
      _ => expectedScaled,
    };
    if (declaredHeight == expectedMinimum && declaredScaled == expectedScaled) {
      return;
    }

    throw FlutterError.fromParts([
      ErrorSummary(
        'CatchRootScreenScaffold requires a '
        '$expectedMinimum-point primary rail.',
      ),
      ErrorDescription(
        '${primaryRail.runtimeType} declared a preferred height of '
        '$declaredHeight points and a scaled height of $declaredScaled points '
        '(expected $expectedScaled).',
      ),
      ErrorHint(
        'Use CatchPageTabBar, or make the feature '
        'adapter report CatchPageTabBar.minimumHeight. The root scaffold owns the '
        'pinned extent; screens must not define local rail geometry.',
      ),
    ]);
  }
}
