import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar.dart';
import 'package:catch_ui/src/components/catch_avatar_colors.dart';
import 'package:catch_ui/src/components/catch_count_badge.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/components/catch_person_row_copy.dart';
import 'package:catch_ui/src/components/catch_person_row_data.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_row_press_surface.dart';
import 'package:catch_ui/src/primitives/catch_status_indicator.dart';
import 'package:flutter/material.dart';

/// Flexible person row used in:
/// - **Chat inbox** — pass [data.lastMessage] to activate chat-thread layout
/// - **Roster / waitlist** — leave [data.lastMessage] null, pass [trailing]
/// - **Catches preview** — similar to roster; pass a badge as [trailing]
///
/// Usage:
/// ```dart
/// // Chat inbox row
/// CatchPersonRow(
///   copy: localizedRowCopy,
///   data: CatchPersonRowData(name: 'Riya', lastMessage: 'See you Saturday!',
///                       contextLine: 'Bandra Breakers 7K',
///                       timestamp: '2m', unreadCount: 2, isFresh: true),
/// )
///
/// // Roster row
/// CatchPersonRow(
///   copy: localizedRowCopy,
///   data: CatchPersonRowData(name: 'Riya', metaLine: '5:30 /km · 26'),
///   trailing: CatchBadge(label: 'Joined', tone: CatchBadgeTone.brand),
/// )
/// ```
class CatchPersonRow extends StatelessWidget {
  const CatchPersonRow({
    super.key,
    required this.data,
    required CatchPersonRowCopy this.copy,
    this.trailing,
    this.onTap,
    this.avatarSize = CatchSpacing.s12,
    this.padding = const EdgeInsets.symmetric(
      horizontal: CatchSpacing.s5,
      vertical: CatchSpacing.micro10,
    ),
    this.divider = false,
    this.dividerInset = CatchLayout.chatListDividerInset,
    this.showFreshBackground = true,
  }) : _directory = false,
       meta = null,
       body = null,
       _contactConfig = null;

  /// A natural-height directory identity with optional rich meta, contextual
  /// content, and a status badge. Parent sections own gutters and separators.
  const CatchPersonRow.directory({
    super.key,
    required this.data,
    this.onTap,
    this.meta,
    this.body,
    this.trailing,
  }) : _directory = true,
       copy = null,
       avatarSize = CatchRecordTokens.avatarExtent,
       padding = const EdgeInsets.symmetric(
         vertical: CatchRecordTokens.verticalPadding,
       ),
       divider = false,
       dividerInset = 0,
       showFreshBackground = false,
       _contactConfig = null;

  /// Compact identity with optional verification, message and navigation actions.
  /// Affordances are derived from callbacks; message taps remain independent.
  const CatchPersonRow.contact({
    super.key,
    required this.data,
    required CatchAvatarColors colors,
    bool verified = false,
    this.divider = false,
    this.onTap,
    VoidCallback? onMessage,
    String? messageTooltip,
    Color? nameColor,
    Color? metaColor,
    Color? actionColor,
  }) : assert(
         onMessage == null ||
             (messageTooltip != null && messageTooltip.length > 0),
         'CatchPersonRow.contact requires messageTooltip for onMessage.',
       ),
       _directory = false,
       copy = null,
       trailing = null,
       meta = null,
       body = null,
       avatarSize = CatchSpacing.s10,
       padding = EdgeInsets.zero,
       dividerInset = 0,
       showFreshBackground = false,
       _contactConfig = (
         colors: colors,
         verified: verified,
         onMessage: onMessage,
         messageTooltip: messageTooltip,
         nameColor: nameColor,
         metaColor: metaColor,
         actionColor: actionColor,
       );

  final _ContactRowConfig? _contactConfig;
  final bool _directory;
  final Widget? meta;
  final Widget? body;

  final CatchPersonRowData data;

  /// Caller-resolved chat and accessibility copy; unused by directory rows.
  final CatchPersonRowCopy? copy;

