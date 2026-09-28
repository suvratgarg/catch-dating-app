// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_release_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostReleaseFlag)
final hostReleaseFlagProvider = HostReleaseFlagFamily._();

final class HostReleaseFlagProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  HostReleaseFlagProvider._({
    required HostReleaseFlagFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostReleaseFlagProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostReleaseFlagHash();

  @override
  String toString() {
    return r'hostReleaseFlagProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return hostReleaseFlag(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HostReleaseFlagProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostReleaseFlagHash() => r'3d9fa6f9a3b8fd8b2ea78f5445b71f03eb757ba1';

final class HostReleaseFlagFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  HostReleaseFlagFamily._()
    : super(
        retry: null,
        name: r'hostReleaseFlagProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  HostReleaseFlagProvider call(String key) =>
      HostReleaseFlagProvider._(argument: key, from: this);

  @override
  String toString() => r'hostReleaseFlagProvider';
}
