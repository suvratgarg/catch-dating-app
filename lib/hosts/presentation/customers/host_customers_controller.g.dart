// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostCustomersDirectoryController)
final hostCustomersDirectoryControllerProvider =
    HostCustomersDirectoryControllerFamily._();

final class HostCustomersDirectoryControllerProvider
    extends
        $AsyncNotifierProvider<
          HostCustomersDirectoryController,
          HostCustomersDirectoryState
        > {
  HostCustomersDirectoryControllerProvider._({
    required HostCustomersDirectoryControllerFamily super.from,
    required HostCustomersDirectoryRequest super.argument,
  }) : super(
         retry: null,
         name: r'hostCustomersDirectoryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostCustomersDirectoryControllerHash();

  @override
  String toString() {
    return r'hostCustomersDirectoryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostCustomersDirectoryController create() =>
      HostCustomersDirectoryController();

  @override
  bool operator ==(Object other) {
    return other is HostCustomersDirectoryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostCustomersDirectoryControllerHash() =>
    r'5df82fc8d6b3474836d4e9992a37e2ca5e5766bf';

final class HostCustomersDirectoryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostCustomersDirectoryController,
          AsyncValue<HostCustomersDirectoryState>,
          HostCustomersDirectoryState,
          FutureOr<HostCustomersDirectoryState>,
          HostCustomersDirectoryRequest
        > {
  HostCustomersDirectoryControllerFamily._()
    : super(
        retry: null,
        name: r'hostCustomersDirectoryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostCustomersDirectoryControllerProvider call(
    HostCustomersDirectoryRequest request,
  ) =>
      HostCustomersDirectoryControllerProvider._(argument: request, from: this);

  @override
  String toString() => r'hostCustomersDirectoryControllerProvider';
}

abstract class _$HostCustomersDirectoryController
    extends $AsyncNotifier<HostCustomersDirectoryState> {
  late final _$args = ref.$arg as HostCustomersDirectoryRequest;
  HostCustomersDirectoryRequest get request => _$args;

  FutureOr<HostCustomersDirectoryState> build(
    HostCustomersDirectoryRequest request,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HostCustomersDirectoryState>,
              HostCustomersDirectoryState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostCustomersDirectoryState>,
                HostCustomersDirectoryState
              >,
              AsyncValue<HostCustomersDirectoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(hostCustomersController)
final hostCustomersControllerProvider = HostCustomersControllerProvider._();

final class HostCustomersControllerProvider
    extends
        $FunctionalProvider<
          HostCustomersController,
          HostCustomersController,
          HostCustomersController
        >
    with $Provider<HostCustomersController> {
  HostCustomersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostCustomersControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostCustomersControllerHash();

  @$internal
  @override
  $ProviderElement<HostCustomersController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostCustomersController create(Ref ref) {
    return hostCustomersController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostCustomersController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostCustomersController>(value),
    );
  }
}

String _$hostCustomersControllerHash() =>
    r'a94e6b28602f03ed7822d21579850a6e304612eb';
