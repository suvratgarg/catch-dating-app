// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'write_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Most common mutation pattern in the app. [build] returns void — the
/// controller holds no Riverpod state. [Mutation]s ([submitMutation],
/// [deleteMutation]) track the lifecycle of single-shot operations.
/// The UI watches mutations directly via `ref.watch(controller.mutation)`
/// and checks `.isPending`, `.hasError`, `.isSuccess`.

@ProviderFor(WriteReviewController)
final writeReviewControllerProvider = WriteReviewControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Most common mutation pattern in the app. [build] returns void — the
/// controller holds no Riverpod state. [Mutation]s ([submitMutation],
/// [deleteMutation]) track the lifecycle of single-shot operations.
/// The UI watches mutations directly via `ref.watch(controller.mutation)`
/// and checks `.isPending`, `.hasError`, `.isSuccess`.
final class WriteReviewControllerProvider
    extends $NotifierProvider<WriteReviewController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Most common mutation pattern in the app. [build] returns void — the
  /// controller holds no Riverpod state. [Mutation]s ([submitMutation],
  /// [deleteMutation]) track the lifecycle of single-shot operations.
  /// The UI watches mutations directly via `ref.watch(controller.mutation)`
  /// and checks `.isPending`, `.hasError`, `.isSuccess`.
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
    r'a5280d6bef96ad0a70bf3aad1c12d13c6af291e4';

/// **Pattern A: Action controller + static Mutations**
///
/// Most common mutation pattern in the app. [build] returns void — the
/// controller holds no Riverpod state. [Mutation]s ([submitMutation],
/// [deleteMutation]) track the lifecycle of single-shot operations.
/// The UI watches mutations directly via `ref.watch(controller.mutation)`
/// and checks `.isPending`, `.hasError`, `.isSuccess`.

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
