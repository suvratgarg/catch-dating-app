// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

/// UI-relevant constraints projected from patch and Firestore document schemas.
class CatchContractFieldConstraints {
  const CatchContractFieldConstraints({
    required this.path,
    this.maxLength,
    this.minLength,
    this.required = false,
    this.pattern,
    this.enumValues,
    this.minimum,
    this.maximum,
  });

  final String path;
  final int? maxLength;
  final int? minLength;
  final bool required;
  final String? pattern;
  final List<String>? enumValues;
  final num? minimum;
  final num? maximum;
}

abstract final class CatchContractConstraints {
  static const activityNotificationDocumentActorName = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.actorName',
    maxLength: 120,
  );

  static const activityNotificationDocumentActorUid = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.actorUid',
    maxLength: 180,
    minLength: 1,
  );

  static const activityNotificationDocumentBody = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.body',
    maxLength: 500,
    minLength: 1,
    required: true,
  );

  static const activityNotificationDocumentClubId = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.clubId',
    maxLength: 180,
    minLength: 1,
  );

  static const activityNotificationDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const activityNotificationDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.createdAt._seconds',
    required: true,
  );

  static const activityNotificationDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const activityNotificationDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const activityNotificationDocumentEventId = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.eventId',
    maxLength: 180,
    minLength: 1,
  );

  static const activityNotificationDocumentMatchId = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.matchId',
    maxLength: 240,
    minLength: 1,
  );

  static const activityNotificationDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.organizerId',
    maxLength: 180,
    minLength: 1,
  );

  static const activityNotificationDocumentPostId = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.postId',
    maxLength: 180,
    minLength: 1,
  );

  static const activityNotificationDocumentReadAtNanoseconds = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.readAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const activityNotificationDocumentReadAtSeconds = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.readAt._seconds',
    required: true,
  );

  static const activityNotificationDocumentScenario = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const activityNotificationDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const activityNotificationDocumentTitle = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.title',
    maxLength: 160,
    minLength: 1,
    required: true,
  );

  static const activityNotificationDocumentType = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.type',
    required: true,
    enumValues: <String>['message', 'match', 'eventReminder', 'eventSignup', 'waitlistPromotion', 'waitlistOffer', 'waitlistOfferExpiring', 'waitlistOfferExpired', 'eventCancelled', 'eventUpdated', 'clubUpdate', 'organizerUpdate'],
  );

  static const activityNotificationDocumentUid = CatchContractFieldConstraints(
    path: 'activityNotificationDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const adminUpdateClubDetailsCallablePayloadClubId = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsAppVisibility = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.appVisibility',
    enumValues: <String>['discoverable', 'hidden'],
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsArea = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.area',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsCityName = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.cityName',
    maxLength: 120,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsCountryCode = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.countryCode',
    pattern: '^[A-Z]{2}\$',
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsCountryName = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.countryName',
    maxLength: 120,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsDescription = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.description',
    maxLength: 2000,
    minLength: 1,
    required: true,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsDisplayCategory = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.displayCategory',
    maxLength: 120,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsEmail = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.email',
    maxLength: 320,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsEntityKind = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.entityKind',
    enumValues: <String>['club', 'venue', 'eventOrganizer', 'creatorCommunity', 'brand'],
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsImageUrl = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.imageUrl',
    maxLength: 2048,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsInstagramHandle = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.instagramHandle',
    maxLength: 320,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsLocation = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.location',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsName = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsOrganizerType = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.organizerType',
    enumValues: <String>['club', 'community', 'individual', 'eventProducer', 'venue', 'brand'],
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPhoneNumber = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.phoneNumber',
    maxLength: 320,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsProfileImageUrl = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.profileImageUrl',
    maxLength: 2048,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsProvenanceSourceConfidence = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.provenance.sourceConfidence',
    enumValues: <String>['seedOnly', 'low', 'medium', 'high', 'ownerVerified'],
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsProvenanceVerificationStatus = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.provenance.verificationStatus',
    enumValues: <String>['unverified', 'sourceBacked', 'ownerVerified'],
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicCategoryLabel = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicCategoryLabel',
    maxLength: 120,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicPageCanonicalPath = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicPage.canonicalPath',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicPageCitySlug = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicPage.citySlug',
    maxLength: 80,
    minLength: 1,
    pattern: '^[a-z0-9-]+\$',
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicPagePublishStatus = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicPage.publishStatus',
    enumValues: <String>['draft', 'qa', 'published', 'suppressed', 'removed'],
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicPageSeoDescription = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicPage.seoDescription',
    maxLength: 320,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicPageSeoTitle = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicPage.seoTitle',
    maxLength: 120,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicPageSlug = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicPage.slug',
    maxLength: 160,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicProfileHeadline = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicProfile.headline',
    maxLength: 160,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicProfileSourceSummary = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicProfile.sourceSummary',
    maxLength: 800,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsPublicProfileSummary = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.publicProfile.summary',
    maxLength: 800,
  );

  static const adminUpdateClubDetailsCallablePayloadFieldsRegionName = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.fields.regionName',
    maxLength: 120,
  );

  static const adminUpdateClubDetailsCallablePayloadReviewNote = CatchContractFieldConstraints(
    path: 'adminUpdateClubDetailsCallablePayload.reviewNote',
    maxLength: 1000,
  );

  static const adminUpdateEventDetailsCallablePayloadEventId = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsDescription = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.description',
    maxLength: 2000,
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsDistanceKm = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.distanceKm',
    minimum: 0,
    maximum: 100,
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatActivityKind = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.activityKind',
    required: true,
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatCustomActivityLabel = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.customActivityLabel',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatDefaultPlaybookId = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.defaultPlaybookId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesAssignmentAlgorithm = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.assignmentAlgorithm',
    enumValues: <String>['none', 'pacePods', 'socialPods', 'pairRotations', 'teamBalancer', 'tableSeating'],
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesCompatibilityPolicy = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.compatibilityPolicy',
    enumValues: <String>['none', 'socialCohortBalance', 'mutualInterestOnly', 'questionnaireClueOnly'],
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesPhoneAvailability = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.phoneAvailability',
    enumValues: <String>['continuous', 'plannedPauses', 'arrivalAndPostEventOnly', 'hostOnlyLive', 'noneDuringActivity'],
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesRotationSuitability = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.rotationSuitability',
    enumValues: <String>['none', 'plannedBreaks', 'continuousRounds'],
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatInteractionModel = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.interactionModel',
    required: true,
    enumValues: <String>['pacePods', 'pairedRotations', 'teamRotations', 'seatedTable', 'freeFormMixer', 'hostLedProgram', 'openFormat'],
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsEventFormatVersion = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.eventFormat.version',
    required: true,
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsPace = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.pace',
    enumValues: <String>['easy', 'moderate', 'fast', 'competitive'],
  );

  static const adminUpdateEventDetailsCallablePayloadFieldsPhotoUrl = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.fields.photoUrl',
    maxLength: 2048,
  );

  static const adminUpdateEventDetailsCallablePayloadReviewNote = CatchContractFieldConstraints(
    path: 'adminUpdateEventDetailsCallablePayload.reviewNote',
    maxLength: 1000,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsAppVisibility = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.appVisibility',
    enumValues: <String>['discoverable', 'hidden'],
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsArea = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.area',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsCityName = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.cityName',
    maxLength: 120,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsCountryCode = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.countryCode',
    pattern: '^[A-Z]{2}\$',
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsCountryName = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.countryName',
    maxLength: 120,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsDescription = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.description',
    maxLength: 2000,
    minLength: 1,
    required: true,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsDisplayCategory = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.displayCategory',
    maxLength: 120,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsEmail = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.email',
    maxLength: 320,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsEntityKind = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.entityKind',
    enumValues: <String>['club', 'venue', 'eventOrganizer', 'creatorCommunity', 'brand'],
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsImageUrl = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.imageUrl',
    maxLength: 2048,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsInstagramHandle = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.instagramHandle',
    maxLength: 320,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsLocation = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.location',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsName = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsOrganizerType = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.organizerType',
    enumValues: <String>['club', 'community', 'individual', 'eventProducer', 'venue', 'brand'],
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPhoneNumber = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.phoneNumber',
    maxLength: 320,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsProfileImageUrl = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.profileImageUrl',
    maxLength: 2048,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsProvenanceSourceConfidence = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.provenance.sourceConfidence',
    enumValues: <String>['seedOnly', 'low', 'medium', 'high', 'ownerVerified'],
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsProvenanceVerificationStatus = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.provenance.verificationStatus',
    enumValues: <String>['unverified', 'sourceBacked', 'ownerVerified'],
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicCategoryLabel = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicCategoryLabel',
    maxLength: 120,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageCanonicalPath = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.canonicalPath',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageCitySlug = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.citySlug',
    maxLength: 80,
    minLength: 1,
    pattern: '^[a-z0-9-]+\$',
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPagePublishStatus = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.publishStatus',
    enumValues: <String>['draft', 'qa', 'published', 'suppressed', 'removed'],
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageSeoDescription = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.seoDescription',
    maxLength: 320,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageSeoTitle = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.seoTitle',
    maxLength: 120,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageSlug = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.slug',
    maxLength: 160,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicProfileHeadline = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicProfile.headline',
    maxLength: 160,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicProfileSourceSummary = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicProfile.sourceSummary',
    maxLength: 800,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsPublicProfileSummary = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.publicProfile.summary',
    maxLength: 800,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadFieldsRegionName = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.fields.regionName',
    maxLength: 120,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadOrganizerId = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const adminUpdateOrganizerDetailsCallablePayloadReviewNote = CatchContractFieldConstraints(
    path: 'adminUpdateOrganizerDetailsCallablePayload.reviewNote',
    maxLength: 1000,
  );

  static const blockDocumentBlockedUserId = CatchContractFieldConstraints(
    path: 'blockDocument.blockedUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const blockDocumentBlockerUserId = CatchContractFieldConstraints(
    path: 'blockDocument.blockerUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const blockDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'blockDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const blockDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'blockDocument.createdAt._seconds',
    required: true,
  );

  static const blockDocumentReasonCode = CatchContractFieldConstraints(
    path: 'blockDocument.reasonCode',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const blockDocumentSource = CatchContractFieldConstraints(
    path: 'blockDocument.source',
    required: true,
    enumValues: <String>['profile', 'chat', 'match', 'support'],
  );

  static const chatMessageDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'chatMessageDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const chatMessageDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'chatMessageDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const chatMessageDocumentImageUrl = CatchContractFieldConstraints(
    path: 'chatMessageDocument.imageUrl',
    maxLength: 2048,
  );

  static const chatMessageDocumentScenario = CatchContractFieldConstraints(
    path: 'chatMessageDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const chatMessageDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'chatMessageDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const chatMessageDocumentSenderId = CatchContractFieldConstraints(
    path: 'chatMessageDocument.senderId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const chatMessageDocumentSentAtNanoseconds = CatchContractFieldConstraints(
    path: 'chatMessageDocument.sentAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const chatMessageDocumentSentAtSeconds = CatchContractFieldConstraints(
    path: 'chatMessageDocument.sentAt._seconds',
    required: true,
  );

  static const chatMessageDocumentText = CatchContractFieldConstraints(
    path: 'chatMessageDocument.text',
    maxLength: 2000,
    required: true,
  );

  static const clubClaimRequestDocumentBusinessEmail = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.businessEmail',
    maxLength: 320,
  );

  static const clubClaimRequestDocumentBusinessPhone = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.businessPhone',
    maxLength: 32,
  );

  static const clubClaimRequestDocumentClubId = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubClaimRequestDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubClaimRequestDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.createdAt._seconds',
    required: true,
  );

  static const clubClaimRequestDocumentDecidedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.decidedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubClaimRequestDocumentDecidedAtSeconds = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.decidedAt._seconds',
    required: true,
  );

  static const clubClaimRequestDocumentDecidedByUid = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.decidedByUid',
    maxLength: 180,
    minLength: 1,
  );

  static const clubClaimRequestDocumentDecisionReason = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.decisionReason',
    maxLength: 1000,
  );

  static const clubClaimRequestDocumentMessage = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.message',
    maxLength: 1000,
  );

  static const clubClaimRequestDocumentPreviousRequestId = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.previousRequestId',
    maxLength: 180,
    minLength: 1,
  );

  static const clubClaimRequestDocumentProofUrls = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.proofUrls',
    required: true,
  );

  static const clubClaimRequestDocumentRequesterName = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.requesterName',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubClaimRequestDocumentRequesterRole = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.requesterRole',
    required: true,
    enumValues: <String>['owner', 'founder', 'manager', 'marketer', 'venueManager', 'other'],
  );

  static const clubClaimRequestDocumentRequesterUid = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.requesterUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubClaimRequestDocumentRequestId = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.requestId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubClaimRequestDocumentStatus = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.status',
    required: true,
    enumValues: <String>['pending', 'approved', 'rejected', 'withdrawn', 'superseded'],
  );

  static const clubClaimRequestDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubClaimRequestDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubClaimRequestDocument.updatedAt._seconds',
    required: true,
  );

  static const clubDocumentAdminSearchSortKey = CatchContractFieldConstraints(
    path: 'clubDocument.adminSearch.sortKey',
    maxLength: 160,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+(?:-[a-z0-9-]+)*\$',
  );

  static const clubDocumentAdminSearchTokens = CatchContractFieldConstraints(
    path: 'clubDocument.adminSearch.tokens',
    required: true,
  );

  static const clubDocumentAdminSearchUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.adminSearch.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentAdminSearchUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.adminSearch.updatedAt._seconds',
    required: true,
  );

  static const clubDocumentAdminSearchUpdatedBySource = CatchContractFieldConstraints(
    path: 'clubDocument.adminSearch.updatedBySource',
    required: true,
    enumValues: <String>['adminUpdateClubDetails', 'adminSetClubIndexStatus', 'adminOrganizerSearchBackfill'],
  );

  static const clubDocumentAppVisibility = CatchContractFieldConstraints(
    path: 'clubDocument.appVisibility',
    enumValues: <String>['discoverable', 'hidden'],
  );

  static const clubDocumentArchived = CatchContractFieldConstraints(
    path: 'clubDocument.archived',
    required: true,
  );

  static const clubDocumentArchivedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.archivedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentArchivedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.archivedAt._seconds',
    required: true,
  );

  static const clubDocumentArchiveReason = CatchContractFieldConstraints(
    path: 'clubDocument.archiveReason',
    maxLength: 500,
  );

  static const clubDocumentArea = CatchContractFieldConstraints(
    path: 'clubDocument.area',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubDocumentCityName = CatchContractFieldConstraints(
    path: 'clubDocument.cityName',
    maxLength: 120,
  );

  static const clubDocumentClaimClaimHref = CatchContractFieldConstraints(
    path: 'clubDocument.claim.claimHref',
    maxLength: 240,
  );

  static const clubDocumentClaimLastClaimRequestId = CatchContractFieldConstraints(
    path: 'clubDocument.claim.lastClaimRequestId',
    maxLength: 180,
    minLength: 1,
  );

  static const clubDocumentClaimState = CatchContractFieldConstraints(
    path: 'clubDocument.claim.state',
    required: true,
    enumValues: <String>['unclaimed', 'claimPending', 'claimed', 'verified', 'suppressed'],
  );

  static const clubDocumentCountryCode = CatchContractFieldConstraints(
    path: 'clubDocument.countryCode',
    pattern: '^[A-Z]{2}\$',
  );

  static const clubDocumentCountryName = CatchContractFieldConstraints(
    path: 'clubDocument.countryName',
    maxLength: 120,
  );

  static const clubDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.createdAt._seconds',
    required: true,
  );

  static const clubDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'clubDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const clubDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'clubDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubDocumentDescription = CatchContractFieldConstraints(
    path: 'clubDocument.description',
    maxLength: 2000,
    minLength: 1,
    required: true,
  );

  static const clubDocumentDisplayCategory = CatchContractFieldConstraints(
    path: 'clubDocument.displayCategory',
    maxLength: 120,
  );

  static const clubDocumentEmail = CatchContractFieldConstraints(
    path: 'clubDocument.email',
    maxLength: 320,
  );

  static const clubDocumentEntityKind = CatchContractFieldConstraints(
    path: 'clubDocument.entityKind',
    enumValues: <String>['club', 'venue', 'eventOrganizer', 'creatorCommunity', 'brand'],
  );

  static const clubDocumentHostAvatarUrl = CatchContractFieldConstraints(
    path: 'clubDocument.hostAvatarUrl',
    maxLength: 2048,
  );

  static const clubDocumentHostDefaultsEventPolicyAdmissionPreset = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.admissionPreset',
    enumValues: <String>['openCapacity', 'inviteOnly', 'balancedSingles', 'fixedCohortCaps'],
  );

  static const clubDocumentHostDefaultsEventPolicyCancellationPolicyId = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.cancellationPolicyId',
    enumValues: <String>['flexible', 'standard', 'strict'],
  );

  static const clubDocumentHostDefaultsEventPolicyDynamicPricingMaxInPaise = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.dynamicPricingMaxInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const clubDocumentHostDefaultsEventPolicyDynamicPricingStepInPaise = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.dynamicPricingStepInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const clubDocumentHostDefaultsEventPolicyMaxAge = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.maxAge',
    minimum: 0,
    maximum: 120,
  );

  static const clubDocumentHostDefaultsEventPolicyMaxMen = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.maxMen',
    minimum: 0,
  );

  static const clubDocumentHostDefaultsEventPolicyMaxWomen = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.maxWomen',
    minimum: 0,
  );

  static const clubDocumentHostDefaultsEventPolicyMinAge = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventPolicy.minAge',
    minimum: 0,
    maximum: 120,
  );

  static const clubDocumentHostDefaultsEventSuccessAttendeePrompt = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.attendeePrompt',
    maxLength: 300,
  );

  static const clubDocumentHostDefaultsEventSuccessHostGoal = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.hostGoal',
    maxLength: 300,
  );

  static const clubDocumentHostDefaultsEventSuccessPlaybookId = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.playbookId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubDocumentHostDefaultsEventSuccessQuestionnaireConfigCustomTitle = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.questionnaireConfig.customTitle',
    maxLength: 80,
  );

  static const clubDocumentHostDefaultsEventSuccessQuestionnaireConfigTemplateId = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.questionnaireConfig.templateId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubDocumentHostDefaultsEventSuccessStructureConfigMaxPairMeetings = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.structureConfig.maxPairMeetings',
    minimum: 1,
    maximum: 10,
  );

  static const clubDocumentHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds',
    required: true,
    minimum: 0,
    maximum: 60,
  );

  static const clubDocumentHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes',
    minimum: 5,
    maximum: 180,
  );

  static const clubDocumentHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy',
    enumValues: <String>['avoid', 'allowWhenExhausted'],
  );

  static const clubDocumentHostDefaultsEventSuccessStructureConfigUnitCount = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.structureConfig.unitCount',
    minimum: 1,
    maximum: 200,
  );

  static const clubDocumentHostDefaultsEventSuccessStructureConfigUnitKind = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.structureConfig.unitKind',
    required: true,
    enumValues: <String>['wholeGroup', 'pods', 'pairs', 'teams', 'tables'],
  );

  static const clubDocumentHostDefaultsEventSuccessStructureConfigUnitSize = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.eventSuccess.structureConfig.unitSize',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const clubDocumentHostDefaultsPrimaryActivityKind = CatchContractFieldConstraints(
    path: 'clubDocument.hostDefaults.primaryActivityKind',
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const clubDocumentHostName = CatchContractFieldConstraints(
    path: 'clubDocument.hostName',
    maxLength: 120,
  );

  static const clubDocumentHostProfiles = CatchContractFieldConstraints(
    path: 'clubDocument.hostProfiles',
    required: true,
  );

  static const clubDocumentHostUserId = CatchContractFieldConstraints(
    path: 'clubDocument.hostUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const clubDocumentHostUserIds = CatchContractFieldConstraints(
    path: 'clubDocument.hostUserIds',
    required: true,
  );

  static const clubDocumentImageUrl = CatchContractFieldConstraints(
    path: 'clubDocument.imageUrl',
    maxLength: 2048,
  );

  static const clubDocumentInstagramHandle = CatchContractFieldConstraints(
    path: 'clubDocument.instagramHandle',
    maxLength: 320,
  );

  static const clubDocumentLocation = CatchContractFieldConstraints(
    path: 'clubDocument.location',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const clubDocumentLocationCityId = CatchContractFieldConstraints(
    path: 'clubDocument.locationCityId',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const clubDocumentLocationMarketId = CatchContractFieldConstraints(
    path: 'clubDocument.locationMarketId',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const clubDocumentLogoPhotoCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentLogoPhotoCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.createdAt._seconds',
    required: true,
  );

  static const clubDocumentLogoPhotoId = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.id',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[A-Za-z0-9_-]+\$',
  );

  static const clubDocumentLogoPhotoModerationReason = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.moderation.reason',
    maxLength: 240,
  );

  static const clubDocumentLogoPhotoModerationReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.moderation.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentLogoPhotoModerationReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.moderation.reviewedAt._seconds',
    required: true,
  );

  static const clubDocumentLogoPhotoModerationStatus = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.moderation.status',
    required: true,
    enumValues: <String>['pending', 'approved', 'rejected'],
  );

  static const clubDocumentLogoPhotoPosition = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.position',
    required: true,
    minimum: 0,
    maximum: 19,
  );

  static const clubDocumentLogoPhotoStoragePath = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.storagePath',
    maxLength: 512,
    minLength: 1,
    required: true,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const clubDocumentLogoPhotoThumbnailStoragePath = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.thumbnailStoragePath',
    maxLength: 512,
    minLength: 1,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const clubDocumentLogoPhotoThumbnailUrl = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.thumbnailUrl',
    maxLength: 2048,
  );

  static const clubDocumentLogoPhotoUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentLogoPhotoUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.updatedAt._seconds',
    required: true,
  );

  static const clubDocumentLogoPhotoUrl = CatchContractFieldConstraints(
    path: 'clubDocument.logoPhoto.url',
    maxLength: 2048,
    required: true,
  );

  static const clubDocumentMemberCount = CatchContractFieldConstraints(
    path: 'clubDocument.memberCount',
    required: true,
    minimum: 0,
  );

  static const clubDocumentName = CatchContractFieldConstraints(
    path: 'clubDocument.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubDocumentNextEventAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.nextEventAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentNextEventAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.nextEventAt._seconds',
    required: true,
  );

  static const clubDocumentNextEventLabel = CatchContractFieldConstraints(
    path: 'clubDocument.nextEventLabel',
    maxLength: 240,
  );

  static const clubDocumentOrganizerType = CatchContractFieldConstraints(
    path: 'clubDocument.organizerType',
    enumValues: <String>['club', 'community', 'individual', 'eventProducer', 'venue', 'brand'],
  );

  static const clubDocumentOrganizerTypeUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.organizerTypeUpdatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentOrganizerTypeUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.organizerTypeUpdatedAt._seconds',
    required: true,
  );

  static const clubDocumentOrganizerTypeUpdatedByUid = CatchContractFieldConstraints(
    path: 'clubDocument.organizerTypeUpdatedByUid',
    maxLength: 180,
    minLength: 1,
  );

  static const clubDocumentOwnershipClaimedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.ownership.claimedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentOwnershipClaimedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.ownership.claimedAt._seconds',
    required: true,
  );

  static const clubDocumentOwnershipClaimedByUid = CatchContractFieldConstraints(
    path: 'clubDocument.ownership.claimedByUid',
    maxLength: 180,
    minLength: 1,
  );

  static const clubDocumentOwnershipHostUserIds = CatchContractFieldConstraints(
    path: 'clubDocument.ownership.hostUserIds',
    required: true,
  );

  static const clubDocumentOwnershipOwnerUserId = CatchContractFieldConstraints(
    path: 'clubDocument.ownership.ownerUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const clubDocumentOwnershipPrimaryHostUserId = CatchContractFieldConstraints(
    path: 'clubDocument.ownership.primaryHostUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const clubDocumentOwnershipState = CatchContractFieldConstraints(
    path: 'clubDocument.ownership.state',
    required: true,
    enumValues: <String>['programmatic', 'userCreated', 'claimed', 'transferred'],
  );

  static const clubDocumentOwnerUserId = CatchContractFieldConstraints(
    path: 'clubDocument.ownerUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const clubDocumentPhoneNumber = CatchContractFieldConstraints(
    path: 'clubDocument.phoneNumber',
    maxLength: 320,
  );

  static const clubDocumentProfileImageUrl = CatchContractFieldConstraints(
    path: 'clubDocument.profileImageUrl',
    maxLength: 2048,
  );

  static const clubDocumentProvenanceLastVerifiedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.provenance.lastVerifiedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentProvenanceLastVerifiedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.provenance.lastVerifiedAt._seconds',
    required: true,
  );

  static const clubDocumentProvenanceOrigin = CatchContractFieldConstraints(
    path: 'clubDocument.provenance.origin',
    required: true,
    enumValues: <String>['userCreated', 'scraper', 'adminSeed', 'import'],
  );

  static const clubDocumentProvenanceSourceConfidence = CatchContractFieldConstraints(
    path: 'clubDocument.provenance.sourceConfidence',
    required: true,
    enumValues: <String>['seedOnly', 'low', 'medium', 'high', 'ownerVerified'],
  );

  static const clubDocumentProvenanceVerificationStatus = CatchContractFieldConstraints(
    path: 'clubDocument.provenance.verificationStatus',
    required: true,
    enumValues: <String>['unverified', 'sourceBacked', 'ownerVerified'],
  );

  static const clubDocumentPublicCategoryLabel = CatchContractFieldConstraints(
    path: 'clubDocument.publicCategoryLabel',
    maxLength: 120,
  );

  static const clubDocumentPublicPageCanonicalPath = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.canonicalPath',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const clubDocumentPublicPageCitySlug = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.citySlug',
    maxLength: 80,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const clubDocumentPublicPageIndexReviewChecklistCadenceVerified = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.checklist.cadenceVerified',
    required: true,
  );

  static const clubDocumentPublicPageIndexReviewChecklistMediaRightsVerified = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.checklist.mediaRightsVerified',
    required: true,
  );

  static const clubDocumentPublicPageIndexReviewChecklistOwnerContactVerified = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.checklist.ownerContactVerified',
    required: true,
  );

  static const clubDocumentPublicPageIndexReviewChecklistSourceEvidenceVerified = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.checklist.sourceEvidenceVerified',
    required: true,
  );

  static const clubDocumentPublicPageIndexReviewIndexStatus = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.indexStatus',
    required: true,
    enumValues: <String>['noindex', 'indexReady', 'indexed'],
  );

  static const clubDocumentPublicPageIndexReviewReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentPublicPageIndexReviewReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.reviewedAt._seconds',
    required: true,
  );

  static const clubDocumentPublicPageIndexReviewReviewedByUid = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubDocumentPublicPageIndexReviewReviewNote = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexReview.reviewNote',
    maxLength: 1000,
  );

  static const clubDocumentPublicPageIndexStatus = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.indexStatus',
    required: true,
    enumValues: <String>['noindex', 'indexReady', 'indexed'],
  );

  static const clubDocumentPublicPageLastRenderedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.lastRenderedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubDocumentPublicPageLastRenderedAtSeconds = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.lastRenderedAt._seconds',
    required: true,
  );

  static const clubDocumentPublicPagePublishStatus = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.publishStatus',
    required: true,
    enumValues: <String>['draft', 'qa', 'published', 'suppressed', 'removed'],
  );

  static const clubDocumentPublicPageRobots = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.robots',
    required: true,
    enumValues: <String>['noindex, follow', 'index, follow'],
  );

  static const clubDocumentPublicPageSeoDescription = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.seoDescription',
    maxLength: 320,
  );

  static const clubDocumentPublicPageSeoTitle = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.seoTitle',
    maxLength: 120,
  );

  static const clubDocumentPublicPageSlug = CatchContractFieldConstraints(
    path: 'clubDocument.publicPage.slug',
    maxLength: 160,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const clubDocumentPublicProfileHeadline = CatchContractFieldConstraints(
    path: 'clubDocument.publicProfile.headline',
    maxLength: 160,
  );

  static const clubDocumentPublicProfileSourceSummary = CatchContractFieldConstraints(
    path: 'clubDocument.publicProfile.sourceSummary',
    maxLength: 800,
  );

  static const clubDocumentPublicProfileSummary = CatchContractFieldConstraints(
    path: 'clubDocument.publicProfile.summary',
    maxLength: 800,
  );

  static const clubDocumentRating = CatchContractFieldConstraints(
    path: 'clubDocument.rating',
    required: true,
    minimum: 0,
    maximum: 5,
  );

  static const clubDocumentRegionName = CatchContractFieldConstraints(
    path: 'clubDocument.regionName',
    maxLength: 120,
  );

  static const clubDocumentReviewCount = CatchContractFieldConstraints(
    path: 'clubDocument.reviewCount',
    required: true,
    minimum: 0,
  );

  static const clubDocumentScenario = CatchContractFieldConstraints(
    path: 'clubDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'clubDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubDocumentStatus = CatchContractFieldConstraints(
    path: 'clubDocument.status',
    required: true,
    enumValues: <String>['active', 'archived'],
  );

  static const clubDocumentTags = CatchContractFieldConstraints(
    path: 'clubDocument.tags',
    required: true,
  );

  static const clubDocumentVerifiedReviewCount = CatchContractFieldConstraints(
    path: 'clubDocument.verifiedReviewCount',
    minimum: 0,
  );

  static const clubHostClaimDocumentClubId = CatchContractFieldConstraints(
    path: 'clubHostClaimDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubHostClaimDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubHostClaimDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubHostClaimDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubHostClaimDocument.createdAt._seconds',
    required: true,
  );

  static const clubHostClaimDocumentUid = CatchContractFieldConstraints(
    path: 'clubHostClaimDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubMembershipDocumentClubId = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubMembershipDocumentDeletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.deletedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubMembershipDocumentDeletedAtSeconds = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.deletedAt._seconds',
    required: true,
  );

  static const clubMembershipDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const clubMembershipDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubMembershipDocumentJoinedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.joinedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubMembershipDocumentJoinedAtSeconds = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.joinedAt._seconds',
    required: true,
  );

  static const clubMembershipDocumentLeftAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.leftAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubMembershipDocumentLeftAtSeconds = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.leftAt._seconds',
    required: true,
  );

  static const clubMembershipDocumentPushNotificationsEnabled = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.pushNotificationsEnabled',
    required: true,
  );

  static const clubMembershipDocumentRole = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.role',
    required: true,
    enumValues: <String>['owner', 'host', 'member'],
  );

  static const clubMembershipDocumentScenario = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubMembershipDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubMembershipDocumentStatus = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.status',
    required: true,
    enumValues: <String>['active', 'left', 'deleted'],
  );

  static const clubMembershipDocumentUid = CatchContractFieldConstraints(
    path: 'clubMembershipDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubPostDocumentAudience = CatchContractFieldConstraints(
    path: 'clubPostDocument.audience',
    required: true,
    enumValues: <String>['followers'],
  );

  static const clubPostDocumentAuthorUid = CatchContractFieldConstraints(
    path: 'clubPostDocument.authorUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubPostDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'clubPostDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const clubPostDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'clubPostDocument.createdAt._seconds',
    required: true,
  );

  static const clubPostDocumentEventId = CatchContractFieldConstraints(
    path: 'clubPostDocument.eventId',
    maxLength: 180,
    minLength: 1,
  );

  static const clubPostDocumentPhotoPath = CatchContractFieldConstraints(
    path: 'clubPostDocument.photoPath',
    maxLength: 500,
    minLength: 1,
  );

  static const clubPostDocumentStatus = CatchContractFieldConstraints(
    path: 'clubPostDocument.status',
    required: true,
    enumValues: <String>['active', 'removed'],
  );

  static const clubPostDocumentText = CatchContractFieldConstraints(
    path: 'clubPostDocument.text',
    maxLength: 500,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentClubId = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentEndTimeMillis = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.endTimeMillis',
    required: true,
    minimum: 0,
  );

  static const clubScheduleLockDocumentEventId = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentOwnerId = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.ownerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentOwnerType = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.ownerType',
    required: true,
  );

  static const clubScheduleLockDocumentScenario = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const clubScheduleLockDocumentSlot = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.slot',
    required: true,
    minimum: 0,
  );

  static const clubScheduleLockDocumentStartTimeMillis = CatchContractFieldConstraints(
    path: 'clubScheduleLockDocument.startTimeMillis',
    required: true,
    minimum: 0,
  );

  static const configCitiesDocumentCities = CatchContractFieldConstraints(
    path: 'configCitiesDocument.cities',
    required: true,
  );

  static const configCitiesDocumentCityNames = CatchContractFieldConstraints(
    path: 'configCitiesDocument.cityNames',
    required: true,
  );

  static const configCitiesDocumentLaunchMarketIds = CatchContractFieldConstraints(
    path: 'configCitiesDocument.launchMarketIds',
    required: true,
  );

  static const configCitiesDocumentMarketIds = CatchContractFieldConstraints(
    path: 'configCitiesDocument.marketIds',
    required: true,
  );

  static const configCitiesDocumentMarkets = CatchContractFieldConstraints(
    path: 'configCitiesDocument.markets',
    required: true,
  );

  static const configCitiesDocumentVersion = CatchContractFieldConstraints(
    path: 'configCitiesDocument.version',
    required: true,
    minimum: 2,
  );

  static const deletedUserTombstoneDocumentCompletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.completedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const deletedUserTombstoneDocumentCompletedAtSeconds = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.completedAt._seconds',
    required: true,
  );

  static const deletedUserTombstoneDocumentDeletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.deletedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const deletedUserTombstoneDocumentDeletedAtSeconds = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.deletedAt._seconds',
    required: true,
  );

  static const deletedUserTombstoneDocumentStatus = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.status',
    required: true,
    enumValues: <String>['processing', 'completed'],
  );

  static const deletedUserTombstoneDocumentUid = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const deletedUserTombstoneDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const deletedUserTombstoneDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'deletedUserTombstoneDocument.updatedAt._seconds',
    required: true,
  );

  static const eventBroadcastDocumentActivityAvailableCount = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.activityAvailableCount',
    required: true,
    minimum: 0,
    maximum: 500,
  );

  static const eventBroadcastDocumentActorUid = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.actorUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventBroadcastDocumentAudience = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.audience',
    required: true,
    enumValues: <String>['booked', 'prospective', 'everyone'],
  );

  static const eventBroadcastDocumentBody = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.body',
    maxLength: 500,
    minLength: 1,
    required: true,
  );

  static const eventBroadcastDocumentClubId = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventBroadcastDocumentCompletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.completedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventBroadcastDocumentCompletedAtSeconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.completedAt._seconds',
    required: true,
  );

  static const eventBroadcastDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventBroadcastDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.createdAt._seconds',
    required: true,
  );

  static const eventBroadcastDocumentDeliveries = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.deliveries',
    required: true,
  );

  static const eventBroadcastDocumentEventId = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventBroadcastDocumentExcludedCount = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.excludedCount',
    required: true,
    minimum: 0,
    maximum: 500,
  );

  static const eventBroadcastDocumentExpiresAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.expiresAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventBroadcastDocumentExpiresAtSeconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.expiresAt._seconds',
    required: true,
  );

  static const eventBroadcastDocumentLeaseExpiresAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.leaseExpiresAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventBroadcastDocumentLeaseExpiresAtSeconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.leaseExpiresAt._seconds',
    required: true,
  );

  static const eventBroadcastDocumentLeaseOwner = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.leaseOwner',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventBroadcastDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventBroadcastDocumentPushAcceptedCount = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.pushAcceptedCount',
    required: true,
    minimum: 0,
    maximum: 500,
  );

  static const eventBroadcastDocumentPushAttemptedCount = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.pushAttemptedCount',
    required: true,
    minimum: 0,
    maximum: 500,
  );

  static const eventBroadcastDocumentPushErrorCodes = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.pushErrorCodes',
    required: true,
  );

  static const eventBroadcastDocumentPushFailedCount = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.pushFailedCount',
    required: true,
    minimum: 0,
    maximum: 500,
  );

  static const eventBroadcastDocumentPushUnknownCount = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.pushUnknownCount',
    required: true,
    minimum: 0,
    maximum: 500,
  );

  static const eventBroadcastDocumentRecipientCount = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.recipientCount',
    required: true,
    minimum: 0,
    maximum: 500,
  );

  static const eventBroadcastDocumentStatus = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.status',
    required: true,
    enumValues: <String>['processing', 'completed', 'partial', 'failed'],
  );

  static const eventBroadcastDocumentTargetUids = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.targetUids',
    required: true,
  );

  static const eventBroadcastDocumentTitle = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.title',
    maxLength: 160,
    minLength: 1,
    required: true,
  );

  static const eventBroadcastDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventBroadcastDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventBroadcastDocument.updatedAt._seconds',
    required: true,
  );

  static const eventDocumentAdminSearchSortKey = CatchContractFieldConstraints(
    path: 'eventDocument.adminSearch.sortKey',
    maxLength: 160,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+(?:-[a-z0-9-]+)*\$',
  );

  static const eventDocumentAdminSearchTokens = CatchContractFieldConstraints(
    path: 'eventDocument.adminSearch.tokens',
    required: true,
  );

  static const eventDocumentAdminSearchUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventDocument.adminSearch.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventDocumentAdminSearchUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventDocument.adminSearch.updatedAt._seconds',
    required: true,
  );

  static const eventDocumentAdminSearchUpdatedBySource = CatchContractFieldConstraints(
    path: 'eventDocument.adminSearch.updatedBySource',
    required: true,
    enumValues: <String>['adminUpdateEventDetails', 'adminEventSearchBackfill'],
  );

  static const eventDocumentBookedCount = CatchContractFieldConstraints(
    path: 'eventDocument.bookedCount',
    required: true,
    minimum: 0,
  );

  static const eventDocumentCancellationReason = CatchContractFieldConstraints(
    path: 'eventDocument.cancellationReason',
    maxLength: 500,
  );

  static const eventDocumentCancelledAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventDocument.cancelledAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventDocumentCancelledAtSeconds = CatchContractFieldConstraints(
    path: 'eventDocument.cancelledAt._seconds',
    required: true,
  );

  static const eventDocumentCapacityLimit = CatchContractFieldConstraints(
    path: 'eventDocument.capacityLimit',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const eventDocumentCheckedInCount = CatchContractFieldConstraints(
    path: 'eventDocument.checkedInCount',
    required: true,
    minimum: 0,
  );

  static const eventDocumentClubId = CatchContractFieldConstraints(
    path: 'eventDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventDocumentCohortCounts = CatchContractFieldConstraints(
    path: 'eventDocument.cohortCounts',
    required: true,
  );

  static const eventDocumentConstraintsMaxAge = CatchContractFieldConstraints(
    path: 'eventDocument.constraints.maxAge',
    required: true,
    minimum: 0,
    maximum: 120,
  );

  static const eventDocumentConstraintsMaxMen = CatchContractFieldConstraints(
    path: 'eventDocument.constraints.maxMen',
    minimum: 0,
  );

  static const eventDocumentConstraintsMaxWomen = CatchContractFieldConstraints(
    path: 'eventDocument.constraints.maxWomen',
    minimum: 0,
  );

  static const eventDocumentConstraintsMinAge = CatchContractFieldConstraints(
    path: 'eventDocument.constraints.minAge',
    required: true,
    minimum: 0,
    maximum: 120,
  );

  static const eventDocumentCurrency = CatchContractFieldConstraints(
    path: 'eventDocument.currency',
    pattern: '^[A-Z]{3}\$',
  );

  static const eventDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventDocumentDescription = CatchContractFieldConstraints(
    path: 'eventDocument.description',
    maxLength: 2000,
    required: true,
  );

  static const eventDocumentDiscoveryActivityKind = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryActivityKind',
    required: true,
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const eventDocumentDiscoveryAvailability = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryAvailability',
    required: true,
    enumValues: <String>['open', 'waitlist', 'gated', 'full', 'cancelled'],
  );

  static const eventDocumentDiscoveryCityName = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryCityName',
    maxLength: 80,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const eventDocumentDiscoveryGeoCell = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryGeoCell',
    required: true,
    pattern: '^-?\\d+:-?\\d+\$',
  );

  static const eventDocumentDiscoveryHasOpenSpots = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryHasOpenSpots',
    required: true,
  );

  static const eventDocumentDiscoveryInviteRequired = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryInviteRequired',
    required: true,
  );

  static const eventDocumentDiscoveryManualApprovalRequired = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryManualApprovalRequired',
    required: true,
  );

  static const eventDocumentDiscoveryMarketId = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryMarketId',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const eventDocumentDiscoveryMaxAge = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryMaxAge',
    required: true,
    minimum: 0,
    maximum: 120,
  );

  static const eventDocumentDiscoveryMembershipRequired = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryMembershipRequired',
    required: true,
  );

  static const eventDocumentDiscoveryMinAge = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryMinAge',
    required: true,
    minimum: 0,
    maximum: 120,
  );

  static const eventDocumentDiscoveryOpenCohorts = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryOpenCohorts',
    required: true,
  );

  static const eventDocumentDiscoveryWaitlistCohorts = CatchContractFieldConstraints(
    path: 'eventDocument.discoveryWaitlistCohorts',
    required: true,
  );

  static const eventDocumentDistanceKm = CatchContractFieldConstraints(
    path: 'eventDocument.distanceKm',
    required: true,
    minimum: 0,
    maximum: 100,
  );

  static const eventDocumentEndTimeNanoseconds = CatchContractFieldConstraints(
    path: 'eventDocument.endTime._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventDocumentEndTimeSeconds = CatchContractFieldConstraints(
    path: 'eventDocument.endTime._seconds',
    required: true,
  );

  static const eventDocumentEventFormatActivityKind = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.activityKind',
    required: true,
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const eventDocumentEventFormatCustomActivityLabel = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.customActivityLabel',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventDocumentEventFormatDefaultPlaybookId = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.defaultPlaybookId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventDocumentEventFormatEventSuccessPrimitivesAssignmentAlgorithm = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.eventSuccessPrimitives.assignmentAlgorithm',
    enumValues: <String>['none', 'pacePods', 'socialPods', 'pairRotations', 'teamBalancer', 'tableSeating'],
  );

  static const eventDocumentEventFormatEventSuccessPrimitivesCompatibilityPolicy = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.eventSuccessPrimitives.compatibilityPolicy',
    enumValues: <String>['none', 'socialCohortBalance', 'mutualInterestOnly', 'questionnaireClueOnly'],
  );

  static const eventDocumentEventFormatEventSuccessPrimitivesPhoneAvailability = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.eventSuccessPrimitives.phoneAvailability',
    enumValues: <String>['continuous', 'plannedPauses', 'arrivalAndPostEventOnly', 'hostOnlyLive', 'noneDuringActivity'],
  );

  static const eventDocumentEventFormatEventSuccessPrimitivesRotationSuitability = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.eventSuccessPrimitives.rotationSuitability',
    enumValues: <String>['none', 'plannedBreaks', 'continuousRounds'],
  );

  static const eventDocumentEventFormatInteractionModel = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.interactionModel',
    required: true,
    enumValues: <String>['pacePods', 'pairedRotations', 'teamRotations', 'seatedTable', 'freeFormMixer', 'hostLedProgram', 'openFormat'],
  );

  static const eventDocumentEventFormatVersion = CatchContractFieldConstraints(
    path: 'eventDocument.eventFormat.version',
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionBalancedRatioPolicyLeftCohortId = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.balancedRatioPolicy.leftCohortId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionBalancedRatioPolicyMaxSkew = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.balancedRatioPolicy.maxSkew',
    required: true,
    minimum: 0,
    maximum: 1000,
  );

  static const eventDocumentEventPolicyAdmissionBalancedRatioPolicyOpeningBufferPerCohort = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.balancedRatioPolicy.openingBufferPerCohort',
    required: true,
    minimum: 0,
    maximum: 1000,
  );

  static const eventDocumentEventPolicyAdmissionBalancedRatioPolicyOutOfRatioCohortPolicy = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.balancedRatioPolicy.outOfRatioCohortPolicy',
    required: true,
    enumValues: <String>['admitWithinGeneralCapacity', 'waitlist', 'manualReview', 'reject'],
  );

  static const eventDocumentEventPolicyAdmissionBalancedRatioPolicyRightCohortId = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.balancedRatioPolicy.rightCohortId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionCapacityLimit = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.capacityLimit',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const eventDocumentEventPolicyAdmissionCohortCapacityLimits = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.cohortCapacityLimits',
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionFormat = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.format',
    required: true,
    enumValues: <String>['open', 'inviteOnly', 'manualApproval', 'fixedCohortCaps', 'balancedRatio', 'membersOnly'],
  );

  static const eventDocumentEventPolicyAdmissionInviteRequired = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.inviteRequired',
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionManualApprovalRequired = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.manualApprovalRequired',
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionMembershipRequired = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.membershipRequired',
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionPrivateAccessPolicyInviteCodeHint = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.privateAccessPolicy.inviteCodeHint',
    maxLength: 64,
  );

  static const eventDocumentEventPolicyAdmissionPrivateAccessPolicyMode = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.privateAccessPolicy.mode',
    required: true,
    enumValues: <String>['none', 'inviteCode'],
  );

  static const eventDocumentEventPolicyAdmissionPrivateAccessPolicyPrivateLinkEnabled = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.privateAccessPolicy.privateLinkEnabled',
    required: true,
  );

  static const eventDocumentEventPolicyAdmissionWaitlistPolicyMode = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.waitlistPolicy.mode',
    required: true,
    enumValues: <String>['disabled', 'rankedOffer', 'broadcastFirstComeFirstServed', 'manualReview'],
  );

  static const eventDocumentEventPolicyAdmissionWaitlistPolicyOfferWindowMinutes = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.admission.waitlistPolicy.offerWindowMinutes',
    required: true,
    minimum: 0,
    maximum: 10080,
  );

  static const eventDocumentEventPolicyCancellationPolicyId = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.cancellation.policyId',
    required: true,
    enumValues: <String>['flexible', 'standard', 'strict'],
  );

  static const eventDocumentEventPolicyPricingBasePriceInPaise = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.pricing.basePriceInPaise',
    required: true,
    minimum: 0,
    maximum: 100000000,
  );

  static const eventDocumentEventPolicyPricingCohortAdjustmentsInPaise = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.pricing.cohortAdjustmentsInPaise',
    required: true,
  );

  static const eventDocumentEventPolicyPricingDemandPricingRules = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.pricing.demandPricingRules',
    required: true,
  );

  static const eventDocumentEventPolicySettlementHostPayoutTiming = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.settlement.hostPayoutTiming',
    required: true,
    enumValues: <String>['afterEventCompletion'],
  );

  static const eventDocumentEventPolicyVersion = CatchContractFieldConstraints(
    path: 'eventDocument.eventPolicy.version',
    required: true,
  );

  static const eventDocumentGenderCounts = CatchContractFieldConstraints(
    path: 'eventDocument.genderCounts',
    required: true,
  );

  static const eventDocumentLocationDetails = CatchContractFieldConstraints(
    path: 'eventDocument.locationDetails',
    maxLength: 1000,
  );

  static const eventDocumentMeetingLocationAddress = CatchContractFieldConstraints(
    path: 'eventDocument.meetingLocation.address',
    maxLength: 500,
  );

  static const eventDocumentMeetingLocationLatitude = CatchContractFieldConstraints(
    path: 'eventDocument.meetingLocation.latitude',
    required: true,
    minimum: -90,
    maximum: 90,
  );

  static const eventDocumentMeetingLocationLongitude = CatchContractFieldConstraints(
    path: 'eventDocument.meetingLocation.longitude',
    required: true,
    minimum: -180,
    maximum: 180,
  );

  static const eventDocumentMeetingLocationName = CatchContractFieldConstraints(
    path: 'eventDocument.meetingLocation.name',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const eventDocumentMeetingLocationNotes = CatchContractFieldConstraints(
    path: 'eventDocument.meetingLocation.notes',
    maxLength: 1000,
  );

  static const eventDocumentMeetingLocationPlaceId = CatchContractFieldConstraints(
    path: 'eventDocument.meetingLocation.placeId',
    maxLength: 256,
    minLength: 1,
  );

  static const eventDocumentMeetingPoint = CatchContractFieldConstraints(
    path: 'eventDocument.meetingPoint',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const eventDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventDocumentPace = CatchContractFieldConstraints(
    path: 'eventDocument.pace',
    required: true,
    enumValues: <String>['easy', 'moderate', 'fast', 'competitive'],
  );

  static const eventDocumentPhotoUrl = CatchContractFieldConstraints(
    path: 'eventDocument.photoUrl',
    maxLength: 2048,
  );

  static const eventDocumentPriceInPaise = CatchContractFieldConstraints(
    path: 'eventDocument.priceInPaise',
    required: true,
    minimum: 0,
    maximum: 100000000,
  );

  static const eventDocumentScenario = CatchContractFieldConstraints(
    path: 'eventDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventDocumentStartingPointLat = CatchContractFieldConstraints(
    path: 'eventDocument.startingPointLat',
    required: true,
    minimum: -90,
    maximum: 90,
  );

  static const eventDocumentStartingPointLng = CatchContractFieldConstraints(
    path: 'eventDocument.startingPointLng',
    required: true,
    minimum: -180,
    maximum: 180,
  );

  static const eventDocumentStartTimeNanoseconds = CatchContractFieldConstraints(
    path: 'eventDocument.startTime._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventDocumentStartTimeSeconds = CatchContractFieldConstraints(
    path: 'eventDocument.startTime._seconds',
    required: true,
  );

  static const eventDocumentStatus = CatchContractFieldConstraints(
    path: 'eventDocument.status',
    required: true,
    enumValues: <String>['active', 'cancelled'],
  );

  static const eventDocumentWaitlistedCohortCounts = CatchContractFieldConstraints(
    path: 'eventDocument.waitlistedCohortCounts',
    required: true,
  );

  static const eventDocumentWaitlistedCount = CatchContractFieldConstraints(
    path: 'eventDocument.waitlistedCount',
    required: true,
    minimum: 0,
  );

  static const eventIntakeReviewDecisionDocumentChecklistCopyReviewed = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.checklist.copyReviewed',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentChecklistDateReviewed = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.checklist.dateReviewed',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentChecklistNoCatchHostingImplied = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.checklist.noCatchHostingImplied',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentChecklistRightsReviewed = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.checklist.rightsReviewed',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentChecklistSourceReviewed = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.checklist.sourceReviewed',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentChecklistVenueReviewed = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.checklist.venueReviewed',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentDecision = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.decision',
    required: true,
    enumValues: <String>['approve', 'needs_changes', 'hold', 'reject'],
  );

  static const eventIntakeReviewDecisionDocumentDecisionId = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.decisionId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentDecisionStatus = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.decisionStatus',
    required: true,
    enumValues: <String>['approved', 'needs_changes', 'held', 'rejected'],
  );

  static const eventIntakeReviewDecisionDocumentEdits = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.edits',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentEffect = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.effect',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentNote = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.note',
    maxLength: 2000,
    minLength: 1,
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventIntakeReviewDecisionDocumentReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.reviewedAt._seconds',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentReviewedByUid = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentRunId = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.runId',
    maxLength: 180,
  );

  static const eventIntakeReviewDecisionDocumentSchemaVersion = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.schemaVersion',
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentTargetId = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.targetId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const eventIntakeReviewDecisionDocumentTargetType = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.targetType',
    required: true,
    enumValues: <String>['source_profile', 'query_template', 'run_plan', 'source_result', 'event_candidate'],
  );

  static const eventIntakeReviewDecisionDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventIntakeReviewDecisionDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventIntakeReviewDecisionDocument.updatedAt._seconds',
    required: true,
  );

  static const eventInviteLinkDocumentCatcherCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.catcherCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentChatStartedCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.chatStartedCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentCheckedInCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.checkedInCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentClubId = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventInviteLinkDocumentConfirmedCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.confirmedCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventInviteLinkDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.createdAt._seconds',
    required: true,
  );

  static const eventInviteLinkDocumentDisabledAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.disabledAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventInviteLinkDocumentDisabledAtSeconds = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.disabledAt._seconds',
    required: true,
  );

  static const eventInviteLinkDocumentEventId = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventInviteLinkDocumentHostUid = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.hostUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventInviteLinkDocumentLabel = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.label',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventInviteLinkDocumentMatchCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.matchCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentOpenCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.openCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventInviteLinkDocumentPaidCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.paidCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentRequestCount = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.requestCount',
    required: true,
    minimum: 0,
  );

  static const eventInviteLinkDocumentSource = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.source',
    maxLength: 80,
    minLength: 1,
  );

  static const eventInviteLinkDocumentTokenHash = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.tokenHash',
    maxLength: 64,
    minLength: 64,
    required: true,
    pattern: '^[a-f0-9]{64}\$',
  );

  static const eventInviteLinkDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventInviteLinkDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventInviteLinkDocument.updatedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentAttendedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.attendedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentAttendedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.attendedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentCancelledAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.cancelledAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentCancelledAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.cancelledAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentClubId = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentCohortAtSignup = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.cohortAtSignup',
    maxLength: 120,
    minLength: 1,
  );

  static const eventParticipationDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.createdAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentDeletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.deletedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentDeletedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.deletedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentEventId = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentGenderAtSignup = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.genderAtSignup',
    enumValues: <String>['man', 'woman', 'nonBinary', 'other'],
  );

  static const eventParticipationDocumentHostApprovalDecidedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.hostApprovalDecidedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentHostApprovalDecidedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.hostApprovalDecidedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentHostApprovalDecidedBy = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.hostApprovalDecidedBy',
    maxLength: 180,
    minLength: 1,
  );

  static const eventParticipationDocumentHostApprovalStatus = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.hostApprovalStatus',
    enumValues: <String>['pending', 'approved', 'declined'],
  );

  static const eventParticipationDocumentInviteCapturedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.inviteCapturedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentInviteCapturedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.inviteCapturedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentInviteLinkId = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.inviteLinkId',
    maxLength: 180,
    minLength: 1,
  );

  static const eventParticipationDocumentInviteSource = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.inviteSource',
    maxLength: 80,
    minLength: 1,
  );

  static const eventParticipationDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentPaymentId = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.paymentId',
    maxLength: 180,
    minLength: 1,
  );

  static const eventParticipationDocumentScenario = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentSignedUpAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.signedUpAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentSignedUpAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.signedUpAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentStatus = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.status',
    required: true,
    enumValues: <String>['signedUp', 'waitlisted', 'attended', 'cancelled', 'deleted'],
  );

  static const eventParticipationDocumentUid = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventParticipationDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.updatedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentWaitlistedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentWaitlistedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentWaitlistOfferAcceptedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferAcceptedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentWaitlistOfferAcceptedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferAcceptedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentWaitlistOfferedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentWaitlistOfferedAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferedAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentWaitlistOfferExpiresAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferExpiresAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventParticipationDocumentWaitlistOfferExpiresAtSeconds = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferExpiresAt._seconds',
    required: true,
  );

  static const eventParticipationDocumentWaitlistOfferId = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferId',
    maxLength: 240,
    minLength: 1,
  );

  static const eventParticipationDocumentWaitlistOfferStatus = CatchContractFieldConstraints(
    path: 'eventParticipationDocument.waitlistOfferStatus',
    enumValues: <String>['active', 'accepted', 'declined', 'expired', 'cancelled'],
  );

  static const eventPrivateAccessDocumentClubId = CatchContractFieldConstraints(
    path: 'eventPrivateAccessDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventPrivateAccessDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventPrivateAccessDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventPrivateAccessDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventPrivateAccessDocument.createdAt._seconds',
    required: true,
  );

  static const eventPrivateAccessDocumentEventId = CatchContractFieldConstraints(
    path: 'eventPrivateAccessDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventPrivateAccessDocumentInviteCode = CatchContractFieldConstraints(
    path: 'eventPrivateAccessDocument.inviteCode',
    maxLength: 64,
    minLength: 4,
    required: true,
    pattern: '^[A-Za-z0-9_-]+\$',
  );

  static const eventPrivateAccessDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventPrivateAccessDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSafetyReportDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSafetyReportDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSafetyReportDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.createdAt._seconds',
    required: true,
  );

  static const eventSafetyReportDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSafetyReportDocumentFeedbackId = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.feedbackId',
    maxLength: 256,
    minLength: 3,
    required: true,
  );

  static const eventSafetyReportDocumentNote = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.note',
    maxLength: 500,
  );

  static const eventSafetyReportDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSafetyReportDocumentReporterUserId = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.reporterUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSafetyReportDocumentSource = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.source',
    required: true,
    enumValues: <String>['event_success_feedback'],
  );

  static const eventSafetyReportDocumentStatus = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.status',
    required: true,
    enumValues: <String>['open', 'reviewed', 'dismissed'],
  );

  static const eventSafetyReportDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSafetyReportDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSafetyReportDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentAnswerOptions = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.answerOptions',
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentCompletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.completedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessArrivalMissionDocumentCompletedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.completedAt._seconds',
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessArrivalMissionDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.createdAt._seconds',
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentObserverUid = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.observerUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentQuestion = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.question',
    maxLength: 160,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentSelectedAnswerId = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.selectedAnswerId',
    maxLength: 64,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentStatus = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.status',
    required: true,
    enumValues: <String>['active', 'completed', 'skipped'],
  );

  static const eventSuccessArrivalMissionDocumentTargetContext = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.targetContext',
    maxLength: 160,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentTargetDisplayName = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.targetDisplayName',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentTargetUid = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.targetUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessArrivalMissionDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessArrivalMissionDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessArrivalMissionDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessAssignmentDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessAssignmentDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.createdAt._seconds',
    required: true,
  );

  static const eventSuccessAssignmentDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentDisplaySubtitle = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.displaySubtitle',
    maxLength: 240,
  );

  static const eventSuccessAssignmentDocumentDisplayTitle = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.displayTitle',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentLabel = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.label',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentModuleId = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.moduleId',
    required: true,
    enumValues: <String>['micro_pods', 'guided_rotations'],
  );

  static const eventSuccessAssignmentDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentPeerUids = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.peerUids',
    required: true,
  );

  static const eventSuccessAssignmentDocumentRotationFairnessAssignedRoundCount = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.rotationFairness.assignedRoundCount',
    required: true,
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessAssignmentDocumentRotationFairnessRepeatPeerCount = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.rotationFairness.repeatPeerCount',
    required: true,
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessAssignmentDocumentRotationFairnessSitOutRoundCount = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.rotationFairness.sitOutRoundCount',
    required: true,
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessAssignmentDocumentRotationFairnessUniquePeerCount = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.rotationFairness.uniquePeerCount',
    required: true,
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessAssignmentDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentSource = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.source',
    required: true,
    enumValues: <String>['server_v1', 'host_override_v1', 'server'],
  );

  static const eventSuccessAssignmentDocumentUid = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentUnitIndex = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.unitIndex',
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessAssignmentDocumentUnitKind = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.unitKind',
    enumValues: <String>['wholeGroup', 'pods', 'pairs', 'teams', 'tables'],
  );

  static const eventSuccessAssignmentDocumentUnitLabel = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.unitLabel',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessAssignmentDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessAssignmentDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessAssignmentDocumentWhySummary = CatchContractFieldConstraints(
    path: 'eventSuccessAssignmentDocument.whySummary',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentAnswerIds = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.answerIds',
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessCompatibilityResponseDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.createdAt._seconds',
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentUid = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessCompatibilityResponseDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessCompatibilityResponseDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessCompatibilityResponseDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessFeedbackDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessFeedbackDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.createdAt._seconds',
    required: true,
  );

  static const eventSuccessFeedbackDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentMetNewPeopleCount = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.metNewPeopleCount',
    required: true,
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessFeedbackDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentPrivateNote = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.privateNote',
    maxLength: 500,
  );

  static const eventSuccessFeedbackDocumentSafetyConcern = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.safetyConcern',
    required: true,
  );

  static const eventSuccessFeedbackDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentStructureRating = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.structureRating',
    required: true,
    minimum: 1,
    maximum: 5,
  );

  static const eventSuccessFeedbackDocumentUid = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessFeedbackDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessFeedbackDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessFeedbackDocumentWelcomeRating = CatchContractFieldConstraints(
    path: 'eventSuccessFeedbackDocument.welcomeRating',
    required: true,
    minimum: 1,
    maximum: 5,
  );

  static const eventSuccessPlanDocumentActiveRevealRoundIndex = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.activeRevealRoundIndex',
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessPlanDocumentActiveStepIndex = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.activeStepIndex',
    required: true,
    minimum: 0,
    maximum: 100,
  );

  static const eventSuccessPlanDocumentAttendeePrompt = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.attendeePrompt',
    maxLength: 300,
  );

  static const eventSuccessPlanDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentCompletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.completedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessPlanDocumentCompletedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.completedAt._seconds',
    required: true,
  );

  static const eventSuccessPlanDocumentContextualOpenersEnabled = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.contextualOpenersEnabled',
    required: true,
  );

  static const eventSuccessPlanDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessPlanDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.createdAt._seconds',
    required: true,
  );

  static const eventSuccessPlanDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentFrozenAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.frozenAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessPlanDocumentFrozenAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.frozenAt._seconds',
    required: true,
  );

  static const eventSuccessPlanDocumentHostGoal = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.hostGoal',
    maxLength: 300,
    required: true,
  );

  static const eventSuccessPlanDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentPlaybookId = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.playbookId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentQuestionnaireConfigCustomTitle = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.questionnaireConfig.customTitle',
    maxLength: 80,
  );

  static const eventSuccessPlanDocumentQuestionnaireConfigTemplateId = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.questionnaireConfig.templateId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentRevealStartedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.revealStartedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessPlanDocumentRevealStartedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.revealStartedAt._seconds',
    required: true,
  );

  static const eventSuccessPlanDocumentRevealStatus = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.revealStatus',
    enumValues: <String>['idle', 'countingDown', 'revealed'],
  );

  static const eventSuccessPlanDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPlanDocumentSelectedModuleIds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.selectedModuleIds',
    required: true,
  );

  static const eventSuccessPlanDocumentStatus = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.status',
    required: true,
    enumValues: <String>['setup', 'live', 'complete'],
  );

  static const eventSuccessPlanDocumentStructureConfigMaxPairMeetings = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.structureConfig.maxPairMeetings',
    minimum: 1,
    maximum: 10,
  );

  static const eventSuccessPlanDocumentStructureConfigRevealCountdownSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.structureConfig.revealCountdownSeconds',
    required: true,
    minimum: 0,
    maximum: 60,
  );

  static const eventSuccessPlanDocumentStructureConfigRotationIntervalMinutes = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.structureConfig.rotationIntervalMinutes',
    minimum: 5,
    maximum: 180,
  );

  static const eventSuccessPlanDocumentStructureConfigRotationRepeatStrategy = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.structureConfig.rotationRepeatStrategy',
    enumValues: <String>['avoid', 'allowWhenExhausted'],
  );

  static const eventSuccessPlanDocumentStructureConfigUnitCount = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.structureConfig.unitCount',
    minimum: 1,
    maximum: 200,
  );

  static const eventSuccessPlanDocumentStructureConfigUnitKind = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.structureConfig.unitKind',
    required: true,
    enumValues: <String>['wholeGroup', 'pods', 'pairs', 'teams', 'tables'],
  );

  static const eventSuccessPlanDocumentStructureConfigUnitSize = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.structureConfig.unitSize',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const eventSuccessPlanDocumentTargetAttendeeCount = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.targetAttendeeCount',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const eventSuccessPlanDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessPlanDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessPlanDocumentWingmanRequestsEnabled = CatchContractFieldConstraints(
    path: 'eventSuccessPlanDocument.wingmanRequestsEnabled',
    required: true,
  );

  static const eventSuccessPreferenceDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessPreferenceDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.createdAt._seconds',
    required: true,
  );

  static const eventSuccessPreferenceDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentGuidedRotationsOptedOut = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.guidedRotationsOptedOut',
    required: true,
  );

  static const eventSuccessPreferenceDocumentMicroPodsOptedOut = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.microPodsOptedOut',
    required: true,
  );

  static const eventSuccessPreferenceDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentUid = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessPreferenceDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessPreferenceDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessPreferenceDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessScorecardDocumentAttendeesWhoCaughtSomeone = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.attendeesWhoCaughtSomeone',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentAttendeesWhoMetTwoPlusPeople = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.attendeesWhoMetTwoPlusPeople',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentAverageStructureRating = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.averageStructureRating',
    required: true,
    minimum: 0,
    maximum: 5,
  );

  static const eventSuccessScorecardDocumentAverageWelcomeRating = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.averageWelcomeRating',
    required: true,
    minimum: 0,
    maximum: 5,
  );

  static const eventSuccessScorecardDocumentBookedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.bookedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentCatchRate = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.catchRate',
    required: true,
    minimum: 0,
    maximum: 1,
  );

  static const eventSuccessScorecardDocumentCatchRecipientCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.catchRecipientCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentCatchSentCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.catchSentCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentChatStartedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.chatStartedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentCheckedInCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.checkedInCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessScorecardDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessScorecardDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessScorecardDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessScorecardDocumentFeedbackCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.feedbackCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelApprovedRequestCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.approvedRequestCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelAttendeesWhoCaughtSomeone = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.attendeesWhoCaughtSomeone',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelBookedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.bookedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelCatchSentCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.catchSentCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelChatStartedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.chatStartedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelCheckedInCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.checkedInCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelCheckoutStartedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.checkoutStartedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelDeclinedRequestCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.declinedRequestCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelDirectSignupCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.directSignupCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelInviteLinkCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.inviteLinkCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelInviteOpenCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.inviteOpenCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelMutualMatchCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.mutualMatchCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelNoShowCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.noShowCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelPaymentCompletedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.paymentCompletedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelPaymentFailedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.paymentFailedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelPaymentPendingCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.paymentPendingCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelPaymentRefundedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.paymentRefundedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelPendingRequestCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.pendingRequestCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelRepeatAttendeeCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.repeatAttendeeCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelRequestCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.requestCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelTotalDemandCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.totalDemandCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelWaitlistJoinCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.waitlistJoinCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelWaitlistOfferAcceptedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.waitlistOfferAcceptedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelWaitlistOfferActiveCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.waitlistOfferActiveCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelWaitlistOfferCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.waitlistOfferCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelWaitlistOfferDeclinedCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.waitlistOfferDeclinedCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentFunnelWaitlistOfferExpiredCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.funnel.waitlistOfferExpiredCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentMutualMatchCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.mutualMatchCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessScorecardDocumentSafetyIncidentCount = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.safetyIncidentCount',
    required: true,
    minimum: 0,
  );

  static const eventSuccessScorecardDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessScorecardDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessScorecardDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessScorecardDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessScorecardDocument.updatedAt._seconds',
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentClubId = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessWingmanRequestDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.createdAt._seconds',
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentEventId = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentHostVisibleConsent = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.hostVisibleConsent',
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentNote = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.note',
    maxLength: 240,
  );

  static const eventSuccessWingmanRequestDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentRequesterUid = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.requesterUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentScenario = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentStatus = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.status',
    required: true,
    enumValues: <String>['active', 'withdrawn'],
  );

  static const eventSuccessWingmanRequestDocumentTargetUid = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.targetUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventSuccessWingmanRequestDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventSuccessWingmanRequestDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventSuccessWingmanRequestDocument.updatedAt._seconds',
    required: true,
  );

  static const eventWaitlistOfferDocumentClubId = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentCohortAtOffer = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.cohortAtOffer',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventWaitlistOfferDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.createdAt._seconds',
    required: true,
  );

  static const eventWaitlistOfferDocumentDecidedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.decidedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventWaitlistOfferDocumentDecidedAtSeconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.decidedAt._seconds',
    required: true,
  );

  static const eventWaitlistOfferDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentEventId = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentExpiresAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.expiresAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventWaitlistOfferDocumentExpiresAtSeconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.expiresAt._seconds',
    required: true,
  );

  static const eventWaitlistOfferDocumentExpiringNotifiedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.expiringNotifiedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventWaitlistOfferDocumentExpiringNotifiedAtSeconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.expiringNotifiedAt._seconds',
    required: true,
  );

  static const eventWaitlistOfferDocumentInviteLinkId = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.inviteLinkId',
    maxLength: 180,
    minLength: 1,
  );

  static const eventWaitlistOfferDocumentOfferedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.offeredAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventWaitlistOfferDocumentOfferedAtSeconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.offeredAt._seconds',
    required: true,
  );

  static const eventWaitlistOfferDocumentOfferedBy = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.offeredBy',
    maxLength: 180,
    minLength: 1,
  );

  static const eventWaitlistOfferDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentScenario = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentSource = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.source',
    required: true,
    enumValues: <String>['host', 'autoPromotion', 'ratioBalancing', 'cancellation'],
  );

  static const eventWaitlistOfferDocumentStatus = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.status',
    required: true,
    enumValues: <String>['active', 'accepted', 'declined', 'expired', 'cancelled'],
  );

  static const eventWaitlistOfferDocumentUid = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const eventWaitlistOfferDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const eventWaitlistOfferDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'eventWaitlistOfferDocument.updatedAt._seconds',
    required: true,
  );

  static const externalEventDocumentActivityActivityKind = CatchContractFieldConstraints(
    path: 'externalEventDocument.activity.activityKind',
    required: true,
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const externalEventDocumentActivityInteractionModel = CatchContractFieldConstraints(
    path: 'externalEventDocument.activity.interactionModel',
    required: true,
    enumValues: <String>['pacePods', 'pairedRotations', 'teamRotations', 'seatedTable', 'freeFormMixer', 'hostLedProgram', 'openFormat'],
  );

  static const externalEventDocumentActivitySource = CatchContractFieldConstraints(
    path: 'externalEventDocument.activity.source',
    required: true,
    enumValues: <String>['heuristic', 'admin', 'source'],
  );

  static const externalEventDocumentActivityVersion = CatchContractFieldConstraints(
    path: 'externalEventDocument.activity.version',
    required: true,
  );

  static const externalEventDocumentBookingCatchBookingEnabled = CatchContractFieldConstraints(
    path: 'externalEventDocument.booking.catchBookingEnabled',
    required: true,
  );

  static const externalEventDocumentBookingCatchPaymentsEnabled = CatchContractFieldConstraints(
    path: 'externalEventDocument.booking.catchPaymentsEnabled',
    required: true,
  );

  static const externalEventDocumentBookingCatchReservationsEnabled = CatchContractFieldConstraints(
    path: 'externalEventDocument.booking.catchReservationsEnabled',
    required: true,
  );

  static const externalEventDocumentBookingCatchWaitlistEnabled = CatchContractFieldConstraints(
    path: 'externalEventDocument.booking.catchWaitlistEnabled',
    required: true,
  );

  static const externalEventDocumentBookingExternalLinks = CatchContractFieldConstraints(
    path: 'externalEventDocument.booking.externalLinks',
    required: true,
  );

  static const externalEventDocumentBookingMode = CatchContractFieldConstraints(
    path: 'externalEventDocument.booking.mode',
    required: true,
  );

  static const externalEventDocumentCanonicalHostId = CatchContractFieldConstraints(
    path: 'externalEventDocument.canonicalHostId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentCompatibilityClubId = CatchContractFieldConstraints(
    path: 'externalEventDocument.compatibilityClubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const externalEventDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.createdAt._seconds',
    required: true,
  );

  static const externalEventDocumentDedupeConflictPolicy = CatchContractFieldConstraints(
    path: 'externalEventDocument.dedupe.conflictPolicy',
    required: true,
  );

  static const externalEventDocumentDedupeDuplicateCandidateIds = CatchContractFieldConstraints(
    path: 'externalEventDocument.dedupe.duplicateCandidateIds',
    required: true,
  );

  static const externalEventDocumentDedupeNormalizedEventKey = CatchContractFieldConstraints(
    path: 'externalEventDocument.dedupe.normalizedEventKey',
    maxLength: 500,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentDedupePrimaryCandidateId = CatchContractFieldConstraints(
    path: 'externalEventDocument.dedupe.primaryCandidateId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentDescription = CatchContractFieldConstraints(
    path: 'externalEventDocument.description',
    maxLength: 4000,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentDiscoveryAvailability = CatchContractFieldConstraints(
    path: 'externalEventDocument.discovery.availability',
    required: true,
  );

  static const externalEventDocumentDiscoveryCitySlug = CatchContractFieldConstraints(
    path: 'externalEventDocument.discovery.citySlug',
    maxLength: 80,
    minLength: 1,
    pattern: '^[a-z0-9-]+\$',
  );

  static const externalEventDocumentDiscoveryCountryCode = CatchContractFieldConstraints(
    path: 'externalEventDocument.discovery.countryCode',
    maxLength: 2,
    minLength: 2,
  );

  static const externalEventDocumentDiscoveryManualApprovalRequired = CatchContractFieldConstraints(
    path: 'externalEventDocument.discovery.manualApprovalRequired',
    required: true,
  );

  static const externalEventDocumentEndTimeNanoseconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.endTime._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const externalEventDocumentEndTimeSeconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.endTime._seconds',
    required: true,
  );

  static const externalEventDocumentEventId = CatchContractFieldConstraints(
    path: 'externalEventDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentExternalSourceCandidateId = CatchContractFieldConstraints(
    path: 'externalEventDocument.externalSource.candidateId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentExternalSourceEventUrl = CatchContractFieldConstraints(
    path: 'externalEventDocument.externalSource.eventUrl',
    maxLength: 2048,
  );

  static const externalEventDocumentExternalSourcePlatform = CatchContractFieldConstraints(
    path: 'externalEventDocument.externalSource.platform',
    required: true,
    enumValues: <String>['bookMyShow', 'district', 'luma', 'partiful', 'sortMyScene'],
  );

  static const externalEventDocumentExternalSourceSourceEventId = CatchContractFieldConstraints(
    path: 'externalEventDocument.externalSource.sourceEventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentExternalSourceSourceEventKey = CatchContractFieldConstraints(
    path: 'externalEventDocument.externalSource.sourceEventKey',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentExternalSourceSourceUrl = CatchContractFieldConstraints(
    path: 'externalEventDocument.externalSource.sourceUrl',
    maxLength: 2048,
  );

  static const externalEventDocumentLocationDetails = CatchContractFieldConstraints(
    path: 'externalEventDocument.locationDetails',
    maxLength: 1000,
  );

  static const externalEventDocumentMeetingLocationAddress = CatchContractFieldConstraints(
    path: 'externalEventDocument.meetingLocation.address',
    maxLength: 500,
  );

  static const externalEventDocumentMeetingLocationLatitude = CatchContractFieldConstraints(
    path: 'externalEventDocument.meetingLocation.latitude',
    minimum: -90,
    maximum: 90,
  );

  static const externalEventDocumentMeetingLocationLongitude = CatchContractFieldConstraints(
    path: 'externalEventDocument.meetingLocation.longitude',
    minimum: -180,
    maximum: 180,
  );

  static const externalEventDocumentMeetingLocationName = CatchContractFieldConstraints(
    path: 'externalEventDocument.meetingLocation.name',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentMeetingLocationNotes = CatchContractFieldConstraints(
    path: 'externalEventDocument.meetingLocation.notes',
    maxLength: 1000,
  );

  static const externalEventDocumentMeetingLocationPlaceId = CatchContractFieldConstraints(
    path: 'externalEventDocument.meetingLocation.placeId',
    maxLength: 256,
    minLength: 1,
  );

  static const externalEventDocumentMeetingPoint = CatchContractFieldConstraints(
    path: 'externalEventDocument.meetingPoint',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentPhotoUrl = CatchContractFieldConstraints(
    path: 'externalEventDocument.photoUrl',
    maxLength: 2048,
  );

  static const externalEventDocumentPriceCurrency = CatchContractFieldConstraints(
    path: 'externalEventDocument.price.currency',
    required: true,
    pattern: '^[A-Z]{3}\$',
  );

  static const externalEventDocumentPriceDisplayText = CatchContractFieldConstraints(
    path: 'externalEventDocument.price.displayText',
    maxLength: 120,
  );

  static const externalEventDocumentPriceParsedPriceInPaise = CatchContractFieldConstraints(
    path: 'externalEventDocument.price.parsedPriceInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const externalEventDocumentPublicationStatus = CatchContractFieldConstraints(
    path: 'externalEventDocument.publicationStatus',
    required: true,
    enumValues: <String>['draft', 'public', 'archived', 'removed'],
  );

  static const externalEventDocumentReviewDecidedAt = CatchContractFieldConstraints(
    path: 'externalEventDocument.review.decidedAt',
    pattern: '^\\d{4}-\\d{2}-\\d{2}\$',
  );

  static const externalEventDocumentReviewEventReviewBatchId = CatchContractFieldConstraints(
    path: 'externalEventDocument.review.eventReviewBatchId',
    maxLength: 180,
  );

  static const externalEventDocumentReviewImportPolicyAcknowledged = CatchContractFieldConstraints(
    path: 'externalEventDocument.review.importPolicyAcknowledged',
    required: true,
  );

  static const externalEventDocumentReviewNote = CatchContractFieldConstraints(
    path: 'externalEventDocument.review.note',
    maxLength: 1000,
  );

  static const externalEventDocumentReviewOwnerSafeCopyReviewed = CatchContractFieldConstraints(
    path: 'externalEventDocument.review.ownerSafeCopyReviewed',
    required: true,
  );

  static const externalEventDocumentReviewReviewer = CatchContractFieldConstraints(
    path: 'externalEventDocument.review.reviewer',
    maxLength: 180,
  );

  static const externalEventDocumentSchemaVersion = CatchContractFieldConstraints(
    path: 'externalEventDocument.schemaVersion',
    required: true,
  );

  static const externalEventDocumentStartTimeNanoseconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.startTime._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const externalEventDocumentStartTimeSeconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.startTime._seconds',
    required: true,
  );

  static const externalEventDocumentStatus = CatchContractFieldConstraints(
    path: 'externalEventDocument.status',
    required: true,
    enumValues: <String>['active', 'cancelled'],
  );

  static const externalEventDocumentTimezone = CatchContractFieldConstraints(
    path: 'externalEventDocument.timezone',
    maxLength: 80,
  );

  static const externalEventDocumentTitle = CatchContractFieldConstraints(
    path: 'externalEventDocument.title',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const externalEventDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const externalEventDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'externalEventDocument.updatedAt._seconds',
    required: true,
  );

  static const functionEventReceiptDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'functionEventReceiptDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const functionEventReceiptDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'functionEventReceiptDocument.createdAt._seconds',
    required: true,
  );

  static const functionEventReceiptDocumentEventId = CatchContractFieldConstraints(
    path: 'functionEventReceiptDocument.eventId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const functionEventReceiptDocumentHandler = CatchContractFieldConstraints(
    path: 'functionEventReceiptDocument.handler',
    required: true,
    enumValues: <String>['onMessageCreated', 'onMatchCreated', 'moderatePhotoOnUpload'],
  );

  static const functionEventReceiptDocumentMatchId = CatchContractFieldConstraints(
    path: 'functionEventReceiptDocument.matchId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const functionEventReceiptDocumentMessageId = CatchContractFieldConstraints(
    path: 'functionEventReceiptDocument.messageId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const hostAnalyticsSnapshotDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.createdAt._seconds',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentExpiresAtNanoseconds = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.expiresAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const hostAnalyticsSnapshotDocumentExpiresAtSeconds = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.expiresAt._seconds',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseDataQuality = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.dataQuality',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummaryClaimClicks = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.claimClicks',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummaryContactClicks = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.contactClicks',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummaryEventSaves = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.eventSaves',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummaryEventViews = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.eventViews',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummaryListingViews = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.listingViews',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummaryOrganizerSaves = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.organizerSaves',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummaryOutboundClicks = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.outboundClicks',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseDiscoverySummarySearchAppearances = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.discoverySummary.searchAppearances',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseGeneratedAt = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.generatedAt',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseRangeEndDate = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.range.endDate',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseRangeGranularity = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.range.granularity',
    required: true,
    enumValues: <String>['day', 'week', 'month'],
  );

  static const hostAnalyticsSnapshotDocumentResponseRangePreset = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.range.preset',
    maxLength: 24,
  );

  static const hostAnalyticsSnapshotDocumentResponseRangeStartDate = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.range.startDate',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseReviewSummaryAverageRating = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.reviewSummary.averageRating',
    required: true,
    minimum: 0,
    maximum: 5,
  );

  static const hostAnalyticsSnapshotDocumentResponseReviewSummaryNewReviews = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.reviewSummary.newReviews',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseReviewSummaryOwnerResponseCount = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.reviewSummary.ownerResponseCount',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseReviewSummaryPublicReviews = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.reviewSummary.publicReviews',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseReviewSummaryPublishedReviews = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.reviewSummary.publishedReviews',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseReviewSummaryVerifiedReviews = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.reviewSummary.verifiedReviews',
    required: true,
    minimum: 0,
  );

  static const hostAnalyticsSnapshotDocumentResponseScopeClubIds = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.scope.clubIds',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseScopeClubName = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.scope.clubName',
    maxLength: 160,
  );

  static const hostAnalyticsSnapshotDocumentResponseScopeEventIds = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.scope.eventIds',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseScopeEventTitle = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.scope.eventTitle',
    maxLength: 160,
  );

  static const hostAnalyticsSnapshotDocumentResponseScopeOrganizerIds = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.scope.organizerIds',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseScopeOrganizerName = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.scope.organizerName',
    maxLength: 160,
  );

  static const hostAnalyticsSnapshotDocumentResponseSummaryCards = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.summaryCards',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseTimezone = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.timezone',
    maxLength: 64,
    minLength: 1,
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseTopEvents = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.topEvents',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentResponseTrend = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.response.trend',
    required: true,
  );

  static const hostAnalyticsSnapshotDocumentScopeHash = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.scopeHash',
    required: true,
    pattern: '^[a-f0-9]{64}\$',
  );

  static const hostAnalyticsSnapshotDocumentUid = CatchContractFieldConstraints(
    path: 'hostAnalyticsSnapshotDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const hostPaymentAccountDocumentChargesEnabled = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.chargesEnabled',
    required: true,
  );

  static const hostPaymentAccountDocumentCountry = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.country',
    maxLength: 2,
    minLength: 2,
    required: true,
  );

  static const hostPaymentAccountDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const hostPaymentAccountDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.createdAt._seconds',
    required: true,
  );

  static const hostPaymentAccountDocumentDefaultCurrency = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.defaultCurrency',
    maxLength: 3,
    minLength: 3,
    required: true,
  );

  static const hostPaymentAccountDocumentDetailsSubmitted = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.detailsSubmitted',
    required: true,
  );

  static const hostPaymentAccountDocumentDisabledReason = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.disabledReason',
    maxLength: 240,
  );

  static const hostPaymentAccountDocumentLastStripeEventId = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.lastStripeEventId',
    maxLength: 180,
  );

  static const hostPaymentAccountDocumentOnboardingStatus = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.onboardingStatus',
    required: true,
    enumValues: <String>['notStarted', 'pending', 'complete', 'restricted'],
  );

  static const hostPaymentAccountDocumentPayoutsEnabled = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.payoutsEnabled',
    required: true,
  );

  static const hostPaymentAccountDocumentProvider = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.provider',
    required: true,
    enumValues: <String>['stripe'],
  );

  static const hostPaymentAccountDocumentRequirementsCurrentlyDue = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.requirementsCurrentlyDue',
    required: true,
  );

  static const hostPaymentAccountDocumentRequirementsPastDue = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.requirementsPastDue',
    required: true,
  );

  static const hostPaymentAccountDocumentRequirementsPendingVerification = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.requirementsPendingVerification',
    required: true,
  );

  static const hostPaymentAccountDocumentStripeAccountId = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.stripeAccountId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const hostPaymentAccountDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const hostPaymentAccountDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.updatedAt._seconds',
    required: true,
  );

  static const hostPaymentAccountDocumentUserId = CatchContractFieldConstraints(
    path: 'hostPaymentAccountDocument.userId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const hostProfileDocumentAvatarUrl = CatchContractFieldConstraints(
    path: 'hostProfileDocument.avatarUrl',
    maxLength: 2048,
  );

  static const hostProfileDocumentBio = CatchContractFieldConstraints(
    path: 'hostProfileDocument.bio',
    maxLength: 500,
  );

  static const hostProfileDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'hostProfileDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const hostProfileDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'hostProfileDocument.createdAt._seconds',
    required: true,
  );

  static const hostProfileDocumentDisplayName = CatchContractFieldConstraints(
    path: 'hostProfileDocument.displayName',
    maxLength: 80,
    minLength: 1,
    required: true,
    pattern: '.*\\S.*',
  );

  static const hostProfileDocumentRoleTitle = CatchContractFieldConstraints(
    path: 'hostProfileDocument.roleTitle',
    maxLength: 80,
  );

  static const hostProfileDocumentStatus = CatchContractFieldConstraints(
    path: 'hostProfileDocument.status',
    required: true,
    enumValues: <String>['active', 'pending', 'suspended'],
  );

  static const hostProfileDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'hostProfileDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const hostProfileDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'hostProfileDocument.updatedAt._seconds',
    required: true,
  );

  static const matchDocumentBlockedAtNanoseconds = CatchContractFieldConstraints(
    path: 'matchDocument.blockedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const matchDocumentBlockedAtSeconds = CatchContractFieldConstraints(
    path: 'matchDocument.blockedAt._seconds',
    required: true,
  );

  static const matchDocumentBlockedBy = CatchContractFieldConstraints(
    path: 'matchDocument.blockedBy',
    maxLength: 180,
    minLength: 1,
  );

  static const matchDocumentClubId = CatchContractFieldConstraints(
    path: 'matchDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const matchDocumentConversationType = CatchContractFieldConstraints(
    path: 'matchDocument.conversationType',
    enumValues: <String>['match', 'clubHostInquiry'],
  );

  static const matchDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'matchDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const matchDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'matchDocument.createdAt._seconds',
    required: true,
  );

  static const matchDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'matchDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const matchDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'matchDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const matchDocumentEventIds = CatchContractFieldConstraints(
    path: 'matchDocument.eventIds',
    required: true,
  );

  static const matchDocumentLastMessageAtNanoseconds = CatchContractFieldConstraints(
    path: 'matchDocument.lastMessageAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const matchDocumentLastMessageAtSeconds = CatchContractFieldConstraints(
    path: 'matchDocument.lastMessageAt._seconds',
    required: true,
  );

  static const matchDocumentLastMessagePreview = CatchContractFieldConstraints(
    path: 'matchDocument.lastMessagePreview',
    maxLength: 300,
  );

  static const matchDocumentLastMessageSenderId = CatchContractFieldConstraints(
    path: 'matchDocument.lastMessageSenderId',
    maxLength: 180,
    minLength: 1,
  );

  static const matchDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'matchDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const matchDocumentParticipantIds = CatchContractFieldConstraints(
    path: 'matchDocument.participantIds',
    required: true,
  );

  static const matchDocumentScenario = CatchContractFieldConstraints(
    path: 'matchDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const matchDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'matchDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const matchDocumentStatus = CatchContractFieldConstraints(
    path: 'matchDocument.status',
    required: true,
    enumValues: <String>['active', 'blocked'],
  );

  static const matchDocumentUnreadCounts = CatchContractFieldConstraints(
    path: 'matchDocument.unreadCounts',
    required: true,
  );

  static const matchDocumentUser1Id = CatchContractFieldConstraints(
    path: 'matchDocument.user1Id',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const matchDocumentUser2Id = CatchContractFieldConstraints(
    path: 'matchDocument.user2Id',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const moderationFlagDocumentContext = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.context',
    maxLength: 1000,
  );

  static const moderationFlagDocumentContextId = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.contextId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const moderationFlagDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const moderationFlagDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.createdAt._seconds',
    required: true,
  );

  static const moderationFlagDocumentFlagType = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.flagType',
    required: true,
    enumValues: <String>['explicit_photo', 'banned_text', 'underage_content'],
  );

  static const moderationFlagDocumentReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const moderationFlagDocumentReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.reviewedAt._seconds',
    required: true,
  );

  static const moderationFlagDocumentSource = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.source',
    required: true,
    enumValues: <String>['profile_photo', 'club_image', 'chat_message', 'user_bio', 'club_description', 'review_comment'],
  );

  static const moderationFlagDocumentStatus = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.status',
    required: true,
    enumValues: <String>['pending', 'reviewed', 'dismissed'],
  );

  static const moderationFlagDocumentTargetUserId = CatchContractFieldConstraints(
    path: 'moderationFlagDocument.targetUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const onboardingDraftDocumentCountryCode = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.countryCode',
    maxLength: 8,
  );

  static const onboardingDraftDocumentDateOfBirthNanoseconds = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.dateOfBirth._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const onboardingDraftDocumentDateOfBirthSeconds = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.dateOfBirth._seconds',
    required: true,
  );

  static const onboardingDraftDocumentDraftVersion = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.draftVersion',
    minimum: 0,
  );

  static const onboardingDraftDocumentFirstName = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.firstName',
    maxLength: 80,
  );

  static const onboardingDraftDocumentGender = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.gender',
    enumValues: <String>['man', 'woman', 'nonBinary', 'other'],
  );

  static const onboardingDraftDocumentInstagramHandle = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.instagramHandle',
    maxLength: 80,
  );

  static const onboardingDraftDocumentLastName = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.lastName',
    maxLength: 80,
  );

  static const onboardingDraftDocumentPhoneNumber = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.phoneNumber',
    maxLength: 32,
  );

  static const onboardingDraftDocumentStep = CatchContractFieldConstraints(
    path: 'onboardingDraftDocument.step',
    required: true,
    minimum: 0,
  );

  static const organizerClaimRequestDocumentBusinessEmail = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.businessEmail',
    maxLength: 320,
  );

  static const organizerClaimRequestDocumentBusinessPhone = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.businessPhone',
    maxLength: 32,
  );

  static const organizerClaimRequestDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerClaimRequestDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.createdAt._seconds',
    required: true,
  );

  static const organizerClaimRequestDocumentDecidedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.decidedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerClaimRequestDocumentDecidedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.decidedAt._seconds',
    required: true,
  );

  static const organizerClaimRequestDocumentDecidedByUid = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.decidedByUid',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerClaimRequestDocumentDecisionReason = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.decisionReason',
    maxLength: 1000,
  );

  static const organizerClaimRequestDocumentMessage = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.message',
    maxLength: 1000,
  );

  static const organizerClaimRequestDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerClaimRequestDocumentPreviousRequestId = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.previousRequestId',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerClaimRequestDocumentProofUrls = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.proofUrls',
    required: true,
  );

  static const organizerClaimRequestDocumentRequesterName = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.requesterName',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const organizerClaimRequestDocumentRequesterRole = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.requesterRole',
    required: true,
    enumValues: <String>['owner', 'founder', 'manager', 'marketer', 'venueManager', 'other'],
  );

  static const organizerClaimRequestDocumentRequesterUid = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.requesterUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerClaimRequestDocumentRequestId = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.requestId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerClaimRequestDocumentStatus = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.status',
    required: true,
    enumValues: <String>['pending', 'approved', 'rejected', 'withdrawn', 'superseded'],
  );

  static const organizerClaimRequestDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerClaimRequestDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerClaimRequestDocument.updatedAt._seconds',
    required: true,
  );

  static const organizerDocumentAdminSearchSortKey = CatchContractFieldConstraints(
    path: 'organizerDocument.adminSearch.sortKey',
    maxLength: 160,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+(?:-[a-z0-9-]+)*\$',
  );

  static const organizerDocumentAdminSearchTokens = CatchContractFieldConstraints(
    path: 'organizerDocument.adminSearch.tokens',
    required: true,
  );

  static const organizerDocumentAdminSearchUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.adminSearch.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentAdminSearchUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.adminSearch.updatedAt._seconds',
    required: true,
  );

  static const organizerDocumentAdminSearchUpdatedBySource = CatchContractFieldConstraints(
    path: 'organizerDocument.adminSearch.updatedBySource',
    required: true,
    enumValues: <String>['adminUpdateClubDetails', 'adminSetClubIndexStatus', 'adminOrganizerSearchBackfill'],
  );

  static const organizerDocumentAppVisibility = CatchContractFieldConstraints(
    path: 'organizerDocument.appVisibility',
    enumValues: <String>['discoverable', 'hidden'],
  );

  static const organizerDocumentArchived = CatchContractFieldConstraints(
    path: 'organizerDocument.archived',
    required: true,
  );

  static const organizerDocumentArchivedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.archivedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentArchivedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.archivedAt._seconds',
    required: true,
  );

  static const organizerDocumentArchiveReason = CatchContractFieldConstraints(
    path: 'organizerDocument.archiveReason',
    maxLength: 500,
  );

  static const organizerDocumentArea = CatchContractFieldConstraints(
    path: 'organizerDocument.area',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentCityName = CatchContractFieldConstraints(
    path: 'organizerDocument.cityName',
    maxLength: 120,
  );

  static const organizerDocumentClaimClaimHref = CatchContractFieldConstraints(
    path: 'organizerDocument.claim.claimHref',
    maxLength: 240,
  );

  static const organizerDocumentClaimLastClaimRequestId = CatchContractFieldConstraints(
    path: 'organizerDocument.claim.lastClaimRequestId',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerDocumentClaimState = CatchContractFieldConstraints(
    path: 'organizerDocument.claim.state',
    required: true,
    enumValues: <String>['unclaimed', 'claimPending', 'claimed', 'verified', 'suppressed'],
  );

  static const organizerDocumentCountryCode = CatchContractFieldConstraints(
    path: 'organizerDocument.countryCode',
    pattern: '^[A-Z]{2}\$',
  );

  static const organizerDocumentCountryName = CatchContractFieldConstraints(
    path: 'organizerDocument.countryName',
    maxLength: 120,
  );

  static const organizerDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.createdAt._seconds',
    required: true,
  );

  static const organizerDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'organizerDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'organizerDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentDescription = CatchContractFieldConstraints(
    path: 'organizerDocument.description',
    maxLength: 2000,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentDisplayCategory = CatchContractFieldConstraints(
    path: 'organizerDocument.displayCategory',
    maxLength: 120,
  );

  static const organizerDocumentEmail = CatchContractFieldConstraints(
    path: 'organizerDocument.email',
    maxLength: 320,
  );

  static const organizerDocumentEntityKind = CatchContractFieldConstraints(
    path: 'organizerDocument.entityKind',
    enumValues: <String>['club', 'venue', 'eventOrganizer', 'creatorCommunity', 'brand'],
  );

  static const organizerDocumentFollowerCount = CatchContractFieldConstraints(
    path: 'organizerDocument.followerCount',
    required: true,
    minimum: 0,
  );

  static const organizerDocumentHostAvatarUrl = CatchContractFieldConstraints(
    path: 'organizerDocument.hostAvatarUrl',
    maxLength: 2048,
  );

  static const organizerDocumentHostDefaultsEventPolicyAdmissionPreset = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.admissionPreset',
    enumValues: <String>['openCapacity', 'inviteOnly', 'balancedSingles', 'fixedCohortCaps'],
  );

  static const organizerDocumentHostDefaultsEventPolicyCancellationPolicyId = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.cancellationPolicyId',
    enumValues: <String>['flexible', 'standard', 'strict'],
  );

  static const organizerDocumentHostDefaultsEventPolicyDynamicPricingMaxInPaise = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.dynamicPricingMaxInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const organizerDocumentHostDefaultsEventPolicyDynamicPricingStepInPaise = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.dynamicPricingStepInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const organizerDocumentHostDefaultsEventPolicyMaxAge = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.maxAge',
    minimum: 0,
    maximum: 120,
  );

  static const organizerDocumentHostDefaultsEventPolicyMaxMen = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.maxMen',
    minimum: 0,
  );

  static const organizerDocumentHostDefaultsEventPolicyMaxWomen = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.maxWomen',
    minimum: 0,
  );

  static const organizerDocumentHostDefaultsEventPolicyMinAge = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventPolicy.minAge',
    minimum: 0,
    maximum: 120,
  );

  static const organizerDocumentHostDefaultsEventSuccessAttendeePrompt = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.attendeePrompt',
    maxLength: 300,
  );

  static const organizerDocumentHostDefaultsEventSuccessHostGoal = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.hostGoal',
    maxLength: 300,
  );

  static const organizerDocumentHostDefaultsEventSuccessPlaybookId = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.playbookId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentHostDefaultsEventSuccessQuestionnaireConfigCustomTitle = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.questionnaireConfig.customTitle',
    maxLength: 80,
  );

  static const organizerDocumentHostDefaultsEventSuccessQuestionnaireConfigTemplateId = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.questionnaireConfig.templateId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentHostDefaultsEventSuccessStructureConfigMaxPairMeetings = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.structureConfig.maxPairMeetings',
    minimum: 1,
    maximum: 10,
  );

  static const organizerDocumentHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds',
    required: true,
    minimum: 0,
    maximum: 60,
  );

  static const organizerDocumentHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes',
    minimum: 5,
    maximum: 180,
  );

  static const organizerDocumentHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy',
    enumValues: <String>['avoid', 'allowWhenExhausted'],
  );

  static const organizerDocumentHostDefaultsEventSuccessStructureConfigUnitCount = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.structureConfig.unitCount',
    minimum: 1,
    maximum: 200,
  );

  static const organizerDocumentHostDefaultsEventSuccessStructureConfigUnitKind = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.structureConfig.unitKind',
    required: true,
    enumValues: <String>['wholeGroup', 'pods', 'pairs', 'teams', 'tables'],
  );

  static const organizerDocumentHostDefaultsEventSuccessStructureConfigUnitSize = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.eventSuccess.structureConfig.unitSize',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const organizerDocumentHostDefaultsPrimaryActivityKind = CatchContractFieldConstraints(
    path: 'organizerDocument.hostDefaults.primaryActivityKind',
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const organizerDocumentHostName = CatchContractFieldConstraints(
    path: 'organizerDocument.hostName',
    maxLength: 120,
  );

  static const organizerDocumentHostProfiles = CatchContractFieldConstraints(
    path: 'organizerDocument.hostProfiles',
    required: true,
  );

  static const organizerDocumentHostUserId = CatchContractFieldConstraints(
    path: 'organizerDocument.hostUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerDocumentHostUserIds = CatchContractFieldConstraints(
    path: 'organizerDocument.hostUserIds',
    required: true,
  );

  static const organizerDocumentImageUrl = CatchContractFieldConstraints(
    path: 'organizerDocument.imageUrl',
    maxLength: 2048,
  );

  static const organizerDocumentInstagramHandle = CatchContractFieldConstraints(
    path: 'organizerDocument.instagramHandle',
    maxLength: 320,
  );

  static const organizerDocumentLocation = CatchContractFieldConstraints(
    path: 'organizerDocument.location',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const organizerDocumentLocationCityId = CatchContractFieldConstraints(
    path: 'organizerDocument.locationCityId',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const organizerDocumentLocationMarketId = CatchContractFieldConstraints(
    path: 'organizerDocument.locationMarketId',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const organizerDocumentLogoPhotoCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentLogoPhotoCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.createdAt._seconds',
    required: true,
  );

  static const organizerDocumentLogoPhotoId = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.id',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[A-Za-z0-9_-]+\$',
  );

  static const organizerDocumentLogoPhotoModerationReason = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.moderation.reason',
    maxLength: 240,
  );

  static const organizerDocumentLogoPhotoModerationReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.moderation.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentLogoPhotoModerationReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.moderation.reviewedAt._seconds',
    required: true,
  );

  static const organizerDocumentLogoPhotoModerationStatus = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.moderation.status',
    required: true,
    enumValues: <String>['pending', 'approved', 'rejected'],
  );

  static const organizerDocumentLogoPhotoPosition = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.position',
    required: true,
    minimum: 0,
    maximum: 19,
  );

  static const organizerDocumentLogoPhotoStoragePath = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.storagePath',
    maxLength: 512,
    minLength: 1,
    required: true,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const organizerDocumentLogoPhotoThumbnailStoragePath = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.thumbnailStoragePath',
    maxLength: 512,
    minLength: 1,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const organizerDocumentLogoPhotoThumbnailUrl = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.thumbnailUrl',
    maxLength: 2048,
  );

  static const organizerDocumentLogoPhotoUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentLogoPhotoUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.updatedAt._seconds',
    required: true,
  );

  static const organizerDocumentLogoPhotoUrl = CatchContractFieldConstraints(
    path: 'organizerDocument.logoPhoto.url',
    maxLength: 2048,
    required: true,
  );

  static const organizerDocumentMemberCount = CatchContractFieldConstraints(
    path: 'organizerDocument.memberCount',
    minimum: 0,
  );

  static const organizerDocumentName = CatchContractFieldConstraints(
    path: 'organizerDocument.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentNextEventAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.nextEventAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentNextEventAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.nextEventAt._seconds',
    required: true,
  );

  static const organizerDocumentNextEventLabel = CatchContractFieldConstraints(
    path: 'organizerDocument.nextEventLabel',
    maxLength: 240,
  );

  static const organizerDocumentOrganizerPhotos = CatchContractFieldConstraints(
    path: 'organizerDocument.organizerPhotos',
    required: true,
  );

  static const organizerDocumentOrganizerType = CatchContractFieldConstraints(
    path: 'organizerDocument.organizerType',
    required: true,
    enumValues: <String>['club', 'community', 'individual', 'eventProducer', 'venue', 'brand'],
  );

  static const organizerDocumentOrganizerTypeUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.organizerTypeUpdatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentOrganizerTypeUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.organizerTypeUpdatedAt._seconds',
    required: true,
  );

  static const organizerDocumentOrganizerTypeUpdatedByUid = CatchContractFieldConstraints(
    path: 'organizerDocument.organizerTypeUpdatedByUid',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerDocumentOwnershipClaimedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.ownership.claimedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentOwnershipClaimedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.ownership.claimedAt._seconds',
    required: true,
  );

  static const organizerDocumentOwnershipClaimedByUid = CatchContractFieldConstraints(
    path: 'organizerDocument.ownership.claimedByUid',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerDocumentOwnershipHostUserIds = CatchContractFieldConstraints(
    path: 'organizerDocument.ownership.hostUserIds',
    required: true,
  );

  static const organizerDocumentOwnershipOwnerUserId = CatchContractFieldConstraints(
    path: 'organizerDocument.ownership.ownerUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerDocumentOwnershipPrimaryHostUserId = CatchContractFieldConstraints(
    path: 'organizerDocument.ownership.primaryHostUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerDocumentOwnershipState = CatchContractFieldConstraints(
    path: 'organizerDocument.ownership.state',
    required: true,
    enumValues: <String>['programmatic', 'userCreated', 'claimed', 'transferred'],
  );

  static const organizerDocumentOwnerUserId = CatchContractFieldConstraints(
    path: 'organizerDocument.ownerUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerDocumentPhoneNumber = CatchContractFieldConstraints(
    path: 'organizerDocument.phoneNumber',
    maxLength: 320,
  );

  static const organizerDocumentProfileImageUrl = CatchContractFieldConstraints(
    path: 'organizerDocument.profileImageUrl',
    maxLength: 2048,
  );

  static const organizerDocumentProvenanceLastVerifiedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.provenance.lastVerifiedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentProvenanceLastVerifiedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.provenance.lastVerifiedAt._seconds',
    required: true,
  );

  static const organizerDocumentProvenanceOrigin = CatchContractFieldConstraints(
    path: 'organizerDocument.provenance.origin',
    required: true,
    enumValues: <String>['userCreated', 'scraper', 'adminSeed', 'import'],
  );

  static const organizerDocumentProvenanceSourceConfidence = CatchContractFieldConstraints(
    path: 'organizerDocument.provenance.sourceConfidence',
    required: true,
    enumValues: <String>['seedOnly', 'low', 'medium', 'high', 'ownerVerified'],
  );

  static const organizerDocumentProvenanceVerificationStatus = CatchContractFieldConstraints(
    path: 'organizerDocument.provenance.verificationStatus',
    required: true,
    enumValues: <String>['unverified', 'sourceBacked', 'ownerVerified'],
  );

  static const organizerDocumentPublicCategoryLabel = CatchContractFieldConstraints(
    path: 'organizerDocument.publicCategoryLabel',
    maxLength: 120,
  );

  static const organizerDocumentPublicPageCanonicalPath = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.canonicalPath',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentPublicPageCitySlug = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.citySlug',
    maxLength: 80,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const organizerDocumentPublicPageIndexReviewChecklistCadenceVerified = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.checklist.cadenceVerified',
    required: true,
  );

  static const organizerDocumentPublicPageIndexReviewChecklistMediaRightsVerified = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.checklist.mediaRightsVerified',
    required: true,
  );

  static const organizerDocumentPublicPageIndexReviewChecklistOwnerContactVerified = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.checklist.ownerContactVerified',
    required: true,
  );

  static const organizerDocumentPublicPageIndexReviewChecklistSourceEvidenceVerified = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.checklist.sourceEvidenceVerified',
    required: true,
  );

  static const organizerDocumentPublicPageIndexReviewIndexStatus = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.indexStatus',
    required: true,
    enumValues: <String>['noindex', 'indexReady', 'indexed'],
  );

  static const organizerDocumentPublicPageIndexReviewReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentPublicPageIndexReviewReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.reviewedAt._seconds',
    required: true,
  );

  static const organizerDocumentPublicPageIndexReviewReviewedByUid = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentPublicPageIndexReviewReviewNote = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexReview.reviewNote',
    maxLength: 1000,
  );

  static const organizerDocumentPublicPageIndexStatus = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.indexStatus',
    required: true,
    enumValues: <String>['noindex', 'indexReady', 'indexed'],
  );

  static const organizerDocumentPublicPageLastRenderedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.lastRenderedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerDocumentPublicPageLastRenderedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.lastRenderedAt._seconds',
    required: true,
  );

  static const organizerDocumentPublicPagePublishStatus = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.publishStatus',
    required: true,
    enumValues: <String>['draft', 'qa', 'published', 'suppressed', 'removed'],
  );

  static const organizerDocumentPublicPageRobots = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.robots',
    required: true,
    enumValues: <String>['noindex, follow', 'index, follow'],
  );

  static const organizerDocumentPublicPageSeoDescription = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.seoDescription',
    maxLength: 320,
  );

  static const organizerDocumentPublicPageSeoTitle = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.seoTitle',
    maxLength: 120,
  );

  static const organizerDocumentPublicPageSlug = CatchContractFieldConstraints(
    path: 'organizerDocument.publicPage.slug',
    maxLength: 160,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const organizerDocumentPublicProfileHeadline = CatchContractFieldConstraints(
    path: 'organizerDocument.publicProfile.headline',
    maxLength: 160,
  );

  static const organizerDocumentPublicProfileSourceSummary = CatchContractFieldConstraints(
    path: 'organizerDocument.publicProfile.sourceSummary',
    maxLength: 800,
  );

  static const organizerDocumentPublicProfileSummary = CatchContractFieldConstraints(
    path: 'organizerDocument.publicProfile.summary',
    maxLength: 800,
  );

  static const organizerDocumentRating = CatchContractFieldConstraints(
    path: 'organizerDocument.rating',
    required: true,
    minimum: 0,
    maximum: 5,
  );

  static const organizerDocumentRegionName = CatchContractFieldConstraints(
    path: 'organizerDocument.regionName',
    maxLength: 120,
  );

  static const organizerDocumentReviewCount = CatchContractFieldConstraints(
    path: 'organizerDocument.reviewCount',
    required: true,
    minimum: 0,
  );

  static const organizerDocumentScenario = CatchContractFieldConstraints(
    path: 'organizerDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'organizerDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const organizerDocumentStatus = CatchContractFieldConstraints(
    path: 'organizerDocument.status',
    required: true,
    enumValues: <String>['active', 'archived'],
  );

  static const organizerDocumentTags = CatchContractFieldConstraints(
    path: 'organizerDocument.tags',
    required: true,
  );

  static const organizerDocumentVerifiedReviewCount = CatchContractFieldConstraints(
    path: 'organizerDocument.verifiedReviewCount',
    minimum: 0,
  );

  static const organizerEventCandidateReviewDecisionDocumentCandidateId = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.candidateId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentChecklistDedupeReviewed = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.checklist.dedupeReviewed',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentChecklistIdentityReviewed = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.checklist.identityReviewed',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentChecklistImportPolicyAcknowledged = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.checklist.importPolicyAcknowledged',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentChecklistLocationReviewed = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.checklist.locationReviewed',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentChecklistOwnerSafeCopyReviewed = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.checklist.ownerSafeCopyReviewed',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentChecklistSourceEventReviewed = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.checklist.sourceEventReviewed',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentChecklistTimeReviewed = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.checklist.timeReviewed',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentDecision = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.decision',
    required: true,
    enumValues: <String>['approve_for_import', 'hold', 'reject'],
  );

  static const organizerEventCandidateReviewDecisionDocumentDecisionId = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.decisionId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentDecisionStatus = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.decisionStatus',
    required: true,
    enumValues: <String>['approved_for_import', 'held', 'rejected'],
  );

  static const organizerEventCandidateReviewDecisionDocumentImportState = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.importState',
    required: true,
    enumValues: <String>['blocked_by_policy', 'not_importable', 'pending_import'],
  );

  static const organizerEventCandidateReviewDecisionDocumentNote = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.note',
    maxLength: 1000,
    minLength: 1,
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerEventCandidateReviewDecisionDocumentReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.reviewedAt._seconds',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentReviewedByUid = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentSchemaVersion = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.schemaVersion',
    required: true,
  );

  static const organizerEventCandidateReviewDecisionDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerEventCandidateReviewDecisionDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerEventCandidateReviewDecisionDocument.updatedAt._seconds',
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentCandidateId = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.candidateId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentChecklistCoordinatesReviewed = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.checklist.coordinatesReviewed',
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentChecklistImportSafetyReviewed = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.checklist.importSafetyReviewed',
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentChecklistPlaceIdentityReviewed = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.checklist.placeIdentityReviewed',
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentChecklistSourceLocationReviewed = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.checklist.sourceLocationReviewed',
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentLocationAddress = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.location.address',
    maxLength: 500,
  );

  static const organizerEventLocationResolutionDecisionDocumentLocationLatitude = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.location.latitude',
    minimum: -90,
    maximum: 90,
  );

  static const organizerEventLocationResolutionDecisionDocumentLocationLongitude = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.location.longitude',
    minimum: -180,
    maximum: 180,
  );

  static const organizerEventLocationResolutionDecisionDocumentLocationName = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.location.name',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentLocationNotes = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.location.notes',
    maxLength: 1000,
  );

  static const organizerEventLocationResolutionDecisionDocumentLocationPlaceId = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.location.placeId',
    maxLength: 256,
    minLength: 1,
  );

  static const organizerEventLocationResolutionDecisionDocumentNote = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.note',
    maxLength: 1000,
    minLength: 1,
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentResolutionId = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.resolutionId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentResolutionStatus = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.resolutionStatus',
    required: true,
    enumValues: <String>['resolved'],
  );

  static const organizerEventLocationResolutionDecisionDocumentReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerEventLocationResolutionDecisionDocumentReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.reviewedAt._seconds',
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentReviewedByUid = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentSchemaVersion = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.schemaVersion',
    required: true,
  );

  static const organizerEventLocationResolutionDecisionDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerEventLocationResolutionDecisionDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerEventLocationResolutionDecisionDocument.updatedAt._seconds',
    required: true,
  );

  static const organizerFollowDocumentFollowedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.followedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerFollowDocumentFollowedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.followedAt._seconds',
    required: true,
  );

  static const organizerFollowDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerFollowDocumentPushNotificationsEnabled = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.pushNotificationsEnabled',
    required: true,
  );

  static const organizerFollowDocumentStatus = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.status',
    required: true,
    enumValues: <String>['active', 'inactive'],
  );

  static const organizerFollowDocumentUid = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerFollowDocumentUnfollowedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.unfollowedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerFollowDocumentUnfollowedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerFollowDocument.unfollowedAt._seconds',
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentDecision = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.decision',
    enumValues: <String>['accept_primary', 'accept_secondary', 'reject_wrong_entity', 'mark_ambiguous', 'mark_historical'],
  );

  static const organizerIntakeCurationDecisionDocumentEntityId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.entityId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentNewEntityId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.newEntityId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentOperationId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.operationId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentOperationStatus = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.operationStatus',
    required: true,
    enumValues: <String>['active', 'superseded'],
  );

  static const organizerIntakeCurationDecisionDocumentOperationType = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.operationType',
    required: true,
    enumValues: <String>['attach_surface', 'merge_entity', 'split_surface', 'suppress_entity', 'surface_decision'],
  );

  static const organizerIntakeCurationDecisionDocumentReason = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.reason',
    maxLength: 500,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerIntakeCurationDecisionDocumentReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.reviewedAt._seconds',
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentReviewedByUid = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSchemaVersion = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.schemaVersion',
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSourceCandidateId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.sourceCandidateId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSourceEntityId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.sourceEntityId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceConfidenceCity = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.confidence.city',
    required: true,
    enumValues: <String>['low', 'medium', 'high'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceConfidenceEntityMatch = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.confidence.entityMatch',
    required: true,
    enumValues: <String>['low', 'medium', 'high'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceConfidenceOwnership = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.confidence.ownership',
    required: true,
    enumValues: <String>['low', 'medium', 'high'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceCrawlEventDiscoveryStatus = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.crawl.eventDiscoveryStatus',
    required: true,
    enumValues: <String>['disabled', 'candidate', 'approved', 'paused'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceCrawlPolicy = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.crawl.policy',
    required: true,
    enumValues: <String>['manualOnly', 'blocked', 'apiPreferred'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceCrawlSupportsEventExtraction = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.crawl.supportsEventExtraction',
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceEvidenceRefs = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.evidenceRefs',
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceNormalizedKey = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.normalizedKey',
    maxLength: 240,
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceNotes = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.notes',
    maxLength: 500,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSurfacePlatform = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.platform',
    required: true,
    enumValues: <String>['bookMyShow', 'district', 'instagram', 'linkedin', 'luma', 'news', 'officialWebsite', 'partiful', 'sortMyScene', 'userReport', 'other'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceRole = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.role',
    required: true,
    enumValues: <String>['primary', 'secondary', 'backup', 'historical', 'ambiguous', 'rejected'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceStatus = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.status',
    required: true,
    enumValues: <String>['active', 'candidate', 'ambiguous', 'historical', 'rejected'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceSurfaceId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.surfaceId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceSurfaceKind = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surface.surfaceKind',
    required: true,
    enumValues: <String>['eventListing', 'eventCalendar', 'organizerProfile', 'personProfile', 'press', 'socialProfile', 'website', 'wrongEntity'],
  );

  static const organizerIntakeCurationDecisionDocumentSurfaceId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.surfaceId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentTargetEntityId = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.targetEntityId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeCurationDecisionDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerIntakeCurationDecisionDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerIntakeCurationDecisionDocument.updatedAt._seconds',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentAppVisibility = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.appVisibility',
    required: true,
    enumValues: <String>['hidden', 'discoverable'],
  );

  static const organizerIntakeReviewDecisionDocumentChecklistCrawlDisabledReviewed = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.checklist.crawlDisabledReviewed',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentChecklistIdentityReviewed = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.checklist.identityReviewed',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentChecklistMarketScopeReviewed = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.checklist.marketScopeReviewed',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentChecklistMediaRightsReviewed = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.checklist.mediaRightsReviewed',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentChecklistOwnerSafeCopyReviewed = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.checklist.ownerSafeCopyReviewed',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentChecklistSurfaceInventoryReviewed = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.checklist.surfaceInventoryReviewed',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentDecision = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.decision',
    required: true,
    enumValues: <String>['approve_public', 'hold', 'suppress'],
  );

  static const organizerIntakeReviewDecisionDocumentDecisionStatus = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.decisionStatus',
    required: true,
    enumValues: <String>['approved_public', 'held', 'suppressed'],
  );

  static const organizerIntakeReviewDecisionDocumentEntityId = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.entityId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentNote = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.note',
    maxLength: 1000,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentProjectionState = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.projectionState',
    required: true,
    enumValues: <String>['pending_static_generation', 'not_projectable'],
  );

  static const organizerIntakeReviewDecisionDocumentReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerIntakeReviewDecisionDocumentReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.reviewedAt._seconds',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentReviewedByUid = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentSchemaVersion = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.schemaVersion',
    required: true,
  );

  static const organizerIntakeReviewDecisionDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerIntakeReviewDecisionDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerIntakeReviewDecisionDocument.updatedAt._seconds',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentChecklistBehaviorStillDisabledAcknowledged = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.checklist.behaviorStillDisabledAcknowledged',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentChecklistCostAndSafetyReviewed = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.checklist.costAndSafetyReviewed',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentChecklistImplementationOwnerReviewed = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.checklist.implementationOwnerReviewed',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentChecklistRequiredInputsReviewed = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.checklist.requiredInputsReviewed',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentDecision = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.decision',
    required: true,
    enumValues: <String>['accept', 'hold', 'reject'],
  );

  static const organizerPolicyGapReviewDecisionDocumentDecisionId = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.decisionId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentDecisionStatus = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.decisionStatus',
    required: true,
    enumValues: <String>['accepted', 'held', 'rejected'],
  );

  static const organizerPolicyGapReviewDecisionDocumentGapId = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.gapId',
    maxLength: 160,
    minLength: 1,
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentNote = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.note',
    maxLength: 1000,
    minLength: 1,
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentOperationalState = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.operationalState',
    required: true,
    enumValues: <String>['blocked_until_policy_encoded', 'not_approved'],
  );

  static const organizerPolicyGapReviewDecisionDocumentRequiredInputsReviewed = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.requiredInputsReviewed',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerPolicyGapReviewDecisionDocumentReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.reviewedAt._seconds',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentReviewedByUid = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.reviewedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentSchemaVersion = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.schemaVersion',
    required: true,
  );

  static const organizerPolicyGapReviewDecisionDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerPolicyGapReviewDecisionDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerPolicyGapReviewDecisionDocument.updatedAt._seconds',
    required: true,
  );

  static const organizerPostDocumentAudience = CatchContractFieldConstraints(
    path: 'organizerPostDocument.audience',
    required: true,
    enumValues: <String>['followers'],
  );

  static const organizerPostDocumentAuthorUid = CatchContractFieldConstraints(
    path: 'organizerPostDocument.authorUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerPostDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerPostDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerPostDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerPostDocument.createdAt._seconds',
    required: true,
  );

  static const organizerPostDocumentEventId = CatchContractFieldConstraints(
    path: 'organizerPostDocument.eventId',
    maxLength: 180,
    minLength: 1,
  );

  static const organizerPostDocumentPhotoPath = CatchContractFieldConstraints(
    path: 'organizerPostDocument.photoPath',
    maxLength: 500,
    minLength: 1,
  );

  static const organizerPostDocumentStatus = CatchContractFieldConstraints(
    path: 'organizerPostDocument.status',
    required: true,
    enumValues: <String>['active', 'removed'],
  );

  static const organizerPostDocumentText = CatchContractFieldConstraints(
    path: 'organizerPostDocument.text',
    maxLength: 500,
    minLength: 1,
    required: true,
  );

  static const organizerScheduleLockDocumentEndTimeMillis = CatchContractFieldConstraints(
    path: 'organizerScheduleLockDocument.endTimeMillis',
    required: true,
    minimum: 0,
  );

  static const organizerScheduleLockDocumentEventId = CatchContractFieldConstraints(
    path: 'organizerScheduleLockDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerScheduleLockDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'organizerScheduleLockDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerScheduleLockDocumentOwnerId = CatchContractFieldConstraints(
    path: 'organizerScheduleLockDocument.ownerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerScheduleLockDocumentOwnerType = CatchContractFieldConstraints(
    path: 'organizerScheduleLockDocument.ownerType',
    required: true,
  );

  static const organizerScheduleLockDocumentSlot = CatchContractFieldConstraints(
    path: 'organizerScheduleLockDocument.slot',
    required: true,
    minimum: 0,
  );

  static const organizerScheduleLockDocumentStartTimeMillis = CatchContractFieldConstraints(
    path: 'organizerScheduleLockDocument.startTimeMillis',
    required: true,
    minimum: 0,
  );

  static const organizerTeamMembershipDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerTeamMembershipDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.createdAt._seconds',
    required: true,
  );

  static const organizerTeamMembershipDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const organizerTeamMembershipDocumentRemovedAtNanoseconds = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.removedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const organizerTeamMembershipDocumentRemovedAtSeconds = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.removedAt._seconds',
    required: true,
  );

  static const organizerTeamMembershipDocumentRole = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.role',
    required: true,
    enumValues: <String>['owner', 'manager'],
  );

  static const organizerTeamMembershipDocumentStatus = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.status',
    required: true,
    enumValues: <String>['active', 'removed'],
  );

  static const organizerTeamMembershipDocumentUid = CatchContractFieldConstraints(
    path: 'organizerTeamMembershipDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentAmount = CatchContractFieldConstraints(
    path: 'paymentDocument.amount',
    required: true,
    minimum: 0,
    maximum: 100000000,
  );

  static const paymentDocumentAmountMinor = CatchContractFieldConstraints(
    path: 'paymentDocument.amountMinor',
    minimum: 0,
    maximum: 100000000,
  );

  static const paymentDocumentApplicationFeeAmount = CatchContractFieldConstraints(
    path: 'paymentDocument.applicationFeeAmount',
    minimum: 0,
    maximum: 100000000,
  );

  static const paymentDocumentCheckoutSessionId = CatchContractFieldConstraints(
    path: 'paymentDocument.checkoutSessionId',
    maxLength: 240,
  );

  static const paymentDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'paymentDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const paymentDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'paymentDocument.createdAt._seconds',
    required: true,
  );

  static const paymentDocumentCurrency = CatchContractFieldConstraints(
    path: 'paymentDocument.currency',
    maxLength: 3,
    minLength: 3,
    required: true,
  );

  static const paymentDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'paymentDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'paymentDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentEventId = CatchContractFieldConstraints(
    path: 'paymentDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentHostUserId = CatchContractFieldConstraints(
    path: 'paymentDocument.hostUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentInviteLinkId = CatchContractFieldConstraints(
    path: 'paymentDocument.inviteLinkId',
    maxLength: 180,
    minLength: 1,
  );

  static const paymentDocumentInviteSource = CatchContractFieldConstraints(
    path: 'paymentDocument.inviteSource',
    maxLength: 80,
    minLength: 1,
  );

  static const paymentDocumentOrderId = CatchContractFieldConstraints(
    path: 'paymentDocument.orderId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentPaymentId = CatchContractFieldConstraints(
    path: 'paymentDocument.paymentId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentProvider = CatchContractFieldConstraints(
    path: 'paymentDocument.provider',
    enumValues: <String>['razorpay', 'stripe'],
  );

  static const paymentDocumentProviderPaymentId = CatchContractFieldConstraints(
    path: 'paymentDocument.providerPaymentId',
    maxLength: 240,
  );

  static const paymentDocumentScenario = CatchContractFieldConstraints(
    path: 'paymentDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'paymentDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const paymentDocumentSignUpFailed = CatchContractFieldConstraints(
    path: 'paymentDocument.signUpFailed',
    required: true,
  );

  static const paymentDocumentStatus = CatchContractFieldConstraints(
    path: 'paymentDocument.status',
    required: true,
    enumValues: <String>['pending', 'completed', 'failed', 'refunded', 'refundFailed'],
  );

  static const paymentDocumentStripeAccountId = CatchContractFieldConstraints(
    path: 'paymentDocument.stripeAccountId',
    maxLength: 120,
  );

  static const paymentDocumentUserId = CatchContractFieldConstraints(
    path: 'paymentDocument.userId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const publicProfileDocumentActivityPreferencesRunningPaceMaxSecsPerKm = CatchContractFieldConstraints(
    path: 'publicProfileDocument.activityPreferences.running.paceMaxSecsPerKm',
    required: true,
    minimum: 1,
  );

  static const publicProfileDocumentActivityPreferencesRunningPaceMinSecsPerKm = CatchContractFieldConstraints(
    path: 'publicProfileDocument.activityPreferences.running.paceMinSecsPerKm',
    required: true,
    minimum: 1,
  );

  static const publicProfileDocumentActivityPreferencesRunningPreferredDistances = CatchContractFieldConstraints(
    path: 'publicProfileDocument.activityPreferences.running.preferredDistances',
    required: true,
  );

  static const publicProfileDocumentActivityPreferencesRunningPreferredRunTimes = CatchContractFieldConstraints(
    path: 'publicProfileDocument.activityPreferences.running.preferredRunTimes',
    required: true,
  );

  static const publicProfileDocumentActivityPreferencesRunningRunningReasons = CatchContractFieldConstraints(
    path: 'publicProfileDocument.activityPreferences.running.runningReasons',
    required: true,
  );

  static const publicProfileDocumentActivityPreferencesRunningVersion = CatchContractFieldConstraints(
    path: 'publicProfileDocument.activityPreferences.running.version',
    required: true,
    minimum: 0,
  );

  static const publicProfileDocumentAge = CatchContractFieldConstraints(
    path: 'publicProfileDocument.age',
    required: true,
    minimum: 18,
    maximum: 120,
  );

  static const publicProfileDocumentChildren = CatchContractFieldConstraints(
    path: 'publicProfileDocument.children',
    enumValues: <String>['dontHave', 'haveWantMore', 'haveNoMore', 'wantSomeday', 'dontWant'],
  );

  static const publicProfileDocumentCity = CatchContractFieldConstraints(
    path: 'publicProfileDocument.city',
    maxLength: 120,
    minLength: 1,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const publicProfileDocumentCompany = CatchContractFieldConstraints(
    path: 'publicProfileDocument.company',
    maxLength: 120,
  );

  static const publicProfileDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'publicProfileDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const publicProfileDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'publicProfileDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const publicProfileDocumentDiet = CatchContractFieldConstraints(
    path: 'publicProfileDocument.diet',
    enumValues: <String>['omnivore', 'vegetarian', 'vegan', 'jain', 'other'],
  );

  static const publicProfileDocumentDrinking = CatchContractFieldConstraints(
    path: 'publicProfileDocument.drinking',
    enumValues: <String>['never', 'socially', 'often'],
  );

  static const publicProfileDocumentEducation = CatchContractFieldConstraints(
    path: 'publicProfileDocument.education',
    enumValues: <String>['highSchool', 'someCollege', 'bachelors', 'masters', 'phd', 'tradeSchool', 'other'],
  );

  static const publicProfileDocumentGender = CatchContractFieldConstraints(
    path: 'publicProfileDocument.gender',
    required: true,
    enumValues: <String>['man', 'woman', 'nonBinary', 'other'],
  );

  static const publicProfileDocumentHeight = CatchContractFieldConstraints(
    path: 'publicProfileDocument.height',
    minimum: 120,
    maximum: 220,
  );

  static const publicProfileDocumentName = CatchContractFieldConstraints(
    path: 'publicProfileDocument.name',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const publicProfileDocumentOccupation = CatchContractFieldConstraints(
    path: 'publicProfileDocument.occupation',
    maxLength: 120,
  );

  static const publicProfileDocumentProfilePhotos = CatchContractFieldConstraints(
    path: 'publicProfileDocument.profilePhotos',
    required: true,
  );

  static const publicProfileDocumentProfilePrompts = CatchContractFieldConstraints(
    path: 'publicProfileDocument.profilePrompts',
    required: true,
  );

  static const publicProfileDocumentRelationshipGoal = CatchContractFieldConstraints(
    path: 'publicProfileDocument.relationshipGoal',
    enumValues: <String>['relationship', 'casual', 'marriage', 'friendship', 'unsure'],
  );

  static const publicProfileDocumentReligion = CatchContractFieldConstraints(
    path: 'publicProfileDocument.religion',
    enumValues: <String>['hindu', 'muslim', 'christian', 'sikh', 'jain', 'buddhist', 'other', 'nonReligious'],
  );

  static const publicProfileDocumentScenario = CatchContractFieldConstraints(
    path: 'publicProfileDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const publicProfileDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'publicProfileDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const publicProfileDocumentSmoking = CatchContractFieldConstraints(
    path: 'publicProfileDocument.smoking',
    enumValues: <String>['never', 'occasionally', 'often'],
  );

  static const publicProfileDocumentWorkout = CatchContractFieldConstraints(
    path: 'publicProfileDocument.workout',
    enumValues: <String>['never', 'sometimes', 'often', 'everyday'],
  );

  static const publicRouteReservationDocumentCitySlug = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.citySlug',
    maxLength: 120,
    pattern: '^[a-z0-9-]+\$',
  );

  static const publicRouteReservationDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const publicRouteReservationDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.createdAt._seconds',
    required: true,
  );

  static const publicRouteReservationDocumentLastVerifiedAtNanoseconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.lastVerifiedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const publicRouteReservationDocumentLastVerifiedAtSeconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.lastVerifiedAt._seconds',
    required: true,
  );

  static const publicRouteReservationDocumentLastVerifiedByUid = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.lastVerifiedByUid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const publicRouteReservationDocumentLastVerifiedSource = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.lastVerifiedSource',
    required: true,
    enumValues: <String>['adminUpdateClubDetails', 'adminSetClubIndexStatus', 'adminUpdateOrganizerDetails', 'adminSetOrganizerIndexStatus', 'clubsToOrganizersMigration'],
  );

  static const publicRouteReservationDocumentOwnerCollection = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.ownerCollection',
    required: true,
    enumValues: <String>['clubs', 'organizers'],
  );

  static const publicRouteReservationDocumentOwnerId = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.ownerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const publicRouteReservationDocumentOwnerType = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.ownerType',
    required: true,
    enumValues: <String>['club', 'organizer'],
  );

  static const publicRouteReservationDocumentReleasedAtNanoseconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.releasedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const publicRouteReservationDocumentReleasedAtSeconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.releasedAt._seconds',
    required: true,
  );

  static const publicRouteReservationDocumentReleasedByUid = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.releasedByUid',
    maxLength: 180,
    minLength: 1,
  );

  static const publicRouteReservationDocumentReplacementRoutePath = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.replacementRoutePath',
    maxLength: 240,
    pattern: '^/organizers/([a-z0-9-]+/)?[a-z0-9-]+/\$',
  );

  static const publicRouteReservationDocumentRouteKey = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.routeKey',
    maxLength: 220,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+(?:__[a-z0-9-]+)*\$',
  );

  static const publicRouteReservationDocumentRouteKind = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.routeKind',
    required: true,
    enumValues: <String>['organizerCanonical'],
  );

  static const publicRouteReservationDocumentRoutePath = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.routePath',
    maxLength: 240,
    minLength: 1,
    required: true,
    pattern: '^/organizers/([a-z0-9-]+/)?[a-z0-9-]+/\$',
  );

  static const publicRouteReservationDocumentRouteSegments = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.routeSegments',
    required: true,
  );

  static const publicRouteReservationDocumentSlug = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.slug',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z0-9-]+\$',
  );

  static const publicRouteReservationDocumentStatus = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.status',
    required: true,
    enumValues: <String>['active', 'released'],
  );

  static const publicRouteReservationDocumentTargetPath = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.targetPath',
    maxLength: 260,
    minLength: 1,
    required: true,
    pattern: '^(clubs|organizers)/[^/]+\$',
  );

  static const publicRouteReservationDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const publicRouteReservationDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'publicRouteReservationDocument.updatedAt._seconds',
    required: true,
  );

  static const rateLimitDocumentAction = CatchContractFieldConstraints(
    path: 'rateLimitDocument.action',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const rateLimitDocumentCount = CatchContractFieldConstraints(
    path: 'rateLimitDocument.count',
    required: true,
    minimum: 1,
  );

  static const rateLimitDocumentExpiresAtNanoseconds = CatchContractFieldConstraints(
    path: 'rateLimitDocument.expiresAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const rateLimitDocumentExpiresAtSeconds = CatchContractFieldConstraints(
    path: 'rateLimitDocument.expiresAt._seconds',
    required: true,
  );

  static const rateLimitDocumentUid = CatchContractFieldConstraints(
    path: 'rateLimitDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const rateLimitDocumentWindowKey = CatchContractFieldConstraints(
    path: 'rateLimitDocument.windowKey',
    required: true,
    minimum: 0,
  );

  static const razorpayPendingOrderDocumentAmountInPaise = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.amountInPaise',
    required: true,
    minimum: 0,
    maximum: 100000000,
  );

  static const razorpayPendingOrderDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const razorpayPendingOrderDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.createdAt._seconds',
    required: true,
  );

  static const razorpayPendingOrderDocumentCurrency = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.currency',
    maxLength: 3,
    minLength: 3,
    required: true,
  );

  static const razorpayPendingOrderDocumentEventId = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const razorpayPendingOrderDocumentOrderId = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.orderId',
    maxLength: 240,
    minLength: 1,
    required: true,
  );

  static const razorpayPendingOrderDocumentProvider = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.provider',
    required: true,
    enumValues: <String>['razorpay'],
  );

  static const razorpayPendingOrderDocumentStatus = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.status',
    required: true,
    enumValues: <String>['pending', 'failed', 'expired'],
  );

  static const razorpayPendingOrderDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const razorpayPendingOrderDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.updatedAt._seconds',
    required: true,
  );

  static const razorpayPendingOrderDocumentUserId = CatchContractFieldConstraints(
    path: 'razorpayPendingOrderDocument.userId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reportDocumentContextId = CatchContractFieldConstraints(
    path: 'reportDocument.contextId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reportDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'reportDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const reportDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'reportDocument.createdAt._seconds',
    required: true,
  );

  static const reportDocumentNotes = CatchContractFieldConstraints(
    path: 'reportDocument.notes',
    maxLength: 1000,
  );

  static const reportDocumentReasonCode = CatchContractFieldConstraints(
    path: 'reportDocument.reasonCode',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const reportDocumentReporterUserId = CatchContractFieldConstraints(
    path: 'reportDocument.reporterUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reportDocumentSource = CatchContractFieldConstraints(
    path: 'reportDocument.source',
    required: true,
    enumValues: <String>['profile', 'chat', 'match', 'support'],
  );

  static const reportDocumentStatus = CatchContractFieldConstraints(
    path: 'reportDocument.status',
    required: true,
    enumValues: <String>['open', 'reviewed', 'dismissed'],
  );

  static const reportDocumentTargetUserId = CatchContractFieldConstraints(
    path: 'reportDocument.targetUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentClubId = CatchContractFieldConstraints(
    path: 'reviewDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentComment = CatchContractFieldConstraints(
    path: 'reviewDocument.comment',
    maxLength: 1000,
    required: true,
  );

  static const reviewDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'reviewDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const reviewDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'reviewDocument.createdAt._seconds',
    required: true,
  );

  static const reviewDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'reviewDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'reviewDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentEventId = CatchContractFieldConstraints(
    path: 'reviewDocument.eventId',
    maxLength: 180,
    minLength: 1,
  );

  static const reviewDocumentModerationStatus = CatchContractFieldConstraints(
    path: 'reviewDocument.moderationStatus',
    enumValues: <String>['published', 'pending', 'rejected'],
  );

  static const reviewDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'reviewDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentOwnerResponseCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'reviewDocument.ownerResponse.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const reviewDocumentOwnerResponseCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'reviewDocument.ownerResponse.createdAt._seconds',
    required: true,
  );

  static const reviewDocumentOwnerResponseHostName = CatchContractFieldConstraints(
    path: 'reviewDocument.ownerResponse.hostName',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentOwnerResponseHostUserId = CatchContractFieldConstraints(
    path: 'reviewDocument.ownerResponse.hostUserId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentOwnerResponseMessage = CatchContractFieldConstraints(
    path: 'reviewDocument.ownerResponse.message',
    maxLength: 1000,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentOwnerResponseUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'reviewDocument.ownerResponse.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const reviewDocumentOwnerResponseUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'reviewDocument.ownerResponse.updatedAt._seconds',
    required: true,
  );

  static const reviewDocumentRating = CatchContractFieldConstraints(
    path: 'reviewDocument.rating',
    required: true,
    minimum: 1,
    maximum: 5,
  );

  static const reviewDocumentReviewerName = CatchContractFieldConstraints(
    path: 'reviewDocument.reviewerName',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentReviewerUserId = CatchContractFieldConstraints(
    path: 'reviewDocument.reviewerUserId',
    maxLength: 180,
    minLength: 1,
  );

  static const reviewDocumentScenario = CatchContractFieldConstraints(
    path: 'reviewDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'reviewDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const reviewDocumentSource = CatchContractFieldConstraints(
    path: 'reviewDocument.source',
    enumValues: <String>['catchEvent', 'publicListing'],
  );

  static const reviewDocumentSubmittedFromPath = CatchContractFieldConstraints(
    path: 'reviewDocument.submittedFromPath',
    maxLength: 240,
  );

  static const reviewDocumentUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'reviewDocument.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const reviewDocumentUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'reviewDocument.updatedAt._seconds',
    required: true,
  );

  static const reviewDocumentVerificationStatus = CatchContractFieldConstraints(
    path: 'reviewDocument.verificationStatus',
    enumValues: <String>['verified', 'unverified'],
  );

  static const savedEventDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'savedEventDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const savedEventDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'savedEventDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const savedEventDocumentEventId = CatchContractFieldConstraints(
    path: 'savedEventDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const savedEventDocumentSavedAtNanoseconds = CatchContractFieldConstraints(
    path: 'savedEventDocument.savedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const savedEventDocumentSavedAtSeconds = CatchContractFieldConstraints(
    path: 'savedEventDocument.savedAt._seconds',
    required: true,
  );

  static const savedEventDocumentScenario = CatchContractFieldConstraints(
    path: 'savedEventDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const savedEventDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'savedEventDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const savedEventDocumentUid = CatchContractFieldConstraints(
    path: 'savedEventDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const seedEventManifestDocumentAnchorUserIds = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.anchorUserIds',
    required: true,
  );

  static const seedEventManifestDocumentCounts = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.counts',
    required: true,
  );

  static const seedEventManifestDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const seedEventManifestDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const seedEventManifestDocumentGeneratedAtNanoseconds = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.generatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const seedEventManifestDocumentGeneratedAtSeconds = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.generatedAt._seconds',
    required: true,
  );

  static const seedEventManifestDocumentManifestId = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.manifestId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const seedEventManifestDocumentPaths = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.paths',
    required: true,
  );

  static const seedEventManifestDocumentScenario = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const seedEventManifestDocumentSeedId = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.seedId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const seedEventManifestDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'seedEventManifestDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const swipeDocumentComment = CatchContractFieldConstraints(
    path: 'swipeDocument.comment',
    maxLength: 240,
  );

  static const swipeDocumentCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'swipeDocument.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const swipeDocumentCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'swipeDocument.createdAt._seconds',
    required: true,
  );

  static const swipeDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'swipeDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const swipeDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'swipeDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const swipeDocumentDirection = CatchContractFieldConstraints(
    path: 'swipeDocument.direction',
    required: true,
    enumValues: <String>['like', 'pass'],
  );

  static const swipeDocumentEventId = CatchContractFieldConstraints(
    path: 'swipeDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const swipeDocumentReactionTargetId = CatchContractFieldConstraints(
    path: 'swipeDocument.reactionTargetId',
    maxLength: 80,
    minLength: 1,
  );

  static const swipeDocumentReactionTargetLabel = CatchContractFieldConstraints(
    path: 'swipeDocument.reactionTargetLabel',
    maxLength: 80,
  );

  static const swipeDocumentReactionTargetPreview = CatchContractFieldConstraints(
    path: 'swipeDocument.reactionTargetPreview',
    maxLength: 240,
  );

  static const swipeDocumentReactionTargetType = CatchContractFieldConstraints(
    path: 'swipeDocument.reactionTargetType',
    enumValues: <String>['heroPhoto', 'photo', 'profilePrompt', 'compatibility', 'running', 'details', 'lifestyle'],
  );

  static const swipeDocumentScenario = CatchContractFieldConstraints(
    path: 'swipeDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const swipeDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'swipeDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const swipeDocumentSwiperId = CatchContractFieldConstraints(
    path: 'swipeDocument.swiperId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const swipeDocumentTargetId = CatchContractFieldConstraints(
    path: 'swipeDocument.targetId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const updateClubPatchArea = CatchContractFieldConstraints(
    path: 'updateClubPatch.area',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateClubPatchDescription = CatchContractFieldConstraints(
    path: 'updateClubPatch.description',
    maxLength: 2000,
    minLength: 1,
    required: true,
  );

  static const updateClubPatchEmail = CatchContractFieldConstraints(
    path: 'updateClubPatch.email',
    maxLength: 320,
  );

  static const updateClubPatchHostAvatarUrl = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostAvatarUrl',
    maxLength: 320,
  );

  static const updateClubPatchHostDefaultsEventPolicyAdmissionPreset = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.admissionPreset',
    enumValues: <String>['openCapacity', 'inviteOnly', 'balancedSingles', 'fixedCohortCaps'],
  );

  static const updateClubPatchHostDefaultsEventPolicyCancellationPolicyId = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.cancellationPolicyId',
    enumValues: <String>['flexible', 'standard', 'strict'],
  );

  static const updateClubPatchHostDefaultsEventPolicyDynamicPricingMaxInPaise = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.dynamicPricingMaxInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const updateClubPatchHostDefaultsEventPolicyDynamicPricingStepInPaise = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.dynamicPricingStepInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const updateClubPatchHostDefaultsEventPolicyMaxAge = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.maxAge',
    minimum: 0,
    maximum: 120,
  );

  static const updateClubPatchHostDefaultsEventPolicyMaxMen = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.maxMen',
    minimum: 0,
  );

  static const updateClubPatchHostDefaultsEventPolicyMaxWomen = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.maxWomen',
    minimum: 0,
  );

  static const updateClubPatchHostDefaultsEventPolicyMinAge = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventPolicy.minAge',
    minimum: 0,
    maximum: 120,
  );

  static const updateClubPatchHostDefaultsEventSuccessAttendeePrompt = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.attendeePrompt',
    maxLength: 300,
  );

  static const updateClubPatchHostDefaultsEventSuccessHostGoal = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.hostGoal',
    maxLength: 300,
  );

  static const updateClubPatchHostDefaultsEventSuccessPlaybookId = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.playbookId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateClubPatchHostDefaultsEventSuccessQuestionnaireConfigCustomTitle = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.questionnaireConfig.customTitle',
    maxLength: 80,
  );

  static const updateClubPatchHostDefaultsEventSuccessQuestionnaireConfigTemplateId = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.questionnaireConfig.templateId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateClubPatchHostDefaultsEventSuccessStructureConfigMaxPairMeetings = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.structureConfig.maxPairMeetings',
    minimum: 1,
    maximum: 10,
  );

  static const updateClubPatchHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds',
    required: true,
    minimum: 0,
    maximum: 60,
  );

  static const updateClubPatchHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes',
    minimum: 5,
    maximum: 180,
  );

  static const updateClubPatchHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy',
    enumValues: <String>['avoid', 'allowWhenExhausted'],
  );

  static const updateClubPatchHostDefaultsEventSuccessStructureConfigUnitCount = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.structureConfig.unitCount',
    minimum: 1,
    maximum: 200,
  );

  static const updateClubPatchHostDefaultsEventSuccessStructureConfigUnitKind = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.structureConfig.unitKind',
    required: true,
    enumValues: <String>['wholeGroup', 'pods', 'pairs', 'teams', 'tables'],
  );

  static const updateClubPatchHostDefaultsEventSuccessStructureConfigUnitSize = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.eventSuccess.structureConfig.unitSize',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const updateClubPatchHostDefaultsPrimaryActivityKind = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostDefaults.primaryActivityKind',
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const updateClubPatchHostName = CatchContractFieldConstraints(
    path: 'updateClubPatch.hostName',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateClubPatchImageUrl = CatchContractFieldConstraints(
    path: 'updateClubPatch.imageUrl',
    maxLength: 320,
  );

  static const updateClubPatchInstagramHandle = CatchContractFieldConstraints(
    path: 'updateClubPatch.instagramHandle',
    maxLength: 320,
  );

  static const updateClubPatchLocation = CatchContractFieldConstraints(
    path: 'updateClubPatch.location',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const updateClubPatchLogoPhotoCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const updateClubPatchLogoPhotoCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.createdAt._seconds',
    required: true,
  );

  static const updateClubPatchLogoPhotoId = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.id',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[A-Za-z0-9_-]+\$',
  );

  static const updateClubPatchLogoPhotoModerationReason = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.moderation.reason',
    maxLength: 240,
  );

  static const updateClubPatchLogoPhotoModerationReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.moderation.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const updateClubPatchLogoPhotoModerationReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.moderation.reviewedAt._seconds',
    required: true,
  );

  static const updateClubPatchLogoPhotoModerationStatus = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.moderation.status',
    required: true,
    enumValues: <String>['pending', 'approved', 'rejected'],
  );

  static const updateClubPatchLogoPhotoPosition = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.position',
    required: true,
    minimum: 0,
    maximum: 19,
  );

  static const updateClubPatchLogoPhotoStoragePath = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.storagePath',
    maxLength: 512,
    minLength: 1,
    required: true,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const updateClubPatchLogoPhotoThumbnailStoragePath = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.thumbnailStoragePath',
    maxLength: 512,
    minLength: 1,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const updateClubPatchLogoPhotoThumbnailUrl = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.thumbnailUrl',
    maxLength: 2048,
  );

  static const updateClubPatchLogoPhotoUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const updateClubPatchLogoPhotoUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.updatedAt._seconds',
    required: true,
  );

  static const updateClubPatchLogoPhotoUrl = CatchContractFieldConstraints(
    path: 'updateClubPatch.logoPhoto.url',
    maxLength: 2048,
    required: true,
  );

  static const updateClubPatchName = CatchContractFieldConstraints(
    path: 'updateClubPatch.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateClubPatchOrganizerType = CatchContractFieldConstraints(
    path: 'updateClubPatch.organizerType',
    enumValues: <String>['club', 'community', 'individual', 'eventProducer', 'venue', 'brand'],
  );

  static const updateClubPatchPhoneNumber = CatchContractFieldConstraints(
    path: 'updateClubPatch.phoneNumber',
    maxLength: 320,
  );

  static const updateClubPatchProfileImageUrl = CatchContractFieldConstraints(
    path: 'updateClubPatch.profileImageUrl',
    maxLength: 320,
  );

  static const updateOrganizerCallablePayloadFieldsArea = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.area',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsDescription = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.description',
    maxLength: 2000,
    minLength: 1,
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsEmail = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.email',
    maxLength: 320,
  );

  static const updateOrganizerCallablePayloadFieldsHostAvatarUrl = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostAvatarUrl',
    maxLength: 320,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyAdmissionPreset = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.admissionPreset',
    enumValues: <String>['openCapacity', 'inviteOnly', 'balancedSingles', 'fixedCohortCaps'],
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyCancellationPolicyId = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.cancellationPolicyId',
    enumValues: <String>['flexible', 'standard', 'strict'],
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyDynamicPricingMaxInPaise = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.dynamicPricingMaxInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyDynamicPricingStepInPaise = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.dynamicPricingStepInPaise',
    minimum: 0,
    maximum: 100000000,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMaxAge = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.maxAge',
    minimum: 0,
    maximum: 120,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMaxMen = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.maxMen',
    minimum: 0,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMaxWomen = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.maxWomen',
    minimum: 0,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMinAge = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.minAge',
    minimum: 0,
    maximum: 120,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessAttendeePrompt = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.attendeePrompt',
    maxLength: 300,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessHostGoal = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.hostGoal',
    maxLength: 300,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessPlaybookId = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.playbookId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessQuestionnaireConfigCustomTitle = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.questionnaireConfig.customTitle',
    maxLength: 80,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessQuestionnaireConfigTemplateId = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.questionnaireConfig.templateId',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigMaxPairMeetings = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.maxPairMeetings',
    minimum: 1,
    maximum: 10,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds',
    required: true,
    minimum: 0,
    maximum: 60,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes',
    minimum: 5,
    maximum: 180,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy',
    enumValues: <String>['avoid', 'allowWhenExhausted'],
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigUnitCount = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.unitCount',
    minimum: 1,
    maximum: 200,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigUnitKind = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.unitKind',
    required: true,
    enumValues: <String>['wholeGroup', 'pods', 'pairs', 'teams', 'tables'],
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigUnitSize = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.unitSize',
    required: true,
    minimum: 1,
    maximum: 1000,
  );

  static const updateOrganizerCallablePayloadFieldsHostDefaultsPrimaryActivityKind = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostDefaults.primaryActivityKind',
    enumValues: <String>['socialRun', 'running', 'walking', 'pickleball', 'padel', 'tennis', 'badminton', 'cycling', 'spinClass', 'yoga', 'strengthTraining', 'pubQuiz', 'barCrawl', 'dinner', 'singlesMixer', 'openActivity'],
  );

  static const updateOrganizerCallablePayloadFieldsHostName = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.hostName',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsImageUrl = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.imageUrl',
    maxLength: 320,
  );

  static const updateOrganizerCallablePayloadFieldsInstagramHandle = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.instagramHandle',
    maxLength: 320,
  );

  static const updateOrganizerCallablePayloadFieldsLocation = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.location',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoCreatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.createdAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoCreatedAtSeconds = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.createdAt._seconds',
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoId = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.id',
    maxLength: 120,
    minLength: 1,
    required: true,
    pattern: '^[A-Za-z0-9_-]+\$',
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoModerationReason = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.moderation.reason',
    maxLength: 240,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoModerationReviewedAtNanoseconds = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.moderation.reviewedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoModerationReviewedAtSeconds = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.moderation.reviewedAt._seconds',
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoModerationStatus = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.moderation.status',
    required: true,
    enumValues: <String>['pending', 'approved', 'rejected'],
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoPosition = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.position',
    required: true,
    minimum: 0,
    maximum: 19,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoStoragePath = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.storagePath',
    maxLength: 512,
    minLength: 1,
    required: true,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoThumbnailStoragePath = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.thumbnailStoragePath',
    maxLength: 512,
    minLength: 1,
    pattern: '^[^/\\u0000][^\\u0000]*\$',
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoThumbnailUrl = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.thumbnailUrl',
    maxLength: 2048,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoUpdatedAtNanoseconds = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.updatedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoUpdatedAtSeconds = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.updatedAt._seconds',
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsLogoPhotoUrl = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.logoPhoto.url',
    maxLength: 2048,
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsName = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateOrganizerCallablePayloadFieldsOrganizerType = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.organizerType',
    enumValues: <String>['club', 'community', 'individual', 'eventProducer', 'venue', 'brand'],
  );

  static const updateOrganizerCallablePayloadFieldsPhoneNumber = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.phoneNumber',
    maxLength: 320,
  );

  static const updateOrganizerCallablePayloadFieldsProfileImageUrl = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.fields.profileImageUrl',
    maxLength: 320,
  );

  static const updateOrganizerCallablePayloadOrganizerId = CatchContractFieldConstraints(
    path: 'updateOrganizerCallablePayload.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const updateUserProfilePatchActivityPreferencesRunningPaceMaxSecsPerKm = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.activityPreferences.running.paceMaxSecsPerKm',
    required: true,
    minimum: 1,
  );

  static const updateUserProfilePatchActivityPreferencesRunningPaceMinSecsPerKm = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.activityPreferences.running.paceMinSecsPerKm',
    required: true,
    minimum: 1,
  );

  static const updateUserProfilePatchActivityPreferencesRunningPreferredDistances = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.activityPreferences.running.preferredDistances',
    required: true,
  );

  static const updateUserProfilePatchActivityPreferencesRunningPreferredRunTimes = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.activityPreferences.running.preferredRunTimes',
    required: true,
  );

  static const updateUserProfilePatchActivityPreferencesRunningRunningReasons = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.activityPreferences.running.runningReasons',
    required: true,
  );

  static const updateUserProfilePatchActivityPreferencesRunningVersion = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.activityPreferences.running.version',
    required: true,
    minimum: 0,
  );

  static const updateUserProfilePatchChildren = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.children',
    enumValues: <String>['dontHave', 'haveWantMore', 'haveNoMore', 'wantSomeday', 'dontWant'],
  );

  static const updateUserProfilePatchCity = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.city',
    maxLength: 120,
    minLength: 1,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const updateUserProfilePatchCompany = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.company',
    maxLength: 120,
  );

  static const updateUserProfilePatchDateOfBirth = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.dateOfBirth',
    minimum: 0,
  );

  static const updateUserProfilePatchDiet = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.diet',
    enumValues: <String>['omnivore', 'vegetarian', 'vegan', 'jain', 'other'],
  );

  static const updateUserProfilePatchDisplayName = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.displayName',
    maxLength: 80,
    minLength: 1,
    required: true,
    pattern: '.*\\S.*',
  );

  static const updateUserProfilePatchDrinking = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.drinking',
    enumValues: <String>['never', 'socially', 'often'],
  );

  static const updateUserProfilePatchEducation = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.education',
    enumValues: <String>['highSchool', 'someCollege', 'bachelors', 'masters', 'phd', 'tradeSchool', 'other'],
  );

  static const updateUserProfilePatchEmail = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.email',
    maxLength: 320,
  );

  static const updateUserProfilePatchGender = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.gender',
    enumValues: <String>['man', 'woman', 'nonBinary', 'other'],
  );

  static const updateUserProfilePatchHeight = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.height',
    minimum: 120,
    maximum: 220,
  );

  static const updateUserProfilePatchInstagramHandle = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.instagramHandle',
    maxLength: 30,
    minLength: 1,
    pattern: '^[A-Za-z0-9._]{1,30}\$',
  );

  static const updateUserProfilePatchLatitude = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.latitude',
    minimum: -90,
    maximum: 90,
  );

  static const updateUserProfilePatchLongitude = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.longitude',
    minimum: -180,
    maximum: 180,
  );

  static const updateUserProfilePatchMaxAgePreference = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.maxAgePreference',
    minimum: 18,
    maximum: 99,
  );

  static const updateUserProfilePatchMinAgePreference = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.minAgePreference',
    minimum: 18,
    maximum: 99,
  );

  static const updateUserProfilePatchName = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const updateUserProfilePatchOccupation = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.occupation',
    maxLength: 120,
  );

  static const updateUserProfilePatchPhoneNumber = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.phoneNumber',
    maxLength: 32,
    minLength: 1,
    required: true,
  );

  static const updateUserProfilePatchRelationshipGoal = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.relationshipGoal',
    enumValues: <String>['relationship', 'casual', 'marriage', 'friendship', 'unsure'],
  );

  static const updateUserProfilePatchReligion = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.religion',
    enumValues: <String>['hindu', 'muslim', 'christian', 'sikh', 'jain', 'buddhist', 'other', 'nonReligious'],
  );

  static const updateUserProfilePatchSmoking = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.smoking',
    enumValues: <String>['never', 'occasionally', 'often'],
  );

  static const updateUserProfilePatchWorkout = CatchContractFieldConstraints(
    path: 'updateUserProfilePatch.workout',
    enumValues: <String>['never', 'sometimes', 'often', 'everyday'],
  );

  static const userEventScheduleLockDocumentClubId = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.clubId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentEndTimeMillis = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.endTimeMillis',
    required: true,
    minimum: 0,
  );

  static const userEventScheduleLockDocumentEventId = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.eventId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentOrganizerId = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.organizerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentOwnerId = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.ownerId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentOwnerType = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.ownerType',
    required: true,
  );

  static const userEventScheduleLockDocumentScenario = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const userEventScheduleLockDocumentSlot = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.slot',
    required: true,
    minimum: 0,
  );

  static const userEventScheduleLockDocumentStartTimeMillis = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.startTimeMillis',
    required: true,
    minimum: 0,
  );

  static const userEventScheduleLockDocumentUid = CatchContractFieldConstraints(
    path: 'userEventScheduleLockDocument.uid',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const userProfileDocumentActivityPreferencesRunningPaceMaxSecsPerKm = CatchContractFieldConstraints(
    path: 'userProfileDocument.activityPreferences.running.paceMaxSecsPerKm',
    required: true,
    minimum: 1,
  );

  static const userProfileDocumentActivityPreferencesRunningPaceMinSecsPerKm = CatchContractFieldConstraints(
    path: 'userProfileDocument.activityPreferences.running.paceMinSecsPerKm',
    required: true,
    minimum: 1,
  );

  static const userProfileDocumentActivityPreferencesRunningPreferredDistances = CatchContractFieldConstraints(
    path: 'userProfileDocument.activityPreferences.running.preferredDistances',
    required: true,
  );

  static const userProfileDocumentActivityPreferencesRunningPreferredRunTimes = CatchContractFieldConstraints(
    path: 'userProfileDocument.activityPreferences.running.preferredRunTimes',
    required: true,
  );

  static const userProfileDocumentActivityPreferencesRunningRunningReasons = CatchContractFieldConstraints(
    path: 'userProfileDocument.activityPreferences.running.runningReasons',
    required: true,
  );

  static const userProfileDocumentActivityPreferencesRunningVersion = CatchContractFieldConstraints(
    path: 'userProfileDocument.activityPreferences.running.version',
    required: true,
    minimum: 0,
  );

  static const userProfileDocumentChildren = CatchContractFieldConstraints(
    path: 'userProfileDocument.children',
    enumValues: <String>['dontHave', 'haveWantMore', 'haveNoMore', 'wantSomeday', 'dontWant'],
  );

  static const userProfileDocumentCity = CatchContractFieldConstraints(
    path: 'userProfileDocument.city',
    maxLength: 120,
    minLength: 1,
    pattern: '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
  );

  static const userProfileDocumentCompany = CatchContractFieldConstraints(
    path: 'userProfileDocument.company',
    maxLength: 120,
  );

  static const userProfileDocumentCountryCode = CatchContractFieldConstraints(
    path: 'userProfileDocument.countryCode',
    pattern: '^\\+\\d{1,4}\$',
  );

  static const userProfileDocumentDateOfBirthNanoseconds = CatchContractFieldConstraints(
    path: 'userProfileDocument.dateOfBirth._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const userProfileDocumentDateOfBirthSeconds = CatchContractFieldConstraints(
    path: 'userProfileDocument.dateOfBirth._seconds',
    required: true,
  );

  static const userProfileDocumentDeletedAtNanoseconds = CatchContractFieldConstraints(
    path: 'userProfileDocument.deletedAt._nanoseconds',
    required: true,
    minimum: 0,
    maximum: 999999999,
  );

  static const userProfileDocumentDeletedAtSeconds = CatchContractFieldConstraints(
    path: 'userProfileDocument.deletedAt._seconds',
    required: true,
  );

  static const userProfileDocumentDemoOpsCommand = CatchContractFieldConstraints(
    path: 'userProfileDocument.demoOpsCommand',
    maxLength: 80,
    minLength: 1,
    required: true,
  );

  static const userProfileDocumentDemoOpsId = CatchContractFieldConstraints(
    path: 'userProfileDocument.demoOpsId',
    maxLength: 180,
    minLength: 1,
    required: true,
  );

  static const userProfileDocumentDiet = CatchContractFieldConstraints(
    path: 'userProfileDocument.diet',
    enumValues: <String>['omnivore', 'vegetarian', 'vegan', 'jain', 'other'],
  );

  static const userProfileDocumentDisplayName = CatchContractFieldConstraints(
    path: 'userProfileDocument.displayName',
    maxLength: 80,
    minLength: 1,
    required: true,
    pattern: '.*\\S.*',
  );

  static const userProfileDocumentDrinking = CatchContractFieldConstraints(
    path: 'userProfileDocument.drinking',
    enumValues: <String>['never', 'socially', 'often'],
  );

  static const userProfileDocumentEducation = CatchContractFieldConstraints(
    path: 'userProfileDocument.education',
    enumValues: <String>['highSchool', 'someCollege', 'bachelors', 'masters', 'phd', 'tradeSchool', 'other'],
  );

  static const userProfileDocumentEmail = CatchContractFieldConstraints(
    path: 'userProfileDocument.email',
    maxLength: 320,
  );

  static const userProfileDocumentFirstName = CatchContractFieldConstraints(
    path: 'userProfileDocument.firstName',
    maxLength: 80,
    required: true,
  );

  static const userProfileDocumentGender = CatchContractFieldConstraints(
    path: 'userProfileDocument.gender',
    required: true,
    enumValues: <String>['man', 'woman', 'nonBinary', 'other'],
  );

  static const userProfileDocumentHeight = CatchContractFieldConstraints(
    path: 'userProfileDocument.height',
    minimum: 120,
    maximum: 220,
  );

  static const userProfileDocumentInstagramHandle = CatchContractFieldConstraints(
    path: 'userProfileDocument.instagramHandle',
    maxLength: 30,
    minLength: 1,
    pattern: '^[A-Za-z0-9._]{1,30}\$',
  );

  static const userProfileDocumentInterestedInGenders = CatchContractFieldConstraints(
    path: 'userProfileDocument.interestedInGenders',
    required: true,
  );

  static const userProfileDocumentLanguages = CatchContractFieldConstraints(
    path: 'userProfileDocument.languages',
    required: true,
  );

  static const userProfileDocumentLastName = CatchContractFieldConstraints(
    path: 'userProfileDocument.lastName',
    maxLength: 80,
    required: true,
  );

  static const userProfileDocumentLatitude = CatchContractFieldConstraints(
    path: 'userProfileDocument.latitude',
    minimum: -90,
    maximum: 90,
  );

  static const userProfileDocumentLongitude = CatchContractFieldConstraints(
    path: 'userProfileDocument.longitude',
    minimum: -180,
    maximum: 180,
  );

  static const userProfileDocumentMaxAgePreference = CatchContractFieldConstraints(
    path: 'userProfileDocument.maxAgePreference',
    required: true,
    minimum: 18,
    maximum: 99,
  );

  static const userProfileDocumentMinAgePreference = CatchContractFieldConstraints(
    path: 'userProfileDocument.minAgePreference',
    required: true,
    minimum: 18,
    maximum: 99,
  );

  static const userProfileDocumentName = CatchContractFieldConstraints(
    path: 'userProfileDocument.name',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const userProfileDocumentOccupation = CatchContractFieldConstraints(
    path: 'userProfileDocument.occupation',
    maxLength: 120,
  );

  static const userProfileDocumentPhoneNumber = CatchContractFieldConstraints(
    path: 'userProfileDocument.phoneNumber',
    maxLength: 32,
    minLength: 1,
    required: true,
  );

  static const userProfileDocumentPrefsClubUpdates = CatchContractFieldConstraints(
    path: 'userProfileDocument.prefsClubUpdates',
    required: true,
  );

  static const userProfileDocumentPrefsEventReminders = CatchContractFieldConstraints(
    path: 'userProfileDocument.prefsEventReminders',
    required: true,
  );

  static const userProfileDocumentPrefsMessages = CatchContractFieldConstraints(
    path: 'userProfileDocument.prefsMessages',
    required: true,
  );

  static const userProfileDocumentPrefsNewCatches = CatchContractFieldConstraints(
    path: 'userProfileDocument.prefsNewCatches',
    required: true,
  );

  static const userProfileDocumentPrefsRunStatusUpdates = CatchContractFieldConstraints(
    path: 'userProfileDocument.prefsRunStatusUpdates',
    required: true,
  );

  static const userProfileDocumentPrefsShowOnMap = CatchContractFieldConstraints(
    path: 'userProfileDocument.prefsShowOnMap',
    required: true,
  );

  static const userProfileDocumentPrefsWeeklyDigest = CatchContractFieldConstraints(
    path: 'userProfileDocument.prefsWeeklyDigest',
    required: true,
  );

  static const userProfileDocumentProfileComplete = CatchContractFieldConstraints(
    path: 'userProfileDocument.profileComplete',
    required: true,
  );

  static const userProfileDocumentProfilePhotos = CatchContractFieldConstraints(
    path: 'userProfileDocument.profilePhotos',
    required: true,
  );

  static const userProfileDocumentProfilePrompts = CatchContractFieldConstraints(
    path: 'userProfileDocument.profilePrompts',
    required: true,
  );

  static const userProfileDocumentRelationshipGoal = CatchContractFieldConstraints(
    path: 'userProfileDocument.relationshipGoal',
    enumValues: <String>['relationship', 'casual', 'marriage', 'friendship', 'unsure'],
  );

  static const userProfileDocumentReligion = CatchContractFieldConstraints(
    path: 'userProfileDocument.religion',
    enumValues: <String>['hindu', 'muslim', 'christian', 'sikh', 'jain', 'buddhist', 'other', 'nonReligious'],
  );

  static const userProfileDocumentScenario = CatchContractFieldConstraints(
    path: 'userProfileDocument.scenario',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const userProfileDocumentSeedPrefix = CatchContractFieldConstraints(
    path: 'userProfileDocument.seedPrefix',
    maxLength: 120,
    minLength: 1,
    required: true,
  );

  static const userProfileDocumentSmoking = CatchContractFieldConstraints(
    path: 'userProfileDocument.smoking',
    enumValues: <String>['never', 'occasionally', 'often'],
  );

  static const userProfileDocumentWorkout = CatchContractFieldConstraints(
    path: 'userProfileDocument.workout',
    enumValues: <String>['never', 'sometimes', 'often', 'everyday'],
  );

  static const all = <String, CatchContractFieldConstraints>{
    'activityNotificationDocument.actorName': activityNotificationDocumentActorName,
    'activityNotificationDocument.actorUid': activityNotificationDocumentActorUid,
    'activityNotificationDocument.body': activityNotificationDocumentBody,
    'activityNotificationDocument.clubId': activityNotificationDocumentClubId,
    'activityNotificationDocument.createdAt._nanoseconds': activityNotificationDocumentCreatedAtNanoseconds,
    'activityNotificationDocument.createdAt._seconds': activityNotificationDocumentCreatedAtSeconds,
    'activityNotificationDocument.demoOpsCommand': activityNotificationDocumentDemoOpsCommand,
    'activityNotificationDocument.demoOpsId': activityNotificationDocumentDemoOpsId,
    'activityNotificationDocument.eventId': activityNotificationDocumentEventId,
    'activityNotificationDocument.matchId': activityNotificationDocumentMatchId,
    'activityNotificationDocument.organizerId': activityNotificationDocumentOrganizerId,
    'activityNotificationDocument.postId': activityNotificationDocumentPostId,
    'activityNotificationDocument.readAt._nanoseconds': activityNotificationDocumentReadAtNanoseconds,
    'activityNotificationDocument.readAt._seconds': activityNotificationDocumentReadAtSeconds,
    'activityNotificationDocument.scenario': activityNotificationDocumentScenario,
    'activityNotificationDocument.seedPrefix': activityNotificationDocumentSeedPrefix,
    'activityNotificationDocument.title': activityNotificationDocumentTitle,
    'activityNotificationDocument.type': activityNotificationDocumentType,
    'activityNotificationDocument.uid': activityNotificationDocumentUid,
    'adminUpdateClubDetailsCallablePayload.clubId': adminUpdateClubDetailsCallablePayloadClubId,
    'adminUpdateClubDetailsCallablePayload.fields.appVisibility': adminUpdateClubDetailsCallablePayloadFieldsAppVisibility,
    'adminUpdateClubDetailsCallablePayload.fields.area': adminUpdateClubDetailsCallablePayloadFieldsArea,
    'adminUpdateClubDetailsCallablePayload.fields.cityName': adminUpdateClubDetailsCallablePayloadFieldsCityName,
    'adminUpdateClubDetailsCallablePayload.fields.countryCode': adminUpdateClubDetailsCallablePayloadFieldsCountryCode,
    'adminUpdateClubDetailsCallablePayload.fields.countryName': adminUpdateClubDetailsCallablePayloadFieldsCountryName,
    'adminUpdateClubDetailsCallablePayload.fields.description': adminUpdateClubDetailsCallablePayloadFieldsDescription,
    'adminUpdateClubDetailsCallablePayload.fields.displayCategory': adminUpdateClubDetailsCallablePayloadFieldsDisplayCategory,
    'adminUpdateClubDetailsCallablePayload.fields.email': adminUpdateClubDetailsCallablePayloadFieldsEmail,
    'adminUpdateClubDetailsCallablePayload.fields.entityKind': adminUpdateClubDetailsCallablePayloadFieldsEntityKind,
    'adminUpdateClubDetailsCallablePayload.fields.imageUrl': adminUpdateClubDetailsCallablePayloadFieldsImageUrl,
    'adminUpdateClubDetailsCallablePayload.fields.instagramHandle': adminUpdateClubDetailsCallablePayloadFieldsInstagramHandle,
    'adminUpdateClubDetailsCallablePayload.fields.location': adminUpdateClubDetailsCallablePayloadFieldsLocation,
    'adminUpdateClubDetailsCallablePayload.fields.name': adminUpdateClubDetailsCallablePayloadFieldsName,
    'adminUpdateClubDetailsCallablePayload.fields.organizerType': adminUpdateClubDetailsCallablePayloadFieldsOrganizerType,
    'adminUpdateClubDetailsCallablePayload.fields.phoneNumber': adminUpdateClubDetailsCallablePayloadFieldsPhoneNumber,
    'adminUpdateClubDetailsCallablePayload.fields.profileImageUrl': adminUpdateClubDetailsCallablePayloadFieldsProfileImageUrl,
    'adminUpdateClubDetailsCallablePayload.fields.provenance.sourceConfidence': adminUpdateClubDetailsCallablePayloadFieldsProvenanceSourceConfidence,
    'adminUpdateClubDetailsCallablePayload.fields.provenance.verificationStatus': adminUpdateClubDetailsCallablePayloadFieldsProvenanceVerificationStatus,
    'adminUpdateClubDetailsCallablePayload.fields.publicCategoryLabel': adminUpdateClubDetailsCallablePayloadFieldsPublicCategoryLabel,
    'adminUpdateClubDetailsCallablePayload.fields.publicPage.canonicalPath': adminUpdateClubDetailsCallablePayloadFieldsPublicPageCanonicalPath,
    'adminUpdateClubDetailsCallablePayload.fields.publicPage.citySlug': adminUpdateClubDetailsCallablePayloadFieldsPublicPageCitySlug,
    'adminUpdateClubDetailsCallablePayload.fields.publicPage.publishStatus': adminUpdateClubDetailsCallablePayloadFieldsPublicPagePublishStatus,
    'adminUpdateClubDetailsCallablePayload.fields.publicPage.seoDescription': adminUpdateClubDetailsCallablePayloadFieldsPublicPageSeoDescription,
    'adminUpdateClubDetailsCallablePayload.fields.publicPage.seoTitle': adminUpdateClubDetailsCallablePayloadFieldsPublicPageSeoTitle,
    'adminUpdateClubDetailsCallablePayload.fields.publicPage.slug': adminUpdateClubDetailsCallablePayloadFieldsPublicPageSlug,
    'adminUpdateClubDetailsCallablePayload.fields.publicProfile.headline': adminUpdateClubDetailsCallablePayloadFieldsPublicProfileHeadline,
    'adminUpdateClubDetailsCallablePayload.fields.publicProfile.sourceSummary': adminUpdateClubDetailsCallablePayloadFieldsPublicProfileSourceSummary,
    'adminUpdateClubDetailsCallablePayload.fields.publicProfile.summary': adminUpdateClubDetailsCallablePayloadFieldsPublicProfileSummary,
    'adminUpdateClubDetailsCallablePayload.fields.regionName': adminUpdateClubDetailsCallablePayloadFieldsRegionName,
    'adminUpdateClubDetailsCallablePayload.reviewNote': adminUpdateClubDetailsCallablePayloadReviewNote,
    'adminUpdateEventDetailsCallablePayload.eventId': adminUpdateEventDetailsCallablePayloadEventId,
    'adminUpdateEventDetailsCallablePayload.fields.description': adminUpdateEventDetailsCallablePayloadFieldsDescription,
    'adminUpdateEventDetailsCallablePayload.fields.distanceKm': adminUpdateEventDetailsCallablePayloadFieldsDistanceKm,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.activityKind': adminUpdateEventDetailsCallablePayloadFieldsEventFormatActivityKind,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.customActivityLabel': adminUpdateEventDetailsCallablePayloadFieldsEventFormatCustomActivityLabel,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.defaultPlaybookId': adminUpdateEventDetailsCallablePayloadFieldsEventFormatDefaultPlaybookId,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.assignmentAlgorithm': adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesAssignmentAlgorithm,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.compatibilityPolicy': adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesCompatibilityPolicy,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.phoneAvailability': adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesPhoneAvailability,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.eventSuccessPrimitives.rotationSuitability': adminUpdateEventDetailsCallablePayloadFieldsEventFormatEventSuccessPrimitivesRotationSuitability,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.interactionModel': adminUpdateEventDetailsCallablePayloadFieldsEventFormatInteractionModel,
    'adminUpdateEventDetailsCallablePayload.fields.eventFormat.version': adminUpdateEventDetailsCallablePayloadFieldsEventFormatVersion,
    'adminUpdateEventDetailsCallablePayload.fields.pace': adminUpdateEventDetailsCallablePayloadFieldsPace,
    'adminUpdateEventDetailsCallablePayload.fields.photoUrl': adminUpdateEventDetailsCallablePayloadFieldsPhotoUrl,
    'adminUpdateEventDetailsCallablePayload.reviewNote': adminUpdateEventDetailsCallablePayloadReviewNote,
    'adminUpdateOrganizerDetailsCallablePayload.fields.appVisibility': adminUpdateOrganizerDetailsCallablePayloadFieldsAppVisibility,
    'adminUpdateOrganizerDetailsCallablePayload.fields.area': adminUpdateOrganizerDetailsCallablePayloadFieldsArea,
    'adminUpdateOrganizerDetailsCallablePayload.fields.cityName': adminUpdateOrganizerDetailsCallablePayloadFieldsCityName,
    'adminUpdateOrganizerDetailsCallablePayload.fields.countryCode': adminUpdateOrganizerDetailsCallablePayloadFieldsCountryCode,
    'adminUpdateOrganizerDetailsCallablePayload.fields.countryName': adminUpdateOrganizerDetailsCallablePayloadFieldsCountryName,
    'adminUpdateOrganizerDetailsCallablePayload.fields.description': adminUpdateOrganizerDetailsCallablePayloadFieldsDescription,
    'adminUpdateOrganizerDetailsCallablePayload.fields.displayCategory': adminUpdateOrganizerDetailsCallablePayloadFieldsDisplayCategory,
    'adminUpdateOrganizerDetailsCallablePayload.fields.email': adminUpdateOrganizerDetailsCallablePayloadFieldsEmail,
    'adminUpdateOrganizerDetailsCallablePayload.fields.entityKind': adminUpdateOrganizerDetailsCallablePayloadFieldsEntityKind,
    'adminUpdateOrganizerDetailsCallablePayload.fields.imageUrl': adminUpdateOrganizerDetailsCallablePayloadFieldsImageUrl,
    'adminUpdateOrganizerDetailsCallablePayload.fields.instagramHandle': adminUpdateOrganizerDetailsCallablePayloadFieldsInstagramHandle,
    'adminUpdateOrganizerDetailsCallablePayload.fields.location': adminUpdateOrganizerDetailsCallablePayloadFieldsLocation,
    'adminUpdateOrganizerDetailsCallablePayload.fields.name': adminUpdateOrganizerDetailsCallablePayloadFieldsName,
    'adminUpdateOrganizerDetailsCallablePayload.fields.organizerType': adminUpdateOrganizerDetailsCallablePayloadFieldsOrganizerType,
    'adminUpdateOrganizerDetailsCallablePayload.fields.phoneNumber': adminUpdateOrganizerDetailsCallablePayloadFieldsPhoneNumber,
    'adminUpdateOrganizerDetailsCallablePayload.fields.profileImageUrl': adminUpdateOrganizerDetailsCallablePayloadFieldsProfileImageUrl,
    'adminUpdateOrganizerDetailsCallablePayload.fields.provenance.sourceConfidence': adminUpdateOrganizerDetailsCallablePayloadFieldsProvenanceSourceConfidence,
    'adminUpdateOrganizerDetailsCallablePayload.fields.provenance.verificationStatus': adminUpdateOrganizerDetailsCallablePayloadFieldsProvenanceVerificationStatus,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicCategoryLabel': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicCategoryLabel,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.canonicalPath': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageCanonicalPath,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.citySlug': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageCitySlug,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.publishStatus': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPagePublishStatus,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.seoDescription': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageSeoDescription,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.seoTitle': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageSeoTitle,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicPage.slug': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicPageSlug,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicProfile.headline': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicProfileHeadline,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicProfile.sourceSummary': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicProfileSourceSummary,
    'adminUpdateOrganizerDetailsCallablePayload.fields.publicProfile.summary': adminUpdateOrganizerDetailsCallablePayloadFieldsPublicProfileSummary,
    'adminUpdateOrganizerDetailsCallablePayload.fields.regionName': adminUpdateOrganizerDetailsCallablePayloadFieldsRegionName,
    'adminUpdateOrganizerDetailsCallablePayload.organizerId': adminUpdateOrganizerDetailsCallablePayloadOrganizerId,
    'adminUpdateOrganizerDetailsCallablePayload.reviewNote': adminUpdateOrganizerDetailsCallablePayloadReviewNote,
    'blockDocument.blockedUserId': blockDocumentBlockedUserId,
    'blockDocument.blockerUserId': blockDocumentBlockerUserId,
    'blockDocument.createdAt._nanoseconds': blockDocumentCreatedAtNanoseconds,
    'blockDocument.createdAt._seconds': blockDocumentCreatedAtSeconds,
    'blockDocument.reasonCode': blockDocumentReasonCode,
    'blockDocument.source': blockDocumentSource,
    'chatMessageDocument.demoOpsCommand': chatMessageDocumentDemoOpsCommand,
    'chatMessageDocument.demoOpsId': chatMessageDocumentDemoOpsId,
    'chatMessageDocument.imageUrl': chatMessageDocumentImageUrl,
    'chatMessageDocument.scenario': chatMessageDocumentScenario,
    'chatMessageDocument.seedPrefix': chatMessageDocumentSeedPrefix,
    'chatMessageDocument.senderId': chatMessageDocumentSenderId,
    'chatMessageDocument.sentAt._nanoseconds': chatMessageDocumentSentAtNanoseconds,
    'chatMessageDocument.sentAt._seconds': chatMessageDocumentSentAtSeconds,
    'chatMessageDocument.text': chatMessageDocumentText,
    'clubClaimRequestDocument.businessEmail': clubClaimRequestDocumentBusinessEmail,
    'clubClaimRequestDocument.businessPhone': clubClaimRequestDocumentBusinessPhone,
    'clubClaimRequestDocument.clubId': clubClaimRequestDocumentClubId,
    'clubClaimRequestDocument.createdAt._nanoseconds': clubClaimRequestDocumentCreatedAtNanoseconds,
    'clubClaimRequestDocument.createdAt._seconds': clubClaimRequestDocumentCreatedAtSeconds,
    'clubClaimRequestDocument.decidedAt._nanoseconds': clubClaimRequestDocumentDecidedAtNanoseconds,
    'clubClaimRequestDocument.decidedAt._seconds': clubClaimRequestDocumentDecidedAtSeconds,
    'clubClaimRequestDocument.decidedByUid': clubClaimRequestDocumentDecidedByUid,
    'clubClaimRequestDocument.decisionReason': clubClaimRequestDocumentDecisionReason,
    'clubClaimRequestDocument.message': clubClaimRequestDocumentMessage,
    'clubClaimRequestDocument.previousRequestId': clubClaimRequestDocumentPreviousRequestId,
    'clubClaimRequestDocument.proofUrls': clubClaimRequestDocumentProofUrls,
    'clubClaimRequestDocument.requesterName': clubClaimRequestDocumentRequesterName,
    'clubClaimRequestDocument.requesterRole': clubClaimRequestDocumentRequesterRole,
    'clubClaimRequestDocument.requesterUid': clubClaimRequestDocumentRequesterUid,
    'clubClaimRequestDocument.requestId': clubClaimRequestDocumentRequestId,
    'clubClaimRequestDocument.status': clubClaimRequestDocumentStatus,
    'clubClaimRequestDocument.updatedAt._nanoseconds': clubClaimRequestDocumentUpdatedAtNanoseconds,
    'clubClaimRequestDocument.updatedAt._seconds': clubClaimRequestDocumentUpdatedAtSeconds,
    'clubDocument.adminSearch.sortKey': clubDocumentAdminSearchSortKey,
    'clubDocument.adminSearch.tokens': clubDocumentAdminSearchTokens,
    'clubDocument.adminSearch.updatedAt._nanoseconds': clubDocumentAdminSearchUpdatedAtNanoseconds,
    'clubDocument.adminSearch.updatedAt._seconds': clubDocumentAdminSearchUpdatedAtSeconds,
    'clubDocument.adminSearch.updatedBySource': clubDocumentAdminSearchUpdatedBySource,
    'clubDocument.appVisibility': clubDocumentAppVisibility,
    'clubDocument.archived': clubDocumentArchived,
    'clubDocument.archivedAt._nanoseconds': clubDocumentArchivedAtNanoseconds,
    'clubDocument.archivedAt._seconds': clubDocumentArchivedAtSeconds,
    'clubDocument.archiveReason': clubDocumentArchiveReason,
    'clubDocument.area': clubDocumentArea,
    'clubDocument.cityName': clubDocumentCityName,
    'clubDocument.claim.claimHref': clubDocumentClaimClaimHref,
    'clubDocument.claim.lastClaimRequestId': clubDocumentClaimLastClaimRequestId,
    'clubDocument.claim.state': clubDocumentClaimState,
    'clubDocument.countryCode': clubDocumentCountryCode,
    'clubDocument.countryName': clubDocumentCountryName,
    'clubDocument.createdAt._nanoseconds': clubDocumentCreatedAtNanoseconds,
    'clubDocument.createdAt._seconds': clubDocumentCreatedAtSeconds,
    'clubDocument.demoOpsCommand': clubDocumentDemoOpsCommand,
    'clubDocument.demoOpsId': clubDocumentDemoOpsId,
    'clubDocument.description': clubDocumentDescription,
    'clubDocument.displayCategory': clubDocumentDisplayCategory,
    'clubDocument.email': clubDocumentEmail,
    'clubDocument.entityKind': clubDocumentEntityKind,
    'clubDocument.hostAvatarUrl': clubDocumentHostAvatarUrl,
    'clubDocument.hostDefaults.eventPolicy.admissionPreset': clubDocumentHostDefaultsEventPolicyAdmissionPreset,
    'clubDocument.hostDefaults.eventPolicy.cancellationPolicyId': clubDocumentHostDefaultsEventPolicyCancellationPolicyId,
    'clubDocument.hostDefaults.eventPolicy.dynamicPricingMaxInPaise': clubDocumentHostDefaultsEventPolicyDynamicPricingMaxInPaise,
    'clubDocument.hostDefaults.eventPolicy.dynamicPricingStepInPaise': clubDocumentHostDefaultsEventPolicyDynamicPricingStepInPaise,
    'clubDocument.hostDefaults.eventPolicy.maxAge': clubDocumentHostDefaultsEventPolicyMaxAge,
    'clubDocument.hostDefaults.eventPolicy.maxMen': clubDocumentHostDefaultsEventPolicyMaxMen,
    'clubDocument.hostDefaults.eventPolicy.maxWomen': clubDocumentHostDefaultsEventPolicyMaxWomen,
    'clubDocument.hostDefaults.eventPolicy.minAge': clubDocumentHostDefaultsEventPolicyMinAge,
    'clubDocument.hostDefaults.eventSuccess.attendeePrompt': clubDocumentHostDefaultsEventSuccessAttendeePrompt,
    'clubDocument.hostDefaults.eventSuccess.hostGoal': clubDocumentHostDefaultsEventSuccessHostGoal,
    'clubDocument.hostDefaults.eventSuccess.playbookId': clubDocumentHostDefaultsEventSuccessPlaybookId,
    'clubDocument.hostDefaults.eventSuccess.questionnaireConfig.customTitle': clubDocumentHostDefaultsEventSuccessQuestionnaireConfigCustomTitle,
    'clubDocument.hostDefaults.eventSuccess.questionnaireConfig.templateId': clubDocumentHostDefaultsEventSuccessQuestionnaireConfigTemplateId,
    'clubDocument.hostDefaults.eventSuccess.structureConfig.maxPairMeetings': clubDocumentHostDefaultsEventSuccessStructureConfigMaxPairMeetings,
    'clubDocument.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds': clubDocumentHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds,
    'clubDocument.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes': clubDocumentHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes,
    'clubDocument.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy': clubDocumentHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy,
    'clubDocument.hostDefaults.eventSuccess.structureConfig.unitCount': clubDocumentHostDefaultsEventSuccessStructureConfigUnitCount,
    'clubDocument.hostDefaults.eventSuccess.structureConfig.unitKind': clubDocumentHostDefaultsEventSuccessStructureConfigUnitKind,
    'clubDocument.hostDefaults.eventSuccess.structureConfig.unitSize': clubDocumentHostDefaultsEventSuccessStructureConfigUnitSize,
    'clubDocument.hostDefaults.primaryActivityKind': clubDocumentHostDefaultsPrimaryActivityKind,
    'clubDocument.hostName': clubDocumentHostName,
    'clubDocument.hostProfiles': clubDocumentHostProfiles,
    'clubDocument.hostUserId': clubDocumentHostUserId,
    'clubDocument.hostUserIds': clubDocumentHostUserIds,
    'clubDocument.imageUrl': clubDocumentImageUrl,
    'clubDocument.instagramHandle': clubDocumentInstagramHandle,
    'clubDocument.location': clubDocumentLocation,
    'clubDocument.locationCityId': clubDocumentLocationCityId,
    'clubDocument.locationMarketId': clubDocumentLocationMarketId,
    'clubDocument.logoPhoto.createdAt._nanoseconds': clubDocumentLogoPhotoCreatedAtNanoseconds,
    'clubDocument.logoPhoto.createdAt._seconds': clubDocumentLogoPhotoCreatedAtSeconds,
    'clubDocument.logoPhoto.id': clubDocumentLogoPhotoId,
    'clubDocument.logoPhoto.moderation.reason': clubDocumentLogoPhotoModerationReason,
    'clubDocument.logoPhoto.moderation.reviewedAt._nanoseconds': clubDocumentLogoPhotoModerationReviewedAtNanoseconds,
    'clubDocument.logoPhoto.moderation.reviewedAt._seconds': clubDocumentLogoPhotoModerationReviewedAtSeconds,
    'clubDocument.logoPhoto.moderation.status': clubDocumentLogoPhotoModerationStatus,
    'clubDocument.logoPhoto.position': clubDocumentLogoPhotoPosition,
    'clubDocument.logoPhoto.storagePath': clubDocumentLogoPhotoStoragePath,
    'clubDocument.logoPhoto.thumbnailStoragePath': clubDocumentLogoPhotoThumbnailStoragePath,
    'clubDocument.logoPhoto.thumbnailUrl': clubDocumentLogoPhotoThumbnailUrl,
    'clubDocument.logoPhoto.updatedAt._nanoseconds': clubDocumentLogoPhotoUpdatedAtNanoseconds,
    'clubDocument.logoPhoto.updatedAt._seconds': clubDocumentLogoPhotoUpdatedAtSeconds,
    'clubDocument.logoPhoto.url': clubDocumentLogoPhotoUrl,
    'clubDocument.memberCount': clubDocumentMemberCount,
    'clubDocument.name': clubDocumentName,
    'clubDocument.nextEventAt._nanoseconds': clubDocumentNextEventAtNanoseconds,
    'clubDocument.nextEventAt._seconds': clubDocumentNextEventAtSeconds,
    'clubDocument.nextEventLabel': clubDocumentNextEventLabel,
    'clubDocument.organizerType': clubDocumentOrganizerType,
    'clubDocument.organizerTypeUpdatedAt._nanoseconds': clubDocumentOrganizerTypeUpdatedAtNanoseconds,
    'clubDocument.organizerTypeUpdatedAt._seconds': clubDocumentOrganizerTypeUpdatedAtSeconds,
    'clubDocument.organizerTypeUpdatedByUid': clubDocumentOrganizerTypeUpdatedByUid,
    'clubDocument.ownership.claimedAt._nanoseconds': clubDocumentOwnershipClaimedAtNanoseconds,
    'clubDocument.ownership.claimedAt._seconds': clubDocumentOwnershipClaimedAtSeconds,
    'clubDocument.ownership.claimedByUid': clubDocumentOwnershipClaimedByUid,
    'clubDocument.ownership.hostUserIds': clubDocumentOwnershipHostUserIds,
    'clubDocument.ownership.ownerUserId': clubDocumentOwnershipOwnerUserId,
    'clubDocument.ownership.primaryHostUserId': clubDocumentOwnershipPrimaryHostUserId,
    'clubDocument.ownership.state': clubDocumentOwnershipState,
    'clubDocument.ownerUserId': clubDocumentOwnerUserId,
    'clubDocument.phoneNumber': clubDocumentPhoneNumber,
    'clubDocument.profileImageUrl': clubDocumentProfileImageUrl,
    'clubDocument.provenance.lastVerifiedAt._nanoseconds': clubDocumentProvenanceLastVerifiedAtNanoseconds,
    'clubDocument.provenance.lastVerifiedAt._seconds': clubDocumentProvenanceLastVerifiedAtSeconds,
    'clubDocument.provenance.origin': clubDocumentProvenanceOrigin,
    'clubDocument.provenance.sourceConfidence': clubDocumentProvenanceSourceConfidence,
    'clubDocument.provenance.verificationStatus': clubDocumentProvenanceVerificationStatus,
    'clubDocument.publicCategoryLabel': clubDocumentPublicCategoryLabel,
    'clubDocument.publicPage.canonicalPath': clubDocumentPublicPageCanonicalPath,
    'clubDocument.publicPage.citySlug': clubDocumentPublicPageCitySlug,
    'clubDocument.publicPage.indexReview.checklist.cadenceVerified': clubDocumentPublicPageIndexReviewChecklistCadenceVerified,
    'clubDocument.publicPage.indexReview.checklist.mediaRightsVerified': clubDocumentPublicPageIndexReviewChecklistMediaRightsVerified,
    'clubDocument.publicPage.indexReview.checklist.ownerContactVerified': clubDocumentPublicPageIndexReviewChecklistOwnerContactVerified,
    'clubDocument.publicPage.indexReview.checklist.sourceEvidenceVerified': clubDocumentPublicPageIndexReviewChecklistSourceEvidenceVerified,
    'clubDocument.publicPage.indexReview.indexStatus': clubDocumentPublicPageIndexReviewIndexStatus,
    'clubDocument.publicPage.indexReview.reviewedAt._nanoseconds': clubDocumentPublicPageIndexReviewReviewedAtNanoseconds,
    'clubDocument.publicPage.indexReview.reviewedAt._seconds': clubDocumentPublicPageIndexReviewReviewedAtSeconds,
    'clubDocument.publicPage.indexReview.reviewedByUid': clubDocumentPublicPageIndexReviewReviewedByUid,
    'clubDocument.publicPage.indexReview.reviewNote': clubDocumentPublicPageIndexReviewReviewNote,
    'clubDocument.publicPage.indexStatus': clubDocumentPublicPageIndexStatus,
    'clubDocument.publicPage.lastRenderedAt._nanoseconds': clubDocumentPublicPageLastRenderedAtNanoseconds,
    'clubDocument.publicPage.lastRenderedAt._seconds': clubDocumentPublicPageLastRenderedAtSeconds,
    'clubDocument.publicPage.publishStatus': clubDocumentPublicPagePublishStatus,
    'clubDocument.publicPage.robots': clubDocumentPublicPageRobots,
    'clubDocument.publicPage.seoDescription': clubDocumentPublicPageSeoDescription,
    'clubDocument.publicPage.seoTitle': clubDocumentPublicPageSeoTitle,
    'clubDocument.publicPage.slug': clubDocumentPublicPageSlug,
    'clubDocument.publicProfile.headline': clubDocumentPublicProfileHeadline,
    'clubDocument.publicProfile.sourceSummary': clubDocumentPublicProfileSourceSummary,
    'clubDocument.publicProfile.summary': clubDocumentPublicProfileSummary,
    'clubDocument.rating': clubDocumentRating,
    'clubDocument.regionName': clubDocumentRegionName,
    'clubDocument.reviewCount': clubDocumentReviewCount,
    'clubDocument.scenario': clubDocumentScenario,
    'clubDocument.seedPrefix': clubDocumentSeedPrefix,
    'clubDocument.status': clubDocumentStatus,
    'clubDocument.tags': clubDocumentTags,
    'clubDocument.verifiedReviewCount': clubDocumentVerifiedReviewCount,
    'clubHostClaimDocument.clubId': clubHostClaimDocumentClubId,
    'clubHostClaimDocument.createdAt._nanoseconds': clubHostClaimDocumentCreatedAtNanoseconds,
    'clubHostClaimDocument.createdAt._seconds': clubHostClaimDocumentCreatedAtSeconds,
    'clubHostClaimDocument.uid': clubHostClaimDocumentUid,
    'clubMembershipDocument.clubId': clubMembershipDocumentClubId,
    'clubMembershipDocument.deletedAt._nanoseconds': clubMembershipDocumentDeletedAtNanoseconds,
    'clubMembershipDocument.deletedAt._seconds': clubMembershipDocumentDeletedAtSeconds,
    'clubMembershipDocument.demoOpsCommand': clubMembershipDocumentDemoOpsCommand,
    'clubMembershipDocument.demoOpsId': clubMembershipDocumentDemoOpsId,
    'clubMembershipDocument.joinedAt._nanoseconds': clubMembershipDocumentJoinedAtNanoseconds,
    'clubMembershipDocument.joinedAt._seconds': clubMembershipDocumentJoinedAtSeconds,
    'clubMembershipDocument.leftAt._nanoseconds': clubMembershipDocumentLeftAtNanoseconds,
    'clubMembershipDocument.leftAt._seconds': clubMembershipDocumentLeftAtSeconds,
    'clubMembershipDocument.pushNotificationsEnabled': clubMembershipDocumentPushNotificationsEnabled,
    'clubMembershipDocument.role': clubMembershipDocumentRole,
    'clubMembershipDocument.scenario': clubMembershipDocumentScenario,
    'clubMembershipDocument.seedPrefix': clubMembershipDocumentSeedPrefix,
    'clubMembershipDocument.status': clubMembershipDocumentStatus,
    'clubMembershipDocument.uid': clubMembershipDocumentUid,
    'clubPostDocument.audience': clubPostDocumentAudience,
    'clubPostDocument.authorUid': clubPostDocumentAuthorUid,
    'clubPostDocument.createdAt._nanoseconds': clubPostDocumentCreatedAtNanoseconds,
    'clubPostDocument.createdAt._seconds': clubPostDocumentCreatedAtSeconds,
    'clubPostDocument.eventId': clubPostDocumentEventId,
    'clubPostDocument.photoPath': clubPostDocumentPhotoPath,
    'clubPostDocument.status': clubPostDocumentStatus,
    'clubPostDocument.text': clubPostDocumentText,
    'clubScheduleLockDocument.clubId': clubScheduleLockDocumentClubId,
    'clubScheduleLockDocument.demoOpsCommand': clubScheduleLockDocumentDemoOpsCommand,
    'clubScheduleLockDocument.demoOpsId': clubScheduleLockDocumentDemoOpsId,
    'clubScheduleLockDocument.endTimeMillis': clubScheduleLockDocumentEndTimeMillis,
    'clubScheduleLockDocument.eventId': clubScheduleLockDocumentEventId,
    'clubScheduleLockDocument.ownerId': clubScheduleLockDocumentOwnerId,
    'clubScheduleLockDocument.ownerType': clubScheduleLockDocumentOwnerType,
    'clubScheduleLockDocument.scenario': clubScheduleLockDocumentScenario,
    'clubScheduleLockDocument.seedPrefix': clubScheduleLockDocumentSeedPrefix,
    'clubScheduleLockDocument.slot': clubScheduleLockDocumentSlot,
    'clubScheduleLockDocument.startTimeMillis': clubScheduleLockDocumentStartTimeMillis,
    'configCitiesDocument.cities': configCitiesDocumentCities,
    'configCitiesDocument.cityNames': configCitiesDocumentCityNames,
    'configCitiesDocument.launchMarketIds': configCitiesDocumentLaunchMarketIds,
    'configCitiesDocument.marketIds': configCitiesDocumentMarketIds,
    'configCitiesDocument.markets': configCitiesDocumentMarkets,
    'configCitiesDocument.version': configCitiesDocumentVersion,
    'deletedUserTombstoneDocument.completedAt._nanoseconds': deletedUserTombstoneDocumentCompletedAtNanoseconds,
    'deletedUserTombstoneDocument.completedAt._seconds': deletedUserTombstoneDocumentCompletedAtSeconds,
    'deletedUserTombstoneDocument.deletedAt._nanoseconds': deletedUserTombstoneDocumentDeletedAtNanoseconds,
    'deletedUserTombstoneDocument.deletedAt._seconds': deletedUserTombstoneDocumentDeletedAtSeconds,
    'deletedUserTombstoneDocument.status': deletedUserTombstoneDocumentStatus,
    'deletedUserTombstoneDocument.uid': deletedUserTombstoneDocumentUid,
    'deletedUserTombstoneDocument.updatedAt._nanoseconds': deletedUserTombstoneDocumentUpdatedAtNanoseconds,
    'deletedUserTombstoneDocument.updatedAt._seconds': deletedUserTombstoneDocumentUpdatedAtSeconds,
    'eventBroadcastDocument.activityAvailableCount': eventBroadcastDocumentActivityAvailableCount,
    'eventBroadcastDocument.actorUid': eventBroadcastDocumentActorUid,
    'eventBroadcastDocument.audience': eventBroadcastDocumentAudience,
    'eventBroadcastDocument.body': eventBroadcastDocumentBody,
    'eventBroadcastDocument.clubId': eventBroadcastDocumentClubId,
    'eventBroadcastDocument.completedAt._nanoseconds': eventBroadcastDocumentCompletedAtNanoseconds,
    'eventBroadcastDocument.completedAt._seconds': eventBroadcastDocumentCompletedAtSeconds,
    'eventBroadcastDocument.createdAt._nanoseconds': eventBroadcastDocumentCreatedAtNanoseconds,
    'eventBroadcastDocument.createdAt._seconds': eventBroadcastDocumentCreatedAtSeconds,
    'eventBroadcastDocument.deliveries': eventBroadcastDocumentDeliveries,
    'eventBroadcastDocument.eventId': eventBroadcastDocumentEventId,
    'eventBroadcastDocument.excludedCount': eventBroadcastDocumentExcludedCount,
    'eventBroadcastDocument.expiresAt._nanoseconds': eventBroadcastDocumentExpiresAtNanoseconds,
    'eventBroadcastDocument.expiresAt._seconds': eventBroadcastDocumentExpiresAtSeconds,
    'eventBroadcastDocument.leaseExpiresAt._nanoseconds': eventBroadcastDocumentLeaseExpiresAtNanoseconds,
    'eventBroadcastDocument.leaseExpiresAt._seconds': eventBroadcastDocumentLeaseExpiresAtSeconds,
    'eventBroadcastDocument.leaseOwner': eventBroadcastDocumentLeaseOwner,
    'eventBroadcastDocument.organizerId': eventBroadcastDocumentOrganizerId,
    'eventBroadcastDocument.pushAcceptedCount': eventBroadcastDocumentPushAcceptedCount,
    'eventBroadcastDocument.pushAttemptedCount': eventBroadcastDocumentPushAttemptedCount,
    'eventBroadcastDocument.pushErrorCodes': eventBroadcastDocumentPushErrorCodes,
    'eventBroadcastDocument.pushFailedCount': eventBroadcastDocumentPushFailedCount,
    'eventBroadcastDocument.pushUnknownCount': eventBroadcastDocumentPushUnknownCount,
    'eventBroadcastDocument.recipientCount': eventBroadcastDocumentRecipientCount,
    'eventBroadcastDocument.status': eventBroadcastDocumentStatus,
    'eventBroadcastDocument.targetUids': eventBroadcastDocumentTargetUids,
    'eventBroadcastDocument.title': eventBroadcastDocumentTitle,
    'eventBroadcastDocument.updatedAt._nanoseconds': eventBroadcastDocumentUpdatedAtNanoseconds,
    'eventBroadcastDocument.updatedAt._seconds': eventBroadcastDocumentUpdatedAtSeconds,
    'eventDocument.adminSearch.sortKey': eventDocumentAdminSearchSortKey,
    'eventDocument.adminSearch.tokens': eventDocumentAdminSearchTokens,
    'eventDocument.adminSearch.updatedAt._nanoseconds': eventDocumentAdminSearchUpdatedAtNanoseconds,
    'eventDocument.adminSearch.updatedAt._seconds': eventDocumentAdminSearchUpdatedAtSeconds,
    'eventDocument.adminSearch.updatedBySource': eventDocumentAdminSearchUpdatedBySource,
    'eventDocument.bookedCount': eventDocumentBookedCount,
    'eventDocument.cancellationReason': eventDocumentCancellationReason,
    'eventDocument.cancelledAt._nanoseconds': eventDocumentCancelledAtNanoseconds,
    'eventDocument.cancelledAt._seconds': eventDocumentCancelledAtSeconds,
    'eventDocument.capacityLimit': eventDocumentCapacityLimit,
    'eventDocument.checkedInCount': eventDocumentCheckedInCount,
    'eventDocument.clubId': eventDocumentClubId,
    'eventDocument.cohortCounts': eventDocumentCohortCounts,
    'eventDocument.constraints.maxAge': eventDocumentConstraintsMaxAge,
    'eventDocument.constraints.maxMen': eventDocumentConstraintsMaxMen,
    'eventDocument.constraints.maxWomen': eventDocumentConstraintsMaxWomen,
    'eventDocument.constraints.minAge': eventDocumentConstraintsMinAge,
    'eventDocument.currency': eventDocumentCurrency,
    'eventDocument.demoOpsCommand': eventDocumentDemoOpsCommand,
    'eventDocument.demoOpsId': eventDocumentDemoOpsId,
    'eventDocument.description': eventDocumentDescription,
    'eventDocument.discoveryActivityKind': eventDocumentDiscoveryActivityKind,
    'eventDocument.discoveryAvailability': eventDocumentDiscoveryAvailability,
    'eventDocument.discoveryCityName': eventDocumentDiscoveryCityName,
    'eventDocument.discoveryGeoCell': eventDocumentDiscoveryGeoCell,
    'eventDocument.discoveryHasOpenSpots': eventDocumentDiscoveryHasOpenSpots,
    'eventDocument.discoveryInviteRequired': eventDocumentDiscoveryInviteRequired,
    'eventDocument.discoveryManualApprovalRequired': eventDocumentDiscoveryManualApprovalRequired,
    'eventDocument.discoveryMarketId': eventDocumentDiscoveryMarketId,
    'eventDocument.discoveryMaxAge': eventDocumentDiscoveryMaxAge,
    'eventDocument.discoveryMembershipRequired': eventDocumentDiscoveryMembershipRequired,
    'eventDocument.discoveryMinAge': eventDocumentDiscoveryMinAge,
    'eventDocument.discoveryOpenCohorts': eventDocumentDiscoveryOpenCohorts,
    'eventDocument.discoveryWaitlistCohorts': eventDocumentDiscoveryWaitlistCohorts,
    'eventDocument.distanceKm': eventDocumentDistanceKm,
    'eventDocument.endTime._nanoseconds': eventDocumentEndTimeNanoseconds,
    'eventDocument.endTime._seconds': eventDocumentEndTimeSeconds,
    'eventDocument.eventFormat.activityKind': eventDocumentEventFormatActivityKind,
    'eventDocument.eventFormat.customActivityLabel': eventDocumentEventFormatCustomActivityLabel,
    'eventDocument.eventFormat.defaultPlaybookId': eventDocumentEventFormatDefaultPlaybookId,
    'eventDocument.eventFormat.eventSuccessPrimitives.assignmentAlgorithm': eventDocumentEventFormatEventSuccessPrimitivesAssignmentAlgorithm,
    'eventDocument.eventFormat.eventSuccessPrimitives.compatibilityPolicy': eventDocumentEventFormatEventSuccessPrimitivesCompatibilityPolicy,
    'eventDocument.eventFormat.eventSuccessPrimitives.phoneAvailability': eventDocumentEventFormatEventSuccessPrimitivesPhoneAvailability,
    'eventDocument.eventFormat.eventSuccessPrimitives.rotationSuitability': eventDocumentEventFormatEventSuccessPrimitivesRotationSuitability,
    'eventDocument.eventFormat.interactionModel': eventDocumentEventFormatInteractionModel,
    'eventDocument.eventFormat.version': eventDocumentEventFormatVersion,
    'eventDocument.eventPolicy.admission.balancedRatioPolicy.leftCohortId': eventDocumentEventPolicyAdmissionBalancedRatioPolicyLeftCohortId,
    'eventDocument.eventPolicy.admission.balancedRatioPolicy.maxSkew': eventDocumentEventPolicyAdmissionBalancedRatioPolicyMaxSkew,
    'eventDocument.eventPolicy.admission.balancedRatioPolicy.openingBufferPerCohort': eventDocumentEventPolicyAdmissionBalancedRatioPolicyOpeningBufferPerCohort,
    'eventDocument.eventPolicy.admission.balancedRatioPolicy.outOfRatioCohortPolicy': eventDocumentEventPolicyAdmissionBalancedRatioPolicyOutOfRatioCohortPolicy,
    'eventDocument.eventPolicy.admission.balancedRatioPolicy.rightCohortId': eventDocumentEventPolicyAdmissionBalancedRatioPolicyRightCohortId,
    'eventDocument.eventPolicy.admission.capacityLimit': eventDocumentEventPolicyAdmissionCapacityLimit,
    'eventDocument.eventPolicy.admission.cohortCapacityLimits': eventDocumentEventPolicyAdmissionCohortCapacityLimits,
    'eventDocument.eventPolicy.admission.format': eventDocumentEventPolicyAdmissionFormat,
    'eventDocument.eventPolicy.admission.inviteRequired': eventDocumentEventPolicyAdmissionInviteRequired,
    'eventDocument.eventPolicy.admission.manualApprovalRequired': eventDocumentEventPolicyAdmissionManualApprovalRequired,
    'eventDocument.eventPolicy.admission.membershipRequired': eventDocumentEventPolicyAdmissionMembershipRequired,
    'eventDocument.eventPolicy.admission.privateAccessPolicy.inviteCodeHint': eventDocumentEventPolicyAdmissionPrivateAccessPolicyInviteCodeHint,
    'eventDocument.eventPolicy.admission.privateAccessPolicy.mode': eventDocumentEventPolicyAdmissionPrivateAccessPolicyMode,
    'eventDocument.eventPolicy.admission.privateAccessPolicy.privateLinkEnabled': eventDocumentEventPolicyAdmissionPrivateAccessPolicyPrivateLinkEnabled,
    'eventDocument.eventPolicy.admission.waitlistPolicy.mode': eventDocumentEventPolicyAdmissionWaitlistPolicyMode,
    'eventDocument.eventPolicy.admission.waitlistPolicy.offerWindowMinutes': eventDocumentEventPolicyAdmissionWaitlistPolicyOfferWindowMinutes,
    'eventDocument.eventPolicy.cancellation.policyId': eventDocumentEventPolicyCancellationPolicyId,
    'eventDocument.eventPolicy.pricing.basePriceInPaise': eventDocumentEventPolicyPricingBasePriceInPaise,
    'eventDocument.eventPolicy.pricing.cohortAdjustmentsInPaise': eventDocumentEventPolicyPricingCohortAdjustmentsInPaise,
    'eventDocument.eventPolicy.pricing.demandPricingRules': eventDocumentEventPolicyPricingDemandPricingRules,
    'eventDocument.eventPolicy.settlement.hostPayoutTiming': eventDocumentEventPolicySettlementHostPayoutTiming,
    'eventDocument.eventPolicy.version': eventDocumentEventPolicyVersion,
    'eventDocument.genderCounts': eventDocumentGenderCounts,
    'eventDocument.locationDetails': eventDocumentLocationDetails,
    'eventDocument.meetingLocation.address': eventDocumentMeetingLocationAddress,
    'eventDocument.meetingLocation.latitude': eventDocumentMeetingLocationLatitude,
    'eventDocument.meetingLocation.longitude': eventDocumentMeetingLocationLongitude,
    'eventDocument.meetingLocation.name': eventDocumentMeetingLocationName,
    'eventDocument.meetingLocation.notes': eventDocumentMeetingLocationNotes,
    'eventDocument.meetingLocation.placeId': eventDocumentMeetingLocationPlaceId,
    'eventDocument.meetingPoint': eventDocumentMeetingPoint,
    'eventDocument.organizerId': eventDocumentOrganizerId,
    'eventDocument.pace': eventDocumentPace,
    'eventDocument.photoUrl': eventDocumentPhotoUrl,
    'eventDocument.priceInPaise': eventDocumentPriceInPaise,
    'eventDocument.scenario': eventDocumentScenario,
    'eventDocument.seedPrefix': eventDocumentSeedPrefix,
    'eventDocument.startingPointLat': eventDocumentStartingPointLat,
    'eventDocument.startingPointLng': eventDocumentStartingPointLng,
    'eventDocument.startTime._nanoseconds': eventDocumentStartTimeNanoseconds,
    'eventDocument.startTime._seconds': eventDocumentStartTimeSeconds,
    'eventDocument.status': eventDocumentStatus,
    'eventDocument.waitlistedCohortCounts': eventDocumentWaitlistedCohortCounts,
    'eventDocument.waitlistedCount': eventDocumentWaitlistedCount,
    'eventIntakeReviewDecisionDocument.checklist.copyReviewed': eventIntakeReviewDecisionDocumentChecklistCopyReviewed,
    'eventIntakeReviewDecisionDocument.checklist.dateReviewed': eventIntakeReviewDecisionDocumentChecklistDateReviewed,
    'eventIntakeReviewDecisionDocument.checklist.noCatchHostingImplied': eventIntakeReviewDecisionDocumentChecklistNoCatchHostingImplied,
    'eventIntakeReviewDecisionDocument.checklist.rightsReviewed': eventIntakeReviewDecisionDocumentChecklistRightsReviewed,
    'eventIntakeReviewDecisionDocument.checklist.sourceReviewed': eventIntakeReviewDecisionDocumentChecklistSourceReviewed,
    'eventIntakeReviewDecisionDocument.checklist.venueReviewed': eventIntakeReviewDecisionDocumentChecklistVenueReviewed,
    'eventIntakeReviewDecisionDocument.decision': eventIntakeReviewDecisionDocumentDecision,
    'eventIntakeReviewDecisionDocument.decisionId': eventIntakeReviewDecisionDocumentDecisionId,
    'eventIntakeReviewDecisionDocument.decisionStatus': eventIntakeReviewDecisionDocumentDecisionStatus,
    'eventIntakeReviewDecisionDocument.edits': eventIntakeReviewDecisionDocumentEdits,
    'eventIntakeReviewDecisionDocument.effect': eventIntakeReviewDecisionDocumentEffect,
    'eventIntakeReviewDecisionDocument.note': eventIntakeReviewDecisionDocumentNote,
    'eventIntakeReviewDecisionDocument.reviewedAt._nanoseconds': eventIntakeReviewDecisionDocumentReviewedAtNanoseconds,
    'eventIntakeReviewDecisionDocument.reviewedAt._seconds': eventIntakeReviewDecisionDocumentReviewedAtSeconds,
    'eventIntakeReviewDecisionDocument.reviewedByUid': eventIntakeReviewDecisionDocumentReviewedByUid,
    'eventIntakeReviewDecisionDocument.runId': eventIntakeReviewDecisionDocumentRunId,
    'eventIntakeReviewDecisionDocument.schemaVersion': eventIntakeReviewDecisionDocumentSchemaVersion,
    'eventIntakeReviewDecisionDocument.targetId': eventIntakeReviewDecisionDocumentTargetId,
    'eventIntakeReviewDecisionDocument.targetType': eventIntakeReviewDecisionDocumentTargetType,
    'eventIntakeReviewDecisionDocument.updatedAt._nanoseconds': eventIntakeReviewDecisionDocumentUpdatedAtNanoseconds,
    'eventIntakeReviewDecisionDocument.updatedAt._seconds': eventIntakeReviewDecisionDocumentUpdatedAtSeconds,
    'eventInviteLinkDocument.catcherCount': eventInviteLinkDocumentCatcherCount,
    'eventInviteLinkDocument.chatStartedCount': eventInviteLinkDocumentChatStartedCount,
    'eventInviteLinkDocument.checkedInCount': eventInviteLinkDocumentCheckedInCount,
    'eventInviteLinkDocument.clubId': eventInviteLinkDocumentClubId,
    'eventInviteLinkDocument.confirmedCount': eventInviteLinkDocumentConfirmedCount,
    'eventInviteLinkDocument.createdAt._nanoseconds': eventInviteLinkDocumentCreatedAtNanoseconds,
    'eventInviteLinkDocument.createdAt._seconds': eventInviteLinkDocumentCreatedAtSeconds,
    'eventInviteLinkDocument.disabledAt._nanoseconds': eventInviteLinkDocumentDisabledAtNanoseconds,
    'eventInviteLinkDocument.disabledAt._seconds': eventInviteLinkDocumentDisabledAtSeconds,
    'eventInviteLinkDocument.eventId': eventInviteLinkDocumentEventId,
    'eventInviteLinkDocument.hostUid': eventInviteLinkDocumentHostUid,
    'eventInviteLinkDocument.label': eventInviteLinkDocumentLabel,
    'eventInviteLinkDocument.matchCount': eventInviteLinkDocumentMatchCount,
    'eventInviteLinkDocument.openCount': eventInviteLinkDocumentOpenCount,
    'eventInviteLinkDocument.organizerId': eventInviteLinkDocumentOrganizerId,
    'eventInviteLinkDocument.paidCount': eventInviteLinkDocumentPaidCount,
    'eventInviteLinkDocument.requestCount': eventInviteLinkDocumentRequestCount,
    'eventInviteLinkDocument.source': eventInviteLinkDocumentSource,
    'eventInviteLinkDocument.tokenHash': eventInviteLinkDocumentTokenHash,
    'eventInviteLinkDocument.updatedAt._nanoseconds': eventInviteLinkDocumentUpdatedAtNanoseconds,
    'eventInviteLinkDocument.updatedAt._seconds': eventInviteLinkDocumentUpdatedAtSeconds,
    'eventParticipationDocument.attendedAt._nanoseconds': eventParticipationDocumentAttendedAtNanoseconds,
    'eventParticipationDocument.attendedAt._seconds': eventParticipationDocumentAttendedAtSeconds,
    'eventParticipationDocument.cancelledAt._nanoseconds': eventParticipationDocumentCancelledAtNanoseconds,
    'eventParticipationDocument.cancelledAt._seconds': eventParticipationDocumentCancelledAtSeconds,
    'eventParticipationDocument.clubId': eventParticipationDocumentClubId,
    'eventParticipationDocument.cohortAtSignup': eventParticipationDocumentCohortAtSignup,
    'eventParticipationDocument.createdAt._nanoseconds': eventParticipationDocumentCreatedAtNanoseconds,
    'eventParticipationDocument.createdAt._seconds': eventParticipationDocumentCreatedAtSeconds,
    'eventParticipationDocument.deletedAt._nanoseconds': eventParticipationDocumentDeletedAtNanoseconds,
    'eventParticipationDocument.deletedAt._seconds': eventParticipationDocumentDeletedAtSeconds,
    'eventParticipationDocument.demoOpsCommand': eventParticipationDocumentDemoOpsCommand,
    'eventParticipationDocument.demoOpsId': eventParticipationDocumentDemoOpsId,
    'eventParticipationDocument.eventId': eventParticipationDocumentEventId,
    'eventParticipationDocument.genderAtSignup': eventParticipationDocumentGenderAtSignup,
    'eventParticipationDocument.hostApprovalDecidedAt._nanoseconds': eventParticipationDocumentHostApprovalDecidedAtNanoseconds,
    'eventParticipationDocument.hostApprovalDecidedAt._seconds': eventParticipationDocumentHostApprovalDecidedAtSeconds,
    'eventParticipationDocument.hostApprovalDecidedBy': eventParticipationDocumentHostApprovalDecidedBy,
    'eventParticipationDocument.hostApprovalStatus': eventParticipationDocumentHostApprovalStatus,
    'eventParticipationDocument.inviteCapturedAt._nanoseconds': eventParticipationDocumentInviteCapturedAtNanoseconds,
    'eventParticipationDocument.inviteCapturedAt._seconds': eventParticipationDocumentInviteCapturedAtSeconds,
    'eventParticipationDocument.inviteLinkId': eventParticipationDocumentInviteLinkId,
    'eventParticipationDocument.inviteSource': eventParticipationDocumentInviteSource,
    'eventParticipationDocument.organizerId': eventParticipationDocumentOrganizerId,
    'eventParticipationDocument.paymentId': eventParticipationDocumentPaymentId,
    'eventParticipationDocument.scenario': eventParticipationDocumentScenario,
    'eventParticipationDocument.seedPrefix': eventParticipationDocumentSeedPrefix,
    'eventParticipationDocument.signedUpAt._nanoseconds': eventParticipationDocumentSignedUpAtNanoseconds,
    'eventParticipationDocument.signedUpAt._seconds': eventParticipationDocumentSignedUpAtSeconds,
    'eventParticipationDocument.status': eventParticipationDocumentStatus,
    'eventParticipationDocument.uid': eventParticipationDocumentUid,
    'eventParticipationDocument.updatedAt._nanoseconds': eventParticipationDocumentUpdatedAtNanoseconds,
    'eventParticipationDocument.updatedAt._seconds': eventParticipationDocumentUpdatedAtSeconds,
    'eventParticipationDocument.waitlistedAt._nanoseconds': eventParticipationDocumentWaitlistedAtNanoseconds,
    'eventParticipationDocument.waitlistedAt._seconds': eventParticipationDocumentWaitlistedAtSeconds,
    'eventParticipationDocument.waitlistOfferAcceptedAt._nanoseconds': eventParticipationDocumentWaitlistOfferAcceptedAtNanoseconds,
    'eventParticipationDocument.waitlistOfferAcceptedAt._seconds': eventParticipationDocumentWaitlistOfferAcceptedAtSeconds,
    'eventParticipationDocument.waitlistOfferedAt._nanoseconds': eventParticipationDocumentWaitlistOfferedAtNanoseconds,
    'eventParticipationDocument.waitlistOfferedAt._seconds': eventParticipationDocumentWaitlistOfferedAtSeconds,
    'eventParticipationDocument.waitlistOfferExpiresAt._nanoseconds': eventParticipationDocumentWaitlistOfferExpiresAtNanoseconds,
    'eventParticipationDocument.waitlistOfferExpiresAt._seconds': eventParticipationDocumentWaitlistOfferExpiresAtSeconds,
    'eventParticipationDocument.waitlistOfferId': eventParticipationDocumentWaitlistOfferId,
    'eventParticipationDocument.waitlistOfferStatus': eventParticipationDocumentWaitlistOfferStatus,
    'eventPrivateAccessDocument.clubId': eventPrivateAccessDocumentClubId,
    'eventPrivateAccessDocument.createdAt._nanoseconds': eventPrivateAccessDocumentCreatedAtNanoseconds,
    'eventPrivateAccessDocument.createdAt._seconds': eventPrivateAccessDocumentCreatedAtSeconds,
    'eventPrivateAccessDocument.eventId': eventPrivateAccessDocumentEventId,
    'eventPrivateAccessDocument.inviteCode': eventPrivateAccessDocumentInviteCode,
    'eventPrivateAccessDocument.organizerId': eventPrivateAccessDocumentOrganizerId,
    'eventSafetyReportDocument.clubId': eventSafetyReportDocumentClubId,
    'eventSafetyReportDocument.createdAt._nanoseconds': eventSafetyReportDocumentCreatedAtNanoseconds,
    'eventSafetyReportDocument.createdAt._seconds': eventSafetyReportDocumentCreatedAtSeconds,
    'eventSafetyReportDocument.eventId': eventSafetyReportDocumentEventId,
    'eventSafetyReportDocument.feedbackId': eventSafetyReportDocumentFeedbackId,
    'eventSafetyReportDocument.note': eventSafetyReportDocumentNote,
    'eventSafetyReportDocument.organizerId': eventSafetyReportDocumentOrganizerId,
    'eventSafetyReportDocument.reporterUserId': eventSafetyReportDocumentReporterUserId,
    'eventSafetyReportDocument.source': eventSafetyReportDocumentSource,
    'eventSafetyReportDocument.status': eventSafetyReportDocumentStatus,
    'eventSafetyReportDocument.updatedAt._nanoseconds': eventSafetyReportDocumentUpdatedAtNanoseconds,
    'eventSafetyReportDocument.updatedAt._seconds': eventSafetyReportDocumentUpdatedAtSeconds,
    'eventSuccessArrivalMissionDocument.answerOptions': eventSuccessArrivalMissionDocumentAnswerOptions,
    'eventSuccessArrivalMissionDocument.clubId': eventSuccessArrivalMissionDocumentClubId,
    'eventSuccessArrivalMissionDocument.completedAt._nanoseconds': eventSuccessArrivalMissionDocumentCompletedAtNanoseconds,
    'eventSuccessArrivalMissionDocument.completedAt._seconds': eventSuccessArrivalMissionDocumentCompletedAtSeconds,
    'eventSuccessArrivalMissionDocument.createdAt._nanoseconds': eventSuccessArrivalMissionDocumentCreatedAtNanoseconds,
    'eventSuccessArrivalMissionDocument.createdAt._seconds': eventSuccessArrivalMissionDocumentCreatedAtSeconds,
    'eventSuccessArrivalMissionDocument.demoOpsCommand': eventSuccessArrivalMissionDocumentDemoOpsCommand,
    'eventSuccessArrivalMissionDocument.demoOpsId': eventSuccessArrivalMissionDocumentDemoOpsId,
    'eventSuccessArrivalMissionDocument.eventId': eventSuccessArrivalMissionDocumentEventId,
    'eventSuccessArrivalMissionDocument.observerUid': eventSuccessArrivalMissionDocumentObserverUid,
    'eventSuccessArrivalMissionDocument.organizerId': eventSuccessArrivalMissionDocumentOrganizerId,
    'eventSuccessArrivalMissionDocument.question': eventSuccessArrivalMissionDocumentQuestion,
    'eventSuccessArrivalMissionDocument.scenario': eventSuccessArrivalMissionDocumentScenario,
    'eventSuccessArrivalMissionDocument.seedPrefix': eventSuccessArrivalMissionDocumentSeedPrefix,
    'eventSuccessArrivalMissionDocument.selectedAnswerId': eventSuccessArrivalMissionDocumentSelectedAnswerId,
    'eventSuccessArrivalMissionDocument.status': eventSuccessArrivalMissionDocumentStatus,
    'eventSuccessArrivalMissionDocument.targetContext': eventSuccessArrivalMissionDocumentTargetContext,
    'eventSuccessArrivalMissionDocument.targetDisplayName': eventSuccessArrivalMissionDocumentTargetDisplayName,
    'eventSuccessArrivalMissionDocument.targetUid': eventSuccessArrivalMissionDocumentTargetUid,
    'eventSuccessArrivalMissionDocument.updatedAt._nanoseconds': eventSuccessArrivalMissionDocumentUpdatedAtNanoseconds,
    'eventSuccessArrivalMissionDocument.updatedAt._seconds': eventSuccessArrivalMissionDocumentUpdatedAtSeconds,
    'eventSuccessAssignmentDocument.clubId': eventSuccessAssignmentDocumentClubId,
    'eventSuccessAssignmentDocument.createdAt._nanoseconds': eventSuccessAssignmentDocumentCreatedAtNanoseconds,
    'eventSuccessAssignmentDocument.createdAt._seconds': eventSuccessAssignmentDocumentCreatedAtSeconds,
    'eventSuccessAssignmentDocument.demoOpsCommand': eventSuccessAssignmentDocumentDemoOpsCommand,
    'eventSuccessAssignmentDocument.demoOpsId': eventSuccessAssignmentDocumentDemoOpsId,
    'eventSuccessAssignmentDocument.displaySubtitle': eventSuccessAssignmentDocumentDisplaySubtitle,
    'eventSuccessAssignmentDocument.displayTitle': eventSuccessAssignmentDocumentDisplayTitle,
    'eventSuccessAssignmentDocument.eventId': eventSuccessAssignmentDocumentEventId,
    'eventSuccessAssignmentDocument.label': eventSuccessAssignmentDocumentLabel,
    'eventSuccessAssignmentDocument.moduleId': eventSuccessAssignmentDocumentModuleId,
    'eventSuccessAssignmentDocument.organizerId': eventSuccessAssignmentDocumentOrganizerId,
    'eventSuccessAssignmentDocument.peerUids': eventSuccessAssignmentDocumentPeerUids,
    'eventSuccessAssignmentDocument.rotationFairness.assignedRoundCount': eventSuccessAssignmentDocumentRotationFairnessAssignedRoundCount,
    'eventSuccessAssignmentDocument.rotationFairness.repeatPeerCount': eventSuccessAssignmentDocumentRotationFairnessRepeatPeerCount,
    'eventSuccessAssignmentDocument.rotationFairness.sitOutRoundCount': eventSuccessAssignmentDocumentRotationFairnessSitOutRoundCount,
    'eventSuccessAssignmentDocument.rotationFairness.uniquePeerCount': eventSuccessAssignmentDocumentRotationFairnessUniquePeerCount,
    'eventSuccessAssignmentDocument.scenario': eventSuccessAssignmentDocumentScenario,
    'eventSuccessAssignmentDocument.seedPrefix': eventSuccessAssignmentDocumentSeedPrefix,
    'eventSuccessAssignmentDocument.source': eventSuccessAssignmentDocumentSource,
    'eventSuccessAssignmentDocument.uid': eventSuccessAssignmentDocumentUid,
    'eventSuccessAssignmentDocument.unitIndex': eventSuccessAssignmentDocumentUnitIndex,
    'eventSuccessAssignmentDocument.unitKind': eventSuccessAssignmentDocumentUnitKind,
    'eventSuccessAssignmentDocument.unitLabel': eventSuccessAssignmentDocumentUnitLabel,
    'eventSuccessAssignmentDocument.updatedAt._nanoseconds': eventSuccessAssignmentDocumentUpdatedAtNanoseconds,
    'eventSuccessAssignmentDocument.updatedAt._seconds': eventSuccessAssignmentDocumentUpdatedAtSeconds,
    'eventSuccessAssignmentDocument.whySummary': eventSuccessAssignmentDocumentWhySummary,
    'eventSuccessCompatibilityResponseDocument.answerIds': eventSuccessCompatibilityResponseDocumentAnswerIds,
    'eventSuccessCompatibilityResponseDocument.clubId': eventSuccessCompatibilityResponseDocumentClubId,
    'eventSuccessCompatibilityResponseDocument.createdAt._nanoseconds': eventSuccessCompatibilityResponseDocumentCreatedAtNanoseconds,
    'eventSuccessCompatibilityResponseDocument.createdAt._seconds': eventSuccessCompatibilityResponseDocumentCreatedAtSeconds,
    'eventSuccessCompatibilityResponseDocument.demoOpsCommand': eventSuccessCompatibilityResponseDocumentDemoOpsCommand,
    'eventSuccessCompatibilityResponseDocument.demoOpsId': eventSuccessCompatibilityResponseDocumentDemoOpsId,
    'eventSuccessCompatibilityResponseDocument.eventId': eventSuccessCompatibilityResponseDocumentEventId,
    'eventSuccessCompatibilityResponseDocument.organizerId': eventSuccessCompatibilityResponseDocumentOrganizerId,
    'eventSuccessCompatibilityResponseDocument.scenario': eventSuccessCompatibilityResponseDocumentScenario,
    'eventSuccessCompatibilityResponseDocument.seedPrefix': eventSuccessCompatibilityResponseDocumentSeedPrefix,
    'eventSuccessCompatibilityResponseDocument.uid': eventSuccessCompatibilityResponseDocumentUid,
    'eventSuccessCompatibilityResponseDocument.updatedAt._nanoseconds': eventSuccessCompatibilityResponseDocumentUpdatedAtNanoseconds,
    'eventSuccessCompatibilityResponseDocument.updatedAt._seconds': eventSuccessCompatibilityResponseDocumentUpdatedAtSeconds,
    'eventSuccessFeedbackDocument.clubId': eventSuccessFeedbackDocumentClubId,
    'eventSuccessFeedbackDocument.createdAt._nanoseconds': eventSuccessFeedbackDocumentCreatedAtNanoseconds,
    'eventSuccessFeedbackDocument.createdAt._seconds': eventSuccessFeedbackDocumentCreatedAtSeconds,
    'eventSuccessFeedbackDocument.demoOpsCommand': eventSuccessFeedbackDocumentDemoOpsCommand,
    'eventSuccessFeedbackDocument.demoOpsId': eventSuccessFeedbackDocumentDemoOpsId,
    'eventSuccessFeedbackDocument.eventId': eventSuccessFeedbackDocumentEventId,
    'eventSuccessFeedbackDocument.metNewPeopleCount': eventSuccessFeedbackDocumentMetNewPeopleCount,
    'eventSuccessFeedbackDocument.organizerId': eventSuccessFeedbackDocumentOrganizerId,
    'eventSuccessFeedbackDocument.privateNote': eventSuccessFeedbackDocumentPrivateNote,
    'eventSuccessFeedbackDocument.safetyConcern': eventSuccessFeedbackDocumentSafetyConcern,
    'eventSuccessFeedbackDocument.scenario': eventSuccessFeedbackDocumentScenario,
    'eventSuccessFeedbackDocument.seedPrefix': eventSuccessFeedbackDocumentSeedPrefix,
    'eventSuccessFeedbackDocument.structureRating': eventSuccessFeedbackDocumentStructureRating,
    'eventSuccessFeedbackDocument.uid': eventSuccessFeedbackDocumentUid,
    'eventSuccessFeedbackDocument.updatedAt._nanoseconds': eventSuccessFeedbackDocumentUpdatedAtNanoseconds,
    'eventSuccessFeedbackDocument.updatedAt._seconds': eventSuccessFeedbackDocumentUpdatedAtSeconds,
    'eventSuccessFeedbackDocument.welcomeRating': eventSuccessFeedbackDocumentWelcomeRating,
    'eventSuccessPlanDocument.activeRevealRoundIndex': eventSuccessPlanDocumentActiveRevealRoundIndex,
    'eventSuccessPlanDocument.activeStepIndex': eventSuccessPlanDocumentActiveStepIndex,
    'eventSuccessPlanDocument.attendeePrompt': eventSuccessPlanDocumentAttendeePrompt,
    'eventSuccessPlanDocument.clubId': eventSuccessPlanDocumentClubId,
    'eventSuccessPlanDocument.completedAt._nanoseconds': eventSuccessPlanDocumentCompletedAtNanoseconds,
    'eventSuccessPlanDocument.completedAt._seconds': eventSuccessPlanDocumentCompletedAtSeconds,
    'eventSuccessPlanDocument.contextualOpenersEnabled': eventSuccessPlanDocumentContextualOpenersEnabled,
    'eventSuccessPlanDocument.createdAt._nanoseconds': eventSuccessPlanDocumentCreatedAtNanoseconds,
    'eventSuccessPlanDocument.createdAt._seconds': eventSuccessPlanDocumentCreatedAtSeconds,
    'eventSuccessPlanDocument.demoOpsCommand': eventSuccessPlanDocumentDemoOpsCommand,
    'eventSuccessPlanDocument.demoOpsId': eventSuccessPlanDocumentDemoOpsId,
    'eventSuccessPlanDocument.eventId': eventSuccessPlanDocumentEventId,
    'eventSuccessPlanDocument.frozenAt._nanoseconds': eventSuccessPlanDocumentFrozenAtNanoseconds,
    'eventSuccessPlanDocument.frozenAt._seconds': eventSuccessPlanDocumentFrozenAtSeconds,
    'eventSuccessPlanDocument.hostGoal': eventSuccessPlanDocumentHostGoal,
    'eventSuccessPlanDocument.organizerId': eventSuccessPlanDocumentOrganizerId,
    'eventSuccessPlanDocument.playbookId': eventSuccessPlanDocumentPlaybookId,
    'eventSuccessPlanDocument.questionnaireConfig.customTitle': eventSuccessPlanDocumentQuestionnaireConfigCustomTitle,
    'eventSuccessPlanDocument.questionnaireConfig.templateId': eventSuccessPlanDocumentQuestionnaireConfigTemplateId,
    'eventSuccessPlanDocument.revealStartedAt._nanoseconds': eventSuccessPlanDocumentRevealStartedAtNanoseconds,
    'eventSuccessPlanDocument.revealStartedAt._seconds': eventSuccessPlanDocumentRevealStartedAtSeconds,
    'eventSuccessPlanDocument.revealStatus': eventSuccessPlanDocumentRevealStatus,
    'eventSuccessPlanDocument.scenario': eventSuccessPlanDocumentScenario,
    'eventSuccessPlanDocument.seedPrefix': eventSuccessPlanDocumentSeedPrefix,
    'eventSuccessPlanDocument.selectedModuleIds': eventSuccessPlanDocumentSelectedModuleIds,
    'eventSuccessPlanDocument.status': eventSuccessPlanDocumentStatus,
    'eventSuccessPlanDocument.structureConfig.maxPairMeetings': eventSuccessPlanDocumentStructureConfigMaxPairMeetings,
    'eventSuccessPlanDocument.structureConfig.revealCountdownSeconds': eventSuccessPlanDocumentStructureConfigRevealCountdownSeconds,
    'eventSuccessPlanDocument.structureConfig.rotationIntervalMinutes': eventSuccessPlanDocumentStructureConfigRotationIntervalMinutes,
    'eventSuccessPlanDocument.structureConfig.rotationRepeatStrategy': eventSuccessPlanDocumentStructureConfigRotationRepeatStrategy,
    'eventSuccessPlanDocument.structureConfig.unitCount': eventSuccessPlanDocumentStructureConfigUnitCount,
    'eventSuccessPlanDocument.structureConfig.unitKind': eventSuccessPlanDocumentStructureConfigUnitKind,
    'eventSuccessPlanDocument.structureConfig.unitSize': eventSuccessPlanDocumentStructureConfigUnitSize,
    'eventSuccessPlanDocument.targetAttendeeCount': eventSuccessPlanDocumentTargetAttendeeCount,
    'eventSuccessPlanDocument.updatedAt._nanoseconds': eventSuccessPlanDocumentUpdatedAtNanoseconds,
    'eventSuccessPlanDocument.updatedAt._seconds': eventSuccessPlanDocumentUpdatedAtSeconds,
    'eventSuccessPlanDocument.wingmanRequestsEnabled': eventSuccessPlanDocumentWingmanRequestsEnabled,
    'eventSuccessPreferenceDocument.clubId': eventSuccessPreferenceDocumentClubId,
    'eventSuccessPreferenceDocument.createdAt._nanoseconds': eventSuccessPreferenceDocumentCreatedAtNanoseconds,
    'eventSuccessPreferenceDocument.createdAt._seconds': eventSuccessPreferenceDocumentCreatedAtSeconds,
    'eventSuccessPreferenceDocument.demoOpsCommand': eventSuccessPreferenceDocumentDemoOpsCommand,
    'eventSuccessPreferenceDocument.demoOpsId': eventSuccessPreferenceDocumentDemoOpsId,
    'eventSuccessPreferenceDocument.eventId': eventSuccessPreferenceDocumentEventId,
    'eventSuccessPreferenceDocument.guidedRotationsOptedOut': eventSuccessPreferenceDocumentGuidedRotationsOptedOut,
    'eventSuccessPreferenceDocument.microPodsOptedOut': eventSuccessPreferenceDocumentMicroPodsOptedOut,
    'eventSuccessPreferenceDocument.organizerId': eventSuccessPreferenceDocumentOrganizerId,
    'eventSuccessPreferenceDocument.scenario': eventSuccessPreferenceDocumentScenario,
    'eventSuccessPreferenceDocument.seedPrefix': eventSuccessPreferenceDocumentSeedPrefix,
    'eventSuccessPreferenceDocument.uid': eventSuccessPreferenceDocumentUid,
    'eventSuccessPreferenceDocument.updatedAt._nanoseconds': eventSuccessPreferenceDocumentUpdatedAtNanoseconds,
    'eventSuccessPreferenceDocument.updatedAt._seconds': eventSuccessPreferenceDocumentUpdatedAtSeconds,
    'eventSuccessScorecardDocument.attendeesWhoCaughtSomeone': eventSuccessScorecardDocumentAttendeesWhoCaughtSomeone,
    'eventSuccessScorecardDocument.attendeesWhoMetTwoPlusPeople': eventSuccessScorecardDocumentAttendeesWhoMetTwoPlusPeople,
    'eventSuccessScorecardDocument.averageStructureRating': eventSuccessScorecardDocumentAverageStructureRating,
    'eventSuccessScorecardDocument.averageWelcomeRating': eventSuccessScorecardDocumentAverageWelcomeRating,
    'eventSuccessScorecardDocument.bookedCount': eventSuccessScorecardDocumentBookedCount,
    'eventSuccessScorecardDocument.catchRate': eventSuccessScorecardDocumentCatchRate,
    'eventSuccessScorecardDocument.catchRecipientCount': eventSuccessScorecardDocumentCatchRecipientCount,
    'eventSuccessScorecardDocument.catchSentCount': eventSuccessScorecardDocumentCatchSentCount,
    'eventSuccessScorecardDocument.chatStartedCount': eventSuccessScorecardDocumentChatStartedCount,
    'eventSuccessScorecardDocument.checkedInCount': eventSuccessScorecardDocumentCheckedInCount,
    'eventSuccessScorecardDocument.clubId': eventSuccessScorecardDocumentClubId,
    'eventSuccessScorecardDocument.demoOpsCommand': eventSuccessScorecardDocumentDemoOpsCommand,
    'eventSuccessScorecardDocument.demoOpsId': eventSuccessScorecardDocumentDemoOpsId,
    'eventSuccessScorecardDocument.eventId': eventSuccessScorecardDocumentEventId,
    'eventSuccessScorecardDocument.feedbackCount': eventSuccessScorecardDocumentFeedbackCount,
    'eventSuccessScorecardDocument.funnel.approvedRequestCount': eventSuccessScorecardDocumentFunnelApprovedRequestCount,
    'eventSuccessScorecardDocument.funnel.attendeesWhoCaughtSomeone': eventSuccessScorecardDocumentFunnelAttendeesWhoCaughtSomeone,
    'eventSuccessScorecardDocument.funnel.bookedCount': eventSuccessScorecardDocumentFunnelBookedCount,
    'eventSuccessScorecardDocument.funnel.catchSentCount': eventSuccessScorecardDocumentFunnelCatchSentCount,
    'eventSuccessScorecardDocument.funnel.chatStartedCount': eventSuccessScorecardDocumentFunnelChatStartedCount,
    'eventSuccessScorecardDocument.funnel.checkedInCount': eventSuccessScorecardDocumentFunnelCheckedInCount,
    'eventSuccessScorecardDocument.funnel.checkoutStartedCount': eventSuccessScorecardDocumentFunnelCheckoutStartedCount,
    'eventSuccessScorecardDocument.funnel.declinedRequestCount': eventSuccessScorecardDocumentFunnelDeclinedRequestCount,
    'eventSuccessScorecardDocument.funnel.directSignupCount': eventSuccessScorecardDocumentFunnelDirectSignupCount,
    'eventSuccessScorecardDocument.funnel.inviteLinkCount': eventSuccessScorecardDocumentFunnelInviteLinkCount,
    'eventSuccessScorecardDocument.funnel.inviteOpenCount': eventSuccessScorecardDocumentFunnelInviteOpenCount,
    'eventSuccessScorecardDocument.funnel.mutualMatchCount': eventSuccessScorecardDocumentFunnelMutualMatchCount,
    'eventSuccessScorecardDocument.funnel.noShowCount': eventSuccessScorecardDocumentFunnelNoShowCount,
    'eventSuccessScorecardDocument.funnel.paymentCompletedCount': eventSuccessScorecardDocumentFunnelPaymentCompletedCount,
    'eventSuccessScorecardDocument.funnel.paymentFailedCount': eventSuccessScorecardDocumentFunnelPaymentFailedCount,
    'eventSuccessScorecardDocument.funnel.paymentPendingCount': eventSuccessScorecardDocumentFunnelPaymentPendingCount,
    'eventSuccessScorecardDocument.funnel.paymentRefundedCount': eventSuccessScorecardDocumentFunnelPaymentRefundedCount,
    'eventSuccessScorecardDocument.funnel.pendingRequestCount': eventSuccessScorecardDocumentFunnelPendingRequestCount,
    'eventSuccessScorecardDocument.funnel.repeatAttendeeCount': eventSuccessScorecardDocumentFunnelRepeatAttendeeCount,
    'eventSuccessScorecardDocument.funnel.requestCount': eventSuccessScorecardDocumentFunnelRequestCount,
    'eventSuccessScorecardDocument.funnel.totalDemandCount': eventSuccessScorecardDocumentFunnelTotalDemandCount,
    'eventSuccessScorecardDocument.funnel.waitlistJoinCount': eventSuccessScorecardDocumentFunnelWaitlistJoinCount,
    'eventSuccessScorecardDocument.funnel.waitlistOfferAcceptedCount': eventSuccessScorecardDocumentFunnelWaitlistOfferAcceptedCount,
    'eventSuccessScorecardDocument.funnel.waitlistOfferActiveCount': eventSuccessScorecardDocumentFunnelWaitlistOfferActiveCount,
    'eventSuccessScorecardDocument.funnel.waitlistOfferCount': eventSuccessScorecardDocumentFunnelWaitlistOfferCount,
    'eventSuccessScorecardDocument.funnel.waitlistOfferDeclinedCount': eventSuccessScorecardDocumentFunnelWaitlistOfferDeclinedCount,
    'eventSuccessScorecardDocument.funnel.waitlistOfferExpiredCount': eventSuccessScorecardDocumentFunnelWaitlistOfferExpiredCount,
    'eventSuccessScorecardDocument.mutualMatchCount': eventSuccessScorecardDocumentMutualMatchCount,
    'eventSuccessScorecardDocument.organizerId': eventSuccessScorecardDocumentOrganizerId,
    'eventSuccessScorecardDocument.safetyIncidentCount': eventSuccessScorecardDocumentSafetyIncidentCount,
    'eventSuccessScorecardDocument.scenario': eventSuccessScorecardDocumentScenario,
    'eventSuccessScorecardDocument.seedPrefix': eventSuccessScorecardDocumentSeedPrefix,
    'eventSuccessScorecardDocument.updatedAt._nanoseconds': eventSuccessScorecardDocumentUpdatedAtNanoseconds,
    'eventSuccessScorecardDocument.updatedAt._seconds': eventSuccessScorecardDocumentUpdatedAtSeconds,
    'eventSuccessWingmanRequestDocument.clubId': eventSuccessWingmanRequestDocumentClubId,
    'eventSuccessWingmanRequestDocument.createdAt._nanoseconds': eventSuccessWingmanRequestDocumentCreatedAtNanoseconds,
    'eventSuccessWingmanRequestDocument.createdAt._seconds': eventSuccessWingmanRequestDocumentCreatedAtSeconds,
    'eventSuccessWingmanRequestDocument.demoOpsCommand': eventSuccessWingmanRequestDocumentDemoOpsCommand,
    'eventSuccessWingmanRequestDocument.demoOpsId': eventSuccessWingmanRequestDocumentDemoOpsId,
    'eventSuccessWingmanRequestDocument.eventId': eventSuccessWingmanRequestDocumentEventId,
    'eventSuccessWingmanRequestDocument.hostVisibleConsent': eventSuccessWingmanRequestDocumentHostVisibleConsent,
    'eventSuccessWingmanRequestDocument.note': eventSuccessWingmanRequestDocumentNote,
    'eventSuccessWingmanRequestDocument.organizerId': eventSuccessWingmanRequestDocumentOrganizerId,
    'eventSuccessWingmanRequestDocument.requesterUid': eventSuccessWingmanRequestDocumentRequesterUid,
    'eventSuccessWingmanRequestDocument.scenario': eventSuccessWingmanRequestDocumentScenario,
    'eventSuccessWingmanRequestDocument.seedPrefix': eventSuccessWingmanRequestDocumentSeedPrefix,
    'eventSuccessWingmanRequestDocument.status': eventSuccessWingmanRequestDocumentStatus,
    'eventSuccessWingmanRequestDocument.targetUid': eventSuccessWingmanRequestDocumentTargetUid,
    'eventSuccessWingmanRequestDocument.updatedAt._nanoseconds': eventSuccessWingmanRequestDocumentUpdatedAtNanoseconds,
    'eventSuccessWingmanRequestDocument.updatedAt._seconds': eventSuccessWingmanRequestDocumentUpdatedAtSeconds,
    'eventWaitlistOfferDocument.clubId': eventWaitlistOfferDocumentClubId,
    'eventWaitlistOfferDocument.cohortAtOffer': eventWaitlistOfferDocumentCohortAtOffer,
    'eventWaitlistOfferDocument.createdAt._nanoseconds': eventWaitlistOfferDocumentCreatedAtNanoseconds,
    'eventWaitlistOfferDocument.createdAt._seconds': eventWaitlistOfferDocumentCreatedAtSeconds,
    'eventWaitlistOfferDocument.decidedAt._nanoseconds': eventWaitlistOfferDocumentDecidedAtNanoseconds,
    'eventWaitlistOfferDocument.decidedAt._seconds': eventWaitlistOfferDocumentDecidedAtSeconds,
    'eventWaitlistOfferDocument.demoOpsCommand': eventWaitlistOfferDocumentDemoOpsCommand,
    'eventWaitlistOfferDocument.demoOpsId': eventWaitlistOfferDocumentDemoOpsId,
    'eventWaitlistOfferDocument.eventId': eventWaitlistOfferDocumentEventId,
    'eventWaitlistOfferDocument.expiresAt._nanoseconds': eventWaitlistOfferDocumentExpiresAtNanoseconds,
    'eventWaitlistOfferDocument.expiresAt._seconds': eventWaitlistOfferDocumentExpiresAtSeconds,
    'eventWaitlistOfferDocument.expiringNotifiedAt._nanoseconds': eventWaitlistOfferDocumentExpiringNotifiedAtNanoseconds,
    'eventWaitlistOfferDocument.expiringNotifiedAt._seconds': eventWaitlistOfferDocumentExpiringNotifiedAtSeconds,
    'eventWaitlistOfferDocument.inviteLinkId': eventWaitlistOfferDocumentInviteLinkId,
    'eventWaitlistOfferDocument.offeredAt._nanoseconds': eventWaitlistOfferDocumentOfferedAtNanoseconds,
    'eventWaitlistOfferDocument.offeredAt._seconds': eventWaitlistOfferDocumentOfferedAtSeconds,
    'eventWaitlistOfferDocument.offeredBy': eventWaitlistOfferDocumentOfferedBy,
    'eventWaitlistOfferDocument.organizerId': eventWaitlistOfferDocumentOrganizerId,
    'eventWaitlistOfferDocument.scenario': eventWaitlistOfferDocumentScenario,
    'eventWaitlistOfferDocument.seedPrefix': eventWaitlistOfferDocumentSeedPrefix,
    'eventWaitlistOfferDocument.source': eventWaitlistOfferDocumentSource,
    'eventWaitlistOfferDocument.status': eventWaitlistOfferDocumentStatus,
    'eventWaitlistOfferDocument.uid': eventWaitlistOfferDocumentUid,
    'eventWaitlistOfferDocument.updatedAt._nanoseconds': eventWaitlistOfferDocumentUpdatedAtNanoseconds,
    'eventWaitlistOfferDocument.updatedAt._seconds': eventWaitlistOfferDocumentUpdatedAtSeconds,
    'externalEventDocument.activity.activityKind': externalEventDocumentActivityActivityKind,
    'externalEventDocument.activity.interactionModel': externalEventDocumentActivityInteractionModel,
    'externalEventDocument.activity.source': externalEventDocumentActivitySource,
    'externalEventDocument.activity.version': externalEventDocumentActivityVersion,
    'externalEventDocument.booking.catchBookingEnabled': externalEventDocumentBookingCatchBookingEnabled,
    'externalEventDocument.booking.catchPaymentsEnabled': externalEventDocumentBookingCatchPaymentsEnabled,
    'externalEventDocument.booking.catchReservationsEnabled': externalEventDocumentBookingCatchReservationsEnabled,
    'externalEventDocument.booking.catchWaitlistEnabled': externalEventDocumentBookingCatchWaitlistEnabled,
    'externalEventDocument.booking.externalLinks': externalEventDocumentBookingExternalLinks,
    'externalEventDocument.booking.mode': externalEventDocumentBookingMode,
    'externalEventDocument.canonicalHostId': externalEventDocumentCanonicalHostId,
    'externalEventDocument.compatibilityClubId': externalEventDocumentCompatibilityClubId,
    'externalEventDocument.createdAt._nanoseconds': externalEventDocumentCreatedAtNanoseconds,
    'externalEventDocument.createdAt._seconds': externalEventDocumentCreatedAtSeconds,
    'externalEventDocument.dedupe.conflictPolicy': externalEventDocumentDedupeConflictPolicy,
    'externalEventDocument.dedupe.duplicateCandidateIds': externalEventDocumentDedupeDuplicateCandidateIds,
    'externalEventDocument.dedupe.normalizedEventKey': externalEventDocumentDedupeNormalizedEventKey,
    'externalEventDocument.dedupe.primaryCandidateId': externalEventDocumentDedupePrimaryCandidateId,
    'externalEventDocument.description': externalEventDocumentDescription,
    'externalEventDocument.discovery.availability': externalEventDocumentDiscoveryAvailability,
    'externalEventDocument.discovery.citySlug': externalEventDocumentDiscoveryCitySlug,
    'externalEventDocument.discovery.countryCode': externalEventDocumentDiscoveryCountryCode,
    'externalEventDocument.discovery.manualApprovalRequired': externalEventDocumentDiscoveryManualApprovalRequired,
    'externalEventDocument.endTime._nanoseconds': externalEventDocumentEndTimeNanoseconds,
    'externalEventDocument.endTime._seconds': externalEventDocumentEndTimeSeconds,
    'externalEventDocument.eventId': externalEventDocumentEventId,
    'externalEventDocument.externalSource.candidateId': externalEventDocumentExternalSourceCandidateId,
    'externalEventDocument.externalSource.eventUrl': externalEventDocumentExternalSourceEventUrl,
    'externalEventDocument.externalSource.platform': externalEventDocumentExternalSourcePlatform,
    'externalEventDocument.externalSource.sourceEventId': externalEventDocumentExternalSourceSourceEventId,
    'externalEventDocument.externalSource.sourceEventKey': externalEventDocumentExternalSourceSourceEventKey,
    'externalEventDocument.externalSource.sourceUrl': externalEventDocumentExternalSourceSourceUrl,
    'externalEventDocument.locationDetails': externalEventDocumentLocationDetails,
    'externalEventDocument.meetingLocation.address': externalEventDocumentMeetingLocationAddress,
    'externalEventDocument.meetingLocation.latitude': externalEventDocumentMeetingLocationLatitude,
    'externalEventDocument.meetingLocation.longitude': externalEventDocumentMeetingLocationLongitude,
    'externalEventDocument.meetingLocation.name': externalEventDocumentMeetingLocationName,
    'externalEventDocument.meetingLocation.notes': externalEventDocumentMeetingLocationNotes,
    'externalEventDocument.meetingLocation.placeId': externalEventDocumentMeetingLocationPlaceId,
    'externalEventDocument.meetingPoint': externalEventDocumentMeetingPoint,
    'externalEventDocument.photoUrl': externalEventDocumentPhotoUrl,
    'externalEventDocument.price.currency': externalEventDocumentPriceCurrency,
    'externalEventDocument.price.displayText': externalEventDocumentPriceDisplayText,
    'externalEventDocument.price.parsedPriceInPaise': externalEventDocumentPriceParsedPriceInPaise,
    'externalEventDocument.publicationStatus': externalEventDocumentPublicationStatus,
    'externalEventDocument.review.decidedAt': externalEventDocumentReviewDecidedAt,
    'externalEventDocument.review.eventReviewBatchId': externalEventDocumentReviewEventReviewBatchId,
    'externalEventDocument.review.importPolicyAcknowledged': externalEventDocumentReviewImportPolicyAcknowledged,
    'externalEventDocument.review.note': externalEventDocumentReviewNote,
    'externalEventDocument.review.ownerSafeCopyReviewed': externalEventDocumentReviewOwnerSafeCopyReviewed,
    'externalEventDocument.review.reviewer': externalEventDocumentReviewReviewer,
    'externalEventDocument.schemaVersion': externalEventDocumentSchemaVersion,
    'externalEventDocument.startTime._nanoseconds': externalEventDocumentStartTimeNanoseconds,
    'externalEventDocument.startTime._seconds': externalEventDocumentStartTimeSeconds,
    'externalEventDocument.status': externalEventDocumentStatus,
    'externalEventDocument.timezone': externalEventDocumentTimezone,
    'externalEventDocument.title': externalEventDocumentTitle,
    'externalEventDocument.updatedAt._nanoseconds': externalEventDocumentUpdatedAtNanoseconds,
    'externalEventDocument.updatedAt._seconds': externalEventDocumentUpdatedAtSeconds,
    'functionEventReceiptDocument.createdAt._nanoseconds': functionEventReceiptDocumentCreatedAtNanoseconds,
    'functionEventReceiptDocument.createdAt._seconds': functionEventReceiptDocumentCreatedAtSeconds,
    'functionEventReceiptDocument.eventId': functionEventReceiptDocumentEventId,
    'functionEventReceiptDocument.handler': functionEventReceiptDocumentHandler,
    'functionEventReceiptDocument.matchId': functionEventReceiptDocumentMatchId,
    'functionEventReceiptDocument.messageId': functionEventReceiptDocumentMessageId,
    'hostAnalyticsSnapshotDocument.createdAt._nanoseconds': hostAnalyticsSnapshotDocumentCreatedAtNanoseconds,
    'hostAnalyticsSnapshotDocument.createdAt._seconds': hostAnalyticsSnapshotDocumentCreatedAtSeconds,
    'hostAnalyticsSnapshotDocument.expiresAt._nanoseconds': hostAnalyticsSnapshotDocumentExpiresAtNanoseconds,
    'hostAnalyticsSnapshotDocument.expiresAt._seconds': hostAnalyticsSnapshotDocumentExpiresAtSeconds,
    'hostAnalyticsSnapshotDocument.response.dataQuality': hostAnalyticsSnapshotDocumentResponseDataQuality,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.claimClicks': hostAnalyticsSnapshotDocumentResponseDiscoverySummaryClaimClicks,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.contactClicks': hostAnalyticsSnapshotDocumentResponseDiscoverySummaryContactClicks,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.eventSaves': hostAnalyticsSnapshotDocumentResponseDiscoverySummaryEventSaves,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.eventViews': hostAnalyticsSnapshotDocumentResponseDiscoverySummaryEventViews,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.listingViews': hostAnalyticsSnapshotDocumentResponseDiscoverySummaryListingViews,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.organizerSaves': hostAnalyticsSnapshotDocumentResponseDiscoverySummaryOrganizerSaves,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.outboundClicks': hostAnalyticsSnapshotDocumentResponseDiscoverySummaryOutboundClicks,
    'hostAnalyticsSnapshotDocument.response.discoverySummary.searchAppearances': hostAnalyticsSnapshotDocumentResponseDiscoverySummarySearchAppearances,
    'hostAnalyticsSnapshotDocument.response.generatedAt': hostAnalyticsSnapshotDocumentResponseGeneratedAt,
    'hostAnalyticsSnapshotDocument.response.range.endDate': hostAnalyticsSnapshotDocumentResponseRangeEndDate,
    'hostAnalyticsSnapshotDocument.response.range.granularity': hostAnalyticsSnapshotDocumentResponseRangeGranularity,
    'hostAnalyticsSnapshotDocument.response.range.preset': hostAnalyticsSnapshotDocumentResponseRangePreset,
    'hostAnalyticsSnapshotDocument.response.range.startDate': hostAnalyticsSnapshotDocumentResponseRangeStartDate,
    'hostAnalyticsSnapshotDocument.response.reviewSummary.averageRating': hostAnalyticsSnapshotDocumentResponseReviewSummaryAverageRating,
    'hostAnalyticsSnapshotDocument.response.reviewSummary.newReviews': hostAnalyticsSnapshotDocumentResponseReviewSummaryNewReviews,
    'hostAnalyticsSnapshotDocument.response.reviewSummary.ownerResponseCount': hostAnalyticsSnapshotDocumentResponseReviewSummaryOwnerResponseCount,
    'hostAnalyticsSnapshotDocument.response.reviewSummary.publicReviews': hostAnalyticsSnapshotDocumentResponseReviewSummaryPublicReviews,
    'hostAnalyticsSnapshotDocument.response.reviewSummary.publishedReviews': hostAnalyticsSnapshotDocumentResponseReviewSummaryPublishedReviews,
    'hostAnalyticsSnapshotDocument.response.reviewSummary.verifiedReviews': hostAnalyticsSnapshotDocumentResponseReviewSummaryVerifiedReviews,
    'hostAnalyticsSnapshotDocument.response.scope.clubIds': hostAnalyticsSnapshotDocumentResponseScopeClubIds,
    'hostAnalyticsSnapshotDocument.response.scope.clubName': hostAnalyticsSnapshotDocumentResponseScopeClubName,
    'hostAnalyticsSnapshotDocument.response.scope.eventIds': hostAnalyticsSnapshotDocumentResponseScopeEventIds,
    'hostAnalyticsSnapshotDocument.response.scope.eventTitle': hostAnalyticsSnapshotDocumentResponseScopeEventTitle,
    'hostAnalyticsSnapshotDocument.response.scope.organizerIds': hostAnalyticsSnapshotDocumentResponseScopeOrganizerIds,
    'hostAnalyticsSnapshotDocument.response.scope.organizerName': hostAnalyticsSnapshotDocumentResponseScopeOrganizerName,
    'hostAnalyticsSnapshotDocument.response.summaryCards': hostAnalyticsSnapshotDocumentResponseSummaryCards,
    'hostAnalyticsSnapshotDocument.response.timezone': hostAnalyticsSnapshotDocumentResponseTimezone,
    'hostAnalyticsSnapshotDocument.response.topEvents': hostAnalyticsSnapshotDocumentResponseTopEvents,
    'hostAnalyticsSnapshotDocument.response.trend': hostAnalyticsSnapshotDocumentResponseTrend,
    'hostAnalyticsSnapshotDocument.scopeHash': hostAnalyticsSnapshotDocumentScopeHash,
    'hostAnalyticsSnapshotDocument.uid': hostAnalyticsSnapshotDocumentUid,
    'hostPaymentAccountDocument.chargesEnabled': hostPaymentAccountDocumentChargesEnabled,
    'hostPaymentAccountDocument.country': hostPaymentAccountDocumentCountry,
    'hostPaymentAccountDocument.createdAt._nanoseconds': hostPaymentAccountDocumentCreatedAtNanoseconds,
    'hostPaymentAccountDocument.createdAt._seconds': hostPaymentAccountDocumentCreatedAtSeconds,
    'hostPaymentAccountDocument.defaultCurrency': hostPaymentAccountDocumentDefaultCurrency,
    'hostPaymentAccountDocument.detailsSubmitted': hostPaymentAccountDocumentDetailsSubmitted,
    'hostPaymentAccountDocument.disabledReason': hostPaymentAccountDocumentDisabledReason,
    'hostPaymentAccountDocument.lastStripeEventId': hostPaymentAccountDocumentLastStripeEventId,
    'hostPaymentAccountDocument.onboardingStatus': hostPaymentAccountDocumentOnboardingStatus,
    'hostPaymentAccountDocument.payoutsEnabled': hostPaymentAccountDocumentPayoutsEnabled,
    'hostPaymentAccountDocument.provider': hostPaymentAccountDocumentProvider,
    'hostPaymentAccountDocument.requirementsCurrentlyDue': hostPaymentAccountDocumentRequirementsCurrentlyDue,
    'hostPaymentAccountDocument.requirementsPastDue': hostPaymentAccountDocumentRequirementsPastDue,
    'hostPaymentAccountDocument.requirementsPendingVerification': hostPaymentAccountDocumentRequirementsPendingVerification,
    'hostPaymentAccountDocument.stripeAccountId': hostPaymentAccountDocumentStripeAccountId,
    'hostPaymentAccountDocument.updatedAt._nanoseconds': hostPaymentAccountDocumentUpdatedAtNanoseconds,
    'hostPaymentAccountDocument.updatedAt._seconds': hostPaymentAccountDocumentUpdatedAtSeconds,
    'hostPaymentAccountDocument.userId': hostPaymentAccountDocumentUserId,
    'hostProfileDocument.avatarUrl': hostProfileDocumentAvatarUrl,
    'hostProfileDocument.bio': hostProfileDocumentBio,
    'hostProfileDocument.createdAt._nanoseconds': hostProfileDocumentCreatedAtNanoseconds,
    'hostProfileDocument.createdAt._seconds': hostProfileDocumentCreatedAtSeconds,
    'hostProfileDocument.displayName': hostProfileDocumentDisplayName,
    'hostProfileDocument.roleTitle': hostProfileDocumentRoleTitle,
    'hostProfileDocument.status': hostProfileDocumentStatus,
    'hostProfileDocument.updatedAt._nanoseconds': hostProfileDocumentUpdatedAtNanoseconds,
    'hostProfileDocument.updatedAt._seconds': hostProfileDocumentUpdatedAtSeconds,
    'matchDocument.blockedAt._nanoseconds': matchDocumentBlockedAtNanoseconds,
    'matchDocument.blockedAt._seconds': matchDocumentBlockedAtSeconds,
    'matchDocument.blockedBy': matchDocumentBlockedBy,
    'matchDocument.clubId': matchDocumentClubId,
    'matchDocument.conversationType': matchDocumentConversationType,
    'matchDocument.createdAt._nanoseconds': matchDocumentCreatedAtNanoseconds,
    'matchDocument.createdAt._seconds': matchDocumentCreatedAtSeconds,
    'matchDocument.demoOpsCommand': matchDocumentDemoOpsCommand,
    'matchDocument.demoOpsId': matchDocumentDemoOpsId,
    'matchDocument.eventIds': matchDocumentEventIds,
    'matchDocument.lastMessageAt._nanoseconds': matchDocumentLastMessageAtNanoseconds,
    'matchDocument.lastMessageAt._seconds': matchDocumentLastMessageAtSeconds,
    'matchDocument.lastMessagePreview': matchDocumentLastMessagePreview,
    'matchDocument.lastMessageSenderId': matchDocumentLastMessageSenderId,
    'matchDocument.organizerId': matchDocumentOrganizerId,
    'matchDocument.participantIds': matchDocumentParticipantIds,
    'matchDocument.scenario': matchDocumentScenario,
    'matchDocument.seedPrefix': matchDocumentSeedPrefix,
    'matchDocument.status': matchDocumentStatus,
    'matchDocument.unreadCounts': matchDocumentUnreadCounts,
    'matchDocument.user1Id': matchDocumentUser1Id,
    'matchDocument.user2Id': matchDocumentUser2Id,
    'moderationFlagDocument.context': moderationFlagDocumentContext,
    'moderationFlagDocument.contextId': moderationFlagDocumentContextId,
    'moderationFlagDocument.createdAt._nanoseconds': moderationFlagDocumentCreatedAtNanoseconds,
    'moderationFlagDocument.createdAt._seconds': moderationFlagDocumentCreatedAtSeconds,
    'moderationFlagDocument.flagType': moderationFlagDocumentFlagType,
    'moderationFlagDocument.reviewedAt._nanoseconds': moderationFlagDocumentReviewedAtNanoseconds,
    'moderationFlagDocument.reviewedAt._seconds': moderationFlagDocumentReviewedAtSeconds,
    'moderationFlagDocument.source': moderationFlagDocumentSource,
    'moderationFlagDocument.status': moderationFlagDocumentStatus,
    'moderationFlagDocument.targetUserId': moderationFlagDocumentTargetUserId,
    'onboardingDraftDocument.countryCode': onboardingDraftDocumentCountryCode,
    'onboardingDraftDocument.dateOfBirth._nanoseconds': onboardingDraftDocumentDateOfBirthNanoseconds,
    'onboardingDraftDocument.dateOfBirth._seconds': onboardingDraftDocumentDateOfBirthSeconds,
    'onboardingDraftDocument.draftVersion': onboardingDraftDocumentDraftVersion,
    'onboardingDraftDocument.firstName': onboardingDraftDocumentFirstName,
    'onboardingDraftDocument.gender': onboardingDraftDocumentGender,
    'onboardingDraftDocument.instagramHandle': onboardingDraftDocumentInstagramHandle,
    'onboardingDraftDocument.lastName': onboardingDraftDocumentLastName,
    'onboardingDraftDocument.phoneNumber': onboardingDraftDocumentPhoneNumber,
    'onboardingDraftDocument.step': onboardingDraftDocumentStep,
    'organizerClaimRequestDocument.businessEmail': organizerClaimRequestDocumentBusinessEmail,
    'organizerClaimRequestDocument.businessPhone': organizerClaimRequestDocumentBusinessPhone,
    'organizerClaimRequestDocument.createdAt._nanoseconds': organizerClaimRequestDocumentCreatedAtNanoseconds,
    'organizerClaimRequestDocument.createdAt._seconds': organizerClaimRequestDocumentCreatedAtSeconds,
    'organizerClaimRequestDocument.decidedAt._nanoseconds': organizerClaimRequestDocumentDecidedAtNanoseconds,
    'organizerClaimRequestDocument.decidedAt._seconds': organizerClaimRequestDocumentDecidedAtSeconds,
    'organizerClaimRequestDocument.decidedByUid': organizerClaimRequestDocumentDecidedByUid,
    'organizerClaimRequestDocument.decisionReason': organizerClaimRequestDocumentDecisionReason,
    'organizerClaimRequestDocument.message': organizerClaimRequestDocumentMessage,
    'organizerClaimRequestDocument.organizerId': organizerClaimRequestDocumentOrganizerId,
    'organizerClaimRequestDocument.previousRequestId': organizerClaimRequestDocumentPreviousRequestId,
    'organizerClaimRequestDocument.proofUrls': organizerClaimRequestDocumentProofUrls,
    'organizerClaimRequestDocument.requesterName': organizerClaimRequestDocumentRequesterName,
    'organizerClaimRequestDocument.requesterRole': organizerClaimRequestDocumentRequesterRole,
    'organizerClaimRequestDocument.requesterUid': organizerClaimRequestDocumentRequesterUid,
    'organizerClaimRequestDocument.requestId': organizerClaimRequestDocumentRequestId,
    'organizerClaimRequestDocument.status': organizerClaimRequestDocumentStatus,
    'organizerClaimRequestDocument.updatedAt._nanoseconds': organizerClaimRequestDocumentUpdatedAtNanoseconds,
    'organizerClaimRequestDocument.updatedAt._seconds': organizerClaimRequestDocumentUpdatedAtSeconds,
    'organizerDocument.adminSearch.sortKey': organizerDocumentAdminSearchSortKey,
    'organizerDocument.adminSearch.tokens': organizerDocumentAdminSearchTokens,
    'organizerDocument.adminSearch.updatedAt._nanoseconds': organizerDocumentAdminSearchUpdatedAtNanoseconds,
    'organizerDocument.adminSearch.updatedAt._seconds': organizerDocumentAdminSearchUpdatedAtSeconds,
    'organizerDocument.adminSearch.updatedBySource': organizerDocumentAdminSearchUpdatedBySource,
    'organizerDocument.appVisibility': organizerDocumentAppVisibility,
    'organizerDocument.archived': organizerDocumentArchived,
    'organizerDocument.archivedAt._nanoseconds': organizerDocumentArchivedAtNanoseconds,
    'organizerDocument.archivedAt._seconds': organizerDocumentArchivedAtSeconds,
    'organizerDocument.archiveReason': organizerDocumentArchiveReason,
    'organizerDocument.area': organizerDocumentArea,
    'organizerDocument.cityName': organizerDocumentCityName,
    'organizerDocument.claim.claimHref': organizerDocumentClaimClaimHref,
    'organizerDocument.claim.lastClaimRequestId': organizerDocumentClaimLastClaimRequestId,
    'organizerDocument.claim.state': organizerDocumentClaimState,
    'organizerDocument.countryCode': organizerDocumentCountryCode,
    'organizerDocument.countryName': organizerDocumentCountryName,
    'organizerDocument.createdAt._nanoseconds': organizerDocumentCreatedAtNanoseconds,
    'organizerDocument.createdAt._seconds': organizerDocumentCreatedAtSeconds,
    'organizerDocument.demoOpsCommand': organizerDocumentDemoOpsCommand,
    'organizerDocument.demoOpsId': organizerDocumentDemoOpsId,
    'organizerDocument.description': organizerDocumentDescription,
    'organizerDocument.displayCategory': organizerDocumentDisplayCategory,
    'organizerDocument.email': organizerDocumentEmail,
    'organizerDocument.entityKind': organizerDocumentEntityKind,
    'organizerDocument.followerCount': organizerDocumentFollowerCount,
    'organizerDocument.hostAvatarUrl': organizerDocumentHostAvatarUrl,
    'organizerDocument.hostDefaults.eventPolicy.admissionPreset': organizerDocumentHostDefaultsEventPolicyAdmissionPreset,
    'organizerDocument.hostDefaults.eventPolicy.cancellationPolicyId': organizerDocumentHostDefaultsEventPolicyCancellationPolicyId,
    'organizerDocument.hostDefaults.eventPolicy.dynamicPricingMaxInPaise': organizerDocumentHostDefaultsEventPolicyDynamicPricingMaxInPaise,
    'organizerDocument.hostDefaults.eventPolicy.dynamicPricingStepInPaise': organizerDocumentHostDefaultsEventPolicyDynamicPricingStepInPaise,
    'organizerDocument.hostDefaults.eventPolicy.maxAge': organizerDocumentHostDefaultsEventPolicyMaxAge,
    'organizerDocument.hostDefaults.eventPolicy.maxMen': organizerDocumentHostDefaultsEventPolicyMaxMen,
    'organizerDocument.hostDefaults.eventPolicy.maxWomen': organizerDocumentHostDefaultsEventPolicyMaxWomen,
    'organizerDocument.hostDefaults.eventPolicy.minAge': organizerDocumentHostDefaultsEventPolicyMinAge,
    'organizerDocument.hostDefaults.eventSuccess.attendeePrompt': organizerDocumentHostDefaultsEventSuccessAttendeePrompt,
    'organizerDocument.hostDefaults.eventSuccess.hostGoal': organizerDocumentHostDefaultsEventSuccessHostGoal,
    'organizerDocument.hostDefaults.eventSuccess.playbookId': organizerDocumentHostDefaultsEventSuccessPlaybookId,
    'organizerDocument.hostDefaults.eventSuccess.questionnaireConfig.customTitle': organizerDocumentHostDefaultsEventSuccessQuestionnaireConfigCustomTitle,
    'organizerDocument.hostDefaults.eventSuccess.questionnaireConfig.templateId': organizerDocumentHostDefaultsEventSuccessQuestionnaireConfigTemplateId,
    'organizerDocument.hostDefaults.eventSuccess.structureConfig.maxPairMeetings': organizerDocumentHostDefaultsEventSuccessStructureConfigMaxPairMeetings,
    'organizerDocument.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds': organizerDocumentHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds,
    'organizerDocument.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes': organizerDocumentHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes,
    'organizerDocument.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy': organizerDocumentHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy,
    'organizerDocument.hostDefaults.eventSuccess.structureConfig.unitCount': organizerDocumentHostDefaultsEventSuccessStructureConfigUnitCount,
    'organizerDocument.hostDefaults.eventSuccess.structureConfig.unitKind': organizerDocumentHostDefaultsEventSuccessStructureConfigUnitKind,
    'organizerDocument.hostDefaults.eventSuccess.structureConfig.unitSize': organizerDocumentHostDefaultsEventSuccessStructureConfigUnitSize,
    'organizerDocument.hostDefaults.primaryActivityKind': organizerDocumentHostDefaultsPrimaryActivityKind,
    'organizerDocument.hostName': organizerDocumentHostName,
    'organizerDocument.hostProfiles': organizerDocumentHostProfiles,
    'organizerDocument.hostUserId': organizerDocumentHostUserId,
    'organizerDocument.hostUserIds': organizerDocumentHostUserIds,
    'organizerDocument.imageUrl': organizerDocumentImageUrl,
    'organizerDocument.instagramHandle': organizerDocumentInstagramHandle,
    'organizerDocument.location': organizerDocumentLocation,
    'organizerDocument.locationCityId': organizerDocumentLocationCityId,
    'organizerDocument.locationMarketId': organizerDocumentLocationMarketId,
    'organizerDocument.logoPhoto.createdAt._nanoseconds': organizerDocumentLogoPhotoCreatedAtNanoseconds,
    'organizerDocument.logoPhoto.createdAt._seconds': organizerDocumentLogoPhotoCreatedAtSeconds,
    'organizerDocument.logoPhoto.id': organizerDocumentLogoPhotoId,
    'organizerDocument.logoPhoto.moderation.reason': organizerDocumentLogoPhotoModerationReason,
    'organizerDocument.logoPhoto.moderation.reviewedAt._nanoseconds': organizerDocumentLogoPhotoModerationReviewedAtNanoseconds,
    'organizerDocument.logoPhoto.moderation.reviewedAt._seconds': organizerDocumentLogoPhotoModerationReviewedAtSeconds,
    'organizerDocument.logoPhoto.moderation.status': organizerDocumentLogoPhotoModerationStatus,
    'organizerDocument.logoPhoto.position': organizerDocumentLogoPhotoPosition,
    'organizerDocument.logoPhoto.storagePath': organizerDocumentLogoPhotoStoragePath,
    'organizerDocument.logoPhoto.thumbnailStoragePath': organizerDocumentLogoPhotoThumbnailStoragePath,
    'organizerDocument.logoPhoto.thumbnailUrl': organizerDocumentLogoPhotoThumbnailUrl,
    'organizerDocument.logoPhoto.updatedAt._nanoseconds': organizerDocumentLogoPhotoUpdatedAtNanoseconds,
    'organizerDocument.logoPhoto.updatedAt._seconds': organizerDocumentLogoPhotoUpdatedAtSeconds,
    'organizerDocument.logoPhoto.url': organizerDocumentLogoPhotoUrl,
    'organizerDocument.memberCount': organizerDocumentMemberCount,
    'organizerDocument.name': organizerDocumentName,
    'organizerDocument.nextEventAt._nanoseconds': organizerDocumentNextEventAtNanoseconds,
    'organizerDocument.nextEventAt._seconds': organizerDocumentNextEventAtSeconds,
    'organizerDocument.nextEventLabel': organizerDocumentNextEventLabel,
    'organizerDocument.organizerPhotos': organizerDocumentOrganizerPhotos,
    'organizerDocument.organizerType': organizerDocumentOrganizerType,
    'organizerDocument.organizerTypeUpdatedAt._nanoseconds': organizerDocumentOrganizerTypeUpdatedAtNanoseconds,
    'organizerDocument.organizerTypeUpdatedAt._seconds': organizerDocumentOrganizerTypeUpdatedAtSeconds,
    'organizerDocument.organizerTypeUpdatedByUid': organizerDocumentOrganizerTypeUpdatedByUid,
    'organizerDocument.ownership.claimedAt._nanoseconds': organizerDocumentOwnershipClaimedAtNanoseconds,
    'organizerDocument.ownership.claimedAt._seconds': organizerDocumentOwnershipClaimedAtSeconds,
    'organizerDocument.ownership.claimedByUid': organizerDocumentOwnershipClaimedByUid,
    'organizerDocument.ownership.hostUserIds': organizerDocumentOwnershipHostUserIds,
    'organizerDocument.ownership.ownerUserId': organizerDocumentOwnershipOwnerUserId,
    'organizerDocument.ownership.primaryHostUserId': organizerDocumentOwnershipPrimaryHostUserId,
    'organizerDocument.ownership.state': organizerDocumentOwnershipState,
    'organizerDocument.ownerUserId': organizerDocumentOwnerUserId,
    'organizerDocument.phoneNumber': organizerDocumentPhoneNumber,
    'organizerDocument.profileImageUrl': organizerDocumentProfileImageUrl,
    'organizerDocument.provenance.lastVerifiedAt._nanoseconds': organizerDocumentProvenanceLastVerifiedAtNanoseconds,
    'organizerDocument.provenance.lastVerifiedAt._seconds': organizerDocumentProvenanceLastVerifiedAtSeconds,
    'organizerDocument.provenance.origin': organizerDocumentProvenanceOrigin,
    'organizerDocument.provenance.sourceConfidence': organizerDocumentProvenanceSourceConfidence,
    'organizerDocument.provenance.verificationStatus': organizerDocumentProvenanceVerificationStatus,
    'organizerDocument.publicCategoryLabel': organizerDocumentPublicCategoryLabel,
    'organizerDocument.publicPage.canonicalPath': organizerDocumentPublicPageCanonicalPath,
    'organizerDocument.publicPage.citySlug': organizerDocumentPublicPageCitySlug,
    'organizerDocument.publicPage.indexReview.checklist.cadenceVerified': organizerDocumentPublicPageIndexReviewChecklistCadenceVerified,
    'organizerDocument.publicPage.indexReview.checklist.mediaRightsVerified': organizerDocumentPublicPageIndexReviewChecklistMediaRightsVerified,
    'organizerDocument.publicPage.indexReview.checklist.ownerContactVerified': organizerDocumentPublicPageIndexReviewChecklistOwnerContactVerified,
    'organizerDocument.publicPage.indexReview.checklist.sourceEvidenceVerified': organizerDocumentPublicPageIndexReviewChecklistSourceEvidenceVerified,
    'organizerDocument.publicPage.indexReview.indexStatus': organizerDocumentPublicPageIndexReviewIndexStatus,
    'organizerDocument.publicPage.indexReview.reviewedAt._nanoseconds': organizerDocumentPublicPageIndexReviewReviewedAtNanoseconds,
    'organizerDocument.publicPage.indexReview.reviewedAt._seconds': organizerDocumentPublicPageIndexReviewReviewedAtSeconds,
    'organizerDocument.publicPage.indexReview.reviewedByUid': organizerDocumentPublicPageIndexReviewReviewedByUid,
    'organizerDocument.publicPage.indexReview.reviewNote': organizerDocumentPublicPageIndexReviewReviewNote,
    'organizerDocument.publicPage.indexStatus': organizerDocumentPublicPageIndexStatus,
    'organizerDocument.publicPage.lastRenderedAt._nanoseconds': organizerDocumentPublicPageLastRenderedAtNanoseconds,
    'organizerDocument.publicPage.lastRenderedAt._seconds': organizerDocumentPublicPageLastRenderedAtSeconds,
    'organizerDocument.publicPage.publishStatus': organizerDocumentPublicPagePublishStatus,
    'organizerDocument.publicPage.robots': organizerDocumentPublicPageRobots,
    'organizerDocument.publicPage.seoDescription': organizerDocumentPublicPageSeoDescription,
    'organizerDocument.publicPage.seoTitle': organizerDocumentPublicPageSeoTitle,
    'organizerDocument.publicPage.slug': organizerDocumentPublicPageSlug,
    'organizerDocument.publicProfile.headline': organizerDocumentPublicProfileHeadline,
    'organizerDocument.publicProfile.sourceSummary': organizerDocumentPublicProfileSourceSummary,
    'organizerDocument.publicProfile.summary': organizerDocumentPublicProfileSummary,
    'organizerDocument.rating': organizerDocumentRating,
    'organizerDocument.regionName': organizerDocumentRegionName,
    'organizerDocument.reviewCount': organizerDocumentReviewCount,
    'organizerDocument.scenario': organizerDocumentScenario,
    'organizerDocument.seedPrefix': organizerDocumentSeedPrefix,
    'organizerDocument.status': organizerDocumentStatus,
    'organizerDocument.tags': organizerDocumentTags,
    'organizerDocument.verifiedReviewCount': organizerDocumentVerifiedReviewCount,
    'organizerEventCandidateReviewDecisionDocument.candidateId': organizerEventCandidateReviewDecisionDocumentCandidateId,
    'organizerEventCandidateReviewDecisionDocument.checklist.dedupeReviewed': organizerEventCandidateReviewDecisionDocumentChecklistDedupeReviewed,
    'organizerEventCandidateReviewDecisionDocument.checklist.identityReviewed': organizerEventCandidateReviewDecisionDocumentChecklistIdentityReviewed,
    'organizerEventCandidateReviewDecisionDocument.checklist.importPolicyAcknowledged': organizerEventCandidateReviewDecisionDocumentChecklistImportPolicyAcknowledged,
    'organizerEventCandidateReviewDecisionDocument.checklist.locationReviewed': organizerEventCandidateReviewDecisionDocumentChecklistLocationReviewed,
    'organizerEventCandidateReviewDecisionDocument.checklist.ownerSafeCopyReviewed': organizerEventCandidateReviewDecisionDocumentChecklistOwnerSafeCopyReviewed,
    'organizerEventCandidateReviewDecisionDocument.checklist.sourceEventReviewed': organizerEventCandidateReviewDecisionDocumentChecklistSourceEventReviewed,
    'organizerEventCandidateReviewDecisionDocument.checklist.timeReviewed': organizerEventCandidateReviewDecisionDocumentChecklistTimeReviewed,
    'organizerEventCandidateReviewDecisionDocument.decision': organizerEventCandidateReviewDecisionDocumentDecision,
    'organizerEventCandidateReviewDecisionDocument.decisionId': organizerEventCandidateReviewDecisionDocumentDecisionId,
    'organizerEventCandidateReviewDecisionDocument.decisionStatus': organizerEventCandidateReviewDecisionDocumentDecisionStatus,
    'organizerEventCandidateReviewDecisionDocument.importState': organizerEventCandidateReviewDecisionDocumentImportState,
    'organizerEventCandidateReviewDecisionDocument.note': organizerEventCandidateReviewDecisionDocumentNote,
    'organizerEventCandidateReviewDecisionDocument.reviewedAt._nanoseconds': organizerEventCandidateReviewDecisionDocumentReviewedAtNanoseconds,
    'organizerEventCandidateReviewDecisionDocument.reviewedAt._seconds': organizerEventCandidateReviewDecisionDocumentReviewedAtSeconds,
    'organizerEventCandidateReviewDecisionDocument.reviewedByUid': organizerEventCandidateReviewDecisionDocumentReviewedByUid,
    'organizerEventCandidateReviewDecisionDocument.schemaVersion': organizerEventCandidateReviewDecisionDocumentSchemaVersion,
    'organizerEventCandidateReviewDecisionDocument.updatedAt._nanoseconds': organizerEventCandidateReviewDecisionDocumentUpdatedAtNanoseconds,
    'organizerEventCandidateReviewDecisionDocument.updatedAt._seconds': organizerEventCandidateReviewDecisionDocumentUpdatedAtSeconds,
    'organizerEventLocationResolutionDecisionDocument.candidateId': organizerEventLocationResolutionDecisionDocumentCandidateId,
    'organizerEventLocationResolutionDecisionDocument.checklist.coordinatesReviewed': organizerEventLocationResolutionDecisionDocumentChecklistCoordinatesReviewed,
    'organizerEventLocationResolutionDecisionDocument.checklist.importSafetyReviewed': organizerEventLocationResolutionDecisionDocumentChecklistImportSafetyReviewed,
    'organizerEventLocationResolutionDecisionDocument.checklist.placeIdentityReviewed': organizerEventLocationResolutionDecisionDocumentChecklistPlaceIdentityReviewed,
    'organizerEventLocationResolutionDecisionDocument.checklist.sourceLocationReviewed': organizerEventLocationResolutionDecisionDocumentChecklistSourceLocationReviewed,
    'organizerEventLocationResolutionDecisionDocument.location.address': organizerEventLocationResolutionDecisionDocumentLocationAddress,
    'organizerEventLocationResolutionDecisionDocument.location.latitude': organizerEventLocationResolutionDecisionDocumentLocationLatitude,
    'organizerEventLocationResolutionDecisionDocument.location.longitude': organizerEventLocationResolutionDecisionDocumentLocationLongitude,
    'organizerEventLocationResolutionDecisionDocument.location.name': organizerEventLocationResolutionDecisionDocumentLocationName,
    'organizerEventLocationResolutionDecisionDocument.location.notes': organizerEventLocationResolutionDecisionDocumentLocationNotes,
    'organizerEventLocationResolutionDecisionDocument.location.placeId': organizerEventLocationResolutionDecisionDocumentLocationPlaceId,
    'organizerEventLocationResolutionDecisionDocument.note': organizerEventLocationResolutionDecisionDocumentNote,
    'organizerEventLocationResolutionDecisionDocument.resolutionId': organizerEventLocationResolutionDecisionDocumentResolutionId,
    'organizerEventLocationResolutionDecisionDocument.resolutionStatus': organizerEventLocationResolutionDecisionDocumentResolutionStatus,
    'organizerEventLocationResolutionDecisionDocument.reviewedAt._nanoseconds': organizerEventLocationResolutionDecisionDocumentReviewedAtNanoseconds,
    'organizerEventLocationResolutionDecisionDocument.reviewedAt._seconds': organizerEventLocationResolutionDecisionDocumentReviewedAtSeconds,
    'organizerEventLocationResolutionDecisionDocument.reviewedByUid': organizerEventLocationResolutionDecisionDocumentReviewedByUid,
    'organizerEventLocationResolutionDecisionDocument.schemaVersion': organizerEventLocationResolutionDecisionDocumentSchemaVersion,
    'organizerEventLocationResolutionDecisionDocument.updatedAt._nanoseconds': organizerEventLocationResolutionDecisionDocumentUpdatedAtNanoseconds,
    'organizerEventLocationResolutionDecisionDocument.updatedAt._seconds': organizerEventLocationResolutionDecisionDocumentUpdatedAtSeconds,
    'organizerFollowDocument.followedAt._nanoseconds': organizerFollowDocumentFollowedAtNanoseconds,
    'organizerFollowDocument.followedAt._seconds': organizerFollowDocumentFollowedAtSeconds,
    'organizerFollowDocument.organizerId': organizerFollowDocumentOrganizerId,
    'organizerFollowDocument.pushNotificationsEnabled': organizerFollowDocumentPushNotificationsEnabled,
    'organizerFollowDocument.status': organizerFollowDocumentStatus,
    'organizerFollowDocument.uid': organizerFollowDocumentUid,
    'organizerFollowDocument.unfollowedAt._nanoseconds': organizerFollowDocumentUnfollowedAtNanoseconds,
    'organizerFollowDocument.unfollowedAt._seconds': organizerFollowDocumentUnfollowedAtSeconds,
    'organizerIntakeCurationDecisionDocument.decision': organizerIntakeCurationDecisionDocumentDecision,
    'organizerIntakeCurationDecisionDocument.entityId': organizerIntakeCurationDecisionDocumentEntityId,
    'organizerIntakeCurationDecisionDocument.newEntityId': organizerIntakeCurationDecisionDocumentNewEntityId,
    'organizerIntakeCurationDecisionDocument.operationId': organizerIntakeCurationDecisionDocumentOperationId,
    'organizerIntakeCurationDecisionDocument.operationStatus': organizerIntakeCurationDecisionDocumentOperationStatus,
    'organizerIntakeCurationDecisionDocument.operationType': organizerIntakeCurationDecisionDocumentOperationType,
    'organizerIntakeCurationDecisionDocument.reason': organizerIntakeCurationDecisionDocumentReason,
    'organizerIntakeCurationDecisionDocument.reviewedAt._nanoseconds': organizerIntakeCurationDecisionDocumentReviewedAtNanoseconds,
    'organizerIntakeCurationDecisionDocument.reviewedAt._seconds': organizerIntakeCurationDecisionDocumentReviewedAtSeconds,
    'organizerIntakeCurationDecisionDocument.reviewedByUid': organizerIntakeCurationDecisionDocumentReviewedByUid,
    'organizerIntakeCurationDecisionDocument.schemaVersion': organizerIntakeCurationDecisionDocumentSchemaVersion,
    'organizerIntakeCurationDecisionDocument.sourceCandidateId': organizerIntakeCurationDecisionDocumentSourceCandidateId,
    'organizerIntakeCurationDecisionDocument.sourceEntityId': organizerIntakeCurationDecisionDocumentSourceEntityId,
    'organizerIntakeCurationDecisionDocument.surface.confidence.city': organizerIntakeCurationDecisionDocumentSurfaceConfidenceCity,
    'organizerIntakeCurationDecisionDocument.surface.confidence.entityMatch': organizerIntakeCurationDecisionDocumentSurfaceConfidenceEntityMatch,
    'organizerIntakeCurationDecisionDocument.surface.confidence.ownership': organizerIntakeCurationDecisionDocumentSurfaceConfidenceOwnership,
    'organizerIntakeCurationDecisionDocument.surface.crawl.eventDiscoveryStatus': organizerIntakeCurationDecisionDocumentSurfaceCrawlEventDiscoveryStatus,
    'organizerIntakeCurationDecisionDocument.surface.crawl.policy': organizerIntakeCurationDecisionDocumentSurfaceCrawlPolicy,
    'organizerIntakeCurationDecisionDocument.surface.crawl.supportsEventExtraction': organizerIntakeCurationDecisionDocumentSurfaceCrawlSupportsEventExtraction,
    'organizerIntakeCurationDecisionDocument.surface.evidenceRefs': organizerIntakeCurationDecisionDocumentSurfaceEvidenceRefs,
    'organizerIntakeCurationDecisionDocument.surface.normalizedKey': organizerIntakeCurationDecisionDocumentSurfaceNormalizedKey,
    'organizerIntakeCurationDecisionDocument.surface.notes': organizerIntakeCurationDecisionDocumentSurfaceNotes,
    'organizerIntakeCurationDecisionDocument.surface.platform': organizerIntakeCurationDecisionDocumentSurfacePlatform,
    'organizerIntakeCurationDecisionDocument.surface.role': organizerIntakeCurationDecisionDocumentSurfaceRole,
    'organizerIntakeCurationDecisionDocument.surface.status': organizerIntakeCurationDecisionDocumentSurfaceStatus,
    'organizerIntakeCurationDecisionDocument.surface.surfaceId': organizerIntakeCurationDecisionDocumentSurfaceSurfaceId,
    'organizerIntakeCurationDecisionDocument.surface.surfaceKind': organizerIntakeCurationDecisionDocumentSurfaceSurfaceKind,
    'organizerIntakeCurationDecisionDocument.surfaceId': organizerIntakeCurationDecisionDocumentSurfaceId,
    'organizerIntakeCurationDecisionDocument.targetEntityId': organizerIntakeCurationDecisionDocumentTargetEntityId,
    'organizerIntakeCurationDecisionDocument.updatedAt._nanoseconds': organizerIntakeCurationDecisionDocumentUpdatedAtNanoseconds,
    'organizerIntakeCurationDecisionDocument.updatedAt._seconds': organizerIntakeCurationDecisionDocumentUpdatedAtSeconds,
    'organizerIntakeReviewDecisionDocument.appVisibility': organizerIntakeReviewDecisionDocumentAppVisibility,
    'organizerIntakeReviewDecisionDocument.checklist.crawlDisabledReviewed': organizerIntakeReviewDecisionDocumentChecklistCrawlDisabledReviewed,
    'organizerIntakeReviewDecisionDocument.checklist.identityReviewed': organizerIntakeReviewDecisionDocumentChecklistIdentityReviewed,
    'organizerIntakeReviewDecisionDocument.checklist.marketScopeReviewed': organizerIntakeReviewDecisionDocumentChecklistMarketScopeReviewed,
    'organizerIntakeReviewDecisionDocument.checklist.mediaRightsReviewed': organizerIntakeReviewDecisionDocumentChecklistMediaRightsReviewed,
    'organizerIntakeReviewDecisionDocument.checklist.ownerSafeCopyReviewed': organizerIntakeReviewDecisionDocumentChecklistOwnerSafeCopyReviewed,
    'organizerIntakeReviewDecisionDocument.checklist.surfaceInventoryReviewed': organizerIntakeReviewDecisionDocumentChecklistSurfaceInventoryReviewed,
    'organizerIntakeReviewDecisionDocument.decision': organizerIntakeReviewDecisionDocumentDecision,
    'organizerIntakeReviewDecisionDocument.decisionStatus': organizerIntakeReviewDecisionDocumentDecisionStatus,
    'organizerIntakeReviewDecisionDocument.entityId': organizerIntakeReviewDecisionDocumentEntityId,
    'organizerIntakeReviewDecisionDocument.note': organizerIntakeReviewDecisionDocumentNote,
    'organizerIntakeReviewDecisionDocument.projectionState': organizerIntakeReviewDecisionDocumentProjectionState,
    'organizerIntakeReviewDecisionDocument.reviewedAt._nanoseconds': organizerIntakeReviewDecisionDocumentReviewedAtNanoseconds,
    'organizerIntakeReviewDecisionDocument.reviewedAt._seconds': organizerIntakeReviewDecisionDocumentReviewedAtSeconds,
    'organizerIntakeReviewDecisionDocument.reviewedByUid': organizerIntakeReviewDecisionDocumentReviewedByUid,
    'organizerIntakeReviewDecisionDocument.schemaVersion': organizerIntakeReviewDecisionDocumentSchemaVersion,
    'organizerIntakeReviewDecisionDocument.updatedAt._nanoseconds': organizerIntakeReviewDecisionDocumentUpdatedAtNanoseconds,
    'organizerIntakeReviewDecisionDocument.updatedAt._seconds': organizerIntakeReviewDecisionDocumentUpdatedAtSeconds,
    'organizerPolicyGapReviewDecisionDocument.checklist.behaviorStillDisabledAcknowledged': organizerPolicyGapReviewDecisionDocumentChecklistBehaviorStillDisabledAcknowledged,
    'organizerPolicyGapReviewDecisionDocument.checklist.costAndSafetyReviewed': organizerPolicyGapReviewDecisionDocumentChecklistCostAndSafetyReviewed,
    'organizerPolicyGapReviewDecisionDocument.checklist.implementationOwnerReviewed': organizerPolicyGapReviewDecisionDocumentChecklistImplementationOwnerReviewed,
    'organizerPolicyGapReviewDecisionDocument.checklist.requiredInputsReviewed': organizerPolicyGapReviewDecisionDocumentChecklistRequiredInputsReviewed,
    'organizerPolicyGapReviewDecisionDocument.decision': organizerPolicyGapReviewDecisionDocumentDecision,
    'organizerPolicyGapReviewDecisionDocument.decisionId': organizerPolicyGapReviewDecisionDocumentDecisionId,
    'organizerPolicyGapReviewDecisionDocument.decisionStatus': organizerPolicyGapReviewDecisionDocumentDecisionStatus,
    'organizerPolicyGapReviewDecisionDocument.gapId': organizerPolicyGapReviewDecisionDocumentGapId,
    'organizerPolicyGapReviewDecisionDocument.note': organizerPolicyGapReviewDecisionDocumentNote,
    'organizerPolicyGapReviewDecisionDocument.operationalState': organizerPolicyGapReviewDecisionDocumentOperationalState,
    'organizerPolicyGapReviewDecisionDocument.requiredInputsReviewed': organizerPolicyGapReviewDecisionDocumentRequiredInputsReviewed,
    'organizerPolicyGapReviewDecisionDocument.reviewedAt._nanoseconds': organizerPolicyGapReviewDecisionDocumentReviewedAtNanoseconds,
    'organizerPolicyGapReviewDecisionDocument.reviewedAt._seconds': organizerPolicyGapReviewDecisionDocumentReviewedAtSeconds,
    'organizerPolicyGapReviewDecisionDocument.reviewedByUid': organizerPolicyGapReviewDecisionDocumentReviewedByUid,
    'organizerPolicyGapReviewDecisionDocument.schemaVersion': organizerPolicyGapReviewDecisionDocumentSchemaVersion,
    'organizerPolicyGapReviewDecisionDocument.updatedAt._nanoseconds': organizerPolicyGapReviewDecisionDocumentUpdatedAtNanoseconds,
    'organizerPolicyGapReviewDecisionDocument.updatedAt._seconds': organizerPolicyGapReviewDecisionDocumentUpdatedAtSeconds,
    'organizerPostDocument.audience': organizerPostDocumentAudience,
    'organizerPostDocument.authorUid': organizerPostDocumentAuthorUid,
    'organizerPostDocument.createdAt._nanoseconds': organizerPostDocumentCreatedAtNanoseconds,
    'organizerPostDocument.createdAt._seconds': organizerPostDocumentCreatedAtSeconds,
    'organizerPostDocument.eventId': organizerPostDocumentEventId,
    'organizerPostDocument.photoPath': organizerPostDocumentPhotoPath,
    'organizerPostDocument.status': organizerPostDocumentStatus,
    'organizerPostDocument.text': organizerPostDocumentText,
    'organizerScheduleLockDocument.endTimeMillis': organizerScheduleLockDocumentEndTimeMillis,
    'organizerScheduleLockDocument.eventId': organizerScheduleLockDocumentEventId,
    'organizerScheduleLockDocument.organizerId': organizerScheduleLockDocumentOrganizerId,
    'organizerScheduleLockDocument.ownerId': organizerScheduleLockDocumentOwnerId,
    'organizerScheduleLockDocument.ownerType': organizerScheduleLockDocumentOwnerType,
    'organizerScheduleLockDocument.slot': organizerScheduleLockDocumentSlot,
    'organizerScheduleLockDocument.startTimeMillis': organizerScheduleLockDocumentStartTimeMillis,
    'organizerTeamMembershipDocument.createdAt._nanoseconds': organizerTeamMembershipDocumentCreatedAtNanoseconds,
    'organizerTeamMembershipDocument.createdAt._seconds': organizerTeamMembershipDocumentCreatedAtSeconds,
    'organizerTeamMembershipDocument.organizerId': organizerTeamMembershipDocumentOrganizerId,
    'organizerTeamMembershipDocument.removedAt._nanoseconds': organizerTeamMembershipDocumentRemovedAtNanoseconds,
    'organizerTeamMembershipDocument.removedAt._seconds': organizerTeamMembershipDocumentRemovedAtSeconds,
    'organizerTeamMembershipDocument.role': organizerTeamMembershipDocumentRole,
    'organizerTeamMembershipDocument.status': organizerTeamMembershipDocumentStatus,
    'organizerTeamMembershipDocument.uid': organizerTeamMembershipDocumentUid,
    'paymentDocument.amount': paymentDocumentAmount,
    'paymentDocument.amountMinor': paymentDocumentAmountMinor,
    'paymentDocument.applicationFeeAmount': paymentDocumentApplicationFeeAmount,
    'paymentDocument.checkoutSessionId': paymentDocumentCheckoutSessionId,
    'paymentDocument.createdAt._nanoseconds': paymentDocumentCreatedAtNanoseconds,
    'paymentDocument.createdAt._seconds': paymentDocumentCreatedAtSeconds,
    'paymentDocument.currency': paymentDocumentCurrency,
    'paymentDocument.demoOpsCommand': paymentDocumentDemoOpsCommand,
    'paymentDocument.demoOpsId': paymentDocumentDemoOpsId,
    'paymentDocument.eventId': paymentDocumentEventId,
    'paymentDocument.hostUserId': paymentDocumentHostUserId,
    'paymentDocument.inviteLinkId': paymentDocumentInviteLinkId,
    'paymentDocument.inviteSource': paymentDocumentInviteSource,
    'paymentDocument.orderId': paymentDocumentOrderId,
    'paymentDocument.paymentId': paymentDocumentPaymentId,
    'paymentDocument.provider': paymentDocumentProvider,
    'paymentDocument.providerPaymentId': paymentDocumentProviderPaymentId,
    'paymentDocument.scenario': paymentDocumentScenario,
    'paymentDocument.seedPrefix': paymentDocumentSeedPrefix,
    'paymentDocument.signUpFailed': paymentDocumentSignUpFailed,
    'paymentDocument.status': paymentDocumentStatus,
    'paymentDocument.stripeAccountId': paymentDocumentStripeAccountId,
    'paymentDocument.userId': paymentDocumentUserId,
    'publicProfileDocument.activityPreferences.running.paceMaxSecsPerKm': publicProfileDocumentActivityPreferencesRunningPaceMaxSecsPerKm,
    'publicProfileDocument.activityPreferences.running.paceMinSecsPerKm': publicProfileDocumentActivityPreferencesRunningPaceMinSecsPerKm,
    'publicProfileDocument.activityPreferences.running.preferredDistances': publicProfileDocumentActivityPreferencesRunningPreferredDistances,
    'publicProfileDocument.activityPreferences.running.preferredRunTimes': publicProfileDocumentActivityPreferencesRunningPreferredRunTimes,
    'publicProfileDocument.activityPreferences.running.runningReasons': publicProfileDocumentActivityPreferencesRunningRunningReasons,
    'publicProfileDocument.activityPreferences.running.version': publicProfileDocumentActivityPreferencesRunningVersion,
    'publicProfileDocument.age': publicProfileDocumentAge,
    'publicProfileDocument.children': publicProfileDocumentChildren,
    'publicProfileDocument.city': publicProfileDocumentCity,
    'publicProfileDocument.company': publicProfileDocumentCompany,
    'publicProfileDocument.demoOpsCommand': publicProfileDocumentDemoOpsCommand,
    'publicProfileDocument.demoOpsId': publicProfileDocumentDemoOpsId,
    'publicProfileDocument.diet': publicProfileDocumentDiet,
    'publicProfileDocument.drinking': publicProfileDocumentDrinking,
    'publicProfileDocument.education': publicProfileDocumentEducation,
    'publicProfileDocument.gender': publicProfileDocumentGender,
    'publicProfileDocument.height': publicProfileDocumentHeight,
    'publicProfileDocument.name': publicProfileDocumentName,
    'publicProfileDocument.occupation': publicProfileDocumentOccupation,
    'publicProfileDocument.profilePhotos': publicProfileDocumentProfilePhotos,
    'publicProfileDocument.profilePrompts': publicProfileDocumentProfilePrompts,
    'publicProfileDocument.relationshipGoal': publicProfileDocumentRelationshipGoal,
    'publicProfileDocument.religion': publicProfileDocumentReligion,
    'publicProfileDocument.scenario': publicProfileDocumentScenario,
    'publicProfileDocument.seedPrefix': publicProfileDocumentSeedPrefix,
    'publicProfileDocument.smoking': publicProfileDocumentSmoking,
    'publicProfileDocument.workout': publicProfileDocumentWorkout,
    'publicRouteReservationDocument.citySlug': publicRouteReservationDocumentCitySlug,
    'publicRouteReservationDocument.createdAt._nanoseconds': publicRouteReservationDocumentCreatedAtNanoseconds,
    'publicRouteReservationDocument.createdAt._seconds': publicRouteReservationDocumentCreatedAtSeconds,
    'publicRouteReservationDocument.lastVerifiedAt._nanoseconds': publicRouteReservationDocumentLastVerifiedAtNanoseconds,
    'publicRouteReservationDocument.lastVerifiedAt._seconds': publicRouteReservationDocumentLastVerifiedAtSeconds,
    'publicRouteReservationDocument.lastVerifiedByUid': publicRouteReservationDocumentLastVerifiedByUid,
    'publicRouteReservationDocument.lastVerifiedSource': publicRouteReservationDocumentLastVerifiedSource,
    'publicRouteReservationDocument.ownerCollection': publicRouteReservationDocumentOwnerCollection,
    'publicRouteReservationDocument.ownerId': publicRouteReservationDocumentOwnerId,
    'publicRouteReservationDocument.ownerType': publicRouteReservationDocumentOwnerType,
    'publicRouteReservationDocument.releasedAt._nanoseconds': publicRouteReservationDocumentReleasedAtNanoseconds,
    'publicRouteReservationDocument.releasedAt._seconds': publicRouteReservationDocumentReleasedAtSeconds,
    'publicRouteReservationDocument.releasedByUid': publicRouteReservationDocumentReleasedByUid,
    'publicRouteReservationDocument.replacementRoutePath': publicRouteReservationDocumentReplacementRoutePath,
    'publicRouteReservationDocument.routeKey': publicRouteReservationDocumentRouteKey,
    'publicRouteReservationDocument.routeKind': publicRouteReservationDocumentRouteKind,
    'publicRouteReservationDocument.routePath': publicRouteReservationDocumentRoutePath,
    'publicRouteReservationDocument.routeSegments': publicRouteReservationDocumentRouteSegments,
    'publicRouteReservationDocument.slug': publicRouteReservationDocumentSlug,
    'publicRouteReservationDocument.status': publicRouteReservationDocumentStatus,
    'publicRouteReservationDocument.targetPath': publicRouteReservationDocumentTargetPath,
    'publicRouteReservationDocument.updatedAt._nanoseconds': publicRouteReservationDocumentUpdatedAtNanoseconds,
    'publicRouteReservationDocument.updatedAt._seconds': publicRouteReservationDocumentUpdatedAtSeconds,
    'rateLimitDocument.action': rateLimitDocumentAction,
    'rateLimitDocument.count': rateLimitDocumentCount,
    'rateLimitDocument.expiresAt._nanoseconds': rateLimitDocumentExpiresAtNanoseconds,
    'rateLimitDocument.expiresAt._seconds': rateLimitDocumentExpiresAtSeconds,
    'rateLimitDocument.uid': rateLimitDocumentUid,
    'rateLimitDocument.windowKey': rateLimitDocumentWindowKey,
    'razorpayPendingOrderDocument.amountInPaise': razorpayPendingOrderDocumentAmountInPaise,
    'razorpayPendingOrderDocument.createdAt._nanoseconds': razorpayPendingOrderDocumentCreatedAtNanoseconds,
    'razorpayPendingOrderDocument.createdAt._seconds': razorpayPendingOrderDocumentCreatedAtSeconds,
    'razorpayPendingOrderDocument.currency': razorpayPendingOrderDocumentCurrency,
    'razorpayPendingOrderDocument.eventId': razorpayPendingOrderDocumentEventId,
    'razorpayPendingOrderDocument.orderId': razorpayPendingOrderDocumentOrderId,
    'razorpayPendingOrderDocument.provider': razorpayPendingOrderDocumentProvider,
    'razorpayPendingOrderDocument.status': razorpayPendingOrderDocumentStatus,
    'razorpayPendingOrderDocument.updatedAt._nanoseconds': razorpayPendingOrderDocumentUpdatedAtNanoseconds,
    'razorpayPendingOrderDocument.updatedAt._seconds': razorpayPendingOrderDocumentUpdatedAtSeconds,
    'razorpayPendingOrderDocument.userId': razorpayPendingOrderDocumentUserId,
    'reportDocument.contextId': reportDocumentContextId,
    'reportDocument.createdAt._nanoseconds': reportDocumentCreatedAtNanoseconds,
    'reportDocument.createdAt._seconds': reportDocumentCreatedAtSeconds,
    'reportDocument.notes': reportDocumentNotes,
    'reportDocument.reasonCode': reportDocumentReasonCode,
    'reportDocument.reporterUserId': reportDocumentReporterUserId,
    'reportDocument.source': reportDocumentSource,
    'reportDocument.status': reportDocumentStatus,
    'reportDocument.targetUserId': reportDocumentTargetUserId,
    'reviewDocument.clubId': reviewDocumentClubId,
    'reviewDocument.comment': reviewDocumentComment,
    'reviewDocument.createdAt._nanoseconds': reviewDocumentCreatedAtNanoseconds,
    'reviewDocument.createdAt._seconds': reviewDocumentCreatedAtSeconds,
    'reviewDocument.demoOpsCommand': reviewDocumentDemoOpsCommand,
    'reviewDocument.demoOpsId': reviewDocumentDemoOpsId,
    'reviewDocument.eventId': reviewDocumentEventId,
    'reviewDocument.moderationStatus': reviewDocumentModerationStatus,
    'reviewDocument.organizerId': reviewDocumentOrganizerId,
    'reviewDocument.ownerResponse.createdAt._nanoseconds': reviewDocumentOwnerResponseCreatedAtNanoseconds,
    'reviewDocument.ownerResponse.createdAt._seconds': reviewDocumentOwnerResponseCreatedAtSeconds,
    'reviewDocument.ownerResponse.hostName': reviewDocumentOwnerResponseHostName,
    'reviewDocument.ownerResponse.hostUserId': reviewDocumentOwnerResponseHostUserId,
    'reviewDocument.ownerResponse.message': reviewDocumentOwnerResponseMessage,
    'reviewDocument.ownerResponse.updatedAt._nanoseconds': reviewDocumentOwnerResponseUpdatedAtNanoseconds,
    'reviewDocument.ownerResponse.updatedAt._seconds': reviewDocumentOwnerResponseUpdatedAtSeconds,
    'reviewDocument.rating': reviewDocumentRating,
    'reviewDocument.reviewerName': reviewDocumentReviewerName,
    'reviewDocument.reviewerUserId': reviewDocumentReviewerUserId,
    'reviewDocument.scenario': reviewDocumentScenario,
    'reviewDocument.seedPrefix': reviewDocumentSeedPrefix,
    'reviewDocument.source': reviewDocumentSource,
    'reviewDocument.submittedFromPath': reviewDocumentSubmittedFromPath,
    'reviewDocument.updatedAt._nanoseconds': reviewDocumentUpdatedAtNanoseconds,
    'reviewDocument.updatedAt._seconds': reviewDocumentUpdatedAtSeconds,
    'reviewDocument.verificationStatus': reviewDocumentVerificationStatus,
    'savedEventDocument.demoOpsCommand': savedEventDocumentDemoOpsCommand,
    'savedEventDocument.demoOpsId': savedEventDocumentDemoOpsId,
    'savedEventDocument.eventId': savedEventDocumentEventId,
    'savedEventDocument.savedAt._nanoseconds': savedEventDocumentSavedAtNanoseconds,
    'savedEventDocument.savedAt._seconds': savedEventDocumentSavedAtSeconds,
    'savedEventDocument.scenario': savedEventDocumentScenario,
    'savedEventDocument.seedPrefix': savedEventDocumentSeedPrefix,
    'savedEventDocument.uid': savedEventDocumentUid,
    'seedEventManifestDocument.anchorUserIds': seedEventManifestDocumentAnchorUserIds,
    'seedEventManifestDocument.counts': seedEventManifestDocumentCounts,
    'seedEventManifestDocument.demoOpsCommand': seedEventManifestDocumentDemoOpsCommand,
    'seedEventManifestDocument.demoOpsId': seedEventManifestDocumentDemoOpsId,
    'seedEventManifestDocument.generatedAt._nanoseconds': seedEventManifestDocumentGeneratedAtNanoseconds,
    'seedEventManifestDocument.generatedAt._seconds': seedEventManifestDocumentGeneratedAtSeconds,
    'seedEventManifestDocument.manifestId': seedEventManifestDocumentManifestId,
    'seedEventManifestDocument.paths': seedEventManifestDocumentPaths,
    'seedEventManifestDocument.scenario': seedEventManifestDocumentScenario,
    'seedEventManifestDocument.seedId': seedEventManifestDocumentSeedId,
    'seedEventManifestDocument.seedPrefix': seedEventManifestDocumentSeedPrefix,
    'swipeDocument.comment': swipeDocumentComment,
    'swipeDocument.createdAt._nanoseconds': swipeDocumentCreatedAtNanoseconds,
    'swipeDocument.createdAt._seconds': swipeDocumentCreatedAtSeconds,
    'swipeDocument.demoOpsCommand': swipeDocumentDemoOpsCommand,
    'swipeDocument.demoOpsId': swipeDocumentDemoOpsId,
    'swipeDocument.direction': swipeDocumentDirection,
    'swipeDocument.eventId': swipeDocumentEventId,
    'swipeDocument.reactionTargetId': swipeDocumentReactionTargetId,
    'swipeDocument.reactionTargetLabel': swipeDocumentReactionTargetLabel,
    'swipeDocument.reactionTargetPreview': swipeDocumentReactionTargetPreview,
    'swipeDocument.reactionTargetType': swipeDocumentReactionTargetType,
    'swipeDocument.scenario': swipeDocumentScenario,
    'swipeDocument.seedPrefix': swipeDocumentSeedPrefix,
    'swipeDocument.swiperId': swipeDocumentSwiperId,
    'swipeDocument.targetId': swipeDocumentTargetId,
    'updateClubPatch.area': updateClubPatchArea,
    'updateClubPatch.description': updateClubPatchDescription,
    'updateClubPatch.email': updateClubPatchEmail,
    'updateClubPatch.hostAvatarUrl': updateClubPatchHostAvatarUrl,
    'updateClubPatch.hostDefaults.eventPolicy.admissionPreset': updateClubPatchHostDefaultsEventPolicyAdmissionPreset,
    'updateClubPatch.hostDefaults.eventPolicy.cancellationPolicyId': updateClubPatchHostDefaultsEventPolicyCancellationPolicyId,
    'updateClubPatch.hostDefaults.eventPolicy.dynamicPricingMaxInPaise': updateClubPatchHostDefaultsEventPolicyDynamicPricingMaxInPaise,
    'updateClubPatch.hostDefaults.eventPolicy.dynamicPricingStepInPaise': updateClubPatchHostDefaultsEventPolicyDynamicPricingStepInPaise,
    'updateClubPatch.hostDefaults.eventPolicy.maxAge': updateClubPatchHostDefaultsEventPolicyMaxAge,
    'updateClubPatch.hostDefaults.eventPolicy.maxMen': updateClubPatchHostDefaultsEventPolicyMaxMen,
    'updateClubPatch.hostDefaults.eventPolicy.maxWomen': updateClubPatchHostDefaultsEventPolicyMaxWomen,
    'updateClubPatch.hostDefaults.eventPolicy.minAge': updateClubPatchHostDefaultsEventPolicyMinAge,
    'updateClubPatch.hostDefaults.eventSuccess.attendeePrompt': updateClubPatchHostDefaultsEventSuccessAttendeePrompt,
    'updateClubPatch.hostDefaults.eventSuccess.hostGoal': updateClubPatchHostDefaultsEventSuccessHostGoal,
    'updateClubPatch.hostDefaults.eventSuccess.playbookId': updateClubPatchHostDefaultsEventSuccessPlaybookId,
    'updateClubPatch.hostDefaults.eventSuccess.questionnaireConfig.customTitle': updateClubPatchHostDefaultsEventSuccessQuestionnaireConfigCustomTitle,
    'updateClubPatch.hostDefaults.eventSuccess.questionnaireConfig.templateId': updateClubPatchHostDefaultsEventSuccessQuestionnaireConfigTemplateId,
    'updateClubPatch.hostDefaults.eventSuccess.structureConfig.maxPairMeetings': updateClubPatchHostDefaultsEventSuccessStructureConfigMaxPairMeetings,
    'updateClubPatch.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds': updateClubPatchHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds,
    'updateClubPatch.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes': updateClubPatchHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes,
    'updateClubPatch.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy': updateClubPatchHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy,
    'updateClubPatch.hostDefaults.eventSuccess.structureConfig.unitCount': updateClubPatchHostDefaultsEventSuccessStructureConfigUnitCount,
    'updateClubPatch.hostDefaults.eventSuccess.structureConfig.unitKind': updateClubPatchHostDefaultsEventSuccessStructureConfigUnitKind,
    'updateClubPatch.hostDefaults.eventSuccess.structureConfig.unitSize': updateClubPatchHostDefaultsEventSuccessStructureConfigUnitSize,
    'updateClubPatch.hostDefaults.primaryActivityKind': updateClubPatchHostDefaultsPrimaryActivityKind,
    'updateClubPatch.hostName': updateClubPatchHostName,
    'updateClubPatch.imageUrl': updateClubPatchImageUrl,
    'updateClubPatch.instagramHandle': updateClubPatchInstagramHandle,
    'updateClubPatch.location': updateClubPatchLocation,
    'updateClubPatch.logoPhoto.createdAt._nanoseconds': updateClubPatchLogoPhotoCreatedAtNanoseconds,
    'updateClubPatch.logoPhoto.createdAt._seconds': updateClubPatchLogoPhotoCreatedAtSeconds,
    'updateClubPatch.logoPhoto.id': updateClubPatchLogoPhotoId,
    'updateClubPatch.logoPhoto.moderation.reason': updateClubPatchLogoPhotoModerationReason,
    'updateClubPatch.logoPhoto.moderation.reviewedAt._nanoseconds': updateClubPatchLogoPhotoModerationReviewedAtNanoseconds,
    'updateClubPatch.logoPhoto.moderation.reviewedAt._seconds': updateClubPatchLogoPhotoModerationReviewedAtSeconds,
    'updateClubPatch.logoPhoto.moderation.status': updateClubPatchLogoPhotoModerationStatus,
    'updateClubPatch.logoPhoto.position': updateClubPatchLogoPhotoPosition,
    'updateClubPatch.logoPhoto.storagePath': updateClubPatchLogoPhotoStoragePath,
    'updateClubPatch.logoPhoto.thumbnailStoragePath': updateClubPatchLogoPhotoThumbnailStoragePath,
    'updateClubPatch.logoPhoto.thumbnailUrl': updateClubPatchLogoPhotoThumbnailUrl,
    'updateClubPatch.logoPhoto.updatedAt._nanoseconds': updateClubPatchLogoPhotoUpdatedAtNanoseconds,
    'updateClubPatch.logoPhoto.updatedAt._seconds': updateClubPatchLogoPhotoUpdatedAtSeconds,
    'updateClubPatch.logoPhoto.url': updateClubPatchLogoPhotoUrl,
    'updateClubPatch.name': updateClubPatchName,
    'updateClubPatch.organizerType': updateClubPatchOrganizerType,
    'updateClubPatch.phoneNumber': updateClubPatchPhoneNumber,
    'updateClubPatch.profileImageUrl': updateClubPatchProfileImageUrl,
    'updateOrganizerCallablePayload.fields.area': updateOrganizerCallablePayloadFieldsArea,
    'updateOrganizerCallablePayload.fields.description': updateOrganizerCallablePayloadFieldsDescription,
    'updateOrganizerCallablePayload.fields.email': updateOrganizerCallablePayloadFieldsEmail,
    'updateOrganizerCallablePayload.fields.hostAvatarUrl': updateOrganizerCallablePayloadFieldsHostAvatarUrl,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.admissionPreset': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyAdmissionPreset,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.cancellationPolicyId': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyCancellationPolicyId,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.dynamicPricingMaxInPaise': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyDynamicPricingMaxInPaise,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.dynamicPricingStepInPaise': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyDynamicPricingStepInPaise,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.maxAge': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMaxAge,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.maxMen': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMaxMen,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.maxWomen': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMaxWomen,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventPolicy.minAge': updateOrganizerCallablePayloadFieldsHostDefaultsEventPolicyMinAge,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.attendeePrompt': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessAttendeePrompt,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.hostGoal': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessHostGoal,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.playbookId': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessPlaybookId,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.questionnaireConfig.customTitle': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessQuestionnaireConfigCustomTitle,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.questionnaireConfig.templateId': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessQuestionnaireConfigTemplateId,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.maxPairMeetings': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigMaxPairMeetings,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.revealCountdownSeconds': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigRevealCountdownSeconds,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.rotationIntervalMinutes': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigRotationIntervalMinutes,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.rotationRepeatStrategy': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigRotationRepeatStrategy,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.unitCount': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigUnitCount,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.unitKind': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigUnitKind,
    'updateOrganizerCallablePayload.fields.hostDefaults.eventSuccess.structureConfig.unitSize': updateOrganizerCallablePayloadFieldsHostDefaultsEventSuccessStructureConfigUnitSize,
    'updateOrganizerCallablePayload.fields.hostDefaults.primaryActivityKind': updateOrganizerCallablePayloadFieldsHostDefaultsPrimaryActivityKind,
    'updateOrganizerCallablePayload.fields.hostName': updateOrganizerCallablePayloadFieldsHostName,
    'updateOrganizerCallablePayload.fields.imageUrl': updateOrganizerCallablePayloadFieldsImageUrl,
    'updateOrganizerCallablePayload.fields.instagramHandle': updateOrganizerCallablePayloadFieldsInstagramHandle,
    'updateOrganizerCallablePayload.fields.location': updateOrganizerCallablePayloadFieldsLocation,
    'updateOrganizerCallablePayload.fields.logoPhoto.createdAt._nanoseconds': updateOrganizerCallablePayloadFieldsLogoPhotoCreatedAtNanoseconds,
    'updateOrganizerCallablePayload.fields.logoPhoto.createdAt._seconds': updateOrganizerCallablePayloadFieldsLogoPhotoCreatedAtSeconds,
    'updateOrganizerCallablePayload.fields.logoPhoto.id': updateOrganizerCallablePayloadFieldsLogoPhotoId,
    'updateOrganizerCallablePayload.fields.logoPhoto.moderation.reason': updateOrganizerCallablePayloadFieldsLogoPhotoModerationReason,
    'updateOrganizerCallablePayload.fields.logoPhoto.moderation.reviewedAt._nanoseconds': updateOrganizerCallablePayloadFieldsLogoPhotoModerationReviewedAtNanoseconds,
    'updateOrganizerCallablePayload.fields.logoPhoto.moderation.reviewedAt._seconds': updateOrganizerCallablePayloadFieldsLogoPhotoModerationReviewedAtSeconds,
    'updateOrganizerCallablePayload.fields.logoPhoto.moderation.status': updateOrganizerCallablePayloadFieldsLogoPhotoModerationStatus,
    'updateOrganizerCallablePayload.fields.logoPhoto.position': updateOrganizerCallablePayloadFieldsLogoPhotoPosition,
    'updateOrganizerCallablePayload.fields.logoPhoto.storagePath': updateOrganizerCallablePayloadFieldsLogoPhotoStoragePath,
    'updateOrganizerCallablePayload.fields.logoPhoto.thumbnailStoragePath': updateOrganizerCallablePayloadFieldsLogoPhotoThumbnailStoragePath,
    'updateOrganizerCallablePayload.fields.logoPhoto.thumbnailUrl': updateOrganizerCallablePayloadFieldsLogoPhotoThumbnailUrl,
    'updateOrganizerCallablePayload.fields.logoPhoto.updatedAt._nanoseconds': updateOrganizerCallablePayloadFieldsLogoPhotoUpdatedAtNanoseconds,
    'updateOrganizerCallablePayload.fields.logoPhoto.updatedAt._seconds': updateOrganizerCallablePayloadFieldsLogoPhotoUpdatedAtSeconds,
    'updateOrganizerCallablePayload.fields.logoPhoto.url': updateOrganizerCallablePayloadFieldsLogoPhotoUrl,
    'updateOrganizerCallablePayload.fields.name': updateOrganizerCallablePayloadFieldsName,
    'updateOrganizerCallablePayload.fields.organizerType': updateOrganizerCallablePayloadFieldsOrganizerType,
    'updateOrganizerCallablePayload.fields.phoneNumber': updateOrganizerCallablePayloadFieldsPhoneNumber,
    'updateOrganizerCallablePayload.fields.profileImageUrl': updateOrganizerCallablePayloadFieldsProfileImageUrl,
    'updateOrganizerCallablePayload.organizerId': updateOrganizerCallablePayloadOrganizerId,
    'updateUserProfilePatch.activityPreferences.running.paceMaxSecsPerKm': updateUserProfilePatchActivityPreferencesRunningPaceMaxSecsPerKm,
    'updateUserProfilePatch.activityPreferences.running.paceMinSecsPerKm': updateUserProfilePatchActivityPreferencesRunningPaceMinSecsPerKm,
    'updateUserProfilePatch.activityPreferences.running.preferredDistances': updateUserProfilePatchActivityPreferencesRunningPreferredDistances,
    'updateUserProfilePatch.activityPreferences.running.preferredRunTimes': updateUserProfilePatchActivityPreferencesRunningPreferredRunTimes,
    'updateUserProfilePatch.activityPreferences.running.runningReasons': updateUserProfilePatchActivityPreferencesRunningRunningReasons,
    'updateUserProfilePatch.activityPreferences.running.version': updateUserProfilePatchActivityPreferencesRunningVersion,
    'updateUserProfilePatch.children': updateUserProfilePatchChildren,
    'updateUserProfilePatch.city': updateUserProfilePatchCity,
    'updateUserProfilePatch.company': updateUserProfilePatchCompany,
    'updateUserProfilePatch.dateOfBirth': updateUserProfilePatchDateOfBirth,
    'updateUserProfilePatch.diet': updateUserProfilePatchDiet,
    'updateUserProfilePatch.displayName': updateUserProfilePatchDisplayName,
    'updateUserProfilePatch.drinking': updateUserProfilePatchDrinking,
    'updateUserProfilePatch.education': updateUserProfilePatchEducation,
    'updateUserProfilePatch.email': updateUserProfilePatchEmail,
    'updateUserProfilePatch.gender': updateUserProfilePatchGender,
    'updateUserProfilePatch.height': updateUserProfilePatchHeight,
    'updateUserProfilePatch.instagramHandle': updateUserProfilePatchInstagramHandle,
    'updateUserProfilePatch.latitude': updateUserProfilePatchLatitude,
    'updateUserProfilePatch.longitude': updateUserProfilePatchLongitude,
    'updateUserProfilePatch.maxAgePreference': updateUserProfilePatchMaxAgePreference,
    'updateUserProfilePatch.minAgePreference': updateUserProfilePatchMinAgePreference,
    'updateUserProfilePatch.name': updateUserProfilePatchName,
    'updateUserProfilePatch.occupation': updateUserProfilePatchOccupation,
    'updateUserProfilePatch.phoneNumber': updateUserProfilePatchPhoneNumber,
    'updateUserProfilePatch.relationshipGoal': updateUserProfilePatchRelationshipGoal,
    'updateUserProfilePatch.religion': updateUserProfilePatchReligion,
    'updateUserProfilePatch.smoking': updateUserProfilePatchSmoking,
    'updateUserProfilePatch.workout': updateUserProfilePatchWorkout,
    'userEventScheduleLockDocument.clubId': userEventScheduleLockDocumentClubId,
    'userEventScheduleLockDocument.demoOpsCommand': userEventScheduleLockDocumentDemoOpsCommand,
    'userEventScheduleLockDocument.demoOpsId': userEventScheduleLockDocumentDemoOpsId,
    'userEventScheduleLockDocument.endTimeMillis': userEventScheduleLockDocumentEndTimeMillis,
    'userEventScheduleLockDocument.eventId': userEventScheduleLockDocumentEventId,
    'userEventScheduleLockDocument.organizerId': userEventScheduleLockDocumentOrganizerId,
    'userEventScheduleLockDocument.ownerId': userEventScheduleLockDocumentOwnerId,
    'userEventScheduleLockDocument.ownerType': userEventScheduleLockDocumentOwnerType,
    'userEventScheduleLockDocument.scenario': userEventScheduleLockDocumentScenario,
    'userEventScheduleLockDocument.seedPrefix': userEventScheduleLockDocumentSeedPrefix,
    'userEventScheduleLockDocument.slot': userEventScheduleLockDocumentSlot,
    'userEventScheduleLockDocument.startTimeMillis': userEventScheduleLockDocumentStartTimeMillis,
    'userEventScheduleLockDocument.uid': userEventScheduleLockDocumentUid,
    'userProfileDocument.activityPreferences.running.paceMaxSecsPerKm': userProfileDocumentActivityPreferencesRunningPaceMaxSecsPerKm,
    'userProfileDocument.activityPreferences.running.paceMinSecsPerKm': userProfileDocumentActivityPreferencesRunningPaceMinSecsPerKm,
    'userProfileDocument.activityPreferences.running.preferredDistances': userProfileDocumentActivityPreferencesRunningPreferredDistances,
    'userProfileDocument.activityPreferences.running.preferredRunTimes': userProfileDocumentActivityPreferencesRunningPreferredRunTimes,
    'userProfileDocument.activityPreferences.running.runningReasons': userProfileDocumentActivityPreferencesRunningRunningReasons,
    'userProfileDocument.activityPreferences.running.version': userProfileDocumentActivityPreferencesRunningVersion,
    'userProfileDocument.children': userProfileDocumentChildren,
    'userProfileDocument.city': userProfileDocumentCity,
    'userProfileDocument.company': userProfileDocumentCompany,
    'userProfileDocument.countryCode': userProfileDocumentCountryCode,
    'userProfileDocument.dateOfBirth._nanoseconds': userProfileDocumentDateOfBirthNanoseconds,
    'userProfileDocument.dateOfBirth._seconds': userProfileDocumentDateOfBirthSeconds,
    'userProfileDocument.deletedAt._nanoseconds': userProfileDocumentDeletedAtNanoseconds,
    'userProfileDocument.deletedAt._seconds': userProfileDocumentDeletedAtSeconds,
    'userProfileDocument.demoOpsCommand': userProfileDocumentDemoOpsCommand,
    'userProfileDocument.demoOpsId': userProfileDocumentDemoOpsId,
    'userProfileDocument.diet': userProfileDocumentDiet,
    'userProfileDocument.displayName': userProfileDocumentDisplayName,
    'userProfileDocument.drinking': userProfileDocumentDrinking,
    'userProfileDocument.education': userProfileDocumentEducation,
    'userProfileDocument.email': userProfileDocumentEmail,
    'userProfileDocument.firstName': userProfileDocumentFirstName,
    'userProfileDocument.gender': userProfileDocumentGender,
    'userProfileDocument.height': userProfileDocumentHeight,
    'userProfileDocument.instagramHandle': userProfileDocumentInstagramHandle,
    'userProfileDocument.interestedInGenders': userProfileDocumentInterestedInGenders,
    'userProfileDocument.languages': userProfileDocumentLanguages,
    'userProfileDocument.lastName': userProfileDocumentLastName,
    'userProfileDocument.latitude': userProfileDocumentLatitude,
    'userProfileDocument.longitude': userProfileDocumentLongitude,
    'userProfileDocument.maxAgePreference': userProfileDocumentMaxAgePreference,
    'userProfileDocument.minAgePreference': userProfileDocumentMinAgePreference,
    'userProfileDocument.name': userProfileDocumentName,
    'userProfileDocument.occupation': userProfileDocumentOccupation,
    'userProfileDocument.phoneNumber': userProfileDocumentPhoneNumber,
    'userProfileDocument.prefsClubUpdates': userProfileDocumentPrefsClubUpdates,
    'userProfileDocument.prefsEventReminders': userProfileDocumentPrefsEventReminders,
    'userProfileDocument.prefsMessages': userProfileDocumentPrefsMessages,
    'userProfileDocument.prefsNewCatches': userProfileDocumentPrefsNewCatches,
    'userProfileDocument.prefsRunStatusUpdates': userProfileDocumentPrefsRunStatusUpdates,
    'userProfileDocument.prefsShowOnMap': userProfileDocumentPrefsShowOnMap,
    'userProfileDocument.prefsWeeklyDigest': userProfileDocumentPrefsWeeklyDigest,
    'userProfileDocument.profileComplete': userProfileDocumentProfileComplete,
    'userProfileDocument.profilePhotos': userProfileDocumentProfilePhotos,
    'userProfileDocument.profilePrompts': userProfileDocumentProfilePrompts,
    'userProfileDocument.relationshipGoal': userProfileDocumentRelationshipGoal,
    'userProfileDocument.religion': userProfileDocumentReligion,
    'userProfileDocument.scenario': userProfileDocumentScenario,
    'userProfileDocument.seedPrefix': userProfileDocumentSeedPrefix,
    'userProfileDocument.smoking': userProfileDocumentSmoking,
    'userProfileDocument.workout': userProfileDocumentWorkout,
  };
}
