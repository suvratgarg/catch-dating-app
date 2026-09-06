import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_record_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_focus_body.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class HostTodayPersonalizationPanel extends StatelessWidget {
  const HostTodayPersonalizationPanel({
    super.key,
    required this.state,
    required this.onChangeFocus,
    required this.onAction,
  });

  final HostTodayPersonalizationState state;
  final VoidCallback onChangeFocus;
  final ValueChanged<HostTodaySuggestedAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.plain(
          title: l10n.hostTodayYourFocus,
          trailing: CatchTextButton(
            key: const ValueKey('host-today-change-focus'),
            label: l10n.hostTodayChangeFocus,
            onPressed: onChangeFocus,
          ),
          child: Text(
            state.focus == null
                ? l10n.hostTodayExploreFocus
                : hostTodayFocusTitle(l10n, state.focus!),
            style: CatchTextStyles.titleL(context),
          ),
        ),
        if (state.primaryAction case final action?) ...[
          const SizedBox(height: CatchSpacing.s6),
          CatchSection.contained(
            title: _actionTitle(l10n, action),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _actionBody(l10n, action),
                  style: CatchTextStyles.bodyL(context),
                ),
                const SizedBox(height: CatchSpacing.s4),
                CatchButton(
                  key: const ValueKey('host-today-suggested-action'),
                  label: _actionLabel(l10n, action),
                  onPressed: () => onAction(action),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: CatchSpacing.s6),
        CatchSection.divided(
          title: l10n.hostTodayRoadmapTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.hostTodayRoadmapIntroduction,
                style: CatchTextStyles.supporting(context),
              ),
              const SizedBox(height: CatchSpacing.s3),
              for (final step in state.roadmap)
                CatchRecordRow(
                  key: ValueKey('host-today-milestone-${step.milestone.name}'),
                  title: _milestoneTitle(l10n, step.milestone),
                  icon: step.progress == HostTodayMilestoneProgress.complete
                      ? CatchIcons.checkCircle
                      : CatchIcons.circle,
                  metadata: !step.enabled
                      ? l10n.hostTodayMilestoneOwnerOnly
                      : switch (step.progress) {
                          HostTodayMilestoneProgress.complete =>
                            l10n.hostTodayMilestoneComplete,
                          HostTodayMilestoneProgress.incomplete =>
                            l10n.hostTodayMilestoneAvailable,
                          HostTodayMilestoneProgress.unknown =>
                            l10n.hostTodayMilestoneUnknown,
                        },
                  onTap: step.enabled ? () => onAction(step.action) : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _milestoneTitle(AppLocalizations l10n, HostTodayMilestone milestone) =>
    switch (milestone) {
      HostTodayMilestone.audience => l10n.hostTodayMilestoneAudience,
      HostTodayMilestone.rehearsal => l10n.hostTodayMilestoneRehearsal,
      HostTodayMilestone.organizerPage => l10n.hostTodayMilestonePage,
      HostTodayMilestone.payouts => l10n.hostTodayMilestonePayouts,
    };

String _actionTitle(AppLocalizations l10n, HostTodaySuggestedAction action) =>
    switch (action) {
      HostTodaySuggestedAction.addCustomer => l10n.hostTodayAddCustomerTitle,
      HostTodaySuggestedAction.openAudience => l10n.hostTodayAudienceTitle,
      HostTodaySuggestedAction.startDressRehearsal =>
        l10n.hostTodayPracticeTitle,
      HostTodaySuggestedAction.openOrganizerPage => l10n.hostTodayPresenceTitle,
      HostTodaySuggestedAction.managePayouts => l10n.hostTodayMilestonePayouts,
    };

String _actionBody(AppLocalizations l10n, HostTodaySuggestedAction action) =>
    switch (action) {
      HostTodaySuggestedAction.addCustomer ||
      HostTodaySuggestedAction.openAudience => l10n.hostTodayAudienceBody,
      HostTodaySuggestedAction.startDressRehearsal =>
        l10n.hostTodayPracticeBody,
      HostTodaySuggestedAction.openOrganizerPage => l10n.hostTodayPresenceBody,
      HostTodaySuggestedAction.managePayouts => l10n.hostTodayPayoutsBody,
    };

String _actionLabel(
  AppLocalizations l10n,
  HostTodaySuggestedAction action,
) => switch (action) {
  HostTodaySuggestedAction.addCustomer => l10n.hostTodayAddCustomerAction,
  HostTodaySuggestedAction.openAudience => l10n.hostTodayAudienceAction,
  HostTodaySuggestedAction.startDressRehearsal => l10n.hostTodayPracticeAction,
  HostTodaySuggestedAction.openOrganizerPage => l10n.hostTodayPresenceAction,
  HostTodaySuggestedAction.managePayouts => l10n.hostTodayPayoutsAction,
};
