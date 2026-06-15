import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:flutter/material.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// View-model for a single person row.
///
/// [metaLine] — secondary text: "5:30 /km · 26", "1.4 km away", etc.
/// [contextLine] — tertiary text: event name (shown with a route icon), or
///   last message text.
/// [lastMessage] — if supplied, the row enters chat-thread layout with the
///   message, timestamp, and optional unread badge.
/// [isFresh] — draws an orange ring around the avatar and a [primarySoft]
///   row background (new match / unread catch).
class PersonRowData {
  const PersonRowData({
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

  /// Draws a primary-colour ring and soft row background.
  final bool isFresh;
}

// ── PersonRow ─────────────────────────────────────────────────────────────────

/// Flexible person row used in:
/// - **Chat inbox** — pass [data.lastMessage] to activate chat-thread layout
/// - **Roster / waitlist** — leave [data.lastMessage] null, pass [trailing]
/// - **Catches preview** — similar to roster; pass a badge as [trailing]
///
/// Usage:
/// ```dart
/// // Chat inbox row
/// PersonRow(
///   data: PersonRowData(name: 'Riya', lastMessage: 'See you Saturday!',
///                       contextLine: 'Bandra Breakers 7K',
///                       timestamp: '2m', unreadCount: 2, isFresh: true),
/// )
///
/// // Roster row
/// PersonRow(
///   data: PersonRowData(name: 'Riya', metaLine: '5:30 /km · 26'),
///   trailing: CatchBadge(label: 'Joined', tone: CatchBadgeTone.brand),
/// )
/// ```
class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.data,
    this.trailing,
    this.onTap,
    this.avatarSize = 48,
  });

  final PersonRowData data;

  /// Optional widget shown at the right edge — badge, follow button, etc.
  final Widget? trailing;
  final VoidCallback? onTap;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isChatMode = data.lastMessage != null;

    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: data.isFresh ? t.primarySoft : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CatchSpacing.s5,
            vertical: CatchSpacing.micro10,
          ),
          child: Row(
            children: [
              // Avatar
              PersonAvatar(
                size: avatarSize,
                name: data.name,
                imageUrl: data.imageUrl,
                borderWidth: data.isFresh ? 2 : 0,
                borderColor: data.isFresh ? t.primary : null,
              ),
              gapW12,
              // Text column
              Expanded(
                child: isChatMode
                    ? _ChatLayout(data: data)
                    : _RosterLayout(data: data),
              ),
              // Trailing widget (chip, button, etc.)
              if (trailing != null) ...[gapW10, trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chat-thread layout ────────────────────────────────────────────────────────

class _ChatLayout extends StatelessWidget {
  const _ChatLayout({required this.data});
  final PersonRowData data;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name + timestamp
        Row(
          children: [
            Expanded(
              child: Text(
                data.name,
                style: CatchTextStyles.sectionTitle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (data.timestamp != null)
              Text(data.timestamp!, style: CatchTextStyles.supporting(context)),
          ],
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
        // Last message + unread badge
        gapH4,
        Row(
          children: [
            Expanded(
              child: Text(
                data.isTyping ? 'Typing…' : data.lastMessage!,
                style:
                    CatchTextStyles.supporting(
                      context,
                      color: data.isTyping ? t.primary : t.ink2,
                    ).copyWith(
                      fontWeight: data.isTyping
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (data.unreadCount > 0) ...[
              gapW8,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchLayout.personUnreadBadgeHorizontalPadding,
                  vertical: CatchSpacing.micro2,
                ),
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                ),
                child: Text(
                  '${data.unreadCount}',
                  style: CatchTextStyles.statusLabel(
                    context,
                    color: t.primaryInk,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Roster layout ─────────────────────────────────────────────────────────────

class _RosterLayout extends StatelessWidget {
  const _RosterLayout({required this.data});
  final PersonRowData data;

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
                size: 11,
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
