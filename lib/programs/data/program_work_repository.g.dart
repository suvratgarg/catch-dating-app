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

String _$programWorkEntryHash() => r'50b7414a9ad3e95964a784acc5674c5edca7c87f';

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
    r'f085a79621708513500c7eb57d21125c922958f0';

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
    r'18e84e27715f52e12984471127950842b01079b9';

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
    required (String, String, {String? tripCursor, String? expectedCursor})
    super.argument,
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
    final argument =
        this.argument
            as (String, String, {String? tripCursor, String? expectedCursor});
    return programHotelInbound(
      ref,
      argument.$1,
      argument.$2,
      tripCursor: argument.tripCursor,
      expectedCursor: argument.expectedCursor,
    );
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
    r'85ec7cf0b6a8c27edd1740e0792a038601c75b08';

final class ProgramHotelInboundFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramHotelInbound>,
          (String, String, {String? tripCursor, String? expectedCursor})
        > {
  ProgramHotelInboundFamily._()
    : super(
        retry: null,
        name: r'programHotelInboundProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramHotelInboundProvider call(
    String programId,
    String hotelId, {
    String? tripCursor,
    String? expectedCursor,
  }) => ProgramHotelInboundProvider._(
    argument: (
      programId,
      hotelId,
      tripCursor: tripCursor,
      expectedCursor: expectedCursor,
    ),
    from: this,
  );

  @override
  String toString() => r'programHotelInboundProvider';
}

@ProviderFor(programFunctionDoorView)
final programFunctionDoorViewProvider = ProgramFunctionDoorViewFamily._();

final class ProgramFunctionDoorViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramDoorView>,
          ProgramDoorView,
          FutureOr<ProgramDoorView>
        >
    with $FutureModifier<ProgramDoorView>, $FutureProvider<ProgramDoorView> {
  ProgramFunctionDoorViewProvider._({
    required ProgramFunctionDoorViewFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'programFunctionDoorViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programFunctionDoorViewHash();

  @override
  String toString() {
    return r'programFunctionDoorViewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramDoorView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramDoorView> create(Ref ref) {
    final argument = this.argument as (String, String);
    return programFunctionDoorView(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramFunctionDoorViewProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programFunctionDoorViewHash() =>
    r'f73a6dc0c0bbd06be491ede77e443b26c2281059';

final class ProgramFunctionDoorViewFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<ProgramDoorView>, (String, String)> {
  ProgramFunctionDoorViewFamily._()
    : super(
        retry: null,
        name: r'programFunctionDoorViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramFunctionDoorViewProvider call(String programId, String functionId) =>
      ProgramFunctionDoorViewProvider._(
        argument: (programId, functionId),
        from: this,
      );

  @override
  String toString() => r'programFunctionDoorViewProvider';
}

@ProviderFor(programFunctionDoorViewWithSnapshot)
final programFunctionDoorViewWithSnapshotProvider =
    ProgramFunctionDoorViewWithSnapshotFamily._();

final class ProgramFunctionDoorViewWithSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramReadView<ProgramDoorView>>,
          ProgramReadView<ProgramDoorView>,
          FutureOr<ProgramReadView<ProgramDoorView>>
        >
    with
        $FutureModifier<ProgramReadView<ProgramDoorView>>,
        $FutureProvider<ProgramReadView<ProgramDoorView>> {
  ProgramFunctionDoorViewWithSnapshotProvider._({
    required ProgramFunctionDoorViewWithSnapshotFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'programFunctionDoorViewWithSnapshotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$programFunctionDoorViewWithSnapshotHash();

  @override
  String toString() {
    return r'programFunctionDoorViewWithSnapshotProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramReadView<ProgramDoorView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramReadView<ProgramDoorView>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return programFunctionDoorViewWithSnapshot(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramFunctionDoorViewWithSnapshotProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programFunctionDoorViewWithSnapshotHash() =>
    r'033a5625589ab42a2286a690e161d5a8678b4c47';

final class ProgramFunctionDoorViewWithSnapshotFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramReadView<ProgramDoorView>>,
          (String, String)
        > {
  ProgramFunctionDoorViewWithSnapshotFamily._()
    : super(
        retry: null,
        name: r'programFunctionDoorViewWithSnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramFunctionDoorViewWithSnapshotProvider call(
    String programId,
    String functionId,
  ) => ProgramFunctionDoorViewWithSnapshotProvider._(
    argument: (programId, functionId),
    from: this,
  );

  @override
  String toString() => r'programFunctionDoorViewWithSnapshotProvider';
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
    required (String, {String? cursor}) super.argument,
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
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramTripList> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramTripList> create(Ref ref) {
    final argument = this.argument as (String, {String? cursor});
    return programTripList(ref, argument.$1, cursor: argument.cursor);
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

String _$programTripListHash() => r'567c8a1f768d508f26d435ab1dc865997b20eae6';

final class ProgramTripListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramTripList>,
          (String, {String? cursor})
        > {
  ProgramTripListFamily._()
    : super(
        retry: null,
        name: r'programTripListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramTripListProvider call(String programId, {String? cursor}) =>
      ProgramTripListProvider._(
        argument: (programId, cursor: cursor),
        from: this,
      );

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
    r'8a888d1076d4957a61446ef6f487d86dfad14ed9';

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
