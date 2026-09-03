import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldVisibilityScope;
import 'package:catch_dating_app/core/widgets/catch_scaled_preferred_size.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';

/// Safe-area ownership for canonical full-screen composition families.
enum CatchScreenSafeArea { all, top, none }

/// Canonical surface owner for full-screen compositions.
///
/// Named constructors make the route role explicit while this widget keeps
/// background, keyboard resize, and safe-area mechanics out of features.
/// Root-title, tabbed, and pushed-route shells use [workspace] because their
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
    final child = switch (safeArea) {
      CatchScreenSafeArea.all => SafeArea(child: body),
      CatchScreenSafeArea.top => SafeArea(bottom: false, child: body),
      CatchScreenSafeArea.none => body,
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

/// Full-screen owner for a root destination with scroll-content title chrome.
///
/// Root feature screens provide semantic header content and body slivers. This
/// scaffold owns the page surface, safe area, vertical scroll owner, body
/// geometry, responsive content lane, field obstruction, refresh behavior,
/// and terminal clearance above adaptive shell navigation.
class CatchRootScreenScaffold extends StatelessWidget {
  const CatchRootScreenScaffold({
    super.key,
    required this.header,
    required this.bodyLayout,
    required this.slivers,
    this.scrollKey,
    this.controller,
    this.physics,
    this.primary,
    this.onRefresh,
    this.constrainToContentWidth = false,
    this.maxContentExtent = CatchLayout.tabbedPageMaxExtent,
    this.includeTerminalPadding = true,
    this.terminalExtra = CatchSpacing.screenPb,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenTopEdge.safeArea,
  }) : assert(slivers.length > 0),
       assert(maxContentExtent > 0),
       assert(terminalExtra >= 0);

  final Widget header;
  final CatchScreenBodyLayout bodyLayout;
  final List<Widget> slivers;
  final Key? scrollKey;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool? primary;
  final Future<void> Function()? onRefresh;
  final bool constrainToContentWidth;
  final double maxContentExtent;
  final bool includeTerminalPadding;
  final double terminalExtra;
  final String? semanticsLabel;
  final String? semanticsHint;
  final CatchRootScreenTopEdge topEdge;

  @override
  Widget build(BuildContext context) {
    return CatchScreenScaffold.workspace(
      body: CatchRootScreenScrollView(
        header: header,
        bodyLayout: bodyLayout,
        slivers: slivers,
        scrollKey: scrollKey,
        controller: controller,
        physics: physics,
        primary: primary,
        onRefresh: onRefresh,
        constrainToContentWidth: constrainToContentWidth,
        maxContentExtent: maxContentExtent,
        includeTerminalPadding: includeTerminalPadding,
        terminalExtra: terminalExtra,
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
  const CatchRootScreenScrollView({
    super.key,
    required this.header,
    required this.bodyLayout,
    required this.slivers,
    this.scrollKey,
    this.controller,
    this.physics,
    this.primary,
    this.onRefresh,
    this.constrainToContentWidth = false,
    this.maxContentExtent = CatchLayout.tabbedPageMaxExtent,
    this.includeTerminalPadding = true,
    this.terminalExtra = CatchSpacing.screenPb,
    this.semanticsLabel,
    this.semanticsHint,
    this.topEdge = CatchRootScreenTopEdge.safeArea,
  }) : assert(slivers.length > 0),
       assert(maxContentExtent > 0),
       assert(terminalExtra >= 0);

  final Widget header;
  final CatchScreenBodyLayout bodyLayout;
  final List<Widget> slivers;
  final Key? scrollKey;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool? primary;
  final Future<void> Function()? onRefresh;
  final bool constrainToContentWidth;
  final double maxContentExtent;
  final bool includeTerminalPadding;
  final double terminalExtra;
  final String? semanticsLabel;
  final String? semanticsHint;
  final CatchRootScreenTopEdge topEdge;

  @override
  Widget build(BuildContext context) {
    final obstruction = AppShellActiveTab.bottomOverlayInsetOf(context);
    Widget scrollView = CustomScrollView(
      key: scrollKey,
      controller: controller,
      primary: primary,
      physics: onRefresh == null
          ? physics
          : AlwaysScrollableScrollPhysics(parent: physics),
      slivers: [
        SliverToBoxAdapter(child: header),
        CatchSliverScreenBody(
          layout: bodyLayout,
          constrainToContentWidth: constrainToContentWidth,
          maxContentExtent: maxContentExtent,
          slivers: slivers,
        ),
        if (includeTerminalPadding)
          CatchSliverTerminalPadding(extra: terminalExtra),
      ],
    );
    if (onRefresh != null) {
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
    return CatchFieldVisibilityScope(
      bottomObstruction: obstruction,
      child: SafeArea(
        top: topEdge == CatchRootScreenTopEdge.safeArea,
        bottom: false,
        child: scrollView,
      ),
    );
  }
}
