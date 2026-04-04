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
      itemBuilder: (context, index) => _PhotoSlot(
        url: index < photoUrls.length ? photoUrls[index] : null,
        isLoading: loadingIndices.contains(index),
        isActive: index <= photoUrls.length,
        onTap: () => onSlotTapped(index),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.url,
    required this.isLoading,
    required this.isActive,
    required this.onTap,
  });

  final String? url;
  final bool isLoading;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Widget content;
    if (url != null) {
      content = Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (isActive) {
      content = Container(
        color: colorScheme.primaryContainer,
        child: Center(
          child: Icon(
            Icons.add_rounded,
            size: 36,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      );
    } else {
      content = Container(color: colorScheme.surfaceContainerHighest);
    }

    return GestureDetector(
      onTap: isActive && !isLoading ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            if (isLoading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            if (!isLoading && url != null)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
