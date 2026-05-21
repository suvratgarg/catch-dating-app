import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/domain/event.dart';

enum EventSuccessConversationCueMoment {
  live('Live prompt'),
  postEvent('Post-match opener');

  const EventSuccessConversationCueMoment(this.label);

  final String label;
}

final class EventSuccessConversationCue {
  const EventSuccessConversationCue({
    required this.title,
    required this.body,
    required this.contextLabel,
    required this.moment,
  });

  final String title;
  final String body;
  final String contextLabel;
  final EventSuccessConversationCueMoment moment;
}

abstract final class EventSuccessConversationCueLibrary {
  static List<EventSuccessConversationCue> liveCuesFor({
    required Event event,
    required EventSuccessPlan plan,
    EventRunOfShowStep? activeStep,
  }) {
    return _dedupe([
      if (activeStep != null)
        EventSuccessConversationCue(
          title: activeStep.title,
          body: activeStep.attendeeExperience,
          contextLabel: activeStep.stage.label,
          moment: EventSuccessConversationCueMoment.live,
        ),
      _activityLiveCue(event.activityKind),
      _lowPressureCue(event.activityKind),
    ]);
  }

  static List<EventSuccessConversationCue> postEventOpenersFor(Event event) {
    return _dedupe([
      _activityOpener(event.activityKind),
      EventSuccessConversationCue(
        title: 'Shared room',
        body: 'I am glad we both made it to ${event.eventFormat.label}.',
        contextLabel: event.eventFormat.label,
        moment: EventSuccessConversationCueMoment.postEvent,
      ),
      const EventSuccessConversationCue(
        title: 'Easy follow-up',
        body: 'What was your favorite moment from the event?',
        contextLabel: 'Low pressure',
        moment: EventSuccessConversationCueMoment.postEvent,
      ),
    ]);
  }

  static List<EventSuccessConversationCue> _dedupe(
    List<EventSuccessConversationCue> cues,
  ) {
    final seen = <String>{};
    final values = <EventSuccessConversationCue>[];
    for (final cue in cues) {
      final key = '${cue.title}|${cue.body}';
      if (seen.add(key)) values.add(cue);
    }
    return List.unmodifiable(values);
  }

  static EventSuccessConversationCue _activityLiveCue(ActivityKind activity) {
    final body = switch (activity) {
      ActivityKind.socialRun || ActivityKind.running || ActivityKind.walking =>
        'Ask someone what route, cafe, or park they would do again.',
      ActivityKind.pickleball ||
      ActivityKind.padel ||
      ActivityKind.tennis ||
      ActivityKind.badminton =>
        'Ask your next partner what shot they are trying to improve.',
      ActivityKind.cycling ||
      ActivityKind.spinClass => 'Ask what kind of ride they want to do next.',
      ActivityKind.yoga => 'Ask what part of class helped them switch off.',
      ActivityKind.strengthTraining =>
        'Ask what lift or movement they are working on right now.',
      ActivityKind.pubQuiz =>
        'Ask which round they wanted more questions from.',
      ActivityKind.barCrawl =>
        'Ask which stop they would come back to with friends.',
      ActivityKind.dinner => 'Ask what dish they would order again.',
      ActivityKind.singlesMixer =>
        'Ask what answer from tonight surprised them.',
      ActivityKind.openActivity => 'Ask what made them say yes to this event.',
    };
    return EventSuccessConversationCue(
      title: 'First live cue',
      body: body,
      contextLabel: activity.label,
      moment: EventSuccessConversationCueMoment.live,
    );
  }

  static EventSuccessConversationCue _lowPressureCue(ActivityKind activity) {
    final body = activity.isMovementHeavy
        ? 'Swap one practical tip before the next round or cooldown.'
        : 'Find one person you have not spoken to and ask one specific follow-up.';
    return EventSuccessConversationCue(
      title: 'Second touch',
      body: body,
      contextLabel: 'Optional',
      moment: EventSuccessConversationCueMoment.live,
    );
  }

  static EventSuccessConversationCue _activityOpener(ActivityKind activity) {
    final body = switch (activity) {
      ActivityKind.socialRun || ActivityKind.running || ActivityKind.walking =>
        'I liked talking on the run. Want to compare routes sometime?',
      ActivityKind.pickleball ||
      ActivityKind.padel ||
      ActivityKind.tennis ||
      ActivityKind.badminton =>
        'Good game today. I am still thinking about that rally.',
      ActivityKind.cycling || ActivityKind.spinClass =>
        'That session had real energy. What kind of ride do you usually like?',
      ActivityKind.yoga =>
        'That class was a good reset. Do you usually go for flow or stretch?',
      ActivityKind.strengthTraining =>
        'Nice training with you today. What are you building toward right now?',
      ActivityKind.pubQuiz =>
        'I liked being on a quiz night with you. Which round was your favorite?',
      ActivityKind.barCrawl =>
        'Fun meeting you tonight. Which stop won for you?',
      ActivityKind.dinner =>
        'I liked meeting you over dinner. What was your favorite dish?',
      ActivityKind.singlesMixer =>
        'I liked our conversation tonight. Want to keep it going?',
      ActivityKind.openActivity =>
        'I liked meeting you at the event. What did you think of it?',
    };
    return EventSuccessConversationCue(
      title: 'Use the shared moment',
      body: body,
      contextLabel: activity.label,
      moment: EventSuccessConversationCueMoment.postEvent,
    );
  }
}
