import 'dart:async';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_motion.dart';
import 'package:catch_ui/src/components/catch_field_surface.dart';
import 'package:catch_ui/src/primitives/catch_control_surface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hold-to-repeat platform-sized target used by `CatchStepper`.
class CatchStepperRepeatButton extends StatefulWidget {
  static double get hitExtent => CatchControlMetrics.squareConstraints(
    CatchFieldTokens.stepperHitExtent,
  ).minHeight;

  /// Keep the same visual text-to-circle gap as the hit target grows.
  static double get layoutGap =>
      CatchFieldTokens.stepperGap -
      (hitExtent - CatchFieldTokens.stepperVisualExtent) / 2;
  const CatchStepperRepeatButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onStep,
    this.visualAlignment = Alignment.center,
  });

  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onStep;
  final AlignmentGeometry visualAlignment;

  @override
  State<CatchStepperRepeatButton> createState() =>
      _CatchStepperRepeatButtonState();
}

class _CatchStepperRepeatButtonState extends State<CatchStepperRepeatButton> {
  Timer? _delay;
  Timer? _repeat;
  int? _pressedPointer;
  int _ticks = 0;
  bool _pressed = false;
  bool _showFocusHighlight = false;

  @override
  void didUpdateWidget(CatchStepperRepeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) _stop();
  }

  @override
  void dispose() {
    _stop(updateState: false);
    super.dispose();
  }

  void _start() {
    if (!widget.enabled || _pressed) return;
    _stop();
    setState(() => _pressed = true);
    widget.onStep();
    _delay = Timer(CatchFieldTokens.repeatDelay, _repeatOnce);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pressedPointer != null || event.buttons & kPrimaryButton == 0) return;
    _start();
    if (_pressed) _pressedPointer = event.pointer;
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_pressedPointer != event.pointer) return;
    _pressedPointer = null;
    _stop();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_pressedPointer != event.pointer) return;
    final bounds =
        Offset.zero & Size.square(CatchStepperRepeatButton.hitExtent);
    if (!bounds.contains(event.localPosition)) {
      _pressedPointer = null;
      _stop();
    }
  }

  void _handlePointerExit(PointerExitEvent event) {
    if (_pressedPointer == null) return;
    _pressedPointer = null;
    _stop();
  }

  void _repeatOnce() {
    if (!mounted || !_pressed || !widget.enabled) return;
    widget.onStep();
    _ticks += 1;
    final interval = _ticks > CatchFieldTokens.repeatAccelerationTicks
        ? CatchFieldTokens.repeatAccelerated
        : CatchFieldTokens.repeatNormal;
    _repeat = Timer(interval, _repeatOnce);
  }

  void _stop({bool updateState = true}) {
    _delay?.cancel();
    _repeat?.cancel();
    _delay = null;
    _repeat = null;
    _pressedPointer = null;
    _ticks = 0;
    if (_pressed && updateState && mounted) setState(() => _pressed = false);
    if (!updateState) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final border = CatchBorder.interactive(
      t,
      !widget.enabled
          ? CatchInteractiveBorderState.disabled
          : _pressed
          ? CatchInteractiveBorderState.pressed
          : CatchInteractiveBorderState.resting,
    );
    final visual = AnimatedScale(
      duration: catchFieldMotionDuration(
        context,
        _pressed ? CatchFieldTokens.pressIn : CatchFieldTokens.pressOut,
      ),
      curve: CatchFieldTokens.curve,
      scale: _pressed ? CatchFieldTokens.stepperPressedScale : 1,
      child: DecoratedBox(
        key: ValueKey('catch-field-stepper-${widget.semanticLabel}-visual'),
        decoration: BoxDecoration(
          color: t.surface,
          shape: BoxShape.circle,
          border: border.all,
        ),
        child: SizedBox.square(
          dimension: CatchFieldTokens.stepperVisualExtent,
          child: Icon(
            widget.icon,
            size: CatchFieldTokens.stepperGlyphExtent,
            color: t.ink,
          ),
        ),
      ),
    );
    return Tooltip(
      message: widget.semanticLabel,
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.semanticLabel,
        onTap: widget.enabled ? widget.onStep : null,
        child: FocusableActionDetector(
          enabled: widget.enabled,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onStep();
                return null;
              },
            ),
          },
          onShowFocusHighlight: (show) {
            if (_showFocusHighlight != show) {
              setState(() => _showFocusHighlight = show);
            }
          },
          child: Opacity(
            opacity: widget.enabled
                ? 1
                : CatchFieldTokens.boundedStepperOpacity,
            child: MouseRegion(
              onExit: widget.enabled ? _handlePointerExit : null,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: widget.enabled ? _handlePointerDown : null,
                onPointerMove: widget.enabled ? _handlePointerMove : null,
                onPointerUp: widget.enabled ? _handlePointerEnd : null,
                onPointerCancel: widget.enabled ? _handlePointerEnd : null,
                child: CatchFieldSurface.focusTarget(
                  outlineKey: ValueKey(
                    'catch-field-stepper-${widget.semanticLabel}-focus-outline',
                  ),
                  states: _showFocusHighlight
                      ? const {WidgetState.focused}
                      : const {},
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  child: SizedBox.square(
                    dimension: CatchStepperRepeatButton.hitExtent,
                    child: Align(
                      alignment: widget.visualAlignment,
                      child: visual,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
