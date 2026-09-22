// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_work_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programWorkRepository)
final programWorkRepositoryProvider = ProgramWorkRepositoryProvider._();

final class ProgramWorkRepositoryProvider
    extends
        $FunctionalProvider<
          ProgramWorkRepository,
          ProgramWorkRepository,
          ProgramWorkRepository
        >
    with $Provider<ProgramWorkRepository> {
  ProgramWorkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programWorkRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programWorkRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgramWorkRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramWorkRepository create(Ref ref) {
    return programWorkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramWorkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramWorkRepository>(value),
    );
  }
}

String _$programWorkRepositoryHash() =>
    r'b9cd95eb60098449d55718c6cabae3e979725965';

@ProviderFor(programWorkAccess)
final programWorkAccessProvider = ProgramWorkAccessFamily._();

final class ProgramWorkAccessProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramWorkAccess>,
          ProgramWorkAccess,
          FutureOr<ProgramWorkAccess>
        >
    with
        $FutureModifier<ProgramWorkAccess>,
        $FutureProvider<ProgramWorkAccess> {
  ProgramWorkAccessProvider._({
    required ProgramWorkAccessFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'programWorkAccessProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programWorkAccessHash();

  @override
  String toString() {
    return r'programWorkAccessProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramWorkAccess> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramWorkAccess> create(Ref ref) {
    final argument = this.argument as String;
    return programWorkAccess(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramWorkAccessProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programWorkAccessHash() => r'5823dddfc078e3c4c64ffb99d3ac23b1de89d21a';

final class ProgramWorkAccessFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProgramWorkAccess>, String> {
  ProgramWorkAccessFamily._()
    : super(
        retry: null,
        name: r'programWorkAccessProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramWorkAccessProvider call(String programId) =>
      ProgramWorkAccessProvider._(argument: programId, from: this);

  @override
  String toString() => r'programWorkAccessProvider';
}

/// Work-shell entry: claims a staff invite when the deep link carries one,
/// then resolves access for the invite's program.

@ProviderFor(programWorkEntry)
final programWorkEntryProvider = ProgramWorkEntryFamily._();

/// Work-shell entry: claims a staff invite when the deep link carries one,
/// then resolves access for the invite's program.

final class ProgramWorkEntryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramWorkAccess>,
          ProgramWorkAccess,
          FutureOr<ProgramWorkAccess>
        >
    with
        $FutureModifier<ProgramWorkAccess>,
        $FutureProvider<ProgramWorkAccess> {
  /// Work-shell entry: claims a staff invite when the deep link carries one,
  /// then resolves access for the invite's program.
  ProgramWorkEntryProvider._({
    required ProgramWorkEntryFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'programWorkEntryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programWorkEntryHash();

  @override
  String toString() {
    return r'programWorkEntryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramWorkAccess> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramWorkAccess> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return programWorkEntry(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramWorkEntryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programWorkEntryHash() => r'0511854dec410c2dd18eef4cacee37e17237ecff';

/// Work-shell entry: claims a staff invite when the deep link carries one,
/// then resolves access for the invite's program.

final class ProgramWorkEntryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramWorkAccess>,
          (String, String?)
        > {
  ProgramWorkEntryFamily._()
    : super(
        retry: null,
        name: r'programWorkEntryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Work-shell entry: claims a staff invite when the deep link carries one,
  /// then resolves access for the invite's program.

  ProgramWorkEntryProvider call(String programId, String? inviteId) =>
      ProgramWorkEntryProvider._(argument: (programId, inviteId), from: this);

  @override
  String toString() => r'programWorkEntryProvider';
}

@ProviderFor(programArrivalsRoster)
final programArrivalsRosterProvider = ProgramArrivalsRosterFamily._();

final class ProgramArrivalsRosterProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramArrivalsRoster>,
          ProgramArrivalsRoster,
          FutureOr<ProgramArrivalsRoster>
        >
    with
        $FutureModifier<ProgramArrivalsRoster>,
        $FutureProvider<ProgramArrivalsRoster> {
  ProgramArrivalsRosterProvider._({
    required ProgramArrivalsRosterFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'programArrivalsRosterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programArrivalsRosterHash();

  @override
  String toString() {
    return r'programArrivalsRosterProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramArrivalsRoster> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramArrivalsRoster> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return programArrivalsRoster(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramArrivalsRosterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programArrivalsRosterHash() =>
    r'ceecb0900c432aec367433a81754bf6c0df1ab7f';

final class ProgramArrivalsRosterFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramArrivalsRoster>,
          (String, String?)
        > {
  ProgramArrivalsRosterFamily._()
    : super(
        retry: null,
        name: r'programArrivalsRosterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramArrivalsRosterProvider call(String programId, String? pickupPointId) =>
      ProgramArrivalsRosterProvider._(
        argument: (programId, pickupPointId),
        from: this,
      );

  @override
  String toString() => r'programArrivalsRosterProvider';
}

/// Roster with offline fallback: a live failure resolves to the last saved
/// snapshot for this station, marked with its capture time so the UI can
/// label it as saved data rather than live.

@ProviderFor(programArrivalsRosterView)
final programArrivalsRosterViewProvider = ProgramArrivalsRosterViewFamily._();

/// Roster with offline fallback: a live failure resolves to the last saved
/// snapshot for this station, marked with its capture time so the UI can
/// label it as saved data rather than live.

final class ProgramArrivalsRosterViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<({ProgramArrivalsRoster roster, DateTime? snapshotAt})>,
          ({ProgramArrivalsRoster roster, DateTime? snapshotAt}),
          FutureOr<({ProgramArrivalsRoster roster, DateTime? snapshotAt})>
        >
    with
        $FutureModifier<({ProgramArrivalsRoster roster, DateTime? snapshotAt})>,
        $FutureProvider<
          ({ProgramArrivalsRoster roster, DateTime? snapshotAt})
        > {
  /// Roster with offline fallback: a live failure resolves to the last saved
  /// snapshot for this station, marked with its capture time so the UI can
  /// label it as saved data rather than live.
  ProgramArrivalsRosterViewProvider._({
    required ProgramArrivalsRosterViewFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'programArrivalsRosterViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programArrivalsRosterViewHash();

  @override
  String toString() {
    return r'programArrivalsRosterViewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({ProgramArrivalsRoster roster, DateTime? snapshotAt})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({ProgramArrivalsRoster roster, DateTime? snapshotAt})> create(
    Ref ref,
  ) {
    final argument = this.argument as (String, String?);
    return programArrivalsRosterView(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramArrivalsRosterViewProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programArrivalsRosterViewHash() =>
    r'6110d2b4deff67a41673b101dfe2af63b6abf0c4';

/// Roster with offline fallback: a live failure resolves to the last saved
/// snapshot for this station, marked with its capture time so the UI can
/// label it as saved data rather than live.

final class ProgramArrivalsRosterViewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({ProgramArrivalsRoster roster, DateTime? snapshotAt})>,
          (String, String?)
        > {
  ProgramArrivalsRosterViewFamily._()
    : super(
        retry: null,
        name: r'programArrivalsRosterViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Roster with offline fallback: a live failure resolves to the last saved
  /// snapshot for this station, marked with its capture time so the UI can
  /// label it as saved data rather than live.

  ProgramArrivalsRosterViewProvider call(
    String programId,
    String? pickupPointId,
  ) => ProgramArrivalsRosterViewProvider._(
    argument: (programId, pickupPointId),
    from: this,
  );

  @override
  String toString() => r'programArrivalsRosterViewProvider';
}

@ProviderFor(programTransportPlan)
final programTransportPlanProvider = ProgramTransportPlanFamily._();

final class ProgramTransportPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramTransportPlan>,
          ProgramTransportPlan,
          FutureOr<ProgramTransportPlan>
        >
    with
        $FutureModifier<ProgramTransportPlan>,
        $FutureProvider<ProgramTransportPlan> {
  ProgramTransportPlanProvider._({
    required ProgramTransportPlanFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'programTransportPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programTransportPlanHash();

  @override
  String toString() {
    return r'programTransportPlanProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramTransportPlan> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramTransportPlan> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return programTransportPlan(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramTransportPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programTransportPlanHash() =>
    r'35a5c164277ec62806f47e80fe2d292fef6fc294';

final class ProgramTransportPlanFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramTransportPlan>,
          (String, String?)
        > {
  ProgramTransportPlanFamily._()
    : super(
        retry: null,
        name: r'programTransportPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramTransportPlanProvider call(String programId, String? pickupPointId) =>
      ProgramTransportPlanProvider._(
        argument: (programId, pickupPointId),
        from: this,
      );

  @override
  String toString() => r'programTransportPlanProvider';
}

/// Transport plan with the same snapshot fallback as the roster.

@ProviderFor(programTransportPlanView)
final programTransportPlanViewProvider = ProgramTransportPlanViewFamily._();

/// Transport plan with the same snapshot fallback as the roster.

final class ProgramTransportPlanViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<({ProgramTransportPlan plan, DateTime? snapshotAt})>,
          ({ProgramTransportPlan plan, DateTime? snapshotAt}),
          FutureOr<({ProgramTransportPlan plan, DateTime? snapshotAt})>
        >
    with
        $FutureModifier<({ProgramTransportPlan plan, DateTime? snapshotAt})>,
        $FutureProvider<({ProgramTransportPlan plan, DateTime? snapshotAt})> {
  /// Transport plan with the same snapshot fallback as the roster.
  ProgramTransportPlanViewProvider._({
    required ProgramTransportPlanViewFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'programTransportPlanViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programTransportPlanViewHash();

  @override
  String toString() {
    return r'programTransportPlanViewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({ProgramTransportPlan plan, DateTime? snapshotAt})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({ProgramTransportPlan plan, DateTime? snapshotAt})> create(
    Ref ref,
  ) {
    final argument = this.argument as (String, String?);
    return programTransportPlanView(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramTransportPlanViewProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programTransportPlanViewHash() =>
    r'1a55ec83841c1a2d1098e751d13f55d0facac535';

/// Transport plan with the same snapshot fallback as the roster.

final class ProgramTransportPlanViewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({ProgramTransportPlan plan, DateTime? snapshotAt})>,
          (String, String?)
        > {
  ProgramTransportPlanViewFamily._()
    : super(
        retry: null,
        name: r'programTransportPlanViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Transport plan with the same snapshot fallback as the roster.

  ProgramTransportPlanViewProvider call(
    String programId,
    String? pickupPointId,
  ) => ProgramTransportPlanViewProvider._(
    argument: (programId, pickupPointId),
    from: this,
  );

  @override
  String toString() => r'programTransportPlanViewProvider';
}

@ProviderFor(programHotelInbound)
final programHotelInboundProvider = ProgramHotelInboundFamily._();

final class ProgramHotelInboundProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramHotelInbound>,
          ProgramHotelInbound,
          FutureOr<ProgramHotelInbound>
        >
    with
        $FutureModifier<ProgramHotelInbound>,
        $FutureProvider<ProgramHotelInbound> {
  ProgramHotelInboundProvider._({
    required ProgramHotelInboundFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'programHotelInboundProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programHotelInboundHash();

  @override
  String toString() {
    return r'programHotelInboundProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramHotelInbound> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramHotelInbound> create(Ref ref) {
    final argument = this.argument as (String, String);
    return programHotelInbound(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramHotelInboundProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programHotelInboundHash() =>
    r'a3b0bf8daec92e22e957b74bbe54a482059b1ee3';

final class ProgramHotelInboundFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramHotelInbound>,
          (String, String)
        > {
  ProgramHotelInboundFamily._()
    : super(
        retry: null,
        name: r'programHotelInboundProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramHotelInboundProvider call(String programId, String hotelId) =>
      ProgramHotelInboundProvider._(argument: (programId, hotelId), from: this);

  @override
  String toString() => r'programHotelInboundProvider';
}

@ProviderFor(programTripList)
final programTripListProvider = ProgramTripListFamily._();

final class ProgramTripListProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramTripList>,
          ProgramTripList,
          FutureOr<ProgramTripList>
        >
    with $FutureModifier<ProgramTripList>, $FutureProvider<ProgramTripList> {
  ProgramTripListProvider._({
    required ProgramTripListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'programTripListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programTripListHash();

  @override
  String toString() {
    return r'programTripListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramTripList> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramTripList> create(Ref ref) {
    final argument = this.argument as String;
    return programTripList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramTripListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programTripListHash() => r'266a04a84992ff39391ae42df1c76e2f93f9a11f';

final class ProgramTripListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProgramTripList>, String> {
  ProgramTripListFamily._()
    : super(
        retry: null,
        name: r'programTripListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramTripListProvider call(String programId) =>
      ProgramTripListProvider._(argument: programId, from: this);

  @override
  String toString() => r'programTripListProvider';
}

@ProviderFor(programTransportVendors)
final programTransportVendorsProvider = ProgramTransportVendorsFamily._();

final class ProgramTransportVendorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProgramVendorOption>>,
          List<ProgramVendorOption>,
          FutureOr<List<ProgramVendorOption>>
        >
    with
        $FutureModifier<List<ProgramVendorOption>>,
        $FutureProvider<List<ProgramVendorOption>> {
  ProgramTransportVendorsProvider._({
    required ProgramTransportVendorsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'programTransportVendorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programTransportVendorsHash();

  @override
  String toString() {
    return r'programTransportVendorsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProgramVendorOption>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProgramVendorOption>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return programTransportVendors(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramTransportVendorsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programTransportVendorsHash() =>
    r'9b453bbc205954e1a670e0b10ca7b4b8736fad98';

final class ProgramTransportVendorsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ProgramVendorOption>>,
          (String, String)
        > {
  ProgramTransportVendorsFamily._()
    : super(
        retry: null,
        name: r'programTransportVendorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramTransportVendorsProvider call(String organizerId, String programId) =>
      ProgramTransportVendorsProvider._(
        argument: (organizerId, programId),
        from: this,
      );

  @override
  String toString() => r'programTransportVendorsProvider';
}
