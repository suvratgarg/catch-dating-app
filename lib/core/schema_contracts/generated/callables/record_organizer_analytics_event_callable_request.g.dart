// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/record_organizer_analytics_event_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Public website analytics event for host-visible organizer metrics. The callable validates organizer scope and writes a raw, aggregate-safe event to BigQuery.
final class RecordOrganizerAnalyticsEventCallableRequest {
  const RecordOrganizerAnalyticsEventCallableRequest({
    required this.clubId,
    this.eventId,
    required this.eventName,
    required this.pagePath,
    this.source,
    this.sessionId,
    this.platform,
  });

  final String clubId;
  final String? eventId;
  final String eventName;
  final String pagePath;
  final String? source;
  final String? sessionId;
  final String? platform;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'eventId': ?eventId,
    'eventName': eventName,
    'pagePath': pagePath,
    'source': ?source,
    'sessionId': ?sessionId,
    'platform': ?platform,
  };
}
