import type {
  AdminClubDetails,
  AdminSetClubIndexStatusPayload,
  AdminUpdateClubDetailsPayload,
  OrganizerAppVisibility,
  OrganizerType,
  OrganizerPublishStatus,
  OrganizerSourceConfidence,
  OrganizerVerificationStatus,
} from "../../../shared/types/adminTypes";

export interface OrganizerPublishingFormState {
  clubId: string;
  name: string;
  description: string;
  location: string;
  area: string;
  tagsText: string;
  instagramHandle: string;
  phoneNumber: string;
  email: string;
  imageUrl: string;
  profileImageUrl: string;
  organizerType: OrganizerType;
  publicCategoryLabel: string;
  cityName: string;
  regionName: string;
  countryCode: string;
  countryName: string;
  appVisibility: OrganizerAppVisibility;
  publicPageSlug: string;
  publicPageCitySlug: string;
  canonicalPath: string;
  publishStatus: OrganizerPublishStatus;
  seoTitle: string;
  seoDescription: string;
  sourceConfidence: OrganizerSourceConfidence;
  verificationStatus: OrganizerVerificationStatus;
  headline: string;
  summary: string;
  sourceSummary: string;
  formatsText: string;
  fitNotesText: string;
  missingEvidenceText: string;
  reviewNote: string;
}

export interface PublishChecklistState {
  sourceEvidenceVerified: boolean;
  mediaRightsVerified: boolean;
  cadenceVerified: boolean;
  ownerContactVerified: boolean;
}

export interface OrganizerValidationIssue {
  id: string;
  label: string;
  detail: string;
  severity: "blocker" | "warning";
}

export interface OrganizerValidationOptions {
  publishing?: boolean;
  requireReviewNote?: boolean;
}

export interface OrganizerDiffRow {
  field: string;
  before: string;
  after: string;
}

const organizerPathPattern =
  /^\/organizers\/([a-z0-9-]+)(?:\/([a-z0-9-]+))?\/$/;

export const emptyPublishChecklist: PublishChecklistState = {
  sourceEvidenceVerified: false,
  mediaRightsVerified: false,
  cadenceVerified: false,
  ownerContactVerified: false,
};

export function completePublishChecklist(
  checklist: PublishChecklistState
): boolean {
  return checklist.sourceEvidenceVerified &&
    checklist.mediaRightsVerified &&
    checklist.cadenceVerified &&
    checklist.ownerContactVerified;
}

export function formFromOrganizerProfile(
  club: AdminClubDetails
): OrganizerPublishingFormState {
  return {
    clubId: club.clubId,
    name: club.name,
    description: club.description,
    location: club.location ?? "",
    area: club.area,
    tagsText: listToText(club.tags),
    instagramHandle: club.instagramHandle ?? "",
    phoneNumber: club.phoneNumber ?? "",
    email: club.email ?? "",
    imageUrl: club.imageUrl ?? "",
    profileImageUrl: club.profileImageUrl ?? "",
    organizerType: club.organizerType,
    publicCategoryLabel: club.publicCategoryLabel ?? "",
    cityName: club.cityName ?? "",
    regionName: club.regionName ?? "",
    countryCode: club.countryCode ?? "",
    countryName: club.countryName ?? "",
    appVisibility: club.appVisibility ?? "hidden",
    publicPageSlug: club.publicPage.slug ?? "",
    publicPageCitySlug: club.publicPage.citySlug ?? "",
    canonicalPath: club.publicPage.canonicalPath ?? "",
    publishStatus: club.publicPage.publishStatus ?? "qa",
    seoTitle: club.publicPage.seoTitle ?? "",
    seoDescription: club.publicPage.seoDescription ?? "",
    sourceConfidence: club.provenance.sourceConfidence ?? "seedOnly",
    verificationStatus: club.provenance.verificationStatus ?? "unverified",
    headline: club.publicProfile.headline ?? "",
    summary: club.publicProfile.summary ?? "",
    sourceSummary: club.publicProfile.sourceSummary ?? "",
    formatsText: listToText(club.publicProfile.formats),
    fitNotesText: listToText(club.publicProfile.fitNotes),
    missingEvidenceText: listToText(club.publicProfile.missingEvidence),
    reviewNote: "",
  };
}

export function diffOrganizerProfile(
  club: AdminClubDetails | null,
  form: OrganizerPublishingFormState | null
): OrganizerDiffRow[] {
  if (!club || !form) return [];
  const original = formFromOrganizerProfile(club);
  return diffFields(original, form);
}

