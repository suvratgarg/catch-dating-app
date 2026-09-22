import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/programs/data/program_operations_outbox.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_arrivals_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_dispatch_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_hotel_desk_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_trips_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_work_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../support/page_preview.dart';
import '../support/widgetbook_harness.dart';
import '../utility/preview.dart';

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
    capabilities: {ProgramVehicleCapability.premium},
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
  duties: const [
    ProgramDutyAssignment(
      duty: ProgramStaffDuty.airportGreeter,
      pickupPointIds: {'del_t3'},
      hotelIds: {},
    ),
    ProgramDutyAssignment(
      duty: ProgramStaffDuty.transportDispatcher,
      pickupPointIds: {'del_t3'},
      hotelIds: {},
    ),
  ],
  grantExpiresAt: null,
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

final _trips = ProgramTripList(programId: _programId, trips: [_trip]);

List<Override> _programOverrides() {
  return [
    uidProvider.overrideWithValue(const AsyncData<String?>('uid_greeter')),
    isObviouslyOfflineProvider.overrideWithValue(false),
    programWorkAccessProvider(
      _programId,
    ).overrideWithValue(AsyncData(_access)),
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
    programTripListProvider(
      _programId,
    ).overrideWithValue(AsyncData(_trips)),
    programTransportVendorsProvider(
      _programId,
      _pickupPointId,
    ).overrideWithValue(
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
            child: const ProgramWorkScreen(programId: _programId),
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
      child: ProgramWorkPageBody(access: _access),
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
        queuedAction: null,
        onAction: (_, action, {manualCurbNote}) async {},
      ),
      ProgramArrivalRow(
        row: _roster.rows[2],
        queuedAction: 'markReady',
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
        programId: _programId,
        pickupPointId: _pickupPointId,
        organizerId: 'org_1',
        group: _plan.groups.first,
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
        child: ProgramHotelInboundTripTile(trip: _trip, inbound: _inbound),
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
        child: ProgramTripLedgerRow(trip: _trip, programId: _programId),
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
