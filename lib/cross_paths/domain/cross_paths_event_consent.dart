import 'package:cloud_firestore/cloud_firestore.dart';

const currentCrossPathsTermsVersion = 1;

enum CrossPathsConsentSource {
  bookingSuccess('booking_success'),
  eventDetail('event_detail'),
  settings('settings');

  const CrossPathsConsentSource(this.wireValue);
  final String wireValue;
}

final class CrossPathsEventConsent {
  const CrossPathsEventConsent({
    required this.eventId,
    required this.uid,
    required this.enabled,
    required this.termsVersion,
    required this.consentedAt,
    required this.updatedAt,
    required this.revokedAt,
    required this.source,
  });

  factory CrossPathsEventConsent.fromJson(Map<String, dynamic> json) {
    DateTime? nullableTimestamp(Object? value) =>
        value is Timestamp ? value.toDate() : null;
    return CrossPathsEventConsent(
      eventId: json['eventId'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      enabled: json['enabled'] == true,
      termsVersion: json['termsVersion'] as int? ?? 0,
      consentedAt: nullableTimestamp(json['consentedAt']),
      updatedAt: nullableTimestamp(json['updatedAt']),
      revokedAt: nullableTimestamp(json['revokedAt']),
      source: json['source'] as String? ?? '',
    );
  }

  final String eventId;
  final String uid;
  final bool enabled;
  final int termsVersion;
  final DateTime? consentedAt;
  final DateTime? updatedAt;
  final DateTime? revokedAt;
  final String source;
}

String crossPathsEventConsentId({
  required String eventId,
  required String uid,
}) => '${eventId}_$uid';
