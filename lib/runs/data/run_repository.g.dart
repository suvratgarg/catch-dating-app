// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runRepository)
final runRepositoryProvider = RunRepositoryProvider._();

final class RunRepositoryProvider
    extends $FunctionalProvider<RunRepository, RunRepository, RunRepository>
    with $Provider<RunRepository> {
  RunRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RunRepository create(Ref ref) {
    return runRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunRepository>(value),
    );
  }
}

String _$runRepositoryHash() => r'1ca5816b6dbed4851ef8ab59b32dfb23f001d4be';

@ProviderFor(watchRun)
final watchRunProvider = WatchRunFamily._();

final class WatchRunProvider
    extends $FunctionalProvider<AsyncValue<Run?>, Run?, Stream<Run?>>
    with $FutureModifier<Run?>, $StreamProvider<Run?> {
  WatchRunProvider._({
    required WatchRunFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunHash();

  @override
  String toString() {
    return r'watchRunProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Run?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Run?> create(Ref ref) {
    final argument = this.argument as String;
    return watchRun(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunHash() => r'871b4572751818a738699f84ce8505831411961d';

final class WatchRunFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Run?>, String> {
  WatchRunFamily._()
    : super(
        retry: null,
        name: r'watchRunProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunProvider call(String runId) =>
      WatchRunProvider._(argument: runId, from: this);

  @override
  String toString() => r'watchRunProvider';
}

@ProviderFor(watchRunsForClub)
final watchRunsForClubProvider = WatchRunsForClubFamily._();

final class WatchRunsForClubProvider
    extends
        $FunctionalProvider<AsyncValue<List<Run>>, List<Run>, Stream<List<Run>>>
    with $FutureModifier<List<Run>>, $StreamProvider<List<Run>> {
  WatchRunsForClubProvider._({
    required WatchRunsForClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunsForClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunsForClubHash();

  @override
  String toString() {
    return r'watchRunsForClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Run>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Run>> create(Ref ref) {
    final argument = this.argument as String;
    return watchRunsForClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunsForClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunsForClubHash() => r'94ae2425b0c76ca84607ebf1b7decfecf122565f';

final class WatchRunsForClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Run>>, String> {
  WatchRunsForClubFamily._()
    : super(
        retry: null,
        name: r'watchRunsForClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunsForClubProvider call(String runClubId) =>
      WatchRunsForClubProvider._(argument: runClubId, from: this);

  @override
  String toString() => r'watchRunsForClubProvider';
}

@ProviderFor(watchAttendedRuns)
final watchAttendedRunsProvider = WatchAttendedRunsFamily._();

final class WatchAttendedRunsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Run>>, List<Run>, Stream<List<Run>>>
    with $FutureModifier<List<Run>>, $StreamProvider<List<Run>> {
  WatchAttendedRunsProvider._({
    required WatchAttendedRunsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchAttendedRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchAttendedRunsHash();

  @override
  String toString() {
    return r'watchAttendedRunsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Run>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Run>> create(Ref ref) {
    final argument = this.argument as String;
    return watchAttendedRuns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchAttendedRunsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchAttendedRunsHash() => r'47e47603ad911756b60455a9524cb4718b987b3e';

final class WatchAttendedRunsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Run>>, String> {
  WatchAttendedRunsFamily._()
    : super(
        retry: null,
        name: r'watchAttendedRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchAttendedRunsProvider call(String uid) =>
      WatchAttendedRunsProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchAttendedRunsProvider';
}

@ProviderFor(watchSignedUpRuns)
final watchSignedUpRunsProvider = WatchSignedUpRunsFamily._();

final class WatchSignedUpRunsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Run>>, List<Run>, Stream<List<Run>>>
    with $FutureModifier<List<Run>>, $StreamProvider<List<Run>> {
  WatchSignedUpRunsProvider._({
    required WatchSignedUpRunsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchSignedUpRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchSignedUpRunsHash();

  @override
  String toString() {
    return r'watchSignedUpRunsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Run>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Run>> create(Ref ref) {
    final argument = this.argument as String;
    return watchSignedUpRuns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchSignedUpRunsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchSignedUpRunsHash() => r'b7ebee6fc666497bfeec4b87d76da54296b2807f';

final class WatchSignedUpRunsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Run>>, String> {
  WatchSignedUpRunsFamily._()
    : super(
        retry: null,
        name: r'watchSignedUpRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchSignedUpRunsProvider call(String uid) =>
      WatchSignedUpRunsProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchSignedUpRunsProvider';
}

/// Returns upcoming runs from clubs the user follows (based on [followedClubIds]).

@ProviderFor(recommendedRuns)
final recommendedRunsProvider = RecommendedRunsFamily._();

/// Returns upcoming runs from clubs the user follows (based on [followedClubIds]).

final class RecommendedRunsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Run>>,
          List<Run>,
          FutureOr<List<Run>>
        >
    with $FutureModifier<List<Run>>, $FutureProvider<List<Run>> {
  /// Returns upcoming runs from clubs the user follows (based on [followedClubIds]).
  RecommendedRunsProvider._({
    required RecommendedRunsFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'recommendedRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recommendedRunsHash();

  @override
  String toString() {
    return r'recommendedRunsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Run>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Run>> create(Ref ref) {
    final argument = this.argument as List<String>;
    return recommendedRuns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendedRunsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendedRunsHash() => r'db8467b5b5593f56269b23fb605f8a515c936497';

/// Returns upcoming runs from clubs the user follows (based on [followedClubIds]).

final class RecommendedRunsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Run>>, List<String>> {
  RecommendedRunsFamily._()
    : super(
        retry: null,
        name: r'recommendedRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns upcoming runs from clubs the user follows (based on [followedClubIds]).

  RecommendedRunsProvider call(List<String> followedClubIds) =>
      RecommendedRunsProvider._(argument: followedClubIds, from: this);

  @override
  String toString() => r'recommendedRunsProvider';
}
