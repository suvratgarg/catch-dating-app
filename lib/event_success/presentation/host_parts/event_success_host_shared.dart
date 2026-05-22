part of '../event_success_host_screen.dart';

class _EventSuccessTabPicker extends StatelessWidget {
  const _EventSuccessTabPicker({
    required this.selectedTab,
    required this.onChanged,
  });

  final EventSuccessHostTab selectedTab;
  final ValueChanged<EventSuccessHostTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final tab in EventSuccessHostTab.values)
          CatchChip(
            label: tab.label,
            active: selectedTab == tab,
            icon: Icon(tab.icon),
            onTap: () => onChanged(tab),
          ),
      ],
    );
  }
}

extension on EventSuccessHostTab {
  String get label {
    return switch (this) {
      EventSuccessHostTab.setup => 'Setup',
      EventSuccessHostTab.live => 'Live',
      EventSuccessHostTab.report => 'Report',
    };
  }

  IconData get icon {
    return switch (this) {
      EventSuccessHostTab.setup => Icons.tune_rounded,
      EventSuccessHostTab.live => Icons.play_circle_outline_rounded,
      EventSuccessHostTab.report => Icons.insights_outlined,
    };
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({
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
          label: '${draft.selectedModules.length} tools',
          tone: CatchBadgeTone.neutral,
        ),
        CatchBadge(
          label: draft.status.label,
          tone: draft.status == EventSuccessSetupStatus.readyForLaunch
              ? CatchBadgeTone.success
              : CatchBadgeTone.warning,
        ),
        CatchBadge(
          label: planIsPersisted ? plan.status.hostLabel : 'Not saved',
          tone: planIsPersisted ? CatchBadgeTone.live : CatchBadgeTone.warning,
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

class _HostActivitySummary extends StatelessWidget {
  const _HostActivitySummary({required this.profile, required this.draft});

  final EventSuccessActivityProfile profile;
  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge(
                label: profile.activityKind.label,
                tone: CatchBadgeTone.brand,
                icon: Icons.auto_awesome_outlined,
              ),
              CatchBadge(
                label: profile.activityKind.defaultInteractionModel.label,
                tone: CatchBadgeTone.neutral,
              ),
              CatchBadge(
                label: '${draft.selectedModules.length} selected',
                tone: CatchBadgeTone.neutral,
              ),
            ],
          ),
          gapH8,
          Text(
            profile.summary,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _CompatibilitySignalHostCard extends StatelessWidget {
  const _CompatibilitySignalHostCard({required this.plan});

  final EventSuccessPlan plan;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final rankingOn = plan.compatibilityAffectsRanking;
    final pack = plan.questionnaireConfig.pack;
    return CatchSurface(
      borderColor: rankingOn ? Colors.transparent : t.line,
      tone: rankingOn ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_alt_outlined, color: t.primary),
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
                      'Match clue questions',
                      style: CatchTextStyles.titleM(context),
                    ),
                    CatchBadge(
                      label: rankingOn ? 'Can guide pairings' : 'Clues only',
                      tone: rankingOn
                          ? CatchBadgeTone.success
                          : CatchBadgeTone.neutral,
                    ),
                    CatchBadge(
                      label: pack.title,
                      tone: CatchBadgeTone.neutral,
                      icon: pack.custom
                          ? Icons.edit_note_rounded
                          : Icons.style_outlined,
                    ),
                  ],
                ),
                gapH6,
                Text(
                  rankingOn
                      ? 'Suggested pairings can use shared answers as one light input after interest, safety, and attendee opt-out checks.'
                      : 'Answers can still shape reveal clues, but suggested pairings will not use them.',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveAttendanceSummaryCard extends StatelessWidget {
  const _LiveAttendanceSummaryCard({
    required this.bookedCount,
    required this.checkedInCount,
    required this.waitlistCount,
  });

  final int bookedCount;
  final int checkedInCount;
  final int waitlistCount;

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
              Icon(Icons.qr_code_2_rounded, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  'Arrival check-in',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              Text(
                '$checkedInCount / $bookedCount',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
          ),
          gapH8,
          Text(
            'Attendance decides who can use assignments, wingman requests, and post-event feedback.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: '$bookedCount booked',
                tone: bookedCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.brand,
                icon: Icons.confirmation_number_outlined,
              ),
              CatchBadge(
                label: '$checkedInCount checked in',
                tone: checkedInCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.success,
                icon: Icons.check_circle_outline_rounded,
              ),
              CatchBadge(
                label: '$waitlistCount waitlist',
                tone: waitlistCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.warning,
                icon: Icons.hourglass_empty_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WingmanRequestsHostCard extends StatelessWidget {
  const _WingmanRequestsHostCard({
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
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism_outlined, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  'Wingman requests',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: '${activeRequests.length} active',
                tone: activeRequests.isEmpty
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.live,
                icon: Icons.visibility_outlined,
              ),
            ],
          ),
          gapH8,
          Text(
            rotationsEnabled
                ? 'Attendees explicitly asked the host for help. Use rotation edits or live facilitation to pair them safely.'
                : 'Attendees explicitly asked the host for help. Use this as live facilitation context.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH12,
          if (activeRequests.isEmpty)
            Text(
              'No host-help requests yet.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            )
          else
            for (final request in activeRequests)
              Padding(
                padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
                child: _WingmanRequestHostRow(
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

class _WingmanRequestHostRow extends StatelessWidget {
  const _WingmanRequestHostRow({
    required this.request,
    required this.requester,
    required this.target,
  });

  final EventSuccessWingmanRequest request;
  final PublicProfile? requester;
  final PublicProfile? target;

  @override
  Widget build(BuildContext context) {
    final targetName = target?.name ?? 'this attendee';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonRow(
          data: PersonRowData(
            name: requester?.name ?? 'Attendee',
            imageUrl: requester?.primaryPhotoThumbnailUrl,
            seed: request.requesterUid,
            metaLine: 'Asked for help meeting $targetName',
          ),
          avatarSize: 40,
          trailing: CatchBadge(
            label: 'Host visible',
            tone: CatchBadgeTone.live,
            icon: Icons.visibility_outlined,
          ),
        ),
        if (request.note != null && request.note!.trim().isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s2,
            ),
            child: Text(
              request.note!,
              style: CatchTextStyles.bodyS(
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
