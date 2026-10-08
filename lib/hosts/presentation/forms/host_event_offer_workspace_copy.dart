part of 'host_event_offer_workspace_section.dart';

/// Localized copy contract for the response-to-offer workspace.
class HostEventOfferWorkspaceCopy {
  const HostEventOfferWorkspaceCopy({
    required this.create,
    required this.selectEvent,
    required this.chooseForRecipient,
    required this.chooseForRecipients,
    required this.loadingEvents,
    required this.preparingOffer,
    required this.loadingOffer,
    required this.preparingMessage,
    required this.cancelPreparation,
    required this.emptyEvents,
    required this.untitledEvent,
    required this.loadMoreEvents,
    required this.needsContact,
    required this.convertContact,
    required this.selectionChanged,
    required this.loadFailed,
    required this.issued,
    required this.refresh,
    required this.existing,
    required this.noOffers,
    required this.configurePayment,
    required this.openSettings,
    required this.statusDraft,
    required this.statusOffered,
    required this.statusWithdrawn,
    required this.statusExpired,
    required this.personalPaymentLink,
    required this.openExisting,
    required this.handoffPrepare,
    required this.handoffBlocked,
    required this.handoffDisclosure,
    required this.openWhatsapp,
    required this.copyMessage,
    required this.messageCopied,
    required this.handoffOpenFailed,
    required this.review,
  });

  final String create;
  final String selectEvent;
  final String Function(String name) chooseForRecipient;
  final String Function(int count) chooseForRecipients;
  final String loadingEvents;
  final String preparingOffer;
  final String loadingOffer;
  final String preparingMessage;
  final String cancelPreparation;
  final String emptyEvents;
  final String untitledEvent;
  final String loadMoreEvents;
  final String needsContact;
  final String convertContact;
  final String selectionChanged;
  final String loadFailed;
  final String issued;
  final String refresh;
  final String existing;
  final String noOffers;
  final String configurePayment;
  final String openSettings;
  final String statusDraft;
  final String statusOffered;
  final String statusWithdrawn;
  final String statusExpired;
  final String Function(String name) personalPaymentLink;
  final String openExisting;
  final String handoffPrepare;
  final String handoffBlocked;
  final String handoffDisclosure;
  final String openWhatsapp;
  final String copyMessage;
  final String messageCopied;
  final String handoffOpenFailed;
  final HostEventOfferReviewCopy review;
}
