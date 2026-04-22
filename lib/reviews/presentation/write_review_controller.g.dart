// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'write_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WriteReviewController)
final writeReviewControllerProvider = WriteReviewControllerProvider._();

final class WriteReviewControllerProvider
    extends $NotifierProvider<WriteReviewController, void> {
  WriteReviewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writeReviewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writeReviewControllerHash();

  @$internal
  @override
  WriteReviewController create() => WriteReviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$writeReviewControllerHash() =>
    r'2b090116fd77513ad9ba8e99d67e854ca64dfa96';

abstract class _$WriteReviewController extends $Notifier<void> {
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
