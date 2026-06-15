import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchOptionGroupVariant { label, mono }

class CatchOption<T> {
  const CatchOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Design-system OptionGroup: an underline selection row for tabs, lenses, and
/// inline scope controls.
class CatchOptionGroup<T> extends StatelessWidget {
  const CatchOptionGroup({
    super.key,
    required this.options,
    required this.selected,
    this.onChanged,
    this.variant = CatchOptionGroupVariant.label,
    this.accent,
    this.trailing,
  });

  final List<CatchOption<T>> options;
  final T selected;
  final ValueChanged<T>? onChanged;
  final CatchOptionGroupVariant variant;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final selectedRule = accent ?? t.ink;
    final gap = variant == CatchOptionGroupVariant.mono
        ? CatchSpacing.s4
        : CatchSpacing.micro18;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final option in options) ...[
                  if (option != options.first) SizedBox(width: gap),
                  Flexible(
                    flex: option.label.length,
                    child: _CatchOptionGroupItem<T>(
                      option: option,
                      selected: option.value == selected,
                      selectedRule: selectedRule,
                      variant: variant,
                      onTap: onChanged == null
                          ? null
                          : () => onChanged!(option.value),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: CatchSpacing.s3),
            Padding(
              padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
  }
}

class _CatchOptionGroupItem<T> extends StatelessWidget {
  const _CatchOptionGroupItem({
    required this.option,
    required this.selected,
    required this.selectedRule,
    required this.variant,
    this.onTap,
  });

  final CatchOption<T> option;
  final bool selected;
  final Color selectedRule;
  final CatchOptionGroupVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final foreground = selected ? t.ink : t.ink3;
    final style = switch (variant) {
      CatchOptionGroupVariant.label => CatchTextStyles.labelL(
        context,
        color: foreground,
      ),
      CatchOptionGroupVariant.mono => CatchTextStyles.monoLabel(
        context,
        color: foreground,
      ),
    };
    final label = variant == CatchOptionGroupVariant.mono
        ? option.label.toUpperCase()
        : option.label;

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: CatchMotion.fast,
          curve: CatchMotion.standardCurve,
          padding: EdgeInsets.only(
            bottom: selected ? CatchSpacing.micro10 : CatchSpacing.s3,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? selectedRule : Colors.transparent,
                width: CatchSpacing.micro3,
              ),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ),
    );
  }
}
