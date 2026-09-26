import 'package:catch_dating_app/programs/data/program_projection_lifetime.dart';
import '../support/page_preview.dart';
import '../support/widgetbook_harness.dart';
import '../utility/preview.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/core/persistence/memory_command_journal_storage.dart';
import 'package:catch_dating_app/programs/data/program_operations_outbox.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/domain/travel_leg_revision.dart';
import 'package:catch_dating_app/programs/presentation/program_arrivals_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_dispatch_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_door_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_hotel_desk_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_operations_controller.dart';
import 'package:catch_dating_app/programs/presentation/program_operations_notice.dart';
import 'package:catch_dating_app/programs/presentation/program_trips_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_work_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _programId = 'program_kapoor_shah';
const _pickupPointId = 'del_t3';
const _hotelId = 'hotel_taj';

final _now = DateTime(2026, 2, 14, 14, 30);

final _vehicleClasses = <ProgramVehicleClass>[
  const ProgramVehicleClass(
    id: 'sedan',
    label: 'Sedan',
    passengerCapacity: 3,
    luggageCapacity: 4,
    capabilities: {},
    sortOrder: 0,
  ),
  const ProgramVehicleClass(
    id: 'innova',
    label: 'Innova',
    passengerCapacity: 6,
    luggageCapacity: 8,
    capabilities: {ProgramVehicleCapability.extraLuggage},
    sortOrder: 1,
  ),
];

final _access = ProgramWorkAccess(
  programId: _programId,
  organizerId: 'org_1',
  title: 'Kapoor–Shah Wedding',
  kind: ProgramKind.wedding,
  timezone: 'Asia/Kolkata',
  status: ProgramStatus.active,
  actorRole: ProgramActorRole.staff,
  duties: [
    ProgramDutyAssignment(
      duty: ProgramStaffDuty.airportGreeter,
      pickupPointIds: {'del_t3'},
      hotelIds: {},
      functionIds: {},
      expiresAt: _now.add(const Duration(hours: 8)),
    ),
    ProgramDutyAssignment(
      duty: ProgramStaffDuty.transportDispatcher,
      pickupPointIds: {'del_t3'},
      hotelIds: {},
      functionIds: {},
      expiresAt: _now.add(const Duration(hours: 8)),
    ),
    ProgramDutyAssignment(
      duty: ProgramStaffDuty.functionCheckIn,
      pickupPointIds: {},
      hotelIds: {},
      functionIds: {'fn_sangeet'},
      expiresAt: _now.add(const Duration(hours: 8)),
    ),
  ],
  grantExpiresAt: _now.add(const Duration(hours: 8)),
  capabilities: const {'arrivalsTransport'},
  pickupPoints: const [
    ProgramStation(
      pickupPointId: 'del_t3',
      label: 'DEL Terminal 3 arrivals',
      kind: 'airportArrival',
      iataCode: 'DEL',
      terminal: 'T3',
    ),
  ],
  hotels: const [ProgramHotel(hotelId: 'hotel_taj', name: 'Taj Palace')],
  functions: [
    ProgramFunction(
      functionId: 'fn_sangeet',
      name: 'Sangeet',
      venueName: 'The Leela Ballroom',
      startsAt: _now.add(const Duration(hours: 3)),
      endsAt: _now.add(const Duration(hours: 6)),
      checkInEnabled: true,
      status: ProgramFunctionStatus.scheduled,
      expectedCount: 12,
      checkedInCount: 4,
    ),
  ],
  vehicleClasses: _vehicleClasses,
);

