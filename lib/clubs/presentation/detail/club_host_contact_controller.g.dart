// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_host_contact_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClubHostContactController)
final clubHostContactControllerProvider = ClubHostContactControllerProvider._();

final class ClubHostContactControllerProvider
    extends $NotifierProvider<ClubHostContactController, void> {
  ClubHostContactControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubHostContactControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubHostContactControllerHash();

  @$internal
  @override
  ClubHostContactController create() => ClubHostContactController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$clubHostContactControllerHash() =>
    r'959edc995023bd7f0b3b2fbdbc9561402b4d4c10';

abstract class _$ClubHostContactController extends $Notifier<void> {
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
