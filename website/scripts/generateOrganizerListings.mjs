import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(dirname, "..");
const repoRoot = path.resolve(websiteRoot, "..");
const seedRoot = path.join(repoRoot, "tool", "host_discovery", "seed_clubs");
const demoScenarioRoot = path.join(repoRoot, "tool", "demo", "demo_seed", "scenarios");
const generatedDir = path.join(websiteRoot, "src", "generated");
const generatedPath = path.join(generatedDir, "hostListings.json");

const listings = [
  ...scrapedSeedListings(),
  ...appCreatedDemoListings(),
].sort((a, b) => a.name.localeCompare(b.name));

fs.mkdirSync(generatedDir, {recursive: true});
fs.writeFileSync(generatedPath, `${JSON.stringify(listings, null, 2)}\n`);

function scrapedSeedListings() {
  return fs
    .readdirSync(seedRoot)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => {
      const wrapper = JSON.parse(
        fs.readFileSync(path.join(seedRoot, file), "utf8")
      );
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
        "First-party synthetic club used for host workflow, roster, review, payment, and Event Success QA.",
      confidence: "high",
    }],
    claim: {
      href: `${path}#events`,
      label: "View events",
    },
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

function priceLabel(priceInPaise) {
  if (!priceInPaise) return "Free";
  return `$${(priceInPaise / 100 / 83).toFixed(0)}`;
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
  if (!timestamp || typeof timestamp._seconds !== "number") {
    return "Unverified";
  }
  return new Date(timestamp._seconds * 1000).toISOString().slice(0, 10);
}
