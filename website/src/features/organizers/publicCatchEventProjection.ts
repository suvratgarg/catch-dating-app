import type {HostListing} from "./types";

type PublicCatchEvent = NonNullable<HostListing["catchEvents"]>[number];
export interface LivePublicCatchEvent {
  organizerId: string;
  event: PublicCatchEvent;
}
const activityTitles: Record<string, string> = {
  socialRun: "Social run", pickleball: "Pickleball social", padel: "Padel social",
  tennis: "Tennis social", badminton: "Badminton social", pubQuiz: "Pub quiz",
  dinner: "Dinner social", barCrawl: "Bar crawl", singlesMixer: "Singles mixer",
  openActivity: "Hosted event",
};
const record = (value: unknown): Record<string, unknown> | null =>
  value !== null && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown> : null;
const count = (value: unknown): value is number => Number.isSafeInteger(value) && Number(value) >= 0;
const text = (value: unknown): string => typeof value === "string" ? value : "";
function millis(value: unknown): number | null {
  const timestamp = record(value);
  if (typeof timestamp?.toMillis !== "function") return null;
  try {
    const result: unknown = timestamp.toMillis();
    return typeof result === "number" && Number.isFinite(result) ? result : null;
  } catch { return null; }
}

/** A bounded display projection. Booking rechecks live terms on the server. */
export function projectLivePublicCatchEvent(id: string, raw: unknown,
  now = Date.now()): LivePublicCatchEvent | null {
  const data = record(raw);
  // Filter before reading rich fields: a private draft need not have them.
  if (!data || data.publicationState !== "published" || data.status !== "active") return null;
  const organizerId = text(data.organizerId || data.clubId);
  if (!/^[A-Za-z0-9][A-Za-z0-9_-]{0,179}$/u.test(id) ||
      !/^[A-Za-z0-9][A-Za-z0-9_-]{0,179}$/u.test(organizerId) ||
      data.organizerId && data.clubId && data.organizerId !== data.clubId) return null;
  const start = millis(data.startTime);
  const end = millis(data.endTime);
  const venue = record(data.meetingLocation);
  const location = text(venue?.name || data.meetingPoint);
  const format = record(data.eventFormat);
  const activityKind = text(format?.activityKind);
  const currency = text(data.currency);
  if (start === null || end === null || end <= start || !location ||
      !activityKind || !count(data.capacityLimit) || data.capacityLimit < 1 ||
      !count(data.bookedCount) || !count(data.priceInPaise) ||
      data.priceInPaise > 100_000_000 || !/^[A-Z]{3}$/u.test(currency)) return null;
  const timezone = text(data.eventTimezone) || "Asia/Kolkata";
  const policy = record(data.eventPolicy);
  const admission = record(policy?.admission);
  const pricing = record(policy?.pricing);
  const constraints = record(data.constraints);
  const hasValues = (value: unknown) => Object.keys(record(value) ?? {}).length > 0;
  const restricted = (data.crossPathsPairHeldCount ?? 0) !== 0 ||
    (data.crossPathsPairConfirmedCount ?? 0) !== 0 ||
    Object.values(record(data.crossPathsPairHeldCohortCounts) ?? {}).some((value) => value !== 0) ||
    constraints?.maxMen != null || constraints?.maxWomen != null ||
    Boolean(policy && (!admission || !pricing || pricing.basePriceInPaise !== data.priceInPaise ||
      admission.format !== "open" || admission.inviteRequired || admission.membershipRequired ||
      admission.manualApprovalRequired || record(admission.privateAccessPolicy)?.mode !== "none" ||
      record(admission.crossPathsPairInventory)?.enabled || admission.balancedRatioPolicy != null ||
      hasValues(admission.cohortCapacityLimits) || hasValues(pricing.cohortAdjustmentsInPaise) ||
      Array.isArray(pricing.demandPricingRules) && pricing.demandPricingRules.length > 0));
  const mode = !restricted && data.publicRegistrationEnabled === true
    ? data.publicRegistrationMode ?? "free" : "closed";
  if (mode !== "closed" && mode !== "free" && mode !== "paid") return null;
  if (mode === "free" && data.priceInPaise !== 0 ||
      mode === "paid" && (data.priceInPaise < 100 || currency !== "INR")) return null;
  try {
    const dates = new Intl.DateTimeFormat("en-IN", {
      timeZone: timezone, dateStyle: "medium", timeStyle: "short",
    });
    return {organizerId, event: {
      id, role: "Hosted event", title: text(data.name).trim() || text(format?.customActivityLabel).trim() ||
        activityTitles[activityKind] || "Hosted event",
      activityKind, timeline: end >= now ? "upcoming" : "past",
      startTime: new Date(start).toISOString(), endTime: new Date(end).toISOString(),
      timezone, date: `${dates.format(start)} – ${dates.format(end)}`,
      location, locationDetails: text(venue?.notes || data.locationDetails),
      summary: text(data.description), capacityLimit: data.capacityLimit,
      bookedCount: data.bookedCount,
      checkedInCount: count(data.checkedInCount) ? data.checkedInCount : 0,
      waitlistedCount: count(data.waitlistedCount) ? data.waitlistedCount : 0,
      publicRegistrationEnabled: mode !== "closed", registrationMode: mode,
      amountPaise: data.priceInPaise, currency,
      priceLabel: data.priceInPaise === 0 ? "Free" :
        new Intl.NumberFormat("en-IN", {style: "currency", currency,
          maximumFractionDigits: data.priceInPaise % 100 === 0 ? 0 : 2})
          .format(data.priceInPaise / 100),
    }};
  } catch {
    return null;
  }
}

/** Reject local/pending snapshots before decoding any event contents. */
export function projectPublicCatchEventSnapshot(snapshot: {
  metadata: {fromCache: boolean; hasPendingWrites: boolean};
  size: number;
  docs: readonly {id: string; data(): unknown}[];
}): LivePublicCatchEvent[] | null {
  if (snapshot.metadata.fromCache || snapshot.metadata.hasPendingWrites || snapshot.size > 400) return null;
  return snapshot.docs.flatMap((document) => {
    const projected = projectLivePublicCatchEvent(document.id, document.data());
    return projected ? [projected] : [];
  });
}
