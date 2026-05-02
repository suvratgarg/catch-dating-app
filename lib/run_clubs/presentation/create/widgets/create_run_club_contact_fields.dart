import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:flutter/material.dart';

class CreateRunClubContactFields extends StatelessWidget {
  const CreateRunClubContactFields({
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
        Text(
          'Contact (optional)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        gapH12,
        CatchTextField(
          label: 'Instagram handle',
          controller: instagramController,
          isOptional: true,
          prefixIcon: const Icon(Icons.alternate_email_rounded),
          hintText: '@yourclub',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        gapH16,
        CatchTextField(
          label: 'Phone number',
          controller: phoneController,
          isOptional: true,
          prefixIcon: const Icon(Icons.call_outlined),
          hintText: '+91 98765 43210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        gapH16,
        CatchTextField(
          label: 'Email',
          controller: emailController,
          isOptional: true,
          prefixIcon: const Icon(Icons.email_outlined),
          hintText: 'hello@yourclub.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
