// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Watches the club, runs, reviews, user profile, and auth streams and
/// combines them into a single [RunClubDetailViewModel]. Each input is
/// individually checked so the combined result is [AsyncError] if any input
/// fails or [AsyncLoading] if any input is still loading.

@ProviderFor(runClubDetailViewModel)
final runClubDetailViewModelProvider = RunClubDetailViewModelFamily._();

/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Watches the club, runs, reviews, user profile, and auth streams and
/// combines them into a single [RunClubDetailViewModel]. Each input is
/// individually checked so the combined result is [AsyncError] if any input
/// fails or [AsyncLoading] if any input is still loading.

final class RunClubDetailViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunClubDetailViewModel?>,
          AsyncValue<RunClubDetailViewModel?>,
          AsyncValue<RunClubDetailViewModel?>
        >
    with $Provider<AsyncValue<RunClubDetailViewModel?>> {
  /// **Pattern D: Pure computed provider combining multiple async streams**
  ///
  /// Watches the club, runs, reviews, user profile, and auth streams and
  /// combines them into a single [RunClubDetailViewModel]. Each input is
  /// individually checked so the combined result is [AsyncError] if any input
  /// fails or [AsyncLoading] if any input is still loading.
  RunClubDetailViewModelProvider._({
    required RunClubDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runClubDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runClubDetailViewModelHash();

  @override
  String toString() {
    return r'runClubDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<RunClubDetailViewModel?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RunClubDetailViewModel?> create(Ref ref) {
    final argument = this.argument as String;
    return runClubDetailViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RunClubDetailViewModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RunClubDetailViewModel?>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RunClubDetailViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runClubDetailViewModelHash() =>
    r'2e39fb7572fc06694f5b1b2d40a3294023552c94';

/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Watches the club, runs, reviews, user profile, and auth streams and
/// combines them into a single [RunClubDetailViewModel]. Each input is
/// individually checked so the combined result is [AsyncError] if any input
/// fails or [AsyncLoading] if any input is still loading.

final class RunClubDetailViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<AsyncValue<RunClubDetailViewModel?>, String> {
  RunClubDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'runClubDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// **Pattern D: Pure computed provider combining multiple async streams**
  ///
  /// Watches the club, runs, reviews, user profile, and auth streams and
  /// combines them into a single [RunClubDetailViewModel]. Each input is
  /// individually checked so the combined result is [AsyncError] if any input
  /// fails or [AsyncLoading] if any input is still loading.

  RunClubDetailViewModelProvider call(String clubId) =>
      RunClubDetailViewModelProvider._(argument: clubId, from: this);

  @override
  String toString() => r'runClubDetailViewModelProvider';
}
