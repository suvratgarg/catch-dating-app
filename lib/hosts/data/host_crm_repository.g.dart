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

@ProviderFor(hostCommunicationPlan)
final hostCommunicationPlanProvider = HostCommunicationPlanFamily._();

final class HostCommunicationPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostCommunicationPlan>,
          HostCommunicationPlan,
          FutureOr<HostCommunicationPlan>
        >
    with
        $FutureModifier<HostCommunicationPlan>,
        $FutureProvider<HostCommunicationPlan> {
  HostCommunicationPlanProvider._({
    required HostCommunicationPlanFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'hostCommunicationPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostCommunicationPlanHash();

  @override
  String toString() {
    return r'hostCommunicationPlanProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HostCommunicationPlan> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostCommunicationPlan> create(Ref ref) {
    final argument = this.argument as (String, String);
    return hostCommunicationPlan(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HostCommunicationPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostCommunicationPlanHash() =>
    r'8b35c3592bdc0b71c30a32e4e97ebd757e8322a6';

final class HostCommunicationPlanFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostCommunicationPlan>,
          (String, String)
        > {
  HostCommunicationPlanFamily._()
    : super(
        retry: null,
        name: r'hostCommunicationPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostCommunicationPlanProvider call(String organizerId, String contactId) =>
      HostCommunicationPlanProvider._(
        argument: (organizerId, contactId),
        from: this,
      );

  @override
  String toString() => r'hostCommunicationPlanProvider';
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
    r'b469dd456cd1ac35bb072e6ad04627ea34df23bd';

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
    r'6a79425d905cab583d40aa3a1c2ad0690c59e9b4';

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

@ProviderFor(hostManualSendTasks)
final hostManualSendTasksProvider = HostManualSendTasksFamily._();

final class HostManualSendTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostManualSendTaskPage>,
          HostManualSendTaskPage,
          FutureOr<HostManualSendTaskPage>
        >
    with
        $FutureModifier<HostManualSendTaskPage>,
        $FutureProvider<HostManualSendTaskPage> {
  HostManualSendTasksProvider._({
    required HostManualSendTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostManualSendTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostManualSendTasksHash();

  @override
  String toString() {
    return r'hostManualSendTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostManualSendTaskPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostManualSendTaskPage> create(Ref ref) {
    final argument = this.argument as String;
    return hostManualSendTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostManualSendTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostManualSendTasksHash() =>
    r'edaf484d821b42b4d143d1a7130ed8c526d92489';

final class HostManualSendTasksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostManualSendTaskPage>, String> {
  HostManualSendTasksFamily._()
    : super(
        retry: null,
        name: r'hostManualSendTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostManualSendTasksProvider call(String organizerId) =>
      HostManualSendTasksProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostManualSendTasksProvider';
}

@ProviderFor(hostWhatsappThreads)
final hostWhatsappThreadsProvider = HostWhatsappThreadsFamily._();

final class HostWhatsappThreadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostWhatsappThreadPage>,
          HostWhatsappThreadPage,
          FutureOr<HostWhatsappThreadPage>
        >
    with
        $FutureModifier<HostWhatsappThreadPage>,
        $FutureProvider<HostWhatsappThreadPage> {
  HostWhatsappThreadsProvider._({
    required HostWhatsappThreadsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostWhatsappThreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostWhatsappThreadsHash();

  @override
  String toString() {
    return r'hostWhatsappThreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostWhatsappThreadPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostWhatsappThreadPage> create(Ref ref) {
    final argument = this.argument as String;
    return hostWhatsappThreads(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostWhatsappThreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostWhatsappThreadsHash() =>
    r'94980382783113c79fa563ea06d95660f383459e';

final class HostWhatsappThreadsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostWhatsappThreadPage>, String> {
  HostWhatsappThreadsFamily._()
    : super(
        retry: null,
        name: r'hostWhatsappThreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostWhatsappThreadsProvider call(String organizerId) =>
      HostWhatsappThreadsProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostWhatsappThreadsProvider';
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
    r'4b9346ad9d975d12692bd6a5d5006ed85d297647';

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
