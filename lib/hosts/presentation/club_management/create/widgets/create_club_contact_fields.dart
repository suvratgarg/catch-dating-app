import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
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
    this.first = false,
  });

  final TextEditingController instagramController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool showLabel;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return CatchSection.fieldRows(
      first: first,
      title: showLabel
          ? context.l10n.hostsCreateClubContactFieldsLabelContact
          : null,
      count: showLabel
          ? context.l10n.coreCatchFormFieldLabelTextOptional
          : null,
      children: [
        CatchField.input(
          title: context.l10n.hostsCreateClubContactFieldsTitleInstagramHandle,
          controller: instagramController,
          isOptional: true,
          icon: CatchIcons.alternateEmailRounded,
          inputHint:
              context.l10n.hostsCreateClubContactFieldsPlaceholderYourclub,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        CatchField.input(
          title: context.l10n.hostsCreateClubContactFieldsTitlePhoneNumber,
          controller: phoneController,
          isOptional: true,
          icon: CatchIcons.callOutlined,
          inputHint: '98765 43210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        CatchField.input(
          title: context.l10n.hostsCreateClubContactFieldsTitleEmail,
          controller: emailController,
          isOptional: true,
          icon: CatchIcons.emailOutlined,
          inputHint: context
              .l10n
              .hostsCreateClubContactFieldsPlaceholderHelloYourclubCom,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
