import 'dart:typed_data';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:flutter/material.dart';

class CreateClubPhotosPicker extends StatelessWidget {
  const CreateClubPhotosPicker({
    super.key,
    required this.photos,
    this.existingImageUrl,
    required this.onAddPhotos,
    required this.onRemovePhoto,
    required this.onReorderPhoto,
  });

  final List<OrderedPhotoPreview> photos;
  final String? existingImageUrl;
  final VoidCallback? onAddPhotos;
  final ValueChanged<int>? onRemovePhoto;
  final void Function(int fromIndex, int toIndex)? onReorderPhoto;

  @override
  Widget build(BuildContext context) {
    final visiblePhotos = photos.isNotEmpty
        ? photos
        : [
            if (existingImageUrl != null)
              OrderedPhotoPreview(
                id: 'existing_legacy_club_cover',
                imageUrl: existingImageUrl,
              ),
          ];
    final hasEditablePhotos = photos.isNotEmpty;
    return OrderedPhotoPicker(
      label: const CatchFormFieldLabel(label: 'Club photos', isOptional: true),
      photos: visiblePhotos,
      onAddPhotos: onAddPhotos,
      onRemovePhoto: hasEditablePhotos ? onRemovePhoto : null,
      onReorderPhoto: hasEditablePhotos ? onReorderPhoto : null,
      emptyActionLabel: 'Add club photos',
      addActionLabel: 'Add photos',
    );
  }
}

class CreateClubProfileImagePicker extends StatelessWidget {
  const CreateClubProfileImagePicker({
    super.key,
    required this.imageBytes,
    this.existingImageUrl,
    required this.onTap,
  });

  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasImage = imageBytes != null || existingImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CatchFormFieldLabel(
          label: 'Club profile image',
          isOptional: true,
        ),
        gapH8,
        Semantics(
          button: true,
          label: hasImage
              ? 'Change club profile image'
              : 'Add club profile image',
          child: GestureDetector(
            onTap: onTap,
            // A small fixed avatar; a full-width square here pushes the rest of
            // the create form off-screen.
            child: SizedBox.square(
              dimension: CatchLayout.clubProfileImagePickerExtent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.md),
                child: hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageBytes != null)
                            Image.memory(imageBytes!, fit: BoxFit.cover)
                          else
                            Image.network(
                              existingImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  Container(color: t.raised),
                            ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: CatchIconTile(
                              icon: CatchIcons.editOutlined,
                              iconColor: t.ink,
                              backgroundColor: t.surface.withValues(
                                alpha: CatchOpacity.imageEditControlFill,
                              ),
                              borderColor: Colors.transparent,
                              size: 28,
                              iconSize: CatchIcon.xs,
                              radius: CatchRadius.pill,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: t.raised,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CatchIcons.addPhotoAlternateOutlined,
                              size: 30,
                              color: t.ink2,
                            ),
                            gapH8,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                'Add image',
                                style: CatchTextStyles.supporting(
                                  context,
                                  color: t.ink2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
