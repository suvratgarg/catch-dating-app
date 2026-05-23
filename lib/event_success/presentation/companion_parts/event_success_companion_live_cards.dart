part of '../event_success_companion_screen.dart';

class _MicroPodCard extends ConsumerWidget {
  const _MicroPodCard({
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.microPodsOptedOut,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final bool microPodsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final mutation = ref.watch(EventSuccessController.microPodsOptOutMutation);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.groups_2_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  microPodsOptedOut
                      ? 'Starter groups paused for you'
                      : assigned?.displayTitle ??
                            'Your starter group will appear here',
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  microPodsOptedOut
                      ? 'You won\'t be included when the host runs the generator.'
                      : assigned?.displaySubtitle ??
                            'The host will publish starter groups once everyone is checked in.',
                  style: CatchTextStyles.bodyS(context),
                ),
                if (assigned != null) ...[
                  gapH10,
                  Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    children: [
                      CatchBadge(
                        label: '${assigned.peerUids.length + 1} people',
                        tone: CatchBadgeTone.neutral,
                        icon: Icons.group_outlined,
                      ),
                      if (peersLoading)
                        const CatchBadge(
                          label: 'Loading group members',
                          tone: CatchBadgeTone.neutral,
                          icon: Icons.hourglass_empty_rounded,
                        )
                      else
                        for (final profile in peerProfiles)
                          CatchBadge(
                            label: profile.name,
                            tone: CatchBadgeTone.neutral,
                            icon: Icons.person_outline_rounded,
                          ),
                    ],
                  ),
                ],
                gapH12,
                _IncludeMeToggle(
                  label: 'Include me in starter groups',
                  included: !microPodsOptedOut,
                  busy: mutation.isPending,
                  onChanged: (include) =>
                      EventSuccessController.microPodsOptOutMutation.run(
                        ref,
                        (tx) => tx
                            .get(eventSuccessControllerProvider.notifier)
                            .setMicroPodsOptOut(
                              event: event,
                              optedOut: !include,
                            ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationScheduleCard extends ConsumerWidget {
  const _RotationScheduleCard({
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.guidedRotationsOptedOut,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final bool guidedRotationsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final mutation = ref.watch(
      EventSuccessController.guidedRotationsOptOutMutation,
    );
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sync_alt_rounded, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guidedRotationsOptedOut
                      ? 'Timed rotations paused for you'
                      : assigned?.displayTitle ??
                            'Your rotation schedule will appear here',
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  guidedRotationsOptedOut
                      ? 'You won\'t be included when the host runs the generator.'
                      : assigned?.displaySubtitle ??
                            'Your timed pairings appear once the host generates rotations.',
                  style: CatchTextStyles.bodyS(context),
                ),
                if (assigned != null) ...[
                  gapH10,
                  if (peersLoading)
                    const CatchBadge(
                      label: 'Loading partner names',
                      tone: CatchBadgeTone.neutral,
                      icon: Icons.hourglass_empty_rounded,
                    )
                  else
                    Column(
                      children: [
                        for (final slot in assigned.rotationSlots)
                          _RotationSlotRow(
                            slot: slot,
                            peerName:
                                profilesByUid[slot.peerUid]?.name ?? 'Partner',
                          ),
                      ],
                    ),
                ],
                gapH12,
                _IncludeMeToggle(
                  label: 'Include me in timed rotations',
                  included: !guidedRotationsOptedOut,
                  busy: mutation.isPending,
                  onChanged: (include) => EventSuccessController
                      .guidedRotationsOptOutMutation
                      .run(
                        ref,
                        (tx) => tx
                            .get(eventSuccessControllerProvider.notifier)
                            .setGuidedRotationsOptOut(
                              event: event,
                              optedOut: !include,
                            ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationSlotRow extends StatelessWidget {
  const _RotationSlotRow({required this.slot, required this.peerName});

  final EventSuccessRotationSlot slot;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final timeRange =
        '${TimeOfDay.fromDateTime(slot.startsAt).format(context)}-'
        '${TimeOfDay.fromDateTime(slot.endsAt).format(context)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: Row(
        children: [
          CatchBadge(
            label: slot.label,
            tone: _isStrongRotationSignal(slot.compatibility)
                ? CatchBadgeTone.success
                : CatchBadgeTone.neutral,
          ),
          gapW8,
          Expanded(
            child: Text(
              '$timeRange · $peerName',
              style: CatchTextStyles.bodyS(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStepContextCard extends StatelessWidget {
  const _LiveStepContextCard({required this.step});

  final EventRunOfShowStep? step;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activeStep = step;
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, color: t.primary),
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
                      activeStep == null ? 'Event is live' : activeStep.title,
                      style: CatchTextStyles.titleM(context),
                    ),
                    if (activeStep != null)
                      CatchBadge(
                        label: activeStep.stage.label,
                        tone: CatchBadgeTone.neutral,
                      ),
                  ],
                ),
                gapH4,
                Text(
                  activeStep?.attendeeExperience ??
                      'Follow the host for the next event moment.',
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

/// Informational preview of what the host will guide the attendee through
/// once check-in opens. Opt-out controls live on the at-event cards instead —
/// asking an attendee to opt out *before* they know what each tool feels like
/// is presumptuous, and the host doesn't need pre-arrival preferences to
/// generate assignments.
class _PreCheckInPlanningCard extends StatelessWidget {
  const _PreCheckInPlanningCard({
    required this.microPodsEnabled,
    required this.guidedRotationsEnabled,
    required this.liveRevealEnabled,
    required this.socialMissionsEnabled,
    required this.wingmanRequestsEnabled,
  });

  final bool microPodsEnabled;
  final bool guidedRotationsEnabled;
  final bool liveRevealEnabled;
  final bool socialMissionsEnabled;
  final bool wingmanRequestsEnabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final entries = <_PreviewLine>[
      if (microPodsEnabled)
        const _PreviewLine(
          icon: Icons.groups_2_outlined,
          text: 'Small starter group when you check in.',
        ),
      if (guidedRotationsEnabled)
        const _PreviewLine(
          icon: Icons.sync_alt_rounded,
          text: 'Timed partner rotations during the event.',
        ),
      if (liveRevealEnabled)
        const _PreviewLine(
          icon: Icons.bolt_rounded,
          text: 'Synchronized partner reveals as the event unfolds.',
        ),
      if (socialMissionsEnabled)
        const _PreviewLine(
          icon: Icons.chat_bubble_outline_rounded,
          text: 'Live conversation prompts from the host.',
        ),
      if (wingmanRequestsEnabled)
        const _PreviewLine(
          icon: Icons.volunteer_activism_outlined,
          text: 'You can ask the host for an intro to someone specific.',
        ),
    ];
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_available_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What we\'ll guide you through',
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  'Live partner and group details unlock after check-in. Here\'s what to expect at the event:',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
                gapH10,
                for (final entry in entries) ...[entry, gapH6],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: t.ink2),
        ),
        gapW6,
        Expanded(
          child: Text(text, style: CatchTextStyles.bodyS(context)),
        ),
      ],
    );
  }
}

/// Small Switch + label used as the per-card opt-in toggle for starter groups
/// and timed rotations. Replaces the older "Skip" / "Join" verb-flipping
/// button so the current state is visible at a glance.
class _IncludeMeToggle extends StatelessWidget {
  const _IncludeMeToggle({
    required this.label,
    required this.included,
    required this.busy,
    required this.onChanged,
  });

  final String label;
  final bool included;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: CatchTextStyles.labelL(context)),
        ),
        Switch.adaptive(
          value: included,
          onChanged: busy ? null : onChanged,
        ),
      ],
    );
  }
}

class _SelfCheckInCard extends ConsumerWidget {
  const _SelfCheckInCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(EventBookingController.selfCheckInMutation);
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arrival check-in', style: CatchTextStyles.titleM(context)),
          gapH6,
          Text(
            'Confirm you are at the event so post-event follow-up only includes actual attendees.',
            style: CatchTextStyles.bodyS(context),
          ),
          gapH12,
          CatchButton(
            label: 'Check in',
            isLoading: mutation.isPending,
            onPressed: mutation.isPending
                ? null
                : () => EventBookingController.selfCheckInMutation.run(
                    ref,
                    (tx) => tx
                        .get(eventBookingControllerProvider.notifier)
                        .selfCheckIn(eventId: event.id),
                  ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
