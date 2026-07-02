part of '../event_success_host_screen.dart';

class MicroPodsHostCard extends StatelessWidget {
  const MicroPodsHostCard({
    super.key,
    required this.event,
    required this.assignments,
    required this.participantProfiles,
    required this.preferences,
    required this.actionState,
    this.onGenerate,
    this.onOverride,
  });

  final Event event;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> participantProfiles;
  final List<EventSuccessPreference> preferences;
  final EventSuccessAssignmentGenerationActionState actionState;
  final Future<void> Function()? onGenerate;
  final ValueChanged<List<EventSuccessGroupOverrideRound>>? onOverride;

  @override
  Widget build(BuildContext context) {
    final optedOutUids = preferences
        .where((preference) => preference.microPodsOptedOut)
        .map((preference) => preference.uid)
        .toSet();
    final optedOutCount = optedOutUids.length;
    final activeAssignments = assignments
        .where((assignment) => !optedOutUids.contains(assignment.uid))
        .toList(growable: false);
    final staleAssignmentCount = assignments.length - activeAssignments.length;
    final hostEdited = activeAssignments.any(
      (assignment) => assignment.source == 'host_override_v1',
    );
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CatchIcons.groups2Outlined,
                color: CatchTokens.of(context).primary,
              ),
              gapW10,
              Expanded(
                child: Text(
                  'Small starter groups',
                  style: CatchTextStyles.sectionTitle(context),
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
                  icon: CatchIcons.visibilityOffOutlined,
                ),
              ],
              if (hostEdited) ...[
                gapW8,
                CatchBadge(label: 'Host edited', icon: CatchIcons.editOutlined),
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
            style: CatchTextStyles.supporting(context),
          ),
          if (activeAssignments.isNotEmpty) ...[
            gapH12,
            PodGroupSummary(assignments: activeAssignments),
            gapH10,
            AssignmentReasonSummary(assignments: activeAssignments),
          ],
          if (actionState.error != null) ...[
            gapH8,
            CatchErrorBanner.fromError(
              actionState.error!,
              context: AppErrorContext.event,
            ),
          ],
          gapH12,
          if (activeAssignments.isEmpty)
            CatchButton(
              key: const ValueKey('eventSuccessGenerateMicroPodsButton'),
              label: 'Generate micro-pods',
              icon: Icon(CatchIcons.autoAwesomeOutlined),
              isLoading: actionState.isGenerating,
              onPressed: actionState.isGenerating || onGenerate == null
                  ? null
                  : () => unawaited(onGenerate!()),
              fullWidth: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: CatchButton(
                    key: const ValueKey('eventSuccessGenerateMicroPodsButton'),
                    label: 'Regenerate',
                    icon: Icon(CatchIcons.autoAwesomeOutlined),
                    variant: CatchButtonVariant.secondary,
                    isLoading: actionState.isGenerating,
                    onPressed: actionState.isGenerating || onGenerate == null
                        ? null
                        : () => unawaited(onGenerate!()),
                    fullWidth: true,
                  ),
                ),
                gapW10,
                Expanded(
                  child: CatchButton(
                    label: 'Edit groups',
                    icon: Icon(CatchIcons.editOutlined),
                    onPressed: () => _showGroupOverrideSheet(
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

Future<void> _showGroupOverrideSheet({
  required BuildContext context,
  required Event event,
  required List<EventSuccessAssignment> assignments,
  required List<PublicProfile> participantProfiles,
  ValueChanged<List<EventSuccessGroupOverrideRound>>? onOverride,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => GroupOverrideSheet(
      event: event,
      assignments: assignments,
      participantProfiles: participantProfiles,
      onOverride: onOverride,
    ),
  );
}

class GroupOverrideSheet extends ConsumerStatefulWidget {
  const GroupOverrideSheet({
    super.key,
    required this.event,
    required this.assignments,
    required this.participantProfiles,
    this.onOverride,
  });

  final Event event;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> participantProfiles;
  final ValueChanged<List<EventSuccessGroupOverrideRound>>? onOverride;

  @override
  ConsumerState<GroupOverrideSheet> createState() => _GroupOverrideSheetState();
}

class _GroupOverrideSheetState extends ConsumerState<GroupOverrideSheet> {
  late final List<String> _participantUids = _rotationParticipantUids(
    widget.assignments,
  );
  late final Map<String, String> _participantLabels = {
    for (final profile in widget.participantProfiles) profile.uid: profile.name,
  };
  late final List<GroupOverrideRoundDraft> _rounds =
      _groupRoundDraftsFromAssignments(widget.assignments);

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(
      EventSuccessController.overrideGroupAssignmentsMutation,
    );
    final validationError = _validationError;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.68;
    return CatchBottomSheetScaffold(
      title: 'Edit groups',
      subtitle: 'Host override',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mutation.hasError) ...[
            CatchErrorBanner.fromError(
              (mutation as MutationError).error,
              context: AppErrorContext.event,
            ),
            gapH8,
          ],
          if (validationError != null) ...[
            Text(
              validationError,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).danger,
              ),
            ),
            gapH8,
          ],
          CatchButton(
            label: 'Save overrides',
            icon: Icon(CatchIcons.checkRounded),
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
            return GroupOverrideRoundEditor(
              round: round,
              participantUids: _participantUids,
              participantLabel: _participantLabel,
              onChanged: () => setState(() {}),
              onAddGroup: () => setState(() => _addGroup(round)),
              onRemoveGroup: (group) =>
                  setState(() => round.groups.remove(group)),
              onAddMember: (group) => setState(() => _addMember(round, group)),
              onRemoveMember: (group, member) =>
                  setState(() => group.memberUids.remove(member)),
            );
          },
        ),
      ),
    );
  }

  String _participantLabel(String uid) => _participantLabels[uid] ?? uid;

  String? get _validationError {
    if (_rounds.every((round) => round.groups.isEmpty)) {
      return 'Add at least one group.';
    }
    for (final round in _rounds) {
      final usedInRound = <String>{};
      for (final group in round.groups) {
        if (group.label.trim().isEmpty) {
          return 'Name every group.';
        }
        if (group.memberUids.isEmpty) {
          return 'Add at least one attendee to every group.';
        }
        for (final memberUid in group.memberUids) {
          if (memberUid == null) {
            return 'Choose every attendee slot.';
          }
          if (!usedInRound.add(memberUid)) {
            return 'Each attendee can appear once per round.';
          }
        }
      }
    }
    return null;
  }

  void _addGroup(GroupOverrideRoundDraft round) {
    final used = round.groups
        .expand((group) => group.memberUids)
        .whereType<String>()
        .toSet();
    final available = _participantUids
        .where((uid) => !used.contains(uid))
        .toList(growable: false);
    round.groups.add(
      GroupOverrideUnitDraft(
        label: 'Group ${round.groups.length + 1}',
        memberUids: <String?>[if (available.isNotEmpty) available.first],
      ),
    );
  }

  void _addMember(GroupOverrideRoundDraft round, GroupOverrideUnitDraft group) {
    final used = round.groups
        .expand((draft) => draft.memberUids)
        .whereType<String>()
        .toSet();
    final available = _participantUids
        .where((uid) => !used.contains(uid))
        .toList(growable: false);
    group.memberUids.add(available.isEmpty ? null : available.first);
  }

  void _saveOverrides(BuildContext context) {
    final overrideRounds = [
      for (final round in _rounds)
        EventSuccessGroupOverrideRound(
          roundIndex: round.roundIndex,
          groups: [
            for (final group in round.groups)
              EventSuccessGroupOverrideUnit(
                label: group.label.trim(),
                participantUids: group.memberUids.whereType<String>().toList(),
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
    EventSuccessController.overrideGroupAssignmentsMutation.run(ref, (
      tx,
    ) async {
      await tx
          .get(eventSuccessControllerProvider.notifier)
          .overrideGroupAssignments(
            eventId: widget.event.id,
            rounds: overrideRounds,
          );
      if (context.mounted) Navigator.of(context).pop();
    });
  }
}

class GroupOverrideRoundEditor extends StatelessWidget {
  const GroupOverrideRoundEditor({
    super.key,
    required this.round,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onAddGroup,
    required this.onRemoveGroup,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  final GroupOverrideRoundDraft round;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onAddGroup;
  final ValueChanged<GroupOverrideUnitDraft> onRemoveGroup;
  final ValueChanged<GroupOverrideUnitDraft> onAddMember;
  final void Function(GroupOverrideUnitDraft group, String? memberUid)
  onRemoveMember;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Round ${round.roundIndex + 1}',
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              CatchButton(
                label: 'Add group',
                icon: Icon(CatchIcons.addRounded),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
                onPressed: onAddGroup,
              ),
            ],
          ),
          gapH10,
          if (round.groups.isEmpty)
            Text(
              'No groups in this round.',
              style: CatchTextStyles.supporting(context, color: t.ink3),
            )
          else
            for (final group in round.groups) ...[
              GroupOverrideUnitEditor(
                group: group,
                participantUids: participantUids,
                participantLabel: participantLabel,
                onChanged: onChanged,
                onAddMember: () => onAddMember(group),
                onRemoveGroup: () => onRemoveGroup(group),
                onRemoveMember: (memberUid) => onRemoveMember(group, memberUid),
              ),
              if (group != round.groups.last) gapH10,
            ],
        ],
      ),
    );
  }
}

