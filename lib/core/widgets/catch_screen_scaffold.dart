import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldVisibilityScope;
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
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
      child: SafeArea(bottom: false, child: scrollView),
    );
  }
}
