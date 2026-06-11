import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateClubContactFields extends StatelessWidget {
  const CreateClubContactFields({
    super.key,
    required this.instagramController,
    required this.phoneController,
    required this.emailController,
  });

  final TextEditingController instagramController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact (optional)', style: CatchTextStyles.titleS(context)),
        gapH12,
        CatchTextField(
          label: 'Instagram handle',
          controller: instagramController,
          isOptional: true,
          prefixIcon: Icon(CatchIcons.alternateEmailRounded),
          hintText: '@yourclub',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        gapH16,
        CatchTextField(
          label: 'Phone number',
          controller: phoneController,
          isOptional: true,
          prefixIcon: Icon(CatchIcons.callOutlined),
          hintText: '98765 43210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        gapH16,
        CatchTextField(
          label: 'Email',
          controller: emailController,
          isOptional: true,
          prefixIcon: Icon(CatchIcons.emailOutlined),
          hintText: 'hello@yourclub.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
