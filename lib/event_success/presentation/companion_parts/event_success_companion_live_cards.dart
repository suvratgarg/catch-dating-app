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
                      ? 'Micro-pods paused for you'
                      : assigned?.displayTitle ?? 'Pod assignment pending',
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  microPodsOptedOut
                      ? 'You will not be included when the host generates pods.'
                      : assigned?.displaySubtitle ??
                            'The host will publish pods once the roster is ready.',
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
                          label: 'Loading podmates',
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
                CatchButton(
                  label: microPodsOptedOut
                      ? 'Join micro-pods'
                      : 'Skip micro-pods',
                  variant: microPodsOptedOut
                      ? CatchButtonVariant.primary
                      : CatchButtonVariant.secondary,
                  isLoading: mutation.isPending,
                  onPressed: mutation.isPending
                      ? null
                      : () =>
                            EventSuccessController.microPodsOptOutMutation.run(
                              ref,
                              (tx) => tx
                                  .get(eventSuccessControllerProvider.notifier)
                                  .setMicroPodsOptOut(
                                    event: event,
                                    optedOut: !microPodsOptedOut,
                                  ),
                            ),
                  fullWidth: true,
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
                      ? 'Rotations paused for you'
                      : assigned?.displayTitle ?? 'Rotation schedule pending',
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  guidedRotationsOptedOut
                      ? 'You will not be included when the host generates timed rotations.'
                      : assigned?.displaySubtitle ??
                            'The host will publish timed pairings once the roster is ready.',
                  style: CatchTextStyles.bodyS(context),
                ),
                if (assigned != null) ...[
                  gapH10,
                  if (peersLoading)
                    const CatchBadge(
                      label: 'Loading partners',
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
                CatchButton(
                  label: guidedRotationsOptedOut
                      ? 'Join rotations'
                      : 'Skip rotations',
                  variant: guidedRotationsOptedOut
                      ? CatchButtonVariant.primary
                      : CatchButtonVariant.secondary,
                  isLoading: mutation.isPending,
                  onPressed: mutation.isPending
                      ? null
                      : () => EventSuccessController
                            .guidedRotationsOptOutMutation
                            .run(
                              ref,
                              (tx) => tx
                                  .get(eventSuccessControllerProvider.notifier)
                                  .setGuidedRotationsOptOut(
                                    event: event,
                                    optedOut: !guidedRotationsOptedOut,
                                  ),
                            ),
                  fullWidth: true,
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

class _PreCheckInPlanningCard extends ConsumerWidget {
  const _PreCheckInPlanningCard({
    required this.event,
    required this.microPodsEnabled,
    required this.guidedRotationsEnabled,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
  });

  final Event event;
  final bool microPodsEnabled;
  final bool guidedRotationsEnabled;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final microPodsMutation = ref.watch(
      EventSuccessController.microPodsOptOutMutation,
    );
    final rotationsMutation = ref.watch(
      EventSuccessController.guidedRotationsOptOutMutation,
    );

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
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Before you arrive',
                      style: CatchTextStyles.titleM(context),
                    ),
                    const CatchBadge(
                      label: 'Pre-arrival',
                      tone: CatchBadgeTone.neutral,
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
                gapH4,
                Text(
                  'Live partner and pod details unlock after check-in. Set planning preferences now so the host can prepare clean assignments.',
                  style: CatchTextStyles.bodyS(context),
                ),
                gapH12,
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    if (microPodsEnabled)
                      CatchButton(
                        label: microPodsOptedOut
                            ? 'Join micro-pods'
                            : 'Skip micro-pods',
                        size: CatchButtonSize.sm,
                        variant: microPodsOptedOut
                            ? CatchButtonVariant.primary
                            : CatchButtonVariant.secondary,
                        icon: Icon(
                          microPodsOptedOut
                              ? Icons.groups_2_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        isLoading: microPodsMutation.isPending,
                        onPressed: microPodsMutation.isPending
                            ? null
                            : () => EventSuccessController
                                  .microPodsOptOutMutation
                                  .run(
                                    ref,
                                    (tx) => tx
                                        .get(
                                          eventSuccessControllerProvider
                                              .notifier,
                                        )
                                        .setMicroPodsOptOut(
                                          event: event,
                                          optedOut: !microPodsOptedOut,
                                        ),
                                  ),
                      ),
                    if (guidedRotationsEnabled)
                      CatchButton(
                        label: guidedRotationsOptedOut
                            ? 'Join rotations'
                            : 'Skip rotations',
                        size: CatchButtonSize.sm,
                        variant: guidedRotationsOptedOut
                            ? CatchButtonVariant.primary
                            : CatchButtonVariant.secondary,
                        icon: Icon(
                          guidedRotationsOptedOut
                              ? Icons.sync_alt_rounded
                              : Icons.block_outlined,
                        ),
                        isLoading: rotationsMutation.isPending,
                        onPressed: rotationsMutation.isPending
                            ? null
                            : () => EventSuccessController
                                  .guidedRotationsOptOutMutation
                                  .run(
                                    ref,
                                    (tx) => tx
                                        .get(
                                          eventSuccessControllerProvider
                                              .notifier,
                                        )
                                        .setGuidedRotationsOptOut(
                                          event: event,
                                          optedOut: !guidedRotationsOptedOut,
                                        ),
                                  ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
