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
    return CatchOptionGroup<EventSuccessHostTab>(
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
    final shrinkWrap = embedded;
    return ListView(
      shrinkWrap: shrinkWrap,
      primary: shrinkWrap ? false : null,
      physics: embedded
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: embedded ? EdgeInsets.zero : CatchInsets.contentRelaxed,
      children: children,
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
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        CatchBadge(label: draft.playbook.title, tone: CatchBadgeTone.brand),
        CatchBadge(
          label: context.l10n
              .eventSuccessEventSuccessHostSharedLabelLengthTools(
                length: draft.selectedModules.length,
              ),
        ),
        CatchBadge(
          label: draft.status.label,
          tone: draft.status == EventSuccessSetupStatus.readyForLaunch
              ? CatchBadgeTone.success
              : CatchBadgeTone.warning,
        ),
        CatchBadge(
          label: planIsPersisted
              ? plan.status.hostLabel
              : context.l10n.eventSuccessEventSuccessHostSharedLabelNotSaved,
          tone: planIsPersisted ? CatchBadgeTone.brand : CatchBadgeTone.warning,
        ),
      ],
    );
  }
}

extension on EventSuccessPlanStatus {
  String get hostLabel {
    return switch (this) {
      EventSuccessPlanStatus.setup => 'Setup saved',
      EventSuccessPlanStatus.live => 'Live',
      EventSuccessPlanStatus.complete => 'Complete',
    };
  }
}

class HostActivitySummary extends StatelessWidget {
  const HostActivitySummary({required this.profile, required this.draft});

  final EventSuccessActivityProfile profile;
  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge(
                label: profile.formatLabel,
                tone: CatchBadgeTone.brand,
                icon: CatchIcons.autoAwesomeOutlined,
              ),
              CatchBadge(label: profile.interactionModel.label),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostSharedLabelLengthSelected(
                      length: draft.selectedModules.length,
                    ),
              ),
            ],
          ),
          gapH8,
          Text(
            profile.summary,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class CompatibilitySignalHostCard extends StatelessWidget {
  const CompatibilitySignalHostCard({required this.plan});

  final EventSuccessPlan plan;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final rankingOn = plan.compatibilityAffectsRanking;
    final pack = plan.questionnaireConfig.pack;
    return CatchSurface(
      borderColor: rankingOn
          ? t.surface.withValues(alpha: CatchOpacity.none)
          : t.line,
      tone: rankingOn ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
      padding: CatchInsets.content,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CatchIcons.psychologyAltOutlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      context
                          .l10n
                          .eventSuccessEventSuccessHostSharedTextMatchClueQuestions,
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    CatchBadge(
                      label: rankingOn
                          ? context
                                .l10n
                                .eventSuccessEventSuccessHostSharedLabelCanGuidePairings
                          : context
                                .l10n
                                .eventSuccessEventSuccessHostSharedLabelCluesOnly,
                      tone: rankingOn
                          ? CatchBadgeTone.success
                          : CatchBadgeTone.neutral,
                    ),
                    CatchBadge(
                      label: pack.title,
                      icon: pack.custom
                          ? CatchIcons.editNoteRounded
                          : CatchIcons.styleOutlined,
                    ),
                  ],
                ),
                gapH6,
                Text(
                  rankingOn
                      ? context
                            .l10n
                            .eventSuccessEventSuccessHostSharedTextSuggestedPairingsCanUse
                      : context
                            .l10n
                            .eventSuccessEventSuccessHostSharedTextAnswersCanStillShape,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LiveAttendanceSummaryCard extends StatelessWidget {
  const LiveAttendanceSummaryCard({
    required this.event,
    required this.bookedCount,
    required this.checkedInCount,
    required this.waitlistCount,
  });

  final Event event;
  final int bookedCount;
  final int checkedInCount;
  final int waitlistCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CatchIcons.qrCode2Rounded, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextArrivalCheckIn,
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              Text(
                context.l10n
                    .eventSuccessEventSuccessHostSharedTextCheckedincountBookedcount(
                      checkedInCount: checkedInCount,
                      bookedCount: bookedCount,
                    ),
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
          gapH8,
          Text(
            context
                .l10n
                .eventSuccessEventSuccessHostSharedTextAttendanceDecidesWhoCan,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostSharedLabelBookedcountBooked(
                      bookedCount: bookedCount,
                    ),
                tone: bookedCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.brand,
                icon: CatchIcons.confirmationNumberOutlined,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostSharedLabelCheckedincountCheckedIn(
                      checkedInCount: checkedInCount,
                    ),
                tone: checkedInCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.success,
                icon: CatchIcons.checkCircleOutlineRounded,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostSharedLabelWaitlistcountWaitlist(
                      waitlistCount: waitlistCount,
                    ),
                tone: waitlistCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.warning,
                icon: CatchIcons.hourglassEmptyRounded,
              ),
            ],
          ),
          gapH14,
          HostCheckInQrPanel(event: event),
        ],
      ),
    );
  }
}

class HostCheckInQrPanel extends StatelessWidget {
  const HostCheckInQrPanel({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final payload = EventCheckInQrPayload(eventId: event.id).encode();
    return CatchSurface(
      radius: CatchRadius.sm,
      backgroundColor: t.raised,
      borderColor: t.line,
      padding: CatchInsets.contentDense,
      child: Row(
        children: [
          CatchSurface(
            radius: CatchRadius.sm,
            backgroundColor: CatchTokens.editorialWhite,
            borderWidth: 0,
            padding: CatchInsets.iconChipContent,
            child: QrImageView(
              data: payload,
              size: 116,
              padding: EdgeInsets.zero,
              backgroundColor: CatchTokens.editorialWhite,
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.eventSuccessEventSuccessHostSharedTextHostQr,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH4,
                Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextAttendeesCanScanThis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
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
    final t = CatchTokens.of(context);
    final activeRequests =
        requests.where((request) => request.isActive).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final profileByUid = {for (final profile in profiles) profile.uid: profile};
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CatchIcons.volunteerActivismOutlined, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextHelpMeSayHi,
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostSharedLabelLengthActive(
                      length: activeRequests.length,
                    ),
                tone: activeRequests.isEmpty
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.brand,
                icon: CatchIcons.visibilityOutlined,
              ),
            ],
          ),
          gapH8,
          Text(
            rotationsEnabled
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThe
                : context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThef44110,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          if (activeRequests.isEmpty)
            Text(
              context
                  .l10n
                  .eventSuccessEventSuccessHostSharedTextNoHostHelpRequests,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            )
          else
            for (final request in activeRequests)
              Padding(
                padding: _hostWingmanRequestGap,
                child: WingmanRequestHostRow(
                  request: request,
                  requester: profileByUid[request.requesterUid],
                  target: profileByUid[request.targetUid],
                ),
              ),
        ],
      ),
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
