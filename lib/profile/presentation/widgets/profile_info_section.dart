import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_info_tile.dart';
import 'package:flutter/material.dart';

class ProfileInfoEntry {
  const ProfileInfoEntry({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.isAddAffordance = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isAddAffordance;
}

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({super.key, required this.entries, this.title});

  final List<ProfileInfoEntry> entries;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gapH8,
        const Divider(),
        gapH8,
        if (title != null) ...[
          Text(
            title!.toUpperCase(),
            style: CatchTextStyles.labelM(
              context,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          gapH8,
        ],
        for (final entry in entries)
          ProfileInfoTile(
            icon: entry.icon,
            label: entry.label,
            value: entry.value,
            onTap: entry.onTap,
            isAddAffordance: entry.isAddAffordance,
          ),
      ],
    );
  }
}
