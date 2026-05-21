part of '../event_success_host_screen.dart';

class _MicroPodsHostCard extends ConsumerWidget {
  const _MicroPodsHostCard({
    required this.eventId,
    required this.assignments,
    required this.preferences,
    this.onGenerate,
  });

  final String eventId;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessPreference> preferences;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(
      EventSuccessController.generateMicroPodsMutation,
    );
    final optedOutUids = preferences
        .where((preference) => preference.microPodsOptedOut)
        .map((preference) => preference.uid)
        .toSet();
    final optedOutCount = optedOutUids.length;
    final activeAssignments = assignments
        .where((assignment) => !optedOutUids.contains(assignment.uid))
        .toList(growable: false);
    final staleAssignmentCount = assignments.length - activeAssignments.length;
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_2_outlined,
                color: CatchTokens.of(context).primary,
              ),
              gapW10,
              Expanded(
                child: Text(
                  'Micro-pods',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: '${activeAssignments.length} assigned',
                tone: activeAssignments.isEmpty
                    ? CatchBadgeTone.warning
                    : CatchBadgeTone.success,
              ),
              if (optedOutCount > 0) ...[
                gapW8,
                CatchBadge(
                  label: '$optedOutCount opted out',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.visibility_off_outlined,
                ),
              ],
            ],
          ),
          gapH8,
          Text(
            staleAssignmentCount > 0
                ? 'Regenerate to remove opted-out attendee cards from the current pod set.'
                : optedOutCount > 0
                ? 'Generate attendee pod cards from the roster, excluding opted-out attendees.'
                : 'Generate attendee pod cards from the current booked and checked-in roster.',
            style: CatchTextStyles.bodyS(context),
          ),
          if (activeAssignments.isNotEmpty) ...[
            gapH12,
            _PodGroupSummary(assignments: activeAssignments),
          ],
          if (mutation.hasError) ...[
            gapH8,
            _ErrorText(error: (mutation as MutationError).error),
          ],
          gapH12,
          CatchButton(
            key: const ValueKey('eventSuccessGenerateMicroPodsButton'),
            label: assignments.isEmpty ? 'Generate micro-pods' : 'Regenerate',
            icon: const Icon(Icons.auto_awesome_outlined),
            isLoading: onGenerate == null && mutation.isPending,
            onPressed: mutation.isPending
                ? null
                : onGenerate ??
                      () =>
                          EventSuccessController.generateMicroPodsMutation.run(
                            ref,
                            (tx) => tx
                                .get(eventSuccessControllerProvider.notifier)
                                .generateMicroPods(eventId: eventId),
                          ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _RotationsHostCard extends ConsumerWidget {
  const _RotationsHostCard({
    required this.event,
    required this.rotationIntervalMinutes,
    required this.assignments,
    required this.participantProfiles,
    required this.preferences,
    this.onGenerate,
    this.onOverride,
  });

  final Event event;
  final int rotationIntervalMinutes;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> participantProfiles;
  final List<EventSuccessPreference> preferences;
  final VoidCallback? onGenerate;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>? onOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(
      EventSuccessController.generateGuidedRotationsMutation,
    );
    final optedOutUids = preferences
        .where((preference) => preference.guidedRotationsOptedOut)
        .map((preference) => preference.uid)
        .toSet();
    final activeAssignments = assignments
        .where((assignment) => !optedOutUids.contains(assignment.uid))
        .toList(growable: false);
    final roundCount = _maxRotationRoundCount(activeAssignments);
    final optedOutCount = optedOutUids.length;
    final staleAssignmentCount = assignments.length - activeAssignments.length;
    final hostEdited = activeAssignments.any(
      (assignment) => assignment.source == 'host_override_v1',
    );
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync_alt_rounded,
                color: CatchTokens.of(context).primary,
              ),
              gapW10,
              Expanded(
                child: Text(
                  'Guided rotations',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: '$roundCount rounds',
                tone: roundCount == 0
                    ? CatchBadgeTone.warning
                    : CatchBadgeTone.success,
              ),
              if (optedOutCount > 0) ...[
                gapW8,
                CatchBadge(
                  label: '$optedOutCount opted out',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.visibility_off_outlined,
                ),
              ],
              if (hostEdited) ...[
                gapW8,
                const CatchBadge(
                  label: 'Host edited',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.edit_outlined,
                ),
              ],
            ],
          ),
          gapH8,
          Text(
            staleAssignmentCount > 0
                ? 'Regenerate to remove opted-out attendees from timed rotations.'
                : 'Generate pairings from event duration, saved cadence, checked-in participants, and mutual gender interest.',
            style: CatchTextStyles.bodyS(context),
          ),
          if (activeAssignments.isNotEmpty) ...[
            gapH12,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchBadge(
                  label: '${activeAssignments.length} assigned',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.people_outline_rounded,
                ),
                CatchBadge(
                  label:
                      '${_eventRotationCapacity(event, rotationIntervalMinutes)} possible',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ],
          if (mutation.hasError) ...[
            gapH8,
            _ErrorText(error: (mutation as MutationError).error),
          ],
          gapH12,
          if (activeAssignments.isEmpty)
            CatchButton(
              key: const ValueKey('eventSuccessGenerateRotationsButton'),
              label: 'Generate rotations',
              icon: const Icon(Icons.auto_awesome_outlined),
              isLoading: onGenerate == null && mutation.isPending,
              onPressed: mutation.isPending
                  ? null
                  : onGenerate ??
                        () => EventSuccessController
                            .generateGuidedRotationsMutation
                            .run(
                              ref,
                              (tx) => tx
                                  .get(eventSuccessControllerProvider.notifier)
                                  .generateGuidedRotations(eventId: event.id),
                            ),
              fullWidth: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: CatchButton(
                    key: const ValueKey('eventSuccessGenerateRotationsButton'),
                    label: 'Regenerate',
                    icon: const Icon(Icons.auto_awesome_outlined),
                    variant: CatchButtonVariant.secondary,
                    isLoading: onGenerate == null && mutation.isPending,
                    onPressed: mutation.isPending
                        ? null
                        : onGenerate ??
                              () => EventSuccessController
                                  .generateGuidedRotationsMutation
                                  .run(
                                    ref,
                                    (tx) => tx
                                        .get(
                                          eventSuccessControllerProvider
                                              .notifier,
                                        )
                                        .generateGuidedRotations(
                                          eventId: event.id,
                                        ),
                                  ),
                    fullWidth: true,
                  ),
                ),
                gapW10,
                Expanded(
                  child: CatchButton(
                    label: 'Edit rotations',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showRotationOverrideSheet(
                      context: context,
                      event: event,
                      assignments: activeAssignments,
                      participantProfiles: participantProfiles,
                      onOverride: onOverride,
                    ),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

Future<void> _showRotationOverrideSheet({
  required BuildContext context,
  required Event event,
  required List<EventSuccessAssignment> assignments,
  required List<PublicProfile> participantProfiles,
  ValueChanged<List<EventSuccessRotationOverrideRound>>? onOverride,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _RotationOverrideSheet(
      event: event,
      assignments: assignments,
      participantProfiles: participantProfiles,
      onOverride: onOverride,
    ),
  );
}

class _RotationOverrideSheet extends ConsumerStatefulWidget {
  const _RotationOverrideSheet({
    required this.event,
    required this.assignments,
    required this.participantProfiles,
    this.onOverride,
  });

  final Event event;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> participantProfiles;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>? onOverride;

  @override
  ConsumerState<_RotationOverrideSheet> createState() =>
      _RotationOverrideSheetState();
}

class _RotationOverrideSheetState
    extends ConsumerState<_RotationOverrideSheet> {
  late final List<String> _participantUids = _rotationParticipantUids(
    widget.assignments,
  );
  late final Map<String, String> _participantLabels = {
    for (final profile in widget.participantProfiles) profile.uid: profile.name,
  };
  late final List<_RotationOverrideRoundDraft> _rounds =
      _rotationRoundDraftsFromAssignments(widget.assignments);

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(
      EventSuccessController.overrideGuidedRotationsMutation,
    );
    final validationError = _validationError;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.68;
    return CatchBottomSheetScaffold(
      title: 'Edit rotations',
      subtitle: 'Host override',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mutation.hasError) ...[
            _ErrorText(error: (mutation as MutationError).error),
            gapH8,
          ],
          if (validationError != null) ...[
            Text(
              validationError,
              style: CatchTextStyles.bodyS(
                context,
                color: CatchTokens.of(context).danger,
              ),
            ),
            gapH8,
          ],
          CatchButton(
            label: 'Save overrides',
            icon: const Icon(Icons.check_rounded),
            isLoading: widget.onOverride == null && mutation.isPending,
            onPressed: mutation.isPending || validationError != null
                ? null
                : () => _saveOverrides(context),
            fullWidth: true,
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _rounds.length,
          separatorBuilder: (_, _) => gapH12,
          itemBuilder: (context, index) {
            final round = _rounds[index];
            return _RotationOverrideRoundEditor(
              round: round,
              participantUids: _participantUids,
              participantLabel: _participantLabel,
              onChanged: () => setState(() {}),
              onAddPair: () => setState(() => _addPair(round)),
              onRemovePair: (pair) =>
                  setState(() => round.pairings.remove(pair)),
            );
          },
        ),
      ),
    );
  }

  String _participantLabel(String uid) => _participantLabels[uid] ?? uid;

  String? get _validationError {
    if (_rounds.every((round) => round.pairings.isEmpty)) {
      return 'Add at least one pair.';
    }
    for (final round in _rounds) {
      final usedInRound = <String>{};
      for (final pair in round.pairings) {
        final uidA = pair.uidA;
        final uidB = pair.uidB;
        if (uidA == null || uidB == null) {
          return 'Choose both attendees for every pair.';
        }
        if (uidA == uidB) {
          return 'Choose two different attendees.';
        }
        if (!usedInRound.add(uidA) || !usedInRound.add(uidB)) {
          return 'Each attendee can appear once per round.';
        }
      }
    }
    return null;
  }

  void _addPair(_RotationOverrideRoundDraft round) {
    final used = round.pairings
        .expand((pair) => [pair.uidA, pair.uidB])
        .whereType<String>()
        .toSet();
    final available = _participantUids
        .where((uid) => !used.contains(uid))
        .toList(growable: false);
    round.pairings.add(
      _RotationOverridePairDraft(
        uidA: available.isEmpty ? null : available.first,
        uidB: available.length < 2 ? null : available[1],
      ),
    );
  }

  void _saveOverrides(BuildContext context) {
    final overrideRounds = [
      for (final round in _rounds)
        EventSuccessRotationOverrideRound(
          roundIndex: round.roundIndex,
          pairings: [
            for (final pair in round.pairings)
              EventSuccessRotationOverridePair(
                uidA: pair.uidA!,
                uidB: pair.uidB!,
              ),
          ],
        ),
    ];
    final fixtureOverride = widget.onOverride;
    if (fixtureOverride != null) {
      fixtureOverride(overrideRounds);
      Navigator.of(context).pop();
      return;
    }
    EventSuccessController.overrideGuidedRotationsMutation.run(ref, (tx) async {
      await tx
          .get(eventSuccessControllerProvider.notifier)
          .overrideGuidedRotations(
            eventId: widget.event.id,
            rounds: overrideRounds,
          );
      if (context.mounted) Navigator.of(context).pop();
    });
  }
}

class _RotationOverrideRoundEditor extends StatelessWidget {
  const _RotationOverrideRoundEditor({
    required this.round,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onAddPair,
    required this.onRemovePair,
  });

  final _RotationOverrideRoundDraft round;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onAddPair;
  final ValueChanged<_RotationOverridePairDraft> onRemovePair;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Round ${round.roundIndex + 1}',
                  style: CatchTextStyles.titleS(context),
                ),
              ),
              CatchButton(
                label: 'Add pair',
                icon: const Icon(Icons.add_rounded),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
                onPressed: onAddPair,
              ),
            ],
          ),
          gapH10,
          if (round.pairings.isEmpty)
            Text(
              'No pairs in this round.',
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            )
          else
            for (final pair in round.pairings) ...[
              _RotationOverridePairEditor(
                pair: pair,
                participantUids: participantUids,
                participantLabel: participantLabel,
                onChanged: onChanged,
                onRemove: () => onRemovePair(pair),
              ),
              if (pair != round.pairings.last) gapH8,
            ],
        ],
      ),
    );
  }
}

