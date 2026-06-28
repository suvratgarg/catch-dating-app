import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_tile.dart';
import 'package:flutter/material.dart';

class ProfileInfoEntry {
  const ProfileInfoEntry({
    this.builder,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.editor,
    this.isExpanded = false,
    this.isAddAffordance = false,
  });

  final WidgetBuilder? builder;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? editor;
  final bool isExpanded;
  final bool isAddAffordance;
}

Widget profileInfoSection({
  Key? key,
  required BuildContext context,
  required List<ProfileInfoEntry> entries,
  String? title,
  String? subtitle,
  bool grouped = false,
  bool first = false,
}) {
  if (entries.isEmpty) {
    return const SizedBox.shrink();
  }

  final tiles = <Widget>[];
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    final builder = entry.builder;
    if (builder != null) {
      tiles.add(builder(context));
    } else {
      tiles.add(
        profileInfoTile(
          icon: entry.icon,
          label: entry.label,
          value: entry.value,
          onTap: entry.onTap,
          isAddAffordance: entry.isAddAffordance,
          isExpanded: entry.isExpanded,
        ),
      );
      final editor = entry.editor;
      if (editor != null) {
        tiles.add(
          profileInlineAnimatedBody(
            isExpanded: entry.isExpanded,
            child: editor,
          ),
        );
      }
    }
    if (grouped && i < entries.length - 1) {
      tiles.add(
        Divider(
          height: 1,
          indent: CatchSpacing.s8,
          color: CatchTokens.of(
            context,
          ).line.withValues(alpha: CatchOpacity.profileInfoDivider),
        ),
      );
    }
  }

  final tileList = Column(children: tiles);
  final Widget section;
  if (grouped && title != null) {
    section = CatchSection(
      title: title,
      count: subtitle,
      first: first,
      bodyGap: CatchSpacing.micro10,
      child: tileList,
    );
  } else {
    final body = grouped
        ? CatchSurface(
            borderColor: CatchTokens.of(context).line,
            padding: CatchInsets.contentHorizontal,
            child: tileList,
          )
        : tileList;

    section = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          gapH16,
          Padding(
            padding: EdgeInsets.only(
              left: grouped ? CatchSpacing.s1 : 0,
              bottom: CatchSpacing.micro2,
            ),
            child: Text(title, style: CatchTextStyles.labelL(context)),
          ),
          gapH8,
        ],
        body,
      ],
    );
  }

  if (key == null) return section;
  return KeyedSubtree(key: key, child: section);
}
