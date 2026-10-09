import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_row_viewport.dart';
import 'package:catch_ui/src/patterns/catch_workspace_pane_scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A level in a route-owned navigation path. Width defaults are semantic;
/// users may resize columns without changing the path.
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
    this.resizeLabel,
    this.contributionOnly = false,
  }) : assert(panes.length > 0),
       assert(!contributionOnly || panes.length == 1);

  final List<CatchWorkspacePane> panes;
  final String? compactPaneId;
  final VoidCallback? onBack;
  final String? resizeLabel;

  /// A content contribution whose physical geometry is owned by an enclosing
  /// viewport. Adapters use this for routed editors with a lifted preview.
  final bool contributionOnly;

  @override
  State<CatchNavigationViewport> createState() =>
      _CatchNavigationViewportState();
}

class _CatchNavigationViewportState extends State<CatchNavigationViewport> {
  final _visited = <String>{};
  final _widths = <String, double>{};
  final _scroll = ScrollController();
  String? _revealedPane;
  bool _revealScheduled = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _revealSelection(bool expanded) {
    final selected = widget.compactPaneId ?? widget.panes.last.id;
    if (!expanded) {
      _revealedPane = null;
      return;
    }
    if (_revealedPane == selected || _revealScheduled) return;
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (!mounted || !_scroll.hasClients) return;
      _revealedPane = selected;
      final index = widget.panes.indexWhere((pane) => pane.id == selected);
      final offset = widget.panes
          .take(index)
          .fold<double>(
            0,
            (sum, pane) => sum + (_widths[pane.id] ?? pane.ancestorWidth),
          );
      _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    // A single content contribution has no column geometry. In particular a
    // routed editor can contribute its preview to an enclosing viewport while
    // preserving its content under this same primitive, without nesting scrolls.
    if (widget.contributionOnly) return widget.panes.single.child;
    final viewport = LayoutBuilder(
      builder: (context, constraints) {
        final panes = widget.panes;
        assert(panes.map((pane) => pane.id).toSet().length == panes.length);
        final compact = widget.compactPaneId == null
            ? panes.length - 1
            : panes.indexWhere((pane) => pane.id == widget.compactPaneId);
        assert(compact >= 0, 'The compact pane must belong to the route path.');
        final expanded =
            constraints.maxWidth >=
            CatchLayout.workspaceDirectoryWidth +
                CatchLayout.workspaceDetailMinWidth;
        _visited.removeWhere((id) => !panes.any((pane) => pane.id == id));
        _widths.removeWhere((id, _) => !panes.any((pane) => pane.id == id));
        final widths = <double>[];
        var preceding = 0.0;
        for (var index = 0; index < panes.length; index++) {
          final pane = panes[index];
          final preferred =
              _widths[pane.id] ??
              (index == panes.length - 1
                  ? (constraints.maxWidth - preceding).clamp(
                      CatchLayout.workspaceDetailMinWidth,
                      double.infinity,
                    )
                  : pane.ancestorWidth);
          widths.add(expanded ? preferred : constraints.maxWidth);
          if (index < panes.length - 1) preceding += preferred;
          if (expanded || index == compact) _visited.add(pane.id);
        }
        final stripWidth = expanded
            ? widths
                  .fold<double>(0, (sum, width) => sum + width)
                  .clamp(constraints.maxWidth, double.infinity)
            : constraints.maxWidth;
        _revealSelection(expanded);
        final t = CatchTokens.of(context);
        return PopScope(
          canPop: widget.onBack == null,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) widget.onBack?.call();
          },
          child: Scrollbar(
            controller: _scroll,
            thumbVisibility: expanded,
            interactive: expanded,
            notificationPredicate: (notice) => notice.depth == 0,
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: expanded ? null : const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: stripWidth,
                height: constraints.maxHeight,
                child: AnimatedBuilder(
                  animation: _scroll,
                  builder: (context, _) => CustomMultiChildLayout(
                    delegate: _WorkspaceLayout(
                      expanded: expanded,
                      compact: compact,
                      widths: widths,
                      direction: Directionality.of(context),
                    ),
                    children: [
                      for (var index = 0; index < panes.length; index++)
                        LayoutId(
                          key: ValueKey((
                            'catch-workspace-pane',
                            panes[index].id,
                          )),
                          id: index,
                          child: Offstage(
                            offstage: !expanded && index != compact,
                            child: TickerMode(
                              enabled: expanded
                                  ? _intersectsViewport(
                                      index,
                                      widths,
                                      constraints.maxWidth,
                                    )
                                  : index == compact,
                              child: ExcludeFocus(
                                excluding: !expanded && index != compact,
                                child: CatchWorkspacePaneScope(
                                  isSinglePane: !expanded,
                                  participatesInHeaderAlignment: !expanded
                                      ? index == compact
                                      : _intersectsViewport(
                                          index,
                                          widths,
                                          constraints.maxWidth,
                                        ),
                                  child: DecoratedBox(
                                    position: DecorationPosition.foreground,
                                    decoration: BoxDecoration(
                                      border: expanded && index > 0
                                          ? BorderDirectional(
                                              start: BorderSide(
                                                color: t.line,
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
                      if (expanded)
                        for (var index = 0; index < panes.length; index++)
                          LayoutId(
                            id: ('divider', index),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeColumn,
                              child: Focus(
                                onKeyEvent: (_, event) {
                                  if (event is! KeyDownEvent &&
                                      event is! KeyRepeatEvent) {
                                    return KeyEventResult.ignored;
                                  }
                                  final direction =
                                      event.logicalKey ==
                                          LogicalKeyboardKey.arrowLeft
                                      ? -1
                                      : event.logicalKey ==
                                            LogicalKeyboardKey.arrowRight
                                      ? 1
                                      : 0;
                                  if (direction == 0) {
                                    return KeyEventResult.ignored;
                                  }
                                  _resize(
                                    panes[index],
                                    widths[index],
                                    direction *
                                        CatchSpacing.s4 *
                                        (Directionality.of(context) ==
                                                TextDirection.rtl
                                            ? -1
                                            : 1),
                                    constraints.maxWidth,
                                  );
                                  return KeyEventResult.handled;
                                },
                                child: Semantics(
                                  label: widget.resizeLabel,
                                  value: widths[index].round().toString(),
                                  increasedValue: _boundedWidth(
                                    widths[index] + CatchSpacing.s4,
                                    constraints.maxWidth,
                                  ).round().toString(),
                                  decreasedValue: _boundedWidth(
                                    widths[index] - CatchSpacing.s4,
                                    constraints.maxWidth,
                                  ).round().toString(),
                                  onIncrease: () => _resize(
                                    panes[index],
                                    widths[index],
                                    CatchSpacing.s4,
                                    constraints.maxWidth,
                                  ),
                                  onDecrease: () => _resize(
                                    panes[index],
                                    widths[index],
                                    -CatchSpacing.s4,
                                    constraints.maxWidth,
                                  ),
                                  child: GestureDetector(
                                    key: ValueKey((
                                      'catch-workspace-divider',
                                      panes[index].id,
                                    )),
                                    behavior: HitTestBehavior.opaque,
                                    onDoubleTap: () => setState(
                                      () => _widths.remove(panes[index].id),
                                    ),
                                    onHorizontalDragUpdate: (details) =>
                                        _resize(
                                          panes[index],
                                          _widths[panes[index].id] ??
                                              widths[index],
                                          Directionality.of(context) ==
                                                  TextDirection.rtl
                                              ? -details.delta.dx
                                              : details.delta.dx,
                                          constraints.maxWidth,
                                        ),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    return CatchWorkspaceHeaderLayout.contains(context)
        ? viewport
        : CatchWorkspaceHeaderLayout(child: viewport);
  }

  bool _intersectsViewport(
    int index,
    List<double> widths,
    double viewportWidth,
  ) {
    final start = widths
        .take(index)
        .fold<double>(0, (sum, width) => sum + width);
    final offset = _scroll.hasClients ? _scroll.offset : 0.0;
    return start + widths[index] > offset && start < offset + viewportWidth;
  }

  double _boundedWidth(double width, double viewportWidth) => width.clamp(
    CatchLayout.workspaceDetailMinWidth,
    viewportWidth.clamp(CatchLayout.workspaceEditorWidth, double.infinity),
  );

  void _resize(
    CatchWorkspacePane pane,
    double width,
    double delta,
    double viewportWidth,
  ) {
    setState(
      () => _widths[pane.id] = _boundedWidth(width + delta, viewportWidth),
    );
  }
}

/// The pane's local presentation, independent of the device's global width.
class CatchWorkspacePaneScope extends InheritedWidget {
  const CatchWorkspacePaneScope({
    super.key,
    required this.isSinglePane,
    this.participatesInHeaderAlignment = true,
    required super.child,
  });

  final bool isSinglePane;
  final bool participatesInHeaderAlignment;

  static bool participatesInHeaderAlignmentOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchWorkspacePaneScope>()
          ?.participatesInHeaderAlignment ??
      true;

  static bool? isSinglePaneOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CatchWorkspacePaneScope>()
      ?.isSinglePane;

  @override
  bool updateShouldNotify(CatchWorkspacePaneScope oldWidget) =>
      isSinglePane != oldWidget.isSinglePane ||
      participatesInHeaderAlignment != oldWidget.participatesInHeaderAlignment;
}

class _WorkspaceLayout extends MultiChildLayoutDelegate {
  _WorkspaceLayout({
    required this.expanded,
    required this.compact,
    required this.widths,
    required this.direction,
  });
  final TextDirection direction;
  final bool expanded;
  final int compact;
  final List<double> widths;

  @override
  void performLayout(Size size) {
    var x = 0.0;
    for (var index = 0; index < widths.length; index++) {
      layoutChild(
        index,
        BoxConstraints.tight(Size(widths[index], size.height)),
      );
      positionChild(
        index,
        Offset(
          expanded
              ? direction == TextDirection.rtl
                    ? size.width - x - widths[index]
                    : x
              : 0,
          0,
        ),
      );
      x += widths[index];
      if (expanded) {
        layoutChild((
          'divider',
          index,
        ), BoxConstraints.tight(Size(CatchSpacing.s3, size.height)));
        positionChild(
          ('divider', index),
          Offset(
            (direction == TextDirection.rtl ? size.width - x : x).clamp(
                  CatchSpacing.s3 / 2,
                  size.width - CatchSpacing.s3 / 2,
                ) -
                CatchSpacing.s3 / 2,
            0,
          ),
        );
      }
    }
  }

  @override
  bool shouldRelayout(_WorkspaceLayout oldDelegate) =>
      direction != oldDelegate.direction ||
      expanded != oldDelegate.expanded ||
      compact != oldDelegate.compact ||
      !listEquals(widths, oldDelegate.widths);
}
