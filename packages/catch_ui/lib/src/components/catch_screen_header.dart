import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_top_bar_action_row.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

/// Root-screen title stack shared by the main tabs and root-like app bars.
class CatchScreenHeader extends StatelessWidget {
  const CatchScreenHeader({
    super.key,
    required this.title,
    this.kicker,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.titleMaxLines = 1,
    this.titleStyle,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
    this.material = false,
    this.backgroundColor,
  });

  const CatchScreenHeader.block({
    super.key,
    required this.title,
    this.kicker,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.titleMaxLines = 1,
    this.titleStyle,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.padding = CatchInsets.screenTitleBlock,
    this.backgroundColor,
  }) : material = true;

  final String title;
  final String? kicker;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final int titleMaxLines;
  final TextStyle? titleStyle;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final EdgeInsetsGeometry? padding;
  final bool material;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasKicker = kicker != null && kicker!.isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;

    final titleStack = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasKicker) ...[
          Text(
            kicker!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.kicker(context, color: t.ink3),
          ),
          gapH2,
        ],
        Text(
          title,
          maxLines: titleMaxLines,
          overflow: TextOverflow.ellipsis,
          style: titleStyle ?? CatchTextStyles.headline(context, color: t.ink),
        ),
        if (hasSubtitle) ...[
          const SizedBox(height: CatchGaps.headerTitleToSubtitle),
          Text(
            subtitle!,
            maxLines: largeText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ],
    );
    final titleRow = Row(
      crossAxisAlignment: rowCrossAxisAlignment,
      children: [
        if (leading != null) ...[leading!, gapW12],
        Expanded(child: titleStack),
      ],
    );
    Widget child = largeText && actions.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleRow,
              gapH8,
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: CatchTopBarActionRow(actions: actions),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: rowCrossAxisAlignment,
            children: [
              if (leading != null) ...[leading!, gapW12],
              Expanded(child: titleStack),
              if (actions.isNotEmpty) ...[
                gapW12,
                CatchTopBarActionRow(actions: actions),
              ],
            ],
          );

    final resolvedPadding = padding;
    if (resolvedPadding != null) {
      child = Padding(padding: resolvedPadding, child: child);
    }

    final resolvedBackground = backgroundColor ?? t.bg;
    if (material) {
      return Material(color: resolvedBackground, child: child);
    }
    if (backgroundColor != null) {
      return ColoredBox(color: resolvedBackground, child: child);
    }
    return child;
  }
}
