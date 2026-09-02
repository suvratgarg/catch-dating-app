// ignore_for_file: prefer_initializing_formals

import 'package:catch_dating_app/core/theme/catch_tokens.dart' show CatchLayout;
import 'package:catch_dating_app/core/widgets/catch_master_detail_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_pager_focus_boundary.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/widgets/catch_section_layout.dart'
    show CatchScreenBodyLayout, CatchSliverContentWidth;

enum _CatchRootScreenPageKind { scroll, surface, masterDetail }

/// Marker for an analyzer-verified semantic root-screen page owner.
///
/// Canonical pages use [CatchRootScreenPageScrollView] directly. Feature owners
/// may implement this interface only when their build terminal delegates to
/// that scroll owner; the resolved composition checker enforces that boundary.
abstract interface class CatchRootScreenPageOwner implements Widget {
  CatchScreenBodyLayout get bodyLayout;
}

/// Typed page entry accepted by [CatchRootScreenBody].
///
/// Every variant retains [CatchRootScreenPageScrollView] as the page's scroll and
/// geometry owner. Surface decoration and expanded master-detail composition
/// remain explicit adapters rather than arbitrary page children.
final class CatchRootScreenPageSpec {
  const CatchRootScreenPageSpec.scroll({required CatchRootScreenPageOwner page})
    : _kind = _CatchRootScreenPageKind.scroll,
      _page = page,
      _backgroundColor = null,
      _expanded = false,
      _detail = null;

  const CatchRootScreenPageSpec.surface({
    required CatchRootScreenPageOwner page,
    required Color backgroundColor,
  }) : _kind = _CatchRootScreenPageKind.surface,
       _page = page,
       _backgroundColor = backgroundColor,
       _expanded = false,
       _detail = null;

  const CatchRootScreenPageSpec.masterDetail({
    required bool expanded,
    required CatchRootScreenPageOwner master,
    required Widget detail,
  }) : _kind = _CatchRootScreenPageKind.masterDetail,
       _page = master,
       _backgroundColor = null,
       _expanded = expanded,
       _detail = detail;

  final _CatchRootScreenPageKind _kind;
  final CatchRootScreenPageOwner _page;
  final Color? _backgroundColor;
  final bool _expanded;
  final Widget? _detail;

  Widget build() {
    return switch (_kind) {
      _CatchRootScreenPageKind.scroll => _page as Widget,
      _CatchRootScreenPageKind.surface => ColoredBox(
        color: _backgroundColor!,
        child: _page as Widget,
      ),
      _CatchRootScreenPageKind.masterDetail => CatchMasterDetailLayout(
        expanded: _expanded,
        master: _page as Widget,
        detail: _detail!,
      ),
    };
  }
}

enum _CatchRootScreenBodyKind { single, paged }

/// Closed body specification for [CatchRootScreenScaffold].
///
/// This prevents a feature from supplying a raw `TabBarView` or unrelated
/// widget. Every visible page is a typed [CatchRootScreenPageSpec] whose primary
/// scroll owner is [CatchRootScreenPageScrollView].
final class CatchRootScreenBody {
  const CatchRootScreenBody.single({required CatchRootScreenPageSpec page})
    : _kind = _CatchRootScreenBodyKind.single,
      _page = page,
      _pages = null,
      _controller = null,
      _physics = null;

  const CatchRootScreenBody.paged({
    required TabController controller,
    required List<CatchRootScreenPageSpec> pages,
    ScrollPhysics? physics,
  }) : _kind = _CatchRootScreenBodyKind.paged,
       _page = null,
       _pages = pages,
       _controller = controller,
       _physics = physics;

  final _CatchRootScreenBodyKind _kind;
  final CatchRootScreenPageSpec? _page;
  final List<CatchRootScreenPageSpec>? _pages;
  final TabController? _controller;
  final ScrollPhysics? _physics;

  Widget build() {
    assert(
      _kind != _CatchRootScreenBodyKind.paged || _pages!.isNotEmpty,
      'CatchRootScreenBody.paged requires at least one page.',
    );
    return switch (_kind) {
      _CatchRootScreenBodyKind.single => _page!.build(),
      _CatchRootScreenBodyKind.paged => TabBarView(
        controller: _controller,
        physics: _physics,
        children: [for (final page in _pages!) page.build()],
      ),
    };
  }
}

/// Inner scroll owner for one page of [CatchRootScreenScaffold].
///
/// It preserves the NestedScrollView overlap contract, isolates focus reveal
/// requests from the horizontal pager, owns shell-aware terminal padding, and
/// can center box-content slivers at the canonical readable width without
/// converting sliver-native pages into box layouts.
class CatchRootScreenPageScrollView extends StatefulWidget
    implements CatchRootScreenPageOwner {
  const CatchRootScreenPageScrollView({
    super.key,
    required this.scrollKey,
    required this.bodyLayout,
    required this.slivers,
    this.includeTerminalPadding = true,
    this.constrainToContentWidth = false,
    this.maxContentExtent,
    this.controller,
    this.scrollStateController,
    this.physics,
    this.onRefresh,
  });

  final PageStorageKey<String> scrollKey;
  @override
  final CatchScreenBodyLayout bodyLayout;
  final List<Widget> slivers;
  final bool includeTerminalPadding;

  /// Centers each supplied sliver around a [CatchLayout.maxContentWidth]
  /// content lane plus the canonical [CatchInsets.pageBody] side gutters.
  ///
  /// Leave this false for full-bleed or intrinsically sliver-native pages such
  /// as read-only previews. The overlap injector and terminal-padding sliver
  /// always retain the viewport's full cross-axis extent.
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
    return CatchPagerFocusBoundary(
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
