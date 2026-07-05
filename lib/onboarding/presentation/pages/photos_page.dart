import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/image_uploads/shared/profile_photo_editor_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page_state.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
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
    final state = OnboardingPhotosState.from(
      profilePhotos: profilePhotos,
      loadingIndices: uploadState.loadingIndices,
      profileCompletionOnly: profileCompletionOnly,
    );

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        showCatchSnackBar(context, 'Upload failed. Please try again.');
      }
    });

    return OnboardingPhotosStep(
      state: state,
      callbacks: OnboardingPhotosCallbacks(
        onContinue: state.canContinue
            ? () => ref
                  .read(onboardingControllerProvider.notifier)
                  .goToStepAndSaveDraft(OnboardingStep.prompts)
            : null,
        onSlotTapped: (intent) {
          unawaited(
            openProfilePhotoEditor(
              context: context,
              ref: ref,
              index: intent.index,
              photo: intent.photo,
              canDelete: intent.canDelete,
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
    );
  }
}

class OnboardingPhotosStep extends StatelessWidget {
  const OnboardingPhotosStep({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final OnboardingPhotosState state;
  final OnboardingPhotosCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return OnboardingStepLayout(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchButton(
            label: 'Continue',
            onPressed: callbacks.onContinue,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          if (state.continueHint case final continueHint?) ...[
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
          profilePhotos: state.profilePhotos,
          loadingIndices: state.loadingIndices,
          canDeletePhotos: state.canDeletePhotos,
          onSlotTapped: (index) =>
              callbacks.onSlotTapped(state.slotIntent(index)),
          onDeletePhoto: callbacks.onDeletePhoto,
          onReorderPhoto: callbacks.onReorderPhoto,
        ),
        gapH16,
        const CatchDivider.section(),
        gapH12,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CatchIcons.bolt, size: CatchIcon.xs, color: t.accent),
            gapW8,
            Expanded(
              child: Text(
                state.supportingCopy,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
