import crypto from "node:crypto";

const eventPlatforms = new Set(["bookMyShow", "district", "luma", "partiful", "sortMyScene"]);
const trackingParams = new Set([
  "fbclid",
  "gclid",
  "igshid",
  "mc_cid",
  "mc_eid",
  "ref",
  "ref_src",
  "si",
  "source",
]);
const pressDomains = new Set([
  "hindustantimes.com",
  "indianexpress.com",
  "lbb.in",
  "mid-day.com",
  "timesofindia.indiatimes.com",
  "whatshot.in",
]);
const instagramReservedSegments = new Set([
  "accounts",
  "direct",
  "explore",
  "p",
  "reel",
  "reels",
  "stories",
  "tv",
]);

export function normalizeOrganizerSurfaceUrl(inputUrl, options = {}) {
  const url = parseSurfaceUrl(inputUrl);
  const host = canonicalHost(url.hostname);
  const segments = pathSegments(url.pathname);
  const canonicalUrl = canonicalUrlString(url, host, segments);
  const classification = classifySurface(host, segments);
  const confidence = options.confidence ?? defaultConfidence(classification);

  return {
    inputUrl: String(inputUrl ?? "").trim(),
    canonicalUrl,
    platform: classification.platform,
    surfaceKind: classification.surfaceKind,
    normalizedKey: classification.normalizedKey,
    role: options.role ?? classification.role,
    status: options.status ?? classification.status,
    confidence,
    crawl: {
      eventDiscoveryStatus: "disabled",
      policy: classification.platform === "other" ? "blocked" : "manualOnly",
      supportsEventExtraction: classification.supportsEventExtraction,
    },
    notes: classification.notes,
    diagnostics: classification.diagnostics,
  };
}

export function surfaceFromUrl(inputUrl, options = {}) {
  const normalized = normalizeOrganizerSurfaceUrl(inputUrl, options);
  const surfaceId = options.surfaceId ?? surfaceIdFromNormalizedKey(
    normalized.normalizedKey,
    normalized.canonicalUrl
  );

  return {
    surfaceId,
    platform: normalized.platform,
    surfaceKind: normalized.surfaceKind,
    url: normalized.canonicalUrl,
    normalizedKey: normalized.normalizedKey,
    role: normalized.role,
    status: normalized.status,
    confidence: normalized.confidence,
    crawl: normalized.crawl,
    evidenceRefs: options.evidenceRefs ?? [],
    notes: options.notes ?? normalized.notes,
  };
}

export function surfaceIdFromNormalizedKey(normalizedKey, fallbackUrl) {
  const base = normalizedKey ?? fallbackUrl ?? "surface";
  const slug = String(base)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 72);
  const hash = crypto.createHash("sha1").update(String(base)).digest("hex").slice(0, 8);
  return `${slug || "surface"}-${hash}`.slice(0, 90).replace(/-+$/g, "");
}

function classifySurface(host, segments) {
  if (isLumaHost(host)) return classifyLuma(segments);
  if (isInstagramHost(host)) return classifyInstagram(segments);
  if (isPartifulHost(host)) return classifyPartiful(segments);
  if (isDistrictHost(host)) return classifyDistrict(segments);
  if (isBookMyShowHost(host)) return classifyBookMyShow(segments);
  if (isSortMySceneHost(host)) return classifySortMyScene(segments);
  if (isLinkedInHost(host)) return classifyLinkedIn(segments);
  if (pressDomains.has(host)) return classifyPress(host, segments);
  return classifyWebsite(host);
}

