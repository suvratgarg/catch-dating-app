import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Catch settings toggle.
///
/// Matches the handoff `Toggle`: pill track, primary fill when on, quiet
/// hairline-grey track when off, and a surface knob.
class CatchToggle extends StatefulWidget {
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
  State<CatchToggle> createState() => _CatchToggleState();
}

class _CatchToggleState extends State<CatchToggle> {
  bool _showFocusHighlight = false;

  void _activate() {
    final onChanged = widget.onChanged;
    if (onChanged != null) onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final enabled = widget.onChanged != null;
    final trackColor = widget.value ? t.primary : t.line2;
    final trackWidth = widget._field
        ? CatchFieldTokens.toggleTrackWidth
        : CatchLayout.toggleTrackWidth;
    final trackHeight = widget._field
        ? CatchFieldTokens.toggleTrackHeight
        : CatchLayout.toggleTrackHeight;
    final trackInset = widget._field
        ? CatchFieldTokens.toggleTrackInset
        : CatchLayout.toggleTrackPadding;
    final knobExtent = widget._field
        ? CatchFieldTokens.toggleKnobExtent
        : CatchLayout.toggleKnobExtent;
    final disabledOpacity = widget._field
        ? CatchFieldTokens.savingToggleOpacity
        : CatchOpacity.disabledControl;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    final alignmentDuration = disableAnimations == true
        ? Duration.zero
        : widget._field
        ? CatchFieldTokens.standard
        : CatchMotion.fast;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      toggled: widget.value,
      enabled: enabled,
      child: FocusableActionDetector(
        enabled: enabled,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (show) {
          if (_showFocusHighlight != show) {
            setState(() => _showFocusHighlight = show);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _activate : null,
          child: AnimatedOpacity(
            duration: alignmentDuration,
            curve: widget._field
                ? CatchFieldTokens.curve
                : CatchMotion.standardCurve,
            opacity: enabled ? CatchOpacity.visible : disabledOpacity,
            child: SizedBox(
              key: widget._field ? const ValueKey('catch-field-toggle') : null,
              width: trackWidth,
              height: widget._field ? CatchSpacing.s11 : trackHeight,
              child: Center(
                child: SizedBox(
                  width: trackWidth,
                  height: trackHeight,
                  child: DecoratedBox(
                    key: widget._field
                        ? const ValueKey('catch-field-toggle-focus-outline')
                        : null,
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                      border: _showFocusHighlight
                          ? Border.all(
                              color: t.ink,
                              width: CatchFieldTokens.focusRingWidth,
                            )
                          : null,
                    ),
                    child: AnimatedContainer(
                      key: widget._field
                          ? const ValueKey('catch-field-toggle-track')
                          : null,
                      duration: alignmentDuration,
                      curve: widget._field
                          ? CatchFieldTokens.curve
                          : CatchMotion.standardCurve,
                      decoration: BoxDecoration(
                        color: trackColor,
                        borderRadius: BorderRadius.circular(CatchRadius.pill),
                      ),
                      child: AnimatedAlign(
                        duration: alignmentDuration,
                        curve: widget._field
                            ? CatchFieldTokens.curve
                            : CatchMotion.standardCurve,
                        alignment: widget.value
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: EdgeInsets.all(trackInset),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: t.surface,
                              borderRadius: BorderRadius.circular(
                                CatchRadius.pill,
                              ),
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
            ),
          ),
        ),
      ),
    );
  }
}
