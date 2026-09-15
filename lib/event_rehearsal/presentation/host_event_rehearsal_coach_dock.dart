part of 'host_event_rehearsal_screen.dart';

class _RehearsalCoachDock extends StatelessWidget {
  const _RehearsalCoachDock({
    required this.task,
    required this.collapsed,
    required this.onWhy,
    required this.onToggle,
  });

  final _RehearsalCoachTask task;
  final bool collapsed;
  final VoidCallback onWhy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    if (collapsed) {
      final coachIdentity = Row(
        children: [
          Icon(CatchIcons.scienceOutlined, color: t.danger),
          gapW8,
          Expanded(
            child: Text(
              context.l10n.hostEventRehearsalCoachCollapsed,
              style: CatchTextStyles.labelM(context),
            ),
          ),
        ],
      );
      final showCoach = CatchButton(
        label: context.l10n.hostEventRehearsalCoachShow,
        size: CatchButtonSize.sm,
        variant: CatchButtonVariant.secondary,
        fullWidth: largeText,
        onPressed: onToggle,
      );
      return CatchDockSurface(
        padding: CatchInsets.rosterRowContent,
        child: largeText
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [coachIdentity, gapH8, showCoach],
              )
            : Row(
                children: [
                  Expanded(child: coachIdentity),
                  showCoach,
                ],
              ),
      );
    }

    final taskCopy = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSurface(
          width: CatchIconAction.navSize,
          height: CatchIconAction.navSize,
          radius: CatchRadius.sm,
          backgroundColor: t.danger,
          child: Icon(CatchIcons.scienceOutlined, color: t.primaryInk),
        ),
        gapW12,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hostEventRehearsalCoachProgress(
                  current: task.number,
                  total: 8,
                ),
                style: CatchTextStyles.kicker(context, color: t.danger),
              ),
              gapH4,
              Text(
                task.title,
                maxLines: largeText ? null : 2,
                overflow: largeText ? null : TextOverflow.ellipsis,
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH2,
              Text(
                task.body,
                maxLines: largeText ? null : 1,
                overflow: largeText ? null : TextOverflow.ellipsis,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
    final actions = Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      alignment: WrapAlignment.end,
      children: [
        CatchButton(
          label: context.l10n.hostEventRehearsalCoachWhy,
          size: CatchButtonSize.sm,
          variant: CatchButtonVariant.secondary,
          onPressed: onWhy,
        ),
        CatchButton(
          label: context.l10n.hostEventRehearsalCoachGotIt,
          size: CatchButtonSize.sm,
          onPressed: onToggle,
        ),
      ],
    );
    return CatchDockSurface(
      padding: largeText ? CatchInsets.content : CatchInsets.rosterRowContent,
      child: largeText
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [taskCopy, gapH10, actions],
            )
          : Row(
              children: [
                Expanded(child: taskCopy),
                gapW8,
                actions,
              ],
            ),
    );
  }
}
