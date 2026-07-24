import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
        child: CatchSectionList(
          emptyStateOmitted: true,
          gap: 0,
          children: [
            CatchSection.fieldRows(
              first: true,
              child: CatchField.input(
                title: context.l10n.hostsClubDetailsStepTitleDescription,
                contract: CatchContractConstraints
                    .createClubCallablePayloadDescription,
                controller: descriptionController,
                icon: CatchIcons.editNoteOutlined,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context
                        .l10n
                        .hostsClubDetailsStepVisiblecopyPleaseAddADescription;
                  }
                  return null;
                },
              ),
            ),
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
