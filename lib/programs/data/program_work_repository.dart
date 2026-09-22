import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/data/program_read_snapshots.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_work_repository.g.dart';

/// Operational program surface: work access, arrivals roster, transport
/// plan, readiness claims, dispatch, trip lifecycle and hotel inbound.
///
/// All reads are server-side scoped projections; the client never reads the
/// program collections directly.
class ProgramWorkRepository {
  const ProgramWorkRepository(this._functions, this._snapshots);

  final FirebaseFunctions _functions;
  final ProgramReadSnapshotStore _snapshots;

  Future<ProgramWorkAccess> getWorkAccess(
    String programId, {
    String? snapshotAccountId,
  }) => _call(
    name: 'getProgramWorkAccess',
    payload: ProgramIdCallableRequest(programId: programId).toJson(),
    action: 'load program access',
    parse: ProgramWorkAccess.fromCallableData,
    snapshotScope: programSnapshotScope('work', programId),
    snapshotAccountId: snapshotAccountId,
  );

  /// Redeems a staff invite for the signed-in account. The callable requires
  /// the account's verified phone to match the invite's bound number.
  Future<String> claimStaffInvite(String inviteId) => _call(
    name: 'claimProgramStaffInvite',
    payload: ClaimProgramStaffInviteCallableRequest(
      inviteId: inviteId,
    ).toJson(),
    action: 'claim the staff invite',
    parse: (value) =>
        requiredString(requiredMap(value, 'invite claim'), 'programId'),
  );

  Future<ProgramArrivalsRoster> getArrivalsRoster({
    required String programId,
    String? pickupPointId,
    String? snapshotAccountId,
  }) => _call(
    name: 'getProgramArrivalsRoster',
    payload: ProgramStationScopeCallableRequest(
      programId: programId,
      pickupPointId: pickupPointId,
    ).toJson(),
    action: 'load the arrivals roster',
    parse: ProgramArrivalsRoster.fromCallableData,
    snapshotScope: programSnapshotScope('arrivals', programId, pickupPointId),
    snapshotAccountId: snapshotAccountId,
  );

  Future<ProgramTransportPlan> getTransportPlan({
    required String programId,
    String? pickupPointId,
    String? snapshotAccountId,
  }) => _call(
    name: 'getProgramTransportPlan',
    payload: ProgramStationScopeCallableRequest(
      programId: programId,
      pickupPointId: pickupPointId,
    ).toJson(),
    action: 'load the transport plan',
    parse: ProgramTransportPlan.fromCallableData,
    snapshotScope: programSnapshotScope('plan', programId, pickupPointId),
    snapshotAccountId: snapshotAccountId,
  );

  /// Claim a guest for greeting. `clientOperationId` makes offline retries
  /// return the original result instead of double-applying.
  Future<ProgramMutationResult> claimLeg({
    required String programId,
    required String legId,
    required String clientOperationId,
    int? expectedRevision,
  }) => _readiness(
    programId: programId,
    legId: legId,
    action: 'claim',
    clientOperationId: clientOperationId,
    expectedRevision: expectedRevision,
    label: 'claim the guest',
  );

  Future<ProgramMutationResult> unclaimLeg({
    required String programId,
    required String legId,
    required String clientOperationId,
    int? expectedRevision,
  }) => _readiness(
    programId: programId,
    legId: legId,
    action: 'unclaim',
    clientOperationId: clientOperationId,
    expectedRevision: expectedRevision,
    label: 'release the claim',
  );

  Future<ProgramMutationResult> markLegReady({
    required String programId,
    required String legId,
    required String clientOperationId,
    int? expectedRevision,
    DateTime? manualCurbAt,
    String? manualCurbNote,
  }) => _readiness(
    programId: programId,
    legId: legId,
    action: 'markReady',
    clientOperationId: clientOperationId,
    expectedRevision: expectedRevision,
    manualCurbAt: manualCurbAt,
    manualCurbNote: manualCurbNote,
    label: 'mark the guest ready',
  );

  Future<ProgramMutationResult> markLegDisrupted({
    required String programId,
    required String legId,
    required String clientOperationId,
    int? expectedRevision,
    DateTime? manualCurbAt,
    String? manualCurbNote,
  }) => _readiness(
    programId: programId,
    legId: legId,
    action: 'markDisrupted',
    clientOperationId: clientOperationId,
    expectedRevision: expectedRevision,
    manualCurbAt: manualCurbAt,
    manualCurbNote: manualCurbNote,
    label: 'flag the disruption',
  );

