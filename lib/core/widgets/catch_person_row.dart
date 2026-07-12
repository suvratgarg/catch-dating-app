import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// View-model for a single person row.
///
/// [metaLine] — secondary text: "5:30 /km · 26", "1.4 km away", etc.
/// [contextLine] — tertiary text: event name (shown with a route icon), or
///   last message text.
/// [lastMessage] — if supplied, the row enters chat-thread layout with the
///   message, timestamp, and optional unread badge.
/// [isFresh] — marks the row as new/unread and draws a primary avatar ring.
class CatchPersonRowData {
  const CatchPersonRowData({
    required this.name,
    this.imageUrl,
    this.seed = '',
    this.metaLine,
    this.contextLine,
    this.lastMessage,
    this.isTyping = false,
    this.timestamp,
    this.unreadCount = 0,
    this.isFresh = false,
    this.showFreshDot = false,
    this.avatarShape = CatchPersonAvatarShape.circle,
  });

  final String name;
  final String? imageUrl;
  final String seed;

  /// Secondary info line — pace, distance, age, proximity, etc.
  final String? metaLine;

  /// Tertiary line shown with a small route icon — typically the shared event name.
  final String? contextLine;

  /// When non-null switches to chat-thread layout.
  final String? lastMessage;

  /// Shows "Typing…" in primary colour instead of [lastMessage].
  final bool isTyping;

  /// Short relative timestamp, e.g. "2m", "1h", "3d".
  final String? timestamp;
  final int unreadCount;

  /// Draws a primary-colour ring. The row decides whether that also paints a
  /// soft background through [CatchPersonRow.showFreshBackground].
  final bool isFresh;

  /// Shows a small primary dot in chat-preview trailing content when there is
  /// no numeric unread count.
  final bool showFreshDot;

  /// Avatar shape for row variants such as host inquiries.
  final CatchPersonAvatarShape avatarShape;
}

// ── CatchPersonRow ─────────────────────────────────────────────────────────────────

/// Flexible person row used in:
/// - **Chat inbox** — pass [data.lastMessage] to activate chat-thread layout
/// - **Roster / waitlist** — leave [data.lastMessage] null, pass [trailing]
/// - **Catches preview** — similar to roster; pass a badge as [trailing]
///
/// Usage:
/// ```dart
/// // Chat inbox row
/// CatchPersonRow(
///   data: CatchPersonRowData(name: 'Riya', lastMessage: 'See you Saturday!',
///                       contextLine: 'Bandra Breakers 7K',
///                       timestamp: '2m', unreadCount: 2, isFresh: true),
/// )
///
/// // Roster row
/// CatchPersonRow(
///   data: CatchPersonRowData(name: 'Riya', metaLine: '5:30 /km · 26'),
///   trailing: CatchBadge(label: 'Joined', tone: CatchBadgeTone.brand),
/// )
/// ```
class CatchPersonRow extends StatelessWidget {
  const CatchPersonRow({
    super.key,
    required this.data,
    this.trailing,
    this.onTap,
    this.avatarSize = 48,
    this.padding = const EdgeInsets.symmetric(
      horizontal: CatchSpacing.s5,
      vertical: CatchSpacing.micro10,
    ),
    this.divider = false,
    this.dividerInset = CatchLayout.chatListDividerInset,
    this.showFreshBackground = true,
  });

  final CatchPersonRowData data;

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
    final isChatMode = data.lastMessage != null;

    final trailingContent =
        trailing ?? (isChatMode ? CatchPersonChatTrailing(data: data) : null);
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
            child: Row(
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
                      ? CatchPersonChatLayout(data: data)
                      : CatchPersonRosterLayout(data: data),
                ),
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

// ── Chat-thread layout ────────────────────────────────────────────────────────

class CatchPersonChatLayout extends StatelessWidget {
  const CatchPersonChatLayout({super.key, required this.data});

  final CatchPersonRowData data;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasUnread = data.unreadCount > 0;
    final emphasized = hasUnread || data.isFresh || data.showFreshDot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.name,
          style: CatchTextStyles.fieldRowTitle(
            context,
            color: emphasized ? t.ink : t.ink2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Event context with route icon
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
        gapH4,
        Text(
          data.isTyping
              ? context.l10n.coreCatchPersonRowTextTyping
              : data.lastMessage!,
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
    );
  }
}

class CatchPersonChatTrailing extends StatelessWidget {
  const CatchPersonChatTrailing({super.key, required this.data});

  final CatchPersonRowData data;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasUnread = data.unreadCount > 0;
    final emphasized = hasUnread || data.isFresh || data.showFreshDot;

    return Column(
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
          CatchPersonUnreadCountPill(count: data.unreadCount),
        ] else if (data.showFreshDot) ...[
          const SizedBox(height: CatchSpacing.micro6),
          const CatchPersonNewMatchDot(),
        ],
      ],
    );
  }
}

class CatchPersonUnreadCountPill extends StatelessWidget {
  const CatchPersonUnreadCountPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final label = catchCountLabel(count);

    return Semantics(
      label: count == 1
          ? context.l10n.coreCatchPersonRowLabelUnreadChat
          : context.l10n.coreCatchPersonRowLabelLabelUnreadChats(label: label),
      child: CatchBadge(
        label: label,
        tone: CatchBadgeTone.brand,
        backgroundColor: t.primary,
        foregroundColor: t.primaryInk,
        borderColor: t.primary,
      ),
    );
  }
}

class CatchPersonNewMatchDot extends StatelessWidget {
  const CatchPersonNewMatchDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.coreCatchPersonRowLabelNewMatch,
      child: ClipOval(
        child: ColoredBox(
          color: CatchTokens.of(context).primary,
          child: const SizedBox.square(dimension: CatchSpacing.s2),
        ),
      ),
    );
  }
}

// ── Roster layout ─────────────────────────────────────────────────────────────

class CatchPersonRosterLayout extends StatelessWidget {
  const CatchPersonRosterLayout({super.key, required this.data});

  final CatchPersonRowData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.name,
          style: CatchTextStyles.sectionTitle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (data.metaLine != null) ...[
          gapH3,
          Text(
            data.metaLine!,
            style: CatchTextStyles.supporting(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (data.contextLine != null) ...[
          gapH2,
          Row(
            children: [
              Icon(
                CatchIcons.directionsRunRounded,
                size: CatchIcon.micro,
                color: CatchTokens.of(context).ink3,
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
      ],
    );
  }
}
