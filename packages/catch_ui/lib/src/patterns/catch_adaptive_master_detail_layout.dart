import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_master_detail_layout.dart';
import 'package:catch_ui/src/patterns/catch_master_detail_pane_builder.dart';
import 'package:flutter/material.dart';

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
