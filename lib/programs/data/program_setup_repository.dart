import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_setup_repository.g.dart';

/// Manager-facing program surface: program CRUD, staff grants and the
/// manifest/resources used by the arrivals workspace.
class ProgramSetupRepository {
  const ProgramSetupRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<List<({String programId, String title, String kind, String status})>>
  listPrograms(String organizerId) => _call(
    name: 'listOrganizerPrograms',
    payload: ListOrganizerProgramsCallableRequest(
      organizerId: organizerId,
    ).toJson(),
    action: 'load your programs',
    parse: (value) {
      final map = requiredMap(value, 'organizer programs');
      return mapList(map['programs'], 'programs')
          .map(
            (entry) => (
              programId: requiredString(entry, 'programId'),
              title: requiredString(entry, 'title'),
              kind: requiredString(entry, 'kind'),
              status: requiredString(entry, 'status'),
            ),
          )
          .toList(growable: false);
    },
  );

  Future<ProgramMutationResult> createProgram({
    required String organizerId,
    required String kind,
    required String title,
    required String timezone,
    required DateTime startsAt,
    required DateTime endsAt,
    List<String> capabilities = const ['arrivalsTransport'],
    Map<String, Object?>? transportSettings,
  }) => _call(
    name: 'createOrganizerProgram',
    payload: CreateOrganizerProgramCallableRequest(
      organizerId: organizerId,
      kind: kind,
      title: title,
      timezone: timezone,
      startsAtMillis: startsAt.millisecondsSinceEpoch,
      endsAtMillis: endsAt.millisecondsSinceEpoch,
      capabilities: capabilities,
      transportSettings: transportSettings,
    ).toJson(),
    action: 'create the program',
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<ProgramMutationResult> updateProgramSettings({
    required String programId,
    required int expectedRevision,
    String? title,
    String? status,
    Map<String, Object?>? transportSettings,
  }) => _call(
    name: 'updateOrganizerProgram',
    payload: UpdateOrganizerProgramCallableRequest(
      programId: programId,
      expectedRevision: expectedRevision,
      title: title,
      status: status,
      transportSettings: transportSettings,
    ).toJson(),
    action: 'update the program',
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<ProgramStaffList> listStaff(String programId) => _call(
    name: 'listProgramStaff',
    payload: ProgramIdCallableRequest(programId: programId).toJson(),
    action: 'load program staff',
    parse: ProgramStaffList.fromCallableData,
  );

  /// Grants are keyed by verified phone number; the callable resolves the
  /// phone to a UID and writes one grant per staff member.
  Future<ProgramStaffList> grantStaff({
    required String programId,
    required String phoneNumber,
    required List<ProgramDutyAssignment> duties,
    required DateTime expiresAt,
  }) => _call(
    name: 'grantProgramStaff',
    payload: GrantProgramStaffCallableRequest(
      programId: programId,
      phoneNumber: phoneNumber,
      duties: duties
          .map(
            (duty) => {
              'duty': duty.duty.name,
              'pickupPointIds': duty.pickupPointIds.toList()..sort(),
              'hotelIds': duty.hotelIds.toList()..sort(),
            },
          )
          .toList(growable: false),
      expiresAtMillis: expiresAt.millisecondsSinceEpoch,
    ).toJson(),
    action: 'grant program staff access',
    parse: ProgramStaffList.fromCallableData,
  );

  Future<ProgramStaffList> revokeStaff({
    required String programId,
    required ProgramStaffMember member,
  }) => _call(
    name: 'revokeProgramStaff',
    payload: RevokeProgramStaffCallableRequest(
      programId: programId,
      uid: member.uid,
      expectedRevision: member.revision,
    ).toJson(),
    action: 'revoke program staff access',
    parse: ProgramStaffList.fromCallableData,
  );

  Future<ProgramMutationResult> upsertGuest({
    required String programId,
    required String displayName,
    String? guestId,
    int? expectedRevision,
    String? householdId,
    String? phoneE164,
    String? email,
    String? externalReference,
    String rsvpStatus = 'pending',
  }) => _call(
    name: 'upsertProgramGuest',
    payload: UpsertProgramGuestCallableRequest(
      programId: programId,
      guestId: guestId,
      expectedRevision: expectedRevision,
      displayName: displayName,
      householdId: householdId,
      phoneE164: phoneE164,
      email: email,
      externalReference: externalReference,
      rsvpStatus: rsvpStatus,
    ).toJson(),
    action: 'save the guest',
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<ProgramMutationResult> upsertPickupPoint({
    required String programId,
    required String kind,
    required String label,
    String? pickupPointId,
    int? expectedRevision,
    String? iataCode,
    String? terminal,
    String? meetingZone,
    String? instructions,
    bool? active,
  }) => _call(
    name: 'upsertProgramPickupPoint',
    payload: UpsertProgramPickupPointCallableRequest(
      programId: programId,
      pickupPointId: pickupPointId,
      expectedRevision: expectedRevision,
      kind: kind,
      label: label,
      iataCode: iataCode,
      terminal: terminal,
      meetingZone: meetingZone,
      instructions: instructions,
      active: active,
    ).toJson(),
    action: 'save the pickup point',
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<ProgramMutationResult> upsertHotel({
    required String programId,
    required String name,
    String? hotelId,
    int? expectedRevision,
    String? address,
    String? notes,
    bool? active,
  }) => _call(
    name: 'upsertProgramHotel',
    payload: UpsertProgramHotelCallableRequest(
      programId: programId,
      hotelId: hotelId,
      expectedRevision: expectedRevision,
      name: name,
      address: address ?? '',
      notes: notes,
      active: active,
    ).toJson(),
    action: 'save the hotel',
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<ProgramMutationResult> upsertVendor({
    required String organizerId,
    required String name,
    String? vendorId,
    int? expectedRevision,
    String? contactName,
    String? phoneE164,
    List<String>? programIds,
    bool? active,
  }) => _call(
    name: 'upsertTransportVendor',
    payload: UpsertTransportVendorCallableRequest(
      organizerId: organizerId,
      vendorId: vendorId,
      expectedRevision: expectedRevision,
      name: name,
      contactName: contactName,
      phoneE164: phoneE164,
      programIds: programIds,
      active: active,
    ).toJson(),
    action: 'save the vendor',
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<ProgramMutationResult> upsertTravelLeg({
    required String programId,
    required String guestId,
    required String kind,
    String? legId,
    int? expectedRevision,
    String? partyId,
    String? flightNumber,
    String? carrierCode,
    String? originIata,
    String? destinationIata,
    DateTime? scheduledArrivalAt,
    bool? international,
    String? pickupPointId,
    String? destinationHotelId,
    String? destinationLabel,
    int passengers = 1,
    int luggageUnits = 0,
    List<String> requiredCapabilities = const [],
    bool dedicatedVehicle = false,
  }) => _call(
    name: 'upsertProgramTravelLeg',
    payload: UpsertProgramTravelLegCallableRequest(
      programId: programId,
      legId: legId,
      expectedRevision: expectedRevision,
      guestId: guestId,
      partyId: partyId,
      kind: kind,
      flightNumber: flightNumber,
      carrierCode: carrierCode,
      originIata: originIata,
      destinationIata: destinationIata,
      scheduledArrivalAtMillis: scheduledArrivalAt?.millisecondsSinceEpoch,
      international: international,
      pickupPointId: pickupPointId,
      destinationHotelId: destinationHotelId,
      destinationLabel: destinationLabel,
      passengers: passengers,
      luggageUnits: luggageUnits,
      requiredCapabilities: requiredCapabilities,
      dedicatedVehicle: dedicatedVehicle,
    ).toJson(),
    action: 'save the travel leg',
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<T> _call<T>({
    required String name,
    required Map<String, Object?> payload,
    required String action,
    required T Function(Object?) parse,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable(name)
          .call<Object?>(payload);
      return parse(result.data);
    },
    context: BackendErrorContext(
      service: BackendService.functions,
      action: action,
      resource: name,
    ),
  );
}

@riverpod
ProgramSetupRepository programSetupRepository(Ref ref) =>
    ProgramSetupRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Future<ProgramStaffList> programStaffList(Ref ref, String programId) =>
    ref.read(programSetupRepositoryProvider).listStaff(programId);
