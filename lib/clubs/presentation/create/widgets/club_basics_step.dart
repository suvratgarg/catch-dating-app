import 'dart:typed_data';

import 'package:catch_dating_app/clubs/presentation/create/widgets/create_club_cover_picker.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:flutter/material.dart';

class ClubBasicsStep extends StatelessWidget {
  const ClubBasicsStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.selectedCity,
    required this.onCityChanged,
    required this.areaController,
    required this.coverImageBytes,
    required this.existingImageUrl,
    required this.profileImageBytes,
    required this.existingProfileImageUrl,
    required this.onPickCover,
    required this.onPickProfileImage,
    this.detailsEnabled = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final CityOption? selectedCity;
  final ValueChanged<CityOption?> onCityChanged;
  final TextEditingController areaController;
  final Uint8List? coverImageBytes;
  final String? existingImageUrl;
  final Uint8List? profileImageBytes;
  final String? existingProfileImageUrl;
  final VoidCallback? onPickCover;
  final VoidCallback? onPickProfileImage;
  final bool detailsEnabled;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          16,
          CatchSpacing.s5,
          24,
        ),
        child: Column(
          children: [
            CreateClubProfileImagePicker(
              imageBytes: profileImageBytes,
              existingImageUrl: existingProfileImageUrl,
              onTap: onPickProfileImage,
            ),
            gapH16,
            CreateClubCoverPicker(
              coverImageBytes: coverImageBytes,
              existingImageUrl: existingImageUrl,
              onTap: onPickCover,
            ),
            gapH20,
            CatchTextField(
              label: 'Club name',
              controller: nameController,
              prefixIcon: const Icon(Icons.group_outlined),
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
              prefixIcon: const Icon(Icons.location_city_outlined),
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
              prefixIcon: const Icon(Icons.location_on_outlined),
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