ArrivalsRosterRow _row({
  required String legId,
  required String name,
  required int passengers,
  required TravelLegReadiness readiness,
  TravelLegFlightStatus flight = TravelLegFlightStatus.landed,
  CurbSource? curbSource = CurbSource.actualLanding,
  Duration curbOffset = Duration.zero,
  String? claimedByDisplay,
  TimingUnavailableReason? unavailableReason,
}) {
  return ArrivalsRosterRow(
    legId: legId,
    guestId: 'guest_$legId',
    partyId: 'party_$legId',
    guestDisplayName: name,
    partyLabel: '$name party',
    partyGuestIds: const [],
    passengers: passengers,
    luggageUnits: passengers + 1,
    flightNumber: 'AI-847',
    originIata: 'BOM',
    arrivalTerminal: '3',
    flightStatus: flight,
    curbAt: unavailableReason == null ? _now.add(curbOffset) : null,
    curbSource: curbSource,
    unavailableReason: unavailableReason,
    readiness: readiness,
    claimedByDisplay: claimedByDisplay,
    claimedByMe: claimedByDisplay != null,
    destinationHotelId: _hotelId,
    destinationLabel: 'Taj Palace',
    requiredCapabilities: const {},
    dedicatedVehicle: false,
    revision: 1,
  );
}

final _roster = ProgramArrivalsRoster(
  accessExpiresAt: _now.add(const Duration(hours: 8)),
  programId: _programId,
  pickupPointId: _pickupPointId,
  generatedAt: _now,
  rows: [
    _row(
      legId: 'leg_rohan',
      name: 'Rohan Sharma',
      passengers: 3,
      readiness: TravelLegReadiness.ready,
      curbSource: CurbSource.ready,
      claimedByDisplay: 'Arjun',
    ),
    _row(
      legId: 'leg_rao',
      name: 'Nisha Rao',
      passengers: 2,
      readiness: TravelLegReadiness.expected,
      curbOffset: const Duration(minutes: 12),
    ),
    _row(
      legId: 'leg_mathew',
      name: 'Anita Mathew',
      passengers: 4,
      readiness: TravelLegReadiness.disrupted,
      flight: TravelLegFlightStatus.cancelled,
      curbSource: null,
      unavailableReason: TimingUnavailableReason.cancelled,
    ),
  ],
  vehicleClasses: _vehicleClasses,
);

final _plan = ProgramTransportPlan(
  accessExpiresAt: _now.add(const Duration(hours: 8)),
  programId: _programId,
  pickupPointId: _pickupPointId,
  generatedAt: _now,
  groups: [
    TransportGroupSuggestion(
      legIds: const ['leg_rohan', 'leg_rao'],
      partyIds: const ['party_rohan', 'party_rao'],
      destinationHotelId: _hotelId,
      destinationLabel: 'Taj Palace',
      readiness: TransportGroupReadiness.ready,
      vehicleClassId: 'innova',
      vehicleClassLabel: 'Innova',
      passengers: 5,
      luggageUnits: 7,
      earliestCurbAt: _now,
      latestCurbAt: _now.add(const Duration(minutes: 12)),
      dispatchBy: _now.add(const Duration(minutes: 10)),
      waitOverdue: false,
    ),
  ],
  unassigned: const [],
);

final _trip = ProgramTripSummary(
  manifestSource: TransportManifestSource.dispatchSnapshot,
  vehicleClassLabel: 'Innova / SUV',
  tripId: 'trip_1',
  pickupPointId: _pickupPointId,
  destinationHotelId: _hotelId,
  destinationLabel: 'Taj Palace',
  vehicleClassId: 'innova',
  plateDisplay: 'DL-1T-4421',
  vendorId: 'vendor_meru',
  vendorName: 'Meru Cabs',
  status: TransportTripStatus.enRoute,
  passengerCount: 5,
  departedAt: _now.subtract(const Duration(minutes: 12)),
  arrivedAt: null,
  estimatedArriveAt: _now.add(const Duration(minutes: 35)),
  voidReason: null,
  guestNames: const ['Rohan Sharma', 'Nisha Rao', 'Vikram Rao'],
  revision: 1,
);

final _inbound = ProgramHotelInbound(
  nextTripCursor: null,
  nextExpectedCursor: null,
  accessExpiresAt: _now.add(const Duration(hours: 8)),
  programId: _programId,
  hotelId: _hotelId,
  hotelName: 'Taj Palace',
  generatedAt: _now,
  trips: [_trip],
  expectedLegs: [
    HotelExpectedLeg(
      legId: 'leg_rao',
      guestDisplayName: 'Nisha Rao',
      partyLabel: 'Nisha Rao party',
      passengers: 2,
      curbAt: _now.add(const Duration(minutes: 12)),
      readiness: TravelLegReadiness.expected,
    ),
  ],
);

