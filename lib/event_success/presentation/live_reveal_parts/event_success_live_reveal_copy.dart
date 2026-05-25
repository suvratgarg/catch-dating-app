part of '../event_success_live_reveal_card.dart';

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
    final groupRotationCount = _uniqueGroupRotationCountForRound(
      assignments,
      roundIndex,
    );
    if (groupRotationCount > 0) {
      final groupWord = groupRotationCount == 1 ? 'group' : 'groups';
      return '$groupRotationCount rotating $groupWord queued for round ${roundIndex + 1}; reveal names once the host has the room.';
    }
    final groups = _assignmentCountsByLabel(assignments);
    return '${assignments.length} attendees across ${groups.length} ${kind.assignmentNounPlural}; reveal names once the host has the room.';
  }
  final roundPairCount = _uniquePairCountForRound(assignments, roundIndex);
  final mutualCount = _strongCompatibilityPairCount(assignments, roundIndex);
  final pairingWord = roundPairCount == 1 ? 'pairing' : 'pairings';
  final verb = roundPairCount == 1 ? 'is' : 'are';
  final clueVerb = mutualCount == 1 ? 'has' : 'have';
  return '$roundPairCount $pairingWord $verb queued for round ${roundIndex + 1}. $mutualCount $clueVerb a stronger shared clue.';
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
    maxRounds = math.max(maxRounds, assignment.groupRotationSlots.length);
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

int _uniqueGroupRotationCountForRound(
  List<EventSuccessAssignment> assignments,
  int roundIndex,
) {
  final groups = <String>{};
  for (final assignment in assignments) {
    for (final slot in assignment.groupRotationSlots) {
      if (slot.roundIndex != roundIndex) continue;
      final uids = [assignment.uid, ...slot.peerUids]..sort();
      groups.add('${slot.unitLabel}:${uids.join('__')}');
    }
  }
  return groups.length;
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

EventSuccessGroupRotationSlot? _groupSlotForRound(
  EventSuccessAssignment assignment,
  int roundIndex,
) {
  for (final slot in assignment.groupRotationSlots) {
    if (slot.roundIndex == roundIndex) return slot;
  }
  return null;
}

String _compatibilityLabel(String value) => switch (value) {
  'mutual_interest' => 'Mutual interest',
  'questionnaire_match' => 'Shared clue',
  'balanced' => 'Balanced',
  'social' => 'Social fit',
  'mixed' => 'Mixed group',
  _ => 'Host fit',
};

String _compatibilityExplanation(String value) => switch (value) {
  'mutual_interest' => 'You both showed stronger interest for this round.',
  'questionnaire_match' =>
    'You share an event answer that can make this round easier to start.',
  'balanced' => 'Balanced by the host for variety and comfort.',
  'social' => 'A lightweight social pairing for this format.',
  'mixed' => 'A group fit balanced across romantic and social signals.',
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
