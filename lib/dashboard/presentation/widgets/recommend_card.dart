import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({
    super.key,
    required this.runClubId,
    required this.runId,
    required this.club,
    required this.dist,
    required this.when,
  });

  factory RecommendCard.fromRun({Key? key, required Run run}) => RecommendCard(
    key: key,
    runClubId: run.runClubId,
    runId: run.id,
    club: run.title,
    dist: '${run.distanceKm.toStringAsFixed(0)}K',
    when: DateFormat('EEE d MMM').format(run.startTime),
  );

  final String runClubId;
  final String runId;
  final String club;
  final String dist;
  final String when;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      onTap: () => context.pushNamed(
        Routes.runDetailScreen.name,
        pathParameters: {'runClubId': runClubId, 'runId': runId},
      ),
      width: 180,
      radius: CatchRadius.md,
      borderColor: t.line,
      backgroundColor: t.surface,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 86,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PersonAvatar(size: double.infinity, name: club),
                Positioned(
                  top: 8,
                  left: 8,
                  child: CatchBadge(label: dist, tone: CatchBadgeTone.neutral),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.p10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club,
                  style: CatchTextStyles.labelL(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH2,
                Text(when, style: CatchTextStyles.bodyS(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
