import 'package:flutter/foundation.dart';

/// Product routes are intentionally more specific than transports.
///
/// Two routes may both use WhatsApp while retaining different sender,
/// consent, delivery, and observability contracts.
enum CommunicationRouteId {
  personalWhatsappHandoff,
  organizerWhatsappCampaign,
  catchWhatsapp,
  catchChat,
  catchEventAnnouncement,
  organizerFollowerUpdate,
}

enum CommunicationTransport { catchApp, whatsapp }

enum CommunicationSenderIdentity {
  hostPersonalDevice,
  organizerManaged,
  catchPlatform,
}

enum CommunicationDeliveryMode {
  externalHandoff,
  directConversation,
  campaign,
  eventAnnouncement,
  followerUpdate,
  platformMessage,
}

enum CommunicationConsentScope {
  directUserAction,
  linkedCatchAccount,
  eventService,
  organizerMarketing,
  followPreference,
  catchMessaging,
}

enum CommunicationObservability { none, catchActivity, providerReceipts }

@immutable
class CommunicationRouteCapability {
  const CommunicationRouteCapability({
    required this.id,
    required this.transport,
    required this.adapterKey,
    required this.senderIdentity,
    required this.deliveryMode,
    required this.consentScope,
    required this.observability,
    required this.requiresHostFinalSend,
    required this.supportsReplies,
    required this.supportsScheduling,
  });

  final CommunicationRouteId id;
  final CommunicationTransport transport;

  /// Stable adapter identifier. New market providers add a route/adapter
  /// without weakening the sender or consent boundary of existing routes.
  final String adapterKey;
  final CommunicationSenderIdentity senderIdentity;
  final CommunicationDeliveryMode deliveryMode;
  final CommunicationConsentScope consentScope;
  final CommunicationObservability observability;
  final bool requiresHostFinalSend;
  final bool supportsReplies;
  final bool supportsScheduling;
}

const communicationRouteCatalog =
    <CommunicationRouteId, CommunicationRouteCapability>{
      CommunicationRouteId.personalWhatsappHandoff:
          CommunicationRouteCapability(
            id: CommunicationRouteId.personalWhatsappHandoff,
            transport: CommunicationTransport.whatsapp,
            adapterKey: 'whatsapp_handoff',
            senderIdentity: CommunicationSenderIdentity.hostPersonalDevice,
            deliveryMode: CommunicationDeliveryMode.externalHandoff,
            consentScope: CommunicationConsentScope.directUserAction,
            observability: CommunicationObservability.none,
            requiresHostFinalSend: true,
            supportsReplies: true,
            supportsScheduling: false,
          ),
      CommunicationRouteId.organizerWhatsappCampaign:
          CommunicationRouteCapability(
            id: CommunicationRouteId.organizerWhatsappCampaign,
            transport: CommunicationTransport.whatsapp,
            adapterKey: 'meta_whatsapp_business',
            senderIdentity: CommunicationSenderIdentity.organizerManaged,
            deliveryMode: CommunicationDeliveryMode.campaign,
            consentScope: CommunicationConsentScope.organizerMarketing,
            observability: CommunicationObservability.providerReceipts,
            requiresHostFinalSend: false,
            supportsReplies: true,
            supportsScheduling: true,
          ),
      CommunicationRouteId.catchWhatsapp: CommunicationRouteCapability(
        id: CommunicationRouteId.catchWhatsapp,
        transport: CommunicationTransport.whatsapp,
        adapterKey: 'catch_whatsapp_business',
        senderIdentity: CommunicationSenderIdentity.catchPlatform,
        deliveryMode: CommunicationDeliveryMode.platformMessage,
        consentScope: CommunicationConsentScope.catchMessaging,
        observability: CommunicationObservability.providerReceipts,
        requiresHostFinalSend: false,
        supportsReplies: true,
        supportsScheduling: true,
      ),
      CommunicationRouteId.catchChat: CommunicationRouteCapability(
        id: CommunicationRouteId.catchChat,
        transport: CommunicationTransport.catchApp,
        adapterKey: 'catch_chat',
        senderIdentity: CommunicationSenderIdentity.organizerManaged,
        deliveryMode: CommunicationDeliveryMode.directConversation,
        consentScope: CommunicationConsentScope.linkedCatchAccount,
        observability: CommunicationObservability.catchActivity,
        requiresHostFinalSend: false,
        supportsReplies: true,
        supportsScheduling: false,
      ),
      CommunicationRouteId.catchEventAnnouncement: CommunicationRouteCapability(
        id: CommunicationRouteId.catchEventAnnouncement,
        transport: CommunicationTransport.catchApp,
        adapterKey: 'catch_activity_push',
        senderIdentity: CommunicationSenderIdentity.organizerManaged,
        deliveryMode: CommunicationDeliveryMode.eventAnnouncement,
        consentScope: CommunicationConsentScope.eventService,
        observability: CommunicationObservability.catchActivity,
        requiresHostFinalSend: false,
        supportsReplies: false,
        supportsScheduling: false,
      ),
      CommunicationRouteId.organizerFollowerUpdate:
          CommunicationRouteCapability(
            id: CommunicationRouteId.organizerFollowerUpdate,
            transport: CommunicationTransport.catchApp,
            adapterKey: 'catch_activity_push',
            senderIdentity: CommunicationSenderIdentity.organizerManaged,
            deliveryMode: CommunicationDeliveryMode.followerUpdate,
            consentScope: CommunicationConsentScope.followPreference,
            observability: CommunicationObservability.catchActivity,
            requiresHostFinalSend: false,
            supportsReplies: false,
            supportsScheduling: false,
          ),
    };

CommunicationRouteCapability communicationRouteCapability(
  CommunicationRouteId id,
) => communicationRouteCatalog[id]!;
