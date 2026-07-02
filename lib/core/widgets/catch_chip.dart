import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Handoff `Chip`: a quiet fact/filter pill.
class CatchChip extends StatelessWidget {
  const CatchChip({
    super.key,
    required this.label,
    this.active = false,
    this.tintColor,
    this.inkColor,
    this.icon,
    this.onTap,
    this.onRemove,
    this.enabled = true,
    this.semanticsLabel,
  });

  final String label;
  final bool active;
  final Color? tintColor;
  final Color? inkColor;
  final Widget? icon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool enabled;
  final String? semanticsLabel;

  bool get _interactive => enabled && (onTap != null || onRemove != null);

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasTint = tintColor != null;
    final background = tintColor ?? (active ? Colors.transparent : t.surface);
    final foreground = inkColor ?? t.ink;
    final border = hasTint
        ? Colors.transparent
        : active
        ? t.ink
        : t.line2;
    final borderWidth = active && !hasTint ? 1.5 : 1.0;

    return Semantics(
      button: _interactive,
      selected: active,
      enabled: enabled,
      label: semanticsLabel ?? label,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : CatchOpacity.disabledControl,
        duration: CatchMotion.fast,
        curve: CatchMotion.standardCurve,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            border: Border.all(color: border, width: borderWidth),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onTap : null,
                splashColor: foreground.withValues(
                  alpha: CatchOpacity.controlOverlayPressed,
                ),
                highlightColor: foreground.withValues(
                  alpha: CatchOpacity.controlOverlayHover,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CatchSpacing.micro14,
                    vertical: CatchSpacing.s2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: foreground,
                            size: CatchIcon.sm,
                          ),
                          child: icon!,
                        ),
                        const SizedBox(width: CatchSpacing.s2),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.labelL(
                            context,
                            color: foreground,
                          ),
                        ),
                      ),
                      if (onRemove != null) ...[
                        const SizedBox(width: CatchSpacing.s2),
                        CatchChipRemoveButton(
                          color: foreground,
                          onRemove: enabled ? onRemove : null,
                        ),
                      ],
                    ],
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

class CatchChipRemoveButton extends StatelessWidget {
  const CatchChipRemoveButton({super.key, required this.color, this.onRemove});

  final Color color;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRemove,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.micro2),
        child: Icon(CatchIcons.closeRounded, color: color, size: CatchIcon.sm),
      ),
    );
  }
}
