import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_calendar_links.dart';
import 'package:catch_dating_app/runs/presentation/run_location_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentConfirmationControllerProvider =
    Provider<PaymentConfirmationController>((ref) {
      return PaymentConfirmationController(
        links: ref.watch(externalLinkControllerProvider),
        share: ref.watch(externalShareControllerProvider),
      );
    });

class PaymentConfirmationController {
  const PaymentConfirmationController({
    required ExternalLinkController links,
    required ExternalShareController share,
  }) : _links = links,
       _share = share;

  final ExternalLinkController _links;
  final ExternalShareController _share;

  Future<bool> addToCalendar(Run run) => _links.openExternal(calendarUri(run));

  Future<bool> openDirections(Run run) =>
      _links.openExternal(directionsUri(run));

  Future<void> inviteFriend(Run run) => _share.shareText(text: inviteText(run));

  Future<void> shareReferral(Run run) =>
      _share.shareText(text: referralText(run));

  static Uri calendarUri(Run run) => calendarUriForRun(run);

  static Uri directionsUri(Run run) => directionsUriForRun(run);

  static String inviteText(Run run) {
    return 'Join me for a run! ${run.title} - ${run.meetingPoint}. '
        'Download Catch: https://catchdates.com';
  }

  static String referralText(Run run) {
    return 'I just signed up for ${run.title}! '
        'Join me - download Catch and book a run: '
        'https://catchdates.com';
  }
}
