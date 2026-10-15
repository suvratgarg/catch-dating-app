part of 'catch_workspace_pane_scaffold.dart';

/// Measures only visible pane headers, then aligns their lower boundaries in
/// the same layout pass. No fixed header height or post-frame state is needed.
class CatchWorkspaceHeaderLayout extends SingleChildRenderObjectWidget {
  const CatchWorkspaceHeaderLayout({super.key, required super.child});

  static bool contains(BuildContext context) =>
      context.findAncestorRenderObjectOfType<_RenderWorkspaceHeaderLayout>() !=
      null;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderWorkspaceHeaderLayout();
}

/// A pane's natural header participating in its workspace's measured row.
class CatchWorkspaceHeader extends SingleChildRenderObjectWidget {
  const CatchWorkspaceHeader({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderWorkspaceHeader(
        context.findAncestorRenderObjectOfType<_RenderWorkspaceHeaderLayout>(),
      );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderWorkspaceHeader).group = context
        .findAncestorRenderObjectOfType<_RenderWorkspaceHeaderLayout>();
  }
}

class _RenderWorkspaceHeaderLayout extends RenderProxyBox {
  final headers = <_RenderWorkspaceHeader>{};
  final _heights = <_RenderWorkspaceHeader, double>{};

  double? heightFor(_RenderWorkspaceHeader header) => _heights[header];
  bool measuring = false;
  bool _relayoutScheduled = false;

  void headerChanged() {
    if (measuring || _relayoutScheduled || !attached) return;
    // LayoutBuilder may update a header inside a descendant layout boundary.
    // Invalidating its clean ancestor there is forbidden by Flutter. Defer
    // that invalidation; the next group layout still measures in one pass.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _relayoutScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _relayoutScheduled = false;
        if (attached) markNeedsLayout();
      });
    } else {
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    measuring = true;
    try {
      _layoutHeaders();
    } finally {
      measuring = false;
    }
  }

  void _layoutHeaders() {
    // First let each header take its natural size at its actual pane width.
    _heights.clear();
    invokeLayoutCallback<BoxConstraints>((_) {
      for (final header in headers) {
        header.markNeedsLayout();
      }
    });
    super.performLayout();
    final visible = headers.where((header) => header.visibleIn(this)).toList();
    if (visible.length < 2) return;
    final bottom = visible
        .map((header) => header.topIn(this) + header.naturalHeight)
        .reduce((a, b) => a > b ? a : b);
    for (final header in visible) {
      _heights[header] = bottom - header.topIn(this);
    }
    if (visible.every((header) => header.allocatedHeight == _heights[header])) {
      return;
    }
    // Only headers stretch. Bodies/scroll views are never intrinsically sized.
    invokeLayoutCallback<BoxConstraints>((_) {
      for (final header in visible) {
        header.markNeedsLayout();
      }
    });
    super.performLayout();
  }
}

class _RenderWorkspaceHeader extends RenderProxyBox {
  _RenderWorkspaceHeader(this._group);
  _RenderWorkspaceHeaderLayout? _group;
  double naturalHeight = 0;
  double allocatedHeight = 0;

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    final group = _group;
    if (attached) group?.headerChanged();
  }

  set group(_RenderWorkspaceHeaderLayout? value) {
    if (identical(value, _group)) return;
    if (attached) _group?.headers.remove(this);
    _group = value;
    if (attached) _group?.headers.add(this);
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _group?.headers.add(this);
  }

  @override
  void detach() {
    _group?.headers.remove(this);
    super.detach();
  }

  double topIn(_RenderWorkspaceHeaderLayout group) {
    var top = 0.0;
    RenderObject? ancestor = this;
    while (ancestor != null && !identical(ancestor, group)) {
      final data = ancestor.parentData;
      if (data is BoxParentData) top += data.offset.dy;
      ancestor = ancestor.parent;
    }
    // Align layout origins. Route animation transforms belong to painting and
    // may read descendant sizes outside the permitted layout scope.
    return top;
  }

  bool visibleIn(_RenderWorkspaceHeaderLayout group) {
    RenderObject? ancestor = parent;
    while (ancestor != null && !identical(ancestor, group)) {
      if (ancestor is RenderOffstage && ancestor.offstage) return false;
      ancestor = ancestor.parent;
    }
    return identical(ancestor, group);
  }

  @override
  void performLayout() {
    child!.layout(constraints.loosen(), parentUsesSize: true);
    naturalHeight = child!.size.height;
    size = constraints.constrain(
      Size(child!.size.width, _group?.heightFor(this) ?? naturalHeight),
    );
    allocatedHeight = size.height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final natural = child!.getDryLayout(constraints.loosen());
    return constraints.constrain(
      Size(natural.width, _group?.heightFor(this) ?? natural.height),
    );
  }
}
