import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_master_detail_pane_builder.dart';
import 'package:flutter/material.dart';

/// Index/detail pane geometry with explicit or local-width split selection.
///
/// The route retains selection and navigation. The adaptive constructor gives
/// its leading builder the same split decision used to lay out the panes.
class CatchMasterDetailViewport extends StatelessWidget {
  const CatchMasterDetailViewport({
    super.key,
    required bool expanded,
    required Widget leading,
    required this.body,
    this.indexPaneWidth = CatchLayout.masterDetailIndexPaneWidth,
  }) : _fixed = (expanded: expanded, leading: leading),
       _adaptive = null;

  const CatchMasterDetailViewport.adaptive({
    super.key,
    required double minimumExpandedWidth,
    required CatchMasterDetailPaneBuilder leadingBuilder,
    required this.body,
    this.indexPaneWidth = CatchLayout.masterDetailIndexPaneWidth,
  }) : _fixed = null,
       _adaptive = (
         minimumExpandedWidth: minimumExpandedWidth,
         leadingBuilder: leadingBuilder,
       );

  final Widget body;
  final double indexPaneWidth;
  final ({bool expanded, Widget leading})? _fixed;
  final ({
    double minimumExpandedWidth,
    CatchMasterDetailPaneBuilder leadingBuilder,
  })?
  _adaptive;

  @override
  Widget build(BuildContext context) {
    final adaptive = _adaptive;
    if (adaptive != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final expanded =
              constraints.maxWidth >= adaptive.minimumExpandedWidth;
          return CatchMasterDetailViewport(
            expanded: expanded,
            leading: adaptive.leadingBuilder(context, expanded),
            body: body,
            indexPaneWidth: indexPaneWidth,
          );
        },
      );
    }
    final fixed = _fixed!;
    if (!fixed.expanded) return fixed.leading;
    final tokens = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: indexPaneWidth, child: fixed.leading),
        VerticalDivider(
          key: const ValueKey('catch-master-detail-divider'),
          width: CatchStroke.hairline,
          thickness: CatchStroke.hairline,
          color: tokens.line,
        ),
        Expanded(child: body),
      ],
    );
  }
}
