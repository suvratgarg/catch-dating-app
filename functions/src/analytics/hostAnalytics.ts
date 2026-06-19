import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {requireAdminRole} from "../admin/adminAuth";
import {writeAdminAuditLog} from "../admin/adminAudit";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {
  ClubDocument,
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  HostAnalyticsQueryCallablePayload,
} from "../shared/generated/hostAnalyticsQueryCallablePayload";
import {
  HostAnalyticsCallableResponse,
} from "../shared/generated/hostAnalyticsCallableResponse";
import {
  validateHostAnalyticsCallableResponse,
  validateHostAnalyticsQueryCallablePayload,
} from "../shared/generated/schemaValidators";
import {isClubHost} from "../shared/clubHosts";
import {
  defaultHostAnalyticsBigQuerySource,
  HostAnalyticsBigQuerySource,
  HostAnalyticsMartRow,
} from "./hostAnalyticsBigQuery";

type AnalyticsGranularity = "day" | "week" | "month";
type QueryScope = "host" | "admin";

interface HostAnalyticsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  now: () => Date;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  bigQuerySource: HostAnalyticsBigQuerySource;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

interface AnalyticsRange {
  start: Date;
  endExclusive: Date;
  granularity: AnalyticsGranularity;
  preset: string | null;
}

interface ClubRecord {
  id: string;
  data: ClubDocument;
}

interface EventRecord {
  id: string;
  data: EventDocument;
}

interface AnalyticsRecords {
  clubs: ClubRecord[];
  events: EventRecord[];
  martRows: HostAnalyticsMartRow[];
}

interface EventMetricAccumulator {
  eventId: string;
  clubId: string;
  title: string;
  startTime: Date;
  status: string;
  capacityLimit: number;
  bookedCount: number;
  checkedInCount: number;
  waitlistedCount: number;
  grossRevenueMinor: number;
  currency: string;
  checkoutStartedCount: number;
  checkoutDropoffCount: number;
  paymentCompletedCount: number;
  paymentFailedCount: number;
  paymentRefundedCount: number;
  reviewCount: number;
  ratingTotal: number;
  verifiedReviewCount: number;
  publicReviewCount: number;
  ownerResponseCount: number;
  demandCount: number;
  inviteOpenCount: number;
  mutualMatchCount: number;
  chatStartedCount: number;
  repeatAttendeeCount: number;
  eventSaveCount: number;
}

const maxHostClubs = 25;
const maxHostEventsPerClub = 500;
const maxAdminClubs = 100;
const maxAdminEvents = 1000;

const defaultDeps: HostAnalyticsDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  bigQuerySource: defaultHostAnalyticsBigQuerySource,
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Returns aggregate analytics for clubs hosted by the signed-in user.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {HostAnalyticsDeps} deps Injectable dependencies.
 * @return {Promise<HostAnalyticsCallableResponse>} Host analytics payload.
 */
export async function getHostAnalyticsHandler(
  request: CallableRequest<unknown>,
  deps: HostAnalyticsDeps = defaultDeps
): Promise<HostAnalyticsCallableResponse> {
  const uid = requireAuth(request);
  const payload = validateAnalyticsPayload(request);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "getHostAnalytics");
  return loadHostAnalytics(db, payload, deps.now(), "host", uid, deps);
}

/**
 * Returns aggregate analytics for admin dashboard readers.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {HostAnalyticsDeps} deps Injectable dependencies.
 * @return {Promise<HostAnalyticsCallableResponse>} Admin analytics payload.
 */
export async function adminGetHostAnalyticsHandler(
  request: CallableRequest<unknown>,
  deps: HostAnalyticsDeps = defaultDeps
): Promise<HostAnalyticsCallableResponse> {
  const adminContext = requireAdminRole(
    request,
    ["adminOwner", "analyticsViewer"]
  );
  const payload = validateAnalyticsPayload(request);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, adminContext.uid, "adminGetHostAnalytics");
  const response = await loadHostAnalytics(
    db,
    payload,
    deps.now(),
    "admin",
    adminContext.uid,
    deps
  );
  await writeAdminAuditLog(db, adminContext, {
    action: "adminGetHostAnalytics",
    targetPath: adminAnalyticsTargetPath(payload),
    request,
    serverTimestamp: deps.serverTimestamp,
  });
  return response;
}

export const getHostAnalytics = onCall(appCheckCallableOptions, (request) =>
  getHostAnalyticsHandler(request)
);

