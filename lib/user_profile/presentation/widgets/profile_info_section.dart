import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_tile.dart';
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
  const ProfileInfoSection({
    super.key,
    required this.entries,
    this.title,
    this.grouped = false,
  });

  final List<ProfileInfoEntry> entries;
  final String? title;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final tiles = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      tiles.add(
        ProfileInfoTile(
          icon: entry.icon,
          label: entry.label,
          value: entry.value,
          onTap: entry.onTap,
          isAddAffordance: entry.isAddAffordance,
        ),
      );
      if (grouped && i < entries.length - 1) {
        tiles.add(Divider(
          height: 1,
          indent: 52,
          color: CatchTokens.of(context).line,
        ));
      }
    }

    final body = grouped
        ? CatchSurface(
            borderColor: CatchTokens.of(context).line,
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
            child: Column(children: tiles),
          )
        : Column(children: tiles);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          gapH16,
          Padding(
            padding: EdgeInsets.only(
              left: grouped ? Sizes.p4 : 0,
              bottom: Sizes.p2,
            ),
            child: Text(
              title!.toUpperCase(),
              style: CatchTextStyles.labelM(context),
            ),
          ),
          gapH8,
        ],
        body,
      ],
    );
  }
}
