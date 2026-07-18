import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Canonical hairline index row for compact directories and browse lists.
class CatchIndexRow extends StatelessWidget {
  const CatchIndexRow({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.trailing,
    this.selected = false,
    this.semanticLabel,
    this.titleStyle,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final String? semanticLabel;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: CatchLayout.eventTypeIndexRowHeight,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, gapW16],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      titleStyle ??
                      CatchTextStyles.titleL(context, color: t.ink),
                ),
              ),
              if (trailing != null) ...[gapW12, trailing!],
            ],
          ),
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      selected: selected,
      label: semanticLabel ?? title,
      child: ExcludeSemantics(child: content),
    );
  }
}