export const adminGetHostAnalytics = onCall(
  appCheckCallableOptions,
  (request) => adminGetHostAnalyticsHandler(request)
);

/**
 * Resolves an analytics range from a callable payload.
 * @param {HostAnalyticsQueryCallablePayload} payload Analytics query payload.
 * @param {Date} now Current time.
 * @return {AnalyticsRange} Inclusive start and exclusive end range.
 */
export function resolveAnalyticsRange(
  payload: HostAnalyticsQueryCallablePayload,
  now: Date
): AnalyticsRange {
  const preset = payload.rangePreset ?? "30d";
  const today = startOfUtcDay(now);
  let start = new Date(today);
  let endExclusive = addUtcDays(today, 1);

  if (preset === "7d") {
    start = addUtcDays(today, -6);
  } else if (preset === "30d") {
    start = addUtcDays(today, -29);
  } else if (preset === "90d") {
    start = addUtcDays(today, -89);
  } else if (preset === "month") {
    start = new Date(Date.UTC(
      today.getUTCFullYear(),
      today.getUTCMonth(),
      1
    ));
  } else if (preset === "custom") {
    if (!payload.startDate || !payload.endDate) {
      throw new HttpsError(
        "invalid-argument",
        "Custom analytics ranges require startDate and endDate."
      );
    }
    start = parseUtcDate(payload.startDate, "startDate");
    endExclusive = addUtcDays(parseUtcDate(payload.endDate, "endDate"), 1);
  }

  if (endExclusive.getTime() <= start.getTime()) {
    throw new HttpsError(
      "invalid-argument",
      "Analytics endDate must be on or after startDate."
    );
  }

  const rangeDays = Math.ceil(
    (endExclusive.getTime() - start.getTime()) / 86400000
  );
  if (rangeDays > 366) {
    throw new HttpsError(
      "invalid-argument",
      "Analytics ranges cannot exceed 366 days."
    );
  }

  return {
    start,
    endExclusive,
    granularity: payload.granularity ?? defaultGranularity(rangeDays),
    preset,
  };
}

/**
 * Builds a host-safe aggregate response from authorized scope and
 * BigQuery rows.
 * @param {AnalyticsRecords} records Authorized Firestore scope + BigQuery rows.
 * @param {AnalyticsRange} range Analytics time range.
 * @param {Date} now Current time.
 * @return {HostAnalyticsCallableResponse} Aggregate response.
 */
