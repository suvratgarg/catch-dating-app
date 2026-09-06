import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Stops descendant focus/caret reveal requests at a horizontal pager page.
class CatchPagerFocusBoundary extends SingleChildRenderObjectWidget {
  const CatchPagerFocusBoundary({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCatchPagerFocusBoundary();
  }
}

class _RenderCatchPagerFocusBoundary extends RenderProxyBox {
  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = CatchMotion.none,
    Curve curve = CatchMotion.easeCurve,
  }) {
    // Inner vertical scrollables receive showOnScreen before this boundary.
    // Do not forward the request to the enclosing horizontal pager.
  }
}
