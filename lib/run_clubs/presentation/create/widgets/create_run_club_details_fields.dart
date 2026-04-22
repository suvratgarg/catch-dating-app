import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/widgets/enum_dropdown.dart';
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
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Club name',
            prefixIcon: Icon(Icons.group_outlined),
          ),
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
        EnumDropdownField<IndianCity>(
          values: IndianCity.values,
          label: 'City',
          prefixIcon: const Icon(Icons.location_city_outlined),
          initialValue: selectedCity,
          onChanged: onCityChanged,
          validator: (_) =>
              selectedCity == null ? 'Please select a city' : null,
        ),
        gapH16,
        TextFormField(
          controller: areaController,
          decoration: const InputDecoration(
            labelText: 'Area / neighbourhood',
            prefixIcon: Icon(Icons.location_on_outlined),
            hintText: 'e.g. Bandra, Koramangala',
          ),
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
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Icons.edit_note_outlined),
            alignLabelWithHint: true,
          ),
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
