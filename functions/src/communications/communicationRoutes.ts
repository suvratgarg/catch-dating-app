/**
 * A communication route is more specific than its transport.
 *
 * In particular, Catch-owned WhatsApp and organizer-owned WhatsApp must never
 * share sender, consent, or suppression state merely because both use Meta.
 */
export type CommunicationTransport = "catchApp" | "whatsapp";

export type CommunicationRouteDefinition = Readonly<{
  id:
    | "personalWhatsappHandoff"
    | "organizerWhatsappCampaign"
    | "catchWhatsapp"
    | "catchChat"
    | "catchEventAnnouncement"
    | "organizerFollowerUpdate";
  transport: CommunicationTransport;
  adapterKey: string;
  senderIdentity: "hostPersonalDevice" | "organizerManaged" | "catchPlatform";
  deliveryMode:
    | "externalHandoff"
    | "directConversation"
    | "campaign"
    | "eventAnnouncement"
    | "followerUpdate"
    | "platformMessage";
  audienceScope:
    | "singleContact"
    | "organizerCrmSegment"
    | "catchPermissionedAudience"
    | "linkedCatchAccount"
    | "eventRoster"
    | "organizerFollowers";
  consentScope:
    | "directUserAction"
    | "linkedCatchAccount"
    | "eventService"
    | "organizerMarketing"
    | "followPreference"
    | "catchMessaging";
  observability: "none" | "catchActivity" | "providerReceipts";
  requiresHostFinalSend: boolean;
  supportsReplies: boolean;
  supportsScheduling: boolean;
}>;

export const communicationRoutes = {
  personalWhatsappHandoff: {
    id: "personalWhatsappHandoff",
    transport: "whatsapp",
    adapterKey: "whatsapp_handoff",
    senderIdentity: "hostPersonalDevice",
    deliveryMode: "externalHandoff",
    audienceScope: "singleContact",
    consentScope: "directUserAction",
    observability: "none",
    requiresHostFinalSend: true,
    supportsReplies: true,
    supportsScheduling: false,
  },
  organizerWhatsappCampaign: {
    id: "organizerWhatsappCampaign",
    transport: "whatsapp",
    adapterKey: "meta_whatsapp_business",
    senderIdentity: "organizerManaged",
    deliveryMode: "campaign",
    audienceScope: "organizerCrmSegment",
    consentScope: "organizerMarketing",
    observability: "providerReceipts",
    requiresHostFinalSend: false,
    supportsReplies: true,
    supportsScheduling: true,
  },
  catchWhatsapp: {
    id: "catchWhatsapp",
    transport: "whatsapp",
    adapterKey: "catch_whatsapp_business",
    senderIdentity: "catchPlatform",
    deliveryMode: "platformMessage",
    audienceScope: "catchPermissionedAudience",
    consentScope: "catchMessaging",
    observability: "providerReceipts",
    requiresHostFinalSend: false,
    supportsReplies: true,
    supportsScheduling: true,
  },
  catchChat: {
    id: "catchChat",
    transport: "catchApp",
    adapterKey: "catch_chat",
    senderIdentity: "organizerManaged",
    deliveryMode: "directConversation",
    audienceScope: "linkedCatchAccount",
    consentScope: "linkedCatchAccount",
    observability: "catchActivity",
    requiresHostFinalSend: false,
    supportsReplies: true,
    supportsScheduling: false,
  },
  catchEventAnnouncement: {
    id: "catchEventAnnouncement",
    transport: "catchApp",
    adapterKey: "catch_activity_push",
    senderIdentity: "organizerManaged",
    deliveryMode: "eventAnnouncement",
    audienceScope: "eventRoster",
    consentScope: "eventService",
    observability: "catchActivity",
    requiresHostFinalSend: false,
    supportsReplies: false,
    supportsScheduling: false,
  },
  organizerFollowerUpdate: {
    id: "organizerFollowerUpdate",
    transport: "catchApp",
    adapterKey: "catch_activity_push",
    senderIdentity: "organizerManaged",
    deliveryMode: "followerUpdate",
    audienceScope: "organizerFollowers",
    consentScope: "followPreference",
    observability: "catchActivity",
    requiresHostFinalSend: false,
    supportsReplies: false,
    supportsScheduling: false,
  },
} as const satisfies Record<
  CommunicationRouteDefinition["id"],
  CommunicationRouteDefinition
>;

export const organizerWhatsappCampaignRoute =
  communicationRoutes.organizerWhatsappCampaign;
