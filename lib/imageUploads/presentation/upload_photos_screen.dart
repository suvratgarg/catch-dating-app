import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/imageUploads/presentation/upload_photos_controller.dart';
import 'package:catch_dating_app/imageUploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/imageUploads/presentation/photo_upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadPhotosScreen extends ConsumerWidget {
  const UploadPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrls =
        ref.watch(appUserStreamProvider).asData?.value?.photoUrls ?? const [];
    final uploadState = ref.watch(photoUploadControllerProvider);
    final completeMutation =
        ref.watch(UploadPhotosController.completeMutation);

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    });

    final canContinue = photoUrls.length >= 2 &&
        uploadState.loadingIndices.isEmpty &&
        !completeMutation.isPending;

    return Scaffold(
      appBar: AppBar(title: const Text('Add photos')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Show yourself',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add at least 2 photos so others can see you',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                  ? () => UploadPhotosController.completeMutation.run(
                        ref,
                        (tx) async => tx
                            .get(uploadPhotosControllerProvider.notifier)
                            .complete(),
                      )
                  : null,
              child: completeMutation.isPending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continue'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
