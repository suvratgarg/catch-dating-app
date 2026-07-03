import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:flutter/material.dart';

class OnboardingPhotosState {
  OnboardingPhotosState({
    required List<ProfilePhoto> profilePhotos,
    required Set<int> loadingIndices,
    required this.profileCompletionOnly,
  }) : profilePhotos = List<ProfilePhoto>.unmodifiable(profilePhotos),
       loadingIndices = Set<int>.unmodifiable(loadingIndices);

  factory OnboardingPhotosState.from({
    required List<ProfilePhoto> profilePhotos,
    required Set<int> loadingIndices,
    required bool profileCompletionOnly,
  }) {
    return OnboardingPhotosState(
      profilePhotos: profilePhotos,
      loadingIndices: loadingIndices,
      profileCompletionOnly: profileCompletionOnly,
    );
  }

  final List<ProfilePhoto> profilePhotos;
  final Set<int> loadingIndices;
  final bool profileCompletionOnly;

  int get photoCount => profilePhotos.length;

  int get uploadingCount => loadingIndices.length;

  bool get canContinue =>
      photoCount >= minimumProfilePhotoCount && loadingIndices.isEmpty;

  bool get canDeletePhotos => photoCount > minimumProfilePhotoCount;

  String? get continueHint {
    if (uploadingCount > 0) {
      return 'Finish uploading your photos to continue.';
    }

    final remainingPhotos = minimumProfilePhotoCount - photoCount;
    if (remainingPhotos > 0) {
      final label = remainingPhotos == 1
          ? '1 more photo'
          : '$remainingPhotos more photos';
      return 'Add $label to continue.';
    }

    return null;
  }

  OnboardingPhotoSlotIntent slotIntent(int index) {
    return OnboardingPhotoSlotIntent(
      index: index,
      photo: index < profilePhotos.length ? profilePhotos[index] : null,
      canDelete: canDeletePhotos,
    );
  }

  String get supportingCopy => profileCompletionOnly
      ? 'This only gates Catches. Event booking stays available.'
      : 'Running photos boost catches by 2.3x.';
}

class OnboardingPhotoSlotIntent {
  const OnboardingPhotoSlotIntent({
    required this.index,
    required this.photo,
    required this.canDelete,
  });

  final int index;
  final ProfilePhoto? photo;
  final bool canDelete;
}

class OnboardingPhotosCallbacks {
  const OnboardingPhotosCallbacks({
    required this.onContinue,
    required this.onSlotTapped,
    required this.onDeletePhoto,
    required this.onReorderPhoto,
  });

  final VoidCallback? onContinue;
  final void Function(OnboardingPhotoSlotIntent intent) onSlotTapped;
  final void Function(int index) onDeletePhoto;
  final void Function(int fromIndex, int toIndex) onReorderPhoto;
}
