// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runClubDetailViewModel)
final runClubDetailViewModelProvider = RunClubDetailViewModelFamily._();

final class RunClubDetailViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunClubDetailViewModel?>,
          AsyncValue<RunClubDetailViewModel?>,
          AsyncValue<RunClubDetailViewModel?>
        >
    with $Provider<AsyncValue<RunClubDetailViewModel?>> {
  RunClubDetailViewModelProvider._({
    required RunClubDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runClubDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runClubDetailViewModelHash();

  @override
  String toString() {
    return r'runClubDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<RunClubDetailViewModel?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RunClubDetailViewModel?> create(Ref ref) {
    final argument = this.argument as String;
    return runClubDetailViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RunClubDetailViewModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RunClubDetailViewModel?>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RunClubDetailViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runClubDetailViewModelHash() =>
    r'd442a4adce675171c688046526359780966f227a';

final class RunClubDetailViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<AsyncValue<RunClubDetailViewModel?>, String> {
  RunClubDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'runClubDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RunClubDetailViewModelProvider call(String clubId) =>
      RunClubDetailViewModelProvider._(argument: clubId, from: this);

  @override
  String toString() => r'runClubDetailViewModelProvider';
}

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
    r'4f2489a3ce15d04fd0c22da33bc5334c8e597daf';

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
