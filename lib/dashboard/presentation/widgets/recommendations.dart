import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommend_card.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Recommendations extends ConsumerWidget {
  const Recommendations({super.key, required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = tokens;
    final userAsync = ref.watch(userProfileStreamProvider);
    final user = userAsync.asData?.value;

    final clubIds = user?.joinedRunClubIds ?? [];
    final runsAsync = ref.watch(recommendedRunsProvider(clubIds));
    final runs = runsAsync.asData?.value ?? [];

    if (runs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recommended runs',
                style: CatchTextStyles.displaySm(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: runs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) =>
                RecommendCard.fromRun(run: runs[i], tokens: t),
          ),
        ),
      ],
    );
  }
}
