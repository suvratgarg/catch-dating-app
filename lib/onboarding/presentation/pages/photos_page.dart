import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotosPage extends ConsumerWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrls =
        ref.watch(userProfileStreamProvider).asData?.value?.photoUrls ??
        const [];
    final uploadState = ref.watch(photoUploadControllerProvider);
    final t = CatchTokens.of(context);

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Upload failed. Please try again.')),
          );
      }
    });

    final canContinue =
        photoUrls.length >= 2 && uploadState.loadingIndices.isEmpty;
    final continueHint = _continueHint(
      photoCount: photoUrls.length,
      uploadingCount: uploadState.loadingIndices.length,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const OnboardingStepHeader(
            title: 'Show yourself',
            subtitle: 'Add at least 2 photos so others can find you.',
          ),
          gapH8,
          Row(
            children: [
              Icon(Icons.bolt, size: 16, color: t.accent),
              gapW8,
              Expanded(
                child: Text(
                  'Running photos boost catches by 2.3×',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: t.accent),
                ),
              ),
            ],
          ),
          gapH24,
          PhotoGrid(
            photoUrls: photoUrls,
            loadingIndices: uploadState.loadingIndices,
            onSlotTapped: (index) => ref
                .read(photoUploadControllerProvider.notifier)
                .pickAndUpload(index),
          ),
          gapH24,
          CatchButton(
            label: 'Continue',
            onPressed: canContinue
                ? () => ref
                      .read(onboardingControllerProvider.notifier)
                      .goToStep(OnboardingStep.runningPrefs)
                : null,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          if (continueHint != null) ...[
            gapH12,
            Text(
              continueHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: t.ink2),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String? _continueHint({
    required int photoCount,
    required int uploadingCount,
  }) {
    if (uploadingCount > 0) {
      return 'Finish uploading your photos to continue.';
    }

    final remainingPhotos = 2 - photoCount;
    if (remainingPhotos > 0) {
      final label = remainingPhotos == 1
          ? '1 more photo'
          : '$remainingPhotos more photos';
      return 'Add $label to continue.';
    }

    return null;
  }
}
