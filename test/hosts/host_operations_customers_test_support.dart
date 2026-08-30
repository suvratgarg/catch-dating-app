part of 'host_operations_screen_test.dart';

HostCustomerDirectoryContact _customerDirectoryContact({
  bool hasAmbiguousIdentity = false,
}) => HostCustomerDirectoryContact(
  contactId: 'contact-1',
  displayName: 'Ananya Rao',
  attendedEventCount: 8,
  lastAttendedAt: null,
  tags: const {HostCustomerTag.regular},
  hasAmbiguousIdentity: hasAmbiguousIdentity,
  whatsappOptedIn: false,
  whatsappAdminSuppressed: false,
);

HostCustomersDirectoryState _customerDirectoryState() =>
    HostCustomersDirectoryState(
      contacts: [_customerDirectoryContact()],
      nextCursor: null,
      matchCount: 1,
      matchCountCoverage: HostCustomerMatchCountCoverage.exact,
      sourceCoverage: HostCustomerDirectoryCoverage.exact,
      projectionVersion: 1,
    );

HostCustomersDirectoryState _emptyCustomerDirectoryState() =>
    const HostCustomersDirectoryState(
      contacts: [],
      nextCursor: null,
      matchCount: 0,
      matchCountCoverage: HostCustomerMatchCountCoverage.exact,
      sourceCoverage: HostCustomerDirectoryCoverage.exact,
      projectionVersion: 1,
    );

HostMessagingSetup _hostMessagingSetup({
  required String organizerId,
  bool providerConfigured = true,
  String connectionStatus = 'active',
}) => HostMessagingSetup(
  organizerId: organizerId,
  providerConfigured: providerConfigured,
  embeddedSignup: const HostWhatsappEmbeddedSignupConfig(
    appId: 'app-id',
    configId: 'config-id',
    graphVersion: 'v24.0',
  ),
  connection: HostWhatsappConnection(
    connectionId: 'connection-1',
    status: connectionStatus,
    displayPhoneNumber: '+91 98765 43210',
    verifiedName: 'Catch Social',
    qualityRating: 'GREEN',
    messagingLimitTier: 'TIER_1K',
    templateSyncStatus: 'ready',
    webhookStatus: 'healthy',
    testStatus: 'verified',
    revision: 1,
  ),
  templates: const [],
);

HostAudienceContactDetail _customerDetail({
  bool contactDetailsEditable = false,
  bool linkedAccount = true,
  HostAudienceIdentityState identityState = HostAudienceIdentityState.verified,
  String identityConfidence = 'verified_account',
  String? phoneE164,
}) => HostAudienceContactDetail(
  organizerId: 'organizer-1',
  contactId: 'contact-1',
  displayName: 'Ananya Rao',
  sourceDisplayName: 'Ananya Rao',
  displayNameOverride: null,
  phoneE164: phoneE164,
  email: null,
  linkedAccount: linkedAccount,
  identityState: identityState,
  identityConfidence: identityConfidence,
  contactDetailsEditable: contactDetailsEditable,
  ambiguousCandidateCount: 0,
  whatsappAdminSuppressed: false,
  whatsappPermission: HostCustomerWhatsappPermission(
    status: HostAudiencePermissionStatus.optedIn,
    evidenceStatus: HostCustomerPermissionEvidenceStatus.complete,
    receiptId: 'receipt-1',
    source: 'hostFormResponse',
    sourceFormId: 'form-1',
    sourceFormTitle: 'Sunday Run sign-up',
    decisionAt: DateTime(2026, 7, 20),
    identityStrength: 'phoneVerified',
  ),
  origins: [
    HostCustomerOrigin(
      originId: 'origin-1',
      sourceKind: HostCustomerOriginSourceKind.hostForm,
      sourceEntityKind: 'hostFormResponse',
      formId: 'form-1',
      formTitle: 'Sunday Run sign-up',
      eventId: 'event-1',
      eventTitle: 'Sunday Run Club',
      observedAt: DateTime(2026, 7, 20),
    ),
  ],
  originsTruncated: false,
  traits: const HostCustomerTraits(
    expectedEventCount: 1,
    attendedEventCount: 1,
    cancelledEventCount: 0,
    noShowCount: 0,
    importedEventCount: 0,
    attendanceRate: 1,
    segments: {HostAudienceSegment.regular},
    whatsappStatus: HostAudiencePermissionStatus.optedIn,
    sourceCoverage: HostAudienceSourceCoverage.exact,
  ),
  revenue: const HostCustomerRevenue(
    coverage: HostCustomerRevenueCoverage.exact,
    amounts: [],
  ),
  events: [
    HostAudienceEventFact(
      eventId: 'event-1',
      displayName: 'Sunday Run Club',
      eventOrigin: HostCustomerEventOrigin.externalCompanion,
      eventProvider: 'eventbrite',
      source: 'attendance',
      status: 'attended',
      checkedIn: true,
      eventStartAt: DateTime(2026, 8),
      revenues: const [
        HostCustomerEventRevenue(
          currency: 'INR',
          amountMinor: 125000,
          source: HostCustomerRevenueSource.hostImport,
          factCount: 1,
          allocation: HostCustomerRevenueAllocation.perAttendee,
        ),
      ],
    ),
  ],
  eventsTruncated: false,
  manualTags: const [
    HostManualTag(
      tagId: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      label: 'Brings friends',
    ),
  ],
  manualTagVocabulary: const [
    HostManualTag(
      tagId: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      label: 'Brings friends',
    ),
    HostManualTag(
      tagId: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      label: 'Prefers weekends',
    ),
  ],
  notes: [
    HostCustomerNote(
      noteId: 'note-1',
      body: 'Introduced three friends.',
      authorUid: _hostUid,
      createdAt: DateTime(2026, 8, 15),
      updatedAt: DateTime(2026, 8, 15),
      revision: 1,
    ),
  ],
  sends: [
    HostCustomerSend(
      campaignId: 'campaign-1',
      name: 'August invite',
      messageClass: 'organizerPromotion',
      deliveryStatus: HostCustomerSendDeliveryStatus.delivered,
      createdAt: DateTime(2026, 8, 14),
      sentAt: DateTime(2026, 8, 14),
      updatedAt: DateTime(2026, 8, 14),
    ),
  ],
  timeline: [
    HostCustomerReplyTimelineEntry(
      timelineId: 'reply-1',
      occurredAt: DateTime(2026, 8, 16),
      transport: HostCustomerReplyTransport.catchChat,
      direction: HostWhatsappMessageDirection.inbound,
      bodyPreview: 'See you there!',
      threadId: 'match-1',
    ),
    HostCustomerEventTimelineEntry(
      timelineId: 'event-1',
      occurredAt: DateTime(2026, 8),
      eventId: 'event-1',
      eventName: 'Sunday Run Club',
      status: 'checkedIn',
      checkedIn: true,
      eventOrigin: HostCustomerEventOrigin.externalCompanion,
      eventProvider: 'eventbrite',
    ),
    HostCustomerFormTimelineEntry(
      timelineId: 'form-1',
      occurredAt: DateTime(2026, 7, 20),
      responseId: 'response-1',
      formId: 'form-1',
      formTitle: 'Sunday Run sign-up',
      action: HostCustomerFormTimelineAction.submitted,
      answeredQuestionCount: 3,
    ),
  ],
  timelineTruncated: false,
  timelineCoverage: const HostCustomerTimelineCoverage(
    forms: HostCustomerTimelineCoverageValue.exact,
    events: HostCustomerTimelineCoverageValue.exact,
    sends: HostCustomerTimelineCoverageValue.exact,
    replies: HostCustomerTimelineCoverageValue.partial,
  ),
  revision: 1,
);

