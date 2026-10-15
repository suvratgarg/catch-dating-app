import 'package:catch_ui/src/components/catch_page_tab_bar.dart';
import 'package:catch_ui/src/components/catch_primary_rail.dart';
import 'package:catch_ui/src/patterns/catch_navigation_viewport.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

part 'catch_workspace_header_layout.dart';

/// One full-height pane: its header and peer controls stay beside its siblings,
/// while only its own body scrolls. Header rhythm is shared with untabbed panes.
class CatchWorkspacePaneScaffold extends StatelessWidget {
  const CatchWorkspacePaneScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  final Widget title;
  final CatchPrimaryRail? actions;
  final Widget body;

  @override
  Widget build(BuildContext context) => CatchWorkspacePaneScope(
    isSinglePane: CatchWorkspacePaneScope.isSinglePaneOf(context) ?? true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchWorkspaceHeader(child: title),
        if (actions != null)
          SizedBox(
            height: switch (actions) {
              final CatchScaledPreferredSize scaled =>
                scaled.preferredSizeFor(context).height,
              _ => CatchPageTabBar.heightFor(context),
            },
            child: actions,
          ),
        Expanded(child: body),
      ],
    ),
  );
}
