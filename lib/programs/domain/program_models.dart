/// Domain projections for private wedding/corporate programs and the
/// airport-arrivals transport workspace.
///
/// Every class parses only the fields the scoped callable actually returns;
/// operational projections never carry contact data.
library;

enum ProgramKind { wedding, corporateOffsite, other }

enum ProgramStatus { draft, active, completed, cancelled }

enum ProgramActorRole { manager, staff }

enum ProgramStaffDuty {
  programCoordinator,
  airportGreeter,
  hotelDesk,
  transportDispatcher,
  reconciliationViewer,
}

enum ProgramVehicleCapability {
  wheelchairAccessible,
  extraLuggage,
  childSeat,
  premium,
}

class ProgramVehicleClass {
  const ProgramVehicleClass({
    required this.id,
    required this.label,
    required this.passengerCapacity,
    required this.luggageCapacity,
    required this.capabilities,
    required this.sortOrder,
  });

  factory ProgramVehicleClass.fromMap(Map<Object?, Object?> map) =>
      ProgramVehicleClass(
        id: requiredString(map, 'id'),
        label: requiredString(map, 'label'),
        passengerCapacity: requiredInt(map, 'passengerCapacity'),
        luggageCapacity: requiredInt(map, 'luggageCapacity'),
        capabilities: stringList(
          map['capabilities'],
        ).map(ProgramVehicleCapability.values.byName).toSet(),
        sortOrder: requiredInt(map, 'sortOrder'),
      );

  final String id;
  final String label;
  final int passengerCapacity;
  final int luggageCapacity;
  final Set<ProgramVehicleCapability> capabilities;
  final int sortOrder;
}

class ProgramDutyAssignment {
  const ProgramDutyAssignment({
    required this.duty,
    required this.pickupPointIds,
    required this.hotelIds,
    this.expiresAt,
  });

  factory ProgramDutyAssignment.fromMap(Map<Object?, Object?> map) =>
      ProgramDutyAssignment(
        duty: ProgramStaffDuty.values.byName(requiredString(map, 'duty')),
        pickupPointIds: stringList(map['pickupPointIds']).toSet(),
        hotelIds: stringList(map['hotelIds']).toSet(),
        expiresAt: nullableDateTime(map['expiresAtMillis']),
      );

  final ProgramStaffDuty duty;
  final Set<String> pickupPointIds;
  final Set<String> hotelIds;

  /// Null is an ungranted request scope or a legacy assignment, never authority.
  final DateTime? expiresAt;

  bool isActiveAt(DateTime now) =>
      expiresAt != null &&
      expiresAt!.isAfter(now) &&
      (duty != ProgramStaffDuty.programCoordinator ||
          (pickupPointIds.isEmpty && hotelIds.isEmpty)) &&
      (duty != ProgramStaffDuty.hotelDesk || pickupPointIds.isEmpty);

  bool get coversAllStations => pickupPointIds.isEmpty;
  bool get coversAllHotels => hotelIds.isEmpty;
  bool coversPickupPoint(String id) =>
      pickupPointIds.isEmpty || pickupPointIds.contains(id);
  bool coversHotel(String id) => hotelIds.isEmpty || hotelIds.contains(id);
}

class ProgramStation {
  const ProgramStation({
    required this.pickupPointId,
    required this.label,
    required this.kind,
    this.iataCode,
    this.terminal,
  });

  factory ProgramStation.fromMap(Map<Object?, Object?> map) => ProgramStation(
    pickupPointId: requiredString(map, 'pickupPointId'),
    label: requiredString(map, 'label'),
    kind: requiredString(map, 'kind'),
    iataCode: map['iataCode'] as String?,
    terminal: map['terminal'] as String?,
  );

  final String pickupPointId;
  final String label;
  final String kind;
  final String? iataCode;
  final String? terminal;
}

class ProgramHotel {
  const ProgramHotel({required this.hotelId, required this.name});

  factory ProgramHotel.fromMap(Map<Object?, Object?> map) => ProgramHotel(
    hotelId: requiredString(map, 'hotelId'),
    name: requiredString(map, 'name'),
  );

  final String hotelId;
  final String name;
}

class ProgramWorkAccess {
  const ProgramWorkAccess({
    required this.programId,
    required this.organizerId,
    required this.title,
    required this.kind,
    required this.timezone,
    required this.status,
    required this.actorRole,
    required this.duties,
    required this.grantExpiresAt,
    required this.capabilities,
    required this.pickupPoints,
    required this.hotels,
    required this.vehicleClasses,
  });