class GroupOverrideUnitEditor extends StatelessWidget {
  const GroupOverrideUnitEditor({
    super.key,
    required this.group,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onAddMember,
    required this.onRemoveGroup,
    required this.onRemoveMember,
  });

  final GroupOverrideUnitDraft group;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onAddMember;
  final VoidCallback onRemoveGroup;
  final ValueChanged<String?> onRemoveMember;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.sm,
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CatchField.input(
                  title: 'Group label',
                  initialValue: group.label,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    group.label = value;
                    onChanged();
                  },
                ),
              ),
              gapW8,
              HostOverrideIconAction(
                tooltip: 'Remove group',
                icon: CatchIcons.deleteOutlineRounded,
                color: t.danger,
                onPressed: onRemoveGroup,
              ),
            ],
          ),
          gapH10,
          for (
            var memberIndex = 0;
            memberIndex < group.memberUids.length;
            memberIndex++
          ) ...[
            GroupOverrideMemberEditor(
              value: group.memberUids[memberIndex],
              participantUids: participantUids,
              participantLabel: participantLabel,
              onChanged: (value) {
                group.memberUids[memberIndex] = value;
                onChanged();
              },
              onRemove: () => onRemoveMember(group.memberUids[memberIndex]),
            ),
            gapH8,
          ],
          CatchButton(
            label: 'Add attendee',
            icon: Icon(CatchIcons.personAddAlt1Rounded),
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
            onPressed: onAddMember,
          ),
        ],
      ),
    );
  }
}

