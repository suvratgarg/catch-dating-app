// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_booking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RunBookingController)
final runBookingControllerProvider = RunBookingControllerProvider._();

final class RunBookingControllerProvider
    extends $NotifierProvider<RunBookingController, void> {
  RunBookingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runBookingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runBookingControllerHash();

  @$internal
  @override
  RunBookingController create() => RunBookingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$runBookingControllerHash() =>
    r'6b0a52a47d2fe3c055fc5c51877d20c06f27815f';

abstract class _$RunBookingController extends $Notifier<void> {
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