export function buildHostAnalyticsFromRecords(
  records: AnalyticsRecords,
  range: AnalyticsRange,
  now: Date
): HostAnalyticsCallableResponse {
  const rows = records.martRows.filter((row) =>
    dailyRowInRange(row, range)
  );
  const clubIds = uniqueStrings(records.clubs.map((club) => club.id));
  const eventIds = resolveScopeEventIds(records, rows);
  const eventMetrics = eventMetricsFromRows(rows, records.events);
  const topEvents = [...eventMetrics]
    .sort((a, b) => b.startTime.getTime() - a.startTime.getTime())
    .slice(0, 25);
  const totals = summarizeEventMetrics(eventMetrics);
  const discoverySummary = summarizeDiscovery(rows);
  const reviewSummary = summarizeReviews(rows);
  const sourceStatus = rows.length === 0 ? "missing" : "ready";
  const response: HostAnalyticsCallableResponse = {
    generatedAt: now.toISOString(),
    timezone: "UTC",
    range: {
      startDate: range.start.toISOString(),
      endDate: addUtcMilliseconds(range.endExclusive, -1).toISOString(),
      granularity: range.granularity,
      preset: range.preset,
    },
    scope: {
      clubIds,
      eventIds,
      clubName: resolveClubName(records, rows),
      eventTitle: resolveEventTitle(records, eventMetrics),
    },
    summaryCards: [
      metricCard(
        "listingViews",
        "Listing views",
        discoverySummary.listingViews,
        "count",
        sourceStatus,
        "From BigQuery host analytics events and marts."
      ),
      metricCard(
        "eventViews",
        "Event views",
        discoverySummary.eventViews,
        "count",
        sourceStatus,
        "From BigQuery host analytics events and marts."
      ),
      metricCard("bookings", "Bookings", totals.booked, "count", sourceStatus),
      metricCard(
        "attendanceRate",
        "Attendance",
        percentage(totals.checkedIn, totals.booked),
        "percent",
        sourceStatus
      ),
      metricCard(
        "revenue",
        "Revenue",
        totals.revenue,
        "money_minor",
        sourceStatus
      ),
      metricCard(
        "checkoutDropoff",
        "Checkout drop-off",
        totals.checkoutDropoff,
        "count",
        sourceStatus
      ),
      metricCard(
        "checkoutConversionRate",
        "Checkout conversion",
        percentage(totals.paymentCompleted, totals.checkoutStarted),
        "percent",
        sourceStatus
      ),
      metricCard(
        "newReviews",
        "New reviews",
        reviewSummary.newReviews,
        "count",
        sourceStatus
      ),
      metricCard(
        "connections",
        "Connections",
        totals.matches,
        "count",
        sourceStatus
      ),
      metricCard(
        "chats",
        "Chats started",
        totals.chats,
        "count",
        sourceStatus
      ),
    ],
    trend: buildTrend(rows, range),
    topEvents: topEvents.map((event) => ({
      eventId: event.eventId,
      clubId: event.clubId,
      title: event.title,
      startTime: event.startTime.toISOString(),
      status: event.status,
      capacityLimit: event.capacityLimit,
      bookedCount: event.bookedCount,
      checkedInCount: event.checkedInCount,
      waitlistedCount: event.waitlistedCount,
      fillRate: percentage(event.bookedCount, event.capacityLimit),
      checkInRate: percentage(event.checkedInCount, event.bookedCount),
      grossRevenueMinor: event.grossRevenueMinor,
      currency: event.currency,
      checkoutStartedCount: event.checkoutStartedCount,
      checkoutDropoffCount: event.checkoutDropoffCount,
      paymentCompletedCount: event.paymentCompletedCount,
      paymentFailedCount: event.paymentFailedCount,
      paymentRefundedCount: event.paymentRefundedCount,
      reviewCount: event.reviewCount,
      averageRating: event.reviewCount === 0 ?
        0 :
        round(event.ratingTotal / event.reviewCount),
      demandCount: event.demandCount,
      inviteOpenCount: event.inviteOpenCount,
      mutualMatchCount: event.mutualMatchCount,
      chatStartedCount: event.chatStartedCount,
      repeatAttendeeCount: event.repeatAttendeeCount,
    })),
    reviewSummary,
    discoverySummary,
    dataQuality: dataQualityRows(rows),
  };
  assertValidResponse(response);
  return response;
}

async function loadHostAnalytics(
  db: FirebaseFirestore.Firestore,
  payload: HostAnalyticsQueryCallablePayload,
  now: Date,
  scope: QueryScope,
  uid: string,
  deps: HostAnalyticsDeps
): Promise<HostAnalyticsCallableResponse> {
  const range = resolveAnalyticsRange(payload, now);
  const clubs = await resolveClubs(db, payload, scope, uid);
  const events = await resolveEvents(db, payload, clubs, range, scope);
  const martRows = await deps.bigQuerySource.loadRows(
    {
      startDate: dateKey(range.start),
      endDate: dateKey(addUtcMilliseconds(range.endExclusive, -1)),
    },
    {
      clubIds: clubs.map((club) => club.id),
      eventId: payload.eventId ?? null,
    },
  );
  return buildHostAnalyticsFromRecords({clubs, events, martRows}, range, now);
}

function validateAnalyticsPayload(
  request: CallableRequest<unknown>
): HostAnalyticsQueryCallablePayload {
  return validateCallableWithAjv<HostAnalyticsQueryCallablePayload>(
    request,
    validateHostAnalyticsQueryCallablePayload,
    normalizeAnalyticsPayload
  );
}

function normalizeAnalyticsPayload(data: unknown): unknown {
  if (data == null || typeof data !== "object" || Array.isArray(data)) {
    return {};
  }
  const input = data as Record<string, unknown>;
  return {
    ...input,
    clubId: nullableTrimmedString(input.clubId),
    eventId: nullableTrimmedString(input.eventId),
    startDate: nullableTrimmedString(input.startDate),
    endDate: nullableTrimmedString(input.endDate),
  };
}

