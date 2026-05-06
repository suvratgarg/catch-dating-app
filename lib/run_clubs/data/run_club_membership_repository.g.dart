// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_membership_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runClubMembershipRepository)
final runClubMembershipRepositoryProvider =
    RunClubMembershipRepositoryProvider._();

final class RunClubMembershipRepositoryProvider
    extends
        $FunctionalProvider<
          RunClubMembershipRepository,
          RunClubMembershipRepository,
          RunClubMembershipRepository
        >
    with $Provider<RunClubMembershipRepository> {
  RunClubMembershipRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubMembershipRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubMembershipRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunClubMembershipRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RunClubMembershipRepository create(Ref ref) {
    return runClubMembershipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunClubMembershipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunClubMembershipRepository>(value),
    );
  }
}

String _$runClubMembershipRepositoryHash() =>
    r'511ab340fa1acccda873d70b60c8bd3c6916ce36';

@ProviderFor(watchActiveRunClubMembershipsForUser)
final watchActiveRunClubMembershipsForUserProvider =
    WatchActiveRunClubMembershipsForUserFamily._();

final class WatchActiveRunClubMembershipsForUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunClubMembership>>,
          List<RunClubMembership>,
          Stream<List<RunClubMembership>>
        >
    with
        $FutureModifier<List<RunClubMembership>>,
        $StreamProvider<List<RunClubMembership>> {
  WatchActiveRunClubMembershipsForUserProvider._({
    required WatchActiveRunClubMembershipsForUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchActiveRunClubMembershipsForUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$watchActiveRunClubMembershipsForUserHash();

  @override
  String toString() {
    return r'watchActiveRunClubMembershipsForUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RunClubMembership>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunClubMembership>> create(Ref ref) {
    final argument = this.argument as String;
    return watchActiveRunClubMembershipsForUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchActiveRunClubMembershipsForUserProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchActiveRunClubMembershipsForUserHash() =>
    r'1e55a602ea4204654016da3b0aff69095ab67e3f';

final class WatchActiveRunClubMembershipsForUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunClubMembership>>, String> {
  WatchActiveRunClubMembershipsForUserFamily._()
    : super(
        retry: null,
        name: r'watchActiveRunClubMembershipsForUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchActiveRunClubMembershipsForUserProvider call(String uid) =>
      WatchActiveRunClubMembershipsForUserProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchActiveRunClubMembershipsForUserProvider';
}

@ProviderFor(watchActiveRunClubMembershipsForClub)
final watchActiveRunClubMembershipsForClubProvider =
    WatchActiveRunClubMembershipsForClubFamily._();

final class WatchActiveRunClubMembershipsForClubProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunClubMembership>>,
          List<RunClubMembership>,
          Stream<List<RunClubMembership>>
        >
    with
        $FutureModifier<List<RunClubMembership>>,
        $StreamProvider<List<RunClubMembership>> {
  WatchActiveRunClubMembershipsForClubProvider._({
    required WatchActiveRunClubMembershipsForClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchActiveRunClubMembershipsForClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$watchActiveRunClubMembershipsForClubHash();

  @override
  String toString() {
    return r'watchActiveRunClubMembershipsForClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RunClubMembership>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunClubMembership>> create(Ref ref) {
    final argument = this.argument as String;
    return watchActiveRunClubMembershipsForClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchActiveRunClubMembershipsForClubProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchActiveRunClubMembershipsForClubHash() =>
    r'341ebddc4522dd7e45153d50dad9c575c4d1d536';

final class WatchActiveRunClubMembershipsForClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunClubMembership>>, String> {
  WatchActiveRunClubMembershipsForClubFamily._()
    : super(
        retry: null,
        name: r'watchActiveRunClubMembershipsForClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchActiveRunClubMembershipsForClubProvider call(String clubId) =>
      WatchActiveRunClubMembershipsForClubProvider._(
        argument: clubId,
        from: this,
      );

  @override
  String toString() => r'watchActiveRunClubMembershipsForClubProvider';
}

@ProviderFor(watchRunClubMembership)
final watchRunClubMembershipProvider = WatchRunClubMembershipFamily._();

final class WatchRunClubMembershipProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunClubMembership?>,
          RunClubMembership?,
          Stream<RunClubMembership?>
        >
    with
        $FutureModifier<RunClubMembership?>,
        $StreamProvider<RunClubMembership?> {
  WatchRunClubMembershipProvider._({
    required WatchRunClubMembershipFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'watchRunClubMembershipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunClubMembershipHash();

  @override
  String toString() {
    return r'watchRunClubMembershipProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<RunClubMembership?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RunClubMembership?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return watchRunClubMembership(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunClubMembershipProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunClubMembershipHash() =>
    r'c57715223fabcdaf7e7585af9bddf1960abda987';

final class WatchRunClubMembershipFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<RunClubMembership?>,
          (String, String)
        > {
  WatchRunClubMembershipFamily._()
    : super(
        retry: null,
        name: r'watchRunClubMembershipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunClubMembershipProvider call(String clubId, String uid) =>
      WatchRunClubMembershipProvider._(argument: (clubId, uid), from: this);

  @override
  String toString() => r'watchRunClubMembershipProvider';
}
