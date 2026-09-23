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
    r'1afd99f8840d6c75a4c222e78cf1b1ab9211f42b';

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

String _$programWorkAccessHash() => r'fc83d202376d96a432425eeac7e15ec706189e3b';

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

/// An invitation must be claimed online; an existing program may reopen from
/// a bounded snapshot of its previously verified access.

@ProviderFor(programWorkEntry)
final programWorkEntryProvider = ProgramWorkEntryFamily._();

/// An invitation must be claimed online; an existing program may reopen from
/// a bounded snapshot of its previously verified access.

final class ProgramWorkEntryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramReadView<ProgramWorkAccess>>,
          ProgramReadView<ProgramWorkAccess>,
          FutureOr<ProgramReadView<ProgramWorkAccess>>
        >
    with
        $FutureModifier<ProgramReadView<ProgramWorkAccess>>,
        $FutureProvider<ProgramReadView<ProgramWorkAccess>> {
  /// An invitation must be claimed online; an existing program may reopen from
  /// a bounded snapshot of its previously verified access.
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
  $FutureProviderElement<ProgramReadView<ProgramWorkAccess>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramReadView<ProgramWorkAccess>> create(Ref ref) {
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

String _$programWorkEntryHash() => r'3fe718addde6415ab059cdb36ba7bfe8354f33d0';

/// An invitation must be claimed online; an existing program may reopen from
/// a bounded snapshot of its previously verified access.

final class ProgramWorkEntryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramReadView<ProgramWorkAccess>>,
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

  /// An invitation must be claimed online; an existing program may reopen from
  /// a bounded snapshot of its previously verified access.

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
    r'9143c3b11fe80a644e2361169750efb93ef3d832';

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

@ProviderFor(programArrivalsRosterView)
final programArrivalsRosterViewProvider = ProgramArrivalsRosterViewFamily._();

final class ProgramArrivalsRosterViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramReadView<ProgramArrivalsRoster>>,
          ProgramReadView<ProgramArrivalsRoster>,
          FutureOr<ProgramReadView<ProgramArrivalsRoster>>
        >
    with
        $FutureModifier<ProgramReadView<ProgramArrivalsRoster>>,
        $FutureProvider<ProgramReadView<ProgramArrivalsRoster>> {
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
  $FutureProviderElement<ProgramReadView<ProgramArrivalsRoster>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramReadView<ProgramArrivalsRoster>> create(Ref ref) {
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
    r'ff1bacf167281acc2edd2be4fa6e8aa246badf59';

final class ProgramArrivalsRosterViewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramReadView<ProgramArrivalsRoster>>,
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
    r'ec3b9e87f6f33c6f78d1c4de42057de36395ab90';

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

@ProviderFor(programTransportPlanView)
final programTransportPlanViewProvider = ProgramTransportPlanViewFamily._();

final class ProgramTransportPlanViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramReadView<ProgramTransportPlan>>,
          ProgramReadView<ProgramTransportPlan>,
          FutureOr<ProgramReadView<ProgramTransportPlan>>
        >
    with
        $FutureModifier<ProgramReadView<ProgramTransportPlan>>,
        $FutureProvider<ProgramReadView<ProgramTransportPlan>> {
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
  $FutureProviderElement<ProgramReadView<ProgramTransportPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramReadView<ProgramTransportPlan>> create(Ref ref) {
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
    r'59fcfea8d52fb4c2f20b8fee9657d5417d771bf0';

final class ProgramTransportPlanViewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramReadView<ProgramTransportPlan>>,
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
    r'7db20840bea481a2247717313192906cba0bd3b8';

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

String _$programTripListHash() => r'7eff20d80de9ae2d6764ff814a367fc8c7f739f3';

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
    r'0e1f041b2a7471b810fcef4a046a67df27d6cee3';

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
