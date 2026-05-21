import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EventSuccessRevealAssignmentKind {
  microPods,
  rotations;

  String get label => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => 'Pod reveal',
    EventSuccessRevealAssignmentKind.rotations => 'Rotation reveal',
  };

  String get assignmentNoun => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => 'pod',
    EventSuccessRevealAssignmentKind.rotations => 'rotation',
  };

  String get assignmentNounPlural => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => 'pods',
    EventSuccessRevealAssignmentKind.rotations => 'rotations',
  };

  IconData get icon => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => Icons.groups_2_outlined,
    EventSuccessRevealAssignmentKind.rotations => Icons.sync_alt_rounded,
  };
}

class EventSuccessLiveRevealHostCard extends ConsumerWidget {
  const EventSuccessLiveRevealHostCard({
    super.key,
    required this.event,
    required this.plan,
    required this.podAssignments,
    required this.rotationAssignments,
    required this.preferences,
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
  final DateTime? now;
  final void Function(int roundIndex, int countdownSeconds)? onStartCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;

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
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: 'Live reveal',
                tone: CatchBadgeTone.live,
                icon: Icons.bolt_rounded,
                backgroundColor: t.surface.withValues(alpha: 0.14),
                foregroundColor: t.surface,
              ),
              gapW8,
              CatchBadge(
                label: revealSet.kind.label,
                tone: CatchBadgeTone.neutral,
                icon: revealSet.kind.icon,
                backgroundColor: t.surface.withValues(alpha: 0.12),
                foregroundColor: t.surface.withValues(alpha: 0.88),
                borderColor: t.surface.withValues(alpha: 0.16),
              ),
              CatchBadge(
                label: roundCount == 0
                    ? 'No assignments'
                    : '${plan.revealedThroughRoundIndex(referenceNow) + 1}/$roundCount shown',
                tone: CatchBadgeTone.neutral,
                backgroundColor: t.surface.withValues(alpha: 0.12),
                foregroundColor: t.surface.withValues(alpha: 0.88),
                borderColor: t.surface.withValues(alpha: 0.16),
              ),
            ],
          ),
          gapH16,
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final number = _CountdownNumber(
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
              final copy = _RevealHostCopy(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  number,
                  gapW16,
                  Expanded(child: copy),
                ],
              );
            },
          ),
          gapH14,
          _RevealProgressBar(progress: plan.revealProgress(referenceNow)),
          if (roundCount > 0) ...[
            gapH14,
            _RevealRoundRail(
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
              style: CatchTextStyles.bodyS(context, color: t.surface),
            ),
          ],
          gapH16,
          _HostRevealActions(
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
    final roundCount = assigned == null
        ? 0
        : kind == EventSuccessRevealAssignmentKind.rotations
        ? assigned.rotationSlots.length
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
    final podVisible =
        assigned != null &&
        kind == EventSuccessRevealAssignmentKind.microPods &&
        plan.isRoundRevealed(0, referenceNow);
    final showAssignment = kind == EventSuccessRevealAssignmentKind.rotations
        ? visibleSlots.isNotEmpty
        : podVisible;
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(kind.icon, color: t.primary),
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
                        CatchBadge(
                          label: kind.label,
                          tone: CatchBadgeTone.live,
                          icon: Icons.bolt_rounded,
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
                    gapH10,
                    Text(
                      _attendeeTitle(
                        assigned: assigned,
                        showAssignment: showAssignment,
                        isCountingDown: isCountingDown,
                        remainingSeconds: _remainingSeconds(plan, referenceNow),
                      ),
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH4,
                    Text(
                      _attendeeSubtitle(
                        assigned: assigned,
                        showAssignment: showAssignment,
                        isCountingDown: isCountingDown,
                      ),
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (assigned != null && !optedOut) ...[
            gapH14,
            if (isCountingDown)
              _AttendeeCountdown(
                plan: plan,
                now: referenceNow,
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
          gapH12,
          CatchButton(
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
      return 'Clue: ${assignment.label} is ready, but the names unlock together.';
    }
    final slot = _slotForRound(assignment, activeRound);
    if (slot == null) {
      return 'Clue: the next pairing is ready.';
    }
    return 'Clue: ${_compatibilityLabel(slot.compatibility).toLowerCase()} signal.';
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

class _HostRevealActions extends ConsumerWidget {
  const _HostRevealActions({
    required this.eventId,
    required this.roundCount,
    required this.nextRound,
    required this.activeRound,
    required this.countdownSeconds,
    required this.isCountingDown,
    required this.allRevealed,
    required this.isLoading,
    this.onStartCountdown,
    this.onRevealRound,
    this.onResetReveal,
  });

  final String eventId;
  final int roundCount;
  final int? nextRound;
  final int activeRound;
  final int countdownSeconds;
  final bool isCountingDown;
  final bool allRevealed;
  final bool isLoading;
  final void Function(int roundIndex, int countdownSeconds)? onStartCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (roundCount == 0) {
      return CatchButton(
        label: 'Generate assignments first',
        icon: const Icon(Icons.auto_awesome_outlined),
        onPressed: null,
        fullWidth: true,
      );
    }
    if (isCountingDown) {
      return Row(
        children: [
          Expanded(
            child: CatchButton(
              label: 'Reveal now',
              icon: const Icon(Icons.visibility_outlined),
              isLoading: isLoading,
              onPressed: isLoading ? null : () => _reveal(ref, activeRound),
              fullWidth: true,
            ),
          ),
          gapW10,
          Expanded(
            child: CatchButton(
              label: 'Reset',
              icon: const Icon(Icons.restart_alt_rounded),
              variant: CatchButtonVariant.secondary,
              isLoading: isLoading,
              onPressed: isLoading ? null : () => _reset(ref),
              fullWidth: true,
            ),
          ),
        ],
      );
    }
    if (allRevealed) {
      return CatchButton(
        label: 'Reset reveal',
        icon: const Icon(Icons.restart_alt_rounded),
        variant: CatchButtonVariant.secondary,
        isLoading: isLoading,
        onPressed: isLoading ? null : () => _reset(ref),
        fullWidth: true,
      );
    }
    final roundIndex = nextRound ?? 0;
    return Row(
      children: [
        Expanded(
          child: CatchButton(
            label: countdownSeconds == 0
                ? 'Reveal round ${roundIndex + 1}'
                : 'Drop ${countdownSeconds}s countdown',
            icon: const Icon(Icons.timer_outlined),
            isLoading: isLoading,
            onPressed: isLoading
                ? null
                : () {
                    if (countdownSeconds == 0) {
                      _reveal(ref, roundIndex);
                    } else {
                      _start(ref, roundIndex);
                    }
                  },
            fullWidth: true,
          ),
        ),
        gapW10,
        Expanded(
          child: CatchButton(
            label: 'Reveal now',
            icon: const Icon(Icons.visibility_outlined),
            variant: CatchButtonVariant.secondary,
            isLoading: isLoading,
            onPressed: isLoading ? null : () => _reveal(ref, roundIndex),
            fullWidth: true,
          ),
        ),
      ],
    );
  }

  void _start(WidgetRef ref, int roundIndex) {
    final fixtureAction = onStartCountdown;
    if (fixtureAction != null) {
      fixtureAction(roundIndex, countdownSeconds);
      return;
    }
    EventSuccessController.startRevealCountdownMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .startRevealCountdown(
            eventId: eventId,
            roundIndex: roundIndex,
            countdownSeconds: countdownSeconds,
          ),
    );
  }

  void _reveal(WidgetRef ref, int roundIndex) {
    final fixtureAction = onRevealRound;
    if (fixtureAction != null) {
      fixtureAction(roundIndex);
      return;
    }
    EventSuccessController.revealRoundMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .revealRound(eventId: eventId, roundIndex: roundIndex),
    );
  }

  void _reset(WidgetRef ref) {
    final fixtureAction = onResetReveal;
    if (fixtureAction != null) {
      fixtureAction();
      return;
    }
    EventSuccessController.resetRevealMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .resetReveal(eventId: eventId),
    );
  }
}

class _CountdownNumber extends StatelessWidget {
  const _CountdownNumber({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 112),
      child: CatchSurface(
        backgroundColor: t.surface.withValues(alpha: 0.12),
        borderColor: t.surface.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s4,
          vertical: CatchSpacing.s3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: CatchMotion.fast,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                value,
                key: ValueKey(value),
                style: CatchTextStyles.displayL(
                  context,
                  color: t.surface,
                ).copyWith(fontSize: 48, height: 1, letterSpacing: 0),
              ),
            ),
            gapH4,
            Text(
              caption,
              style: CatchTextStyles.labelS(
                context,
                color: t.surface.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevealHostCopy extends StatelessWidget {
  const _RevealHostCopy({required this.headline, required this.body});

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: CatchTextStyles.titleL(context, color: t.surface),
        ),
        gapH6,
        Text(
          body,
          style: CatchTextStyles.bodyS(
            context,
            color: t.surface.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _RevealProgressBar extends StatelessWidget {
  const _RevealProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: LinearProgressIndicator(
        minHeight: 7,
        value: progress.clamp(0, 1).toDouble(),
        backgroundColor: t.surface.withValues(alpha: 0.14),
        valueColor: AlwaysStoppedAnimation<Color>(t.gold),
      ),
    );
  }
}

class _AttendeeCountdown extends StatelessWidget {
  const _AttendeeCountdown({
    required this.plan,
    required this.now,
    required this.clue,
  });

  final EventSuccessPlan plan;
  final DateTime now;
  final String clue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Column(
              children: [
                Text(
                  '${_remainingSeconds(plan, now)}',
                  style: CatchTextStyles.displayM(context, color: t.primary),
                ),
                Text(
                  'seconds',
                  style: CatchTextStyles.labelS(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RevealProgressBar(progress: plan.revealProgress(now)),
                gapH8,
                Text(
                  clue,
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

class _WaitingRevealCue extends StatelessWidget {
  const _WaitingRevealCue({required this.kind});

  final EventSuccessRevealAssignmentKind kind;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        children: [
          Icon(Icons.lock_clock_rounded, color: t.ink3),
          gapW10,
          Expanded(
            child: Text(
              'The host controls the ${kind.assignmentNoun} reveal from live mode.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisiblePodAssignment extends StatelessWidget {
  const _VisiblePodAssignment({
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
  });

  final EventSuccessAssignment assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        CatchBadge(
          label: '${assignment.peerUids.length + 1} people',
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
    );
  }
}

class _VisibleRotationSlots extends StatelessWidget {
  const _VisibleRotationSlots({
    required this.slots,
    required this.profilesByUid,
    required this.peersLoading,
  });

  final List<EventSuccessRotationSlot> slots;
  final Map<String, PublicProfile> profilesByUid;
  final bool peersLoading;

  @override
  Widget build(BuildContext context) {
    if (peersLoading) {
      return const CatchBadge(
        label: 'Loading partners',
        tone: CatchBadgeTone.neutral,
        icon: Icons.hourglass_empty_rounded,
      );
    }
    return Column(
      children: [
        for (final slot in slots)
          _RevealSlotRow(
            slot: slot,
            peerName: profilesByUid[slot.peerUid]?.name ?? 'Partner',
          ),
      ],
    );
  }
}

class _RevealSlotRow extends StatelessWidget {
  const _RevealSlotRow({required this.slot, required this.peerName});

  final EventSuccessRotationSlot slot;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange =
        '${TimeOfDay.fromDateTime(slot.startsAt).format(context)}-'
        '${TimeOfDay.fromDateTime(slot.endsAt).format(context)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: CatchSurface(
        tone: CatchSurfaceTone.raised,
        borderColor: t.line,
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          children: [
            CatchBadge(
              label: slot.label,
              tone: _isStrongCompatibilitySignal(slot.compatibility)
                  ? CatchBadgeTone.success
                  : CatchBadgeTone.neutral,
            ),
            gapW8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeRange · $peerName',
                    style: CatchTextStyles.titleS(context),
                  ),
                  gapH2,
                  Text(
                    _compatibilityExplanation(slot.compatibility),
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevealRoundRail extends StatelessWidget {
  const _RevealRoundRail({
    required this.roundCount,
    required this.activeRoundIndex,
    required this.revealedThrough,
    this.foreground,
  });

  final int roundCount;
  final int activeRoundIndex;
  final int revealedThrough;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = foreground ?? t.surface;
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (var index = 0; index < roundCount; index++)
          CatchBadge(
            label: 'R${index + 1}',
            tone: index <= revealedThrough
                ? CatchBadgeTone.success
                : index == activeRoundIndex
                ? CatchBadgeTone.warning
                : CatchBadgeTone.neutral,
            backgroundColor: foreground == null
                ? color.withValues(
                    alpha: index <= revealedThrough ? 0.18 : 0.10,
                  )
                : null,
            foregroundColor: foreground == null ? color : null,
            borderColor: foreground == null
                ? color.withValues(alpha: 0.14)
                : null,
          ),
      ],
    );
  }
}

class _RevealTicker extends StatefulWidget {
  const _RevealTicker({required this.enabled, required this.builder});

  final bool enabled;
  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<_RevealTicker> createState() => _RevealTickerState();
}

class _RevealTickerState extends State<_RevealTicker> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _RevealTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _syncTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    _now = DateTime.now();
    if (!widget.enabled) return;
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }
}

final class _HostRevealSet {
  const _HostRevealSet({
    required this.kind,
    required this.assignments,
    required this.roundCount,
  });

  final EventSuccessRevealAssignmentKind kind;
  final List<EventSuccessAssignment> assignments;
  final int roundCount;
}

String _hostHeadline({
  required EventSuccessRevealAssignmentKind kind,
  required bool isCountingDown,
  required bool allRevealed,
  required int targetRound,
  required int roundCount,
  required int remainingSeconds,
}) {
  if (roundCount == 0) return 'Build the queue before the reveal';
  if (isCountingDown) {
    return 'Round ${targetRound + 1} opens in ${remainingSeconds}s';
  }
  if (allRevealed) return 'Every reveal is live';
  return 'Create the next room-wide beat';
}

String _hostBody({
  required EventSuccessRevealAssignmentKind kind,
  required List<EventSuccessAssignment> assignments,
  required int roundIndex,
  required int roundCount,
  required bool allRevealed,
}) {
  if (roundCount == 0) {
    return 'Generate ${kind.assignmentNounPlural} first, then drop a countdown so everyone gets the assignment together.';
  }
  if (allRevealed) {
    return 'All ${kind.assignmentNounPlural} have been released. Reset only if the host wants to rehearse or restart the live flow.';
  }
  if (kind == EventSuccessRevealAssignmentKind.microPods) {
    final groups = _assignmentCountsByLabel(assignments);
    return '${assignments.length} attendees across ${groups.length} ${kind.assignmentNounPlural}; reveal names once the host has the room.';
  }
  final roundPairCount = _uniquePairCountForRound(assignments, roundIndex);
  final mutualCount = _strongCompatibilityPairCount(assignments, roundIndex);
  final pairingWord = roundPairCount == 1 ? 'pairing' : 'pairings';
  final verb = roundPairCount == 1 ? 'is' : 'are';
  final signalVerb = mutualCount == 1 ? 'carries' : 'carry';
  return '$roundPairCount $pairingWord $verb queued for round ${roundIndex + 1}. $mutualCount $signalVerb a stronger compatibility signal.';
}

int _remainingSeconds(EventSuccessPlan plan, DateTime now) =>
    (plan.revealRemaining(now).inMilliseconds / 1000)
        .ceil()
        .clamp(0, 60)
        .toInt();

int _safeRoundIndex(int value, int roundCount) {
  if (roundCount <= 0) return 0;
  return value.clamp(0, roundCount - 1).toInt();
}

int _maxRotationRoundCount(List<EventSuccessAssignment> assignments) {
  var maxRounds = 0;
  for (final assignment in assignments) {
    maxRounds = math.max(maxRounds, assignment.rotationSlots.length);
  }
  return maxRounds;
}

Map<String, int> _assignmentCountsByLabel(
  List<EventSuccessAssignment> assignments,
) {
  final counts = <String, int>{};
  for (final assignment in assignments) {
    counts.update(assignment.label, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}

int _uniquePairCountForRound(
  List<EventSuccessAssignment> assignments,
  int roundIndex,
) {
  final pairs = <String>{};
  for (final assignment in assignments) {
    for (final slot in assignment.rotationSlots) {
      if (slot.roundIndex != roundIndex) continue;
      final uids = [assignment.uid, slot.peerUid]..sort();
      pairs.add(uids.join('__'));
    }
  }
  return pairs.length;
}

int _strongCompatibilityPairCount(
  List<EventSuccessAssignment> assignments,
  int roundIndex,
) {
  final pairs = <String>{};
  for (final assignment in assignments) {
    for (final slot in assignment.rotationSlots) {
      if (slot.roundIndex != roundIndex ||
          !_isStrongCompatibilitySignal(slot.compatibility)) {
        continue;
      }
      final uids = [assignment.uid, slot.peerUid]..sort();
      pairs.add(uids.join('__'));
    }
  }
  return pairs.length;
}

EventSuccessRotationSlot? _slotForRound(
  EventSuccessAssignment assignment,
  int roundIndex,
) {
  for (final slot in assignment.rotationSlots) {
    if (slot.roundIndex == roundIndex) return slot;
  }
  return null;
}

String _compatibilityLabel(String value) => switch (value) {
  'mutual_interest' => 'Mutual interest',
  'questionnaire_match' => 'Shared clue',
  'balanced' => 'Balanced',
  'social' => 'Social fit',
  _ => 'Host fit',
};

String _compatibilityExplanation(String value) => switch (value) {
  'mutual_interest' =>
    'A stronger two-way compatibility signal for this round.',
  'questionnaire_match' =>
    'You share an event answer that can make this round easier to start.',
  'balanced' => 'Balanced by the host for variety and comfort.',
  'social' => 'A lightweight social pairing for this format.',
  _ => 'Adjusted by the host for the live room.',
};

bool _isStrongCompatibilitySignal(String value) =>
    value == 'mutual_interest' || value == 'questionnaire_match';

String _skipLabel(EventSuccessRevealAssignmentKind kind) =>
    kind == EventSuccessRevealAssignmentKind.rotations
    ? 'Skip rotations'
    : 'Skip micro-pods';

String _joinLabel(EventSuccessRevealAssignmentKind kind) =>
    kind == EventSuccessRevealAssignmentKind.rotations
    ? 'Join rotations'
    : 'Join micro-pods';

extension on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
