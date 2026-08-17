// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_applications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostApplicationsDirectoryController)
final hostApplicationsDirectoryControllerProvider =
    HostApplicationsDirectoryControllerFamily._();

final class HostApplicationsDirectoryControllerProvider
    extends
        $AsyncNotifierProvider<
          HostApplicationsDirectoryController,
          HostApplicationsDirectoryState
        > {
  HostApplicationsDirectoryControllerProvider._({
    required HostApplicationsDirectoryControllerFamily super.from,
    required HostApplicationListRequest super.argument,
  }) : super(
         retry: null,
         name: r'hostApplicationsDirectoryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$hostApplicationsDirectoryControllerHash();

  @override
  String toString() {
    return r'hostApplicationsDirectoryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostApplicationsDirectoryController create() =>
      HostApplicationsDirectoryController();

  @override
  bool operator ==(Object other) {
    return other is HostApplicationsDirectoryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostApplicationsDirectoryControllerHash() =>
    r'79445ef422c7077dd13306665c2971a2cece0b8c';

final class HostApplicationsDirectoryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostApplicationsDirectoryController,
          AsyncValue<HostApplicationsDirectoryState>,
          HostApplicationsDirectoryState,
          FutureOr<HostApplicationsDirectoryState>,
          HostApplicationListRequest
        > {
  HostApplicationsDirectoryControllerFamily._()
    : super(
        retry: null,
        name: r'hostApplicationsDirectoryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostApplicationsDirectoryControllerProvider call(
    HostApplicationListRequest request,
  ) => HostApplicationsDirectoryControllerProvider._(
    argument: request,
    from: this,
  );

  @override
  String toString() => r'hostApplicationsDirectoryControllerProvider';
}

abstract class _$HostApplicationsDirectoryController
    extends $AsyncNotifier<HostApplicationsDirectoryState> {
  late final _$args = ref.$arg as HostApplicationListRequest;
  HostApplicationListRequest get request => _$args;

  FutureOr<HostApplicationsDirectoryState> build(
    HostApplicationListRequest request,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HostApplicationsDirectoryState>,
              HostApplicationsDirectoryState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostApplicationsDirectoryState>,
                HostApplicationsDirectoryState
              >,
              AsyncValue<HostApplicationsDirectoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(hostApplicationsController)
final hostApplicationsControllerProvider =
    HostApplicationsControllerProvider._();

final class HostApplicationsControllerProvider
    extends
        $FunctionalProvider<
          HostApplicationsController,
          HostApplicationsController,
          HostApplicationsController
        >
    with $Provider<HostApplicationsController> {
  HostApplicationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostApplicationsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostApplicationsControllerHash();

  @$internal
  @override
  $ProviderElement<HostApplicationsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostApplicationsController create(Ref ref) {
    return hostApplicationsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostApplicationsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostApplicationsController>(value),
    );
  }
}

String _$hostApplicationsControllerHash() =>
    r'6bd9823ca821cf953b519c1d7ab648334bde7446';
