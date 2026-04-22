// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerFamily._();

final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthState> {
  AuthControllerProvider._({
    required AuthControllerFamily super.from,
    required AuthState super.argument,
  }) : super(
         retry: null,
         name: r'authControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @override
  String toString() {
    return r'authControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AuthControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authControllerHash() => r'9fdbd837a441bbf22feb4750a0d992d14a27d5b0';

final class AuthControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AuthController,
          AuthState,
          AuthState,
          AuthState,
          AuthState
        > {
  AuthControllerFamily._()
    : super(
        retry: null,
        name: r'authControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuthControllerProvider call({required AuthState authState}) =>
      AuthControllerProvider._(argument: authState, from: this);

  @override
  String toString() => r'authControllerProvider';
}

abstract class _$AuthController extends $Notifier<AuthState> {
  late final _$args = ref.$arg as AuthState;
  AuthState get authState => _$args;

  AuthState build({required AuthState authState});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(authState: _$args));
  }
}
