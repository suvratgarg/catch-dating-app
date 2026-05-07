import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class ReviewPromptCard extends StatelessWidget {
  const ReviewPromptCard({
    super.key,
    required this.run,
    required this.reviewer,
  });

  final Run run;
  final UserProfile reviewer;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rate_review_outlined, color: t.primary, size: 18),
              gapW8,
              Expanded(
                child: Text(
                  'Review your run',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
            ],
          ),
          gapH8,
          Text(
            'Tell future runners how ${RunFormatters.longDate(run.startTime)} felt.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH12,
          CatchButton(
            label: 'Write review',
            onPressed: () => showWriteReviewSheet(
              context: context,
              runClubId: run.runClubId,
              runId: run.id,
              reviewer: reviewer,
            ),
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