async function resolveClubs(
  db: FirebaseFirestore.Firestore,
  payload: HostAnalyticsQueryCallablePayload,
  scope: QueryScope,
  uid: string
): Promise<ClubRecord[]> {
  if (payload.eventId) {
    const eventSnap = await db.collection("events").doc(payload.eventId).get();
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = eventSnap.data() as EventDocument;
    const club = await getClubRecord(db, event.clubId);
    assertCanReadClub(club, scope, uid);
    return [club];
  }

  if (payload.clubId) {
    const club = await getClubRecord(db, payload.clubId);
    assertCanReadClub(club, scope, uid);
    return [club];
  }

  if (scope === "admin") {
    const snap = await db.collection("clubs").limit(maxAdminClubs).get();
    return snap.docs.map((doc) => ({
      id: doc.id,
      data: doc.data() as ClubDocument,
    }));
  }

  const snapshots = await Promise.all([
    db.collection("clubs")
      .where("hostUserIds", "array-contains", uid)
      .limit(maxHostClubs)
      .get(),
    db.collection("clubs")
      .where("ownerUserId", "==", uid)
      .limit(maxHostClubs)
      .get(),
    db.collection("clubs")
      .where("hostUserId", "==", uid)
      .limit(maxHostClubs)
      .get(),
  ]);
  const byId = new Map<string, ClubRecord>();
  for (const snapshot of snapshots) {
    for (const doc of snapshot.docs) {
      byId.set(doc.id, {id: doc.id, data: doc.data() as ClubDocument});
    }
  }
  return [...byId.values()].slice(0, maxHostClubs);
}

async function resolveEvents(
  db: FirebaseFirestore.Firestore,
  payload: HostAnalyticsQueryCallablePayload,
  clubs: ClubRecord[],
  range: AnalyticsRange,
  scope: QueryScope
): Promise<EventRecord[]> {
  if (payload.eventId) {
    const snap = await db.collection("events").doc(payload.eventId).get();
    if (!snap.exists) throw new HttpsError("not-found", "Event not found.");
    return [{id: snap.id, data: snap.data() as EventDocument}];
  }

  if (scope === "admin" && !payload.clubId) {
    const snap = await db.collection("events")
      .where("startTime", ">=", admin.firestore.Timestamp.fromDate(
        range.start
      ))
      .where("startTime", "<", admin.firestore.Timestamp.fromDate(
        range.endExclusive
      ))
      .limit(maxAdminEvents)
      .get();
    return snap.docs.map((doc) => ({
      id: doc.id,
      data: doc.data() as EventDocument,
    }));
  }

  const eventSnapshots = await Promise.all(
    clubs.map((club) => db.collection("events")
      .where("clubId", "==", club.id)
      .limit(maxHostEventsPerClub)
      .get())
  );
  return eventSnapshots.flatMap((snapshot) => snapshot.docs.map((doc) => ({
    id: doc.id,
    data: doc.data() as EventDocument,
  }))).filter((event) => {
    const startTime = timestampToDate(event.data.startTime);
    return startTime !== null && inRange(startTime, range);
  });
}

async function getClubRecord(
  db: FirebaseFirestore.Firestore,
  clubId: string
): Promise<ClubRecord> {
  const clubSnap = await db.collection("clubs").doc(clubId).get();
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  return {id: clubSnap.id, data: clubSnap.data() as ClubDocument};
}

function assertCanReadClub(
  club: ClubRecord,
  scope: QueryScope,
  uid: string
): void {
  if (scope === "admin") return;
  if (isClubHost(club.data, uid)) return;
  throw new HttpsError(
    "permission-denied",
    "Only this club's host team can read host analytics."
  );
}

