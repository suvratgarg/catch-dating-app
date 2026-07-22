// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_membership_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Owns follow actions from both the organizer list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.

@ProviderFor(ClubMembershipController)
final clubMembershipControllerProvider = ClubMembershipControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Owns follow actions from both the organizer list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.
final class ClubMembershipControllerProvider
    extends $NotifierProvider<ClubMembershipController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Owns follow actions from both the organizer list and detail screens.
  /// The UI watches mutation state to show loading spinners and error banners.
  ClubMembershipControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubMembershipControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubMembershipControllerHash();

  @$internal
  @override
  ClubMembershipController create() => ClubMembershipController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$clubMembershipControllerHash() =>
    r'aa0bc92ce05b21f4ff46513cd60f0528b8987390';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns follow actions from both the organizer list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.

abstract class _$ClubMembershipController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
