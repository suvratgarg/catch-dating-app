import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({
    super.key,
    required this.club,
    required this.dist,
    required this.when,
    required this.tokens,
  });

  factory RecommendCard.fromRun({
    Key? key,
    required Run run,
    required CatchTokens tokens,
  }) => RecommendCard(
        key: key,
        club: run.title,
        dist: '${run.distanceKm.toStringAsFixed(0)}K',
        when: DateFormat('EEE d MMM').format(run.startTime),
        tokens: tokens,
      );

  final String club;
  final String dist;
  final String when;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.card),
      ),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(CatchRadius.button),
                    ),
                    child: Text(
                      dist,
                      style: CatchTextStyles.labelSm(
                        context,
                        color: Colors.black,
                      ).copyWith(letterSpacing: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.p10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(club,
                    style: CatchTextStyles.labelMd(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                gapH2,
                Text(when, style: CatchTextStyles.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
