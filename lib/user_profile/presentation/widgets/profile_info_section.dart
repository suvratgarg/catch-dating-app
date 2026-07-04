import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldRow;
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({
    super.key,
    required this.children,
    required this.title,
    this.subtitle,
    this.first = false,
  });

  final List<Widget> children;
  final String title;
  final String? subtitle;
  final bool first;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    // The section owns the gutter and the dividers: rows render flush via
    // CatchSection.divided's inset scope, and dividers align to the field
    // text lane (derived from the leading-slot metrics, not hardcoded).
    return CatchSection.divided(
      title: title,
      count: subtitle,
      first: first,
      bodyGap: CatchSpacing.micro10,
      dividerIndent: CatchFieldRow.textLaneInset,
      children: children,
    );
  }
}
