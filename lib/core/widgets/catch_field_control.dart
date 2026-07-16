part of 'catch_field.dart';

extension _CatchFieldControl on _CatchFieldState {
  void _dismiss() {
    if (_isSaving) return;
    if (_isOpen) {
      _handleCancel();
    }
    if (_focusNode.hasFocus) _focusNode.unfocus();
    if (_menuController.isOpen) _menuController.close();
  }

  void _handleCancel() {
    if (_isSaving) return;
    _requestExpansion(false);
    widget._onCancel?.call();
  }

  void _handleSubmit() {
    if (_isSaving) return;
    widget._onSubmit?.call();
    // The handoff closes locally-owned disclosures after Done. Controlled
    // editors remain parent-owned so async validation/save state can decide
    // when their card collapses.
    if (mounted &&
        widget._closeLocallyOnSubmit &&
        widget.open == null &&
        !_isSaving) {
      _requestExpansion(false);
    }
  }
}

/// Exact wrapping chip control used by [CatchField.choices].
class CatchFieldChoiceControl<T> extends StatelessWidget {
  const CatchFieldChoiceControl({
    super.key,
    required this.values,
    required this.itemLabel,
    required this.selected,
    required this.multi,
    required this.onSelectionChanged,
    this.allowEmptySelection = false,
    this.autoClose = false,
    this.enabled = true,
    this.itemAccent,
  });

  final List<T> values;
  final String Function(T value) itemLabel;
  final Set<T> selected;
  final bool multi;
  final bool allowEmptySelection;
  final bool autoClose;
  final bool enabled;
  final Color? Function(T value)? itemAccent;
  final ValueChanged<Set<T>>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: CatchFieldTokens.chipHorizontalGap,
        runSpacing: CatchFieldTokens.chipRunSpacing,
        children: [
          for (final value in values)
            CatchFieldChoiceChip(
              label: itemLabel(value),
              selected: selected.contains(value),
              multi: multi,
              enabled: enabled && onSelectionChanged != null,
              accent: itemAccent?.call(value),
              onPressed: () {
                final next = Set<T>.from(selected);
                if (multi) {
                  if (next.contains(value)) {
                    if (!allowEmptySelection && next.length == 1) return;
                    next.remove(value);
                  } else {
                    next.add(value);
                  }
                } else {
                  final wasSelected = next.contains(value);
                  next.clear();
                  if (!wasSelected || !allowEmptySelection) {
                    next.add(value);
                  }
                }
                onSelectionChanged?.call(next);
                if (!multi && autoClose && onSelectionChanged != null) {
                  const _CatchFieldChoicePickedNotification(
                    autoClose: true,
                  ).dispatch(context);
                }
              },
            ),
        ],
      ),
    );
  }
}

class CatchFieldChoiceChip extends StatefulWidget {
  const CatchFieldChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.multi,
    required this.enabled,
    required this.onPressed,
    this.accent,
  });

  final String label;
  final bool selected;
  final bool multi;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? accent;

  @override
  State<CatchFieldChoiceChip> createState() => _CatchFieldChoiceChipState();
}

class CatchFieldFocusOutline extends StatelessWidget {
  const CatchFieldFocusOutline({
    super.key,
    required this.debugKey,
    required this.show,
    required this.borderRadius,
    required this.child,
  });

