// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RunClubDetailController)
final runClubDetailControllerProvider = RunClubDetailControllerProvider._();

final class RunClubDetailControllerProvider
    extends $NotifierProvider<RunClubDetailController, void> {
  RunClubDetailControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubDetailControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubDetailControllerHash();

  @$internal
  @override
  RunClubDetailController create() => RunClubDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$runClubDetailControllerHash() =>
    r'5d8a91df95117762762e9284b4c226b16e2d8d5b';

abstract class _$RunClubDetailController extends $Notifier<void> {
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