  factory ProgramWorkAccess.fromCallableData(Object? value) {
    final map = requiredMap(value, 'program work access');
    return ProgramWorkAccess(
      programId: requiredString(map, 'programId'),
      organizerId: requiredString(map, 'organizerId'),
      title: requiredString(map, 'title'),
      kind: ProgramKind.values.byName(requiredString(map, 'kind')),
      timezone: requiredString(map, 'timezone'),
      status: ProgramStatus.values.byName(requiredString(map, 'status')),
      actorRole: ProgramActorRole.values.byName(
        requiredString(map, 'actorRole'),
      ),
      duties: mapList(
        map['duties'],
        'duties',
      ).map(ProgramDutyAssignment.fromMap).toList(growable: false),
      grantExpiresAt: nullableDateTime(map['grantExpiresAtMillis']),
      capabilities: stringList(map['capabilities']).toSet(),
      pickupPoints: mapList(
        map['pickupPoints'],
        'pickupPoints',
      ).map(ProgramStation.fromMap).toList(growable: false),
      hotels: mapList(
        map['hotels'],
        'hotels',
      ).map(ProgramHotel.fromMap).toList(growable: false),
      vehicleClasses: mapList(
        map['vehicleClasses'],
        'vehicleClasses',
      ).map(ProgramVehicleClass.fromMap).toList(growable: false),
    );
  }

  final String programId;
  final String organizerId;
  final String title;
  final ProgramKind kind;
  final String timezone;
  final ProgramStatus status;
  final ProgramActorRole actorRole;
  final List<ProgramDutyAssignment> duties;
  final DateTime? grantExpiresAt;
  final Set<String> capabilities;
  final List<ProgramStation> pickupPoints;
  final List<ProgramHotel> hotels;
  final List<ProgramVehicleClass> vehicleClasses;

  bool get isManager => actorRole == ProgramActorRole.manager;

  Iterable<ProgramDutyAssignment> activeDutiesAt(DateTime now) =>
      grantExpiresAt == null || !grantExpiresAt!.isAfter(now)
      ? const []
      : duties.where((assignment) => assignment.isActiveAt(now));

  bool hasDuty(ProgramStaffDuty duty, {required DateTime now}) =>
      isManager ||
      activeDutiesAt(now).any(
        (a) => a.duty == duty || a.duty == ProgramStaffDuty.programCoordinator,
      );

  /// Stations this actor may open; empty scope on a duty means all.
  Set<String>? stationScope(ProgramStaffDuty duty, {required DateTime now}) {
    if (isManager) return null;
    final scoped = <String>{};
    for (final a in activeDutiesAt(now)) {
      if (a.duty != duty && a.duty != ProgramStaffDuty.programCoordinator) {
        continue;
      }
      if (a.pickupPointIds.isEmpty) return null;
      scoped.addAll(a.pickupPointIds);
    }
    return scoped;
  }

  Set<String>? hotelScope(ProgramStaffDuty duty, {required DateTime now}) {
    if (isManager) return null;
    final scoped = <String>{};
    for (final a in activeDutiesAt(now)) {
      if (a.duty != duty && a.duty != ProgramStaffDuty.programCoordinator) {
        continue;
      }
      if (a.hotelIds.isEmpty) return null;
      scoped.addAll(a.hotelIds);
    }
    return scoped;
  }
}

enum TravelLegReadiness { expected, ready, disrupted, dispatched, arrived }

enum TravelLegFlightStatus {
  scheduled,
  enroute,
  landed,
  delayed,
  cancelled,
  diverted,
  unknown,
}

enum CurbSource {
  ready,
  manual,
  actualLanding,
  estimatedLanding,
  scheduledLanding,
}

enum TimingUnavailableReason { cancelled, diverted, missingTiming }

class ArrivalsRosterRow {
  const ArrivalsRosterRow({
    required this.legId,
    required this.guestId,
    required this.partyId,
    required this.guestDisplayName,
    required this.partyLabel,
    required this.partyGuestIds,
    required this.passengers,
    required this.luggageUnits,
    required this.flightNumber,
    required this.originIata,
    required this.arrivalTerminal,
    required this.flightStatus,
    required this.curbAt,
    required this.curbSource,
    required this.unavailableReason,
    required this.readiness,
    required this.claimedByDisplay,
    required this.claimedByMe,
    required this.destinationHotelId,
    required this.destinationLabel,
    required this.requiredCapabilities,
    required this.dedicatedVehicle,
    required this.revision,
  });

