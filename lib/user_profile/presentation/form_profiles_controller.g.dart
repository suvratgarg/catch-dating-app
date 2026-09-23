// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_profiles_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FormProfilesController)
final formProfilesControllerProvider = FormProfilesControllerProvider._();

final class FormProfilesControllerProvider
    extends $AsyncNotifierProvider<FormProfilesController, FormProfilesState> {
  FormProfilesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'formProfilesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$formProfilesControllerHash();

  @$internal
  @override
  FormProfilesController create() => FormProfilesController();
}

String _$formProfilesControllerHash() =>
    r'd20730ede9958f93a88d371974e3d93b22ca78e0';

abstract class _$FormProfilesController
    extends $AsyncNotifier<FormProfilesState> {
  FutureOr<FormProfilesState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<FormProfilesState>, FormProfilesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FormProfilesState>, FormProfilesState>,
              AsyncValue<FormProfilesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(formProfileReview)
final formProfileReviewProvider = FormProfileReviewFamily._();

final class FormProfileReviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<FormProfileReview>,
          FormProfileReview,
          FutureOr<FormProfileReview>
        >
    with
        $FutureModifier<FormProfileReview>,
        $FutureProvider<FormProfileReview> {
  FormProfileReviewProvider._({
    required FormProfileReviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'formProfileReviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$formProfileReviewHash();

  @override
  String toString() {
    return r'formProfileReviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FormProfileReview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FormProfileReview> create(Ref ref) {
    final argument = this.argument as String;
    return formProfileReview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FormProfileReviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$formProfileReviewHash() => r'd382e44fec2fb7bec8db3fee1e000ab70af566b7';

final class FormProfileReviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FormProfileReview>, String> {
  FormProfileReviewFamily._()
    : super(
        retry: null,
        name: r'formProfileReviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FormProfileReviewProvider call(String responseId) =>
      FormProfileReviewProvider._(argument: responseId, from: this);

  @override
  String toString() => r'formProfileReviewProvider';
}

@ProviderFor(FormProfileClaimController)
final formProfileClaimControllerProvider =
    FormProfileClaimControllerProvider._();

final class FormProfileClaimControllerProvider
    extends $NotifierProvider<FormProfileClaimController, void> {
  FormProfileClaimControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'formProfileClaimControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$formProfileClaimControllerHash();

  @$internal
  @override
  FormProfileClaimController create() => FormProfileClaimController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$formProfileClaimControllerHash() =>
    r'2b78923aa2b3470a5b0862cf1dd755b0caa3bd59';

abstract class _$FormProfileClaimController extends $Notifier<void> {
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
