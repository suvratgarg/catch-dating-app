import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateClubContactFields extends StatelessWidget {
  const CreateClubContactFields({
    super.key,
    required this.instagramController,
    required this.phoneController,
    required this.emailController,
    this.showLabel = true,
  });

  final TextEditingController instagramController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          CatchFormFieldLabel(
            label: context.l10n.hostsCreateClubContactFieldsLabelContact,
            isOptional: true,
          ),
          gapH12,
        ],
        CatchField.input(
          title: context.l10n.hostsCreateClubContactFieldsTitleInstagramHandle,
          controller: instagramController,
          isOptional: true,
          prefixIcon: Icon(CatchIcons.alternateEmailRounded),
          placeholder:
              context.l10n.hostsCreateClubContactFieldsPlaceholderYourclub,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        gapH16,
        CatchField.input(
          title: context.l10n.hostsCreateClubContactFieldsTitlePhoneNumber,
          controller: phoneController,
          isOptional: true,
          prefixIcon: Icon(CatchIcons.callOutlined),
          placeholder: '98765 43210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        gapH16,
        CatchField.input(
          title: context.l10n.hostsCreateClubContactFieldsTitleEmail,
          controller: emailController,
          isOptional: true,
          prefixIcon: Icon(CatchIcons.emailOutlined),
          placeholder: context
              .l10n
              .hostsCreateClubContactFieldsPlaceholderHelloYourclubCom,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
