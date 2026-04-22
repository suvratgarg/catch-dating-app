import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:flutter/material.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// View-model for a single person row.
///
/// [metaLine] — secondary text: "5:30 /km · 26", "1.4 km away", etc.
/// [contextLine] — tertiary text: run name (shown with a route icon), or
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

  /// Tertiary line shown with a small route icon — typically the shared run name.
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
/// - **Catches preview** — similar to roster; pass [trailing] = [StatusChip]
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
///   trailing: StatusChip(status: RunStatus.joined),
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

  /// Optional widget shown at the right edge — [StatusChip], follow button, etc.
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
            horizontal: CatchSpacing.screenH,
            vertical: 10,
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
              const SizedBox(width: 12),
              // Text column
              Expanded(
                child: isChatMode
                    ? _ChatLayout(data: data)
                    : _RosterLayout(data: data),
              ),
              // Trailing widget (chip, button, etc.)
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
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
                style: CatchTextStyles.labelLg(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (data.timestamp != null)
              Text(data.timestamp!, style: CatchTextStyles.caption(context)),
          ],
        ),
        // Run context with route icon
        if (data.contextLine != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.directions_run_rounded, size: 11, color: t.ink3),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  data.contextLine!,
                  style: CatchTextStyles.caption(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        // Last message + unread badge
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                data.isTyping ? 'Typing…' : data.lastMessage!,
                style: CatchTextStyles.bodySm(
                  context,
                  color: data.isTyping ? t.primary : t.ink2,
                  weight: data.isTyping ? FontWeight.w500 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (data.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(CatchRadius.button),
                ),
                child: Text(
                  '${data.unreadCount}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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
          style: CatchTextStyles.labelLg(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (data.metaLine != null) ...[
          const SizedBox(height: 3),
          Text(
            data.metaLine!,
            style: CatchTextStyles.bodySm(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (data.contextLine != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.directions_run_rounded,
                size: 11,
                color: CatchTokens.of(context).ink3,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  data.contextLine!,
                  style: CatchTextStyles.caption(context),
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
