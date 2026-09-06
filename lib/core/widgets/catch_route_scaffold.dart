// ignore_for_file: prefer_initializing_formals

import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldVisibilityScope;
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_status_strip.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

typedef CatchRouteTopBarBuilder =
    PreferredSizeWidget Function(BuildContext context, bool scrolledUnder);

enum _CatchRouteBodyKind {
  standard,
  standardSlivers,
  standardSections,
  paged,
  fullBleed,
}

/// Closed body specification for [CatchRouteScaffold].
///
/// Standard variants own the canonical 20 point horizontal gutter and 16
/// point top rhythm. The explicit full-bleed variant preserves intrinsically
/// edge-owned canvases. Route features provide content, never local padding.
final class CatchRouteBody {
  const CatchRouteBody.standard({
    required Widget child,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
  }) : this._standard(
         child: child,
         scrollable: true,
         constrainToContentWidth: false,
         maxContentExtent: CatchLayout.maxContentWidth,
         controller: controller,
         physics: physics,
         primary: primary,
       );

  const CatchRouteBody.standardViewport({
    required Widget child,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
  }) : this._standard(
         child: child,
         scrollable: false,
         constrainToContentWidth: false,
         maxContentExtent: CatchLayout.maxContentWidth,
         controller: controller,
         physics: physics,
         primary: primary,
       );

  const CatchRouteBody.standardConstrained({
    required Widget child,
    double maxContentExtent = CatchLayout.maxContentWidth,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
  }) : this._standard(
         child: child,
         scrollable: true,
         constrainToContentWidth: true,
         maxContentExtent: maxContentExtent,
         controller: controller,
         physics: physics,
         primary: primary,
       );

  const CatchRouteBody._standard({
    required Widget child,
    required bool scrollable,
    required bool constrainToContentWidth,
    required double maxContentExtent,
    required ScrollController? controller,
    required ScrollPhysics? physics,
    required bool? primary,
  }) : assert(maxContentExtent > 0),
       _kind = _CatchRouteBodyKind.standard,
       _child = child,
       _slivers = null,
       _sections = null,
       _pages = null,
       _tabController = null,
       _scrollable = scrollable,
       _constrainToContentWidth = constrainToContentWidth,
       _maxContentExtent = maxContentExtent,
       _controller = controller,
       _physics = physics,
       _primary = primary,
       _includeTerminalPadding = false,
       _onRefresh = null,
       _sectionGap = CatchGaps.section,
       _columnGap = CatchGaps.section,
       _sectionComposition = CatchResponsiveSectionComposition.centered;

  const CatchRouteBody.standardSlivers({
    required List<Widget> slivers,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
    Future<void> Function()? onRefresh,
  }) : this._standardSlivers(
         slivers: slivers,
         constrainToContentWidth: false,
         maxContentExtent: CatchLayout.screenPageMaxExtent,
         controller: controller,
         physics: physics,
         primary: primary,
         onRefresh: onRefresh,
       );

  const CatchRouteBody.standardConstrainedSlivers({
    required List<Widget> slivers,
    double maxContentExtent = CatchLayout.screenPageMaxExtent,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
    Future<void> Function()? onRefresh,
  }) : this._standardSlivers(
         slivers: slivers,
         constrainToContentWidth: true,
         maxContentExtent: maxContentExtent,
         controller: controller,
         physics: physics,
         primary: primary,
         onRefresh: onRefresh,
       );

  const CatchRouteBody._standardSlivers({
    required List<Widget> slivers,
    required bool constrainToContentWidth,
    required double maxContentExtent,
    required ScrollController? controller,
    required ScrollPhysics? physics,
    required bool? primary,
    required Future<void> Function()? onRefresh,
  }) : assert(maxContentExtent > 0),
       _kind = _CatchRouteBodyKind.standardSlivers,
       _child = null,
       _slivers = slivers,
       _sections = null,
       _pages = null,
       _tabController = null,
       _scrollable = true,
       _constrainToContentWidth = constrainToContentWidth,
       _maxContentExtent = maxContentExtent,
       _controller = controller,
       _physics = physics,
       _primary = primary,
       _includeTerminalPadding = true,
       _onRefresh = onRefresh,
       _sectionGap = CatchGaps.section,
       _columnGap = CatchGaps.section,
       _sectionComposition = CatchResponsiveSectionComposition.centered;

