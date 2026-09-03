// ignore_for_file: prefer_initializing_formals

import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldVisibilityScope;
import 'package:catch_dating_app/core/widgets/catch_master_detail_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_pager_focus_boundary.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/widgets/catch_section_layout.dart'
    show CatchScreenBodyLayout, CatchSliverContentWidth;

enum _CatchTabbedPageKind { scroll, surface, masterDetail }

/// Marker for an analyzer-verified semantic tab page owner.
///
/// Canonical pages use [CatchTabbedPageScrollView] directly. Feature owners
/// may implement this interface only when their build terminal delegates to
/// that scroll owner; the resolved composition checker enforces that boundary.
abstract interface class CatchTabbedPageOwner implements Widget {
  CatchScreenBodyLayout get bodyLayout;
}

/// Typed page entry accepted by [CatchTabbedScreenBody].
///
/// Every variant retains [CatchTabbedPageScrollView] as the tab's scroll and
/// geometry owner. Surface decoration and expanded master-detail composition
/// remain explicit adapters rather than arbitrary tab children.
final class CatchTabbedPageSpec {
  const CatchTabbedPageSpec.scroll({
    required CatchScreenBodyLayout bodyLayout,
    required CatchTabbedPageOwner page,
  }) : _kind = _CatchTabbedPageKind.scroll,
       _bodyLayout = bodyLayout,
       _page = page,
       _backgroundColor = null,
       _expanded = false,
       _detail = null;

  const CatchTabbedPageSpec.surface({
    required CatchScreenBodyLayout bodyLayout,
    required CatchTabbedPageOwner page,
    required Color backgroundColor,
  }) : _kind = _CatchTabbedPageKind.surface,
       _bodyLayout = bodyLayout,
       _page = page,
       _backgroundColor = backgroundColor,
       _expanded = false,
       _detail = null;

  const CatchTabbedPageSpec.masterDetail({
    required CatchScreenBodyLayout bodyLayout,
    required bool expanded,
    required CatchTabbedPageOwner master,
    required Widget detail,
  }) : _kind = _CatchTabbedPageKind.masterDetail,
       _bodyLayout = bodyLayout,
       _page = master,
       _backgroundColor = null,
       _expanded = expanded,
       _detail = detail;

  final _CatchTabbedPageKind _kind;
  final CatchScreenBodyLayout _bodyLayout;
  final CatchTabbedPageOwner _page;
  final Color? _backgroundColor;
  final bool _expanded;
  final Widget? _detail;

  Widget _build() {
    if (_page.bodyLayout != _bodyLayout) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'CatchTabbedPageSpec and its page owner disagree on body geometry.',
        ),
        ErrorDescription(
          '${_page.runtimeType} declares ${_page.bodyLayout}, while the page '
          'spec declares $_bodyLayout.',
        ),
        ErrorHint(
          'Use the same explicit CatchScreenBodyLayout on the page spec and '
          'its CatchTabbedPageOwner. Semantic wrappers must forward that role '
          'to CatchTabbedPageScrollView.',
        ),
      ]);
    }
    return switch (_kind) {
      _CatchTabbedPageKind.scroll => _page as Widget,
      _CatchTabbedPageKind.surface => ColoredBox(
        color: _backgroundColor!,
        child: _page as Widget,
      ),
      _CatchTabbedPageKind.masterDetail => CatchMasterDetailLayout(
        expanded: _expanded,
        master: _page as Widget,
        detail: _detail!,
      ),
    };
  }
}

enum _CatchTabbedScreenBodyKind { single, paged }

/// Closed body specification for [CatchTabbedScreenScaffold].
///
/// This prevents a feature from supplying a raw `TabBarView` or unrelated
/// widget. Every visible page is a typed [CatchTabbedPageSpec] whose primary
/// scroll owner is [CatchTabbedPageScrollView].
final class CatchTabbedScreenBody {
  const CatchTabbedScreenBody.single({required CatchTabbedPageSpec page})
    : _kind = _CatchTabbedScreenBodyKind.single,
      _page = page,
      _pages = null,
      _controller = null,
      _physics = null;

  const CatchTabbedScreenBody.paged({
    required TabController controller,
    required List<CatchTabbedPageSpec> pages,
    ScrollPhysics? physics,
  }) : _kind = _CatchTabbedScreenBodyKind.paged,
       _page = null,
       _pages = pages,
       _controller = controller,
       _physics = physics;

  final _CatchTabbedScreenBodyKind _kind;
  final CatchTabbedPageSpec? _page;
  final List<CatchTabbedPageSpec>? _pages;
  final TabController? _controller;
  final ScrollPhysics? _physics;

  Widget _build() {
    assert(
      _kind != _CatchTabbedScreenBodyKind.paged || _pages!.isNotEmpty,
      'CatchTabbedScreenBody.paged requires at least one page.',
    );
    return switch (_kind) {
      _CatchTabbedScreenBodyKind.single => _page!._build(),
      _CatchTabbedScreenBodyKind.paged => TabBarView(
        controller: _controller,
        physics: _physics,
        children: [for (final page in _pages!) page._build()],
      ),
    };
  }
}

