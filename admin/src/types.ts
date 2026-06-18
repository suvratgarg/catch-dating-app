export interface AdminOverviewMetric {
  id: string;
  label: string;
  value: number;
  unit?: string;
}

export interface AdminQueueItem {
  id: string;
  title: string;
  detail: string;
  status: string;
  createdAt: string | null;
  targetPath: string;
}

export interface AdminOverviewResponse {
  generatedAt: string;
  timezone: "UTC";
  metrics: AdminOverviewMetric[];
  queues: {
    safetyReports: AdminQueueItem[];
    moderationFlags: AdminQueueItem[];
    eventSafetyReports: AdminQueueItem[];
    accessApplications: AdminQueueItem[];
    clubClaimRequests: AdminQueueItem[];
    clubIndexReviews: AdminQueueItem[];
    paymentIssues: AdminQueueItem[];
  };
  dataQuality: Array<{
    id: string;
    label: string;
    state: "ok" | "warning" | "blocked";
    detail: string;
  }>;
}

export type DataMode = "sample" | "live";

export type AccessApplicationDecision = "approve" | "deny";
export type ClubClaimDecision = "approve" | "reject";
export type ClubIndexDecision = "indexReady" | "noindex";
export type OrganizerIntakeDecision = "approve_public" | "hold" | "suppress";
export type OrganizerEventCandidateDecision =
  | "approve_for_import"
  | "hold"
  | "reject";
export type OrganizerPolicyGapDecision = "accept" | "hold" | "reject";
export type OrganizerEntityKind =
  | "club"
  | "venue"
  | "eventOrganizer"
  | "creatorCommunity"
  | "brand";
export type OrganizerAppVisibility = "discoverable" | "hidden";
export type OrganizerPublishStatus =
  | "draft"
  | "qa"
  | "published"
  | "suppressed"
  | "removed";
export type OrganizerSourceConfidence =
  | "seedOnly"
  | "low"
  | "medium"
  | "high"
  | "ownerVerified";
export type OrganizerVerificationStatus =
  | "unverified"
  | "sourceBacked"
  | "ownerVerified";
export type OrganizerCurationOperation =
  | "attach_surface"
  | "merge_entity"
  | "split_surface"
  | "suppress_entity"
  | "surface_decision";
export type OrganizerSurfaceDecision =
  | "accept_primary"
  | "accept_secondary"
  | "reject_wrong_entity"
  | "mark_ambiguous"
  | "mark_historical";

export interface OrganizerCurationSurface {
  surfaceId: string;
  platform:
    | "bookMyShow"
    | "district"
    | "instagram"
    | "linkedin"
    | "luma"
    | "news"
    | "officialWebsite"
    | "partiful"
    | "sortMyScene"
    | "userReport"
    | "other";
  surfaceKind:
    | "eventListing"
    | "eventCalendar"
    | "organizerProfile"
    | "personProfile"
    | "press"
    | "socialProfile"
    | "website"
    | "wrongEntity";
  url: string | null;
  normalizedKey: string | null;
  role: "primary" | "secondary" | "backup" | "historical" | "ambiguous" | "rejected";
  status: "active" | "candidate" | "ambiguous" | "historical" | "rejected";
  confidence: {
    city: "low" | "medium" | "high";
    entityMatch: "low" | "medium" | "high";
    ownership: "low" | "medium" | "high";
  };
  crawl: {
    eventDiscoveryStatus: "disabled" | "candidate" | "approved" | "paused";
    policy: "manualOnly" | "blocked" | "apiPreferred";
    supportsEventExtraction: boolean;
  };
  evidenceRefs: Array<{
    type: "hostDiscoveryRun" | "seedClub" | "userReportedSearchResult" | "manualNote";
    ref: string | null;
    description: string;
  }>;
  notes: string;
}

export interface AdminDecideAccessApplicationPayload {
  applicationUid: string;
  decision: AccessApplicationDecision;
  note?: string | null;
  cohortId?: string | null;
}

export interface AdminDecideAccessApplicationResponse {
  applicationUid: string;
  decision: AccessApplicationDecision;
  status: "approvedForProfile" | "notSelectedYet";
}

export interface AdminDecideClubClaimPayload {
  requestId: string;
  decision: ClubClaimDecision;
  decisionReason?: string | null;
}

export interface AdminDecideClubClaimResponse {
  requestId: string;
  clubId: string;
  decision: ClubClaimDecision;
  status: "approved" | "rejected";
}

export interface AdminSetClubIndexStatusPayload {
  clubId: string;
  indexStatus: ClubIndexDecision;
  checklist: {
    sourceEvidenceVerified: boolean;
    mediaRightsVerified: boolean;
    cadenceVerified: boolean;
    ownerContactVerified: boolean;
  };
  reviewNote?: string | null;
}

export interface AdminSetClubIndexStatusResponse {
  clubId: string;
  indexStatus: ClubIndexDecision;
  publishStatus: "qa" | "published";
  robots: "noindex, follow" | "index, follow";
}

export interface AdminDecideOrganizerIntakePayload {
  entityId: string;
  decision: OrganizerIntakeDecision;
  appVisibility: OrganizerAppVisibility;
  checklist: {
    identityReviewed: boolean;
    surfaceInventoryReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    marketScopeReviewed: boolean;
    mediaRightsReviewed: boolean;
    crawlDisabledReviewed: boolean;
    manualReportsReviewed?: boolean;
  };
  note: string;
}

export interface AdminDecideOrganizerIntakeResponse {
  entityId: string;
  decision: OrganizerIntakeDecision;
  decisionStatus: "approved_public" | "held" | "suppressed";
  appVisibility: OrganizerAppVisibility;
  decisionPath: string;
  projectionState: "pending_static_generation" | "not_projectable";
}

