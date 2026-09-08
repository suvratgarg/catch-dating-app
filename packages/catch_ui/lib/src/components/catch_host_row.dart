import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar.dart';
import 'package:catch_ui/src/components/catch_avatar_colors.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_row_press_surface.dart';
import 'package:flutter/material.dart';

/// Compact, provider-free identity row for a host or organizer.
///
/// Interaction affordances are derived from the callbacks: [onTap] adds the
/// trailing navigation chevron and [onMessage] adds the message action. This
/// keeps the visual affordances and the available actions from drifting apart.
class CatchHostRow extends StatelessWidget {
  const CatchHostRow({
    super.key,
    required this.colors,
    required this.name,
    this.imageUrl,
    this.meta,
    this.verified = false,
    this.divider = false,
    this.onTap,
    this.onMessage,
    this.messageTooltip,
    this.nameColor,
    this.metaColor,
    this.actionColor,
  }) : assert(
         onMessage == null ||
             (messageTooltip != null && messageTooltip.length > 0),
         'CatchHostRow requires messageTooltip when onMessage is provided.',
       );

  /// Caller-resolved identity colors, shared by the avatar and verified mark.
  final CatchAvatarColors colors;
  final String name;
  final String? imageUrl;
  final String? meta;
  final bool verified;
  final bool divider;

  /// Makes the identity row navigable and automatically shows a chevron.
  final VoidCallback? onTap;

  /// Adds a distinct message action. Its tap wins over the enclosing row tap.
  final VoidCallback? onMessage;
  final String? messageTooltip;

  final Color? nameColor;
  final Color? metaColor;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveMetaColor = metaColor ?? t.ink3;
    final effectiveActionColor = actionColor ?? t.primary;

    final content = Padding(
      padding: EdgeInsets.only(top: divider ? CatchSpacing.s3 : 0),
      child: Row(
        children: [
          CatchAvatar(
            name: name,
            imageUrl: imageUrl,
            size: CatchSpacing.s10,
            colors: colors,
          ),
          gapW12,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.name(context, color: nameColor),
                      ),
                    ),
                    if (verified) ...[
                      const SizedBox(width: CatchSpacing.micro6),
                      Icon(
                        CatchIcons.sealCheck,
                        size: CatchIcon.sm,
                        color: colors.accent,
                      ),
                    ],
                  ],
                ),
                if (meta != null && meta!.isNotEmpty) ...[
                  const SizedBox(height: CatchSpacing.s1),
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.monoLabel(
                      context,
                      color: effectiveMetaColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onMessage != null) ...[
            gapW8,
            CatchIconAction(
              onPressed: onMessage,
              tooltip: messageTooltip,
              variant: CatchIconActionVariant.plain,
              active: true,
              emphasis: CatchIconActionEmphasis.outline,
              accent: effectiveActionColor,
              child: Icon(CatchIcons.chatBubbleOutlineRounded),
            ),
          ],
          if (onTap != null) ...[
            gapW8,
            Icon(
              CatchIcons.chevronRightRounded,
              size: CatchIcon.lg,
              color: effectiveMetaColor,
            ),
          ],
        ],
      ),
    );

    final row = divider
        ? DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.line)),
            ),
            child: content,
          )
        : content;

    return CatchRowPressSurface(onTap: onTap, child: row);
  }
}