function classifyLuma(segments) {
  const first = lower(segments[0]);
  if (first === "calendar" && segments[1]) {
    return eventPlatformClassification({
      platform: "luma",
      surfaceKind: "eventCalendar",
      normalizedKey: `luma:calendar:${keySegment(segments[1])}`,
      notes: "Luma calendar URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  if (["host", "u", "user"].includes(first) && segments[1]) {
    return eventPlatformClassification({
      platform: "luma",
      surfaceKind: "organizerProfile",
      normalizedKey: `luma:profile:${keySegment(segments[1])}`,
      notes: "Luma profile URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  if (segments[0]) {
    return eventPlatformClassification({
      platform: "luma",
      surfaceKind: "eventListing",
      normalizedKey: `luma:event:${keySegment(segments[0])}`,
      role: "secondary",
      notes: "Luma event URL; useful event evidence but not a recurring calendar by itself.",
    });
  }
  return otherClassification("luma", "Luma URL without a path cannot identify an organizer surface.");
}

function classifyInstagram(segments) {
  const first = lower(segments[0]);
  if (!first) return otherClassification("instagram", "Instagram URL without a handle cannot identify an organizer surface.");
  if (instagramReservedSegments.has(first)) {
    return {
      platform: "instagram",
      surfaceKind: "socialProfile",
      normalizedKey: null,
      role: "ambiguous",
      status: "candidate",
      supportsEventExtraction: false,
      notes: "Instagram content URL; capture the profile URL before using it as an identity dedupe key.",
      diagnostics: ["instagram_content_url_not_identity_surface"],
    };
  }
  const handle = first.replace(/^@/, "");
  return {
    platform: "instagram",
    surfaceKind: "socialProfile",
    normalizedKey: `instagram:${handle}`,
    role: "secondary",
    status: "candidate",
    supportsEventExtraction: false,
    notes: "Instagram profile URL; admin should confirm it is owner-controlled before publication or claim handoff.",
    diagnostics: [],
  };
}

function classifyPartiful(segments) {
  const marker = markerValue(segments, ["e", "event", "events"]);
  if (marker) {
    return eventPlatformClassification({
      platform: "partiful",
      surfaceKind: "eventListing",
      normalizedKey: `partiful:event:${keySegment(marker)}`,
      role: "secondary",
      notes: "Partiful event URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  const profile = segments[0]?.replace(/^@/, "");
  if (profile) {
    return eventPlatformClassification({
      platform: "partiful",
      surfaceKind: "organizerProfile",
      normalizedKey: `partiful:profile:${keySegment(profile)}`,
      notes: "Partiful profile URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  return otherClassification("partiful", "Partiful URL without a path cannot identify an organizer surface.");
}

function classifyDistrict(segments) {
  const event = markerValue(segments, ["event", "events", "activities", "activity"]);
  if (event) {
    return eventPlatformClassification({
      platform: "district",
      surfaceKind: "eventListing",
      normalizedKey: `district:event:${keySegment(event)}`,
      role: "secondary",
      notes: "District event URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  const profile = markerValue(segments, ["organizer", "organizers", "host", "hosts", "venue", "venues"]);
  if (profile) {
    return eventPlatformClassification({
      platform: "district",
      surfaceKind: "organizerProfile",
      normalizedKey: `district:profile:${keySegment(profile)}`,
      notes: "District organizer or venue URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  return eventPlatformClassification({
    platform: "district",
    surfaceKind: "organizerProfile",
    normalizedKey: segments[0] ? `district:profile:${pathKey(segments)}` : null,
    notes: "District URL; admin should confirm whether this is an organizer, venue, or event surface.",
    diagnostics: ["district_surface_kind_inferred_from_path"],
  });
}

function classifyBookMyShow(segments) {
  const event = markerValue(segments, ["event", "events", "activity", "activities"]);
  if (event) {
    return eventPlatformClassification({
      platform: "bookMyShow",
      surfaceKind: "eventListing",
      normalizedKey: `bookMyShow:event:${keySegment(event)}`,
      role: "secondary",
      notes: "BookMyShow event URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  const venue = markerValue(segments, ["venue", "venues"]);
  if (venue) {
    return eventPlatformClassification({
      platform: "bookMyShow",
      surfaceKind: "organizerProfile",
      normalizedKey: `bookMyShow:venue:${keySegment(venue)}`,
      notes: "BookMyShow venue URL; admin should confirm whether the venue is the canonical organizer entity.",
    });
  }
  const artist = markerValue(segments, ["artist", "artists"]);
  if (artist) {
    return eventPlatformClassification({
      platform: "bookMyShow",
      surfaceKind: "personProfile",
      normalizedKey: `bookMyShow:artist:${keySegment(artist)}`,
      notes: "BookMyShow artist profile URL; admin should confirm whether this person is the organizer entity.",
    });
  }
  return eventPlatformClassification({
    platform: "bookMyShow",
    surfaceKind: "organizerProfile",
    normalizedKey: segments[0] ? `bookMyShow:profile:${pathKey(segments)}` : null,
    notes: "BookMyShow URL; admin should confirm whether this is an organizer, venue, artist, or event surface.",
    diagnostics: ["bookmyshow_surface_kind_inferred_from_path"],
  });
}

function classifySortMyScene(segments) {
  const event = markerValue(segments, ["event", "events"]);
  if (event) {
    return eventPlatformClassification({
      platform: "sortMyScene",
      surfaceKind: "eventListing",
      normalizedKey: `sortMyScene:event:${keySegment(event)}`,
      role: "secondary",
      notes: "Sort My Scene event URL; eligible for future event discovery only after crawl policy approval.",
    });
  }
  const profile = markerValue(segments, ["organizer", "organizers", "host", "hosts", "profile", "club", "clubs"]);
  return eventPlatformClassification({
    platform: "sortMyScene",
    surfaceKind: "organizerProfile",
    normalizedKey: profile ? `sortMyScene:profile:${keySegment(profile)}` :
      (segments[0] ? `sortMyScene:profile:${pathKey(segments)}` : null),
    notes: "Sort My Scene organizer URL; eligible for future event discovery only after crawl policy approval.",
  });
}

function classifyLinkedIn(segments) {
  const first = lower(segments[0]);
  if (first === "company" && segments[1]) {
    return {
      platform: "linkedin",
      surfaceKind: "organizerProfile",
      normalizedKey: `linkedin:company:${keySegment(segments[1])}`,
      role: "secondary",
      status: "candidate",
      supportsEventExtraction: false,
      notes: "LinkedIn company URL; useful for identity context but not event discovery.",
      diagnostics: [],
    };
  }
  if (first === "in" && segments[1]) {
    return {
      platform: "linkedin",
      surfaceKind: "personProfile",
      normalizedKey: `linkedin:person:${keySegment(segments[1])}`,
      role: "ambiguous",
      status: "candidate",
      supportsEventExtraction: false,
      notes: "LinkedIn person URL; treat as supporting evidence, not a public organizer identity by itself.",
      diagnostics: [],
    };
  }
  return otherClassification("linkedin", "LinkedIn URL does not point to a supported company or person profile.");
}

function classifyPress(host, segments) {
  return {
    platform: "news",
    surfaceKind: "press",
    normalizedKey: null,
    role: "secondary",
    status: "candidate",
    supportsEventExtraction: false,
    notes: `Press URL on ${host}; useful evidence but intentionally excluded from strong identity dedupe keys.`,
    diagnostics: segments.length > 0 ? [] : ["press_homepage_not_article"],
  };
}

function classifyWebsite(host) {
  return {
    platform: "officialWebsite",
    surfaceKind: "website",
    normalizedKey: `domain:${host}`,
    role: "secondary",
    status: "candidate",
    supportsEventExtraction: false,
    notes: "Website URL; admin should confirm it belongs to the organizer before treating it as first-party.",
    diagnostics: [],
  };
}

function eventPlatformClassification(fields) {
  return {
    platform: fields.platform,
    surfaceKind: fields.surfaceKind,
    normalizedKey: clampKey(fields.normalizedKey),
    role: fields.role ?? "secondary",
    status: "candidate",
    supportsEventExtraction: true,
    notes: fields.notes,
    diagnostics: fields.diagnostics ?? [],
  };
}

function otherClassification(platform, notes) {
  return {
    platform,
    surfaceKind: "website",
    normalizedKey: null,
    role: "ambiguous",
    status: "candidate",
    supportsEventExtraction: eventPlatforms.has(platform),
    notes,
    diagnostics: ["surface_not_normalized"],
  };
}

function defaultConfidence(classification) {
  if (classification.platform === "officialWebsite") {
    return {entityMatch: "medium", ownership: "low", city: "low"};
  }
  if (classification.surfaceKind === "eventListing" || classification.surfaceKind === "eventCalendar") {
    return {entityMatch: "medium", ownership: "low", city: "medium"};
  }
  return {entityMatch: "medium", ownership: "low", city: "low"};
}

function parseSurfaceUrl(inputUrl) {
  const trimmed = String(inputUrl ?? "").trim();
  if (!trimmed) throw new TypeError("A surface URL is required.");
  if (/^https?:\/\//i.test(trimmed)) return new URL(trimmed);
  if (/^[a-z0-9.-]+\.[a-z]{2,}(?:[/:?#].*)?$/i.test(trimmed)) return new URL(`https://${trimmed}`);
  throw new TypeError(`Unsupported surface URL: ${trimmed}`);
}

function canonicalHost(rawHost) {
  const host = rawHost.toLowerCase().replace(/\.$/, "");
  const withoutWww = host.replace(/^www\./, "");
  if (withoutWww === "lu.ma") return "luma.com";
  if (["m.instagram.com", "instagram.com"].includes(withoutWww)) return "instagram.com";
  if (["m.linkedin.com", "linkedin.com"].includes(withoutWww)) return "linkedin.com";
  if (withoutWww === "bookmyshow.com" || withoutWww.endsWith(".bookmyshow.com")) {
    return "bookmyshow.com";
  }
  return withoutWww;
}

function canonicalUrlString(source, host, segments) {
  const url = new URL(source.toString());
  url.protocol = "https:";
  url.hostname = host;
  url.port = "";
  url.username = "";
  url.password = "";
  url.hash = "";
  url.pathname = segments.length > 0 ? `/${segments.map((segment) => encodeURIComponent(segment)).join("/")}` : "/";
  stripTracking(url.searchParams);
  sortSearchParams(url);
  return url.toString();
}

function stripTracking(params) {
  for (const key of [...params.keys()]) {
    const lowerKey = key.toLowerCase();
    if (lowerKey.startsWith("utm_") || trackingParams.has(lowerKey)) {
      params.delete(key);
    }
  }
}

function sortSearchParams(url) {
  const entries = [...url.searchParams.entries()].sort(([aKey, aValue], [bKey, bValue]) =>
    `${aKey}=${aValue}`.localeCompare(`${bKey}=${bValue}`)
  );
  url.search = "";
  for (const [key, value] of entries) url.searchParams.append(key, value);
}

function pathSegments(pathname) {
  return pathname
    .split("/")
    .map((segment) => decodeSegment(segment.trim()))
    .filter(Boolean);
}

function decodeSegment(segment) {
  try {
    return decodeURIComponent(segment);
  } catch {
    return segment;
  }
}

function markerValue(segments, markers) {
  const lowerSegments = segments.map(lower);
  for (const marker of markers) {
    const index = lowerSegments.indexOf(marker);
    if (index >= 0 && segments[index + 1]) return segments[index + 1];
  }
  return null;
}

function pathKey(segments) {
  return clampKey(segments.map(keySegment).filter(Boolean).join("/"));
}

function keySegment(segment) {
  return String(segment ?? "")
    .trim()
    .replace(/^@/, "")
    .toLowerCase()
    .replace(/\s+/g, "-");
}

function clampKey(value) {
  const key = String(value ?? "").trim();
  if (key.length <= 240) return key;
  const hash = crypto.createHash("sha1").update(key).digest("hex").slice(0, 12);
  return `${key.slice(0, 227)}:${hash}`;
}

function lower(value) {
  return String(value ?? "").toLowerCase();
}

function isLumaHost(host) {
  return host === "luma.com";
}

function isInstagramHost(host) {
  return host === "instagram.com";
}

function isPartifulHost(host) {
  return host === "partiful.com";
}

function isDistrictHost(host) {
  return host === "district.in";
}

function isBookMyShowHost(host) {
  return host === "bookmyshow.com";
}

function isSortMySceneHost(host) {
  return host === "sortmyscene.com";
}

function isLinkedInHost(host) {
  return host === "linkedin.com";
}
