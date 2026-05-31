import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/events/domain/event.dart';

const chatContextFallbackStamp = 'MATCHED THROUGH CATCH';

String chatContextStampFor(Event? event) {
  if (event == null) return chatContextFallbackStamp;
  return chatContextStampForActivity(event.activityKind);
}

String chatContextStampForActivity(ActivityKind kind) {
  return switch (kind) {
    ActivityKind.socialRun || ActivityKind.running => 'YOU BOTH RAN',
    ActivityKind.walking => 'YOU BOTH WALKED',
    ActivityKind.pickleball => 'BOTH PLAYED PICKLEBALL',
    ActivityKind.padel => 'BOTH PLAYED PADEL',
    ActivityKind.tennis => 'BOTH PLAYED TENNIS',
    ActivityKind.badminton => 'BOTH PLAYED BADMINTON',
    ActivityKind.cycling => 'YOU BOTH RODE',
    ActivityKind.spinClass => 'MET AT SPIN CLASS',
    ActivityKind.yoga => 'MET THROUGH YOGA',
    ActivityKind.strengthTraining => 'MET THROUGH STRENGTH',
    ActivityKind.pubQuiz => 'MET AT PUB QUIZ',
    ActivityKind.barCrawl => 'MET ON BAR CRAWL',
    ActivityKind.dinner => 'MATCHED AFTER DINNER',
    ActivityKind.singlesMixer => 'MATCHED AFTER MIXER',
    ActivityKind.openActivity => 'MATCHED AFTER EVENT',
  };
}

String chatShareCardTitleFor(Event? event) {
  if (event == null) return 'After the event';
  return 'After ${event.eventFormat.eventTitleLabel.toLowerCase()}';
}
