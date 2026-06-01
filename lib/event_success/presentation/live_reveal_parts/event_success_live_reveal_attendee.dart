part of '../event_success_live_reveal_card.dart';

class EventSuccessLiveRevealAttendeeCard extends ConsumerWidget {
  const EventSuccessLiveRevealAttendeeCard({
    super.key,
    required this.event,
    required this.plan,
    required this.kind,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.optedOut,
    this.now,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessRevealAssignmentKind kind;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final bool optedOut;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RevealTicker(
      enabled: now == null && plan.isRevealCountdownRunning(DateTime.now()),
      builder: (context, tickNow) {
        final referenceNow = now ?? tickNow;
        return _buildCard(context, ref, referenceNow);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    DateTime referenceNow,
  ) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final mutation = kind == EventSuccessRevealAssignmentKind.rotations
        ? ref.watch(EventSuccessController.guidedRotationsOptOutMutation)
        : ref.watch(EventSuccessController.microPodsOptOutMutation);
    final groupSlots =
        assigned?.groupRotationSlots ?? const <EventSuccessGroupRotationSlot>[];
    final roundCount = assigned == null
        ? 0
        : kind == EventSuccessRevealAssignmentKind.rotations
        ? assigned.rotationSlots.length
        : groupSlots.isNotEmpty
        ? groupSlots.length
        : 1;
    final revealedThrough = plan.revealedThroughRoundIndex(referenceNow);
    final activeRound = _safeRoundIndex(
      plan.activeRevealRoundIndex,
      roundCount,
    );
    final isCountingDown =
        assigned != null && plan.isRevealCountdownRunning(referenceNow);
    final visibleSlots = assigned == null
        ? const <EventSuccessRotationSlot>[]
        : assigned.rotationSlots
              .where(
                (slot) => plan.isRoundRevealed(slot.roundIndex, referenceNow),
              )
              .toList(growable: false);
    final visibleGroupSlots = groupSlots
        .where((slot) => plan.isRoundRevealed(slot.roundIndex, referenceNow))
        .toList(growable: false);
    final podVisible =
        assigned != null &&
        kind == EventSuccessRevealAssignmentKind.microPods &&
        groupSlots.isEmpty &&
        plan.isRoundRevealed(0, referenceNow);
    final showAssignment = kind == EventSuccessRevealAssignmentKind.rotations
        ? visibleSlots.isNotEmpty
        : groupSlots.isNotEmpty
        ? visibleGroupSlots.isNotEmpty
        : podVisible;
    final title = _attendeeTitle(
      assigned: assigned,
      showAssignment: showAssignment,
      isCountingDown: isCountingDown,
      remainingSeconds: _remainingSeconds(plan, referenceNow),
    );
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };

    final revealColor = showAssignment ? t.success : t.primary;
    return CatchSurface(
      backgroundColor: t.surface.withValues(
        alpha: CatchOpacity.revealAttendeePanelFill,
      ),
      radius: CatchRadius.sm,
      borderColor: revealColor.withValues(
        alpha: CatchOpacity.revealAttendeeBorder,
      ),
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge(
                label: kind.label,
                tone: CatchBadgeTone.live,
                icon: CatchIcons.boltRounded,
              ),
              if (assigned != null)
                CatchBadge(
                  label: isCountingDown
                      ? 'Unlocking'
                      : showAssignment
                      ? 'Revealed'
                      : 'Waiting',
                  tone: showAssignment
                      ? CatchBadgeTone.success
                      : isCountingDown
                      ? CatchBadgeTone.warning
                      : CatchBadgeTone.neutral,
                ),
            ],
          ),
          gapH12,
          Text(title, style: CatchTextStyles.titleL(context)),
          gapH6,
          Text(
            _attendeeSubtitle(
              assigned: assigned,
              showAssignment: showAssignment,
              isCountingDown: isCountingDown,
            ),
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (assigned != null && !optedOut) ...[
            gapH16,
            if (isCountingDown)
              _AttendeeCountdown(
                plan: plan,
                now: referenceNow,
                kind: kind,
                clue: _attendeeClue(assigned, activeRound),
              )
            else if (!showAssignment)
              _WaitingRevealCue(kind: kind)
            else if (kind == EventSuccessRevealAssignmentKind.rotations)
              _VisibleRotationSlots(
                slots: visibleSlots,
                profilesByUid: profilesByUid,
                peersLoading: peersLoading,
              )
            else if (groupSlots.isNotEmpty)
              _VisibleGroupRotationSlots(
                slots: visibleGroupSlots,
                profilesByUid: profilesByUid,
                peersLoading: peersLoading,
              )
            else
              _VisiblePodAssignment(
                assignment: assigned,
                peerProfiles: peerProfiles,
                peersLoading: peersLoading,
              ),
            if (roundCount > 1) ...[
              gapH12,
              _RevealRoundRail(
                roundCount: roundCount,
                activeRoundIndex: activeRound,
                revealedThrough: revealedThrough,
                foreground: t.ink,
              ),
            ],
          ],
          gapH14,
          CatchSurface(
            backgroundColor: t.ink.withValues(
              alpha: CatchOpacity.revealAttendeeActionDock,
            ),
            radius: CatchRadius.sm,
            borderWidth: 0,
            padding: CatchInsets.iconChipContent,
            child: CatchButton(
              label: optedOut ? _joinLabel(kind) : _skipLabel(kind),
              variant: optedOut
                  ? CatchButtonVariant.primary
                  : CatchButtonVariant.secondary,
              isLoading: mutation.isPending,
              onPressed: mutation.isPending
                  ? null
                  : () => _toggleOptOut(ref, optedOut: !optedOut),
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  String _attendeeTitle({
    required EventSuccessAssignment? assigned,
    required bool showAssignment,
    required bool isCountingDown,
    required int remainingSeconds,
  }) {
    if (optedOut) {
      return '${kind.assignmentNounPlural.capitalized} paused for you';
    }
    if (assigned == null) {
      return '${kind.assignmentNoun.capitalized} reveal pending';
    }
    if (isCountingDown) return 'Next reveal in ${remainingSeconds}s';
    if (showAssignment) {
      if (kind == EventSuccessRevealAssignmentKind.rotations) {
        return assigned.displayTitle;
      }
      return assigned.displayTitle;
    }
    return 'Waiting for the host reveal';
  }

  String _attendeeSubtitle({
    required EventSuccessAssignment? assigned,
    required bool showAssignment,
    required bool isCountingDown,
  }) {
    if (optedOut) {
      return kind == EventSuccessRevealAssignmentKind.rotations
          ? 'You will not be included when the host generates timed rotations.'
          : 'You will not be included when the host generates pods.';
    }
    if (assigned == null) {
      return 'The host will publish ${kind.assignmentNounPlural} once the roster is ready.';
    }
    if (isCountingDown) {
      return 'Everyone gets this ${kind.assignmentNoun} at the same time.';
    }
    if (showAssignment) {
      return assigned.displaySubtitle ??
          'Use this as a nudge, then let the conversation breathe.';
    }
    return 'Your details stay hidden until the shared reveal moment starts.';
  }

  String _attendeeClue(EventSuccessAssignment assignment, int activeRound) {
    if (kind == EventSuccessRevealAssignmentKind.microPods) {
      final slot = _groupSlotForRound(assignment, activeRound);
      if (slot != null) {
        return 'Clue: ${slot.unitLabel} is ready, but the names unlock together.';
      }
      return 'Clue: ${assignment.label} is ready, but the names unlock together.';
    }
    final slot = _slotForRound(assignment, activeRound);
    if (slot == null) {
      return 'Clue: the next pairing is ready.';
    }
    return 'Clue: ${_compatibilityLabel(slot.compatibility).toLowerCase()}.';
  }

  void _toggleOptOut(WidgetRef ref, {required bool optedOut}) {
    if (kind == EventSuccessRevealAssignmentKind.rotations) {
      EventSuccessController.guidedRotationsOptOutMutation.run(
        ref,
        (tx) => tx
            .get(eventSuccessControllerProvider.notifier)
            .setGuidedRotationsOptOut(event: event, optedOut: optedOut),
      );
      return;
    }
    EventSuccessController.microPodsOptOutMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .setMicroPodsOptOut(event: event, optedOut: optedOut),
    );
  }
}
