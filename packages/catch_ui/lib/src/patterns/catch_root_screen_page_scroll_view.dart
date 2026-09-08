import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_page_owner.dart';
import 'package:catch_ui/src/patterns/catch_screen_body_layout.dart';
import 'package:catch_ui/src/patterns/catch_sliver_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_sliver_terminal_padding.dart';
import 'package:catch_ui/src/primitives/catch_pager_focus_viewport.dart';
import 'package:flutter/material.dart';

/// Inner scroll owner for one page of `CatchRootScreenScaffold`.
///
/// It preserves the NestedScrollView overlap contract, isolates focus reveal
/// requests from the horizontal pager, owns shell-aware terminal padding, and
/// can center box-content slivers at the canonical readable width without
/// converting sliver-native pages into box layouts.
class CatchRootScreenPageScrollView extends StatefulWidget
    implements CatchRootScreenPageOwner {
  /// Standard root page: canonical body rhythm, responsive content lane, and
  /// shell-aware terminal clearance.
  const CatchRootScreenPageScrollView.standard({
    super.key,
    required this.scrollKey,
    required this.slivers,
    this.maxContentExtent = CatchLayout.screenPageMaxExtent,
    this.controller,
    this.scrollStateController,
    this.physics,
    this.onRefresh,
  }) : bodyLayout = CatchScreenBodyLayout.standard,
       includeTerminalPadding = true,
       constrainToContentWidth = true;

  /// Full-bleed root page whose slivers still use shell-owned terminal
  /// clearance.
  const CatchRootScreenPageScrollView.fullBleed({
    super.key,
    required this.scrollKey,
    required this.slivers,
    this.controller,
    this.scrollStateController,
    this.physics,
    this.onRefresh,
  }) : bodyLayout = CatchScreenBodyLayout.fullBleed,
       includeTerminalPadding = true,
       constrainToContentWidth = false,
       maxContentExtent = null;

  /// Full-bleed page whose single fill-remaining child owns its own scrolling
  /// viewport and terminal shell clearance.
  const CatchRootScreenPageScrollView.embeddedViewport({
    super.key,
    required this.scrollKey,
    required this.slivers,
    this.controller,
    this.scrollStateController,
    this.physics,
    this.onRefresh,
  }) : bodyLayout = CatchScreenBodyLayout.fullBleed,
       includeTerminalPadding = false,
       constrainToContentWidth = false,
       maxContentExtent = null;

  final PageStorageKey<String> scrollKey;
  final CatchScreenBodyLayout bodyLayout;
  final List<Widget> slivers;
  final bool includeTerminalPadding;

  /// Centers each supplied sliver around a [CatchLayout.maxContentWidth]
  /// content lane plus the canonical [CatchInsets.pageBody] side gutters.
  ///
  /// Full-bleed variants leave this false. The overlap injector and terminal
  /// padding always retain the viewport's full cross-axis extent.
  final bool constrainToContentWidth;

  /// Optional cross-axis extent for a content-width-constrained page.
  /// Defaults to the canonical prose lane plus page gutters.
  final double? maxContentExtent;
  final ScrollController? controller;
  final CatchRootScreenPageScrollController? scrollStateController;
  final ScrollPhysics? physics;
  final Future<void> Function()? onRefresh;

  @override
  State<CatchRootScreenPageScrollView> createState() =>
      _CatchRootScreenPageScrollViewState();
}

/// Imperative offset access for a [CatchRootScreenPageScrollView].
///
/// The page owns its widget state; consumers that need to preserve an offset
/// across a page transition use this controller instead of a public `State`
/// subclass or `GlobalKey`.
class CatchRootScreenPageScrollController {
  _CatchRootScreenPageScrollViewState? _state;

  double? captureOffset() => _state?._captureOffset();

  void restoreOffset(double? savedPixels) =>
      _state?._restoreOffset(savedPixels);

  void _attach(_CatchRootScreenPageScrollViewState state) {
    assert(_state == null || identical(_state, state));
    _state = state;
  }

  void _detach(_CatchRootScreenPageScrollViewState state) {
    if (identical(_state, state)) _state = null;
  }
}

class _CatchRootScreenPageScrollViewState
    extends State<CatchRootScreenPageScrollView>
    with AutomaticKeepAliveClientMixin<CatchRootScreenPageScrollView> {
  ScrollController? _effectiveController;

  @override
  void initState() {
    super.initState();
    widget.scrollStateController?._attach(this);
  }

  @override
  void didUpdateWidget(CatchRootScreenPageScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(
      oldWidget.scrollStateController,
      widget.scrollStateController,
    )) {
      oldWidget.scrollStateController?._detach(this);
      widget.scrollStateController?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.scrollStateController?._detach(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  double? _captureOffset() {
    final position = _ownPosition;
    return position?.hasPixels == true ? position!.pixels : null;
  }

  void _restoreOffset(double? savedPixels) {
    final position = _ownPosition;
    if (position?.hasPixels != true || savedPixels == null) return;
    position!.jumpTo(
      savedPixels.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  ScrollPosition? get _ownPosition {
    final controller = _effectiveController;
    if (controller == null || !controller.hasClients) return null;
    for (final position in controller.positions) {
      final notificationContext = position.context.notificationContext;
      if (notificationContext == null) continue;
      var belongsToThisPage = false;
      notificationContext.visitAncestorElements((element) {
        if (element == context) {
          belongsToThisPage = true;
          return false;
        }
        return true;
      });
      if (belongsToThisPage) return position;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CatchPagerFocusViewport(
      child: Builder(
        builder: (context) {
          _effectiveController =
              widget.controller ?? PrimaryScrollController.maybeOf(context);
          final scrollView = CustomScrollView(
            key: widget.scrollKey,
            controller: widget.controller,
            physics: widget.onRefresh == null
                ? widget.physics
                : AlwaysScrollableScrollPhysics(parent: widget.physics),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              CatchSliverScreenBody(
                layout: widget.bodyLayout,
                constrainToContentWidth: widget.constrainToContentWidth,
                maxContentExtent:
                    widget.maxContentExtent ?? CatchLayout.screenPageMaxExtent,
                slivers: widget.slivers,
              ),
              if (widget.includeTerminalPadding)
                const CatchSliverTerminalPadding(),
            ],
          );
          final onRefresh = widget.onRefresh;
          final refreshed = onRefresh == null
              ? scrollView
              : RefreshIndicator.adaptive(
                  onRefresh: onRefresh,
                  child: scrollView,
                );
          return refreshed;
        },
      ),
    );
  }
}
