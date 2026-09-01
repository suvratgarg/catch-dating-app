import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

typedef CatchMasterDetailPaneBuilder =
    Widget Function(BuildContext context, bool expanded);

/// Shared geometry for route-owned master-detail workspaces.
///
/// The route decides whether the current page context is expanded and owns
/// selection. This primitive owns only the index width, divider, and pane
/// composition so feature screens cannot drift from one another.
class CatchMasterDetailLayout extends StatelessWidget {
  const CatchMasterDetailLayout({
    super.key,
    required this.expanded,
    required this.master,
    required this.detail,
    this.indexPaneWidth = CatchLayout.masterDetailIndexPaneWidth,
  });

  final bool expanded;
  final Widget master;
  final Widget detail;
  final double indexPaneWidth;

  @override
  Widget build(BuildContext context) {
    if (!expanded) return master;
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: indexPaneWidth, child: master),
        VerticalDivider(
          key: const ValueKey('catch-master-detail-divider'),
          width: CatchStroke.hairline,
          thickness: CatchStroke.hairline,
          color: t.line,
        ),
        Expanded(child: detail),
      ],
    );
  }
}

/// Constraint-owned adaptive wrapper for [CatchMasterDetailLayout].
///
/// Use this when shell navigation changes the route body's usable width. The
/// master builder receives the resolved split state so the route can choose
/// adjacent-detail or pushed-route navigation without measuring locally.
class CatchAdaptiveMasterDetailLayout extends StatelessWidget {
  const CatchAdaptiveMasterDetailLayout({
    super.key,
    required this.minimumExpandedWidth,
    required this.masterBuilder,
    required this.detail,
    this.indexPaneWidth = CatchLayout.masterDetailIndexPaneWidth,
  });

  final double minimumExpandedWidth;
  final CatchMasterDetailPaneBuilder masterBuilder;
  final Widget detail;
  final double indexPaneWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= minimumExpandedWidth;
        return CatchMasterDetailLayout(
          expanded: expanded,
          master: masterBuilder(context, expanded),
          detail: detail,
          indexPaneWidth: indexPaneWidth,
        );
      },
    );
  }
}
