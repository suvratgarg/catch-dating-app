import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  schemaErrorMessages,
  validateWebsiteHostListingProjection,
} from "../../tool/contracts/generated/schema_contract_validators.mjs";
import {inMarket} from "../src/content/markets/in.ts";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(dirname, "..");
const repoRoot = path.resolve(websiteRoot, "..");
const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const seedRoot = path.resolve(
  args.seedRoot ?? path.join(repoRoot, "tool", "host_discovery", "seed_clubs")
);
const intakeProjectionPath = path.resolve(args.projectionPlan ?? path.join(
  repoRoot,
  "tool",
  "organizer_intake",
  "generated",
  "public_projection_plan.json"
));
const externalEventReadinessPath = path.resolve(
  args.externalEventReadiness ?? path.join(
    repoRoot,
    "tool",
    "organizer_intake",
    "generated",
    "external_event_import_execution_plan.json"
  )
);
const claimTargetSyncPreviewPath = path.resolve(
  args.claimTargetSyncPreview ?? path.join(
    repoRoot,
    "tool",
    "organizer_intake",
    "generated",
    "organizer_claim_target_sync_preview.json"
  )
);
const claimTargetPlanPath = path.resolve(
  args.claimTargetPlan ?? path.join(
    repoRoot,
    "tool",
    "organizer_intake",
    "generated",
    "organizer_claim_targets.json"
  )
);
const claimTargetReadinessReceiptPath =
  args.claimTargetReadinessReceipt ??
  process.env.ORGANIZER_CLAIM_TARGET_RECEIPT ??
  null;
const demoScenarioRoot = path.resolve(
  args.demoScenarioRoot ??
    path.join(repoRoot, "tool", "demo", "demo_seed", "scenarios")
);
const generatedPath = path.resolve(
  args.output ??
    path.join(websiteRoot, "src", "generated", "hostListings.json")
);
const checkOnly = args.check;
const claimTargetSyncPreview = readJsonIfExists(claimTargetSyncPreviewPath);
const claimTargetReadinessReceipt = claimTargetReadinessReceiptPath ?
  readAndValidateClaimTargetReadinessReceipt(
    path.resolve(claimTargetReadinessReceiptPath)
  ) :
  null;
const liveMarketKeys = new Set(
  inMarket.cities
    .filter((city) => city.status === "live")
    .flatMap((city) => [city.slug, city.label, ...city.aliases])
    .map(normalizeMarketKey)
);
const approvedIntakeProjections = organizerIntakeProjectionEntries();
const productionIntakeProjections = approvedIntakeProjections.filter(
  organizerIntakeProjectionHasLiveMarket
);
const publicExternalEventsByHostId =
  publicExternalEventsByCanonicalHostId(readJsonIfExists(externalEventReadinessPath));
const suppressedLegacyPaths = new Set(
  approvedIntakeProjections.flatMap((entry) => [
    entry.publicListing?.path,
    ...(entry.legacyPaths ?? []),
  ]).filter(Boolean)
);

const listings = [
  ...(args.includeDemo ? approvedIntakeProjections : productionIntakeProjections)
    .map((entry) => listingFromOrganizerIntakeProjection(entry, {
      liveMarketsOnly: !args.includeDemo,
    })),
  ...(args.noSeeds ? [] : scrapedSeedListings(suppressedLegacyPaths)
    .filter((listing) => args.includeDemo || listingHasLiveMarket(listing))),
  ...(args.includeDemo ? appCreatedDemoListings() : []),
]
  .map(withPublicExternalEvents)
  .sort((a, b) => compareText(a.name, b.name));
validateListingProjections(listings);
const renderedListings = `${JSON.stringify(listings, null, 2)}\n`;

