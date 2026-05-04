import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RunClubAvatarRail extends StatelessWidget {
  const RunClubAvatarRail({super.key, required this.clubs});

  final List<RunClub> clubs;

  @override
  Widget build(BuildContext context) {
    return CatchHorizontalRail(
      title: 'Your clubs',
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return RunClubListTile(
          club: club,
          variant: RunClubListTileVariant.avatarChip,
          showLiveBadge: club.nextRunLabel != null,
        );
      },
      trailing: _CreateClubButton(
        onTap: () => context.pushNamed(Routes.createRunClubScreen.name),
      ),
    );
  }
}

class _CreateClubButton extends StatelessWidget {
  const _CreateClubButton({required this.onTap});

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
              'Create',
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
