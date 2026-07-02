import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/events/data/event_calendar_links.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_location_links.dart';
import 'package:catch_dating_app/events/shared/event_invite_share_copy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_confirmation_controller.g.dart';

@Riverpod(keepAlive: true)
PaymentConfirmationController paymentConfirmationController(Ref ref) {
  return PaymentConfirmationController(
    calendar: ref.watch(eventCalendarControllerProvider),
    links: ref.watch(externalLinkControllerProvider),
    share: ref.watch(externalShareControllerProvider),
  );
}

class PaymentConfirmationController {
  const PaymentConfirmationController({
    required this._calendar,
    required this._links,
    required this._share,
  });

  final EventCalendarController _calendar;
  final ExternalLinkController _links;
  final ExternalShareController _share;

  Future<bool> addToCalendar(Event event) => _calendar.addToCalendar(event);

  Future<bool> openDirections(Event event) =>
      _links.openExternal(directionsUri(event));

  Future<bool> openCheckout(Uri checkoutUrl) =>
      _links.openExternal(checkoutUrl);

  Future<void> inviteFriend(Event event) =>
      _share.shareText(text: inviteText(event), subject: inviteSubject(event));

  Future<void> shareReferral(Event event) => _share.shareText(
    text: referralText(event),
    subject: inviteSubject(event),
  );

  static CalendarEventPayload calendarEvent(Event event) =>
      calendarEventPayloadForEvent(event);

  static Uri directionsUri(Event event) => directionsUriForEvent(event);

  static String inviteSubject(Event event) =>
      EventInviteShareCopy.subject(event);

  static String inviteText(Event event) {
    return EventInviteShareCopy.bookingInviteText(event);
  }

  static String referralText(Event event) {
    return EventInviteShareCopy.referralText(event);
  }
}
