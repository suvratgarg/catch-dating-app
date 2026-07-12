import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_list_tile.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Returns the slivers for the club directory section. Returns multiple
/// slivers so the parent can spread them flat — nesting `SliverMainAxisGroup`
/// inside another `SliverMainAxisGroup` produces inconsistent build
/// behaviour for items past the first viewport.
List<Widget> buildClubDirectorySlivers({
  required BuildContext context,
  required List<Club> clubs,
  required Set<String> joinedClubIds,
}) {
  return [
    SliverToBoxAdapter(
      child: CatchSectionHeader(
        title: context.l10n.clubsClubDiscoverListTitleClubDirectory,
        titleStyle: CatchTextStyles.titleL(context),
        padding: CatchInsets.sectionHeader,
      ),
    ),
    SliverPadding(
      padding: CatchInsets.pageHorizontal,
      sliver: SliverList.list(
        children: [
          for (var index = 0; index < clubs.length; index += 1) ...[
            if (index > 0) gapH14,
            ClubIndexRow(
              club: clubs[index],
              isJoined: joinedClubIds.contains(clubs[index].id),
              onTap: () => _openClubDetail(context, clubs[index]),
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
  });

  final List<Club> clubs;
  final Set<String> joinedClubIds;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: buildClubDirectorySlivers(
        context: context,
        clubs: clubs,
        joinedClubIds: joinedClubIds,
      ),
    );
  }
}

void _openClubDetail(BuildContext context, Club club) {
  context.pushNamed(
    Routes.clubDetailScreen.name,
    pathParameters: {'clubId': club.id},
    extra: club,
  );
}
