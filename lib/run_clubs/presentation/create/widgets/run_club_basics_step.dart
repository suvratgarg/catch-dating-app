import 'dart:typed_data';

import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/widgets/create_run_club_cover_picker.dart';
import 'package:flutter/material.dart';

class RunClubBasicsStep extends StatelessWidget {
  const RunClubBasicsStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.selectedCity,
    required this.onCityChanged,
    required this.areaController,
    required this.coverImageBytes,
    required this.existingImageUrl,
    required this.onPickCover,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final IndianCity? selectedCity;
  final ValueChanged<IndianCity?> onCityChanged;
  final TextEditingController areaController;
  final Uint8List? coverImageBytes;
  final String? existingImageUrl;
  final VoidCallback? onPickCover;

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
            CreateRunClubCoverPicker(
              coverImageBytes: coverImageBytes,
              existingImageUrl: existingImageUrl,
              onTap: onPickCover,
            ),
            gapH20,
            CatchTextField(
              label: 'Club name',
              controller: nameController,
              prefixIcon: const Icon(Icons.group_outlined),
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
            CatchDropdownField<IndianCity>(
              values: IndianCity.values,
              label: 'City',
              prefixIcon: const Icon(Icons.location_city_outlined),
              value: selectedCity,
              onChanged: onCityChanged,
              validator: (_) =>
                  selectedCity == null ? 'Please select a city' : null,
            ),
            gapH16,
            CatchTextField(
              label: 'Area / neighbourhood',
              controller: areaController,
              prefixIcon: const Icon(Icons.location_on_outlined),
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
