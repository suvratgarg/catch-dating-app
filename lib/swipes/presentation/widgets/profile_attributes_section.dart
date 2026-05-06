import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_info_chip.dart';
import 'package:flutter/material.dart';

class ProfileAttributesSection extends StatelessWidget {
  const ProfileAttributesSection({super.key, required this.attrs});

  final List<ProfileCardFact> attrs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s1,
      ),
      child: Wrap(
        spacing: CatchSpacing.s2,
        runSpacing: CatchSpacing.s2,
        children: [
          for (final a in attrs) ProfileInfoChip(icon: a.icon, text: a.text),
        ],
      ),
    );
  }
}
