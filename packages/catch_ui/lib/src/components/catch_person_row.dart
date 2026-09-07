import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_person_avatar.dart';
import 'package:catch_ui/src/components/catch_person_chat_layout.dart';
import 'package:catch_ui/src/components/catch_person_chat_trailing.dart';
import 'package:catch_ui/src/components/catch_person_roster_layout.dart';
import 'package:catch_ui/src/components/catch_person_row_copy.dart';
import 'package:catch_ui/src/components/catch_person_row_data.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_row_press_surface.dart';
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
       metadata = null,
       contextContent = null,
       status = null;

  /// A natural-height directory identity with optional rich metadata, contextual
  /// content, and a status badge. Parent sections own gutters and separators.
  const CatchPersonRow.directory({
    super.key,
    required this.data,
    this.onTap,
    this.metadata,
    this.contextContent,
    this.status,
  }) : _directory = true,
       copy = null,
       trailing = null,
       avatarSize = CatchRecordTokens.avatarExtent,
       padding = const EdgeInsets.symmetric(
         vertical: CatchRecordTokens.verticalPadding,
       ),
       divider = false,
       dividerInset = 0,
       showFreshBackground = false;

  final bool _directory;
  final Widget? metadata;
  final Widget? contextContent;
  final Widget? status;

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
                  child: CatchPersonAvatar(
                    size: avatarSize,
                    name: data.name,
                    imageUrl: data.imageUrl,
                    shape: data.avatarShape,
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
                          if (status != null && !stackStatus) ...[
                            const SizedBox(width: CatchSpacing.s2),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    constraints.maxWidth *
                                    CatchRecordTokens.statusMaxWidthFraction,
                              ),
                              child: status!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (metadata != null) ...[
                      const SizedBox(height: CatchRecordTokens.titleGap),
                      DefaultTextStyle(
                        style: CatchTextStyles.supporting(context),
                        child: metadata!,
                      ),
                    ],
                    if (contextContent != null) ...[
                      const SizedBox(height: CatchRecordTokens.titleGap),
                      DefaultTextStyle(
                        style: CatchTextStyles.recordContext(context),
                        child: contextContent!,
                      ),
                    ],
                    if (status != null && stackStatus) ...[
                      const SizedBox(height: CatchRecordTokens.bodyGap),
                      status!,
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

    final trailingContent =
        trailing ??
        (isChatMode ? CatchPersonChatTrailing(data: data, copy: copy!) : null);
    final stackExplicitTrailing =
        trailing != null && MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final identity = Row(
      children: [
        CatchPersonAvatar(
          size: avatarSize,
          name: data.name,
          imageUrl: data.imageUrl,
          borderWidth: data.isFresh ? CatchStroke.underline : 0,
          borderColor: data.isFresh ? t.primary : null,
          shape: data.avatarShape,
        ),
        gapW12,
        Expanded(
          child: isChatMode
              ? CatchPersonChatLayout(data: data, copy: copy!)
              : CatchPersonRosterLayout(data: data),
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
