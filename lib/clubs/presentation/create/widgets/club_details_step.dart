import 'package:catch_dating_app/clubs/presentation/create/widgets/create_club_contact_fields.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:flutter/material.dart';

class ClubDetailsStep extends StatelessWidget {
  const ClubDetailsStep({
    super.key,
    required this.formKey,
    required this.descriptionController,
    required this.instagramController,
    required this.phoneController,
    required this.emailController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final TextEditingController instagramController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: CatchInsets.formStepBody,
        child: Column(
          children: [
            CatchTextField(
              label: 'Description',
              controller: descriptionController,
              prefixIcon: Icon(CatchIcons.editNoteOutlined),
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
            gapH24,
            CreateClubContactFields(
              instagramController: instagramController,
              phoneController: phoneController,
              emailController: emailController,
            ),
          ],
        ),
      ),
    );
  }
}
