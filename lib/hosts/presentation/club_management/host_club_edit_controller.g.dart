// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_club_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostClubEditController)
final hostClubEditControllerProvider = HostClubEditControllerProvider._();

final class HostClubEditControllerProvider
    extends
        $FunctionalProvider<
          HostClubEditActions,
          HostClubEditActions,
          HostClubEditActions
        >
    with $Provider<HostClubEditActions> {
  HostClubEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostClubEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostClubEditControllerHash();

  @$internal
  @override
  $ProviderElement<HostClubEditActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostClubEditActions create(Ref ref) {
    return hostClubEditController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostClubEditActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostClubEditActions>(value),
    );
  }
}

String _$hostClubEditControllerHash() =>
    r'83e16b57a3a0368a9f97b48a75b656199e45b140';
