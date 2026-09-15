part of 'host_event_rehearsal_screen.dart';

class _RehearsalCoachTask {
  const _RehearsalCoachTask({
    required this.key,
    required this.number,
    required this.title,
    required this.body,
    required this.workspace,
    this.actorId,
  });

  final String key;
  final int number;
  final String title;
  final String body;
  final EventSuccessLiveWorkspace workspace;
  final String? actorId;
}

_RehearsalCoachTask _buildCoachTask(
  BuildContext context,
  EventRehearsalBootstrap rehearsal,
) {
  final late = rehearsal.actors
      .where((actor) => actor.status == EventRehearsalActorStatus.late)
      .firstOrNull;
  if (late != null) {
    return _RehearsalCoachTask(
      key: 'late:${late.actorId}',
      number: 3,
      title: context.l10n.hostEventRehearsalCoachResolveLate(
        name: _coachFirstName(late.displayName),
      ),
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
      actorId: late.actorId,
    );
  }
  final help = rehearsal.actors
      .where((actor) => actor.helpRequested)
      .firstOrNull;
  if (help != null) {
    return _RehearsalCoachTask(
      key: 'help:${help.actorId}',
      number: 5,
      title: context.l10n.hostEventRehearsalCoachResolveHelp(
        name: _coachFirstName(help.displayName),
      ),
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
      actorId: help.actorId,
    );
  }
  final placement = rehearsal.actors
      .where(
        (actor) =>
            (actor.status == EventRehearsalActorStatus.present ||
                actor.status == EventRehearsalActorStatus.returned) &&
            actor.layoutUnitId != null &&
            actor.confirmedLayoutUnitId != actor.layoutUnitId,
      )
      .firstOrNull;
  if (placement != null) {
    return _RehearsalCoachTask(
      key: 'place:${placement.actorId}:${placement.layoutUnitId}',
      number: 4,
      title: context.l10n.hostEventRehearsalCoachPlaceGuest(
        name: _coachFirstName(placement.displayName),
      ),
      body: context.l10n.hostEventRehearsalCoachPlaceGuestBody,
      workspace: EventSuccessLiveWorkspace.room,
      actorId: placement.actorId,
    );
  }
  return switch (rehearsal.session.status) {
    EventRehearsalStatus.draft ||
    EventRehearsalStatus.ready => _RehearsalCoachTask(
      key: 'start',
      number: 1,
      title: context.l10n.hostEventRehearsalCoachStart,
      body: context.l10n.hostEventRehearsalCoachStartBody,
      workspace: EventSuccessLiveWorkspace.now,
    ),
    EventRehearsalStatus.paused => _RehearsalCoachTask(
      key: 'resume:${rehearsal.session.activeStepIndex}',
      number: (rehearsal.session.activeStepIndex + 2).clamp(1, 8),
      title: context.l10n.hostEventRehearsalCoachResume,
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
    ),
    EventRehearsalStatus.complete ||
    EventRehearsalStatus.expired => _RehearsalCoachTask(
      key: 'complete',
      number: 8,
      title: context.l10n.hostEventRehearsalCoachComplete,
      body: context.l10n.hostEventRehearsalCoachCompleteBody,
      workspace: EventSuccessLiveWorkspace.now,
    ),
    EventRehearsalStatus.running => _RehearsalCoachTask(
      key: 'advance:${rehearsal.session.activeStepIndex}',
      number: (rehearsal.session.activeStepIndex + 2).clamp(1, 8),
      title: context.l10n.hostEventRehearsalCoachAdvance,
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
    ),
  };
}

String _coachFirstName(String displayName) {
  final trimmed = displayName.trim();
  if (trimmed.isEmpty) return displayName;
  return trimmed.split(RegExp(r'\s+')).first;
}

EventRehearsalSpatialScope _rehearsalSpatialScope(
  EventSuccessSpatialScope scope,
) => switch (scope) {
  EventSuccessSpatialScope.thisRound => EventRehearsalSpatialScope.thisRound,
  EventSuccessSpatialScope.pinned => EventRehearsalSpatialScope.pinned,
};
