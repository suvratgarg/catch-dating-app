// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern D: View-model provider**
///
/// Watches the club, events, reviews, user profile, and auth streams and
/// combines them into a single [ClubDetailViewModel].
///
/// Club, events, and auth identity are blocking because they control the main
/// route and schedule. Reviews, profile, and membership state are secondary;
/// they hydrate the detail screen when available without hiding newly-created
/// events behind the route's placeholder body.

@ProviderFor(clubDetailViewModel)
final clubDetailViewModelProvider = ClubDetailViewModelFamily._();

/// **Pattern D: View-model provider**
///
/// Watches the club, events, reviews, user profile, and auth streams and
/// combines them into a single [ClubDetailViewModel].
///
/// Club, events, and auth identity are blocking because they control the main
/// route and schedule. Reviews, profile, and membership state are secondary;
/// they hydrate the detail screen when available without hiding newly-created
/// events behind the route's placeholder body.

final class ClubDetailViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClubDetailViewModel?>,
          AsyncValue<ClubDetailViewModel?>,
          AsyncValue<ClubDetailViewModel?>
        >
    with $Provider<AsyncValue<ClubDetailViewModel?>> {
  /// **Pattern D: View-model provider**
  ///
  /// Watches the club, events, reviews, user profile, and auth streams and
  /// combines them into a single [ClubDetailViewModel].
  ///
  /// Club, events, and auth identity are blocking because they control the main
  /// route and schedule. Reviews, profile, and membership state are secondary;
  /// they hydrate the detail screen when available without hiding newly-created
  /// events behind the route's placeholder body.
  ClubDetailViewModelProvider._({
    required ClubDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubDetailViewModelHash();

  @override
  String toString() {
    return r'clubDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<ClubDetailViewModel?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<ClubDetailViewModel?> create(Ref ref) {
    final argument = this.argument as String;
    return clubDetailViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ClubDetailViewModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ClubDetailViewModel?>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ClubDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubDetailViewModelHash() =>
    r'1279325e6ca3680ae5861c610aa872eb9facdd83';

/// **Pattern D: View-model provider**
///
/// Watches the club, events, reviews, user profile, and auth streams and
/// combines them into a single [ClubDetailViewModel].
///
/// Club, events, and auth identity are blocking because they control the main
/// route and schedule. Reviews, profile, and membership state are secondary;
/// they hydrate the detail screen when available without hiding newly-created
/// events behind the route's placeholder body.

final class ClubDetailViewModelFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<ClubDetailViewModel?>, String> {
  ClubDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'clubDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// **Pattern D: View-model provider**
  ///
  /// Watches the club, events, reviews, user profile, and auth streams and
  /// combines them into a single [ClubDetailViewModel].
  ///
  /// Club, events, and auth identity are blocking because they control the main
  /// route and schedule. Reviews, profile, and membership state are secondary;
  /// they hydrate the detail screen when available without hiding newly-created
  /// events behind the route's placeholder body.

  ClubDetailViewModelProvider call(String clubId) =>
      ClubDetailViewModelProvider._(argument: clubId, from: this);

  @override
  String toString() => r'clubDetailViewModelProvider';
}
