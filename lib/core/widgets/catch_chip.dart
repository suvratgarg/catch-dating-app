import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Canonical Catch filter/tag chip primitive.
class CatchChip extends StatelessWidget {
  const CatchChip({
    super.key,
    required this.label,
    this.active = false,
    this.icon,
    this.onTap,
    this.onRemove,
    this.enabled = true,
    this.semanticsLabel,
  });

  final String label;
  final bool active;
  final Widget? icon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool enabled;
  final String? semanticsLabel;

  bool get _interactive => enabled && (onTap != null || onRemove != null);

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final background = active ? t.ink : t.surface;
    final foreground = active ? t.surface : t.ink;
    final border = active ? Colors.transparent : t.line2;

    return Semantics(
      button: _interactive,
      selected: active,
      enabled: enabled,
      label: semanticsLabel ?? label,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.4,
        duration: CatchMotion.fast,
        curve: CatchMotion.standardCurve,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            border: Border.all(color: border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onTap : null,
                splashColor: foreground.withValues(alpha: 0.08),
                highlightColor: foreground.withValues(alpha: 0.04),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
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
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.titleS(
                          context,
                          color: foreground,
                        ),
                      ),
                      if (onRemove != null) ...[
                        const SizedBox(width: CatchSpacing.s2),
                        _RemoveButton(
                          color: active ? t.surface : t.ink2,
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

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.color, required this.onRemove});

  final Color color;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRemove,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(Icons.close_rounded, color: color, size: CatchIcon.sm),
      ),
    );
  }
}