if (checkOnly) {
  if (!fs.existsSync(generatedPath)) {
    console.error(`Missing generated organizer listings: ${generatedPath}`);
    process.exit(1);
  }
  const currentListings = fs.readFileSync(generatedPath, "utf8");
  if (currentListings !== renderedListings) {
    console.error("website/src/generated/hostListings.json is stale.");
    console.error("Run: npm --workspace catch-marketing run generate:organizer-listings");
    process.exit(1);
  }
} else {
  fs.mkdirSync(path.dirname(generatedPath), {recursive: true});
  fs.writeFileSync(generatedPath, renderedListings);
}

function organizerIntakeProjectionEntries() {
  if (!fs.existsSync(intakeProjectionPath)) return [];
  const projectionPlan = JSON.parse(fs.readFileSync(intakeProjectionPath, "utf8"));
  return (projectionPlan.entries ?? [])
    .filter((entry) =>
      entry?.projectionStatus === "ready" &&
      entry?.publicListing &&
      entry?.publishStatus === "published"
    )
    .sort((a, b) => compareText(a.entityId, b.entityId));
}

function readJsonIfExists(filePath) {
  if (!fs.existsSync(filePath)) return null;
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function readAndValidateClaimTargetReadinessReceipt(filePath) {
  const receipt = readJsonIfExists(filePath);
  if (!receipt) {
    fail(`Missing organizer claim-target readiness receipt: ${filePath}`);
  }
  if (receipt.schemaVersion !== 1 ||
      receipt.receiptType !== "organizer_claim_target_readiness") {
    fail(`Unsupported organizer claim-target readiness receipt: ${filePath}`);
  }
  if (receipt.mode?.source !== "firestore_read" ||
      receipt.mode?.remoteWrites !== 0) {
    fail("Organizer claim-target readiness must come from a read-only Firestore receipt.");
  }
  const expectedProjectId =
    process.env.ORGANIZER_CLAIM_TARGET_PROJECT_ID?.trim() || null;
  if (expectedProjectId && receipt.projectId !== expectedProjectId) {
    fail(
      `Organizer claim-target receipt project ${receipt.projectId ?? "missing"} ` +
        `does not match ${expectedProjectId}.`
    );
  }
  const planHash = crypto.createHash("sha256")
    .update(fs.readFileSync(claimTargetPlanPath))
    .digest("hex");
  if (receipt.plan?.sha256 !== planHash) {
    fail("Organizer claim-target readiness receipt does not match the current plan.");
  }
  if (!Array.isArray(receipt.actions)) {
    fail("Organizer claim-target readiness receipt actions are missing.");
  }
  return receipt;
}

function compareText(a, b) {
  const left = String(a ?? "");
  const right = String(b ?? "");
  if (left < right) return -1;
  if (left > right) return 1;
  return 0;
}

function normalizeMarketKey(value) {
  return String(value ?? "").toLowerCase().replace(/[^a-z0-9]+/gu, "");
}

function isLiveMarketValue(value) {
  const key = normalizeMarketKey(value);
  return key.length > 0 && liveMarketKeys.has(key);
}

function organizerIntakeProjectionHasLiveMarket(entry) {
  return (entry?.publicListing?.markets ?? []).some((market) =>
    isLiveMarketValue(market?.marketSlug) ||
      isLiveMarketValue(market?.displayName)
  );
}

function listingHasLiveMarket(listing) {
  return isLiveMarketValue(listing?.citySlug) || isLiveMarketValue(listing?.city);
}

function publicExternalEventsByCanonicalHostId(readiness) {
  const grouped = new Map();
  for (const event of publicExternalEventProjections(readiness)) {
    for (const hostId of [event.canonicalHostId, event.compatibilityClubId]) {
      if (!hostId) continue;
      const hostEvents = grouped.get(hostId) ?? [];
      hostEvents.push(event.projection);
      grouped.set(hostId, hostEvents);
    }
  }
  for (const [hostId, events] of grouped) {
    grouped.set(
      hostId,
      uniqueById(events)
        .sort((a, b) => Date.parse(a.startTime) - Date.parse(b.startTime))
    );
  }
  return grouped;
}

function publicExternalEventProjections(readiness) {
  if (!readiness || typeof readiness !== "object") return [];
  const actions = externalEventReadinessActions(readiness);
  return actions
    .filter(isPublishableExternalEventAction)
    .map((action) => publicExternalEventProjectionFromAction(action))
    .filter(Boolean);
}

function externalEventReadinessActions(readiness) {
  if (Array.isArray(readiness.actions)) return readiness.actions;
  if (Array.isArray(readiness.executionPlan?.actions)) {
    return readiness.executionPlan.actions;
  }
  return [];
}

function isPublishableExternalEventAction(action) {
  const document = action?.externalEventDocument;
  return Boolean(
    action &&
    typeof action === "object" &&
    action.sourceAction === "publish_read_only_external_event" &&
    action.status === "would_publish_read_only" &&
    Array.isArray(action.blockers) &&
    action.blockers.length === 0 &&
    action.payloadValidation?.valid === true &&
    action.projectionValidation?.valid === true &&
    document?.status === "active" &&
    document?.publicationStatus === "public" &&
    document?.discovery?.availability === "read_only_external" &&
    document?.booking?.mode === "external_outbound_only" &&
    document?.booking?.catchBookingEnabled === false &&
    document?.booking?.catchPaymentsEnabled === false &&
    document?.booking?.catchReservationsEnabled === false &&
    document?.booking?.catchWaitlistEnabled === false
  );
}

function publicExternalEventProjectionFromAction(action) {
  const event = action.externalEventDocument;
  const startTime = timestampIso(event.startTime);
  if (!startTime) return null;
  const endTime = timestampIso(event.endTime);
  const primaryLink =
    event.booking.externalLinks.find((link) => link.primary) ??
    event.booking.externalLinks[0] ??
    null;
  const sourceHref =
    primaryLink?.url ?? event.externalSource?.eventUrl ?? event.externalSource?.sourceUrl;
  if (!sourceHref) return null;
  const sourceLabel = platformLabel(primaryLink?.platform ?? event.externalSource?.platform);
  return {
    canonicalHostId: event.canonicalHostId,
    compatibilityClubId: event.compatibilityClubId,
    projection: {
      id: event.eventId,
      title: event.title,
      activityKind: event.activity.activityKind,
      availability: event.discovery.availability,
      startTime,
      endTime,
      date: eventDateLabelForTimezone(startTime, endTime, event.timezone),
      location: event.meetingPoint,
      summary: event.description,
      priceLabel: event.price.displayText ?? "External ticketing",
      sourceLabel,
      sourceHref,
      externalLinkCount: event.booking.externalLinks.length,
      dedupeKey: event.dedupe.normalizedEventKey,
    },
  };
}

function withPublicExternalEvents(listing) {
  const externalEvents = publicExternalEventsByHostId.get(listing.id) ?? [];
  if (!externalEvents.length) return listing;
  return {
    ...listing,
    externalEvents,
    searchText: searchText([
      listing.searchText,
      ...externalEvents.flatMap((event) => [
        event.title,
        event.activityKind,
        event.date,
        event.location,
        event.priceLabel,
        event.sourceLabel,
      ]),
    ]),
  };
}

function publicApiForOrganizerIntake(entityId) {
  const readiness = claimTargetReadinessReceipt ?? claimTargetSyncPreview;
  const action = (readiness?.actions ?? []).find((item) =>
    item?.entityId === entityId || item?.path === `clubs/${entityId}`
  );
  if (!readiness) {
    return disabledPublicApi(
      "Claiming is not available for this organizer yet.",
      "unknown"
    );
  }
  if (!action) {
    return {
      state: "enabled",
      reason: "The organizer claim target is ready.",
      claimTargetSyncStatus: "in_sync",
    };
  }
  if (action.status === "in_sync") {
    return {
      state: "enabled",
      reason: "The organizer claim target is ready.",
      claimTargetSyncStatus: "in_sync",
    };
  }
  return disabledPublicApi(
    "Claiming is not available for this organizer yet.",
    "write_needed"
  );
}

function staticPublicApi(reason) {
  return disabledPublicApi(reason, "static_fixture");
}

function disabledPublicApi(reason, claimTargetSyncStatus) {
  return {
    state: "disabled",
    reason,
    claimTargetSyncStatus,
  };
}

function validateListingProjections(listings) {
  const errors = [];
  for (const listing of listings) {
    if (validateWebsiteHostListingProjection(listing)) continue;
    const label = listing?.id ?? listing?.path ?? "unknown listing";
    for (const message of schemaErrorMessages(validateWebsiteHostListingProjection)) {
      errors.push(`${label}: ${message}`);
    }
  }
  if (errors.length === 0) return;
  fail([
    "Generated organizer listings do not match WebsiteHostListingProjection.",
    ...errors.map((error) => `- ${error}`),
  ].join("\n"));
}

function scrapedSeedListings(suppressedPaths) {
  return fs
    .readdirSync(seedRoot)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => {
      const wrapper = JSON.parse(
        fs.readFileSync(path.join(seedRoot, file), "utf8")
      );
      if (suppressedPaths.has(wrapper?.data?.publicPage?.canonicalPath)) {
        return null;
      }
      return listingFromClubSeed(wrapper);
    })
    .filter(Boolean);
}