  Future<DispatchResult> dispatchTrip({
    required String programId,
    required String pickupPointId,
    required String vehicleClassId,
    required String plateDisplay,
    required List<String> legIds,
    required String clientOperationId,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
    List<({String legId, int revision})>? expectedLegRevisions,
    DateTime? departedAt,
    String? notes,
  }) => _call(
    name: 'dispatchProgramTrip',
    payload: DispatchProgramTripCallableRequest(
      programId: programId,
      pickupPointId: pickupPointId,
      destinationHotelId: destinationHotelId,
      destinationLabel: destinationLabel,
      vehicleClassId: vehicleClassId,
      plateDisplay: plateDisplay,
      vendorId: vendorId,
      legIds: legIds,
      expectedLegRevisions: expectedLegRevisions
          ?.map((fence) => {'legId': fence.legId, 'revision': fence.revision})
          .toList(growable: false),
      departedAtMillis: departedAt?.millisecondsSinceEpoch,
      notes: notes,
      clientOperationId: clientOperationId,
    ).toJson(),
    action: 'dispatch the vehicle',
    parse: DispatchResult.fromCallableData,
  );

  Future<ProgramMutationResult> markTripArrived({
    required String programId,
    required String tripId,
    required int expectedRevision,
    required String clientOperationId,
  }) => _tripAction(
    name: 'markProgramTripArrived',
    programId: programId,
    tripId: tripId,
    expectedRevision: expectedRevision,
    clientOperationId: clientOperationId,
    label: 'mark the trip arrived',
  );

  Future<ProgramMutationResult> voidTrip({
    required String programId,
    required String tripId,
    required int expectedRevision,
    required String reason,
    required String clientOperationId,
  }) => _tripAction(
    name: 'voidProgramTrip',
    programId: programId,
    tripId: tripId,
    expectedRevision: expectedRevision,
    reason: reason,
    clientOperationId: clientOperationId,
    label: 'void the trip',
  );

  Future<ProgramHotelInbound> getHotelInbound({
    required String programId,
    required String hotelId,
  }) => _call(
    name: 'getProgramHotelInbound',
    payload: GetProgramHotelInboundCallableRequest(
      programId: programId,
      hotelId: hotelId,
    ).toJson(),
    action: 'load the hotel inbound view',
    parse: ProgramHotelInbound.fromCallableData,
  );

  Future<ProgramTripList> listTrips(String programId) => _call(
    name: 'listProgramTrips',
    payload: ProgramIdCallableRequest(programId: programId).toJson(),
    action: 'load the trip ledger',
    parse: ProgramTripList.fromCallableData,
  );

  /// Vendor picker data for the dispatch sheet — the callable filters to
  /// vendors bound to this program and returns operational fields only.
  Future<List<ProgramVendorOption>> listVendors({
    required String organizerId,
    required String programId,
  }) => _call(
    name: 'listTransportVendors',
    payload: ListTransportVendorsCallableRequest(
      organizerId: organizerId,
      programId: programId,
    ).toJson(),
    action: 'load transport vendors',
    parse: (value) {
      final map = requiredMap(value, 'transport vendors');
      return mapList(map['vendors'], 'vendors')
          .map(
            (vendor) => ProgramVendorOption(
              vendorId: requiredString(vendor, 'vendorId'),
              name: requiredString(vendor, 'name'),
              active: vendor['active'] == true,
              boundToProgram: vendor['boundToProgram'] == true,
            ),
          )
          .toList(growable: false);
    },
  );

