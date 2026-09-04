// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_events_timeline_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostEventsTimelineController)
final hostEventsTimelineControllerProvider =
    HostEventsTimelineControllerFamily._();

final class HostEventsTimelineControllerProvider
    extends
        $AsyncNotifierProvider<
          HostEventsTimelineController,
          HostEventsTimelineData
        > {
  HostEventsTimelineControllerProvider._({
    required HostEventsTimelineControllerFamily super.from,
    required HostEventsTimelineRequest super.argument,
  }) : super(
         retry: null,
         name: r'hostEventsTimelineControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostEventsTimelineControllerHash();

  @override
  String toString() {
    return r'hostEventsTimelineControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostEventsTimelineController create() => HostEventsTimelineController();

  @override
  bool operator ==(Object other) {
    return other is HostEventsTimelineControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostEventsTimelineControllerHash() =>
    r'e609960fba73e3851a6436484f90d6be0b375bb4';

final class HostEventsTimelineControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostEventsTimelineController,
          AsyncValue<HostEventsTimelineData>,
          HostEventsTimelineData,
          FutureOr<HostEventsTimelineData>,
          HostEventsTimelineRequest
        > {
  HostEventsTimelineControllerFamily._()
    : super(
        retry: null,
        name: r'hostEventsTimelineControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostEventsTimelineControllerProvider call(
    HostEventsTimelineRequest request,
  ) => HostEventsTimelineControllerProvider._(argument: request, from: this);

  @override
  String toString() => r'hostEventsTimelineControllerProvider';
}

abstract class _$HostEventsTimelineController
    extends $AsyncNotifier<HostEventsTimelineData> {
  late final _$args = ref.$arg as HostEventsTimelineRequest;
  HostEventsTimelineRequest get request => _$args;

  FutureOr<HostEventsTimelineData> build(HostEventsTimelineRequest request);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<HostEventsTimelineData>, HostEventsTimelineData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostEventsTimelineData>,
                HostEventsTimelineData
              >,
              AsyncValue<HostEventsTimelineData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