export interface AdminDecideOrganizerEventCandidatePayload {
  candidateId: string;
  decision: OrganizerEventCandidateDecision;
  checklist: {
    identityReviewed: boolean;
    sourceEventReviewed: boolean;
    timeReviewed: boolean;
    locationReviewed: boolean;
    dedupeReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    importPolicyAcknowledged: boolean;
  };
  note: string;
}

export interface AdminDecideOrganizerEventCandidateResponse {
  candidateId: string;
  decisionId: string;
  decision: OrganizerEventCandidateDecision;
  decisionStatus: "approved_for_import" | "held" | "rejected";
  decisionPath: string;
  importState: "blocked_by_policy" | "not_importable" | "pending_import";
}

export interface AdminDecideOrganizerPolicyGapPayload {
  gapId: string;
  decision: OrganizerPolicyGapDecision;
  requiredInputsReviewed: string[];
  checklist: {
    requiredInputsReviewed: boolean;
    costAndSafetyReviewed: boolean;
    implementationOwnerReviewed: boolean;
    behaviorStillDisabledAcknowledged: boolean;
  };
  note: string;
}

export interface AdminDecideOrganizerPolicyGapResponse {
  gapId: string;
  decisionId: string;
  decision: OrganizerPolicyGapDecision;
  decisionStatus: "accepted" | "held" | "rejected";
  decisionPath: string;
  operationalState: "blocked_until_policy_encoded" | "not_approved";
}

export interface OrganizerResolvedEventLocation {
  name: string;
  address?: string | null;
  placeId?: string | null;
  latitude: number | null;
  longitude: number | null;
  notes?: string | null;
}

export interface AdminResolveOrganizerEventLocationPayload {
  candidateId: string;
  location: OrganizerResolvedEventLocation;
  checklist: {
    sourceLocationReviewed: boolean;
    coordinatesReviewed: boolean;
    placeIdentityReviewed: boolean;
    importSafetyReviewed: boolean;
  };
  note: string;
}

export interface AdminResolveOrganizerEventLocationResponse {
  candidateId: string;
  resolutionId: string;
  resolutionStatus: "resolved";
  decisionPath: string;
  location: OrganizerResolvedEventLocation;
}

export interface AdminRecordOrganizerCurationPayload {
  operationId?: string;
  operationType: OrganizerCurationOperation;
  entityId?: string;
  sourceEntityId?: string;
  targetEntityId?: string;
  surfaceId?: string;
  newEntityId?: string;
  sourceCandidateId?: string;
  decision?: OrganizerSurfaceDecision;
  surface?: OrganizerCurationSurface;
  reason: string;
}

export interface AdminRecordOrganizerCurationResponse {
  operationId: string;
  operationType: OrganizerCurationOperation;
  operationStatus: "active" | "superseded";
  decisionPath: string;
}

export interface AdminClubDetails {
  clubId: string;
  name: string;
  description: string;
  location: string | null;
  area: string;
  tags: string[];
  instagramHandle: string | null;
  phoneNumber: string | null;
  email: string | null;
  imageUrl: string | null;
  profileImageUrl: string | null;
  entityKind: OrganizerEntityKind | null;
  entitySubtypes: string[];
  displayCategory: string | null;
  cityName: string | null;
  regionName: string | null;
  countryCode: string | null;
  countryName: string | null;
  appVisibility: OrganizerAppVisibility | null;
  ownershipState: string | null;
  claimState: string | null;
  publicPage: {
    slug: string | null;
    citySlug: string | null;
    canonicalPath: string | null;
    publishStatus: OrganizerPublishStatus | null;
    indexStatus: string | null;
    robots: string | null;
    seoTitle: string | null;
    seoDescription: string | null;
  };
  provenance: {
    origin: string | null;
    sourceConfidence: OrganizerSourceConfidence | null;
    verificationStatus: OrganizerVerificationStatus | null;
  };
  publicProfile: {
    headline: string | null;
    summary: string | null;
    sourceSummary: string | null;
    formats: string[];
    fitNotes: string[];
    missingEvidence: string[];
  };
}

export interface AdminGetClubDetailsPayload {
  clubId: string;
}

export interface AdminGetClubDetailsResponse {
  club: AdminClubDetails;
}

export interface AdminUpdateClubDetailsPayload {
  clubId: string;
  fields: {
    name?: string;
    description?: string;
    location?: string | null;
    area?: string;
    tags?: string[];
    instagramHandle?: string | null;
    phoneNumber?: string | null;
    email?: string | null;
    imageUrl?: string | null;
    profileImageUrl?: string | null;
    entityKind?: OrganizerEntityKind;
    entitySubtypes?: string[];
    displayCategory?: string | null;
    cityName?: string | null;
    regionName?: string | null;
    countryCode?: string | null;
    countryName?: string | null;
    appVisibility?: OrganizerAppVisibility;
    publicPage?: {
      slug?: string;
      citySlug?: string | null;
      canonicalPath?: string;
      publishStatus?: OrganizerPublishStatus;
      seoTitle?: string | null;
      seoDescription?: string | null;
    };
    provenance?: {
      sourceConfidence?: OrganizerSourceConfidence;
      verificationStatus?: OrganizerVerificationStatus;
    };
    publicProfile?: {
      headline?: string | null;
      summary?: string | null;
      sourceSummary?: string | null;
      formats?: string[];
      fitNotes?: string[];
      missingEvidence?: string[];
    };
  };
  reviewNote?: string | null;
}

export interface AdminUpdateClubDetailsResponse {
  clubId: string;
  updatedFieldCount: number;
}
