import 'package:meta/meta.dart';

@immutable
class EventChatParticipant {
  const EventChatParticipant({
    required this.uid,
    required this.displayName,
    required this.isHost,
  });
  factory EventChatParticipant.fromMap(Map<Object?, Object?> json) =>
      EventChatParticipant(
        uid: json['uid']! as String,
        displayName: json['displayName']! as String,
        isHost: json['role'] == 'host',
      );
  final String uid, displayName;
  final bool isHost;
}

@immutable
class EventChatParticipantPage {
  EventChatParticipantPage({
    required Iterable<EventChatParticipant> items,
    required Map<String, Object?>? nextCursor,
  }) : items = List.unmodifiable(items),
       nextCursor = nextCursor == null ? null : Map.unmodifiable(nextCursor);
  factory EventChatParticipantPage.fromMap(Map<Object?, Object?> json) =>
      EventChatParticipantPage(
        items: (json['items']! as List).map(
          (row) => EventChatParticipant.fromMap(row as Map),
        ),
        nextCursor: (json['nextCursor'] as Map?)?.cast<String, Object?>(),
      );
  final List<EventChatParticipant> items;
  final Map<String, Object?>? nextCursor;
}
