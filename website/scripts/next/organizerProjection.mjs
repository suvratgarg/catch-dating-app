// Pure projection shared by the build materializer and request-time server reader.
import {organizerListingReadiness, supplyCapabilitiesForAuthority} from "../organizerListingReadiness.mjs";

export function staticPublicApi(reason) {
  return disabledPublicApi(reason, "static_fixture");
}

export function disabledPublicApi(reason, claimTargetSyncStatus) {
  return {
    state: "disabled",
    reason,
    claimTargetSyncStatus,
  };
}

export function organizerAuthority({
  ownershipState = "programmatic",
  claimState = "unclaimed",
  provenanceOrigin = "import",
  sourceConfidence = "seedOnly",
  verificationStatus = "unverified",
  appVisibility = "hidden",
  publishStatus = "draft",
  indexStatus = "noindex",
} = {}) {
  return {
    ownershipState: enumValue(
      ownershipState,
      ["programmatic", "userCreated", "claimed", "transferred"],
      "programmatic"
    ),
    claimState: enumValue(
      claimState,
      ["unclaimed", "claimPending", "claimed", "verified", "suppressed"],
      "unclaimed"
    ),
    provenanceOrigin: enumValue(
      provenanceOrigin,
      ["userCreated", "scraper", "adminSeed", "import"],
      "import"
    ),
    sourceConfidence: enumValue(
      sourceConfidence,
      ["seedOnly", "low", "medium", "high", "ownerVerified"],
      "seedOnly"
    ),
    verificationStatus: enumValue(
      verificationStatus,
      ["unverified", "sourceBacked", "ownerVerified"],
      "unverified"
    ),
    appVisibility: enumValue(
      appVisibility,
      ["discoverable", "hidden"],
      "hidden"
    ),
    publishStatus: enumValue(
      publishStatus,
      ["draft", "qa", "published", "suppressed", "removed"],
      "draft"
    ),
    indexStatus: enumValue(
      indexStatus,
      ["noindex", "indexReady", "indexed"],
      "noindex"
    ),
  };
}

export function enumValue(value, allowed, fallback) {
  return allowed.includes(value) ? value : fallback;
}

export function listingCapabilities(
  authority,
  backendReadiness,
  publicReviewTarget = {
    state: "disabled",
    reason: "Public reviews are unavailable until canonical target readiness is verified.",
  }
) {
  const claimable = authority.claimState === "unclaimed";
  const claimBackendEnabled = backendReadiness.state === "enabled";
  const publicReviewTargetEnabled = publicReviewTarget.state === "enabled";
  const publicReviewsEligible =
    authority.publishStatus === "published" &&
    authority.indexStatus !== "noindex" &&
    authority.claimState !== "suppressed";
  const publicReviewsEnabled =
    publicReviewsEligible && publicReviewTargetEnabled;
  return {
    claimRequest: {
      state: claimable && claimBackendEnabled ? "enabled" : "disabled",
      reason: !claimable ?
        claimCapabilityReason(authority.claimState) :
        backendReadiness.reason,
    },
    publicReviews: {
      targetState: publicReviewTargetEnabled ? "enabled" : "disabled",
      readState: publicReviewsEnabled ? "enabled" : "disabled",
      writeState: publicReviewsEnabled ? "enabled" : "disabled",
      reason: !publicReviewsEligible ?
        "Public reviews require a published, index-ready organizer page." :
        !publicReviewTargetEnabled ? publicReviewTarget.reason :
        "Public reviews are available for this published organizer page.",
    },
    supply: supplyCapabilitiesForAuthority(authority),
  };
}

export function claimCapabilityReason(claimState) {
  switch (claimState) {
  case "claimPending": return "A claim request is already under review.";
  case "claimed": return "This organizer has already been claimed.";
  case "verified": return "This organizer is owner verified.";
  case "suppressed": return "This organizer is not accepting claim requests.";
  default: return "Claiming is not available for this organizer yet.";
  }
}

