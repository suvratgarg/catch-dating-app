import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotosPage extends ConsumerWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrls =
        ref.watch(appUserStreamProvider).asData?.value?.photoUrls ?? const [];
    final uploadState = ref.watch(photoUploadControllerProvider);
    final t = CatchTokens.of(context);

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    });

    final canContinue =
        photoUrls.length >= 2 && uploadState.loadingIndices.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'Show yourself',
            style: CatchTextStyles.displaySm(context).copyWith(
              fontWeight: FontWeight.bold,
              color: t.ink,
            ),
          ),
          gapH8,
          Text(
            'Add at least 2 photos so others can find you.',
            style: CatchTextStyles.bodyMd(context, color: t.ink2),
          ),
          gapH8,
          Row(
            children: [
              Icon(Icons.bolt, size: 16, color: t.accent),
              gapW8,
              Expanded(
                child: Text(
                  'Running photos boost catches by 2.3×',
                  style: CatchTextStyles.bodySm(context, color: t.accent),
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
          const Spacer(),
          FilledButton(
            onPressed: canContinue
                ? () => ref
                    .read(onboardingControllerProvider.notifier)
                    .goToStep(6)
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('Continue'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
