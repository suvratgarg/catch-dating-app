import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_conversation_cue.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

extension EventSuccessConversationCueMomentCopy
    on EventSuccessConversationCueMoment {
  String label(AppLocalizations l10n) => switch (this) {
    EventSuccessConversationCueMoment.live =>
      l10n.eventSuccessEventSuccessConversationCueCopyLabelLivePrompt,
    EventSuccessConversationCueMoment.postEvent =>
      l10n.eventSuccessEventSuccessConversationCueCopyLabelPostMatchOpener,
  };
}

abstract final class EventSuccessConversationCueLibrary {
  static List<EventSuccessConversationCue> liveCuesFor({
    required Event event,
    required EventSuccessPlan plan,
    required AppLocalizations l10n,
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
      _activityLiveCue(event.activityKind, l10n),
      _lowPressureCue(event.activityKind, l10n),
    ]);
  }

  static List<EventSuccessConversationCue> postEventOpenersFor(
    Event event, {
    required AppLocalizations l10n,
  }) {
    return _dedupe([
      _activityOpener(event.activityKind, l10n),
      EventSuccessConversationCue(
        title: l10n.eventSuccessEventSuccessConversationCueCopyTitleSharedRoom,
        body: l10n.eventSuccessEventSuccessConversationCueCopyBodyIAmGladWe(
          label: event.eventFormat.label,
        ),
        contextLabel: event.eventFormat.label,
        moment: EventSuccessConversationCueMoment.postEvent,
      ),
      EventSuccessConversationCue(
        title:
            l10n.eventSuccessEventSuccessConversationCueCopyTitleEasyFollowUp,
        body: l10n
            .eventSuccessEventSuccessConversationCueCopyBodyWhatWasYourFavorite,
        contextLabel: l10n
            .eventSuccessEventSuccessConversationCueCopyVisiblecopyLowPressure,
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

  static EventSuccessConversationCue _activityLiveCue(
    ActivityKind activity,
    AppLocalizations l10n,
  ) {
    final body = switch (activity) {
      ActivityKind.socialRun || ActivityKind.running || ActivityKind.walking =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskSomeoneWhatRoute,
      ActivityKind.pickleball ||
      ActivityKind.padel ||
      ActivityKind.tennis ||
      ActivityKind.badminton =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskYourNextPartner,
      ActivityKind.cycling || ActivityKind.spinClass =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhatKindOf,
      ActivityKind.yoga =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhatPartOf,
      ActivityKind.strengthTraining =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhatLiftOr,
      ActivityKind.pubQuiz =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhichRoundThey,
      ActivityKind.barCrawl =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhichStopThey,
      ActivityKind.dinner =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhatDishThey,
      ActivityKind.singlesMixer =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhatAnswerFrom,
      ActivityKind.openActivity =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyAskWhatMadeThem,
    };
    return EventSuccessConversationCue(
      title: l10n.eventSuccessEventSuccessConversationCueCopyTitleFirstLiveCue,
      body: body,
      contextLabel: activity.label,
      moment: EventSuccessConversationCueMoment.live,
    );
  }

  static EventSuccessConversationCue _lowPressureCue(
    ActivityKind activity,
    AppLocalizations l10n,
  ) {
    final body = activity.isMovementHeavy
        ? l10n.eventSuccessEventSuccessConversationCueCopyBodySwapOnePracticalTip
        : l10n.eventSuccessEventSuccessConversationCueCopyBodyFindOnePersonYou;
    return EventSuccessConversationCue(
      title: l10n.eventSuccessEventSuccessConversationCueCopyTitleSecondTouch,
      body: body,
      contextLabel:
          l10n.eventSuccessEventSuccessConversationCueCopyVisiblecopyOptional,
      moment: EventSuccessConversationCueMoment.live,
    );
  }

  static EventSuccessConversationCue _activityOpener(
    ActivityKind activity,
    AppLocalizations l10n,
  ) {
    final body = switch (activity) {
      ActivityKind.socialRun || ActivityKind.running || ActivityKind.walking =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyILikedTalkingOn,
      ActivityKind.pickleball ||
      ActivityKind.padel ||
      ActivityKind.tennis ||
      ActivityKind.badminton =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyGoodGameTodayI,
      ActivityKind.cycling || ActivityKind.spinClass =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyThatSessionHadReal,
      ActivityKind.yoga =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyThatClassWasA,
      ActivityKind.strengthTraining =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyNiceTrainingWithYou,
      ActivityKind.pubQuiz =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyILikedBeingOn,
      ActivityKind.barCrawl =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyFunMeetingYouTonight,
      ActivityKind.dinner =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyILikedMeetingYou,
      ActivityKind.singlesMixer =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyILikedOurConversation,
      ActivityKind.openActivity =>
        l10n.eventSuccessEventSuccessConversationCueCopyBodyILikedMeetingYou957a50,
    };
    return EventSuccessConversationCue(
      title: l10n
          .eventSuccessEventSuccessConversationCueCopyTitleUseTheSharedMoment,
      body: body,
      contextLabel: activity.label,
      moment: EventSuccessConversationCueMoment.postEvent,
    );
  }
}
