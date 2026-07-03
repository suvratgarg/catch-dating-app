import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:flutter/material.dart';

class CreateEventPhotoPicker extends StatelessWidget {
  const CreateEventPhotoPicker({
    super.key,
    required this.photos,
    required this.onAddPhotos,
    required this.onRemovePhoto,
    required this.onReorderPhoto,
  });

  final List<OrderedPhotoPreview> photos;
  final VoidCallback? onAddPhotos;
  final ValueChanged<int>? onRemovePhoto;
  final void Function(int fromIndex, int toIndex)? onReorderPhoto;

  @override
  Widget build(BuildContext context) {
    return OrderedPhotoPicker(
      label: const CatchFormFieldLabel(
        label: 'Event photos',
        isOptional: true,
        large: true,
      ),
      photos: photos,
      onAddPhotos: onAddPhotos,
      onRemovePhoto: onRemovePhoto,
      onReorderPhoto: onReorderPhoto,
      emptyActionLabel: 'Add event photos',
      addActionLabel: 'Add photos',
    );
  }
}
