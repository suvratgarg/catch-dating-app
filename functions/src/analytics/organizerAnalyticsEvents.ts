import crypto from "node:crypto";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {BigQueryClient, defaultBigQueryClient} from "../shared/bigQuery";
import {checkIpRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {
  RecordOrganizerAnalyticsEventCallablePayload,
} from "../shared/generated/recordOrganizerAnalyticsEventCallablePayload";
import {
  validateRecordOrganizerAnalyticsEventCallablePayload,
} from "../shared/generated/schemaValidators";

interface OrganizerAnalyticsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  bigQuery: BigQueryClient;
  now: () => Date;
  randomId: () => string;
  checkIpRateLimit: (
    ip: string,
    maxRequests?: number,
    windowMs?: number
  ) => boolean;
}

const defaultDeps: OrganizerAnalyticsDeps = {
  firestore: () => admin.firestore(),
  bigQuery: defaultBigQueryClient,
  now: () => new Date(),
  randomId: () => crypto.randomUUID(),
  checkIpRateLimit,
};

/**
 * Records one public organizer analytics event into BigQuery.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {OrganizerAnalyticsDeps} deps Injectable dependencies.
 * @return {Promise<{accepted: boolean}>} Accepted marker.
 */
export async function recordOrganizerAnalyticsEventHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerAnalyticsDeps = defaultDeps
): Promise<{accepted: boolean}> {
  const payload = validateCallableWithAjv<
    RecordOrganizerAnalyticsEventCallablePayload
  >(
    request,
    validateRecordOrganizerAnalyticsEventCallablePayload,
    normalizePayload
  );
  const clientIp = clientIpFromRequest(request);
  if (!deps.checkIpRateLimit(clientIp, 120, 60 * 1000)) {
    throw new HttpsError(
      "resource-exhausted",
      "Too many analytics events. Please try again later."
    );
  }

  const db = deps.firestore();
  await assertOrganizerScope(db, payload);

  const occurredAt = deps.now();
  const analyticsEventId = [
    payload.clubId,
    payload.eventId ?? "organizer",
    payload.eventName,
    occurredAt.getTime(),
    deps.randomId(),
  ].join("_");
  await deps.bigQuery.insertRows(
    hostAnalyticsDataset(),
    hostAnalyticsEventsTable(),
    [{
      insertId: analyticsEventId,
      json: {
        analytics_event_id: analyticsEventId,
        occurred_at: occurredAt.toISOString(),
        event_date: utcDateKey(occurredAt),
        event_name: payload.eventName,
        club_id: payload.clubId,
        target_event_id: payload.eventId ?? null,
        page_path: payload.pagePath,
        source: payload.source ?? null,
        session_hash: sessionHash(payload.sessionId ?? null),
        platform: payload.platform ?? "web",
        ingested_at: occurredAt.toISOString(),
      },
    }]
  );

  return {accepted: true};
}

export const recordOrganizerAnalyticsEvent = onCall(
  appCheckCallableOptions,
  (request) => recordOrganizerAnalyticsEventHandler(request)
);

async function assertOrganizerScope(
  db: FirebaseFirestore.Firestore,
  payload: RecordOrganizerAnalyticsEventCallablePayload
): Promise<void> {
  const clubRef = db.collection("clubs").doc(payload.clubId);
  const eventRef = payload.eventId ?
    db.collection("events").doc(payload.eventId) :
    null;
  const [clubSnapshot, eventSnapshot] = await Promise.all([
    clubRef.get(),
    eventRef ? eventRef.get() : Promise.resolve(null),
  ]);
  if (!clubSnapshot.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  if (eventSnapshot && !eventSnapshot.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  if (eventSnapshot && eventSnapshot.get("clubId") !== payload.clubId) {
    throw new HttpsError(
      "invalid-argument",
      "Event does not belong to that organizer."
    );
  }
}

function normalizePayload(data: unknown): unknown {
  if (data == null || typeof data !== "object" || Array.isArray(data)) {
    return data;
  }
  const input = data as Record<string, unknown>;
  return {
    ...input,
    clubId: trimmedString(input.clubId),
    eventId: nullableTrimmedString(input.eventId),
    pagePath: trimmedString(input.pagePath),
    source: nullableTrimmedString(input.source),
    sessionId: nullableTrimmedString(input.sessionId),
    platform: nullableTrimmedString(input.platform),
  };
}

function sessionHash(value: string | null): string | null {
  if (!value) return null;
  return crypto.createHash("sha256").update(value).digest("hex");
}

function utcDateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function clientIpFromRequest(request: CallableRequest<unknown>): string {
  const forwarded = request.rawRequest.get("x-forwarded-for");
  const firstForwarded = forwarded?.split(",")[0]?.trim();
  return firstForwarded ||
    request.rawRequest.ip ||
    request.rawRequest.socket.remoteAddress ||
    "unknown";
}

function trimmedString(value: unknown): unknown {
  return typeof value === "string" ? value.trim() : value;
}

function nullableTrimmedString(value: unknown): unknown {
  if (value == null) return null;
  if (typeof value !== "string") return value;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function hostAnalyticsDataset(): string {
  return process.env.HOST_ANALYTICS_BIGQUERY_DATASET || "catch_analytics";
}

function hostAnalyticsEventsTable(): string {
  return process.env.HOST_ANALYTICS_EVENTS_TABLE || "host_analytics_events";
}