function eventMetricsFromRows(
  rows: HostAnalyticsMartRow[],
  events: EventRecord[]
): EventMetricAccumulator[] {
  const eventMap = new Map(events.map((event) => [event.id, event]));
  const byEvent = new Map<string, EventMetricAccumulator>();
  for (const row of rows) {
    if (!row.eventId) continue;
    const existing = byEvent.get(row.eventId);
    const fallbackEvent = eventMap.get(row.eventId) ?? null;
    if (!existing) {
      byEvent.set(row.eventId, {
        eventId: row.eventId,
        clubId: row.clubId,
        title: row.eventTitle ?? fallbackEventTitle(fallbackEvent),
        startTime: parseDate(row.eventStartTime) ??
          timestampToDate(fallbackEvent?.data.startTime) ??
          parseDailyDate(row.date),
        status: row.eventStatus ?? fallbackEvent?.data.status ?? "unknown",
        capacityLimit: Math.max(0, Math.trunc(row.capacityLimit)),
        bookedCount: Math.max(0, Math.trunc(row.bookedCount)),
        checkedInCount: Math.max(0, Math.trunc(row.checkedInCount)),
        waitlistedCount: Math.max(0, Math.trunc(row.waitlistedCount)),
        grossRevenueMinor: Math.max(0, Math.trunc(row.grossRevenueMinor)),
        currency: row.currency ?? fallbackEvent?.data.currency ?? "INR",
        checkoutStartedCount: Math.max(
          0,
          Math.trunc(row.checkoutStartedCount)
        ),
        checkoutDropoffCount: Math.max(
          0,
          Math.trunc(row.checkoutDropoffCount)
        ),
        paymentCompletedCount: Math.max(
          0,
          Math.trunc(row.paymentCompletedCount)
        ),
        paymentFailedCount: Math.max(0, Math.trunc(row.paymentFailedCount)),
        paymentRefundedCount: Math.max(0, Math.trunc(row.paymentRefundedCount)),
        reviewCount: Math.max(0, Math.trunc(row.reviewCount)),
        ratingTotal: Math.max(0, row.ratingTotal),
        verifiedReviewCount: Math.max(0, Math.trunc(
          row.verifiedReviewCount ?? 0
        )),
        publicReviewCount: Math.max(
          0,
          Math.trunc(row.publicReviewCount ?? 0)
        ),
        ownerResponseCount: Math.max(
          0,
          Math.trunc(row.ownerResponseCount ?? 0)
        ),
        demandCount: Math.max(0, Math.trunc(row.demandCount)),
        inviteOpenCount: Math.max(0, Math.trunc(row.inviteOpenCount)),
        mutualMatchCount: Math.max(0, Math.trunc(row.mutualMatchCount)),
        chatStartedCount: Math.max(0, Math.trunc(row.chatStartedCount)),
        repeatAttendeeCount: Math.max(0, Math.trunc(row.repeatAttendeeCount)),
        eventSaveCount: Math.max(0, Math.trunc(row.eventSaves)),
      });
      continue;
    }
    existing.capacityLimit = Math.max(
      existing.capacityLimit,
      row.capacityLimit
    );
    existing.bookedCount += Math.max(0, Math.trunc(row.bookedCount));
    existing.checkedInCount += Math.max(0, Math.trunc(row.checkedInCount));
    existing.waitlistedCount += Math.max(0, Math.trunc(row.waitlistedCount));
    existing.grossRevenueMinor += Math.max(
      0,
      Math.trunc(row.grossRevenueMinor)
    );
    existing.checkoutStartedCount += Math.max(
      0,
      Math.trunc(row.checkoutStartedCount)
    );
    existing.checkoutDropoffCount += Math.max(
      0,
      Math.trunc(row.checkoutDropoffCount)
    );
    existing.paymentCompletedCount += Math.max(
      0,
      Math.trunc(row.paymentCompletedCount)
    );
    existing.paymentFailedCount += Math.max(
      0,
      Math.trunc(row.paymentFailedCount)
    );
    existing.paymentRefundedCount += Math.max(
      0,
      Math.trunc(row.paymentRefundedCount)
    );
    existing.reviewCount += Math.max(0, Math.trunc(row.reviewCount));
    existing.ratingTotal += Math.max(0, row.ratingTotal);
    existing.verifiedReviewCount += Math.max(
      0,
      Math.trunc(row.verifiedReviewCount ?? 0)
    );
    existing.publicReviewCount += Math.max(
      0,
      Math.trunc(row.publicReviewCount ?? 0)
    );
    existing.ownerResponseCount += Math.max(
      0,
      Math.trunc(row.ownerResponseCount ?? 0)
    );
    existing.demandCount += Math.max(0, Math.trunc(row.demandCount));
    existing.inviteOpenCount += Math.max(0, Math.trunc(row.inviteOpenCount));
    existing.mutualMatchCount += Math.max(0, Math.trunc(row.mutualMatchCount));
    existing.chatStartedCount += Math.max(0, Math.trunc(row.chatStartedCount));
    existing.repeatAttendeeCount += Math.max(
      0,
      Math.trunc(row.repeatAttendeeCount)
    );
    existing.eventSaveCount += Math.max(0, Math.trunc(row.eventSaves));
  }
  return [...byEvent.values()];
}

function summarizeEventMetrics(events: EventMetricAccumulator[]) {
  return events.reduce((sum, event) => ({
    booked: sum.booked + event.bookedCount,
    checkedIn: sum.checkedIn + event.checkedInCount,
    revenue: sum.revenue + event.grossRevenueMinor,
    checkoutStarted: sum.checkoutStarted + event.checkoutStartedCount,
    checkoutDropoff: sum.checkoutDropoff + event.checkoutDropoffCount,
    paymentCompleted: sum.paymentCompleted + event.paymentCompletedCount,
    matches: sum.matches + event.mutualMatchCount,
    chats: sum.chats + event.chatStartedCount,
  }), {
    booked: 0,
    checkedIn: 0,
    revenue: 0,
    checkoutStarted: 0,
    checkoutDropoff: 0,
    paymentCompleted: 0,
    matches: 0,
    chats: 0,
  });
}

