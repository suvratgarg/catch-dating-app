// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_run_club_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateRunClubController)
final createRunClubControllerProvider = CreateRunClubControllerProvider._();

final class CreateRunClubControllerProvider
    extends $NotifierProvider<CreateRunClubController, void> {
  CreateRunClubControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRunClubControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRunClubControllerHash();

  @$internal
  @override
  CreateRunClubController create() => CreateRunClubController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createRunClubControllerHash() =>
    r'64b35d9a07686ae4b8c35e1692c1bbb240545fcb';

abstract class _$CreateRunClubController extends $Notifier<void> {
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
