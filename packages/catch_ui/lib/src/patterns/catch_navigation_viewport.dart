import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_row_viewport.dart';
import 'package:catch_ui/src/patterns/catch_workspace_pane_scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A level in a route-owned navigation path. The final visible level expands;
/// its ancestors retain the canonical index width.
enum CatchWorkspacePaneMode { directory, editor }

@immutable
final class CatchWorkspacePane {
  const CatchWorkspacePane({
    required this.id,
    required this.child,
    this.mode = CatchWorkspacePaneMode.directory,
  });

  final String id;
  final Widget child;
  final CatchWorkspacePaneMode mode;

  double get ancestorWidth => switch (mode) {
    CatchWorkspacePaneMode.directory => CatchLayout.workspaceDirectoryWidth,
    CatchWorkspacePaneMode.editor => CatchLayout.workspaceEditorWidth,
  };
}

/// Presents the same route path as concurrent columns or one active pane.
///
/// Width never changes the route. Visited ancestors stay mounted (including
/// drafts, tab selection and scroll state), but cannot receive focus or expose
/// semantics. Routes supply the path and the active compact pane; a preview can
/// therefore be visible beside its editor without becoming a Back destination.
class CatchNavigationViewport extends StatefulWidget {
  const CatchNavigationViewport({
    super.key,
    required this.panes,
    this.compactPaneId,
    this.onBack,
  }) : assert(panes.length > 0);

  final List<CatchWorkspacePane> panes;
  final String? compactPaneId;
  final VoidCallback? onBack;

  @override
  State<CatchNavigationViewport> createState() =>
      _CatchNavigationViewportState();
}

class _CatchNavigationViewportState extends State<CatchNavigationViewport> {
  final _visited = <String>{};

  @override
  Widget build(BuildContext context) {
    final viewport = LayoutBuilder(
      builder: (context, constraints) {
        final panes = widget.panes;
        final compactPaneId = widget.compactPaneId;
        final onBack = widget.onBack;
        assert(panes.map((pane) => pane.id).toSet().length == panes.length);
        final compact = compactPaneId == null
            ? panes.length - 1
            : panes.indexWhere((pane) => pane.id == compactPaneId);
        assert(compact >= 0, 'The compact pane must belong to the route path.');
        var visibleCount = 1;
        var requiredWidth = CatchLayout.workspaceDetailMinWidth;
        for (var index = panes.length - 2; index >= 0; index--) {
          requiredWidth += panes[index].ancestorWidth + CatchStroke.hairline;
          if (requiredWidth > constraints.maxWidth) break;
          visibleCount++;
        }
        final first = visibleCount == 1 ? compact : panes.length - visibleCount;
        final last = visibleCount == 1 ? compact : panes.length - 1;
        for (var index = first; index <= last; index++) {
          _visited.add(panes[index].id);
        }
        return PopScope(
          canPop: onBack == null,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) onBack?.call();
          },
          child: CustomMultiChildLayout(
            delegate: _WorkspaceLayout(
              first: first,
              last: last,
              widths: [for (final pane in panes) pane.ancestorWidth],
            ),
            children: [
              for (var index = 0; index < panes.length; index++)
                LayoutId(
                  key: ValueKey(('catch-workspace-pane', panes[index].id)),
                  id: index,
                  child: Offstage(
                    offstage: index < first || index > last,
                    child: TickerMode(
                      enabled: index >= first && index <= last,
                      child: ExcludeFocus(
                        excluding: index < first || index > last,
                        child: CatchWorkspacePaneScope(
                          isSinglePane: visibleCount == 1,
                          child: DecoratedBox(
                            position: DecorationPosition.foreground,
                            decoration: BoxDecoration(
                              border: index > first && index <= last
                                  ? Border(
                                      left: BorderSide(
                                        color: CatchTokens.of(context).line,
                                        width: CatchStroke.hairline,
                                      ),
                                    )
                                  : null,
                            ),
                            child: CatchRowViewport(
                              child: _visited.contains(panes[index].id)
                                  ? panes[index].child
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    return CatchWorkspaceHeaderLayout.contains(context)
        ? viewport
        : CatchWorkspaceHeaderLayout(child: viewport);
  }
}

/// The pane's local presentation, independent of the device's global width.
class CatchWorkspacePaneScope extends InheritedWidget {
  const CatchWorkspacePaneScope({
    super.key,
    required this.isSinglePane,
    required super.child,
  });

  final bool isSinglePane;

  static bool? isSinglePaneOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CatchWorkspacePaneScope>()
      ?.isSinglePane;

  @override
  bool updateShouldNotify(CatchWorkspacePaneScope oldWidget) =>
      isSinglePane != oldWidget.isSinglePane;
}

class _WorkspaceLayout extends MultiChildLayoutDelegate {
  _WorkspaceLayout({
    required this.first,
    required this.last,
    required this.widths,
  });
  final int first;
  final int last;
  final List<double> widths;

  @override
  void performLayout(Size size) {
    var x = 0.0;
    for (var index = 0; index < widths.length; index++) {
      final visible = index >= first && index <= last;
      final width = visible && index < last
          ? widths[index]
          : visible
          ? size.width - x
          : size.width;
      layoutChild(index, BoxConstraints.tight(Size(width, size.height)));
      positionChild(index, Offset(visible ? x : 0, 0));
      if (visible) x += width;
    }
  }

  @override
  bool shouldRelayout(_WorkspaceLayout oldDelegate) =>
      first != oldDelegate.first ||
      last != oldDelegate.last ||
      !listEquals(widths, oldDelegate.widths);
}