class _RotationOverridePairEditor extends StatelessWidget {
  const _RotationOverridePairEditor({
    required this.pair,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onRemove,
  });

  final _RotationOverridePairDraft pair;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CatchSelectMenu<String>(
            values: participantUids,
            value: pair.uidA,
            itemLabel: participantLabel,
            hintText: 'Attendee',
            semanticLabel: 'First rotation attendee',
            onChanged: (value) {
              pair.uidA = value;
              onChanged();
            },
          ),
        ),
        gapW8,
        Expanded(
          child: CatchSelectMenu<String>(
            values: participantUids,
            value: pair.uidB,
            itemLabel: participantLabel,
            hintText: 'Partner',
            semanticLabel: 'Second rotation attendee',
            onChanged: (value) {
              pair.uidB = value;
              onChanged();
            },
          ),
        ),
        IconButton(
          tooltip: 'Remove pair',
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _PodGroupSummary extends StatelessWidget {
  const _PodGroupSummary({required this.assignments});

  final List<EventSuccessAssignment> assignments;

  @override
  Widget build(BuildContext context) {
    final groups = _assignmentCountsByLabel(assignments);
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final entry in groups.entries)
          CatchBadge(
            label: '${entry.key} · ${entry.value} assigned',
            tone: CatchBadgeTone.neutral,
            icon: Icons.group_outlined,
          ),
      ],
    );
  }
}

