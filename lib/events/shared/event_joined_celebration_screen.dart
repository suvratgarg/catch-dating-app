import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:flutter/material.dart';

class EventJoinedCelebrationScreen extends StatelessWidget {
  const EventJoinedCelebrationScreen({
    super.key,
    required this.event,
    required this.onViewEvent,
    required this.onBackHome,
    this.clubName,
    this.paymentData,
    this.supplementalChildren = const [],
    this.viewEventKey,
    this.backHomeKey,
  });

  final Event event;
  final String? clubName;
  final PaymentConfirmationData? paymentData;
  final VoidCallback onViewEvent;
  final VoidCallback onBackHome;
  final List<Widget> supplementalChildren;
  final Key? viewEventKey;
  final Key? backHomeKey;

  @override
  Widget build(BuildContext context) {
    final paymentData = this.paymentData;

    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.eventJoined,
      eyebrow: context
          .l10n
          .eventsEventJoinedCelebrationScreenEyebrowBookingConfirmed,
      title: context.l10n.eventsEventJoinedCelebrationScreenTitleYouReIn,
      message: context.l10n
          .eventsEventJoinedCelebrationScreenMessageYourSpotIsConfirmed(
            title: event.title,
            value2: clubName == null
                ? ''
                : context.l10n
                      .eventsEventJoinedCelebrationScreenMessageWithClubname(
                        clubName: clubName!,
                      ),
          ),
      details: [
        CelebrationDetail(
          icon: CatchIcons.calendarMonthOutlined,
          label: context.l10n.eventsEventJoinedCelebrationScreenLabelWhen,
          value: '${event.longDateLabel} · ${event.timeRangeLabel}',
        ),
        CelebrationDetail(
          icon: CatchIcons.locationOnOutlined,
          label: context.l10n.eventsEventJoinedCelebrationScreenLabelWhere,
          value: event.locationName,
        ),
        CelebrationDetail(
          icon: CatchIcons.directionsRunRounded,
          label: context.l10n.eventsEventJoinedCelebrationScreenLabelEvent,
          value: event.activitySummaryLabel,
        ),
        if (paymentData != null) ...[
          CelebrationDetail(
            icon: CatchIcons.paymentsOutlined,
            label: context.l10n.eventsEventJoinedCelebrationScreenLabelPaid,
            value: EventFormatters.priceInPaise(
              paymentData.amountInPaise,
              currencyCode: paymentData.currency,
            ),
          ),
          CelebrationDetail(
            icon: CatchIcons.receiptLongOutlined,
            label:
                context.l10n.eventsEventJoinedCelebrationScreenLabelPaymentId,
            value: paymentData.paymentId,
          ),
        ],
      ],
      note:
          context.l10n.eventsEventJoinedCelebrationScreenNoteArriveByTheMeeting,
      supplementalChildren: supplementalChildren,
      primaryAction: CelebrationAction(
        key: viewEventKey,
        label: context.l10n.eventsEventJoinedCelebrationScreenLabelViewEvent,
        onPressed: onViewEvent,
        icon: Icon(CatchIcons.directionsRunRounded),
      ),
      secondaryAction: CelebrationAction(
        key: backHomeKey,
        label: context.l10n.eventsEventJoinedCelebrationScreenLabelBackToHome,
        onPressed: onBackHome,
      ),
      onClose: onBackHome,
    );
  }
}
