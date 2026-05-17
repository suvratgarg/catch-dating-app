// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_membership_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Owns membership actions from both the club list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.

@ProviderFor(ClubMembershipController)
final clubMembershipControllerProvider = ClubMembershipControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Owns membership actions from both the club list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.
final class ClubMembershipControllerProvider
    extends $NotifierProvider<ClubMembershipController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Owns membership actions from both the club list and detail screens.
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
    r'a7242ce2d0e188043a4c1e0a6a4265c2196b1799';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns membership actions from both the club list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.

abstract class _$ClubMembershipController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
