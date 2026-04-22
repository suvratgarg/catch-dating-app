import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_info_tile.dart';
import 'package:flutter/material.dart';

class ProfileInfoEntry {
  const ProfileInfoEntry({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({super.key, required this.entries});

  final List<ProfileInfoEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        gapH8,
        const Divider(),
        gapH8,
        for (final entry in entries)
          ProfileInfoTile(
            icon: entry.icon,
            label: entry.label,
            value: entry.value,
          ),
      ],
    );
  }
}
