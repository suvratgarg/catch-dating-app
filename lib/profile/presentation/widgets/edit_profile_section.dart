import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:flutter/material.dart';

class EditProfileSection extends StatelessWidget {
  const EditProfileSection({
    super.key,
    required this.children,
    this.title,
    this.showDivider = false,
  });

  final String? title;
  final bool showDivider;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDivider) ...[gapH32, const Divider(), gapH16],
        if (title != null) ...[
          Text(
            title!,
            style: CatchTextStyles.displaySm(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          gapH16,
        ],
        ...children,
      ],
    );
  }
}
