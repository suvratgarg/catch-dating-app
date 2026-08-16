// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_crm_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostCrmRepository)
final hostCrmRepositoryProvider = HostCrmRepositoryProvider._();

final class HostCrmRepositoryProvider
    extends
        $FunctionalProvider<
          HostCrmRepository,
          HostCrmRepository,
          HostCrmRepository
        >
    with $Provider<HostCrmRepository> {
  HostCrmRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostCrmRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostCrmRepositoryHash();

  @$internal
  @override
  $ProviderElement<HostCrmRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostCrmRepository create(Ref ref) {
    return hostCrmRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostCrmRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostCrmRepository>(value),
    );
  }
}

String _$hostCrmRepositoryHash() => r'57853e0668b362f13b2e2578e32747ba5e46db88';

@ProviderFor(hostCrmSummary)
final hostCrmSummaryProvider = HostCrmSummaryFamily._();

final class HostCrmSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostCrmSummary>,
          HostCrmSummary,
          FutureOr<HostCrmSummary>
        >
    with $FutureModifier<HostCrmSummary>, $FutureProvider<HostCrmSummary> {
  HostCrmSummaryProvider._({
    required HostCrmSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostCrmSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostCrmSummaryHash();

  @override
  String toString() {
    return r'hostCrmSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostCrmSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostCrmSummary> create(Ref ref) {
    final argument = this.argument as String;
    return hostCrmSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostCrmSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostCrmSummaryHash() => r'446fd2c4a736f7611f1e86b1a86d205e15815c00';

final class HostCrmSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostCrmSummary>, String> {
  HostCrmSummaryFamily._()
    : super(
        retry: null,
        name: r'hostCrmSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostCrmSummaryProvider call(String organizerId) =>
      HostCrmSummaryProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostCrmSummaryProvider';
}

@ProviderFor(hostEventRosterInsights)
final hostEventRosterInsightsProvider = HostEventRosterInsightsFamily._();

final class HostEventRosterInsightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostEventRosterInsights>,
          HostEventRosterInsights,
          FutureOr<HostEventRosterInsights>
        >
    with
        $FutureModifier<HostEventRosterInsights>,
        $FutureProvider<HostEventRosterInsights> {
  HostEventRosterInsightsProvider._({
    required HostEventRosterInsightsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostEventRosterInsightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostEventRosterInsightsHash();

  @override
  String toString() {
    return r'hostEventRosterInsightsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostEventRosterInsights> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostEventRosterInsights> create(Ref ref) {
    final argument = this.argument as String;
    return hostEventRosterInsights(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostEventRosterInsightsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostEventRosterInsightsHash() =>
    r'6006a6ca9aa528ab69d2663b83fa5ddcec6bcf5d';

final class HostEventRosterInsightsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostEventRosterInsights>, String> {
  HostEventRosterInsightsFamily._()
    : super(
        retry: null,
        name: r'hostEventRosterInsightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostEventRosterInsightsProvider call(String eventId) =>
      HostEventRosterInsightsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'hostEventRosterInsightsProvider';
}

@ProviderFor(hostAudience)
final hostAudienceProvider = HostAudienceFamily._();

final class HostAudienceProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostAudiencePage>,
          HostAudiencePage,
          FutureOr<HostAudiencePage>
        >
    with $FutureModifier<HostAudiencePage>, $FutureProvider<HostAudiencePage> {
  HostAudienceProvider._({
    required HostAudienceFamily super.from,
    required (String, HostAudienceQuery) super.argument,
  }) : super(
         retry: null,
         name: r'hostAudienceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostAudienceHash();

  @override
  String toString() {
    return r'hostAudienceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HostAudiencePage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostAudiencePage> create(Ref ref) {
    final argument = this.argument as (String, HostAudienceQuery);
    return hostAudience(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HostAudienceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostAudienceHash() => r'f895d84a108d214b9d0afe8f90bdbd95cf020489';

final class HostAudienceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostAudiencePage>,
          (String, HostAudienceQuery)
        > {
  HostAudienceFamily._()
    : super(
        retry: null,
        name: r'hostAudienceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostAudienceProvider call(String organizerId, HostAudienceQuery query) =>
      HostAudienceProvider._(argument: (organizerId, query), from: this);

  @override
  String toString() => r'hostAudienceProvider';
}

@ProviderFor(hostAudienceContactDetail)
final hostAudienceContactDetailProvider = HostAudienceContactDetailFamily._();

final class HostAudienceContactDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostAudienceContactDetail>,
          HostAudienceContactDetail,
          FutureOr<HostAudienceContactDetail>
        >
    with
        $FutureModifier<HostAudienceContactDetail>,
        $FutureProvider<HostAudienceContactDetail> {
  HostAudienceContactDetailProvider._({
    required HostAudienceContactDetailFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'hostAudienceContactDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostAudienceContactDetailHash();

  @override
  String toString() {
    return r'hostAudienceContactDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HostAudienceContactDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostAudienceContactDetail> create(Ref ref) {
    final argument = this.argument as (String, String);
    return hostAudienceContactDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HostAudienceContactDetailProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostAudienceContactDetailHash() =>
    r'5b65f279a2964fc649a3c0b65291b945e957bde6';

final class HostAudienceContactDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostAudienceContactDetail>,
          (String, String)
        > {
  HostAudienceContactDetailFamily._()
    : super(
        retry: null,
        name: r'hostAudienceContactDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostAudienceContactDetailProvider call(
    String organizerId,
    String contactId,
  ) => HostAudienceContactDetailProvider._(
    argument: (organizerId, contactId),
    from: this,
  );

  @override
  String toString() => r'hostAudienceContactDetailProvider';
}

@ProviderFor(hostMessagingSetup)
final hostMessagingSetupProvider = HostMessagingSetupFamily._();

final class HostMessagingSetupProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostMessagingSetup>,
          HostMessagingSetup,
          FutureOr<HostMessagingSetup>
        >
    with
        $FutureModifier<HostMessagingSetup>,
        $FutureProvider<HostMessagingSetup> {
  HostMessagingSetupProvider._({
    required HostMessagingSetupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostMessagingSetupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostMessagingSetupHash();

  @override
  String toString() {
    return r'hostMessagingSetupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostMessagingSetup> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostMessagingSetup> create(Ref ref) {
    final argument = this.argument as String;
    return hostMessagingSetup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostMessagingSetupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostMessagingSetupHash() =>
    r'46702bc3ef9b10def08a4dd457f55f59ff6a6aed';

final class HostMessagingSetupFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostMessagingSetup>, String> {
  HostMessagingSetupFamily._()
    : super(
        retry: null,
        name: r'hostMessagingSetupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostMessagingSetupProvider call(String organizerId) =>
      HostMessagingSetupProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostMessagingSetupProvider';
}

@ProviderFor(hostSends)
final hostSendsProvider = HostSendsFamily._();

final class HostSendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostSendsPage>,
          HostSendsPage,
          FutureOr<HostSendsPage>
        >
    with $FutureModifier<HostSendsPage>, $FutureProvider<HostSendsPage> {
  HostSendsProvider._({
    required HostSendsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostSendsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostSendsHash();

  @override
  String toString() {
    return r'hostSendsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostSendsPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostSendsPage> create(Ref ref) {
    final argument = this.argument as String;
    return hostSends(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostSendsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostSendsHash() => r'ec7157dc5067f83cfd1a42565826821987b7b472';

final class HostSendsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostSendsPage>, String> {
  HostSendsFamily._()
    : super(
        retry: null,
        name: r'hostSendsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostSendsProvider call(String organizerId) =>
      HostSendsProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostSendsProvider';
}
