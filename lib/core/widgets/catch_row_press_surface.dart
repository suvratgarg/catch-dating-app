import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Full-row interaction layer for list and field rows.
///
/// The child owns its content padding, lanes, and dividers. This surface owns
/// only the full-width hover/focus/pressed band and tap semantics.
class CatchRowPressSurface extends StatefulWidget {
  const CatchRowPressSurface({
    super.key,
    required this.child,
    this.onTap,
    this.semanticButton = true,
    this.expandToMaxWidth = true,
  });

  static const overlayKey = ValueKey<String>('catch-row-press-overlay');

  final Widget child;
  final VoidCallback? onTap;
  final bool semanticButton;
  final bool expandToMaxWidth;

  @override
  State<CatchRowPressSurface> createState() => _CatchRowPressSurfaceState();
}

class _CatchRowPressSurfaceState extends State<CatchRowPressSurface> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final surface = LayoutBuilder(
      builder: (context, constraints) {
        final child = widget.expandToMaxWidth && constraints.hasBoundedWidth
            ? SizedBox(width: constraints.maxWidth, child: widget.child)
            : widget.child;

        final stack = Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  key: CatchRowPressSurface.overlayKey,
                  color: _overlayColor(CatchTokens.of(context)),
                ),
              ),
            ),
          ],
        );
        if (!_enabled) return stack;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: FocusableActionDetector(
            mouseCursor: SystemMouseCursors.click,
            onShowFocusHighlight: _setFocused,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onTap?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              child: stack,
            ),
          ),
        );
      },
    );

    if (!widget.semanticButton || !_enabled) return surface;
    return Semantics(button: true, child: surface);
  }

  Color _overlayColor(CatchTokens t) {
    if (_pressed) {
      return t.ink.withValues(alpha: CatchOpacity.controlOverlayPressed);
    }
    if (_hovered || _focused) {
      return t.ink.withValues(alpha: CatchOpacity.controlOverlayHover);
    }
    return Colors.transparent;
  }

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  void _setHovered(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
  }

  void _setFocused(bool focused) {
    if (_focused == focused) return;
    setState(() => _focused = focused);
  }
}