export function buildOrganizerSavePayload(
  club: AdminClubDetails,
  form: OrganizerPublishingFormState
): AdminUpdateClubDetailsPayload {
  const original = formFromOrganizerProfile(club);
  const fields: AdminUpdateClubDetailsPayload["fields"] = {};

  addChanged(fields, "name", original.name, form.name);
  addChanged(fields, "description", original.description, form.description);
  addChanged(fields, "location", original.location, nullableText(form.location));
  addChanged(fields, "area", original.area, form.area);
  addChangedArray(fields, "tags", original.tagsText, form.tagsText);
  addChanged(
    fields,
    "instagramHandle",
    original.instagramHandle,
    nullableText(form.instagramHandle)
  );
  addChanged(fields, "phoneNumber", original.phoneNumber, nullableText(form.phoneNumber));
  addChanged(fields, "email", original.email, nullableText(form.email));
  addChanged(fields, "imageUrl", original.imageUrl, nullableText(form.imageUrl));
  addChanged(
    fields,
    "profileImageUrl",
    original.profileImageUrl,
    nullableText(form.profileImageUrl)
  );
  addChanged(
    fields,
    "organizerType",
    original.organizerType,
    form.organizerType
  );
  addChanged(
    fields,
    "publicCategoryLabel",
    original.publicCategoryLabel,
    nullableText(form.publicCategoryLabel)
  );
  addChanged(fields, "cityName", original.cityName, nullableText(form.cityName));
  addChanged(fields, "regionName", original.regionName, nullableText(form.regionName));
  addChanged(fields, "countryCode", original.countryCode, nullableText(form.countryCode));
  addChanged(fields, "countryName", original.countryName, nullableText(form.countryName));
  addChanged(fields, "appVisibility", original.appVisibility, form.appVisibility);

  const publicPage: NonNullable<
    AdminUpdateClubDetailsPayload["fields"]["publicPage"]
  > = {};
  addChanged(publicPage, "slug", original.publicPageSlug, form.publicPageSlug);
  addChanged(
    publicPage,
    "citySlug",
    original.publicPageCitySlug,
    nullableText(form.publicPageCitySlug)
  );
  addChanged(
    publicPage,
    "canonicalPath",
    original.canonicalPath,
    form.canonicalPath
  );
  addChanged(publicPage, "publishStatus", original.publishStatus, form.publishStatus);
  addChanged(publicPage, "seoTitle", original.seoTitle, nullableText(form.seoTitle));
  addChanged(
    publicPage,
    "seoDescription",
    original.seoDescription,
    nullableText(form.seoDescription)
  );
  if (Object.keys(publicPage).length > 0) fields.publicPage = publicPage;

  const provenance: NonNullable<
    AdminUpdateClubDetailsPayload["fields"]["provenance"]
  > = {};
  addChanged(
    provenance,
    "sourceConfidence",
    original.sourceConfidence,
    form.sourceConfidence
  );
  addChanged(
    provenance,
    "verificationStatus",
    original.verificationStatus,
    form.verificationStatus
  );
  if (Object.keys(provenance).length > 0) fields.provenance = provenance;

  const publicProfile: NonNullable<
    AdminUpdateClubDetailsPayload["fields"]["publicProfile"]
  > = {};
  addChanged(publicProfile, "headline", original.headline, nullableText(form.headline));
  addChanged(publicProfile, "summary", original.summary, nullableText(form.summary));
  addChanged(
    publicProfile,
    "sourceSummary",
    original.sourceSummary,
    nullableText(form.sourceSummary)
  );
  addChangedArray(publicProfile, "formats", original.formatsText, form.formatsText);
  addChangedArray(publicProfile, "fitNotes", original.fitNotesText, form.fitNotesText);
  addChangedArray(
    publicProfile,
    "missingEvidence",
    original.missingEvidenceText,
    form.missingEvidenceText
  );
  if (Object.keys(publicProfile).length > 0) {
    fields.publicProfile = publicProfile;
  }

  return {
    clubId: form.clubId.trim(),
    reviewNote: nullableText(form.reviewNote),
    fields,
  };
}

export function buildOrganizerPublishPayload(
  form: OrganizerPublishingFormState,
  checklist: PublishChecklistState
): AdminSetClubIndexStatusPayload {
  return {
    clubId: form.clubId.trim(),
    indexStatus: "indexReady",
    checklist,
    reviewNote: nullableText(form.reviewNote),
  };
}

