import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardClubsRail extends ConsumerWidget {
  const DashboardClubsRail({super.key, required this.clubIds});

  final List<String> clubIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniqueIds = clubIds.toSet().take(12).toList(growable: false);
    if (uniqueIds.isEmpty) return const SizedBox.shrink();

    final clubsAsync = ref.watch(
      watchClubsByIdsProvider(ClubsByIdQuery(uniqueIds)),
    );
    final clubs = clubsAsync.asData?.value ?? const [];

    if (clubs.isNotEmpty) {
      return ClubAvatarRail(
        clubs: clubs,
        showDivider: false,
        headerPadding: EdgeInsets.zero,
        listPadding: EdgeInsets.zero,
      );
    }

    return clubsAsync.isLoading
        ? const _DashboardClubsRailSkeleton()
        : const SizedBox.shrink();
  }
}

class _DashboardClubsRailSkeleton extends StatelessWidget {
  const _DashboardClubsRailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Your clubs', style: CatchTextStyles.titleL(context)),
        gapH12,
        Row(
          children: [
            for (var index = 0; index < 3; index += 1) ...[
              if (index > 0) gapW14,
              Column(
                children: [
                  CatchSkeleton.circle(size: 64),
                  gapH6,
                  CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}
