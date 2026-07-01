import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_controller.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final publicProfileScreenStateProvider =
    Provider.family<PublicProfileScreenState, PublicProfileScreenStateArgs>((
      ref,
      args,
    ) {
      final profileAsync = ref.watch(watchPublicProfileProvider(args.uid));
      final viewerProfile = ref.watch(watchUserProfileProvider).asData?.value;
      final blockMutation = ref.watch(
        PublicProfileController.blockUserMutation,
      );
      final reportMutation = ref.watch(
        PublicProfileController.reportUserMutation,
      );

      return PublicProfileScreenState.fromAsync(
        uid: args.uid,
        profileAsync: profileAsync,
        initialProfile: args.initialProfile,
        viewerProfile: viewerProfile,
        sharedRunTitle: args.sharedRunTitle,
        blockPending: blockMutation.isPending,
        reportPending: reportMutation.isPending,
      );
    });

class PublicProfileScreenStateArgs {
  const PublicProfileScreenStateArgs({
    required this.uid,
    required this.initialProfile,
    required this.sharedRunTitle,
  });

  final String uid;
  final PublicProfile? initialProfile;
  final String? sharedRunTitle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicProfileScreenStateArgs &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          initialProfile == other.initialProfile &&
          sharedRunTitle == other.sharedRunTitle;

  @override
  int get hashCode => Object.hash(uid, initialProfile, sharedRunTitle);
}

enum PublicProfileRouteStatus { loading, error, unavailable, ready }

enum PublicProfileRetryIntent { reloadProfile }

enum PublicProfileMutationMode {
  idle,
  reportPending,
  blockPending,
  reportAndBlockPending,
}

class PublicProfileScreenState {
  const PublicProfileScreenState({
    required this.uid,
    required this.status,
    required this.mutationMode,
    required this.sharedRunTitle,
    this.profile,
    this.viewerProfile,
    this.error,
    this.retryIntent,
    this.isInitialProfileFallback = false,
  });

  factory PublicProfileScreenState.fromAsync({
    required String uid,
    required AsyncValue<PublicProfile?> profileAsync,
    required PublicProfile? initialProfile,
    required UserProfile? viewerProfile,
    required String? sharedRunTitle,
    required bool blockPending,
    required bool reportPending,
  }) {
    final mutationMode = publicProfileMutationModeFromFlags(
      blockPending: blockPending,
      reportPending: reportPending,
    );

    return switch (profileAsync) {
      AsyncLoading() =>
        initialProfile == null
            ? PublicProfileScreenState(
                uid: uid,
                status: PublicProfileRouteStatus.loading,
                mutationMode: mutationMode,
                viewerProfile: viewerProfile,
                sharedRunTitle: sharedRunTitle,
              )
            : PublicProfileScreenState(
                uid: uid,
                status: PublicProfileRouteStatus.ready,
                profile: initialProfile,
                viewerProfile: viewerProfile,
                mutationMode: mutationMode,
                sharedRunTitle: sharedRunTitle,
                isInitialProfileFallback: true,
              ),
      AsyncError(:final error) => PublicProfileScreenState(
        uid: uid,
        status: PublicProfileRouteStatus.error,
        error: error,
        mutationMode: mutationMode,
        viewerProfile: viewerProfile,
        sharedRunTitle: sharedRunTitle,
        retryIntent: PublicProfileRetryIntent.reloadProfile,
      ),
      AsyncData(:final value) =>
        value == null
            ? PublicProfileScreenState(
                uid: uid,
                status: PublicProfileRouteStatus.unavailable,
                mutationMode: mutationMode,
                viewerProfile: viewerProfile,
                sharedRunTitle: sharedRunTitle,
              )
            : PublicProfileScreenState(
                uid: uid,
                status: PublicProfileRouteStatus.ready,
                profile: value,
                viewerProfile: viewerProfile,
                mutationMode: mutationMode,
                sharedRunTitle: sharedRunTitle,
              ),
    };
  }

  final String uid;
  final PublicProfileRouteStatus status;
  final PublicProfile? profile;
  final UserProfile? viewerProfile;
  final Object? error;
  final PublicProfileRetryIntent? retryIntent;
  final PublicProfileMutationMode mutationMode;
  final String? sharedRunTitle;
  final bool isInitialProfileFallback;

  String get title => profile?.name ?? 'Profile';
  bool get isSubmitting => mutationMode != PublicProfileMutationMode.idle;
  bool get showSafetyActions => profile != null;
  bool get enableSafetyActions => showSafetyActions && !isSubmitting;

  UserProfile? get viewerProfileForSurface {
    final target = profile;
    final viewer = viewerProfile;
    if (target == null || viewer == null || viewer.uid == target.uid) {
      return null;
    }
    return viewer;
  }
}

PublicProfileMutationMode publicProfileMutationModeFromFlags({
  required bool blockPending,
  required bool reportPending,
}) {
  if (blockPending && reportPending) {
    return PublicProfileMutationMode.reportAndBlockPending;
  }
  if (blockPending) return PublicProfileMutationMode.blockPending;
  if (reportPending) return PublicProfileMutationMode.reportPending;
  return PublicProfileMutationMode.idle;
}
