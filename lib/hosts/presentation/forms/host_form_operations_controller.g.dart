// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_form_operations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostFormResponsesController)
final hostFormResponsesControllerProvider =
    HostFormResponsesControllerFamily._();

final class HostFormResponsesControllerProvider
    extends
        $AsyncNotifierProvider<
          HostFormResponsesController,
          HostFormResponsesState
        > {
  HostFormResponsesControllerProvider._({
    required HostFormResponsesControllerFamily super.from,
    required HostFormResponseListRequest super.argument,
  }) : super(
         retry: null,
         name: r'hostFormResponsesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormResponsesControllerHash();

  @override
  String toString() {
    return r'hostFormResponsesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostFormResponsesController create() => HostFormResponsesController();

  @override
  bool operator ==(Object other) {
    return other is HostFormResponsesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormResponsesControllerHash() =>
    r'e6a4130f7cffd08fbf9471071cb050e42cc50ffc';

final class HostFormResponsesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostFormResponsesController,
          AsyncValue<HostFormResponsesState>,
          HostFormResponsesState,
          FutureOr<HostFormResponsesState>,
          HostFormResponseListRequest
        > {
  HostFormResponsesControllerFamily._()
    : super(
        retry: null,
        name: r'hostFormResponsesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormResponsesControllerProvider call(
    HostFormResponseListRequest request,
  ) => HostFormResponsesControllerProvider._(argument: request, from: this);

  @override
  String toString() => r'hostFormResponsesControllerProvider';
}

abstract class _$HostFormResponsesController
    extends $AsyncNotifier<HostFormResponsesState> {
  late final _$args = ref.$arg as HostFormResponseListRequest;
  HostFormResponseListRequest get request => _$args;

  FutureOr<HostFormResponsesState> build(HostFormResponseListRequest request);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<HostFormResponsesState>, HostFormResponsesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostFormResponsesState>,
                HostFormResponsesState
              >,
              AsyncValue<HostFormResponsesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(hostFormResponseDetail)
final hostFormResponseDetailProvider = HostFormResponseDetailFamily._();

final class HostFormResponseDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostFormResponseDetail>,
          HostFormResponseDetail,
          FutureOr<HostFormResponseDetail>
        >
    with
        $FutureModifier<HostFormResponseDetail>,
        $FutureProvider<HostFormResponseDetail> {
  HostFormResponseDetailProvider._({
    required HostFormResponseDetailFamily super.from,
    required ({String organizerId, String responseId}) super.argument,
  }) : super(
         retry: null,
         name: r'hostFormResponseDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormResponseDetailHash();

  @override
  String toString() {
    return r'hostFormResponseDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HostFormResponseDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostFormResponseDetail> create(Ref ref) {
    final argument = this.argument as ({String organizerId, String responseId});
    return hostFormResponseDetail(
      ref,
      organizerId: argument.organizerId,
      responseId: argument.responseId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HostFormResponseDetailProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormResponseDetailHash() =>
    r'9d05632a979d37b5677f1af63369175c5bdc1592';

final class HostFormResponseDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostFormResponseDetail>,
          ({String organizerId, String responseId})
        > {
  HostFormResponseDetailFamily._()
    : super(
        retry: null,
        name: r'hostFormResponseDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormResponseDetailProvider call({
    required String organizerId,
    required String responseId,
  }) => HostFormResponseDetailProvider._(
    argument: (organizerId: organizerId, responseId: responseId),
    from: this,
  );

  @override
  String toString() => r'hostFormResponseDetailProvider';
}

@ProviderFor(hostFormAnalytics)
final hostFormAnalyticsProvider = HostFormAnalyticsFamily._();

final class HostFormAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostFormAnalytics>,
          HostFormAnalytics,
          FutureOr<HostFormAnalytics>
        >
    with
        $FutureModifier<HostFormAnalytics>,
        $FutureProvider<HostFormAnalytics> {
  HostFormAnalyticsProvider._({
    required HostFormAnalyticsFamily super.from,
    required ({String organizerId, String formId, String? versionId})
    super.argument,
  }) : super(
         retry: null,
         name: r'hostFormAnalyticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormAnalyticsHash();

  @override
  String toString() {
    return r'hostFormAnalyticsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HostFormAnalytics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostFormAnalytics> create(Ref ref) {
    final argument =
        this.argument
            as ({String organizerId, String formId, String? versionId});
    return hostFormAnalytics(
      ref,
      organizerId: argument.organizerId,
      formId: argument.formId,
      versionId: argument.versionId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HostFormAnalyticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormAnalyticsHash() => r'ffcc8a3bcf04927f9c80f290e3d4c629bec657e6';

final class HostFormAnalyticsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostFormAnalytics>,
          ({String organizerId, String formId, String? versionId})
        > {
  HostFormAnalyticsFamily._()
    : super(
        retry: null,
        name: r'hostFormAnalyticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormAnalyticsProvider call({
    required String organizerId,
    required String formId,
    String? versionId,
  }) => HostFormAnalyticsProvider._(
    argument: (organizerId: organizerId, formId: formId, versionId: versionId),
    from: this,
  );

  @override
  String toString() => r'hostFormAnalyticsProvider';
}

@ProviderFor(HostFormAutomationsController)
final hostFormAutomationsControllerProvider =
    HostFormAutomationsControllerFamily._();

final class HostFormAutomationsControllerProvider
    extends
        $AsyncNotifierProvider<
          HostFormAutomationsController,
          HostFormAutomationsState
        > {
  HostFormAutomationsControllerProvider._({
    required HostFormAutomationsControllerFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'hostFormAutomationsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormAutomationsControllerHash();

  @override
  String toString() {
    return r'hostFormAutomationsControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  HostFormAutomationsController create() => HostFormAutomationsController();

  @override
  bool operator ==(Object other) {
    return other is HostFormAutomationsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormAutomationsControllerHash() =>
    r'28fded3017fca77acb4d17acef720ea9aab36c49';

final class HostFormAutomationsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostFormAutomationsController,
          AsyncValue<HostFormAutomationsState>,
          HostFormAutomationsState,
          FutureOr<HostFormAutomationsState>,
          (String, String?)
        > {
  HostFormAutomationsControllerFamily._()
    : super(
        retry: null,
        name: r'hostFormAutomationsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormAutomationsControllerProvider call(
    String organizerId,
    String? formId,
  ) => HostFormAutomationsControllerProvider._(
    argument: (organizerId, formId),
    from: this,
  );

  @override
  String toString() => r'hostFormAutomationsControllerProvider';
}

abstract class _$HostFormAutomationsController
    extends $AsyncNotifier<HostFormAutomationsState> {
  late final _$args = ref.$arg as (String, String?);
  String get organizerId => _$args.$1;
  String? get formId => _$args.$2;

  FutureOr<HostFormAutomationsState> build(String organizerId, String? formId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HostFormAutomationsState>,
              HostFormAutomationsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostFormAutomationsState>,
                HostFormAutomationsState
              >,
              AsyncValue<HostFormAutomationsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(HostAutomationMessagesController)
final hostAutomationMessagesControllerProvider =
    HostAutomationMessagesControllerFamily._();

final class HostAutomationMessagesControllerProvider
    extends
        $AsyncNotifierProvider<
          HostAutomationMessagesController,
          HostAutomationMessagesState
        > {
  HostAutomationMessagesControllerProvider._({
    required HostAutomationMessagesControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostAutomationMessagesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostAutomationMessagesControllerHash();

  @override
  String toString() {
    return r'hostAutomationMessagesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostAutomationMessagesController create() =>
      HostAutomationMessagesController();

  @override
  bool operator ==(Object other) {
    return other is HostAutomationMessagesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostAutomationMessagesControllerHash() =>
    r'8286ee1821d50ae1ac21a2f42b32850c7f07c340';

final class HostAutomationMessagesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostAutomationMessagesController,
          AsyncValue<HostAutomationMessagesState>,
          HostAutomationMessagesState,
          FutureOr<HostAutomationMessagesState>,
          String
        > {
  HostAutomationMessagesControllerFamily._()
    : super(
        retry: null,
        name: r'hostAutomationMessagesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostAutomationMessagesControllerProvider call(String organizerId) =>
      HostAutomationMessagesControllerProvider._(
        argument: organizerId,
        from: this,
      );

  @override
  String toString() => r'hostAutomationMessagesControllerProvider';
}

abstract class _$HostAutomationMessagesController
    extends $AsyncNotifier<HostAutomationMessagesState> {
  late final _$args = ref.$arg as String;
  String get organizerId => _$args;

  FutureOr<HostAutomationMessagesState> build(String organizerId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HostAutomationMessagesState>,
              HostAutomationMessagesState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostAutomationMessagesState>,
                HostAutomationMessagesState
              >,
              AsyncValue<HostAutomationMessagesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