  Future<ProgramMutationResult> _readiness({
    required String programId,
    required String legId,
    required String action,
    required String clientOperationId,
    required String label,
    int? expectedRevision,
    DateTime? manualCurbAt,
    String? manualCurbNote,
  }) => _call(
    name: 'setProgramTravelReadiness',
    payload: SetProgramTravelReadinessCallableRequest(
      programId: programId,
      legId: legId,
      action: action,
      expectedRevision: expectedRevision,
      manualCurbAtMillis: manualCurbAt?.millisecondsSinceEpoch,
      manualCurbNote: manualCurbNote,
      clientOperationId: clientOperationId,
    ).toJson(),
    action: label,
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<ProgramMutationResult> _tripAction({
    required String name,
    required String programId,
    required String tripId,
    required int expectedRevision,
    required String clientOperationId,
    required String label,
    String? reason,
  }) => _call(
    name: name,
    payload: ProgramTripActionCallableRequest(
      programId: programId,
      tripId: tripId,
      reason: reason,
      expectedRevision: expectedRevision,
      clientOperationId: clientOperationId,
    ).toJson(),
    action: label,
    parse: ProgramMutationResult.fromCallableData,
  );

  Future<T> _call<T>({
    required String name,
    required Map<String, Object?> payload,
    required String action,
    required T Function(Object?) parse,
    String? snapshotScope,
    String? snapshotAccountId,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable(name)
          .call<Object?>(payload);
      if (snapshotScope != null && snapshotAccountId != null) {
        unawaited(
          _snapshots
              .save(snapshotAccountId, snapshotScope, result.data)
              .onError<Object>((_, _) => null),
        );
      }
      return parse(result.data);
    },
    context: BackendErrorContext(
      service: BackendService.functions,
      action: action,
      resource: name,
    ),
  );
}

// keepalive: the keep-alive operations outbox watches this repository, so it
// must outlive any individual screen subscription.
@Riverpod(keepAlive: true)
ProgramWorkRepository programWorkRepository(Ref ref) => ProgramWorkRepository(
  ref.watch(firebaseFunctionsProvider),
  ref.watch(programReadSnapshotStoreProvider),
);

@riverpod
Future<ProgramWorkAccess> programWorkAccess(Ref ref, String programId) => ref
    .read(programWorkRepositoryProvider)
    .getWorkAccess(
      programId,
      snapshotAccountId: ref.read(uidProvider).asData?.value,
    );

/// Work-shell entry: claims a staff invite when the deep link carries one,
/// then resolves access for the invite's program.
@riverpod
Future<ProgramWorkAccess> programWorkEntry(
  Ref ref,
  String programId,
  String? inviteId,
) async {
  final repository = ref.read(programWorkRepositoryProvider);
  final resolvedProgramId = inviteId == null || inviteId.isEmpty
      ? programId
      : await repository.claimStaffInvite(inviteId);
  return repository.getWorkAccess(
    resolvedProgramId,
    snapshotAccountId: ref.read(uidProvider).asData?.value,
  );
}

@riverpod
Future<ProgramArrivalsRoster> programArrivalsRoster(
  Ref ref,
  String programId,
  String? pickupPointId,
) => ref
    .read(programWorkRepositoryProvider)
    .getArrivalsRoster(
      programId: programId,
      pickupPointId: pickupPointId,
      snapshotAccountId: ref.read(uidProvider).asData?.value,
    );

/// Roster with offline fallback: a live failure resolves to the last saved
/// snapshot for this station, marked with its capture time so the UI can
/// label it as saved data rather than live.
@riverpod
Future<({ProgramArrivalsRoster roster, DateTime? snapshotAt})>
programArrivalsRosterView(
  Ref ref,
  String programId,
  String? pickupPointId,
) async {
  try {
    final roster = await ref.watch(
      programArrivalsRosterProvider(programId, pickupPointId).future,
    );
    return (roster: roster, snapshotAt: null);
  } on Object {
    final accountId = ref.read(uidProvider).asData?.value;
    if (accountId == null || accountId.isEmpty) rethrow;
    final snapshot = await ref
        .read(programReadSnapshotStoreProvider)
        .load(
          accountId,
          programSnapshotScope('arrivals', programId, pickupPointId),
        );
    if (snapshot == null) rethrow;
    return (
      roster: ProgramArrivalsRoster.fromCallableData(snapshot.data),
      snapshotAt: snapshot.savedAt,
    );
  }
}

@riverpod
Future<ProgramTransportPlan> programTransportPlan(
  Ref ref,
  String programId,
  String? pickupPointId,
) => ref
    .read(programWorkRepositoryProvider)
    .getTransportPlan(
      programId: programId,
      pickupPointId: pickupPointId,
      snapshotAccountId: ref.read(uidProvider).asData?.value,
    );

/// Transport plan with the same snapshot fallback as the roster.
@riverpod
Future<({ProgramTransportPlan plan, DateTime? snapshotAt})>
programTransportPlanView(
  Ref ref,
  String programId,
  String? pickupPointId,
) async {
  try {
    final plan = await ref.watch(
      programTransportPlanProvider(programId, pickupPointId).future,
    );
    return (plan: plan, snapshotAt: null);
  } on Object {
    final accountId = ref.read(uidProvider).asData?.value;
    if (accountId == null || accountId.isEmpty) rethrow;
    final snapshot = await ref
        .read(programReadSnapshotStoreProvider)
        .load(
          accountId,
          programSnapshotScope('plan', programId, pickupPointId),
        );
    if (snapshot == null) rethrow;
    return (
      plan: ProgramTransportPlan.fromCallableData(snapshot.data),
      snapshotAt: snapshot.savedAt,
    );
  }
}

@riverpod
Future<ProgramHotelInbound> programHotelInbound(
  Ref ref,
  String programId,
  String hotelId,
) => ref
    .read(programWorkRepositoryProvider)
    .getHotelInbound(programId: programId, hotelId: hotelId);

@riverpod
Future<ProgramTripList> programTripList(Ref ref, String programId) =>
    ref.read(programWorkRepositoryProvider).listTrips(programId);

@riverpod
Future<List<ProgramVendorOption>> programTransportVendors(
  Ref ref,
  String organizerId,
  String programId,
) => ref
    .read(programWorkRepositoryProvider)
    .listVendors(organizerId: organizerId, programId: programId);
