// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_today_roadmap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostTodayRoadmap)
final hostTodayRoadmapProvider = HostTodayRoadmapFamily._();

final class HostTodayRoadmapProvider
    extends
        $FunctionalProvider<
          HostTodayRoadmapEvidence,
          HostTodayRoadmapEvidence,
          HostTodayRoadmapEvidence
        >
    with $Provider<HostTodayRoadmapEvidence> {
  HostTodayRoadmapProvider._({
    required HostTodayRoadmapFamily super.from,
    required HostTodayPreferenceScope super.argument,
  }) : super(
         retry: null,
         name: r'hostTodayRoadmapProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostTodayRoadmapHash();

  @override
  String toString() {
    return r'hostTodayRoadmapProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<HostTodayRoadmapEvidence> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostTodayRoadmapEvidence create(Ref ref) {
    final argument = this.argument as HostTodayPreferenceScope;
    return hostTodayRoadmap(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostTodayRoadmapEvidence value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostTodayRoadmapEvidence>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HostTodayRoadmapProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostTodayRoadmapHash() => r'6cfce3d0932965afd31577f239d48a5e03208016';

final class HostTodayRoadmapFamily extends $Family
    with
        $FunctionalFamilyOverride<
          HostTodayRoadmapEvidence,
          HostTodayPreferenceScope
        > {
  HostTodayRoadmapFamily._()
    : super(
        retry: null,
        name: r'hostTodayRoadmapProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostTodayRoadmapProvider call(HostTodayPreferenceScope scope) =>
      HostTodayRoadmapProvider._(argument: scope, from: this);

  @override
  String toString() => r'hostTodayRoadmapProvider';
}
