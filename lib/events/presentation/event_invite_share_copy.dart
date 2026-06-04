import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';

abstract final class EventInviteShareCopy {
  static Uri eventUri(
    Event event, {
    String? inviteCode,
    String? inviteLinkId,
  }) => AppDeepLinks.event(
    clubId: event.clubId,
    eventId: event.id,
    inviteCode: inviteCode,
    inviteLinkId: inviteLinkId,
  );

  static String subject(Event event) => 'Join me at ${event.title}';

  static String eventDetailInviteText(
    Event event, {
    String? inviteCode,
    String? inviteLinkId,
  }) {
    return _composeInvite(
      event,
      intro: 'This feels like your kind of plan.',
      inviteCode: inviteCode,
      inviteLinkId: inviteLinkId,
    );
  }

  static String bookingInviteText(Event event) {
    return _composeInvite(event, intro: 'I just booked this. Come with me?');
  }

  static String referralText(Event event) {
    return _composeInvite(
      event,
      intro: 'I am going to this on Catch and thought of you.',
    );
  }

  static String hostPrivateInviteText({
    required Event event,
    required String clubName,
    required String inviteLink,
  }) {
    return [
      'You are invited to ${event.title} from $clubName.',
      '',
      _eventLine(event),
      event.locationName,
      '',
      'Use this private Catch invite to book your spot:',
      inviteLink,
    ].join('\n');
  }

  static String _composeInvite(
    Event event, {
    required String intro,
    String? inviteCode,
    String? inviteLinkId,
  }) {
    final link = eventUri(
      event,
      inviteCode: inviteCode,
      inviteLinkId: inviteLinkId,
    );
    return [
      intro,
      '',
      event.title,
      _eventLine(event),
      event.locationName,
      '',
      'Book it on Catch:',
      link.toString(),
    ].join('\n');
  }

  static String _eventLine(Event event) {
    final price = event.isFree
        ? 'Free'
        : EventFormatters.priceInPaise(
            event.priceInPaise,
            currencyCode: event.currency,
          );
    return [
      event.longDateLabel,
      event.timeRangeLabel,
      event.activitySummaryLabel,
      price,
    ].join(' | ');
  }
}
