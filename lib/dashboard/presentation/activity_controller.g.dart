// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActivityController)
final activityControllerProvider = ActivityControllerProvider._();

final class ActivityControllerProvider
    extends $NotifierProvider<ActivityController, void> {
  ActivityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityControllerHash();

  @$internal
  @override
  ActivityController create() => ActivityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$activityControllerHash() =>
    r'397339963dad84555318a556802b6992f9643728';

abstract class _$ActivityController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