final _trips = ProgramTripList(
  nextCursor: null,
  accessExpiresAt: _now.add(const Duration(hours: 8)),
  programId: _programId,
  trips: [_trip],
);

const _functionId = 'fn_sangeet';

ProgramDoorGuest _doorGuest(
  String id,
  String name, {
  ProgramRsvpStatus rsvp = ProgramRsvpStatus.attending,
  ProgramFunctionAttendanceStatus attendance =
      ProgramFunctionAttendanceStatus.expected,
  int? partySize,
  String? householdLabel,
  bool invited = true,
}) => ProgramDoorGuest(
  guestId: id,
  displayName: name,
  invited: invited,
  rsvpStatus: rsvp,
  attendanceStatus: attendance,
  partySize: partySize,
  householdLabel: householdLabel,
);

final _doorView = ProgramDoorView(
  programId: _programId,
  functionId: _functionId,
  serverTime: _now,
  accessExpiresAt: _now.add(const Duration(hours: 8)),
  function: ProgramDoorFunction(
    name: 'Sangeet',
    invitationMode: ProgramFunctionInvitationMode.selectedGuests,
    checkInEnabled: true,
    status: ProgramFunctionStatus.scheduled,
    startsAt: _now.add(const Duration(hours: 3)),
    endsAt: _now.add(const Duration(hours: 6)),
    venueName: 'The Leela Ballroom',
    dressCode: 'Festive',
    expectedCount: 12,
    checkedInCount: 4,
  ),
  counts: const ProgramDoorCounts(
    listedCount: 3,
    expectedHeads: 12,
    checkedInHeads: 4,
    checkedInParties: 1,
    noShowCount: 0,
    walkInCount: 1,
  ),
  guests: [
    _doorGuest(
      'g_rohan',
      'Rohan Sharma',
      attendance: ProgramFunctionAttendanceStatus.checkedIn,
      partySize: 3,
      householdLabel: 'Sharma household',
    ),
    _doorGuest(
      'g_nisha',
      'Nisha Rao',
      partySize: 2,
      householdLabel: 'Rao household',
    ),
    _doorGuest(
      'g_walk',
      'Priya Kapoor',
      rsvp: ProgramRsvpStatus.pending,
      attendance: ProgramFunctionAttendanceStatus.checkedIn,
      invited: false,
    ),
  ],
  journal: [
    ProgramDoorJournalEntry(
      journalId: 'j1',
      guestId: 'g_rohan',
      displayName: 'Rohan Sharma',
      action: ProgramDoorAction.checkIn,
      occurredAt: _now.subtract(const Duration(minutes: 4)),
      partySize: 3,
      actorLabel: 'Arjun',
    ),
    ProgramDoorJournalEntry(
      journalId: 'j2',
      guestId: 'g_walk',
      displayName: 'Priya Kapoor',
      action: ProgramDoorAction.walkInCreate,
      occurredAt: _now.subtract(const Duration(minutes: 9)),
      actorLabel: 'Dev',
    ),
  ],
);

ProgramOperationOutboxStore _previewJournal() {
  final storage = MemoryCommandJournalStorage();
  return createProgramOperationJournal(
    storage: () async => storage,
    currentAccountId: () => 'uid_greeter',
  );
}

class _PreviewMutator implements ProgramOperationsMutator {
  @override
  Future<ProgramMutationResult> setReadiness({
    required String programId,
    required String legId,
    required String action,
    required String clientOperationId,
    required int expectedRevision,
    required DateTime observedAt,
    TravelLegObservationReference? afterObservation,
    int? manualCurbAtMillis,
    String? manualCurbNote,
  }) async => const ProgramMutationResult(
    entityId: 'leg',
    revision: 2,
    alreadyApplied: false,
  );