function summarizeReviews(
  rows: HostAnalyticsMartRow[]
): HostAnalyticsCallableResponse["reviewSummary"] {
  const totals = rows.reduce((sum, row) => ({
    reviews: sum.reviews + intValue(row.reviewCount),
    ratingTotal: sum.ratingTotal + Math.max(0, row.ratingTotal),
    verifiedReviews: sum.verifiedReviews + intValue(row.verifiedReviewCount),
    publicReviews: sum.publicReviews + intValue(row.publicReviewCount),
    ownerResponses: sum.ownerResponses + intValue(row.ownerResponseCount),
  }), {
    reviews: 0,
    ratingTotal: 0,
    verifiedReviews: 0,
    publicReviews: 0,
    ownerResponses: 0,
  });

  return {
    newReviews: totals.reviews,
    publishedReviews: totals.reviews,
    verifiedReviews: totals.verifiedReviews,
    publicReviews: totals.publicReviews,
    ownerResponseCount: totals.ownerResponses,
    averageRating: totals.reviews === 0 ?
      0 :
      round(totals.ratingTotal / totals.reviews),
  };
}

function summarizeDiscovery(
  rows: HostAnalyticsMartRow[]
): HostAnalyticsCallableResponse["discoverySummary"] {
  return rows.reduce((sum, row) => ({
    listingViews: sum.listingViews + intValue(row.listingViews),
    searchAppearances: sum.searchAppearances + intValue(row.searchAppearances),
    eventViews: sum.eventViews + intValue(row.eventViews),
    organizerSaves: sum.organizerSaves + intValue(row.organizerSaves),
    eventSaves: sum.eventSaves + intValue(row.eventSaves),
    contactClicks: sum.contactClicks + intValue(row.contactClicks),
    claimClicks: sum.claimClicks + intValue(row.claimClicks),
    outboundClicks: sum.outboundClicks + intValue(row.outboundClicks),
  }), {
    listingViews: 0,
    searchAppearances: 0,
    eventViews: 0,
    organizerSaves: 0,
    eventSaves: 0,
    contactClicks: 0,
    claimClicks: 0,
    outboundClicks: 0,
  });
}

function buildTrend(
  rows: HostAnalyticsMartRow[],
  range: AnalyticsRange
): HostAnalyticsCallableResponse["trend"] {
  const buckets = trendBuckets(range);
  for (const row of rows) {
    const rowDate = parseDailyDate(row.date);
    const bucket = bucketFor(buckets, rowDate);
    if (!bucket) continue;
    bucket.metrics.eventCount += row.eventId ? 1 : 0;
    bucket.metrics.bookings += intValue(row.bookedCount);
    bucket.metrics.checkedIn += intValue(row.checkedInCount);
    bucket.metrics.revenueMinor += intValue(row.grossRevenueMinor);
    bucket.metrics.checkoutStarted += intValue(row.checkoutStartedCount);
    bucket.metrics.checkoutDropoff += intValue(row.checkoutDropoffCount);
    bucket.metrics.demand += intValue(row.demandCount);
    bucket.metrics.reviews += intValue(row.reviewCount);
    bucket.metrics.matches += intValue(row.mutualMatchCount);
    bucket.metrics.chats += intValue(row.chatStartedCount);
    bucket.metrics.eventSaves += intValue(row.eventSaves);
    bucket.metrics.listingViews += intValue(row.listingViews);
    bucket.metrics.eventViews += intValue(row.eventViews);
    bucket.metrics.organizerSaves += intValue(row.organizerSaves);
  }
  return buckets.map((bucket) => ({
    periodStart: bucket.periodStart.toISOString(),
    periodEnd: addUtcMilliseconds(bucket.periodEndExclusive, -1)
      .toISOString(),
    metrics: bucket.metrics,
  }));
}