function appCreatedDemoListings() {
  return ["host-demo.json"]
    .map((file) => {
      const config = JSON.parse(
        fs.readFileSync(path.join(demoScenarioRoot, file), "utf8")
      );
      return listingFromSalesDemo(config);
    })
    .filter(Boolean);
}

function listingFromClubSeed(wrapper) {
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
  const claimHref = claimState === "claimed" ?
    club.claim?.claimHref ?? "/host/#founding-hosts" :
    `${club.publicPage.canonicalPath}#claim`;

  return {
    id,
    listingVariant: "unclaimedScraped",
    dataOrigin: "scrapedSeed",
    name: club.name,
    slug: club.publicPage.slug,
    city,
    citySlug,
    region: club.regionName ?? "",
    country: club.countryName ?? "",
    path: club.publicPage.canonicalPath,
    legacyPaths: [],
    category: club.displayCategory ?? "Organizer",
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
    fitNotes: publicProfile.fitNotes ?? [],
    missingEvidence: publicProfile.missingEvidence ?? [],
    sources: publicSourcesForListing(club.publicSources ?? []),
    claim: {
      href: claimHref,
      label: claimState === "claimed" ? "View organizer tools" : "Claim this listing",
    },
    publicApi: staticPublicApi(
      "Legacy scraped seed listings are static until their Firestore claim target sync is verified."
    ),
    lastVerifiedAt: dateLabel(club.provenance?.lastVerifiedAt),
    searchText: searchText([
      club.name,
      city,
      club.area,
      club.displayCategory,
      club.instagramHandle,
      ...(club.tags ?? []),
      ...(publicProfile.formats ?? []),
    ]),
  };
}

