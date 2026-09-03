// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_forms_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostFormsDirectoryController)
final hostFormsDirectoryControllerProvider =
    HostFormsDirectoryControllerFamily._();

final class HostFormsDirectoryControllerProvider
    extends
        $AsyncNotifierProvider<
          HostFormsDirectoryController,
          HostFormsDirectoryState
        > {
  HostFormsDirectoryControllerProvider._({
    required HostFormsDirectoryControllerFamily super.from,
    required HostFormListRequest super.argument,
  }) : super(
         retry: null,
         name: r'hostFormsDirectoryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormsDirectoryControllerHash();

  @override
  String toString() {
    return r'hostFormsDirectoryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostFormsDirectoryController create() => HostFormsDirectoryController();

  @override
  bool operator ==(Object other) {
    return other is HostFormsDirectoryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormsDirectoryControllerHash() =>
    r'41428a72b0ccc5c72c1d36d19a98c6b60d05efa4';

final class HostFormsDirectoryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostFormsDirectoryController,
          AsyncValue<HostFormsDirectoryState>,
          HostFormsDirectoryState,
          FutureOr<HostFormsDirectoryState>,
          HostFormListRequest
        > {
  HostFormsDirectoryControllerFamily._()
    : super(
        retry: null,
        name: r'hostFormsDirectoryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormsDirectoryControllerProvider call(HostFormListRequest request) =>
      HostFormsDirectoryControllerProvider._(argument: request, from: this);

  @override
  String toString() => r'hostFormsDirectoryControllerProvider';
}

abstract class _$HostFormsDirectoryController
    extends $AsyncNotifier<HostFormsDirectoryState> {
  late final _$args = ref.$arg as HostFormListRequest;
  HostFormListRequest get request => _$args;

  FutureOr<HostFormsDirectoryState> build(HostFormListRequest request);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HostFormsDirectoryState>,
              HostFormsDirectoryState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostFormsDirectoryState>,
                HostFormsDirectoryState
              >,
              AsyncValue<HostFormsDirectoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(HostFormEditorController)
final hostFormEditorControllerProvider = HostFormEditorControllerFamily._();

final class HostFormEditorControllerProvider
    extends
        $AsyncNotifierProvider<HostFormEditorController, HostFormEditorState> {
  HostFormEditorControllerProvider._({
    required HostFormEditorControllerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'hostFormEditorControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormEditorControllerHash();

  @override
  String toString() {
    return r'hostFormEditorControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  HostFormEditorController create() => HostFormEditorController();

  @override
  bool operator ==(Object other) {
    return other is HostFormEditorControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormEditorControllerHash() =>
    r'f0159fb284432ce4145e2407dde8ebea62d40a7c';

final class HostFormEditorControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostFormEditorController,
          AsyncValue<HostFormEditorState>,
          HostFormEditorState,
          FutureOr<HostFormEditorState>,
          (String, String)
        > {
  HostFormEditorControllerFamily._()
    : super(
        retry: null,
        name: r'hostFormEditorControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormEditorControllerProvider call(String organizerId, String formId) =>
      HostFormEditorControllerProvider._(
        argument: (organizerId, formId),
        from: this,
      );

  @override
  String toString() => r'hostFormEditorControllerProvider';
}

abstract class _$HostFormEditorController
    extends $AsyncNotifier<HostFormEditorState> {
  late final _$args = ref.$arg as (String, String);
  String get organizerId => _$args.$1;
  String get formId => _$args.$2;

  FutureOr<HostFormEditorState> build(String organizerId, String formId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<HostFormEditorState>, HostFormEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HostFormEditorState>, HostFormEditorState>,
              AsyncValue<HostFormEditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(hostFormShareAssetsController)
final hostFormShareAssetsControllerProvider =
    HostFormShareAssetsControllerFamily._();

final class HostFormShareAssetsControllerProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostFormShareAssets>,
          HostFormShareAssets,
          FutureOr<HostFormShareAssets>
        >
    with
        $FutureModifier<HostFormShareAssets>,
        $FutureProvider<HostFormShareAssets> {
  HostFormShareAssetsControllerProvider._({
    required HostFormShareAssetsControllerFamily super.from,
    required ({String organizerId, String formId}) super.argument,
  }) : super(
         retry: null,
         name: r'hostFormShareAssetsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormShareAssetsControllerHash();

  @override
  String toString() {
    return r'hostFormShareAssetsControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HostFormShareAssets> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostFormShareAssets> create(Ref ref) {
    final argument = this.argument as ({String organizerId, String formId});
    return hostFormShareAssetsController(
      ref,
      organizerId: argument.organizerId,
      formId: argument.formId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HostFormShareAssetsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormShareAssetsControllerHash() =>
    r'8fef45385f72a7b9219b152c2abd2ce82109f0b0';

final class HostFormShareAssetsControllerFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostFormShareAssets>,
          ({String organizerId, String formId})
        > {
  HostFormShareAssetsControllerFamily._()
    : super(
        retry: null,
        name: r'hostFormShareAssetsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormShareAssetsControllerProvider call({
    required String organizerId,
    required String formId,
  }) => HostFormShareAssetsControllerProvider._(
    argument: (organizerId: organizerId, formId: formId),
    from: this,
  );

  @override
  String toString() => r'hostFormShareAssetsControllerProvider';
}

@ProviderFor(hostFormsController)
final hostFormsControllerProvider = HostFormsControllerProvider._();

final class HostFormsControllerProvider
    extends
        $FunctionalProvider<
          HostFormsController,
          HostFormsController,
          HostFormsController
        >
    with $Provider<HostFormsController> {
  HostFormsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostFormsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostFormsControllerHash();

  @$internal
  @override
  $ProviderElement<HostFormsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostFormsController create(Ref ref) {
    return hostFormsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostFormsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostFormsController>(value),
    );
  }
}

String _$hostFormsControllerHash() =>
    r'b6ea9e9a8411ed939d1e10bec121069bffecfb3c';
