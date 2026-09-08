import 'package:catch_ui/src/components/catch_person_avatar_shape.dart';

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
  /// soft background through `CatchPersonRow.showFreshBackground`.
  final bool isFresh;

  /// Shows a small primary dot in chat-preview trailing content when there is
  /// no numeric unread count.
  final bool showFreshDot;

  /// Avatar shape for row variants such as host inquiries.
  final CatchPersonAvatarShape avatarShape;
}
