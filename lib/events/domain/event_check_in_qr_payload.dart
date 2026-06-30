import 'dart:convert';

const eventCheckInQrKind = 'catch:event-check-in';

class EventCheckInQrPayload {
  const EventCheckInQrPayload({required this.eventId});

  factory EventCheckInQrPayload.fromJson(Map<String, Object?> json) {
    final kind = json['kind'];
    final version = json['v'];
    final eventId = json['eventId'];
    if (kind != eventCheckInQrKind || version != 1 || eventId is! String) {
      throw const FormatException('Unsupported event check-in QR code.');
    }
    final normalizedEventId = eventId.trim();
    if (normalizedEventId.isEmpty) {
      throw const FormatException(
        'Event check-in QR code is missing event id.',
      );
    }
    return EventCheckInQrPayload(eventId: normalizedEventId);
  }

  final String eventId;

  String encode() =>
      jsonEncode({'kind': eventCheckInQrKind, 'v': 1, 'eventId': eventId});

  static EventCheckInQrPayload? tryParse(String rawValue) {
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, Object?>) return null;
      return EventCheckInQrPayload.fromJson(decoded);
    } on FormatException {
      return null;
    } on Object {
      return null;
    }
  }
}
