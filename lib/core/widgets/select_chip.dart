import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Handoff `SelectChip`: a tactile selectable pill for questionnaire answers,
/// mission choices, and choosy filters.
class SelectChip extends StatefulWidget {
  const SelectChip({
    super.key,
    required this.label,
    this.active = false,
    this.accentColor,
    this.onTap,
    this.enabled = true,
    this.semanticsLabel,
  });

  final String label;
  final bool active;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticsLabel;

  @override
  State<SelectChip> createState() => _SelectChipState();
}

class _SelectChipState extends State<SelectChip> {
  static const double _pressedScale = 0.95;
  static const double _activeScale = 1.03;

  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onTap != null;

  void _setPressed(bool value) {
    if (!_interactive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final accent = widget.accentColor ?? t.primary;
    final foreground = widget.active ? t.onFill(accent) : t.ink;
    final background = widget.active ? accent : t.surface;
    final border = widget.active ? Colors.transparent : t.line2;
    final scale = _pressed
        ? _pressedScale
        : widget.active
        ? _activeScale
        : 1.0;

    return Semantics(
      button: _interactive,
      selected: widget.active,
      enabled: widget.enabled,
      label: widget.semanticsLabel ?? widget.label,
      child: AnimatedOpacity(
        opacity: widget.enabled ? 1 : CatchOpacity.disabledControl,
        duration: CatchMotion.fast,
        curve: CatchMotion.standardCurve,
        child: GestureDetector(
          onTapDown: _interactive ? (_) => _setPressed(true) : null,
          onTapUp: _interactive ? (_) => _setPressed(false) : null,
          onTapCancel: _interactive ? () => _setPressed(false) : null,
          child: AnimatedScale(
            scale: scale,
            duration: CatchMotion.fast,
            curve: CatchMotion.standardCurve,
            child: CatchSurface(
              backgroundColor: background,
              borderColor: border,
              radius: CatchRadius.pill,
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s4,
                vertical: CatchSpacing.micro10,
              ),
              boxShadow: widget.active
                  ? <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(
                          alpha: CatchOpacity.eventTypeCueGlowActive,
                        ),
                        blurRadius: CatchSpacing.micro14,
                        offset: const Offset(CatchSpacing.s0, CatchSpacing.s1),
                      ),
                    ]
                  : CatchElevation.none,
              onTap: _interactive ? widget.onTap : null,
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.labelL(context, color: foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