Map<String, int> _assignmentCountsByLabel(
  List<EventSuccessAssignment> assignments,
) {
  final counts = <String, int>{};
  for (final assignment in assignments) {
    counts.update(assignment.label, (value) => value + 1, ifAbsent: () => 1);
  }
  return Map.fromEntries(
    counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

List<String> _rotationParticipantUids(
  List<EventSuccessAssignment> assignments,
) {
  final uids = <String>{};
  for (final assignment in assignments) {
    uids.add(assignment.uid);
    uids.addAll(assignment.peerUids);
    for (final slot in assignment.rotationSlots) {
      uids.add(slot.peerUid);
    }
  }
  return uids.toList()..sort();
}

List<String> _wingmanRequestProfileUids(
  List<EventSuccessWingmanRequest> requests,
) {
  final uids = <String>{};
  for (final request in requests) {
    if (!request.isActive) continue;
    uids
      ..add(request.requesterUid)
      ..add(request.targetUid);
  }
  return uids.toList()..sort();
}

List<_RotationOverrideRoundDraft> _rotationRoundDraftsFromAssignments(
  List<EventSuccessAssignment> assignments,
) {
  final pairsByRound = <int, Map<String, _RotationOverridePairDraft>>{};
  for (final assignment in assignments) {
    for (final slot in assignment.rotationSlots) {
      final pairUids = [assignment.uid, slot.peerUid]..sort();
      final key = pairUids.join('__');
      pairsByRound
          .putIfAbsent(slot.roundIndex, () => {})
          .putIfAbsent(
            key,
            () => _RotationOverridePairDraft(
              uidA: pairUids.first,
              uidB: pairUids.last,
            ),
          );
    }
  }
  final entries = pairsByRound.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final entry in entries)
      _RotationOverrideRoundDraft(
        roundIndex: entry.key,
        pairings: entry.value.values.toList(),
      ),
  ];
}

final class _RotationOverrideRoundDraft {
  _RotationOverrideRoundDraft({
    required this.roundIndex,
    required this.pairings,
  });

  final int roundIndex;
  final List<_RotationOverridePairDraft> pairings;
}

final class _RotationOverridePairDraft {
  _RotationOverridePairDraft({required this.uidA, required this.uidB});

  String? uidA;
  String? uidB;
}

int _maxRotationRoundCount(List<EventSuccessAssignment> assignments) {
  var maxRounds = 0;
  for (final assignment in assignments) {
    maxRounds = math.max(maxRounds, assignment.rotationSlots.length);
  }
  return maxRounds;
}

int _eventRotationCapacity(Event event, int rotationIntervalMinutes) {
  final durationMinutes = event.endTime.difference(event.startTime).inMinutes;
  return math.max(0, durationMinutes ~/ rotationIntervalMinutes);
}
