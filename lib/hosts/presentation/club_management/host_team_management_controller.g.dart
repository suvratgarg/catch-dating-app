// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_team_management_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostTeamManagementController)
final hostTeamManagementControllerProvider =
    HostTeamManagementControllerProvider._();

final class HostTeamManagementControllerProvider
    extends $NotifierProvider<HostTeamManagementController, void> {
  HostTeamManagementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostTeamManagementControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostTeamManagementControllerHash();

  @$internal
  @override
  HostTeamManagementController create() => HostTeamManagementController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$hostTeamManagementControllerHash() =>
    r'c56c229cf5b43944bb2d704f8ce2d87cd83b804b';

abstract class _$HostTeamManagementController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
