import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_list_tile.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/section_header.dart';
import 'package:flutter/material.dart';

class HorizontalClubSection extends StatelessWidget {
  const HorizontalClubSection({
    super.key,
    required this.title,
    this.trailing,
    required this.height,
    required this.clubs,
    required this.variant,
    this.isJoined = false,
  });

  final String title;
  final String? trailing;
  final double height;
  final List<RunClub> clubs;
  final RunClubListTileVariant variant;
  final bool isJoined;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title, trailing: trailing),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.screenH,
            ),
            itemCount: clubs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => RunClubListTile(
              club: clubs[index],
              variant: variant,
              isJoined: isJoined,
            ),
          ),
        ),
      ],
    );
  }
}