  factory ArrivalsRosterRow.fromMap(Map<Object?, Object?> map) =>
      ArrivalsRosterRow(
        legId: requiredString(map, 'legId'),
        guestId: requiredString(map, 'guestId'),
        partyId: map['partyId'] as String?,
        guestDisplayName: requiredString(map, 'guestDisplayName'),
        partyLabel: map['partyLabel'] as String?,
        partyGuestIds: stringList(map['partyGuestIds']),
        passengers: requiredInt(map, 'passengers'),
        luggageUnits: requiredInt(map, 'luggageUnits'),
        flightNumber: map['flightNumber'] as String?,
        originIata: map['originIata'] as String?,
        arrivalTerminal: map['arrivalTerminal'] as String?,
        flightStatus: TravelLegFlightStatus.values.byName(
          requiredString(map, 'flightStatus'),
        ),
        curbAt: nullableDateTime(map['curbAtMillis']),
        curbSource: nullableEnum(map['curbSource'], CurbSource.values),
        unavailableReason: nullableEnum(
          map['unavailableReason'],
          TimingUnavailableReason.values,
        ),
        readiness: TravelLegReadiness.values.byName(
          requiredString(map, 'readiness'),
        ),
        claimedByDisplay: map['claimedByDisplay'] as String?,
        claimedByMe: map['claimedByMe'] == true,
        destinationHotelId: map['destinationHotelId'] as String?,
        destinationLabel: requiredString(map, 'destinationLabel'),
        requiredCapabilities: stringList(
          map['requiredCapabilities'],
        ).map(ProgramVehicleCapability.values.byName).toSet(),
        dedicatedVehicle: map['dedicatedVehicle'] == true,
        revision: requiredInt(map, 'revision'),
      );

  final String legId;
  final String guestId;
  final String? partyId;
  final String guestDisplayName;
  final String? partyLabel;
  final List<String> partyGuestIds;
  final int passengers;
  final int luggageUnits;
  final String? flightNumber;
  final String? originIata;
  final String? arrivalTerminal;
  final TravelLegFlightStatus flightStatus;
  final DateTime? curbAt;
  final CurbSource? curbSource;
  final TimingUnavailableReason? unavailableReason;
  final TravelLegReadiness readiness;
  final String? claimedByDisplay;
  final bool claimedByMe;
  final String? destinationHotelId;
  final String destinationLabel;
  final Set<ProgramVehicleCapability> requiredCapabilities;
  final bool dedicatedVehicle;
  final int revision;

  /// The party label shown to staff: explicit label or lead guest name.
  String get partyTitle => partyLabel ?? guestDisplayName;

  bool get needsAttention =>
      readiness == TravelLegReadiness.disrupted || unavailableReason != null;
}

class ProgramArrivalsRoster {
  const ProgramArrivalsRoster({
    required this.programId,
    required this.pickupPointId,
    required this.generatedAt,
    required this.rows,
    required this.vehicleClasses,
  });

  factory ProgramArrivalsRoster.fromCallableData(Object? value) {
    final map = requiredMap(value, 'arrivals roster');
    return ProgramArrivalsRoster(
      programId: requiredString(map, 'programId'),
      pickupPointId: map['pickupPointId'] as String?,
      generatedAt: requiredDateTime(map, 'generatedAtMillis'),
      rows: mapList(
        map['rows'],
        'rows',
      ).map(ArrivalsRosterRow.fromMap).toList(growable: false),
      vehicleClasses: mapList(
        map['vehicleClasses'],
        'vehicleClasses',
      ).map(ProgramVehicleClass.fromMap).toList(growable: false),
    );
  }

  final String programId;
  final String? pickupPointId;
  final DateTime generatedAt;
  final List<ArrivalsRosterRow> rows;
  final List<ProgramVehicleClass> vehicleClasses;
}

enum TransportGroupReadiness { expected, ready }

enum TransportUnassignedReason { missingTime, noSuitableVehicle, missingScope }

