part of '../event_success_live_reveal_card.dart';

class EventSuccessLiveRevealHostCard extends ConsumerWidget {
  const EventSuccessLiveRevealHostCard({
    super.key,
    required this.event,
    required this.plan,
    required this.podAssignments,
    required this.rotationAssignments,
    required this.preferences,
    this.participantProfiles = const [],
    this.now,
    this.onStartCountdown,
    this.onRevealRound,
    this.onResetReveal,
  });

  final Event event;
  final EventSuccessPlan plan;
  final List<EventSuccessAssignment> podAssignments;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<EventSuccessPreference> preferences;

  /// Names for the rotation run-of-show list (reveal-gated). Pairings stay
  /// masked as "Hidden until reveal" until the host releases each round.
  final List<PublicProfile> participantProfiles;
  final DateTime? now;
  final void Function(int roundIndex, int countdownSeconds)? onStartCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RevealTicker(
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
    final revealSet = _hostRevealSet();
    final assignments = revealSet.assignments;
    final roundCount = revealSet.roundCount;
    final nextRound = plan.nextRevealRoundIndex(
      roundCount: roundCount,
      now: referenceNow,
    );
    final activeRound = _safeRoundIndex(
      plan.activeRevealRoundIndex,
      roundCount,
    );
    final targetRound = plan.isRevealCountdownRunning(referenceNow)
        ? activeRound
        : nextRound ?? activeRound;
    final countdownSeconds = plan.structureConfig.revealCountdownSeconds;
    final allRevealed = plan.allRevealRoundsShown(
      roundCount: roundCount,
      now: referenceNow,
    );
    final isCountingDown = plan.isRevealCountdownRunning(referenceNow);
    final remainingSeconds = _remainingSeconds(plan, referenceNow);
    final headline = _hostHeadline(
      kind: revealSet.kind,
      isCountingDown: isCountingDown,
      allRevealed: allRevealed,
      targetRound: targetRound,
      roundCount: roundCount,
      remainingSeconds: remainingSeconds,
    );
    final startMutation = ref.watch(
      EventSuccessController.startRevealCountdownMutation,
    );
    final revealMutation = ref.watch(
      EventSuccessController.revealRoundMutation,
    );
    final resetMutation = ref.watch(EventSuccessController.resetRevealMutation);
    final hasPendingMutation =
        startMutation.isPending ||
        revealMutation.isPending ||
        resetMutation.isPending;
    final errorMutation = startMutation.hasError
        ? startMutation
        : revealMutation.hasError
        ? revealMutation
        : resetMutation.hasError
        ? resetMutation
        : null;

    return CatchSurface(
      clipBehavior: Clip.antiAlias,
      borderWidth: 0,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          t.ink,
          Color.lerp(t.ink, t.accent, 0.55)!,
          Color.lerp(t.primary, t.gold, 0.18)!,
        ],
      ),
      boxShadow: CatchElevation.raised,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: 'Synchronized partner reveal',
                tone: CatchBadgeTone.live,
                icon: CatchIcons.boltRounded,
                backgroundColor: t.surface.withValues(
                  alpha: CatchOpacity.warningFill,
                ),
                foregroundColor: t.surface,
              ),
              gapW8,
              CatchBadge(
                label: revealSet.kind.label,
                icon: revealSet.kind.icon,
                backgroundColor: t.surface.withValues(
                  alpha: CatchOpacity.subtleFill,
                ),
                foregroundColor: t.surface.withValues(
                  alpha: CatchOpacity.floatingControlFill,
                ),
                borderColor: t.surface.withValues(
                  alpha: CatchOpacity.photoScrimMedium,
                ),
              ),
              CatchBadge(
                label: roundCount == 0
                    ? 'No assignments'
                    : '${plan.revealedThroughRoundIndex(referenceNow) + 1}/$roundCount shown',
                backgroundColor: t.surface.withValues(
                  alpha: CatchOpacity.subtleFill,
                ),
                foregroundColor: t.surface.withValues(
                  alpha: CatchOpacity.floatingControlFill,
                ),
                borderColor: t.surface.withValues(
                  alpha: CatchOpacity.photoScrimMedium,
                ),
              ),
            ],
          ),
          gapH16,
          LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth <
                  ComponentBreakpoints.eventSuccessRevealHostCompactBreakpoint;
              final number = CountdownNumber(
                value: isCountingDown
                    ? '$remainingSeconds'
                    : allRevealed
                    ? 'OK'
                    : '${targetRound + 1}',
                caption: isCountingDown
                    ? 'seconds'
                    : allRevealed
                    ? 'revealed'
                    : 'next round',
              );
              final copy = RevealHostCopy(
                headline: headline,
                body: _hostBody(
                  kind: revealSet.kind,
                  assignments: assignments,
                  roundIndex: targetRound,
                  roundCount: roundCount,
                  allRevealed: allRevealed,
                ),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [number, gapH14, copy],
                );
              }
              return Row(
                children: [
                  number,
                  gapW16,
                  Expanded(child: copy),
                ],
              );
            },
          ),
          gapH14,
          RevealProgressBar(progress: plan.revealProgress(referenceNow)),
          if (roundCount > 0) ...[
            gapH14,
            if (revealSet.kind == EventSuccessRevealAssignmentKind.rotations)
              RevealRoundList(
                config: _rotationConfigLine(plan.structureConfig),
                roundCount: roundCount,
                revealedThrough: plan.revealedThroughRoundIndex(referenceNow),
                assignments: assignments,
                profilesByUid: {
                  for (final profile in participantProfiles)
                    profile.uid: profile,
                },
              )
            else
              RevealRoundRail(
                roundCount: roundCount,
                activeRoundIndex: targetRound,
                revealedThrough: plan.revealedThroughRoundIndex(referenceNow),
              ),
          ],
          if (errorMutation != null) ...[
            gapH10,
            Text(
              appErrorMessage(
                (errorMutation as MutationError).error,
                context: AppErrorContext.event,
              ),
              style: CatchTextStyles.supporting(context, color: t.surface),
            ),
          ],
          gapH16,
          HostRevealActions(
            eventId: event.id,
            roundCount: roundCount,
            nextRound: nextRound,
            activeRound: activeRound,
            countdownSeconds: countdownSeconds,
            isCountingDown: isCountingDown,
            allRevealed: allRevealed,
            isLoading: hasPendingMutation,
            onStartCountdown: onStartCountdown,
            onRevealRound: onRevealRound,
            onResetReveal: onResetReveal,
          ),
        ],
      ),
    );
  }

  _HostRevealSet _hostRevealSet() {
    final canUseRotations =
        plan.hasModule(EventSuccessModuleCatalog.guidedRotations.id) &&
        (rotationAssignments.isNotEmpty ||
            !plan.hasModule(EventSuccessModuleCatalog.microPods.id));
    final kind = canUseRotations
        ? EventSuccessRevealAssignmentKind.rotations
        : EventSuccessRevealAssignmentKind.microPods;
    final optedOutUids = preferences
        .where(
          (preference) => kind == EventSuccessRevealAssignmentKind.rotations
              ? preference.guidedRotationsOptedOut
              : preference.microPodsOptedOut,
        )
        .map((preference) => preference.uid)
        .toSet();
    final rawAssignments = kind == EventSuccessRevealAssignmentKind.rotations
        ? rotationAssignments
        : podAssignments;
    final activeAssignments = rawAssignments
        .where((assignment) => !optedOutUids.contains(assignment.uid))
        .toList(growable: false);
    final roundCount = kind == EventSuccessRevealAssignmentKind.rotations
        ? _maxRotationRoundCount(activeAssignments)
        : activeAssignments.isEmpty
        ? 0
        : 1;
    return _HostRevealSet(
      kind: kind,
      assignments: activeAssignments,
      roundCount: roundCount,
    );
  }
}
