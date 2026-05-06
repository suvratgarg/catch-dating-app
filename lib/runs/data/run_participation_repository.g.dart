// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_participation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runParticipationRepository)
final runParticipationRepositoryProvider =
    RunParticipationRepositoryProvider._();

final class RunParticipationRepositoryProvider
    extends
        $FunctionalProvider<
          RunParticipationRepository,
          RunParticipationRepository,
          RunParticipationRepository
        >
    with $Provider<RunParticipationRepository> {
  RunParticipationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runParticipationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runParticipationRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunParticipationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RunParticipationRepository create(Ref ref) {
    return runParticipationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunParticipationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunParticipationRepository>(value),
    );
  }
}

String _$runParticipationRepositoryHash() =>
    r'b8589d8c6205dbf5c0599c4f5aeaaa6dc6a5ae21';

@ProviderFor(watchRunParticipationsForUser)
final watchRunParticipationsForUserProvider =
    WatchRunParticipationsForUserFamily._();

final class WatchRunParticipationsForUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunParticipation>>,
          List<RunParticipation>,
          Stream<List<RunParticipation>>
        >
    with
        $FutureModifier<List<RunParticipation>>,
        $StreamProvider<List<RunParticipation>> {
  WatchRunParticipationsForUserProvider._({
    required WatchRunParticipationsForUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunParticipationsForUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunParticipationsForUserHash();

  @override
  String toString() {
    return r'watchRunParticipationsForUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RunParticipation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunParticipation>> create(Ref ref) {
    final argument = this.argument as String;
    return watchRunParticipationsForUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunParticipationsForUserProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunParticipationsForUserHash() =>
    r'5f1c354d3f9ade39b388d87473898e241a91f806';

final class WatchRunParticipationsForUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunParticipation>>, String> {
  WatchRunParticipationsForUserFamily._()
    : super(
        retry: null,
        name: r'watchRunParticipationsForUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunParticipationsForUserProvider call(String uid) =>
      WatchRunParticipationsForUserProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchRunParticipationsForUserProvider';
}

@ProviderFor(watchRunParticipationsForRun)
final watchRunParticipationsForRunProvider =
    WatchRunParticipationsForRunFamily._();

final class WatchRunParticipationsForRunProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunParticipation>>,
          List<RunParticipation>,
          Stream<List<RunParticipation>>
        >
    with
        $FutureModifier<List<RunParticipation>>,
        $StreamProvider<List<RunParticipation>> {
  WatchRunParticipationsForRunProvider._({
    required WatchRunParticipationsForRunFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunParticipationsForRunProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunParticipationsForRunHash();

  @override
  String toString() {
    return r'watchRunParticipationsForRunProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RunParticipation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunParticipation>> create(Ref ref) {
    final argument = this.argument as String;
    return watchRunParticipationsForRun(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunParticipationsForRunProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunParticipationsForRunHash() =>
    r'ed980f75018e1d420f2ffce58a091e746304ba31';

final class WatchRunParticipationsForRunFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunParticipation>>, String> {
  WatchRunParticipationsForRunFamily._()
    : super(
        retry: null,
        name: r'watchRunParticipationsForRunProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunParticipationsForRunProvider call(String runId) =>
      WatchRunParticipationsForRunProvider._(argument: runId, from: this);

  @override
  String toString() => r'watchRunParticipationsForRunProvider';
}

@ProviderFor(watchRunParticipationRoster)
final watchRunParticipationRosterProvider =
    WatchRunParticipationRosterFamily._();

final class WatchRunParticipationRosterProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunParticipationRoster>,
          RunParticipationRoster,
          Stream<RunParticipationRoster>
        >
    with
        $FutureModifier<RunParticipationRoster>,
        $StreamProvider<RunParticipationRoster> {
  WatchRunParticipationRosterProvider._({
    required WatchRunParticipationRosterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunParticipationRosterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunParticipationRosterHash();

  @override
  String toString() {
    return r'watchRunParticipationRosterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RunParticipationRoster> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RunParticipationRoster> create(Ref ref) {
    final argument = this.argument as String;
    return watchRunParticipationRoster(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunParticipationRosterProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunParticipationRosterHash() =>
    r'7e3c45bd7a2a7a6f86aec9504261099a90320fc3';

final class WatchRunParticipationRosterFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RunParticipationRoster>, String> {
  WatchRunParticipationRosterFamily._()
    : super(
        retry: null,
        name: r'watchRunParticipationRosterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunParticipationRosterProvider call(String runId) =>
      WatchRunParticipationRosterProvider._(argument: runId, from: this);

  @override
  String toString() => r'watchRunParticipationRosterProvider';
}

@ProviderFor(watchRunParticipation)
final watchRunParticipationProvider = WatchRunParticipationFamily._();

final class WatchRunParticipationProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunParticipation?>,
          RunParticipation?,
          Stream<RunParticipation?>
        >
    with
        $FutureModifier<RunParticipation?>,
        $StreamProvider<RunParticipation?> {
  WatchRunParticipationProvider._({
    required WatchRunParticipationFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'watchRunParticipationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunParticipationHash();

  @override
  String toString() {
    return r'watchRunParticipationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<RunParticipation?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RunParticipation?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return watchRunParticipation(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunParticipationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunParticipationHash() =>
    r'05da3a7759647d534928d6d9e962fe04aea7e45d';

final class WatchRunParticipationFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<RunParticipation?>, (String, String)> {
  WatchRunParticipationFamily._()
    : super(
        retry: null,
        name: r'watchRunParticipationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunParticipationProvider call(String runId, String uid) =>
      WatchRunParticipationProvider._(argument: (runId, uid), from: this);

  @override
  String toString() => r'watchRunParticipationProvider';
}
