import 'package:catch_dating_app/image_uploads/presentation/photo_grid_keys.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/photo_slot.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:flutter/material.dart';

/// A 3×2 grid of photo slots for displaying and editing a user's profile photos.
///
/// Slots are filled densely: filled slots are tappable to replace, the next
/// empty slot shows a + icon and is tappable to add, remaining empty slots
/// are inactive.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.profilePhotos,
    required this.onSlotTapped,
    this.loadingIndices = const {},
    this.onDeletePhoto,
    this.onReorderPhoto,
    this.canDeletePhotos = true,
  });

  final List<ProfilePhoto> profilePhotos;
  final void Function(int index) onSlotTapped;
  final Set<int> loadingIndices;
  final void Function(int index)? onDeletePhoto;
  final void Function(int fromIndex, int toIndex)? onReorderPhoto;
  final bool canDeletePhotos;

  static const _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    final photos = normalizeProfilePhotos(profilePhotos);
    final photosByPosition = {
      for (final photo in photos) photo.position: photo,
    };
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemCount: maximumProfilePhotoCount,
      itemBuilder: (context, index) {
        final photo = photosByPosition[index];
        final isLoading = loadingIndices.contains(index);
        final isActive = index <= photos.length;
        PhotoSlot slot({bool isReorderTarget = false}) => PhotoSlot(
          key: PhotoGridKeys.slot(index),
          index: index,
          url: photo?.url,
          prompt: photo?.prompt,
          isLoading: isLoading,
          isActive: isActive,
          onTap: () => onSlotTapped(index),
          onDelete: photo != null && canDeletePhotos && onDeletePhoto != null
              ? () => onDeletePhoto!(index)
              : null,
          isReorderTarget: isReorderTarget,
        );
        if (photo == null || isLoading || onReorderPhoto == null) {
          return slot();
        }
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) =>
              details.data != index && details.data < photos.length,
          onAcceptWithDetails: (details) =>
              onReorderPhoto!(details.data, index),
          builder: (context, candidateData, rejectedData) {
            final isTarget = candidateData.isNotEmpty;
            return LongPressDraggable<int>(
              data: index,
              feedback: _PhotoDragFeedback(photo: photo, index: index),
              childWhenDragging: Opacity(opacity: 0.35, child: slot()),
              child: slot(isReorderTarget: isTarget),
            );
          },
        );
      },
    );
  }
}

class _PhotoDragFeedback extends StatelessWidget {
  const _PhotoDragFeedback({required this.photo, required this.index});

  final ProfilePhoto photo;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 112,
        height: 150,
        child: PhotoSlot(
          index: index,
          url: photo.url,
          prompt: photo.prompt,
          isLoading: false,
          isActive: true,
          onTap: () {},
        ),
      ),
    );
  }
}