/// Canonical root shell for a scroll-away screen title, pinned tab rail, and
/// native horizontally paged tab bodies.
class CatchTabbedScreenScaffold extends StatelessWidget {
  const CatchTabbedScreenScaffold({
    super.key,
    required this.title,
    required this.tabRail,
    required this.body,
    this.eyebrow,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.search,
    this.titleMaxLines = 1,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.outerScrollController,
    this.semanticsLabel,
    this.semanticsHint,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final CatchTopBarSearch? search;
  final int titleMaxLines;
  final CrossAxisAlignment rowCrossAxisAlignment;

  /// Typed tab content for the pinned rail slot.
  ///
  /// The supplied widget may adapt `CatchTabRail` for feature-specific labels
  /// or controller wiring, but it must declare the canonical rail height. This
  /// scaffold validates that contract at runtime and owns the actual pinned
  /// extent so route code cannot introduce local tab geometry.
  final PreferredSizeWidget tabRail;
  final CatchTabbedScreenBody body;
  final ScrollController? outerScrollController;
  final String? semanticsLabel;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    _validateTabRailGeometry();
    final t = CatchTokens.of(context);
    Widget scrollView = NestedScrollView(
      controller: outerScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        final headerTitle = search == null
            ? CatchScreenHeaderTitle.block(
                eyebrow: eyebrow,
                title: title,
                subtitle: subtitle,
                leading: leading,
                actions: actions,
                titleMaxLines: titleMaxLines,
                rowCrossAxisAlignment: rowCrossAxisAlignment,
                padding: CatchInsets.tabbedScreenTitleBlock,
              )
            : CatchScreenTopBar.tabbed(
                context: context,
                eyebrow: eyebrow,
                title: title,
                subtitle: subtitle,
                leading: leading,
                actions: actions,
                titleMaxLines: titleMaxLines,
                rowCrossAxisAlignment: rowCrossAxisAlignment,
                search: search,
              );
        final headerSlivers = CatchSliverHeader(
          title: headerTitle,
          bottomHeight: CatchTabRail.heightFor(context),
          bottom: tabRail,
        ).buildSlivers(context);
        final collapsibleSlivers = headerSlivers.take(headerSlivers.length - 1);
        final pinnedSliver = headerSlivers.last;

        return [
          ...collapsibleSlivers,
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: pinnedSliver,
          ),
        ];
      },
      body: body._build(),
    );

    if (semanticsLabel != null || semanticsHint != null) {
      scrollView = Semantics(
        label: semanticsLabel,
        hint: semanticsHint,
        child: scrollView,
      );
    }

    return CatchScreenScaffold.workspace(
      backgroundColor: t.bg,
      body: SafeArea(bottom: false, child: scrollView),
    );
  }

  void _validateTabRailGeometry() {
    final declaredHeight = tabRail.preferredSize.height;
    if (declaredHeight == CatchLayout.tabRailHeight) return;

    throw FlutterError.fromParts([
      ErrorSummary(
        'CatchTabbedScreenScaffold requires a '
        '${CatchLayout.tabRailHeight}-point tab rail.',
      ),
      ErrorDescription(
        '${tabRail.runtimeType} declared a preferred height of '
        '$declaredHeight points.',
      ),
      ErrorHint(
        'Use CatchTabRail or CatchTabControllerRail, or make the '
        'feature adapter report CatchLayout.tabRailHeight. The scaffold owns '
        'the pinned extent; screens must not define local tab-rail geometry.',
      ),
    ]);
  }
}

/// Inner scroll owner for one page of [CatchTabbedScreenScaffold].
///
/// It preserves the NestedScrollView overlap contract, isolates focus reveal
/// requests from the horizontal pager, owns shell-aware terminal padding, and
/// can center box-content slivers at the canonical readable width without
/// converting sliver-native pages into box layouts.
class CatchTabbedPageScrollView extends StatefulWidget
    implements CatchTabbedPageOwner {
  const CatchTabbedPageScrollView({
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
  final CatchTabbedPageScrollController? scrollStateController;
  final ScrollPhysics? physics;
  final Future<void> Function()? onRefresh;

  @override
  State<CatchTabbedPageScrollView> createState() =>
      _CatchTabbedPageScrollViewState();
}

/// Imperative offset access for a [CatchTabbedPageScrollView].
///
/// The page owns its widget state; consumers that need to preserve an offset
/// across a tab transition use this controller instead of a public `State`
/// subclass or `GlobalKey`.
class CatchTabbedPageScrollController {
  _CatchTabbedPageScrollViewState? _state;

  double? captureOffset() => _state?._captureOffset();

  void restoreOffset(double? savedPixels) =>
      _state?._restoreOffset(savedPixels);

  void _attach(_CatchTabbedPageScrollViewState state) {
    assert(_state == null || identical(_state, state));
    _state = state;
  }

  void _detach(_CatchTabbedPageScrollViewState state) {
    if (identical(_state, state)) _state = null;
  }
}

class _CatchTabbedPageScrollViewState extends State<CatchTabbedPageScrollView>
    with AutomaticKeepAliveClientMixin<CatchTabbedPageScrollView> {
  ScrollController? _effectiveController;

  @override
  void initState() {
    super.initState();
    widget.scrollStateController?._attach(this);
  }

  @override
  void didUpdateWidget(CatchTabbedPageScrollView oldWidget) {
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
                    widget.maxContentExtent ?? CatchLayout.tabbedPageMaxExtent,
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
          return CatchFieldVisibilityScope(
            bottomObstruction: AppShellActiveTab.bottomOverlayInsetOf(context),
            child: refreshed,
          );
        },
      ),
    );
  }
}