  @override
  Future<DispatchResult> dispatchTrip({
    required String programId,
    required String pickupPointId,
    required String vehicleClassId,
    required String plateDisplay,
    required List<String> legIds,
    required DateTime departedAt,
    required String clientOperationId,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
    required List<DispatchLegRevision> expectedLegRevisions,
  }) async => const DispatchResult(
    tripId: 'trip_preview',
    revision: 1,
    alreadyApplied: false,
    passengerCount: 0,
  );

  @override
  Future<ProgramDoorJournalBatch> recordDoorAction({
    required String programId,
    required String functionId,
    required Map<String, Object?> operation,
  }) async => const ProgramDoorJournalBatch(
    entityId: 'fn',
    revision: 2,
    results: [],
    appendedCount: 1,
    duplicateCount: 0,
    rejectedCount: 0,
    alreadyApplied: false,
  );

  @override
  Future<ProgramMutationResult> createWalkIn({
    required String programId,
    required String functionId,
    required String displayName,
    required DateTime occurredAt,
    required String clientOperationId,
    int? partySize,
    String? note,
  }) async => const ProgramMutationResult(
    entityId: 'guest',
    revision: 1,
    alreadyApplied: false,
  );
}

List<Override> _programOverrides() {
  return [
    programProjectionClockProvider.overrideWithValue(() => _now),
    uidProvider.overrideWithValue(const AsyncData<String?>('uid_greeter')),
    programOperationsOutboxProvider.overrideWithValue(
      ProgramOperationsOutbox(_previewJournal(), _PreviewMutator()),
    ),
    isObviouslyOfflineProvider.overrideWithValue(false),
    programWorkEntryProvider(_programId, null).overrideWithValue(
      AsyncData((value: _access, snapshotAt: null, snapshotExpiresAt: null)),
    ),
    programArrivalsRosterProvider(
      _programId,
      _pickupPointId,
    ).overrideWithValue(AsyncData(_roster)),
    programTransportPlanProvider(
      _programId,
      _pickupPointId,
    ).overrideWithValue(AsyncData(_plan)),
    programHotelInboundProvider(
      _programId,
      _hotelId,
    ).overrideWithValue(AsyncData(_inbound)),
    programTripListProvider(_programId).overrideWithValue(AsyncData(_trips)),
    programFunctionDoorViewProvider(
      _programId,
      _functionId,
    ).overrideWithValue(AsyncData(_doorView)),
    programFunctionDoorViewWithSnapshotProvider(
      _programId,
      _functionId,
    ).overrideWithValue(
      AsyncData((value: _doorView, snapshotAt: null, snapshotExpiresAt: null)),
    ),
    programTransportVendorsProvider('org_1', _programId).overrideWithValue(
      const AsyncData(<ProgramVendorOption>[
        ProgramVendorOption(
          vendorId: 'vendor_meru',
          name: 'Meru Cabs',
          active: true,
          boundToProgram: true,
        ),
      ]),
    ),
  ];
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ProgramWorkScreen,
  path: '[P1 product surfaces]/Program work',
)
Widget programWorkScreenStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramWorkScreen',
    contractId: 'screen.programs.work',
    children: [
      WidgetbookPageStateCard(
        label: 'staff access',
        child: WidgetbookUtilityDeviceFrame(
          child: ProviderScope(
            overrides: _programOverrides(),
            child: ProgramWorkScreen(programId: _programId, now: () => _now),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ProgramArrivalsScreen,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programArrivalsScreenStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramArrivalsScreen',
    contractId: 'screen.programs.arrivals',
    children: [
      WidgetbookPageStateCard(
        label: 'station roster',
        child: WidgetbookUtilityDeviceFrame(
          child: ProviderScope(
            overrides: _programOverrides(),
            child: const ProgramArrivalsScreen(
              programId: _programId,
              pickupPointId: _pickupPointId,
              stationLabel: 'DEL Terminal 3 arrivals',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ProgramDispatchScreen,
  path: '[P1 product surfaces]/Program dispatch',
)
Widget programDispatchScreenStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramDispatchScreen',
    contractId: 'screen.programs.dispatch',
    children: [
      WidgetbookPageStateCard(
        label: 'suggested groups',
        child: WidgetbookUtilityDeviceFrame(
          child: ProviderScope(
            overrides: _programOverrides(),
            child: const ProgramDispatchScreen(
              programId: _programId,
              pickupPointId: _pickupPointId,
              stationLabel: 'DEL Terminal 3 arrivals',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ProgramHotelDeskScreen,
  path: '[P1 product surfaces]/Program hotel desk',
)
Widget programHotelDeskScreenStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramHotelDeskScreen',
    contractId: 'screen.programs.hotel_desk',
    children: [
      WidgetbookPageStateCard(
        label: 'inbound view',
        child: WidgetbookUtilityDeviceFrame(
          child: ProviderScope(
            overrides: _programOverrides(),
            child: const ProgramHotelDeskScreen(
              programId: _programId,
              hotelId: _hotelId,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ProgramTripsScreen,
  path: '[P1 product surfaces]/Program trips',
)
Widget programTripsScreenStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramTripsScreen',
    contractId: 'screen.programs.trips',
    children: [
      WidgetbookPageStateCard(
        label: 'ledger',
        child: WidgetbookUtilityDeviceFrame(
          child: ProviderScope(
            overrides: _programOverrides(),
            child: const ProgramTripsScreen(programId: _programId),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body states',
  type: ProgramWorkPageBody,
  path: '[P1 product surfaces]/Program work',
)
Widget programWorkPageBodyStates(BuildContext context) {
  return WidgetbookUtilityDeviceFrame(
    child: ProviderScope(
      overrides: _programOverrides(),
      child: ProgramWorkPageBody(access: _access, now: _now),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Row states',
  type: ProgramArrivalRow,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programArrivalRowStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramArrivalRow',
    catalogId: 'screen.programs.arrivals',
    children: [
      ProgramArrivalRow(
        row: _roster.rows[0],
        queuedStatus: null,
        onAction: (_, action, {manualCurbNote}) async {},
      ),
      ProgramArrivalRow(
        row: _roster.rows[2],
        queuedStatus: ProgramOperationOutboxStatus.pending,
        onAction: (_, action, {manualCurbNote}) async {},
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Badge states',
  type: ProgramArrivalReadinessBadge,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programArrivalReadinessBadgeStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramArrivalReadinessBadge',
    catalogId: 'screen.programs.arrivals',
    children: [
      ProgramArrivalReadinessBadge(row: _roster.rows[0]),
      ProgramArrivalReadinessBadge(row: _roster.rows[1]),
      ProgramArrivalReadinessBadge(row: _roster.rows[2]),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Menu states',
  type: ProgramArrivalActionMenu,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programArrivalActionMenuStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramArrivalActionMenu',
    catalogId: 'screen.programs.arrivals',
    children: [
      ProgramArrivalActionMenu(
        row: _roster.rows[0],
        queued: true,
        onAction: (_, action, {manualCurbNote}) async {},
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Banner states',
  type: ProgramArrivalsOutboxBanner,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programArrivalsOutboxBannerStates(BuildContext context) {
  return const WidgetbookCatalogFrame(
    title: 'ProgramArrivalsOutboxBanner',
    catalogId: 'screen.programs.arrivals',
    children: [
      ProgramArrivalsOutboxBanner(
        outbox: ProgramOperationOutboxSummary([]),
        busy: false,
        onFlush: _noop,
        onClearReview: _noop,
      ),
    ],
  );
}

void _noop() {}

@widgetbook.UseCase(
  name: 'Tile states',
  type: ProgramDispatchGroupTile,
  path: '[P1 product surfaces]/Program dispatch',
)
Widget programDispatchGroupTileStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramDispatchGroupTile',
    catalogId: 'screen.programs.dispatch',
    children: [
      ProgramDispatchGroupTile(group: _plan.groups.first, onDispatch: _noop),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: ProgramDispatchSheet,
  path: '[P1 product surfaces]/Program dispatch',
)
Widget programDispatchSheetStates(BuildContext context) {
  return WidgetbookUtilitySheetFrame(
    child: ProviderScope(
      overrides: _programOverrides(),
      child: ProgramDispatchSheet(
        authorityGeneration: 0,
        accessExpiresAt: _now.add(const Duration(hours: 8)),
        accountId: 'uid_greeter',
        programId: _programId,
        pickupPointId: _pickupPointId,
        organizerId: 'org_1',
        group: _plan.groups.first,
        holdCandidates: const [],
        vehicleClasses: _vehicleClasses,
        onDispatched: (_, error) {},
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Tile states',
  type: ProgramHotelInboundTripTile,
  path: '[P1 product surfaces]/Program hotel desk',
)
Widget programHotelInboundTripTileStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramHotelInboundTripTile',
    catalogId: 'screen.programs.hotel_desk',
    children: [
      ProviderScope(
        overrides: _programOverrides(),
        child: ProgramHotelInboundTripTile(
          trip: _trip,
          inbound: _inbound,
          onChanged: () {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row states',
  type: ProgramTripLedgerRow,
  path: '[P1 product surfaces]/Program trips',
)
Widget programTripLedgerRowStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramTripLedgerRow',
    catalogId: 'screen.programs.trips',
    children: [
      ProviderScope(
        overrides: _programOverrides(),
        child: ProgramTripLedgerRow(
          trip: _trip,
          programId: _programId,
          onChanged: () {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: ProgramTripVoidSheet,
  path: '[P1 product surfaces]/Program trips',
)
Widget programTripVoidSheetStates(BuildContext context) {
  return const WidgetbookUtilitySheetFrame(child: ProgramTripVoidSheet());
}

ProgramOperationsState _reviewOperationsState() => ProgramOperationsState(
  outbox: ProgramOperationOutboxSummary([
    ProgramOperationOutboxEntry.legObservation(
      programId: _programId,
      legId: _roster.rows.first.legId,
      action: 'markReady',
      clientOperationId: 'review-preview',
      createdAt: _now,
      expectedRevision: 1,
    ).copyWith(status: ProgramOperationOutboxStatus.needsReview),
  ]),
);

@widgetbook.UseCase(
  name: 'Notice states',
  type: ProgramOperationsNotice,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programOperationsNoticeStates(BuildContext context) => ProviderScope(
  overrides: [
    ..._programOverrides(),
    programOperationsStateProvider(
      _programId,
    ).overrideWithValue(AsyncData(_reviewOperationsState())),
  ],
  child: WidgetbookCatalogFrame(
    title: 'ProgramOperationsNotice',
    catalogId: 'screen.programs.arrivals',
    children: [
      const ProgramOperationsNotice(
        programId: _programId,
        pickupPointId: _pickupPointId,
      ),
      ProviderScope(
        overrides: [
          programOperationsStateProvider(_programId).overrideWithValue(
            const AsyncData(
              ProgramOperationsState(
                error: ValidationException(
                  'Damaged demo journal',
                  code: 'local-journal-quarantined',
                ),
              ),
            ),
          ),
          programOperationsOutboxProvider.overrideWithValue(
            ProgramOperationsOutbox(
              createProgramOperationJournal(
                storage: () async => MemoryCommandJournalStorage(),
                currentAccountId: () => 'uid_greeter',
                loadLegacy: (_) async => 'damaged synthetic demo record',
              ),
              _PreviewMutator(),
            ),
          ),
        ],
        child: const ProgramOperationsNotice(
          programId: _programId,
          pickupPointId: _pickupPointId,
        ),
      ),
    ],
  ),
);

@widgetbook.UseCase(
  name: 'Review states',
  type: ProgramOperationReviewSheet,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programOperationReviewSheetStates(BuildContext context) =>
    WidgetbookUtilitySheetFrame(
      child: ProviderScope(
        overrides: [
          ..._programOverrides(),
          programOperationsStateProvider(
            _programId,
          ).overrideWithValue(AsyncData(_reviewOperationsState())),
        ],
        child: const ProgramOperationReviewSheet(
          programId: _programId,
          accountId: 'uid_greeter',
          pickupPointId: _pickupPointId,
        ),
      ),
    );

@widgetbook.UseCase(
  name: 'Preserved local work',
  type: ProgramJournalRecoverySheet,
  path: '[P1 product surfaces]/Program arrivals',
)
Widget programJournalRecoverySheetPreview(BuildContext context) =>
    WidgetbookUtilitySheetFrame(
      child: ProviderScope(
        overrides: [
          ..._programOverrides(),
          programOperationsOutboxProvider.overrideWithValue(
            ProgramOperationsOutbox(
              createProgramOperationJournal(
                storage: () async => MemoryCommandJournalStorage(),
                currentAccountId: () => 'uid_greeter',
                loadLegacy: (_) async => 'damaged synthetic demo record',
              ),
              _PreviewMutator(),
            ),
          ),
        ],
        child: const ProgramJournalRecoverySheet(accountId: 'uid_greeter'),
      ),
    );

@widgetbook.UseCase(
  name: 'Screen states',
  type: ProgramFunctionDoorScreen,
  path: '[P1 product surfaces]/Program door',
)
Widget programDoorScreenStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramFunctionDoorScreen',
    contractId: 'screen.programs.door',
    children: [
      WidgetbookPageStateCard(
        label: 'open door',
        child: WidgetbookUtilityDeviceFrame(
          child: ProviderScope(
            overrides: _programOverrides(),
            child: const ProgramFunctionDoorScreen(
              programId: _programId,
              functionId: _functionId,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row states',
  type: ProgramDoorGuestRow,
  path: '[P1 product surfaces]/Program door',
)
Widget programDoorGuestRowStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramDoorGuestRow',
    catalogId: 'screen.programs.door',
    children: [
      ProgramDoorGuestRow(
        guest: _doorView.guests[0],
        doorOpen: true,
        queuedStatus: null,
        onAction: (_) {},
      ),
      ProgramDoorGuestRow(
        guest: _doorView.guests[1],
        doorOpen: true,
        queuedStatus: ProgramOperationOutboxStatus.pending,
        onAction: (_) {},
      ),
      ProgramDoorGuestRow(
        guest: _doorView.guests[2],
        doorOpen: false,
        queuedStatus: null,
        onAction: (_) {},
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: ProgramDoorPartySizeSheet,
  path: '[P1 product surfaces]/Program door',
)
Widget programDoorPartySizeSheetStates(BuildContext context) {
  return WidgetbookUtilitySheetFrame(
    child: ProgramDoorPartySizeSheet(guest: _doorView.guests[0]),
  );
}

@widgetbook.UseCase(
  name: 'Body states',
  type: ProgramDoorPageBody,
  path: '[P1 product surfaces]/Program door',
)
Widget programDoorPageBodyStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramDoorPageBody',
    contractId: 'screen.programs.door',
    children: [
      WidgetbookPageStateCard(
        label: 'open roster',
        child: WidgetbookUtilityDeviceFrame(
          child: ProgramDoorPageBody(
            view: _doorView,
            programId: _programId,
            outbox: const ProgramOperationOutboxSummary([]),
            operationsBusy: false,
            showOperationsNotice: false,
            walkInName: TextEditingController(),
            walkInPartySize: TextEditingController(),
            onGuestAction: (_, action) {},
            onSubmitWalkIn: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Badge states',
  type: ProgramDoorAttendanceBadge,
  path: '[P1 product surfaces]/Program door',
)
Widget programDoorAttendanceBadgeStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramDoorAttendanceBadge',
    catalogId: 'screen.programs.door',
    children: const [
      ProgramDoorAttendanceBadge(
        status: ProgramFunctionAttendanceStatus.expected,
      ),
      ProgramDoorAttendanceBadge(
        status: ProgramFunctionAttendanceStatus.checkedIn,
      ),
      ProgramDoorAttendanceBadge(
        status: ProgramFunctionAttendanceStatus.noShow,
      ),
    ],
  );
}
