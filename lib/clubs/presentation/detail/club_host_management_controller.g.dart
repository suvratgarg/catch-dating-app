// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_host_management_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClubHostManagementController)
final clubHostManagementControllerProvider =
    ClubHostManagementControllerProvider._();

final class ClubHostManagementControllerProvider
    extends $NotifierProvider<ClubHostManagementController, void> {
  ClubHostManagementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubHostManagementControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubHostManagementControllerHash();

  @$internal
  @override
  ClubHostManagementController create() => ClubHostManagementController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$clubHostManagementControllerHash() =>
    r'a4785376f8cf467377b23c357ca64c7c08839833';

abstract class _$ClubHostManagementController extends $Notifier<void> {
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
