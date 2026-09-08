import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/components/catch_field_motion.dart';
import 'package:catch_ui/src/components/catch_field_spinner.dart';
import 'package:catch_ui/src/components/catch_field_surface.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Exact Cancel/Done action used by a disclosed `CatchField` editor.
class CatchFieldCommitButton extends StatefulWidget {
  const CatchFieldCommitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;

  @override
  State<CatchFieldCommitButton> createState() => _CatchFieldCommitButtonState();
}

class _CatchFieldCommitButtonState extends State<CatchFieldCommitButton> {
  late final FocusNode _focusNode = FocusNode(
    debugLabel: widget.primary
        ? 'CatchField Done button'
        : 'CatchField Cancel button',
  );
  bool _showFocusHighlight = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_updateFocusHighlight);
    FocusManager.instance.addHighlightModeListener(_updateFocusHighlight);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_updateFocusHighlight)
      ..dispose();
    FocusManager.instance.removeHighlightModeListener(_updateFocusHighlight);
    super.dispose();
  }

  void _updateFocusHighlight([FocusHighlightMode? _]) {
    final show =
        _focusNode.hasFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    if (show != _showFocusHighlight && mounted) {
      setState(() => _showFocusHighlight = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final background = widget.primary ? t.ink : t.surface;
    final foreground = widget.primary ? t.primaryInk : t.ink;
    final button = CatchButton.text(
      label: widget.label,
      onPressed: widget.onPressed,
      foregroundColor: foreground,
      backgroundColor: background,
      disabledForegroundColor: foreground,
      disabledBackgroundColor: background,
      focusNode: _focusNode,
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchFieldTokens.actionButtonHorizontalPadding,
        vertical: CatchFieldTokens.actionButtonVerticalPadding,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: widget.primary ? Colors.transparent : t.line2),
      shape: const StadiumBorder(),
      textStyle: CatchTextStyles.control(context),
      leading: widget.loading
          ? ExcludeSemantics(
              child: SizedBox.square(
                dimension: CatchFieldTokens.actionSpinnerExtent,
                child: CatchFieldSpinner(
                  size: CatchFieldTokens.actionSpinnerExtent,
                  color: foreground,
                ),
              ),
            )
          : null,
      leadingGap: CatchFieldTokens.actionButtonSpinnerGap,
    );
    return Semantics(
      liveRegion: widget.loading,
      child: AnimatedOpacity(
        duration: catchFieldMotionDuration(context, CatchFieldTokens.fast),
        curve: CatchFieldTokens.curve,
        opacity: widget.onPressed == null && !widget.primary
            ? CatchFieldTokens.savingCancelOpacity
            : 1,
        child: CatchFieldSurface.focusTarget(
          outlineKey: ValueKey(
            widget.primary
                ? 'catch-field-done-focus-outline'
                : 'catch-field-cancel-focus-outline',
          ),
          states: _showFocusHighlight ? const {WidgetState.focused} : const {},
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: button,
        ),
      ),
    );
  }
}
