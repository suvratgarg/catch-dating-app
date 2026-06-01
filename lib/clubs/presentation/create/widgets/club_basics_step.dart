import 'dart:typed_data';

import 'package:catch_dating_app/clubs/presentation/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:flutter/material.dart';

class ClubBasicsStep extends StatelessWidget {
  const ClubBasicsStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.selectedCity,
    required this.onCityChanged,
    required this.areaController,
    required this.clubPhotoPreviews,
    required this.existingImageUrl,
    required this.profileImageBytes,
    required this.existingProfileImageUrl,
    required this.onPickClubPhotos,
    required this.onRemoveClubPhoto,
    required this.onReorderClubPhoto,
    required this.onPickProfileImage,
    this.detailsEnabled = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final CityOption? selectedCity;
  final ValueChanged<CityOption?> onCityChanged;
  final TextEditingController areaController;
  final List<OrderedPhotoPreview> clubPhotoPreviews;
  final String? existingImageUrl;
  final Uint8List? profileImageBytes;
  final String? existingProfileImageUrl;
  final VoidCallback? onPickClubPhotos;
  final ValueChanged<int>? onRemoveClubPhoto;
  final void Function(int fromIndex, int toIndex)? onReorderClubPhoto;
  final VoidCallback? onPickProfileImage;
  final bool detailsEnabled;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: CatchInsets.formStepBody,
        child: Column(
          children: [
            CreateClubProfileImagePicker(
              imageBytes: profileImageBytes,
              existingImageUrl: existingProfileImageUrl,
              onTap: onPickProfileImage,
            ),
            gapH16,
            CreateClubPhotosPicker(
              photos: clubPhotoPreviews,
              existingImageUrl: existingImageUrl,
              onAddPhotos: onPickClubPhotos,
              onRemovePhoto: onRemoveClubPhoto,
              onReorderPhoto: onReorderClubPhoto,
            ),
            gapH20,
            CatchTextField(
              label: 'Club name',
              controller: nameController,
              prefixIcon: Icon(CatchIcons.groupOutlined),
              enabled: detailsEnabled,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a club name';
                }
                return null;
              },
            ),
            gapH16,
            CatchDropdownField<CityOption>(
              values: defaultCityOptions,
              label: 'City',
              prefixIcon: Icon(CatchIcons.locationCityOutlined),
              value: selectedCity,
              enabled: detailsEnabled,
              onChanged: onCityChanged,
              validator: (_) =>
                  selectedCity == null ? 'Please select a city' : null,
            ),
            gapH16,
            CatchTextField(
              label: 'Area / neighbourhood',
              controller: areaController,
              prefixIcon: Icon(CatchIcons.locationOnOutlined),
              enabled: detailsEnabled,
              hintText: 'e.g. Bandra, Koramangala',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an area';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
