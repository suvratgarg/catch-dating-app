import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:flutter/material.dart';

/// Compact, provider-free identity row for a host or organizer.
///
/// Interaction affordances are derived from the callbacks: [onTap] adds the
/// trailing navigation chevron and [onMessage] adds the message action. This
/// keeps the visual affordances and the available actions from drifting apart.
class CatchHostRow extends StatelessWidget {
  const CatchHostRow({
    super.key,
    required this.activityKind,
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

  final ActivityKind activityKind;
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
    final activity = ActivityPalette.resolve(context, activityKind);
    final effectiveMetaColor = metaColor ?? t.ink3;
    final effectiveActionColor = actionColor ?? t.primary;

    final content = Padding(
      padding: EdgeInsets.only(top: divider ? CatchSpacing.s3 : 0),
      child: Row(
        children: [
          CatchPersonAvatar(
            name: name,
            imageUrl: imageUrl,
            size: CatchSpacing.s10,
            activityKind: activityKind,
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
                        color: activity.accent,
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
            CatchIconButton(
              onTap: onMessage,
              tooltip: messageTooltip,
              variant: CatchIconButtonVariant.plain,
              size: CatchIconButton.navSize,
              active: true,
              fill: false,
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
