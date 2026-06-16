import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Canonical "leading icon + title + supporting message + optional action"
/// card.
///
/// This absorbs the many near-identical feature cards that hand-rolled the
/// shape `CatchSurface(Row(Icon, Column(title, message, [cta])))` — for
/// example event-companion, invite-loop, and host notice cards. Color overrides
/// are optional so callers with bespoke surface styling can still adopt it
/// instead of reimplementing the layout.
class CatchInfoCard extends StatelessWidget {
  const CatchInfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.tone = CatchSurfaceTone.surface,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.titleColor,
    this.messageColor,
    this.padding = CatchInsets.tileContentCompact,
  });

  /// Leading icon.
  final IconData icon;

  /// Card heading (sentence case).
  final String title;

  /// Optional supporting copy under the title.
  final String? message;

  /// Optional trailing action, typically a [CatchButton]/[CatchTextButton],
  /// rendered below the message.
  final Widget? action;

  final CatchSurfaceTone tone;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? titleColor;
  final Color? messageColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: tone,
      backgroundColor: backgroundColor,
      borderColor: borderColor ?? t.line,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CatchTextStyles.sectionTitle(
                    context,
                    color: titleColor ?? t.ink,
                  ),
                ),
                if (message != null) ...[
                  gapH4,
                  Text(
                    message!,
                    style: CatchTextStyles.supporting(
                      context,
                      color: messageColor ?? t.ink2,
                    ),
                  ),
                ],
                if (action != null) ...[gapH12, action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