export function validateOrganizerPublishingForm(
  form: OrganizerPublishingFormState | null,
  options: OrganizerValidationOptions = {}
): OrganizerValidationIssue[] {
  if (!form) {
    return [{
      id: "no-form",
      label: "No organizer loaded",
      detail: "Load a canonical clubs/{id} document before publishing.",
      severity: "blocker",
    }];
  }
  const issues: OrganizerValidationIssue[] = [];
  requireText(issues, "name", "Name", form.name);
  requireText(issues, "description", "Description", form.description);
  requireText(issues, "area", "Area", form.area);
  requireText(issues, "slug", "Slug", form.publicPageSlug);
  requireText(issues, "canonical-path", "Canonical path", form.canonicalPath);
  const routeIssue = validateCanonicalPath(form);
  if (routeIssue) issues.push(routeIssue);
  if (options.requireReviewNote && !form.reviewNote.trim()) {
    issues.push({
      id: "review-note",
      label: "Review note",
      detail: "Add a review note so the audited save has operator context.",
      severity: "blocker",
    });
  }
  if (options.publishing) {
    requireText(issues, "headline", "Headline", form.headline);
    requireText(issues, "summary", "Summary", form.summary);
    if (form.sourceConfidence !== "high" &&
        form.sourceConfidence !== "ownerVerified") {
      issues.push({
        id: "source-confidence",
        label: "Source confidence",
        detail: "Publishing requires high or owner-verified source confidence.",
        severity: "blocker",
      });
    }
    if (form.verificationStatus === "unverified") {
      issues.push({
        id: "verification",
        label: "Verification",
        detail: "Publishing requires source-backed or owner-verified status.",
        severity: "blocker",
      });
    }
  }
  return issues;
}

export function hasBlockingIssues(issues: OrganizerValidationIssue[]): boolean {
  return issues.some((issue) => issue.severity === "blocker");
}

export function organizerTypeLabel(type: OrganizerType): string {
  switch (type) {
  case "eventProducer": return "Event producer";
  case "individual": return "Individual organizer";
  default: return type.charAt(0).toUpperCase() + type.slice(1);
  }
}

function validateCanonicalPath(
  form: OrganizerPublishingFormState
): OrganizerValidationIssue | null {
  const match = organizerPathPattern.exec(form.canonicalPath.trim());
  if (!match) {
    return {
      id: "route-shape",
      label: "Canonical path",
      detail: "Use /organizers/{slug}/ or /organizers/{citySlug}/{slug}/.",
      severity: "blocker",
    };
  }
  const firstSegment = match[1];
  const secondSegment = match[2] ?? null;
  const routeSlug = secondSegment ?? firstSegment;
  const routeCity = secondSegment ? firstSegment : null;
  if (routeSlug !== form.publicPageSlug.trim()) {
    return {
      id: "route-slug",
      label: "Canonical path",
      detail: "The final route segment must match the public page slug.",
      severity: "blocker",
    };
  }
  if (routeCity &&
      form.publicPageCitySlug.trim() &&
      routeCity !== form.publicPageCitySlug.trim()) {
    return {
      id: "route-city",
      label: "Canonical path",
      detail: "The route city segment must match the page city slug.",
      severity: "blocker",
    };
  }
  return null;
}

function requireText(
  issues: OrganizerValidationIssue[],
  id: string,
  label: string,
  value: string
) {
  if (value.trim()) return;
  issues.push({
    id,
    label,
    detail: `${label} is required for a canonical organizer listing.`,
    severity: "blocker",
  });
}

function diffFields(
  before: OrganizerPublishingFormState,
  after: OrganizerPublishingFormState
): OrganizerDiffRow[] {
  const rows: OrganizerDiffRow[] = [];
  for (const key of Object.keys(before) as Array<keyof OrganizerPublishingFormState>) {
    if (key === "reviewNote") continue;
    const beforeValue = String(before[key] ?? "");
    const afterValue = String(after[key] ?? "");
    if (beforeValue !== afterValue) {
      rows.push({
        field: labelFromKey(key),
        before: beforeValue || "empty",
        after: afterValue || "empty",
      });
    }
  }
  return rows;
}

function labelFromKey(key: string): string {
  return key
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

function addChanged<T extends Record<string, unknown>, K extends keyof T>(
  target: T,
  key: K,
  before: unknown,
  after: T[K]
) {
  if (normalizeComparable(before) !== normalizeComparable(after)) {
    target[key] = after;
  }
}

function addChangedArray<T extends Record<string, unknown>, K extends keyof T>(
  target: T,
  key: K,
  beforeText: string,
  afterText: string
) {
  const before = JSON.stringify(textToList(beforeText));
  const after = textToList(afterText);
  if (before !== JSON.stringify(after)) target[key] = after as T[K];
}

function normalizeComparable(value: unknown): string {
  if (value === null || value === undefined) return "";
  return String(value).trim();
}

function listToText(items: string[]): string {
  return items.join("\n");
}

function textToList(value: string): string[] {
  return Array.from(new Set(
    value
      .split("\n")
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
  ));
}

function nullableText(value: string): string | null {
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}