export function canonicalOrganizerType(club) {
  const value = club?.organizerType;
  if ([
    "club",
    "community",
    "individual",
    "eventProducer",
    "venue",
    "brand",
  ].includes(value)) return value;
  switch (club?.entityKind) {
  case "creatorCommunity": return "community";
  case "eventOrganizer": return "eventProducer";
  case "venue": return "venue";
  case "brand": return "brand";
  default: return "club";
  }
}

export function organizerTypeLabel(type) {
  switch (type) {
  case "eventProducer": return "Event producer";
  case "individual": return "Individual organizer";
  default: return `${type.charAt(0).toUpperCase()}${type.slice(1)}`;
  }
}

export function listingFromOrganizerDocument(wrapper) {
  if (!wrapper || typeof wrapper !== "object") return null;
  const {path: firestorePath, data: club} = wrapper;
  if (!club || typeof club !== "object") return null;
  if (!club.publicPage?.canonicalPath) return null;
  if (!["qa", "published"].includes(club.publicPage.publishStatus)) return null;

  const id = String(firestorePath ?? "").split("/").pop() || club.publicPage.slug;
  const city = club.cityName || club.area || club.location || "Unknown";
  const citySlug = club.publicPage.citySlug || club.location || "unknown";
  const publicProfile = club.publicProfile ?? {};
  const claimState = club.claim?.state ?? "unclaimed";
  const claimHref = claimState === "unclaimed" ?
    `${club.publicPage.canonicalPath}#claim` :
    club.publicPage.canonicalPath;
  const authority = organizerAuthority({
    ownershipState: club.ownership?.state,
    claimState,
    provenanceOrigin: club.provenance?.origin,
    sourceConfidence: club.provenance?.sourceConfidence,
    verificationStatus: club.provenance?.verificationStatus,
    appVisibility: club.appVisibility,
    publishStatus: club.publicPage.publishStatus,
    indexStatus: club.publicPage.indexStatus,
  });
  const publicApi = staticPublicApi(
    "This listing remains fail-closed until its Firestore claim target is verified."
  );

  return {
    id,
    listingVariant: "unclaimedScraped",
    dataOrigin: "organizerIntake",
    name: club.name,
    slug: club.publicPage.slug,
    city,
    citySlug,
    region: club.regionName ?? "",
    country: club.countryName ?? "",
    path: club.publicPage.canonicalPath,
    legacyPaths: [],
    category: club.publicCategoryLabel ??
      club.displayCategory ??
      organizerTypeLabel(canonicalOrganizerType(club)),
    status: claimState,
    indexing: club.publicPage.robots ?? "noindex, follow",
    sourceConfidence: club.provenance?.sourceConfidence ?? "low",
    headline: publicProfile.headline ?? `${club.name} in ${city}`,
    description: publicProfile.summary ?? club.description,
    sourceSummary: publicProfile.sourceSummary ?? club.description,
    logo: {
      mode: "monogram",
      text: initialsForName(club.name),
      status: club.logoPhoto ? "source_provided" : "not_verified",
    },
    formats: publicProfile.formats?.length ? publicProfile.formats : club.tags ?? [],
    facts: publicProfile.facts ?? [],
    eventEvidence: publicProfile.eventEvidence ?? [],
    reviews: publicReviewsForListing(wrapper.reviews ?? [], id),
    // Organizers no longer store operator fit notes or evidence checklists;
    // the listing DTO keeps the empty lists until its own contract drops them.
    fitNotes: [],
    missingEvidence: [],
    sources: publicSourcesForListing(club.publicSources ?? []),
    claim: {
      href: claimHref,
      label: claimState === "unclaimed" ? "Claim this listing" : "View organizer profile",
    },
    publicApi,
    authority,
    capabilities: listingCapabilities(authority, publicApi),
    lastVerifiedAt: dateLabel(club.provenance?.lastVerifiedAt),
    searchText: searchText([
      club.name,
      city,
      club.area,
      club.organizerType,
      club.publicCategoryLabel,
      club.displayCategory,
      club.instagramHandle,
      ...(club.tags ?? []),
      ...(publicProfile.formats ?? []),
    ]),
  };
}

