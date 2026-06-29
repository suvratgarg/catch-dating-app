import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/image_uploads/presentation/profile_photo_editor_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotosPage extends ConsumerWidget {
  const PhotosPage({super.key, this.profileCompletionOnly = false});

  final bool profileCompletionOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilePhotos =
        ref
            .watch(watchUserProfileProvider)
            .asData
            ?.value
            ?.effectiveProfilePhotos ??
        const [];
    final uploadState = ref.watch(photoUploadControllerProvider);
    final t = CatchTokens.of(context);

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        showCatchSnackBar(context, 'Upload failed. Please try again.');
      }
    });

    final canContinue =
        profilePhotos.length >= minimumProfilePhotoCount &&
        uploadState.loadingIndices.isEmpty;
    final continueHint = _continueHint(
      photoCount: profilePhotos.length,
      uploadingCount: uploadState.loadingIndices.length,
    );

    return OnboardingStepLayout(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchButton(
            label: 'Continue',
            onPressed: canContinue
                ? () => ref
                      .read(onboardingControllerProvider.notifier)
                      .goToStepAndSaveDraft(OnboardingStep.prompts)
                : null,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          if (continueHint != null) ...[
            gapH12,
            Text(
              continueHint,
              style: CatchTextStyles.supporting(context, color: t.ink2),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      children: [
        PhotoGrid(
          profilePhotos: profilePhotos,
          loadingIndices: uploadState.loadingIndices,
          onSlotTapped: (index) {
            unawaited(
              openProfilePhotoEditor(
                context: context,
                ref: ref,
                index: index,
                photo: index < profilePhotos.length
                    ? profilePhotos[index]
                    : null,
                canDelete: profilePhotos.length > minimumProfilePhotoCount,
              ),
            );
          },
          onDeletePhoto: (index) {
            unawaited(
              PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
                await tx
                    .get(photoUploadControllerProvider.notifier)
                    .deletePhoto(index);
              }),
            );
          },
          onReorderPhoto: (fromIndex, toIndex) {
            unawaited(
              PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
                await tx
                    .get(photoUploadControllerProvider.notifier)
                    .reorderPhoto(fromIndex: fromIndex, toIndex: toIndex);
              }),
            );
          },
        ),
        gapH16,
        Divider(height: 1, color: t.line),
        gapH12,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CatchIcons.bolt, size: CatchIcon.xs, color: t.accent),
            gapW8,
            Expanded(
              child: Text(
                profileCompletionOnly
                    ? 'This only gates Catches. Event booking stays available.'
                    : 'Running photos boost catches by 2.3x.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _continueHint({
    required int photoCount,
    required int uploadingCount,
  }) {
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
}