class TransportGroupSuggestion {
  const TransportGroupSuggestion({
    required this.legIds,
    required this.partyIds,
    required this.destinationHotelId,
    required this.destinationLabel,
    required this.readiness,
    required this.vehicleClassId,
    required this.vehicleClassLabel,
    required this.passengers,
    required this.luggageUnits,
    required this.earliestCurbAt,
    required this.latestCurbAt,
    required this.dispatchBy,
    required this.waitOverdue,
  });

  factory TransportGroupSuggestion.fromMap(Map<Object?, Object?> map) =>
      TransportGroupSuggestion(
        legIds: stringList(map['legIds']),
        partyIds: stringList(map['partyIds']),
        destinationHotelId: map['destinationHotelId'] as String?,
        destinationLabel: requiredString(map, 'destinationLabel'),
        readiness: TransportGroupReadiness.values.byName(
          requiredString(map, 'readiness'),
        ),
        vehicleClassId: requiredString(map, 'vehicleClassId'),
        vehicleClassLabel: requiredString(map, 'vehicleClassLabel'),
        passengers: requiredInt(map, 'passengers'),
        luggageUnits: requiredInt(map, 'luggageUnits'),
        earliestCurbAt: requiredDateTime(map, 'earliestCurbAtMillis'),
        latestCurbAt: requiredDateTime(map, 'latestCurbAtMillis'),
        dispatchBy: nullableDateTime(map['dispatchByMillis']),
        waitOverdue: map['waitOverdue'] == true,
      );

  final List<String> legIds;
  final List<String> partyIds;
  final String? destinationHotelId;
  final String destinationLabel;
  final TransportGroupReadiness readiness;
  final String vehicleClassId;
  final String vehicleClassLabel;
  final int passengers;
  final int luggageUnits;
  final DateTime earliestCurbAt;
  final DateTime latestCurbAt;
  final DateTime? dispatchBy;
  final bool waitOverdue;
}

class ProgramTransportPlan {
  const ProgramTransportPlan({
    required this.programId,
    required this.pickupPointId,
    required this.generatedAt,
    required this.groups,
    required this.unassigned,
  });