  const CatchRouteBody.standardSections({
    required List<CatchResponsiveSectionItem> sections,
    CatchResponsiveSectionComposition composition =
        CatchResponsiveSectionComposition.centered,
    double sectionGap = CatchGaps.section,
    double columnGap = CatchGaps.section,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
  }) : _kind = _CatchRouteBodyKind.standardSections,
       _child = null,
       _slivers = null,
       _sections = sections,
       _pages = null,
       _tabController = null,
       _scrollable = true,
       _constrainToContentWidth = false,
       _maxContentExtent = CatchLayout.maxContentWidth,
       _controller = controller,
       _physics = physics,
       _primary = primary,
       _includeTerminalPadding = true,
       _onRefresh = null,
       _sectionGap = sectionGap,
       _columnGap = columnGap,
       _sectionComposition = composition;

  const CatchRouteBody.paged({
    required TabController controller,
    required List<CatchRouteBody> pages,
  }) : _kind = _CatchRouteBodyKind.paged,
       _child = null,
       _slivers = null,
       _sections = null,
       _pages = pages,
       _tabController = controller,
       _scrollable = true,
       _constrainToContentWidth = false,
       _maxContentExtent = CatchLayout.maxContentWidth,
       _controller = null,
       _physics = null,
       _primary = null,
       _includeTerminalPadding = false,
       _onRefresh = null,
       _sectionGap = CatchGaps.section,
       _columnGap = CatchGaps.section,
       _sectionComposition = CatchResponsiveSectionComposition.centered;

  const CatchRouteBody.fullBleed({required Widget child})
    : _kind = _CatchRouteBodyKind.fullBleed,
      _child = child,
      _slivers = null,
      _sections = null,
      _pages = null,
      _tabController = null,
      _scrollable = false,
      _constrainToContentWidth = false,
      _maxContentExtent = CatchLayout.maxContentWidth,
      _controller = null,
      _physics = null,
      _primary = null,
      _includeTerminalPadding = false,
      _onRefresh = null,
      _sectionGap = CatchGaps.section,
      _columnGap = CatchGaps.section,
      _sectionComposition = CatchResponsiveSectionComposition.centered;

  final _CatchRouteBodyKind _kind;
  final Widget? _child;
  final List<Widget>? _slivers;
  final List<CatchResponsiveSectionItem>? _sections;
  final List<CatchRouteBody>? _pages;
  final TabController? _tabController;
  final bool _scrollable;
  final bool _constrainToContentWidth;
  final double _maxContentExtent;
  final ScrollController? _controller;
  final ScrollPhysics? _physics;
  final bool? _primary;
  final bool _includeTerminalPadding;
  final Future<void> Function()? _onRefresh;
  final double _sectionGap;
  final double _columnGap;
  final CatchResponsiveSectionComposition _sectionComposition;

  Widget _build(BuildContext context) {
    assert(
      _kind != _CatchRouteBodyKind.standardSlivers || _slivers!.isNotEmpty,
      'CatchRouteBody.standardSlivers requires at least one sliver.',
    );
    assert(
      _kind != _CatchRouteBodyKind.paged || _pages!.isNotEmpty,
      'CatchRouteBody.paged requires at least one page.',
    );
    return switch (_kind) {
      _CatchRouteBodyKind.standard => _buildStandard(context),
      _CatchRouteBodyKind.standardSlivers => _buildStandardSlivers(context),
      _CatchRouteBodyKind.standardSections => SafeArea(
        top: false,
        bottom: false,
        child: CatchResponsiveSectionPage(
          sections: _sections!,
          composition: _sectionComposition,
          sectionGap: _sectionGap,
          columnGap: _columnGap,
          controller: _controller,
          physics: _physics,
          primary: _primary,
        ),
      ),
      _CatchRouteBodyKind.paged => TabBarView(
        controller: _tabController,
        children: [for (final page in _pages!) page._build(context)],
      ),
      _CatchRouteBodyKind.fullBleed => _child!,
    };
  }