class GroupOverrideMemberEditor extends StatelessWidget {
  const GroupOverrideMemberEditor({
    super.key,
    required this.value,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onRemove,
  });

  final String? value;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CatchField.select<String>(
            title: 'Group attendee',
            values: participantUids,
            value: value,
            itemLabel: participantLabel,
            hintText: 'Attendee',
            showLabel: false,
            onChanged: onChanged,
          ),
        ),
        gapW8,
        HostOverrideIconAction(
          tooltip: 'Remove attendee',
          icon: CatchIcons.closeRounded,
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class RotationsHostCard extends StatelessWidget {
  const RotationsHostCard({
    super.key,
    required this.event,
    required this.rotationIntervalMinutes,
    required this.assignments,
    required this.participantProfiles,
    required this.preferences,
    required this.actionState,
    this.onGenerate,
    this.onOverride,
  });

  final Event event;
  final int rotationIntervalMinutes;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> participantProfiles;
  final List<EventSuccessPreference> preferences;
  final EventSuccessAssignmentGenerationActionState actionState;
  final Future<void> Function()? onGenerate;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>? onOverride;

  @override
  Widget build(BuildContext context) {
    final optedOutUids = preferences
        .where((preference) => preference.guidedRotationsOptedOut)
        .map((preference) => preference.uid)
        .toSet();
    final activeAssignments = assignments
        .where((assignment) => !optedOutUids.contains(assignment.uid))
        .toList(growable: false);
    final roundCount = _maxRotationRoundCount(activeAssignments);
    final fairness = _rotationFairnessTotals(activeAssignments);
    final optedOutCount = optedOutUids.length;
    final staleAssignmentCount = assignments.length - activeAssignments.length;
    final hostEdited = activeAssignments.any(
      (assignment) => assignment.source == 'host_override_v1',
    );
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CatchIcons.syncAltRounded,
                color: CatchTokens.of(context).primary,
              ),
              gapW10,
              Expanded(
                child: Text(
                  'Timed partner rotations',
                  style: CatchTextStyles.sectionTitle(context),
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
                  icon: CatchIcons.visibilityOffOutlined,
                ),
              ],
              if (hostEdited) ...[
                gapW8,
                CatchBadge(label: 'Host edited', icon: CatchIcons.editOutlined),
              ],
            ],
          ),
          gapH8,
          Text(
            staleAssignmentCount > 0
                ? 'Regenerate to remove opted-out attendees from timed rotations.'
                : 'Generate pairings from event duration, saved cadence, checked-in participants, and mutual gender interest.',
            style: CatchTextStyles.supporting(context),
          ),
          if (activeAssignments.isNotEmpty) ...[
            gapH12,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchBadge(
                  label: '${activeAssignments.length} assigned',
                  icon: CatchIcons.peopleOutlineRounded,
                ),
                CatchBadge(
                  label:
                      '${_eventRotationCapacity(event, rotationIntervalMinutes)} possible',
                  icon: CatchIcons.scheduleRounded,
                ),
                if (fairness.sitOutRoundCount > 0)
                  CatchBadge(
                    label: '${fairness.sitOutRoundCount} planned breaks',
                    icon: CatchIcons.eventRepeatOutlined,
                  ),
                if (fairness.repeatPeerCount > 0)
                  CatchBadge(
                    label: '${fairness.repeatPeerCount} repeated peers',
                    tone: CatchBadgeTone.warning,
                    icon: CatchIcons.infoOutlineRounded,
                  ),
              ],
            ),
            gapH10,
            AssignmentReasonSummary(assignments: activeAssignments),
          ],
          if (actionState.error != null) ...[
            gapH8,
            CatchErrorBanner.fromError(
              actionState.error!,
              context: AppErrorContext.event,
            ),
          ],
          gapH12,
          if (activeAssignments.isEmpty)
            CatchButton(
              key: const ValueKey('eventSuccessGenerateRotationsButton'),
              label: 'Generate rotations',
              icon: Icon(CatchIcons.autoAwesomeOutlined),
              isLoading: actionState.isGenerating,
              onPressed: actionState.isGenerating || onGenerate == null
                  ? null
                  : () => unawaited(onGenerate!()),
              fullWidth: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: CatchButton(
                    key: const ValueKey('eventSuccessGenerateRotationsButton'),
                    label: 'Regenerate',
                    icon: Icon(CatchIcons.autoAwesomeOutlined),
                    variant: CatchButtonVariant.secondary,
                    isLoading: actionState.isGenerating,
                    onPressed: actionState.isGenerating || onGenerate == null
                        ? null
                        : () => unawaited(onGenerate!()),
                    fullWidth: true,
                  ),
                ),
                gapW10,
                Expanded(
                  child: CatchButton(
                    label: 'Edit rotations',
                    icon: Icon(CatchIcons.editOutlined),
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
    builder: (context) => RotationOverrideSheet(
      event: event,
      assignments: assignments,
      participantProfiles: participantProfiles,
      onOverride: onOverride,
    ),
  );
}

