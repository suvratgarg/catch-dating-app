// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/upsert_program_travel_party_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Create or update a ride-together travel party.
final class UpsertProgramTravelPartyCallableRequest {
  const UpsertProgramTravelPartyCallableRequest({
    required this.programId,
    this.partyId,
    this.expectedRevision,
    this.label,
    required this.memberGuestIds,
    required this.dedicatedVehicle,
  });

  final String programId;
  final String? partyId;
  final int? expectedRevision;
  final String? label;
  final List<String> memberGuestIds;
  final bool dedicatedVehicle;

  Map<String, Object?> toJson() => {
    'programId': programId,
    'partyId': ?partyId,
    'expectedRevision': ?expectedRevision,
    'label': ?label,
    'memberGuestIds': memberGuestIds,
    'dedicatedVehicle': dedicatedVehicle,
  };
}
