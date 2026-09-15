part of 'event_success_feature_blocks.dart';

class LiveStepRow extends StatelessWidget {
  const LiveStepRow({super.key, required this.step, required this.state});

  final EventRunOfShowStep step;
  final EventSuccessProgressStatus state;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = switch (state) {
      EventSuccessProgressStatus.current => t.gold,
      EventSuccessProgressStatus.complete => t.success,
      EventSuccessProgressStatus.future => t.ink3,
    };

    return Padding(
      padding: _liveStepRowGap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            switch (state) {
              EventSuccessProgressStatus.complete =>
                CatchIcons.checkCircleRounded,
              EventSuccessProgressStatus.current =>
                CatchIcons.radioButtonCheckedRounded,
              EventSuccessProgressStatus.future =>
                CatchIcons.radioButtonUncheckedRounded,
            },
            color: color,
            size: CatchIcon.md,
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: CatchTextStyles.sectionTitle(context)),
                const SizedBox(height: CatchSpacing.s1),
                Text(
                  context.l10n
                      .eventSuccessEventSuccessFeatureBlocksTextDurationminutesMinLabel(
                        durationMinutes: step.durationMinutes,
                        label: step.stage.label,
                      ),
                  style: CatchTextStyles.supporting(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
