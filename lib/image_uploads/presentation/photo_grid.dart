import 'package:catch_dating_app/image_uploads/presentation/widgets/photo_slot.dart';
import 'package:flutter/material.dart';

/// A 3×2 grid of photo slots for displaying and editing a user's profile photos.
///
/// Slots are filled densely: filled slots are tappable to replace, the next
/// empty slot shows a + icon and is tappable to add, remaining empty slots
/// are inactive.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photoUrls,
    required this.onSlotTapped,
    this.loadingIndices = const {},
  });

  final List<String> photoUrls;
  final void Function(int index) onSlotTapped;
  final Set<int> loadingIndices;

  static const _slotCount = 6;
  static const _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemCount: _slotCount,
      itemBuilder: (context, index) => PhotoSlot(
        url: index < photoUrls.length ? photoUrls[index] : null,
        isLoading: loadingIndices.contains(index),
        isActive: index <= photoUrls.length,
        onTap: () => onSlotTapped(index),
      ),
    );
  }
}
