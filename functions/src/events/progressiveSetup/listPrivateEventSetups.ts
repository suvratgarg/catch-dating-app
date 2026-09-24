import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {authorizeSetupManager} from "./service";

const ID = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/;
const MAX_LIMIT = 50;
const CURSOR_VERSION = 1;

export interface ListPrivateEventSetupsRequest {
  organizerId: string;
  limit?: number;
  cursor?: string;
}

export interface PrivateEventSetupSummary {
  eventId: string;
  name: string;
  city: {cityId: string; marketId: string};
  localDate: string;
  localStartTime: string;
  timezone: string;
  startTimeMillis: number;
  setupRevision: number;
  status: "active";
  detailsConfigured: boolean;
}

export interface ListPrivateEventSetupsResponse {
  events: PrivateEventSetupSummary[];
  nextCursor: string | null;
}

interface PageCursor {
  v: 1;
  organizerId: string;
  asOfMillis: number;
  lastStartTimeMillis: number;
  lastEventId: string;
}

function invalidCursor(): never {
  throw new HttpsError("invalid-argument", "Invalid event setup cursor.");
}

function decodeCursor(raw: string, organizerId: string,
  nowMillis: number): PageCursor {
  if (raw.length > 1024 || !/^[A-Za-z0-9_-]+$/.test(raw)) invalidCursor();
  let parsed: unknown;
  try {
    parsed = JSON.parse(Buffer.from(raw, "base64url").toString("utf8"));
  } catch {
    invalidCursor();
  }
  if (!parsed || typeof parsed !== "object") invalidCursor();
  const value = parsed as Record<string, unknown>;
  if (Object.keys(value).sort().join(",") !==
      "asOfMillis,lastEventId,lastStartTimeMillis,organizerId,v" ||
      value.v !== CURSOR_VERSION || value.organizerId !== organizerId ||
      !Number.isSafeInteger(value.asOfMillis) ||
      !Number.isSafeInteger(value.lastStartTimeMillis) ||
      !ID.test(String(value.lastEventId)) ||
      (value.asOfMillis as number) > nowMillis ||
      (value.asOfMillis as number) < nowMillis - 24 * 60 * 60 * 1000 ||
      (value.lastStartTimeMillis as number) <
        (value.asOfMillis as number)) invalidCursor();
  return value as unknown as PageCursor;
}

function millis(value: unknown): number | null {
  if (!value || typeof value !== "object" ||
      typeof (value as {toMillis?: unknown}).toMillis !== "function") {
    return null;
  }
  const result = (value as FirebaseFirestore.Timestamp).toMillis();
  return Number.isSafeInteger(result) ? result : null;
}

function project(doc: FirebaseFirestore.QueryDocumentSnapshot,
  organizerId: string, asOfMillis: number): PrivateEventSetupSummary {
  const event: Record<string, unknown> = doc.data();
  const startTimeMillis = millis(event.startTime);
  const name = event.name;
  const cityId = event.eventCityId;
  const marketId = event.eventMarketId;
  const localDate = event.eventLocalDate;
  const localStartTime = event.eventLocalStartTime;
  const timezone = event.eventTimezone;
  const setupRevision = event.setupRevision;
  if (!validateEventDocument(event) ||
      event.organizerId !== organizerId || event.clubId !== organizerId ||
      event.publicationState !== "private" || event.status !== "active" ||
      !ID.test(doc.id) || !Number.isSafeInteger(setupRevision) ||
      typeof name !== "string" || !name.trim() ||
      typeof cityId !== "string" || typeof marketId !== "string" ||
      typeof localDate !== "string" ||
      typeof localStartTime !== "string" ||
      typeof timezone !== "string" ||
      startTimeMillis === null || startTimeMillis < asOfMillis) {
    throw new HttpsError("failed-precondition",
      "A private event setup needs review.");
  }
  return {
    eventId: doc.id,
    name,
    city: {cityId, marketId},
    localDate,
    localStartTime,
    timezone,
    startTimeMillis,
    setupRevision: setupRevision as number,
    status: "active",
    detailsConfigured: event.endTime !== undefined ||
      event.meetingLocation !== undefined ||
      event.eventSuccessPlanId !== undefined,
  };
}

/** Lists upcoming private canonical events for an organizer manager. */
export async function listPrivateEventSetups(params: {
  actorUid: string;
  command: ListPrivateEventSetupsRequest;
  db: FirebaseFirestore.Firestore;
  nowMillis?: () => number;
}): Promise<ListPrivateEventSetupsResponse> {
  const {actorUid, command, db} = params;
  if (!actorUid) throw new HttpsError("unauthenticated", "Sign in first.");
  if (!command || !ID.test(command.organizerId) ||
      (command.limit !== undefined && (!Number.isInteger(command.limit) ||
      command.limit < 1 || command.limit > MAX_LIMIT)) ||
      (command.cursor !== undefined && typeof command.cursor !== "string")) {
    throw new HttpsError("invalid-argument", "Invalid event setup request.");
  }
  const limit = command.limit ?? 20;
  const now = (params.nowMillis ?? Date.now)();
  if (!Number.isSafeInteger(now) || now < 0) {
    throw new HttpsError("internal", "Invalid server clock.");
  }
  const cursor = command.cursor ? decodeCursor(command.cursor,
    command.organizerId, now) : null;
  const asOfMillis = cursor?.asOfMillis ?? now;
  const organizerRef = db.collection("organizers").doc(command.organizerId);
  const deletedRef = db.collection("deletedUsers").doc(actorUid);
  return db.runTransaction(async (tx) => {
    const [organizer, deleted] = await Promise.all([
      tx.get(organizerRef), tx.get(deletedRef),
    ]);
    authorizeSetupManager(organizer, deleted, actorUid);
    let query = db.collection("events")
      .where("organizerId", "==", command.organizerId)
      .where("publicationState", "==", "private")
      .where("status", "==", "active")
      .where("startTime", ">=", admin.firestore.Timestamp.fromMillis(
        asOfMillis))
      .orderBy("startTime", "asc")
      .orderBy(admin.firestore.FieldPath.documentId(), "asc");
    if (cursor) {
      query = query.startAfter(admin.firestore.Timestamp.fromMillis(
        cursor.lastStartTimeMillis), cursor.lastEventId);
    }
    const page = await tx.get(query.limit(limit + 1));
    const projected = page.docs.map((doc) => project(doc,
      command.organizerId, asOfMillis));
    const events = projected.slice(0, limit);
    const last = events.at(-1);
    const nextCursor = projected.length > limit && last ?
      Buffer.from(JSON.stringify({
        v: CURSOR_VERSION,
        organizerId: command.organizerId,
        asOfMillis,
        lastStartTimeMillis: last.startTimeMillis,
        lastEventId: last.eventId,
      } satisfies PageCursor)).toString("base64url") : null;
    return {events, nextCursor};
  });
}
