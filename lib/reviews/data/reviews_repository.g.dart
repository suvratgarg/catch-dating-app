// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviewsRepository)
final reviewsRepositoryProvider = ReviewsRepositoryProvider._();

final class ReviewsRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewsRepository,
          ReviewsRepository,
          ReviewsRepository
        >
    with $Provider<ReviewsRepository> {
  ReviewsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewsRepository create(Ref ref) {
    return reviewsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewsRepository>(value),
    );
  }
}

String _$reviewsRepositoryHash() => r'93a61efc28bcb8b4a4d88a1d1676dcf4c687d81c';

@ProviderFor(watchReviewsForClub)
final watchReviewsForClubProvider = WatchReviewsForClubFamily._();

final class WatchReviewsForClubProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Review>>,
          List<Review>,
          Stream<List<Review>>
        >
    with $FutureModifier<List<Review>>, $StreamProvider<List<Review>> {
  WatchReviewsForClubProvider._({
    required WatchReviewsForClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchReviewsForClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchReviewsForClubHash();

  @override
  String toString() {
    return r'watchReviewsForClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Review>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Review>> create(Ref ref) {
    final argument = this.argument as String;
    return watchReviewsForClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchReviewsForClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchReviewsForClubHash() =>
    r'29850161fb5c05475642d7cfea057ff679cc4ac2';

final class WatchReviewsForClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Review>>, String> {
  WatchReviewsForClubFamily._()
    : super(
        retry: null,
        name: r'watchReviewsForClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchReviewsForClubProvider call(String runClubId) =>
      WatchReviewsForClubProvider._(argument: runClubId, from: this);

  @override
  String toString() => r'watchReviewsForClubProvider';
}

@ProviderFor(watchReviewsForRun)
final watchReviewsForRunProvider = WatchReviewsForRunFamily._();

final class WatchReviewsForRunProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Review>>,
          List<Review>,
          Stream<List<Review>>
        >
    with $FutureModifier<List<Review>>, $StreamProvider<List<Review>> {
  WatchReviewsForRunProvider._({
    required WatchReviewsForRunFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchReviewsForRunProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchReviewsForRunHash();

  @override
  String toString() {
    return r'watchReviewsForRunProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Review>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Review>> create(Ref ref) {
    final argument = this.argument as String;
    return watchReviewsForRun(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchReviewsForRunProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchReviewsForRunHash() =>
    r'85ef13ecada797c39b9bcf24f915925e3d4dacbe';

final class WatchReviewsForRunFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Review>>, String> {
  WatchReviewsForRunFamily._()
    : super(
        retry: null,
        name: r'watchReviewsForRunProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchReviewsForRunProvider call(String runId) =>
      WatchReviewsForRunProvider._(argument: runId, from: this);

  @override
  String toString() => r'watchReviewsForRunProvider';
}

@ProviderFor(watchReviewsByUser)
final watchReviewsByUserProvider = WatchReviewsByUserFamily._();

final class WatchReviewsByUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Review>>,
          List<Review>,
          Stream<List<Review>>
        >
    with $FutureModifier<List<Review>>, $StreamProvider<List<Review>> {
  WatchReviewsByUserProvider._({
    required WatchReviewsByUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchReviewsByUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchReviewsByUserHash();

  @override
  String toString() {
    return r'watchReviewsByUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Review>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Review>> create(Ref ref) {
    final argument = this.argument as String;
    return watchReviewsByUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchReviewsByUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchReviewsByUserHash() =>
    r'825043f2c5c6f2b83717e2a2e2b5e25ee78696b2';

final class WatchReviewsByUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Review>>, String> {
  WatchReviewsByUserFamily._()
    : super(
        retry: null,
        name: r'watchReviewsByUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchReviewsByUserProvider call(String reviewerUserId) =>
      WatchReviewsByUserProvider._(argument: reviewerUserId, from: this);

  @override
  String toString() => r'watchReviewsByUserProvider';
}

@ProviderFor(watchUserReviewForRun)
final watchUserReviewForRunProvider = WatchUserReviewForRunFamily._();

final class WatchUserReviewForRunProvider
    extends $FunctionalProvider<AsyncValue<Review?>, Review?, Stream<Review?>>
    with $FutureModifier<Review?>, $StreamProvider<Review?> {
  WatchUserReviewForRunProvider._({
    required WatchUserReviewForRunFamily super.from,
    required ({String runId, String reviewerUserId}) super.argument,
  }) : super(
         retry: null,
         name: r'watchUserReviewForRunProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchUserReviewForRunHash();

  @override
  String toString() {
    return r'watchUserReviewForRunProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Review?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Review?> create(Ref ref) {
    final argument = this.argument as ({String runId, String reviewerUserId});
    return watchUserReviewForRun(
      ref,
      runId: argument.runId,
      reviewerUserId: argument.reviewerUserId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WatchUserReviewForRunProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchUserReviewForRunHash() =>
    r'61922815ae5c3a544351d6590b58cb8811b74156';

final class WatchUserReviewForRunFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Review?>,
          ({String runId, String reviewerUserId})
        > {
  WatchUserReviewForRunFamily._()
    : super(
        retry: null,
        name: r'watchUserReviewForRunProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchUserReviewForRunProvider call({
    required String runId,
    required String reviewerUserId,
  }) => WatchUserReviewForRunProvider._(
    argument: (runId: runId, reviewerUserId: reviewerUserId),
    from: this,
  );

  @override
  String toString() => r'watchUserReviewForRunProvider';
}
