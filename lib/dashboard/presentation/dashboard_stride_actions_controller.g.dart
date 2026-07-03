// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stride_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardStrideActions)
final dashboardStrideActionsProvider = DashboardStrideActionsProvider._();

final class DashboardStrideActionsProvider
    extends
        $FunctionalProvider<
          DashboardStrideActions,
          DashboardStrideActions,
          DashboardStrideActions
        >
    with $Provider<DashboardStrideActions> {
  DashboardStrideActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStrideActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStrideActionsHash();

  @$internal
  @override
  $ProviderElement<DashboardStrideActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardStrideActions create(Ref ref) {
    return dashboardStrideActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardStrideActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardStrideActions>(value),
    );
  }
}

String _$dashboardStrideActionsHash() =>
    r'b2326a1d20866273e0c8a2c67ca6f320e75ba941';
