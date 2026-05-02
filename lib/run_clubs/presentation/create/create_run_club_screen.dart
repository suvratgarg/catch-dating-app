import 'dart:typed_data';

import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/app_form_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/create_run_club_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/widgets/create_run_club_cover_picker.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/widgets/create_run_club_details_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CreateRunClubScreen extends ConsumerStatefulWidget {
  const CreateRunClubScreen({super.key, this.initialRunClub});

  final RunClub? initialRunClub;

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
  Uint8List? _coverImageBytes;

  bool get _isEditing => widget.initialRunClub != null;

  @override
  void initState() {
    super.initState();
    final club = widget.initialRunClub;
    if (club == null) {
      return;
    }

    _nameController.text = club.name;
    _areaController.text = club.area;
    _descriptionController.text = club.description;
    _selectedCity = club.location;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final image = await ref
        .read(imageUploadRepositoryProvider)
        .pickImage(imageQuality: 85);
    if (!mounted || image == null) {
      return;
    }
    final imageBytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      _coverImage = image;
      _coverImageBytes = imageBytes;
    });
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
              existingRunClub: widget.initialRunClub,
              coverImage: _coverImage,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final submitMutation = ref.watch(CreateRunClubController.submitMutation);
    final mutationError = submitMutation.hasError
        ? (submitMutation as MutationError).error.toString()
        : null;

    ref.listen(CreateRunClubController.submitMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: CatchTopBar(
        title: _isEditing ? 'Edit run club' : 'Create run club',
      ),
      body: AppFormLayout(
        formKey: _formKey,
        children: [
          Text(
            _isEditing ? 'Update club' : 'Start a club',
            style: CatchTextStyles.titleL(context, color: t.primary),
            textAlign: TextAlign.center,
          ),
          gapH8,
          Text(
            _isEditing
                ? 'Keep your club details current'
                : 'Tell runners what your club is about',
            style: CatchTextStyles.bodyM(context, color: t.ink2),
            textAlign: TextAlign.center,
          ),
          gapH48,
          CreateRunClubCoverPicker(
            coverImageBytes: _coverImageBytes,
            existingImageUrl: widget.initialRunClub?.imageUrl,
            onTap: submitMutation.isPending ? null : _pickCoverImage,
          ),
          gapH16,
          CreateRunClubDetailsFields(
            nameController: _nameController,
            selectedCity: _selectedCity,
            onCityChanged: (city) => setState(() => _selectedCity = city),
            areaController: _areaController,
            descriptionController: _descriptionController,
          ),
          if (mutationError != null) ...[
            gapH16,
            ErrorBanner(message: mutationError),
          ],
          gapH24,
          CatchButton(
            label: _isEditing ? 'Save changes' : 'Create club',
            onPressed: _submit,
            isLoading: submitMutation.isPending,
            fullWidth: true,
          ),
          gapH48,
        ],
      ),
    );
  }
}