HostCommunicationPlan _individualCommunicationPlan({
  bool catchChatAvailable = true,
  HostCommunicationRouteBlocker? catchChatBlocker,
  bool whatsappHandoffAvailable = true,
  HostCommunicationRouteBlocker? whatsappHandoffBlocker,
}) {
  final recommendedRouteId = catchChatAvailable
      ? HostCommunicationRouteId.catchChat
      : whatsappHandoffAvailable
      ? HostCommunicationRouteId.personalWhatsappHandoff
      : null;
  return HostCommunicationPlan(
    organizerId: 'organizer-1',
    intent: HostCommunicationIntent.individualConversation,
    capabilityVersion: 1,
    resolvedAt: DateTime(2026, 8, 29),
    recipients: [
      HostCommunicationRecipientPlan(
        contactId: 'contact-1',
        displayName: 'Ananya Rao',
        outcome: catchChatAvailable
            ? HostCommunicationOutcome.inCatch
            : whatsappHandoffAvailable
            ? HostCommunicationOutcome.byHand
            : HostCommunicationOutcome.unavailable,
        recommendedRouteId: recommendedRouteId,
        routes: [
          HostCommunicationRouteOption(
            routeId: HostCommunicationRouteId.catchChat,
            executionMode: HostCommunicationExecutionMode.managedDelivery,
            availability: catchChatAvailable
                ? HostCommunicationRouteAvailability.available
                : HostCommunicationRouteAvailability.unavailable,
            blocker: catchChatAvailable
                ? null
                : catchChatBlocker ??
                      HostCommunicationRouteBlocker.catchAccountRequired,
          ),
          HostCommunicationRouteOption(
            routeId: HostCommunicationRouteId.personalWhatsappHandoff,
            executionMode: HostCommunicationExecutionMode.externalHandoff,
            availability: whatsappHandoffAvailable
                ? HostCommunicationRouteAvailability.available
                : HostCommunicationRouteAvailability.unavailable,
            blocker: whatsappHandoffAvailable
                ? null
                : whatsappHandoffBlocker ??
                      HostCommunicationRouteBlocker.missingPhone,
          ),
        ],
      ),
    ],
  );
}

class _FixedHostCustomersDirectoryController
    extends HostCustomersDirectoryController {
  _FixedHostCustomersDirectoryController(this.requests, this.value);

  final List<HostCustomersDirectoryRequest> requests;
  final HostCustomersDirectoryState value;

  @override
  Future<HostCustomersDirectoryState> build(
    HostCustomersDirectoryRequest request,
  ) async {
    requests.add(request);
    return value;
  }
}
