import 'package:catch_dating_app/image_uploads/domain/photo_upload_state.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_edit_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selfProfileScreenStateProvider = Provider<SelfProfileScreenState>((ref) {
  final profileAsync = ref.watch(watchUserProfileProvider);
  final uploadState = ref.watch(photoUploadControllerProvider);
  final uploadMutation = ref.watch(PhotoUploadController.uploadPhotoMutation);
  final saveMutation = ref.watch(ProfileEditController.saveFieldsMutation);

  return SelfProfileScreenState.fromAsync(
    profileAsync: profileAsync,
    uploadState: uploadState,
    uploadMutationPending: uploadMutation.isPending,
    saveMutationPending: saveMutation.isPending,
  );
});

enum SelfProfileRouteStatus { loading, error, unavailable, ready }

enum SelfProfileRetryIntent { reloadProfile }

enum SelfProfileMutationMode {
  idle,
  uploadPending,
  savePending,
  uploadAndSavePending,
}

class SelfProfileScreenState {
  const SelfProfileScreenState({
    required this.status,
    required this.uploadState,
    required this.mutationMode,
    this.error,
    this.user,
    this.previewProfile,
    this.retryIntent,
  });

  factory SelfProfileScreenState.fromAsync({
    required AsyncValue<UserProfile?> profileAsync,
    required PhotoUploadState uploadState,
    required bool uploadMutationPending,
    required bool saveMutationPending,
  }) {
    final mutationMode = selfProfileMutationModeFromFlags(
      uploadPending:
          uploadMutationPending || uploadState.loadingIndices.isNotEmpty,
      savePending: saveMutationPending,
    );

    return switch (profileAsync) {
      AsyncLoading() => SelfProfileScreenState(
        status: SelfProfileRouteStatus.loading,
        uploadState: uploadState,
        mutationMode: mutationMode,
      ),
      AsyncError(:final error) => SelfProfileScreenState(
        status: SelfProfileRouteStatus.error,
        error: error,
        uploadState: uploadState,
        mutationMode: mutationMode,
        retryIntent: SelfProfileRetryIntent.reloadProfile,
      ),
      AsyncData(:final value) =>
        value == null
            ? SelfProfileScreenState(
                status: SelfProfileRouteStatus.unavailable,
                uploadState: uploadState,
                mutationMode: mutationMode,
              )
            : SelfProfileScreenState(
                status: SelfProfileRouteStatus.ready,
                user: value,
                previewProfile: publicProfileFromUserProfile(value),
                uploadState: uploadState,
                mutationMode: mutationMode,
              ),
    };
  }

  final SelfProfileRouteStatus status;
  final Object? error;
  final UserProfile? user;
  final PublicProfile? previewProfile;
  final PhotoUploadState uploadState;
  final SelfProfileMutationMode mutationMode;
  final SelfProfileRetryIntent? retryIntent;

  bool get isReady => status == SelfProfileRouteStatus.ready;
  bool get isMutating => mutationMode != SelfProfileMutationMode.idle;
  bool get isUploadMutating =>
      mutationMode == SelfProfileMutationMode.uploadPending ||
      mutationMode == SelfProfileMutationMode.uploadAndSavePending;
  bool get isSaveMutating =>
      mutationMode == SelfProfileMutationMode.savePending ||
      mutationMode == SelfProfileMutationMode.uploadAndSavePending;
}

SelfProfileMutationMode selfProfileMutationModeFromFlags({
  required bool uploadPending,
  required bool savePending,
}) {
  if (uploadPending && savePending) {
    return SelfProfileMutationMode.uploadAndSavePending;
  }
  if (uploadPending) return SelfProfileMutationMode.uploadPending;
  if (savePending) return SelfProfileMutationMode.savePending;
  return SelfProfileMutationMode.idle;
}
