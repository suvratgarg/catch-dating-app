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