class RotationOverrideSheet extends ConsumerStatefulWidget {
  const RotationOverrideSheet({
    super.key,
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
  ConsumerState<RotationOverrideSheet> createState() =>
      _RotationOverrideSheetState();
}

class _RotationOverrideSheetState extends ConsumerState<RotationOverrideSheet> {
  late final List<String> _participantUids = _rotationParticipantUids(
    widget.assignments,
  );
  late final Map<String, String> _participantLabels = {
    for (final profile in widget.participantProfiles) profile.uid: profile.name,
  };
  late final List<RotationOverrideRoundDraft> _rounds =
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
            CatchErrorBanner.fromError(
              (mutation as MutationError).error,
              context: AppErrorContext.event,
            ),
            gapH8,
          ],
          if (validationError != null) ...[
            Text(
              validationError,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).danger,
              ),
            ),
            gapH8,
          ],
          CatchButton(
            label: 'Save overrides',
            icon: Icon(CatchIcons.checkRounded),
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
            return RotationOverrideRoundEditor(
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

  void _addPair(RotationOverrideRoundDraft round) {
    final used = round.pairings
        .expand((pair) => [pair.uidA, pair.uidB])
        .whereType<String>()
        .toSet();
    final available = _participantUids
        .where((uid) => !used.contains(uid))
        .toList(growable: false);
    round.pairings.add(
      RotationOverridePairDraft(
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

class RotationOverrideRoundEditor extends StatelessWidget {
  const RotationOverrideRoundEditor({
    super.key,
    required this.round,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onAddPair,
    required this.onRemovePair,
  });

  final RotationOverrideRoundDraft round;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onAddPair;
  final ValueChanged<RotationOverridePairDraft> onRemovePair;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Round ${round.roundIndex + 1}',
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              CatchButton(
                label: 'Add pair',
                icon: Icon(CatchIcons.addRounded),
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
              style: CatchTextStyles.supporting(context, color: t.ink3),
            )
          else
            for (final pair in round.pairings) ...[
              RotationOverridePairEditor(
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

class RotationOverridePairEditor extends StatelessWidget {
  const RotationOverridePairEditor({
    super.key,
    required this.pair,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onRemove,
  });

  final RotationOverridePairDraft pair;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CatchField.select<String>(
            title: 'First rotation attendee',
            values: participantUids,
            value: pair.uidA,
            itemLabel: participantLabel,
            hintText: 'Attendee',
            showLabel: false,
            onChanged: (value) {
              pair.uidA = value;
              onChanged();
            },
          ),
        ),
        gapW8,
        Expanded(
          child: CatchField.select<String>(
            title: 'Second rotation attendee',
            values: participantUids,
            value: pair.uidB,
            itemLabel: participantLabel,
            hintText: 'Partner',
            showLabel: false,
            onChanged: (value) {
              pair.uidB = value;
              onChanged();
            },
          ),
        ),
        gapW8,
        HostOverrideIconAction(
          tooltip: 'Remove pair',
          icon: CatchIcons.deleteOutlineRounded,
          color: CatchTokens.of(context).danger,
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class HostOverrideIconAction extends StatelessWidget {
  const HostOverrideIconAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Tooltip(
      message: tooltip,
      child: CatchIconButton(
        onTap: onPressed,
        child: Icon(icon, size: CatchIcon.md, color: color ?? t.ink2),
      ),
    );
  }
}

class PodGroupSummary extends StatelessWidget {
  const PodGroupSummary({super.key, required this.assignments});

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
            icon: CatchIcons.groupOutlined,
          ),
      ],
    );
  }
}

class AssignmentReasonSummary extends StatelessWidget {
  const AssignmentReasonSummary({super.key, required this.assignments});

  final List<EventSuccessAssignment> assignments;

  @override
  Widget build(BuildContext context) {
    final reasons = _assignmentReasonSummaries(assignments);
    if (reasons.isEmpty) return const SizedBox.shrink();
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CatchIcons.infoOutlineRounded,
              size: CatchIcon.xs,
              color: t.ink2,
            ),
            gapW6,
            Text(
              'Assignment notes',
              style: CatchTextStyles.labelM(context, color: t.ink2),
            ),
          ],
        ),
        gapH6,
        for (final reason in reasons)
          Padding(
            padding: _hostLaunchIssueGap,
            child: Text(
              reason,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
      ],
    );
  }
}

List<String> _assignmentReasonSummaries(
  List<EventSuccessAssignment> assignments,
) {
  final summaries = <String>[];
  for (final assignment in assignments) {
    final summary = assignment.whySummary?.trim();
    if (summary != null && summary.isNotEmpty) summaries.add(summary);
    for (final slot in assignment.rotationSlots) {
      final slotSummary = slot.whySummary?.trim();
      if (slotSummary != null && slotSummary.isNotEmpty) {
        summaries.add(slotSummary);
      }
    }
    for (final slot in assignment.groupRotationSlots) {
      final slotSummary = slot.whySummary?.trim();
      if (slotSummary != null && slotSummary.isNotEmpty) {
        summaries.add(slotSummary);
      }
    }
    for (final slot in assignment.sitOutSlots) {
      summaries.add(slot.whySummary);
    }
  }
  return [...summaries.toSet()].take(3).toList(growable: false);
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
    uids.addAll(assignment.allPeerUids);
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

List<GroupOverrideRoundDraft> _groupRoundDraftsFromAssignments(
  List<EventSuccessAssignment> assignments,
) {
  final hasGroupRotations = assignments.any(
    (assignment) => assignment.groupRotationSlots.isNotEmpty,
  );
  if (hasGroupRotations) {
    return _groupRotationRoundDraftsFromAssignments(assignments);
  }
  return [
    GroupOverrideRoundDraft(
      roundIndex: 0,
      groups: _staticGroupDraftsFromAssignments(assignments),
    ),
  ];
}

List<GroupOverrideRoundDraft> _groupRotationRoundDraftsFromAssignments(
  List<EventSuccessAssignment> assignments,
) {
  final groupsByRound = <int, Map<String, GroupOverrideUnitDraft>>{};
  for (final assignment in assignments) {
    for (final slot in assignment.groupRotationSlots) {
      final memberUids = [assignment.uid, ...slot.peerUids]..sort();
      final key = '${slot.unitLabel}:${memberUids.join('__')}';
      groupsByRound
          .putIfAbsent(slot.roundIndex, () => {})
          .putIfAbsent(
            key,
            () => GroupOverrideUnitDraft(
              label: slot.unitLabel,
              memberUids: <String?>[...memberUids],
            ),
          );
    }
  }
  final entries = groupsByRound.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final entry in entries)
      GroupOverrideRoundDraft(
        roundIndex: entry.key,
        groups: entry.value.values.toList(),
      ),
  ];
}

