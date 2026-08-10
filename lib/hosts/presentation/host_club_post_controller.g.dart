// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_club_post_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostClubPostController)
final hostClubPostControllerProvider = HostClubPostControllerProvider._();

final class HostClubPostControllerProvider
    extends
        $FunctionalProvider<
          HostClubPostController,
          HostClubPostController,
          HostClubPostController
        >
    with $Provider<HostClubPostController> {
  HostClubPostControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostClubPostControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostClubPostControllerHash();

  @$internal
  @override
  $ProviderElement<HostClubPostController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostClubPostController create(Ref ref) {
    return hostClubPostController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostClubPostController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostClubPostController>(value),
    );
  }
}

String _$hostClubPostControllerHash() =>
    r'1e826d5d8522381c49191fdd501687eebd7eda8a';