  /// Optional widget shown at the right edge — badge, follow button, etc.
  final Widget? trailing;
  final VoidCallback? onTap;
  final double avatarSize;
  final EdgeInsetsGeometry padding;
  final bool divider;
  final double dividerInset;
  final bool showFreshBackground;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    if (_contactConfig case final contact?) {
      final colors = contact.colors;
      final name = data.name;
      final imageUrl = data.imageUrl;
      final meta = data.metaLine;
      final verified = contact.verified;
      final onMessage = contact.onMessage;
      final messageTooltip = contact.messageTooltip;
      final nameColor = contact.nameColor;
      final metaColor = contact.metaColor;
      final actionColor = contact.actionColor;
      final effectiveMetaColor = metaColor ?? t.ink3;
      final effectiveActionColor = actionColor ?? t.primary;

      final content = Padding(
        padding: EdgeInsets.only(top: divider ? CatchSpacing.s3 : 0),
        child: Row(
          children: [
            CatchAvatar(
              name: name,
              imageUrl: imageUrl,
              size: avatarSize,
              colors: colors,
              variant: data.avatarShape,
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
                          style: CatchTextStyles.name(
                            context,
                            color: nameColor,
                          ),
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
                  if (meta != null && meta.isNotEmpty) ...[
                    const SizedBox(height: CatchSpacing.s1),
                    Text(
                      meta,
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
    if (_directory) {
      final stackStatus =
          MediaQuery.textScalerOf(context).scale(1) >=
          CatchRecordTokens.largeTextBreakpoint;
      return CatchRowPressSurface(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1,
                  child: CatchAvatar(
                    size: avatarSize,
                    name: data.name,
                    imageUrl: data.imageUrl,
                    variant: data.avatarShape,
                  ),
                ),
              ),
              const SizedBox(width: CatchRecordTokens.leadingGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              data.name,
                              style: CatchTextStyles.name(context),
                            ),
                          ),
                          if (trailing != null && !stackStatus) ...[
                            const SizedBox(width: CatchSpacing.s2),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    constraints.maxWidth *
                                    CatchRecordTokens.statusMaxWidthFraction,
                              ),
                              child: trailing!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (meta != null) ...[
                      const SizedBox(height: CatchRecordTokens.titleGap),
                      DefaultTextStyle(
                        style: CatchTextStyles.supporting(context),
                        child: meta!,
                      ),
                    ],
                    if (body != null) ...[
                      const SizedBox(height: CatchRecordTokens.titleGap),
                      DefaultTextStyle(
                        style: CatchTextStyles.recordContext(context),
                        child: body!,
                      ),
                    ],
                    if (trailing != null && stackStatus) ...[
                      const SizedBox(height: CatchRecordTokens.bodyGap),
                      trailing!,
                    ],
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: CatchSpacing.s2),
                ExcludeSemantics(
                  child: Icon(
                    CatchIcons.chevronRightRounded,
                    size: CatchIcon.sm,
                    color: t.ink3,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    final isChatMode = data.lastMessage != null;
    final hasUnread = data.unreadCount > 0;
    final emphasized = hasUnread || data.isFresh || data.showFreshDot;

    final trailingContent =
        trailing ??
        (isChatMode
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (data.timestamp != null)
                    Text(
                      data.timestamp!,
                      style: CatchTextStyles.meta(
                        context,
                        color: emphasized ? t.primary : t.ink3,
                      ),
                    ),
                  if (hasUnread) ...[
                    const SizedBox(height: CatchSpacing.micro6),
                    CatchCountBadge.label(
                      count: data.unreadCount,
                      semanticsLabel: copy!.unreadCountLabel(data.unreadCount),
                    ),
                  ] else if (data.showFreshDot) ...[
                    const SizedBox(height: CatchSpacing.micro6),
                    CatchStatusIndicator(
                      size: CatchSpacing.s2,
                      semanticsLabel: copy!.newMatchLabel,
                    ),
                  ],
                ],
              )
            : null);
    final stackExplicitTrailing =
        trailing != null && MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final identity = Row(
      children: [
        CatchAvatar(
          size: avatarSize,
          name: data.name,
          imageUrl: data.imageUrl,
          borderWidth: data.isFresh ? CatchStroke.underline : 0,
          borderColor: data.isFresh ? t.primary : null,
          variant: data.avatarShape,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.name,
                style: isChatMode
                    ? CatchTextStyles.fieldRowTitle(
                        context,
                        color: emphasized ? t.ink : t.ink2,
                      )
                    : CatchTextStyles.sectionTitle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isChatMode && data.metaLine != null) ...[
                gapH3,
                Text(
                  data.metaLine!,
                  style: CatchTextStyles.supporting(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Shared event context for chat and roster rows.
              if (data.contextLine != null) ...[
                gapH2,
                Row(
                  children: [
                    Icon(
                      CatchIcons.directionsRunRounded,
                      size: CatchIcon.micro,
                      color: t.ink3,
                    ),
                    gapW3,
                    Expanded(
                      child: Text(
                        data.contextLine!,
                        style: CatchTextStyles.supporting(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (isChatMode) ...[
                gapH4,
                Text(
                  data.isTyping ? copy!.typingLabel : data.lastMessage!,
                  style: CatchTextStyles.chatPreview(
                    context,
                    color: data.isTyping
                        ? t.primary
                        : data.showFreshDot
                        ? t.primary
                        : hasUnread
                        ? t.ink
                        : t.ink2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
    final row = ColoredBox(
      color: showFreshBackground && data.isFresh
          ? t.primarySoft
          : Colors.transparent,
      child: Stack(
        children: [
          if (divider)
            Positioned(
              top: 0,
              left: dividerInset,
              right: 0,
              child: const CatchDivider(),
            ),
          Padding(
            padding: padding,
            child: stackExplicitTrailing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      identity,
                      gapH8,
                      Align(
                        alignment: Alignment.centerRight,
                        child: trailingContent,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: identity),
                      if (trailingContent != null) ...[gapW10, trailingContent],
                    ],
                  ),
          ),
        ],
      ),
    );

    return CatchRowPressSurface(onTap: onTap, child: row);
  }
}

typedef _ContactRowConfig = ({
  CatchAvatarColors colors,
  bool verified,
  VoidCallback? onMessage,
  String? messageTooltip,
  Color? nameColor,
  Color? metaColor,
  Color? actionColor,
});
