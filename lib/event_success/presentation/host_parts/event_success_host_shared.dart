part of '../event_success_host_screen.dart';

class EventSuccessTabPicker extends StatelessWidget {
  const EventSuccessTabPicker({
    required this.selectedTab,
    required this.onChanged,
  });

  final EventSuccessHostTab selectedTab;
  final ValueChanged<EventSuccessHostTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchTabRail<EventSuccessHostTab>(
      options: [
        for (final tab in EventSuccessHostTab.values)
          CatchOption(value: tab, label: tab.label(context.l10n)),
      ],
      selected: selectedTab,
      onChanged: onChanged,
    );
  }
}

class EventSuccessHostTabBody extends StatelessWidget {
  const EventSuccessHostTabBody({
    required this.embedded,
    required this.children,
  });

  final bool embedded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return CatchSectionList(
        gap: 0,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: CatchInsets.contentRelaxed,
      child: CatchSectionList(
        gap: 0,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

extension on EventSuccessHostTab {
  String label(AppLocalizations l10n) {
    return switch (this) {
      EventSuccessHostTab.setup =>
        l10n.eventSuccessEventSuccessHostSharedLabelSetup,
      EventSuccessHostTab.live =>
        l10n.eventSuccessEventSuccessHostSharedLabelLive,
      EventSuccessHostTab.report =>
        l10n.eventSuccessEventSuccessHostSharedLabelReport,
    };
  }
}

class PlanSummary extends StatelessWidget {
  const PlanSummary({
    required this.plan,
    required this.draft,
    required this.planIsPersisted,
  });

  final EventSuccessPlan plan;
  final EventSuccessHostDraft draft;
  final bool planIsPersisted;

  @override
  Widget build(BuildContext context) {
    final ready = draft.status == EventSuccessSetupStatus.readyForLaunch;
    return CatchField.content(
      title: draft.playbook.title,
      body: context.l10n.eventSuccessEventSuccessHostSharedLabelLengthTools(
        length: draft.selectedModules.length,
      ),
      action: CatchBadge(
        label: planIsPersisted
            ? draft.status.label
            : context.l10n.eventSuccessEventSuccessHostSharedLabelNotSaved,
        tone: planIsPersisted
            ? (ready ? CatchBadgeTone.success : CatchBadgeTone.warning)
            : CatchBadgeTone.warning,
      ),
      icon: CatchIcons.ruleFolderOutlined,
    );
  }
}

class HostActivitySummary extends StatelessWidget {
  const HostActivitySummary({required this.profile, required this.draft});

  final EventSuccessActivityProfile profile;
  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    return CatchField.content(
      title: profile.formatLabel,
      body: profile.summary,
      valueText: profile.interactionModel.label,
      icon: CatchIcons.autoAwesomeOutlined,
      action: CatchBadge(
        label: context.l10n
            .eventSuccessEventSuccessHostSharedLabelLengthSelected(
              length: draft.selectedModules.length,
            ),
      ),
    );
  }
}

class CompatibilitySignalHostCard extends StatelessWidget {
  const CompatibilitySignalHostCard({required this.plan});

  final EventSuccessPlan plan;

  @override
  Widget build(BuildContext context) {
    final rankingOn = plan.compatibilityAffectsRanking;
    final pack = plan.questionnaireConfig.pack;
    return CatchSection.fieldRows(
      children: [
        CatchField.content(
          title: context
              .l10n
              .eventSuccessEventSuccessHostSharedTextMatchClueQuestions,
          body: rankingOn
              ? context
                    .l10n
                    .eventSuccessEventSuccessHostSharedTextSuggestedPairingsCanUse
              : context
                    .l10n
                    .eventSuccessEventSuccessHostSharedTextAnswersCanStillShape,
          valueText: pack.title,
          icon: CatchIcons.psychologyAltOutlined,
          action: CatchBadge(
            label: rankingOn
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostSharedLabelCanGuidePairings
                : context.l10n.eventSuccessEventSuccessHostSharedLabelCluesOnly,
            tone: rankingOn ? CatchBadgeTone.success : CatchBadgeTone.neutral,
          ),
        ),
      ],
    );
  }
}

class WingmanRequestsHostCard extends StatelessWidget {
  const WingmanRequestsHostCard({
    required this.requests,
    required this.profiles,
    required this.rotationsEnabled,
  });

  final List<EventSuccessWingmanRequest> requests;
  final List<PublicProfile> profiles;
  final bool rotationsEnabled;

  @override
  Widget build(BuildContext context) {
    final activeRequests =
        requests.where((request) => request.isActive).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final profileByUid = {for (final profile in profiles) profile.uid: profile};
    return CatchSection.fieldRows(
      title: context.l10n.eventSuccessEventSuccessHostSharedTextHelpMeSayHi,
      count: context.l10n.eventSuccessEventSuccessHostSharedLabelLengthActive(
        length: activeRequests.length,
      ),
      children: [
        if (activeRequests.isEmpty)
          CatchField.content(
            title: context
                .l10n
                .eventSuccessEventSuccessHostSharedTextNoHostHelpRequests,
            body: rotationsEnabled
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThe
                : context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThef44110,
            icon: CatchIcons.volunteerActivismOutlined,
          ),
        for (final request in activeRequests)
          WingmanRequestHostRow(
            request: request,
            requester: profileByUid[request.requesterUid],
            target: profileByUid[request.targetUid],
          ),
      ],
    );
  }
}

class WingmanRequestHostRow extends StatelessWidget {
  const WingmanRequestHostRow({
    required this.request,
    required this.requester,
    required this.target,
  });

  final EventSuccessWingmanRequest request;
  final PublicProfile? requester;
  final PublicProfile? target;

  @override
  Widget build(BuildContext context) {
    final targetName =
        target?.name ??
        context.l10n.eventSuccessEventSuccessHostSharedVisiblecopyThisAttendee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchPersonRow(
          data: CatchPersonRowData(
            name:
                requester?.name ??
                context
                    .l10n
                    .eventSuccessEventSuccessHostSharedVisiblecopyAttendee,
            imageUrl: requester?.primaryPhotoThumbnailUrl,
            seed: request.requesterUid,
            metaLine: context.l10n
                .eventSuccessEventSuccessHostSharedVisiblecopyAskedForHelpMeeting(
                  targetName: targetName,
                ),
          ),
          avatarSize: 40,
          trailing: CatchBadge.functional(
            label:
                context.l10n.eventSuccessEventSuccessHostSharedLabelHostVisible,
            tone: CatchBadgeTone.brand,
            icon: CatchIcons.visibilityOutlined,
          ),
        ),
        if (request.note != null && request.note!.trim().isNotEmpty) ...[
          Padding(
            padding: _hostWingmanRequestNotePadding,
            child: Text(
              request.note!,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).ink2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
