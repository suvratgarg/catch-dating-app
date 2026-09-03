import 'package:catch_dating_app/core/app_config.dart';

enum ForegroundNotificationKind { match, message }

/// A validated arrival event, not a durable Activity row or a navigation URL
/// supplied by the network. Its destination is derived locally from the role.
class ForegroundNotification {
  const ForegroundNotification({
    required this.id,
    required this.uid,
    required this.matchId,
    required this.kind,
    required this.role,
    this.title,
    this.body,
    this.actorName,
    this.actorAvatarUrl,
  });

  final String id;
  final String uid;
  final String matchId;
  final ForegroundNotificationKind kind;
  final AppRole role;
  final String? title;
  final String? body;
  final String? actorName;
  final String? actorAvatarUrl;

  String get route => role.isHost
      ? '/host/inbox/${Uri.encodeComponent(matchId)}'
      : '/chats/${Uri.encodeComponent(matchId)}';
  String get dedupeKey => 'arrival.$route';

  static ForegroundNotification? parse({
    required Map<String, Object?> data,
    required String uid,
    required AppRole role,
    String? deliveryId,
    String? title,
    String? body,
  }) {
    final kind = switch (data['type']) {
      'match' => ForegroundNotificationKind.match,
      'message' => ForegroundNotificationKind.message,
      _ => null,
    };
    final matchId = _text(data['matchId']);
    final recipient = data['recipientUid'];
    final targetRole = data['appRole'];
    if (uid.isEmpty ||
        kind == null ||
        matchId == null ||
        matchId.contains('/') ||
        matchId == '.' ||
        matchId == '..' ||
        (recipient != null && recipient != uid) ||
        (targetRole != null && targetRole != role.value) ||
        (role.isHost && kind == ForegroundNotificationKind.match)) {
      return null;
    }
    final eventId =
        _text(data['notificationId']) ??
        _text(deliveryId) ??
        _text(data['messageId']);
    // Message bodies are not event identities. Without an id, fail closed
    // rather than replaying/replacing unrelated messages with identical copy.
    if (eventId == null && kind == ForegroundNotificationKind.message) {
      return null;
    }
    final avatar = _text(data['actorAvatarUrl']);
    final avatarUri = avatar == null ? null : Uri.tryParse(avatar);
    return ForegroundNotification(
      id: 'arrival.${eventId ?? 'match_$matchId'}',
      uid: uid,
      matchId: matchId,
      kind: kind,
      role: role,
      title: _text(title),
      body: _text(body),
      actorName: _text(data['actorName']),
      actorAvatarUrl: avatarUri?.scheme == 'https' && avatarUri!.host.isNotEmpty
          ? avatar
          : null,
    );
  }

  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
}