function dataQualityRows(
  rows: HostAnalyticsMartRow[]
): HostAnalyticsCallableResponse["dataQuality"] {
  const discoveryRows = rows.filter((row) =>
    row.listingViews > 0 ||
    row.searchAppearances > 0 ||
    row.eventViews > 0 ||
    row.organizerSaves > 0 ||
    row.eventSaves > 0
  ).length;
  const businessRows = rows.filter((row) =>
    row.bookedCount > 0 ||
    row.checkedInCount > 0 ||
    row.checkoutStartedCount > 0 ||
    row.paymentCompletedCount > 0 ||
    row.reviewCount > 0
  ).length;
  return [
    {
      id: "bigquery-host-mart",
      state: rows.length === 0 ? "missing" : "ok",
      detail: rows.length === 0 ?
        "No BigQuery host analytics mart rows were returned for this scope." :
        "Host analytics are served from BigQuery mart rows.",
    },
    {
      id: "client-behavior-events",
      state: discoveryRows === 0 ? "missing" : "ok",
      detail:
        "Listing views, search appearances, event views, saves, and clicks " +
        "come from GA4/direct BigQuery host analytics events.",
    },
    {
      id: "server-business-facts",
      state: businessRows === 0 ? "missing" : "ok",
      detail:
        "Bookings, payments, attendance, reviews, matches, and chats come " +
        "from BigQuery marts derived from server-owned business facts.",
    },
    {
      id: "firestore-cache",
      state: "ok",
      detail:
        "Firestore is used only for host authorization and optional " +
        "snapshots; " +
        "it is not the analytics source of truth.",
    },
  ];
}

function metricCard(
  id: string,
  label: string,
  value: number,
  unit: HostAnalyticsCallableResponse["summaryCards"][number]["unit"],
  status: HostAnalyticsCallableResponse["summaryCards"][number]["status"],
  caption: string | null = null
): HostAnalyticsCallableResponse["summaryCards"][number] {
  return {id, label, value, unit, status, caption};
}

function trendBuckets(range: AnalyticsRange): Array<{
  periodStart: Date;
  periodEndExclusive: Date;
  metrics: Record<string, number>;
}> {
  const buckets: Array<{
    periodStart: Date;
    periodEndExclusive: Date;
    metrics: Record<string, number>;
  }> = [];
  let cursor = startOfBucket(range.start, range.granularity);
  while (cursor.getTime() < range.endExclusive.getTime()) {
    const next = nextBucket(cursor, range.granularity);
    buckets.push({
      periodStart: maxDate(cursor, range.start),
      periodEndExclusive: minDate(next, range.endExclusive),
      metrics: {
        eventCount: 0,
        bookings: 0,
        checkedIn: 0,
        revenueMinor: 0,
        checkoutStarted: 0,
        checkoutDropoff: 0,
        demand: 0,
        reviews: 0,
        matches: 0,
        chats: 0,
        eventSaves: 0,
        listingViews: 0,
        eventViews: 0,
        organizerSaves: 0,
      },
    });
    cursor = next;
  }
  return buckets;
}

function bucketFor(
  buckets: Array<{
    periodStart: Date;
    periodEndExclusive: Date;
    metrics: Record<string, number>;
  }>,
  date: Date
): {
  periodStart: Date;
  periodEndExclusive: Date;
  metrics: Record<string, number>;
} | null {
  return buckets.find((bucket) =>
    date.getTime() >= bucket.periodStart.getTime() &&
    date.getTime() < bucket.periodEndExclusive.getTime()
  ) ?? null;
}

function resolveScopeEventIds(
  records: AnalyticsRecords,
  rows: HostAnalyticsMartRow[]
): string[] {
  const authorized = records.events.map((event) => event.id);
  if (authorized.length > 0) return uniqueStrings(authorized);
  return uniqueStrings(rows.flatMap((row) =>
    row.eventId ? [row.eventId] : []
  ));
}

function resolveClubName(
  records: AnalyticsRecords,
  rows: HostAnalyticsMartRow[]
): string | null {
  if (records.clubs.length === 1) {
    return records.clubs[0].data.name;
  }
  const rowNames = uniqueStrings(rows.flatMap((row) =>
    row.clubName ? [row.clubName] : []
  ));
  return rowNames.length === 1 ? rowNames[0] : null;
}

function resolveEventTitle(
  records: AnalyticsRecords,
  events: EventMetricAccumulator[]
): string | null {
  if (events.length === 1) return events[0].title;
  if (records.events.length === 1) return fallbackEventTitle(records.events[0]);
  return null;
}

function fallbackEventTitle(event: EventRecord | null): string {
  if (!event) return "Event";
  const format = event.data.eventFormat;
  const activity = format.customActivityLabel?.trim() ||
    activityLabel(format.activityKind);
  const date = timestampToDate(event.data.startTime);
  if (!date) return activity;
  return `${activity} · ${date.toISOString().slice(0, 10)}`;
}

