// ignore_for_file: prefer_initializing_formals

import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldVisibilityScope;
import 'package:catch_dating_app/core/widgets/catch_root_screen_body.dart';
import 'package:catch_dating_app/core/widgets/catch_scaled_preferred_size.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_status_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/widgets/catch_root_screen_body.dart'
    show
        CatchRootScreenBody,
        CatchRootScreenPageOwner,
        CatchRootScreenPageScrollController,
        CatchRootScreenPageScrollView,
        CatchRootScreenPageSpec;

/// Safe-area ownership for canonical full-screen composition families.
enum CatchScreenSafeArea { all, top, none }

/// Canonical surface owner for full-screen compositions.
///
/// Named constructors make the route role explicit while this widget keeps
/// background, keyboard resize, and safe-area mechanics out of features.
/// Root-title, primary-rail, and pushed-route shells use [workspace] because their
/// nested owner already applies the appropriate insets.
class CatchScreenScaffold extends StatelessWidget {
  const CatchScreenScaffold.standalone({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.safeArea = CatchScreenSafeArea.all,
    this.extendBody = false,
  }) : appBar = null,
       bottomNavigationBar = null;

  const CatchScreenScaffold.stepFlow({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.safeArea = CatchScreenSafeArea.all,
    this.extendBody = false,
  }) : appBar = null,
       bottomNavigationBar = null;

  const CatchScreenScaffold.workspace({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.appBar,
    this.bottomNavigationBar,
    this.extendBody = false,
  }) : safeArea = CatchScreenSafeArea.none;

  final Key? scaffoldKey;
  final Widget body;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final CatchScreenSafeArea safeArea;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final statuses = CatchStatusStripScope.of(context);
    // Keep this ancestry stable when connectivity changes: inserting a new
    // wrapper only while offline would recreate focused editors and state.
    final content = safeArea == CatchScreenSafeArea.none
        ? body
        : CatchStatusStripScope(
            statuses: const [],
            child: Column(
              children: [
                CatchStatusStrip(statuses: statuses),
                Expanded(child: body),
              ],
            ),
          );
    final child = switch (safeArea) {
      CatchScreenSafeArea.all => SafeArea(child: content),
      CatchScreenSafeArea.top => SafeArea(bottom: false, child: content),
      CatchScreenSafeArea.none => content,
    };
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor ?? CatchTokens.of(context).bg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      appBar: switch (appBar) {
        final CatchScaledPreferredSize scaled => PreferredSize(
          preferredSize: scaled.preferredSizeFor(context),
          child: scaled,
        ),
        final bar => bar,
      },
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }
}

/// Declares which owner consumes the physical top safe-area inset.
enum CatchRootScreenTopEdge {
  /// The canonical root scroll owner keeps all content below the safe area.
  safeArea,

  /// An edge-to-edge header paints behind system chrome and applies its own
  /// safe-area padding to interactive content.
  headerOwned,
}

enum _CatchRootScreenHeaderKind { custom, title }

/// Closed header specification for a root screen with a pinned primary rail.
///
/// Most destinations use [title], which preserves the shared compact
/// title-to-rail handoff. Edge-to-edge destinations such as Explore use
/// [custom] while retaining the same root scroll and pinning owner.
final class CatchRootScreenHeader {
  const CatchRootScreenHeader.custom(Widget header)
    : _kind = _CatchRootScreenHeaderKind.custom,
      _header = header,
      _title = null,
      _eyebrow = null,
      _subtitle = null,
      _leading = null,
      _actions = const <Widget>[],
      _search = null,
      _titleMaxLines = 1,
      _rowCrossAxisAlignment = CrossAxisAlignment.center;

  const CatchRootScreenHeader.title({
    required String title,
    String? eyebrow,
    String? subtitle,
    Widget? leading,
    List<Widget> actions = const <Widget>[],
    CatchTopBarSearch? search,
    int titleMaxLines = 1,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.center,
  }) : _kind = _CatchRootScreenHeaderKind.title,
       _header = null,
       _title = title,
       _eyebrow = eyebrow,
       _subtitle = subtitle,
       _leading = leading,
       _actions = actions,
       _search = search,
       _titleMaxLines = titleMaxLines,
       _rowCrossAxisAlignment = rowCrossAxisAlignment;

  final _CatchRootScreenHeaderKind _kind;
  final Widget? _header;
  final String? _title;
  final String? _eyebrow;
  final String? _subtitle;
  final Widget? _leading;
  final List<Widget> _actions;
  final CatchTopBarSearch? _search;
  final int _titleMaxLines;
  final CrossAxisAlignment _rowCrossAxisAlignment;

  Widget _build(BuildContext context) {
    if (_kind == _CatchRootScreenHeaderKind.custom) return _header!;
    if (_search == null) {
      return CatchScreenHeaderTitle.block(
        eyebrow: _eyebrow,
        title: _title!,
        subtitle: _subtitle,
        leading: _leading,
        actions: _actions,
        titleMaxLines: _titleMaxLines,
        rowCrossAxisAlignment: _rowCrossAxisAlignment,
        padding: CatchInsets.primaryRailTitleBlock,
      );
    }
    return CatchScreenTopBar.primaryRail(
      context: context,
      eyebrow: _eyebrow,
      title: _title!,
      subtitle: _subtitle,
      leading: _leading,
      actions: _actions,
      titleMaxLines: _titleMaxLines,
      rowCrossAxisAlignment: _rowCrossAxisAlignment,
      search: _search,
    );
  }
}

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
       bodyLayout = CatchScreenBodyLayout.standard,
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
       bodyLayout = CatchScreenBodyLayout.fullBleed,
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
      body: CatchRootScreenScrollView._(
        header: _header!,
        bodyLayout: bodyLayout!,
        slivers: slivers!,
        scrollKey: scrollKey,
        controller: controller,
        physics: physics,
        primary: primary,
        onRefresh: onRefresh,
        constrainToContentWidth: constrainToContentWidth,
        maxContentExtent: maxContentExtent,
        semanticsLabel: semanticsLabel,
        semanticsHint: semanticsHint,
        topEdge: topEdge,
      ),
    );
  }
}

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

  const CatchRootScreenScrollView._({
    required Widget header,
    required this.bodyLayout,
    required List<Widget> slivers,
    this.scrollKey,
    this.controller,
    this.physics,
    this.primary,
    this.onRefresh,
    required this.constrainToContentWidth,
    required this.maxContentExtent,
    this.semanticsLabel,
    this.semanticsHint,
    required this.topEdge,
  }) : _header = header,
       _primaryRailHeader = null,
       slivers = slivers,
       primaryRail = null,
       body = null,
       assert(slivers.length > 0),
       assert(maxContentExtent > 0);

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
    final obstruction = AppShellActiveTab.bottomOverlayInsetOf(context);
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
      _validatePrimaryRailGeometry();
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
                        height: CatchTabRail.heightFor(context),
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

  void _validatePrimaryRailGeometry() {
    final declaredHeight = primaryRail!.preferredSize.height;
    if (declaredHeight == CatchLayout.tabRailHeight) return;

    throw FlutterError.fromParts([
      ErrorSummary(
        'CatchRootScreenScaffold requires a '
        '${CatchLayout.tabRailHeight}-point primary rail.',
      ),
      ErrorDescription(
        '${primaryRail.runtimeType} declared a preferred height of '
        '$declaredHeight points.',
      ),
      ErrorHint(
        'Use CatchTabRail or CatchTabControllerRail, or make the feature '
        'adapter report CatchLayout.tabRailHeight. The root scaffold owns the '
        'pinned extent; screens must not define local rail geometry.',
      ),
    ]);
  }
}
