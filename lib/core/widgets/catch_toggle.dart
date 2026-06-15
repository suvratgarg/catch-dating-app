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
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final enabled = onChanged != null;
    final trackColor = value ? t.primary : t.line2;

    return Semantics(
      label: semanticLabel,
      button: true,
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Opacity(
          opacity: enabled
              ? CatchOpacity.visible
              : CatchOpacity.disabledControl,
          child: SizedBox(
            width: 46,
            height: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: AnimatedAlign(
                duration: CatchMotion.fast,
                curve: CatchMotion.standardCurve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const SizedBox.square(dimension: 22),
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