function activityLabel(kind: string): string {
  return kind
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/^./, (value) => value.toUpperCase());
}

function startOfBucket(date: Date, granularity: AnalyticsGranularity): Date {
  if (granularity === "month") {
    return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), 1));
  }
  const start = startOfUtcDay(date);
  if (granularity === "week") {
    const day = start.getUTCDay();
    const mondayOffset = day === 0 ? -6 : 1 - day;
    return addUtcDays(start, mondayOffset);
  }
  return start;
}

function nextBucket(date: Date, granularity: AnalyticsGranularity): Date {
  if (granularity === "month") {
    return new Date(Date.UTC(
      date.getUTCFullYear(),
      date.getUTCMonth() + 1,
      1
    ));
  }
  return addUtcDays(date, granularity === "week" ? 7 : 1);
}

function inRange(date: Date, range: AnalyticsRange): boolean {
  return date.getTime() >= range.start.getTime() &&
    date.getTime() < range.endExclusive.getTime();
}

function dailyRowInRange(
  row: HostAnalyticsMartRow,
  range: AnalyticsRange
): boolean {
  return inRange(parseDailyDate(row.date), range);
}

function parseDailyDate(value: string): Date {
  const millis = Date.parse(`${value}T00:00:00.000Z`);
  return Number.isFinite(millis) ? new Date(millis) : new Date(0);
}

function parseDate(value: string | null): Date | null {
  if (!value) return null;
  const millis = Date.parse(value);
  return Number.isFinite(millis) ? new Date(millis) : null;
}

function percentage(numerator: number, denominator: number): number {
  if (denominator <= 0) return 0;
  return round((numerator / denominator) * 100);
}

function round(value: number): number {
  return Math.round(value * 100) / 100;
}

function intValue(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return 0;
  return Math.max(0, Math.trunc(value));
}

function timestampToDate(value: unknown): Date | null {
  if (value instanceof Date) return value;
  if (typeof value === "string") {
    const millis = Date.parse(value);
    return Number.isFinite(millis) ? new Date(millis) : null;
  }
  const maybeTimestamp = value as {toDate?: unknown} | null | undefined;
  if (typeof maybeTimestamp?.toDate === "function") {
    const date = maybeTimestamp.toDate() as unknown;
    return date instanceof Date ? date : null;
  }
  return null;
}

function parseUtcDate(value: string, fieldName: string): Date {
  const millis = Date.parse(`${value}T00:00:00.000Z`);
  if (!Number.isFinite(millis)) {
    throw new HttpsError("invalid-argument", `${fieldName} is invalid.`);
  }
  return new Date(millis);
}

function dateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function startOfUtcDay(reference: Date): Date {
  return new Date(Date.UTC(
    reference.getUTCFullYear(),
    reference.getUTCMonth(),
    reference.getUTCDate()
  ));
}

function addUtcDays(date: Date, days: number): Date {
  const next = new Date(date);
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

function addUtcMilliseconds(date: Date, millis: number): Date {
  return new Date(date.getTime() + millis);
}

function maxDate(a: Date, b: Date): Date {
  return a.getTime() >= b.getTime() ? a : b;
}

function minDate(a: Date, b: Date): Date {
  return a.getTime() <= b.getTime() ? a : b;
}

function defaultGranularity(days: number): AnalyticsGranularity {
  if (days > 120) return "month";
  if (days > 45) return "week";
  return "day";
}

function nullableTrimmedString(value: unknown): string | null | undefined {
  if (value === null) return null;
  if (value === undefined) return undefined;
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function uniqueStrings(values: string[]): string[] {
  return [...new Set(values.filter((value) => value.length > 0))];
}

function adminAnalyticsTargetPath(
  payload: HostAnalyticsQueryCallablePayload
): string {
  if (payload.eventId) return `events/${payload.eventId}/analytics`;
  if (payload.clubId) return `clubs/${payload.clubId}/analytics`;
  return "admin/hostAnalytics";
}

function assertValidResponse(response: HostAnalyticsCallableResponse): void {
  if (validateHostAnalyticsCallableResponse(response)) return;
  const message = (validateHostAnalyticsCallableResponse.errors ?? [])
    .map((error) => `${error.instancePath}: ${error.message}`)
    .join("; ");
  throw new HttpsError(
    "internal",
    `Generated host analytics response failed validation: ${message}`
  );
}
