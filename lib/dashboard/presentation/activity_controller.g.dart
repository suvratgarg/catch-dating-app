// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern B: Stateless controller + static Mutations**
///
/// Performs batch operations on matches. [markAllReadMutation] tracks the
/// async lifecycle so the UI can show a loading indicator.

@ProviderFor(ActivityController)
final activityControllerProvider = ActivityControllerProvider._();

/// **Pattern B: Stateless controller + static Mutations**
///
/// Performs batch operations on matches. [markAllReadMutation] tracks the
/// async lifecycle so the UI can show a loading indicator.
final class ActivityControllerProvider
    extends $NotifierProvider<ActivityController, void> {
  /// **Pattern B: Stateless controller + static Mutations**
  ///
  /// Performs batch operations on matches. [markAllReadMutation] tracks the
  /// async lifecycle so the UI can show a loading indicator.
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
    r'07356c2bab2ed4832b9554189c231d066b874e5b';

/// **Pattern B: Stateless controller + static Mutations**
///
/// Performs batch operations on matches. [markAllReadMutation] tracks the
/// async lifecycle so the UI can show a loading indicator.

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