function listingFromOrganizerIntakeProjection(entry, {liveMarketsOnly = false} = {}) {
  const projection = entry.publicListing;
  const markets = (projection.markets ?? []).filter((market) =>
    !liveMarketsOnly ||
      isLiveMarketValue(market?.marketSlug) ||
      isLiveMarketValue(market?.displayName)
  );
  const primaryMarket = markets[0] ?? null;
  const allMarketNames = markets.map((market) => market.displayName).filter(Boolean);
  const city = allMarketNames.length > 1 ?
    "Multiple cities" :
    primaryMarket?.displayName ?? "Unknown";
  const citySlug = primaryMarket?.marketSlug ?? "multi-city";
  const country = countryNameForCode(primaryMarket?.countryCode);
  const sources = publicSourcesForOrganizerIntake(projection.sources ?? []);

  return {
    id: projection.id,
    listingVariant: "unclaimedScraped",
    dataOrigin: "organizerIntake",
    name: projection.name,
    slug: projection.slug,
    city,
    citySlug,
    region: "",
    country,
    path: projection.path,
    legacyPaths: entry.legacyPaths ?? [],
    category: projection.category,
    status: projection.status,
    indexing: projection.indexing,
    sourceConfidence: highestSourceConfidence(sources),
    headline: projection.headline ?? `${projection.name} organizer profile`,
    description: projection.description,
    sourceSummary: projection.sourceSummary,
    logo: {
      mode: "monogram",
      text: initialsForName(projection.name),
      status: "not_verified",
    },
    formats: projection.formats ?? [],
    facts: [
      ...(allMarketNames.length ? [{
        label: allMarketNames.length > 1 ? "Markets" : "Market",
        value: allMarketNames.join(", "),
      }] : []),
      {label: "Organizer type", value: projection.category},
      {label: "Claim state", value: titleCaseText(projection.status)},
      {label: "Indexing", value: projection.indexing},
      {label: "App visibility", value: entry.appVisibility ?? "hidden"},
      {label: "Source surfaces", value: String(sources.length)},
    ],
    eventEvidence: [],
    reviews: [],
    fitNotes: [
      "This profile was promoted from organizer intake after manual admin review.",
      "Events remain market-filtered under one canonical organizer identity.",
      "Claiming unlocks owner-managed copy, official media, Catch events, and verified reviews.",
    ],
    missingEvidence: projection.missingEvidence ?? [],
    sources,
    claim: {
      href: `${projection.path}#claim`,
      label: "Claim this listing",
    },
    publicApi: publicApiForOrganizerIntake(entry.entityId),
    lastVerifiedAt: dateLabel(entry.reviewDecision?.decidedAt),
    searchText: searchText([
      projection.name,
      projection.category,
      city,
      citySlug,
      ...(projection.formats ?? []),
      ...allMarketNames,
      ...sources.flatMap((source) => [source.label, source.detail]),
    ]),
  };
}

