import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_pager_focus_boundary.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

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
  final int titleMaxLines;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final PreferredSizeWidget tabRail;
  final Widget body;
  final ScrollController? outerScrollController;
  final String? semanticsLabel;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    Widget scrollView = NestedScrollView(
      controller: outerScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        final headerSlivers = CatchSliverHeader(
          title: CatchScreenHeaderTitle.block(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            leading: leading,
            actions: actions,
            titleMaxLines: titleMaxLines,
            rowCrossAxisAlignment: rowCrossAxisAlignment,
          ),
          bottomHeight: tabRail.preferredSize.height,
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
      body: body,
    );

    if (semanticsLabel != null || semanticsHint != null) {
      scrollView = Semantics(
        label: semanticsLabel,
        hint: semanticsHint,
        child: scrollView,
      );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(bottom: false, child: scrollView),
    );
  }
}

/// Inner scroll owner for one page of [CatchTabbedScreenScaffold].
///
/// It preserves the NestedScrollView overlap contract, isolates focus reveal
/// requests from the horizontal pager, and owns shell-aware terminal padding.
class CatchTabbedPageScrollView extends StatefulWidget {
  const CatchTabbedPageScrollView({
    super.key,
    required this.scrollKey,
    required this.slivers,
    this.includeTerminalPadding = true,
    this.controller,
    this.physics,
  });

  final PageStorageKey<String> scrollKey;
  final List<Widget> slivers;
  final bool includeTerminalPadding;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  State<CatchTabbedPageScrollView> createState() =>
      _CatchTabbedPageScrollViewState();
}

class _CatchTabbedPageScrollViewState extends State<CatchTabbedPageScrollView>
    with AutomaticKeepAliveClientMixin<CatchTabbedPageScrollView> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CatchPagerFocusBoundary(
      child: Builder(
        builder: (context) {
          return CustomScrollView(
            key: widget.scrollKey,
            controller: widget.controller,
            physics: widget.physics,
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              ...widget.slivers,
              if (widget.includeTerminalPadding)
                const CatchSliverTerminalPadding(),
            ],
          );
        },
      ),
    );
  }
}
