import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Catch settings toggle.
///
/// Matches the handoff `Toggle`: pill track, primary fill when on, quiet
/// hairline-grey track when off, and a surface knob.
class CatchToggle extends StatelessWidget {
  const CatchToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  }) : _field = false;

  /// Compact toggle geometry used by `CatchField.toggle`.
  ///
  /// Every Catch toggle retains one interaction and semantics implementation;
  /// only the field handoff's geometry and motion tokens differ.
  const CatchToggle.field({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  }) : _field = true;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final bool _field;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final enabled = onChanged != null;
    final trackColor = value ? t.primary : t.line2;
    final trackWidth = _field
        ? CatchFieldTokens.toggleTrackWidth
        : CatchLayout.toggleTrackWidth;
    final trackHeight = _field
        ? CatchFieldTokens.toggleTrackHeight
        : CatchLayout.toggleTrackHeight;
    final trackInset = _field
        ? CatchFieldTokens.toggleTrackInset
        : CatchLayout.toggleTrackPadding;
    final knobExtent = _field
        ? CatchFieldTokens.toggleKnobExtent
        : CatchLayout.toggleKnobExtent;
    final disabledOpacity = _field
        ? CatchFieldTokens.savingToggleOpacity
        : CatchOpacity.disabledControl;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    final alignmentDuration = disableAnimations == true
        ? Duration.zero
        : _field
        ? CatchFieldTokens.standard
        : CatchMotion.fast;

    return Semantics(
      label: semanticLabel,
      button: true,
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Opacity(
          opacity: enabled ? CatchOpacity.visible : disabledOpacity,
          child: SizedBox(
            key: _field ? const ValueKey('catch-field-toggle') : null,
            width: trackWidth,
            height: trackHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: AnimatedAlign(
                duration: alignmentDuration,
                curve: _field
                    ? CatchFieldTokens.curve
                    : CatchMotion.standardCurve,
                alignment: value
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsets.all(trackInset),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                      boxShadow: CatchElevation.toggleKnob,
                    ),
                    child: SizedBox.square(dimension: knobExtent),
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
