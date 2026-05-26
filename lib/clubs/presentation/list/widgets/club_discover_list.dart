import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Returns the slivers for the club directory section. Returns multiple
/// slivers so the parent can spread them flat — nesting `SliverMainAxisGroup`
/// inside another `SliverMainAxisGroup` produces inconsistent build
/// behaviour for items past the first viewport.
List<Widget> buildClubDirectorySlivers({
  required BuildContext context,
  required List<Club> clubs,
  required Set<String> joinedClubIds,
  required Set<String> hostedClubIds,
}) {
  return [
    SliverToBoxAdapter(
      child: SectionHeader(
        title: 'Club directory',
        uppercase: false,
        titleStyle: CatchTextStyles.titleL(context),
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          14,
          CatchSpacing.s5,
          8,
        ),
      ),
    ),
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
      sliver: SliverList.list(
        children: [
          for (var index = 0; index < clubs.length; index += 1) ...[
            if (index > 0) gapH14,
            ClubListTile(
              club: clubs[index],
              variant: ClubListTileVariant.directory,
              isJoined: joinedClubIds.contains(clubs[index].id),
              isHost: hostedClubIds.contains(clubs[index].id),
            ),
          ],
        ],
      ),
    ),
  ];
}

/// Compatibility wrapper — kept so the `ClubDiscoverList()` constructor call
/// remains a valid sliver expression at existing call sites.
class ClubDiscoverList extends StatelessWidget {
  const ClubDiscoverList({
    super.key,
    required this.clubs,
    required this.joinedClubIds,
    required this.hostedClubIds,
  });

  final List<Club> clubs;
  final Set<String> joinedClubIds;
  final Set<String> hostedClubIds;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: buildClubDirectorySlivers(
        context: context,
        clubs: clubs,
        joinedClubIds: joinedClubIds,
        hostedClubIds: hostedClubIds,
      ),
    );
  }
}
