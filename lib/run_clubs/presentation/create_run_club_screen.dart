import 'dart:io';

import 'package:catch_dating_app/common_widgets/app_form_layout.dart';
import 'package:catch_dating_app/common_widgets/enum_dropdown.dart';
import 'package:catch_dating_app/common_widgets/error_banner.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/presentation/create_run_club_controller.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  IndianCity? _selectedCity;
  XFile? _coverImage;

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
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
              area: _areaController.text.trim(),
              description: _descriptionController.text.trim(),
              coverImage: _coverImage,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final submitMutation = ref.watch(CreateRunClubController.submitMutation);

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
            style: CatchTextStyles.displaySm(context, color: t.primary),
            textAlign: TextAlign.center,
          ),
          gapH8,
          Text(
            'Tell runners what your club is about',
            style: CatchTextStyles.bodyMd(context, color: t.ink2),
            textAlign: TextAlign.center,
          ),
          gapH48,
          GestureDetector(
            onTap: submitMutation.isPending ? null : _pickCoverImage,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.card),
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
                                color: t.surface.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: t.ink,
                              ),
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
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: t.ink2,
                            ),
                            gapH8,
                            Text(
                              'Add cover photo',
                              style: CatchTextStyles.bodyMd(context, color: t.ink2),
                            ),
                            Text(
                              'Optional',
                              style: CatchTextStyles.caption(context, color: t.ink3),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          gapH16,
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
          gapH16,
          EnumDropdownField<IndianCity>(
            values: IndianCity.values,
            label: 'City',
            prefixIcon: const Icon(Icons.location_city_outlined),
            initialValue: _selectedCity,
            onChanged: (city) => setState(() => _selectedCity = city),
            validator: (_) =>
                _selectedCity == null ? 'Please select a city' : null,
          ),
          gapH16,
          TextFormField(
            controller: _areaController,
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
            gapH16,
            ErrorBanner(
              message: (submitMutation as MutationError).error.toString(),
            ),
          ],
          gapH24,
          FilledButton(
            onPressed: submitMutation.isPending ? null : _submit,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create club'),
                if (submitMutation.isPending) ...[
                  gapW8,
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          gapH48,
        ],
      ),
    );
  }
}