List<GroupOverrideUnitDraft> _staticGroupDraftsFromAssignments(
  List<EventSuccessAssignment> assignments,
) {
  final memberUidsByLabel = <String, Set<String>>{};
  for (final assignment in assignments) {
    memberUidsByLabel.putIfAbsent(assignment.label, () => <String>{}).addAll([
      assignment.uid,
      ...assignment.peerUids,
    ]);
  }
  final entries = memberUidsByLabel.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final entry in entries)
      GroupOverrideUnitDraft(
        label: entry.key,
        memberUids: <String?>[...(entry.value.toList()..sort())],
      ),
  ];
}

final class GroupOverrideRoundDraft {
  GroupOverrideRoundDraft({required this.roundIndex, required this.groups});

  final int roundIndex;
  final List<GroupOverrideUnitDraft> groups;
}

final class GroupOverrideUnitDraft {
  GroupOverrideUnitDraft({required this.label, required this.memberUids});

  String label;
  final List<String?> memberUids;
}

List<RotationOverrideRoundDraft> _rotationRoundDraftsFromAssignments(
  List<EventSuccessAssignment> assignments,
) {
  final pairsByRound = <int, Map<String, RotationOverridePairDraft>>{};
  for (final assignment in assignments) {
    for (final slot in assignment.rotationSlots) {
      final pairUids = [assignment.uid, slot.peerUid]..sort();
      final key = pairUids.join('__');
      pairsByRound
          .putIfAbsent(slot.roundIndex, () => {})
          .putIfAbsent(
            key,
            () => RotationOverridePairDraft(
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
      RotationOverrideRoundDraft(
        roundIndex: entry.key,
        pairings: entry.value.values.toList(),
      ),
  ];
}

final class RotationOverrideRoundDraft {
  RotationOverrideRoundDraft({
    required this.roundIndex,
    required this.pairings,
  });

  final int roundIndex;
  final List<RotationOverridePairDraft> pairings;
}

final class RotationOverridePairDraft {
  RotationOverridePairDraft({required this.uidA, required this.uidB});

  String? uidA;
  String? uidB;
}

final class _RotationFairnessTotals {
  const _RotationFairnessTotals({
    required this.sitOutRoundCount,
    required this.repeatPeerCount,
  });

  final int sitOutRoundCount;
  final int repeatPeerCount;
}

_RotationFairnessTotals _rotationFairnessTotals(
  List<EventSuccessAssignment> assignments,
) {
  var sitOutRoundCount = 0;
  var repeatPeerCount = 0;
  for (final assignment in assignments) {
    final fairness = assignment.rotationFairness;
    if (fairness == null) continue;
    sitOutRoundCount += fairness.sitOutRoundCount;
    repeatPeerCount += fairness.repeatPeerCount;
  }
  return _RotationFairnessTotals(
    sitOutRoundCount: sitOutRoundCount,
    repeatPeerCount: repeatPeerCount,
  );
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
