import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_list_tile.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RunClubsContent extends StatelessWidget {
  const RunClubsContent({
    super.key,
    required this.viewModel,
    required this.isJoinPending,
    this.onJoin,
  });

  final RunClubsListViewModel viewModel;
  final bool isJoinPending;
  final ValueChanged<RunClub>? onJoin;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isEmpty) {
      return Center(child: RunClubsEmptyState());
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (viewModel.joinedClubs.isNotEmpty) ...[
          const SectionHeader(title: 'Your clubs'),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
              itemCount: viewModel.joinedClubs.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index < viewModel.joinedClubs.length) {
                  final club = viewModel.joinedClubs[index];
                  return RunClubListTile(
                    club: club,
                    variant: RunClubListTileVariant.avatarChip,
                    showLiveBadge: club.nextRunLabel != null,
                  );
                }
                return _FindMoreButton(
                  onTap: () =>
                      context.pushNamed(Routes.createRunClubScreen.name),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
            child: Divider(color: CatchTokens.of(context).line, height: 24),
          ),
        ],
        if (viewModel.allClubs.isNotEmpty) ...[
          const SectionHeader(title: 'Discover'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
            child: Column(
              children: [
                for (var i = 0; i < viewModel.allClubs.length; i++) ...[
                  RunClubListTile(
                    club: viewModel.allClubs[i],
                    variant: RunClubListTileVariant.directory,
                    isJoined: viewModel.joinedClubIds
                        .contains(viewModel.allClubs[i].id),
                    onJoin: onJoin == null || isJoinPending
                        ? null
                        : () => onJoin!(viewModel.allClubs[i]),
                  ),
                  if (i < viewModel.allClubs.length - 1)
                    const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FindMoreButton extends StatelessWidget {
  const _FindMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.line2,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                color: t.raised,
              ),
              child: Icon(Icons.add_rounded, size: 24, color: t.ink2),
            ),
            const SizedBox(height: 6),
            Text(
              'Find more',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: t.ink2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