  Widget _buildStandard(BuildContext context) {
    Widget child = _child!;
    if (_constrainToContentWidth) {
      child = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxContentExtent),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
    }
    final bottomObstruction = AppShellActiveTab.bottomOverlayInsetOf(context);
    final terminalClearance = AppShellActiveTab.scrollTerminalClearanceOf(
      context,
      extra: CatchSpacing.screenPb,
    );
    return CatchFieldVisibilityScope(
      bottomObstruction: bottomObstruction,
      child: SafeArea(
        top: false,
        bottom: false,
        child: CatchScreenBody(
          pb: terminalClearance,
          scrollable: _scrollable,
          controller: _controller,
          physics: _physics,
          primary: _primary,
          child: child,
        ),
      ),
    );
  }

  Widget _buildStandardSlivers(BuildContext context) {
    Widget scrollView = CustomScrollView(
      controller: _controller,
      primary: _primary,
      physics: _onRefresh == null
          ? _physics
          : AlwaysScrollableScrollPhysics(parent: _physics),
      slivers: [
        CatchSliverScreenBody(
          layout: CatchScreenBodyLayout.standard,
          constrainToContentWidth: _constrainToContentWidth,
          maxContentExtent: _maxContentExtent,
          slivers: _slivers!,
        ),
        if (_includeTerminalPadding) const CatchSliverTerminalPadding(),
      ],
    );
    if (_onRefresh != null) {
      scrollView = RefreshIndicator.adaptive(
        onRefresh: _onRefresh,
        child: scrollView,
      );
    }
    return CatchFieldVisibilityScope(
      bottomObstruction: AppShellActiveTab.bottomOverlayInsetOf(context),
      child: SafeArea(top: false, bottom: false, child: scrollView),
    );
  }
}

/// Canonical shell for pushed utility, list, and identity routes.
///
/// The shell owns the route surface and scroll-under divider so callers cannot
/// independently choose competing background/border behavior. Root tab screens
/// keep using sliver headers because their title is part of the scroll content.
class CatchRouteScaffold extends StatefulWidget {
  const CatchRouteScaffold({
    super.key,
    required this.topBarBuilder,
    required this.body,
    this.statuses = const [],
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final CatchRouteTopBarBuilder topBarBuilder;
  final CatchRouteBody body;
  final List<CatchStatusStripData> statuses;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  State<CatchRouteScaffold> createState() => _CatchRouteScaffoldState();
}

class _CatchRouteScaffoldState extends State<CatchRouteScaffold> {
  bool _scrolledUnder = false;

  bool _handleScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final scrolledUnder = notification.metrics.extentBefore > 0;
    if (scrolledUnder != _scrolledUnder) {
      setState(() => _scrolledUnder = scrolledUnder);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.backgroundColor ?? CatchTokens.of(context).bg;
    final statuses = [...widget.statuses, ...CatchStatusStripScope.of(context)];
    return CatchStatusStripScope(
      statuses: const [],
      child: CatchScreenScaffold.workspace(
        backgroundColor: background,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        appBar: widget.topBarBuilder(context, _scrolledUnder),
        bottomNavigationBar: widget.bottomNavigationBar,
        body: NotificationListener<ScrollNotification>(
          onNotification: _handleScroll,
          child: Column(
            children: [
              CatchStatusStrip(statuses: statuses),
              Expanded(child: widget.body._build(context)),
            ],
          ),
        ),
      ),
    );
  }
}