function listingFromSalesDemo(config) {
  const demo = config.salesDemo;
  if (!demo?.club || !demo.market) return null;
  const club = demo.club;
  const slug = slugForName(club.name);
  const citySlug = demo.market.city;
  const city = demo.market.cityLabel;
  const path = `/organizers/${citySlug}/${slug}/`;
  const events = salesDemoEvents(demo);
  const reviews = salesDemoReviews(demo);
  const scorecard = events.find((event) => event.scorecard)?.scorecard ?? null;
  const nextEvent = events.find((event) => event.timeline === "upcoming");

  return {
    id: club.id,
    listingVariant: "appCreatedClub",
    dataOrigin: "catchDemo",
    name: club.name,
    slug,
    city,
    citySlug,
    region: "New York",
    country: "United States",
    path,
    category: "Catch-created host club",
    status: "claimed",
    indexing: "noindex, follow",
    sourceConfidence: "first_party",
    headline: `${club.name} in ${city}`,
    description: club.description,
    sourceSummary:
      `${club.name} is a first-party Catch demo club with app-created events, ` +
      "verified event reviews, host identity, and event-success metrics.",
    logo: {
      mode: "monogram",
      text: initialsForName(club.name),
      status: "app_created",
    },
    formats: titleCaseList(club.tags ?? []),
    facts: [
      {label: "Location", value: `${club.area}, ${city}`},
      {label: "Host", value: demo.host.displayName},
      {label: "Members", value: String(club.memberCount)},
      {label: "Rating", value: `${club.rating.toFixed(1)} from ${club.reviewCount} reviews`},
      {label: "Next event", value: nextEvent?.date ?? "Demo event schedule"},
      {label: "Built in Catch", value: "App-created club"},
    ],
    metrics: {
      memberCount: club.memberCount,
      rating: club.rating,
      reviewCount: club.reviewCount,
      nextEventAt: nextEvent?.startTime ?? null,
      nextEventLabel: nextEvent?.title ?? null,
    },
    host: {
      name: demo.host.displayName,
      role: "Owner",
      avatarUrl: null,
    },
    catchEvents: events,
    eventSuccessSummary: scorecard ? {
      bookedCount: scorecard.bookedCount,
      checkedInCount: scorecard.checkedInCount,
      mutualMatchCount: scorecard.mutualMatchCount,
      chatStartedCount: scorecard.chatStartedCount,
      catchSentCount: scorecard.catchSentCount,
      safetyIncidentCount: scorecard.safetyIncidentCount,
    } : null,
    eventEvidence: [],
    reviews,
    fitNotes: [
      "App-created clubs should lead with host identity, upcoming events, ratings, and member activity rather than a source ledger.",
      "Verified review aggregates matter more here than scrape confidence because the club and events already exist inside Catch.",
      "The page should help members decide whether to follow, book, or review, while unclaimed scraped pages should focus on owner claim.",
    ],
    missingEvidence: [],
    sources: [{
      type: "catch_demo",
      label: "Catch host-demo scenario",
      detail:
        "First-party synthetic club used for host workflow, roster, review, payment, and Playbook QA.",
      confidence: "high",
    }],
    claim: {
      href: `${path}#events`,
      label: "View events",
    },
    publicApi: staticPublicApi(
      "Catch demo listings use static fixture data and do not call public organizer APIs."
    ),
    lastVerifiedAt: dateLabel({_seconds: Date.parse(demo.referenceNow) / 1000}),
    searchText: searchText([
      club.name,
      city,
      club.area,
      demo.host.displayName,
      ...(club.tags ?? []),
      ...events.flatMap((event) => [event.title, event.activityKind]),
    ]),
  };
}

