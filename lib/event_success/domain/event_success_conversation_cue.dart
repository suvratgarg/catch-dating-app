/// Stable semantic moment for a conversation cue.
///
/// User-visible labels belong to the presentation copy adapter rather than the
/// domain enum so locale selection stays at the render boundary.
enum EventSuccessConversationCueMoment { live, postEvent }

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
