import 'dart:io';

import 'package:catch_dating_app/commonWidgets/app_form_layout.dart';
import 'package:catch_dating_app/commonWidgets/enum_dropdown.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/runClubs/presentation/create_run_club_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CreateRunClubScreen extends ConsumerStatefulWidget {
  const CreateRunClubScreen({super.key});

  @override
  ConsumerState<CreateRunClubScreen> createState() =>
      _CreateRunClubScreenState();
}

class _CreateRunClubScreenState extends ConsumerState<CreateRunClubScreen> {
  static const _fieldSpacing = 16.0;
  static const _buttonTopSpacing = 24.0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  IndianCity? _selectedCity;
  XFile? _coverImage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) setState(() => _coverImage = image);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      CreateRunClubController.submitMutation.run(ref, (transaction) async {
        await transaction
            .get(createRunClubControllerProvider.notifier)
            .submit(
              name: _nameController.text.trim(),
              location: _selectedCity!,
              description: _descriptionController.text.trim(),
              coverImage: _coverImage,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitMutation =
        ref.watch(CreateRunClubController.submitMutation);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(CreateRunClubController.submitMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Run Club')),
      body: AppFormLayout(
        formKey: _formKey,
        children: [
          Text(
            'Start a club',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell runners what your club is about',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: submitMutation.isPending ? null : _pickCoverImage,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _coverImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          kIsWeb
                              ? Image.network(_coverImage!.path, fit: BoxFit.cover)
                              : Image.file(File(_coverImage!.path), fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add cover photo',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Optional',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _nameController,
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
          const SizedBox(height: _fieldSpacing),
          EnumDropdownField<IndianCity>(
            values: IndianCity.values,
            label: 'City',
            prefixIcon: const Icon(Icons.location_on_outlined),
            initialValue: _selectedCity,
            onChanged: (city) => setState(() => _selectedCity = city),
            validator: (_) =>
                _selectedCity == null ? 'Please select a city' : null,
          ),
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _descriptionController,
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
          if (submitMutation.hasError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (submitMutation as MutationError).error.toString(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: _buttonTopSpacing),
          FilledButton(
            onPressed: submitMutation.isPending ? null : _submit,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create club'),
                if (submitMutation.isPending) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