function publicReviewsForListing(reviews, clubId) {
  if (!Array.isArray(reviews)) return [];
  return reviews
    .map((entry) => {
      const review = entry?.data ?? entry;
      if (!review || typeof review !== "object") return null;
      if (review.clubId !== clubId) return null;
      if (review.moderationStatus && review.moderationStatus !== "published") {
        return null;
      }
      return {
        id: String(entry?.path ?? review.id ?? "").split("/").pop() || null,
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

function publicOwnerResponse(response) {
  if (!response || typeof response !== "object") return null;
  return {
    hostName: response.hostName ?? "Host",
    hostAvatarUrl: response.hostAvatarUrl ?? null,
    message: response.message ?? "",
    updatedAt: dateLabel(response.updatedAt),
  };
}

function publicSourcesForListing(sources) {
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

function publicSourcesForOrganizerIntake(sources) {
  return sources.map((source) => {
    const label = source.label ?? source.type ?? "Public source";
    const confidence = source.confidence ?? "medium";
    const listingSource = {
      type: source.type ?? "organizer_intake_surface",
      label,
      detail:
        source.detail ??
        `${label} was reviewed as an organizer-intake surface with ${confidence} confidence.`,
      confidence,
    };
    if (source.href) listingSource.href = source.href;
    return listingSource;
  });
}

function salesDemoEvents(demo) {
  const now = new Date(demo.referenceNow);
  return (demo.events ?? []).map((event) => {
    const start = new Date(event.startTime);
    const end = new Date(event.endTime);
    return {
      id: event.id,
      role: event.role,
      title: titleForDemoEvent(event),
      activityKind: event.activityKind,
      timeline: start > now ? "upcoming" : "past",
      startTime: event.startTime,
      endTime: event.endTime,
      date: eventDateLabel(start, end),
      location: event.meetingPoint,
      summary: event.description,
      capacityLimit: event.capacityLimit,
      bookedCount: event.bookedCount,
      checkedInCount: event.checkedInCount,
      waitlistedCount: event.waitlistedCount,
      priceLabel: priceLabel(event.priceInPaise),
      scorecard: event.scorecard ?? null,
    };
  });
}

function salesDemoReviews(demo) {
  const baseDate = new Date(demo.referenceNow);
  return [
    {
      id: `${demo.club.id}-verified-review-1`,
      reviewerName: "Maya S.",
      rating: 5,
      comment:
        "The host kept the dinner moving without making it feel forced. Easy arrivals, good prompts, and useful follow-up after.",
      createdAt: offsetIso(baseDate, -2),
      verificationStatus: "verified",
      source: "catchEvent",
      isAnonymous: false,
      ownerResponse: null,
    },
    {
      id: `${demo.club.id}-verified-review-2`,
      reviewerName: "Daniel K.",
      rating: 5,
      comment:
        "The rotations made it simple to meet more people than I would have on my own, and the post-event catch window felt private.",
      createdAt: offsetIso(baseDate, -3),
      verificationStatus: "verified",
      source: "catchEvent",
      isAnonymous: false,
      ownerResponse: null,
    },
    {
      id: `${demo.club.id}-verified-review-3`,
      reviewerName: "Anonymous attendee",
      rating: 4,
      comment:
        "Good crowd and clear structure. I liked that the host could adjust the live flow when the group changed.",
      createdAt: offsetIso(baseDate, -5),
      verificationStatus: "verified",
      source: "catchEvent",
      isAnonymous: true,
      ownerResponse: null,
    },
  ];
}

function titleForDemoEvent(event) {
  if (event.activityKind === "dinner") return "Hosted long-table dinner";
  if (event.activityKind === "pickleball") return "Social pickleball night";
  if (event.activityKind === "socialRun") return "Hudson River social run";
  return "Hosted singles mixer";
}

function eventDateLabel(start, end) {
  const date = new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
    timeZone: "America/New_York",
  }).format(start);
  const time = new Intl.DateTimeFormat("en", {
    hour: "numeric",
    minute: "2-digit",
    timeZone: "America/New_York",
  }).format(start);
  const endTime = new Intl.DateTimeFormat("en", {
    hour: "numeric",
    minute: "2-digit",
    timeZone: "America/New_York",
  }).format(end);
  return `${date}, ${time}-${endTime}`;
}

function eventDateLabelForTimezone(startIso, endIso, timezone) {
  const start = new Date(startIso);
  const end = endIso ? new Date(endIso) : null;
  const zone = validTimezone(timezone) ? timezone : "UTC";
  const date = new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
    timeZone: zone,
  }).format(start);
  const time = new Intl.DateTimeFormat("en", {
    hour: "numeric",
    minute: "2-digit",
    timeZone: zone,
  }).format(start);
  if (!end || Number.isNaN(end.getTime())) return `${date}, ${time}`;
  const endTime = new Intl.DateTimeFormat("en", {
    hour: "numeric",
    minute: "2-digit",
    timeZone: zone,
  }).format(end);
  return `${date}, ${time}-${endTime}`;
}

function priceLabel(priceInPaise) {
  if (!priceInPaise) return "Free";
  return `$${(priceInPaise / 100 / 83).toFixed(0)}`;
}

function timestampIso(value) {
  if (!value) return null;
  if (typeof value === "string" && !Number.isNaN(Date.parse(value))) {
    return new Date(value).toISOString();
  }
  if (typeof value._seconds === "number") {
    return new Date(value._seconds * 1000).toISOString();
  }
  return null;
}

function validTimezone(value) {
  if (!value) return false;
  try {
    new Intl.DateTimeFormat("en", {timeZone: value}).format(new Date());
    return true;
  } catch (_error) {
    return false;
  }
}

function platformLabel(platform) {
  const labels = {
    bookMyShow: "BookMyShow",
    district: "District",
    luma: "Luma",
    partiful: "Partiful",
    sortMyScene: "Sort My Scene",
  };
  return labels[platform] ?? titleCaseText(platform ?? "External source");
}

function uniqueById(items) {
  const byId = new Map();
  for (const item of items) {
    if (!byId.has(item.id)) byId.set(item.id, item);
  }
  return Array.from(byId.values());
}

function offsetIso(date, days) {
  const next = new Date(date);
  next.setUTCDate(next.getUTCDate() + days);
  return next.toISOString();
}

function titleCaseList(values) {
  return values.map((value) =>
    String(value)
      .split(/[\s_-]+/)
      .filter(Boolean)
      .map((word) => `${word[0]?.toUpperCase() ?? ""}${word.slice(1)}`)
      .join(" ")
  );
}

function searchText(values) {
  return values
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
}

function highestSourceConfidence(sources) {
  if (sources.some((source) => source.confidence === "high")) return "high";
  if (sources.some((source) => source.confidence === "medium")) return "medium";
  return "low";
}

function countryNameForCode(countryCode) {
  if (countryCode === "IN") return "India";
  if (countryCode === "US") return "United States";
  return countryCode ?? "";
}

function titleCaseText(value) {
  return String(value)
    .split(/[\s_-]+/)
    .filter(Boolean)
    .map((word) => `${word[0]?.toUpperCase() ?? ""}${word.slice(1)}`)
    .join(" ");
}

function initialsForName(name) {
  return String(name)
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("") || "C";
}

function slugForName(name) {
  return String(name)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function dateLabel(timestamp) {
  if (typeof timestamp === "string" && !Number.isNaN(Date.parse(timestamp))) {
    return new Date(timestamp).toISOString().slice(0, 10);
  }
  if (!timestamp || typeof timestamp._seconds !== "number") {
    return "Unverified";
  }
  return new Date(timestamp._seconds * 1000).toISOString().slice(0, 10);
}

function parseArgs(argv) {
  const parsed = {
    check: false,
    demoScenarioRoot: null,
    externalEventReadiness: null,
    help: false,
    includeDemo: false,
    noSeeds: false,
    output: null,
    projectionPlan: null,
    claimTargetPlan: null,
    claimTargetReadinessReceipt: null,
    seedRoot: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") parsed.check = true;
    else if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--include-demo") parsed.includeDemo = true;
    else if (arg === "--no-demo") parsed.includeDemo = false;
    else if (arg === "--no-seeds") parsed.noSeeds = true;
    else if (arg === "--demo-scenario-root") {
      parsed.demoScenarioRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--output") {
      parsed.output = requiredValue(argv, ++index, arg);
    } else if (arg === "--projection-plan") {
      parsed.projectionPlan = requiredValue(argv, ++index, arg);
    } else if (arg === "--external-event-readiness") {
      parsed.externalEventReadiness = requiredValue(argv, ++index, arg);
    } else if (arg === "--claim-target-sync-preview") {
      parsed.claimTargetSyncPreview = requiredValue(argv, ++index, arg);
    } else if (arg === "--claim-target-plan") {
      parsed.claimTargetPlan = requiredValue(argv, ++index, arg);
    } else if (arg === "--claim-target-readiness-receipt") {
      parsed.claimTargetReadinessReceipt = requiredValue(argv, ++index, arg);
    } else if (arg === "--seed-root") {
      parsed.seedRoot = requiredValue(argv, ++index, arg);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node website/scripts/generateOrganizerListings.mjs [options]

Options:
  --check                         Check generated hostListings.json drift.
  --projection-plan <path>         Read a specific organizer public projection plan.
  --external-event-readiness <path>
                                  Read a specific external event readiness/preflight plan.
  --claim-target-sync-preview <path>
                                  Read a specific claim target sync preview.
  --claim-target-plan <path>       Read a specific claim target plan for receipt validation.
  --claim-target-readiness-receipt <path>
                                  Read a Firestore readiness receipt for public claim APIs.
  --seed-root <path>               Read legacy scraped seed listings from a specific folder.
  --demo-scenario-root <path>      Read demo scenario configs from a specific folder.
  --output <path>                  Write or check a specific output file.
  --no-seeds                      Exclude legacy scraped seed listings.
  --include-demo                  Include app-created demo listings (Storybook/sales fixtures only).
  --no-demo                       Compatibility flag; production already excludes demos by default.
`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
