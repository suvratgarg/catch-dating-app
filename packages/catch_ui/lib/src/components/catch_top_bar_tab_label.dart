import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Selected or resting label inside the adaptive top-bar tab control.
///
/// A Material [Tab] contributes its text, child or icon in that order. Other
/// caller-owned widgets retain their layout under the shared label styling.
class CatchTopBarTabLabel extends StatelessWidget {
  const CatchTopBarTabLabel({
    super.key,
    required this.tab,
    required this.selected,
  });

  final Widget tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = selected ? t.ink : t.ink2;
    final style = CatchTextStyles.labelL(context, color: color);
    final source = tab;
    Widget child = source;
    if (source is Tab) {
      final text = source.text;
      child = text != null
          ? Text(text, style: style)
          : source.child ?? source.icon ?? source;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: CatchPlatformTokens.minimumInteractiveExtent,
      ),
      child: Center(
        child: DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: style,
          child: IconTheme(
            data: IconThemeData(color: color, size: CatchIcon.sm),
            child: child,
          ),
        ),
      ),
    );
  }
}
