import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    return CatchSection.fieldRows(
      title: context.l10n.hostsCreateEventPhotoPickerLabelEventPhotos,
      count: context.l10n.coreCatchFormFieldLabelTextOptional,
      first: true,
      showInternalDividers: false,
      child: OrderedPhotoPicker(
        photos: photos,
        onAddPhotos: onAddPhotos,
        onRemovePhoto: onRemovePhoto,
        onReorderPhoto: onReorderPhoto,
        emptyActionLabel:
            context.l10n.hostsCreateEventPhotoPickerVisiblecopyAddEventPhotos,
        addActionLabel:
            context.l10n.hostsCreateEventPhotoPickerVisiblecopyAddPhotos,
      ),
    );
  }
}