export function listingFromFirestoreOrganizer({id, path = `organizers/${id}`, data: club}) {
  const readiness = organizerListingReadiness({id, path, data: club});
  if (!readiness.documentValid || club.archived || club.status === "archived" ||
      club.claim?.state === "suppressed") return null;
  const wrapper = {path, data: club};
  const listing = listingFromOrganizerDocument(wrapper);
  if (!listing) return null;
  const {publicApi, publicReviewTarget} = readiness;
  const authority = organizerAuthority({
    ownershipState: club.ownership?.state,
    claimState: club.claim?.state,
    provenanceOrigin: club.provenance?.origin,
    sourceConfidence: club.provenance?.sourceConfidence,
    verificationStatus: club.provenance?.verificationStatus,
    appVisibility: club.appVisibility,
    publishStatus: club.publicPage?.publishStatus,
    indexStatus: club.publicPage?.indexStatus,
  });
  const capabilities = listingCapabilities(authority, publicApi, publicReviewTarget);
  if (capabilities.supply.reviewPolicy === "after_event_end") {
    capabilities.publicReviews.writeState = "disabled";
    if (publicReviewTarget.state === "enabled") {
      capabilities.publicReviews.reason =
        "Public reviews can be read here; unclaimed organizer reviews require a finished event.";
    }
  }
  return {
    ...listing,
    dataOrigin: club.provenance?.origin === "userCreated" ?
      "appCreated" :
      "organizerIntake",
    legacyPaths: club.publicPage?.legacyPaths ?? [],
    publicApi,
    authority,
    capabilities,
  };
}

export function publicReviewsForListing(reviews, organizerId) {
  if (!Array.isArray(reviews)) return [];
  return reviews
    .map((entry) => {
      const review = entry?.data ?? entry;
      if (!review || typeof review !== "object") return null;
      if ((review.organizerId ?? review.clubId) !== organizerId) return null;
      if (review.moderationStatus && review.moderationStatus !== "published") {
        return null;
      }
      return {
        id: String(entry?.path ?? review.id ?? "").split("/").pop() || null,
        eventId: typeof review.eventId === "string" ? review.eventId : null,
        reviewerName: review.reviewerName ?? "Catch member",
        rating: review.rating,
        comment: review.comment ?? "",
        createdAt: dateLabel(review.createdAt),
        verificationStatus:
          review.verificationStatus ?? (review.eventId ? "verified" : "unverified"),
        source:
          review.source ?? (review.eventId ? "catchEvent" : "publicListing"),
        isAnonymous: review.isAnonymous === true,
        ownerResponse: publicOwnerResponse(review.ownerResponse),
      };
    })
    .filter(Boolean);
}

export function publicOwnerResponse(response) {
  if (!response || typeof response !== "object") return null;
  return {
    hostName: response.hostName ?? "Host",
    hostAvatarUrl: response.hostAvatarUrl ?? null,
    message: response.message ?? "",
    updatedAt: dateLabel(response.updatedAt),
  };
}

export function publicSourcesForListing(sources) {
  return sources.map((source) => {
    const listingSource = {
      type: source.type,
      label: source.label,
      detail: source.detail,
      confidence: source.confidence,
    };
    if (source.href) listingSource.href = source.href;
    return listingSource;
  });
}

export function searchText(values) {
  return values
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
}

export function initialsForName(name) {
  return String(name)
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("") || "C";
}

export function dateLabel(timestamp) {
  if (typeof timestamp === "string" && !Number.isNaN(Date.parse(timestamp))) {
    return new Date(timestamp).toISOString().slice(0, 10);
  }
  if (!timestamp || typeof timestamp._seconds !== "number") {
    return "Unverified";
  }
  return new Date(timestamp._seconds * 1000).toISOString().slice(0, 10);
}

