import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_calendar_links.dart';
import 'package:catch_dating_app/events/presentation/event_location_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_confirmation_controller.g.dart';

@Riverpod(keepAlive: true)
PaymentConfirmationController paymentConfirmationController(Ref ref) {
  return PaymentConfirmationController(
    links: ref.watch(externalLinkControllerProvider),
    share: ref.watch(externalShareControllerProvider),
  );
}

class PaymentConfirmationController {
  const PaymentConfirmationController({
    required ExternalLinkController links,
    required ExternalShareController share,
  }) : _links = links,
       _share = share;

  final ExternalLinkController _links;
  final ExternalShareController _share;

  Future<bool> addToCalendar(Event event) =>
      _links.openExternal(calendarUri(event));

  Future<bool> openDirections(Event event) =>
      _links.openExternal(directionsUri(event));

  Future<void> inviteFriend(Event event) =>
      _share.shareText(text: inviteText(event));

  Future<void> shareReferral(Event event) =>
      _share.shareText(text: referralText(event));

  static Uri calendarUri(Event event) => calendarUriForEvent(event);

  static Uri directionsUri(Event event) => directionsUriForEvent(event);

  static String inviteText(Event event) {
    return 'Join me for an event! ${event.title} - ${event.locationName}. '
        'Download Catch: https://catchdates.com';
  }

  static String referralText(Event event) {
    return 'I just signed up for ${event.title}! '
        'Join me - download Catch and book an event: '
        'https://catchdates.com';
  }
}
