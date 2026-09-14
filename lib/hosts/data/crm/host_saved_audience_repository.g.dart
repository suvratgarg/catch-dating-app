// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_saved_audience_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostSavedAudienceRepository)
final hostSavedAudienceRepositoryProvider =
    HostSavedAudienceRepositoryProvider._();

final class HostSavedAudienceRepositoryProvider
    extends
        $FunctionalProvider<
          HostSavedAudienceRepository,
          HostSavedAudienceRepository,
          HostSavedAudienceRepository
        >
    with $Provider<HostSavedAudienceRepository> {
  HostSavedAudienceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostSavedAudienceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostSavedAudienceRepositoryHash();

  @$internal
  @override
  $ProviderElement<HostSavedAudienceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostSavedAudienceRepository create(Ref ref) {
    return hostSavedAudienceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostSavedAudienceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostSavedAudienceRepository>(value),
    );
  }
}

String _$hostSavedAudienceRepositoryHash() =>
    r'7ec326c7d207d299b41ac8df66457d2f79908fb4';

@ProviderFor(hostSavedAudiences)
final hostSavedAudiencesProvider = HostSavedAudiencesFamily._();

final class HostSavedAudiencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostSavedAudiencePage>,
          HostSavedAudiencePage,
          FutureOr<HostSavedAudiencePage>
        >
    with
        $FutureModifier<HostSavedAudiencePage>,
        $FutureProvider<HostSavedAudiencePage> {
  HostSavedAudiencesProvider._({
    required HostSavedAudiencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostSavedAudiencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostSavedAudiencesHash();

  @override
  String toString() {
    return r'hostSavedAudiencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostSavedAudiencePage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostSavedAudiencePage> create(Ref ref) {
    final argument = this.argument as String;
    return hostSavedAudiences(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostSavedAudiencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostSavedAudiencesHash() =>
    r'3fb518edb5a7787a0d64e22d5c147d6fa60b1920';

final class HostSavedAudiencesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostSavedAudiencePage>, String> {
  HostSavedAudiencesFamily._()
    : super(
        retry: null,
        name: r'hostSavedAudiencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostSavedAudiencesProvider call(String organizerId) =>
      HostSavedAudiencesProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostSavedAudiencesProvider';
}

/// Exhaustive saved-audience directory used by the Customers-owned workspace.
///
/// The callable remains cursor-paginated; this bounded provider follows those
/// cursors so client-side name search never silently searches only page one.

@ProviderFor(hostAllSavedAudiences)
final hostAllSavedAudiencesProvider = HostAllSavedAudiencesFamily._();

/// Exhaustive saved-audience directory used by the Customers-owned workspace.
///
/// The callable remains cursor-paginated; this bounded provider follows those
/// cursors so client-side name search never silently searches only page one.

final class HostAllSavedAudiencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostSavedAudiencePage>,
          HostSavedAudiencePage,
          FutureOr<HostSavedAudiencePage>
        >
    with
        $FutureModifier<HostSavedAudiencePage>,
        $FutureProvider<HostSavedAudiencePage> {
  /// Exhaustive saved-audience directory used by the Customers-owned workspace.
  ///
  /// The callable remains cursor-paginated; this bounded provider follows those
  /// cursors so client-side name search never silently searches only page one.
  HostAllSavedAudiencesProvider._({
    required HostAllSavedAudiencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostAllSavedAudiencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostAllSavedAudiencesHash();

  @override
  String toString() {
    return r'hostAllSavedAudiencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostSavedAudiencePage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostSavedAudiencePage> create(Ref ref) {
    final argument = this.argument as String;
    return hostAllSavedAudiences(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostAllSavedAudiencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostAllSavedAudiencesHash() =>
    r'8f30ca12ebd1bf0628c7e5463a0deeed7a5400d9';

/// Exhaustive saved-audience directory used by the Customers-owned workspace.
///
/// The callable remains cursor-paginated; this bounded provider follows those
/// cursors so client-side name search never silently searches only page one.

final class HostAllSavedAudiencesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostSavedAudiencePage>, String> {
  HostAllSavedAudiencesFamily._()
    : super(
        retry: null,
        name: r'hostAllSavedAudiencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Exhaustive saved-audience directory used by the Customers-owned workspace.
  ///
  /// The callable remains cursor-paginated; this bounded provider follows those
  /// cursors so client-side name search never silently searches only page one.

  HostAllSavedAudiencesProvider call(String organizerId) =>
      HostAllSavedAudiencesProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostAllSavedAudiencesProvider';
}

@ProviderFor(hostStaticAudienceMembers)
final hostStaticAudienceMembersProvider = HostStaticAudienceMembersFamily._();

final class HostStaticAudienceMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HostStaticAudienceMember>>,
          List<HostStaticAudienceMember>,
          FutureOr<List<HostStaticAudienceMember>>
        >
    with
        $FutureModifier<List<HostStaticAudienceMember>>,
        $FutureProvider<List<HostStaticAudienceMember>> {
  HostStaticAudienceMembersProvider._({
    required HostStaticAudienceMembersFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'hostStaticAudienceMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostStaticAudienceMembersHash();

  @override
  String toString() {
    return r'hostStaticAudienceMembersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<HostStaticAudienceMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HostStaticAudienceMember>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return hostStaticAudienceMembers(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HostStaticAudienceMembersProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostStaticAudienceMembersHash() =>
    r'31d7f3c6b3ad14fd6b9f5fb78d72f04e56a7deb2';

final class HostStaticAudienceMembersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<HostStaticAudienceMember>>,
          (String, String)
        > {
  HostStaticAudienceMembersFamily._()
    : super(
        retry: null,
        name: r'hostStaticAudienceMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostStaticAudienceMembersProvider call(
    String organizerId,
    String selectionKey,
  ) => HostStaticAudienceMembersProvider._(
    argument: (organizerId, selectionKey),
    from: this,
  );

  @override
  String toString() => r'hostStaticAudienceMembersProvider';
}

@ProviderFor(hostSavedAudienceFilterOptions)
final hostSavedAudienceFilterOptionsProvider =
    HostSavedAudienceFilterOptionsFamily._();

final class HostSavedAudienceFilterOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostSavedAudienceFilterOptions>,
          HostSavedAudienceFilterOptions,
          FutureOr<HostSavedAudienceFilterOptions>
        >
    with
        $FutureModifier<HostSavedAudienceFilterOptions>,
        $FutureProvider<HostSavedAudienceFilterOptions> {
  HostSavedAudienceFilterOptionsProvider._({
    required HostSavedAudienceFilterOptionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostSavedAudienceFilterOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostSavedAudienceFilterOptionsHash();

  @override
  String toString() {
    return r'hostSavedAudienceFilterOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostSavedAudienceFilterOptions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostSavedAudienceFilterOptions> create(Ref ref) {
    final argument = this.argument as String;
    return hostSavedAudienceFilterOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostSavedAudienceFilterOptionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostSavedAudienceFilterOptionsHash() =>
    r'f26f821b8e1a5060110fba8c02999bd97480b317';

final class HostSavedAudienceFilterOptionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostSavedAudienceFilterOptions>,
          String
        > {
  HostSavedAudienceFilterOptionsFamily._()
    : super(
        retry: null,
        name: r'hostSavedAudienceFilterOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostSavedAudienceFilterOptionsProvider call(String organizerId) =>
      HostSavedAudienceFilterOptionsProvider._(
        argument: organizerId,
        from: this,
      );

  @override
  String toString() => r'hostSavedAudienceFilterOptionsProvider';
}
