import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:flutter/material.dart';

class CreateRunClubDetailsFields extends StatelessWidget {
  const CreateRunClubDetailsFields({
    super.key,
    required this.nameController,
    required this.selectedCity,
    required this.onCityChanged,
    required this.areaController,
    required this.descriptionController,
  });

  final TextEditingController nameController;
  final IndianCity? selectedCity;
  final ValueChanged<IndianCity?> onCityChanged;
  final TextEditingController areaController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        // TODO: replace free-text area field with a validated dropdown of known
        // neighbourhoods per city (see indian_city_areas.dart). Add a LabelledString
        // wrapper so CatchDropdownField can hold String values. "Other..." option
        // reveals a text field for custom input. City change resets area selection.
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
        gapH16,
        CatchTextField(
          label: 'Description',
          controller: descriptionController,
          prefixIcon: const Icon(Icons.edit_note_outlined),
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please add a description';
            }
            return null;
          },
        ),
      ],
    );
  }
}