  factory ProgramTransportPlan.fromCallableData(Object? value) {
    final map = requiredMap(value, 'transport plan');
    return ProgramTransportPlan(
      programId: requiredString(map, 'programId'),
      pickupPointId: map['pickupPointId'] as String?,
      generatedAt: requiredDateTime(map, 'generatedAtMillis'),
      groups: mapList(
        map['groups'],
        'groups',
      ).map(TransportGroupSuggestion.fromMap).toList(growable: false),
      unassigned: mapList(map['unassigned'], 'unassigned')
          .map(
            (item) => (
              legId: requiredString(item, 'legId'),
              reason: TransportUnassignedReason.values.byName(
                requiredString(item, 'reason'),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  final String programId;
  final String? pickupPointId;
  final DateTime generatedAt;
  final List<TransportGroupSuggestion> groups;
  final List<({String legId, TransportUnassignedReason reason})> unassigned;
}

enum TransportTripStatus { enRoute, arrived, cancelled, voided }

class ProgramTripSummary {
  const ProgramTripSummary({
    required this.tripId,
    required this.pickupPointId,
    required this.destinationHotelId,
    required this.destinationLabel,
    required this.vehicleClassId,
    required this.plateDisplay,
    required this.vendorId,
    required this.vendorName,
    required this.status,
    required this.passengerCount,
    required this.departedAt,
    required this.arrivedAt,
    required this.estimatedArriveAt,
    required this.voidReason,
    required this.guestNames,
    required this.revision,
  });

  factory ProgramTripSummary.fromTripMap(Map<Object?, Object?> map) =>
      ProgramTripSummary(
        tripId: requiredString(map, 'tripId'),
        pickupPointId: requiredString(map, 'pickupPointId'),
        destinationHotelId: map['destinationHotelId'] as String?,
        destinationLabel: map['destinationLabel'] as String? ?? 'Unassigned',
        vehicleClassId: requiredString(map, 'vehicleClassId'),
        plateDisplay: requiredString(map, 'plateDisplay'),
        vendorId: map['vendorId'] as String?,
        vendorName: map['vendorName'] as String?,
        status: TransportTripStatus.values.byName(
          requiredString(map, 'status'),
        ),
        passengerCount: requiredInt(map, 'passengerCount'),
        departedAt: requiredDateTime(map, 'departedAtMillis'),
        arrivedAt: nullableDateTime(map['arrivedAtMillis']),
        estimatedArriveAt: nullableDateTime(map['estimatedArriveAtMillis']),
        voidReason: map['voidReason'] as String?,
        guestNames: stringList(map['guestNames']),
        revision: requiredInt(map, 'revision'),
      );

  /// Hotel-inbound rows carry a slightly different shape (no vendorId/kind).
  factory ProgramTripSummary.fromInboundMap(Map<Object?, Object?> map) =>
      ProgramTripSummary(
        tripId: requiredString(map, 'tripId'),
        pickupPointId: '',
        destinationHotelId: null,
        destinationLabel: '',
        vehicleClassId: requiredString(map, 'vehicleClassId'),
        plateDisplay: requiredString(map, 'plateDisplay'),
        vendorId: null,
        vendorName: map['vendorName'] as String?,
        status: TransportTripStatus.values.byName(
          requiredString(map, 'status'),
        ),
        passengerCount: requiredInt(map, 'passengerCount'),
        departedAt: requiredDateTime(map, 'departedAtMillis'),
        arrivedAt: null,
        estimatedArriveAt: nullableDateTime(map['estimatedArriveAtMillis']),
        voidReason: null,
        guestNames: stringList(map['guestNames']),
        revision: requiredInt(map, 'revision'),
      );

  final String tripId;
  final String pickupPointId;
  final String? destinationHotelId;
  final String destinationLabel;
  final String vehicleClassId;
  final String plateDisplay;
  final String? vendorId;
  final String? vendorName;
  final TransportTripStatus status;
  final int passengerCount;
  final DateTime departedAt;
  final DateTime? arrivedAt;
  final DateTime? estimatedArriveAt;
  final String? voidReason;
  final List<String> guestNames;
  final int revision;
}

class ProgramTripList {
  const ProgramTripList({required this.programId, required this.trips});

  factory ProgramTripList.fromCallableData(Object? value) {
    final map = requiredMap(value, 'program trips');
    return ProgramTripList(
      programId: requiredString(map, 'programId'),
      trips: mapList(
        map['trips'],
        'trips',
      ).map(ProgramTripSummary.fromTripMap).toList(growable: false),
    );
  }

  final String programId;
  final List<ProgramTripSummary> trips;
}

class HotelExpectedLeg {
  const HotelExpectedLeg({
    required this.legId,
    required this.guestDisplayName,
    required this.partyLabel,
    required this.passengers,
    required this.curbAt,
    required this.readiness,
  });

  factory HotelExpectedLeg.fromMap(Map<Object?, Object?> map) =>
      HotelExpectedLeg(
        legId: requiredString(map, 'legId'),
        guestDisplayName: requiredString(map, 'guestDisplayName'),
        partyLabel: map['partyLabel'] as String?,
        passengers: requiredInt(map, 'passengers'),
        curbAt: nullableDateTime(map['curbAtMillis']),
        readiness: TravelLegReadiness.values.byName(
          requiredString(map, 'readiness'),
        ),
      );

  final String legId;
  final String guestDisplayName;
  final String? partyLabel;
  final int passengers;
  final DateTime? curbAt;
  final TravelLegReadiness readiness;
}

class ProgramHotelInbound {
  const ProgramHotelInbound({
    required this.programId,
    required this.hotelId,
    required this.hotelName,
    required this.generatedAt,
    required this.trips,
    required this.expectedLegs,
  });

  factory ProgramHotelInbound.fromCallableData(Object? value) {
    final map = requiredMap(value, 'hotel inbound');
    return ProgramHotelInbound(
      programId: requiredString(map, 'programId'),
      hotelId: requiredString(map, 'hotelId'),
      hotelName: requiredString(map, 'hotelName'),
      generatedAt: requiredDateTime(map, 'generatedAtMillis'),
      trips: mapList(
        map['trips'],
        'trips',
      ).map(ProgramTripSummary.fromInboundMap).toList(growable: false),
      expectedLegs: mapList(
        map['expectedLegs'],
        'expectedLegs',
      ).map(HotelExpectedLeg.fromMap).toList(growable: false),
    );
  }

  final String programId;
  final String hotelId;
  final String hotelName;
  final DateTime generatedAt;
  final List<ProgramTripSummary> trips;
  final List<HotelExpectedLeg> expectedLegs;
}

class ProgramVendorOption {
  const ProgramVendorOption({
    required this.vendorId,
    required this.name,
    required this.active,
    required this.boundToProgram,
  });

  final String vendorId;
  final String name;
  final bool active;
  final bool boundToProgram;
}

enum ProgramStaffStatus { active, expired, revoked }

class ProgramStaffMember {
  const ProgramStaffMember({
    required this.uid,
    required this.displayName,
    required this.phoneLastFour,
    required this.duties,
    required this.status,
    required this.expiresAt,
    required this.revision,
  });

  factory ProgramStaffMember.fromMap(Map<Object?, Object?> map) =>
      ProgramStaffMember(
        uid: requiredString(map, 'uid'),
        displayName: requiredString(map, 'displayName'),
        phoneLastFour: requiredString(map, 'phoneLastFour'),
        duties: mapList(
          map['duties'],
          'duties',
        ).map(ProgramDutyAssignment.fromMap).toList(growable: false),
        status: ProgramStaffStatus.values.byName(requiredString(map, 'status')),
        expiresAt: requiredDateTime(map, 'expiresAtMillis'),
        revision: requiredInt(map, 'revision'),
      );

  final String uid;
  final String displayName;
  final String phoneLastFour;
  final List<ProgramDutyAssignment> duties;
  final ProgramStaffStatus status;
  final DateTime expiresAt;
  final int revision;
}

class ProgramStaffList {
  const ProgramStaffList({required this.programId, required this.members});

  factory ProgramStaffList.fromCallableData(Object? value) {
    final map = requiredMap(value, 'program staff list');
    return ProgramStaffList(
      programId: requiredString(map, 'programId'),
      members: mapList(
        map['members'],
        'members',
      ).map(ProgramStaffMember.fromMap).toList(growable: false),
    );
  }

  final String programId;
  final List<ProgramStaffMember> members;
}

class ProgramMutationResult {
  const ProgramMutationResult({
    required this.entityId,
    required this.revision,
    required this.alreadyApplied,
  });

  factory ProgramMutationResult.fromCallableData(Object? value) {
    final map = requiredMap(value, 'program mutation');
    return ProgramMutationResult(
      entityId: requiredString(map, 'entityId'),
      revision: requiredInt(map, 'revision'),
      alreadyApplied: map['alreadyApplied'] == true,
    );
  }

  final String entityId;
  final int revision;
  final bool alreadyApplied;
}

class DispatchResult {
  const DispatchResult({
    required this.tripId,
    required this.revision,
    required this.alreadyApplied,
    required this.passengerCount,
  });

  factory DispatchResult.fromCallableData(Object? value) {
    final map = requiredMap(value, 'dispatch result');
    return DispatchResult(
      tripId: requiredString(map, 'tripId'),
      revision: requiredInt(map, 'revision'),
      alreadyApplied: map['alreadyApplied'] == true,
      passengerCount: requiredInt(map, 'passengerCount'),
    );
  }

  final String tripId;
  final int revision;
  final bool alreadyApplied;
  final int passengerCount;
}

// ── Parsing helpers (same convention as host_event_staff_repository) ────────

Map<Object?, Object?> requiredMap(Object? value, String label) {
  if (value is Map<Object?, Object?>) return value;
  throw FormatException('Invalid $label.');
}

String requiredString(Map<Object?, Object?> map, String field) {
  final value = map[field];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Invalid $field.');
}

int requiredInt(Map<Object?, Object?> map, String field) {
  final value = map[field];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Invalid $field.');
}

DateTime requiredDateTime(Map<Object?, Object?> map, String field) =>
    DateTime.fromMillisecondsSinceEpoch(requiredInt(map, field));

DateTime? nullableDateTime(Object? value) {
  if (value == null) return null;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  throw const FormatException('Invalid nullable date.');
}

T? nullableEnum<T extends Enum>(Object? value, List<T> values) {
  if (value == null) return null;
  if (value is String) {
    for (final entry in values) {
      if (entry.name == value) return entry;
    }
  }
  throw const FormatException('Invalid enum value.');
}

List<String> stringList(Object? value) {
  if (value is List<Object?> && value.every((item) => item is String)) {
    return value.cast<String>();
  }
  throw const FormatException('Invalid string list.');
}

List<Map<Object?, Object?>> mapList(Object? value, String field) {
  if (value is List<Object?>) {
    return value.map((item) => requiredMap(item, field)).toList();
  }
  throw FormatException('Invalid $field.');
}
