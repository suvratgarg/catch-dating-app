import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

class EventPolicyPreviewAttendees {
  const EventPolicyPreviewAttendees._();

  static const straightMan = EventAttendeeProfile(
    uid: 'preview_straight_man',
    gender: Gender.man,
    interestedInGenders: {Gender.woman},
  );

  static const straightWoman = EventAttendeeProfile(
    uid: 'preview_straight_woman',
    gender: Gender.woman,
    interestedInGenders: {Gender.man},
  );

  static const queerOpenMan = EventAttendeeProfile(
    uid: 'preview_queer_open_man',
    gender: Gender.man,
    interestedInGenders: {Gender.man, Gender.woman},
  );

  static const queerOpenWoman = EventAttendeeProfile(
    uid: 'preview_queer_open_woman',
    gender: Gender.woman,
    interestedInGenders: {Gender.man, Gender.woman},
  );

  static const nonBinaryInterestedInWomen = EventAttendeeProfile(
    uid: 'preview_non_binary_interested_in_women',
    gender: Gender.nonBinary,
    interestedInGenders: {Gender.woman},
  );
}