  final Key debugKey;
  final bool show;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Stack(
      key: debugKey,
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CatchFieldFocusOutlinePainter(
                  color: t.ink,
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CatchFieldFocusOutlinePainter extends CustomPainter {
  const _CatchFieldFocusOutlinePainter({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final reach =
        CatchFieldTokens.focusRingOffset + CatchFieldTokens.focusRingWidth / 2;
    final outline = borderRadius.toRRect(Offset.zero & size).inflate(reach);
    canvas.drawRRect(
      outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = CatchFieldTokens.focusRingWidth,
    );
  }

  @override
  bool shouldRepaint(_CatchFieldFocusOutlinePainter oldDelegate) =>
      color != oldDelegate.color || borderRadius != oldDelegate.borderRadius;
}

class _CatchFieldDisclosureClipper extends CustomClipper<Rect> {
  const _CatchFieldDisclosureClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    0,
    0,
    size.width,
    size.height +
        CatchFieldTokens.focusRingOffset +
        CatchFieldTokens.focusRingWidth,
  );

  @override
  bool shouldReclip(_CatchFieldDisclosureClipper oldClipper) => false;
}

class _CatchFieldChoiceChipState extends State<CatchFieldChoiceChip> {
  bool _pressed = false;
  bool _showFocusHighlight = false;

  @override
  Widget build(BuildContext context) {
    if (widget.accent != null) {
      return CatchChip.selectable(
        key: ValueKey('catch-field-choice-${widget.label}'),
        label: widget.label,
        selected: widget.selected,
        enabled: widget.enabled,
        accent: widget.accent,
        leading: widget.multi && widget.selected
            ? Icon(
                CatchIcons.checkRounded,
                size: CatchFieldTokens.chipSelectedGlyphExtent,
              )
            : null,
        semanticsLabel: widget.label,
        onChanged: (_) => widget.onPressed(),
      );
    }
    final t = CatchTokens.of(context);
    final foreground = widget.selected ? t.primaryInk : t.ink;
    final background = widget.selected ? t.ink : t.surface;
    final visual = AnimatedScale(
      duration: _fieldDuration(
        context,
        _pressed ? CatchFieldTokens.pressIn : CatchFieldTokens.pressOut,
      ),
      curve: CatchFieldTokens.curve,
      scale: _pressed ? CatchFieldTokens.chipPressedScale : 1,
      child: AnimatedContainer(
        key: ValueKey('catch-field-choice-${widget.label}'),
        duration: _fieldDuration(context, CatchFieldTokens.fast),
        curve: CatchFieldTokens.curve,
        constraints: const BoxConstraints(
          minHeight: CatchFieldTokens.chipVisualMinHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CatchFieldTokens.chipHorizontalPadding,
          vertical: CatchFieldTokens.chipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          border: Border.all(color: widget.selected ? t.ink : t.line2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.multi && widget.selected) ...[
              Icon(
                CatchIcons.checkRounded,
                size: CatchFieldTokens.chipSelectedGlyphExtent,
                color: foreground,
              ),
              const SizedBox(width: CatchFieldTokens.chipSelectedGlyphGap),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.fieldRowTitle(context, color: foreground)
                    .copyWith(
                      fontSize: CatchFieldTokens.chipFontSize,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: widget.enabled,
      checked: widget.selected,
      inMutuallyExclusiveGroup: !widget.multi,
      label: widget.label,
      child: FocusableActionDetector(
        enabled: widget.enabled,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
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
          opacity: widget.enabled ? 1 : CatchFieldTokens.disabledOpacity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? widget.onPressed : null,
            onTapDown: widget.enabled
                ? (_) => setState(() => _pressed = true)
                : null,
            onTapUp: widget.enabled
                ? (_) => setState(() => _pressed = false)
                : null,
            onTapCancel: widget.enabled
                ? () => setState(() => _pressed = false)
                : null,
            child: CatchFieldFocusOutline(
              debugKey: ValueKey(
                'catch-field-choice-${widget.label}-focus-outline',
              ),
              show: _showFocusHighlight,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              child: visual,
            ),
          ),
        ),
      ),
    );
  }
}

/// Exact numeric control used by [CatchField.stepper].
class CatchFieldStepper extends StatelessWidget {
  const CatchFieldStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decreaseSemanticLabel,
    required this.increaseSemanticLabel,
    this.min,
    this.max,
    this.step = 1,
    this.unit,
    this.formatter,
    this.enabled = true,
  });

  final num value;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final num step;
  final String? unit;
  final String Function(num value)? formatter;
  final String decreaseSemanticLabel;
  final String increaseSemanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final number = formatter?.call(value) ?? _formatNumber(value);
    final formatted = unit == null ? number : '$number $unit';
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        key: const ValueKey('catch-field-stepper'),
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchFieldRepeatButton(
            icon: CatchIcons.removeRounded,
            semanticLabel: decreaseSemanticLabel,
            enabled:
                enabled && onChanged != null && (min == null || value > min!),
            onStep: () => onChanged?.call(_nextValue(-step)),
          ),
          const SizedBox(width: CatchFieldTokens.stepperLayoutGap),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: CatchFieldTokens.stepperValueMinWidth,
            ),
            child: Text(
              formatted,
              key: const ValueKey('catch-field-stepper-value'),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: CatchTextStyles.fieldRowTitle(context, color: t.ink)
                  .copyWith(
                    fontSize: CatchFieldTokens.stepperValueFontSize,
                    fontWeight: FontWeight.w700,
                    height: CatchFieldTokens.valueLineHeight,
                  ),
            ),
          ),
          const SizedBox(width: CatchFieldTokens.stepperLayoutGap),
          CatchFieldRepeatButton(
            icon: CatchIcons.addRounded,
            semanticLabel: increaseSemanticLabel,
            enabled:
                enabled && onChanged != null && (max == null || value < max!),
            onStep: () => onChanged?.call(_nextValue(step)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(num number) => number == number.roundToDouble()
      ? number.toInt().toString()
      : number.toString();

  num _nextValue(num delta) {
    num next = ((value + delta) * 100).round() / 100;
    if (min != null && next < min!) next = min!;
    if (max != null && next > max!) next = max!;
    return next;
  }
}

/// Hold-to-repeat 44px stepper target used by [CatchFieldStepper].
class CatchFieldRepeatButton extends StatefulWidget {
  const CatchFieldRepeatButton({
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
  State<CatchFieldRepeatButton> createState() => _CatchFieldRepeatButtonState();
}

class _CatchFieldRepeatButtonState extends State<CatchFieldRepeatButton> {
  Timer? _delay;
  Timer? _repeat;
  int? _pressedPointer;
  int _ticks = 0;
  bool _pressed = false;
  bool _showFocusHighlight = false;

  @override
  void didUpdateWidget(CatchFieldRepeatButton oldWidget) {
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
        Offset.zero & const Size.square(CatchFieldTokens.stepperHitExtent);
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
    final visual = AnimatedScale(
      duration: _fieldDuration(
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
          border: Border.all(color: t.line2),
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
                child: CatchFieldFocusOutline(
                  debugKey: ValueKey(
                    'catch-field-stepper-${widget.semanticLabel}-focus-outline',
                  ),
                  show: _showFocusHighlight,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  child: SizedBox.square(
                    dimension: CatchFieldTokens.stepperHitExtent,
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
