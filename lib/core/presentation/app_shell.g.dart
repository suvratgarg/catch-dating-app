// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_shell.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appShellFcmInitialization)
final appShellFcmInitializationProvider = AppShellFcmInitializationFamily._();

final class AppShellFcmInitializationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  AppShellFcmInitializationProvider._({
    required AppShellFcmInitializationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'appShellFcmInitializationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$appShellFcmInitializationHash();

  @override
  String toString() {
    return r'appShellFcmInitializationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return appShellFcmInitialization(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AppShellFcmInitializationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appShellFcmInitializationHash() =>
    r'312e963b1cb0760e18f06a2477debb8a3c678626';

final class AppShellFcmInitializationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  AppShellFcmInitializationFamily._()
    : super(
        retry: null,
        name: r'appShellFcmInitializationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AppShellFcmInitializationProvider call(String uid) =>
      AppShellFcmInitializationProvider._(argument: uid, from: this);

  @override
  String toString() => r'appShellFcmInitializationProvider';
}
