import {FieldPath, Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {ListEventRcsPreferencesCallablePayload as Scope} from
  "../../shared/generated/listEventRcsPreferencesInput";
import type {ListEventRcsPreferencesCallableResponse as Response} from
  "../../shared/generated/listEventRcsPreferencesOutput";
import {guestSourceFactsFromSnapshots, requireDocumentId} from
  "./guestRecords";
import {parseRcsPermission, rcsConsentCollections} from "./rcsConsent";
import {rcsCallbackClock} from "./rcsCallbackRecords";
import {RUNTIME_CONFIGS, runtimeConfigId, parseRuntimeConfig,
  runtimeConfigSource} from "./runtimeConfigRecords";
import {runAssistanceTransaction} from "./transactionCallback";

const pageSize = 50;
const unavailable = () => new HttpsError("permission-denied",
  "Event RCS preferences unavailable.");

/** Discovers saved senders, never consent, readiness or dispatch authority. */
export class RcsPreferenceOptionsStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async list(uid: string, scope: Scope): Promise<Response> {
    [uid, scope.eventId, scope.attendeeId].forEach(requireDocumentId);
    if (scope.cursor !== null &&
        !/^rcs-permission:[a-f0-9]{64}$/.test(scope.cursor)) {
      throw new HttpsError("invalid-argument", "Invalid preference cursor.");
    }
    return runAssistanceTransaction(this.db, async (tx) => {
      const now = rcsCallbackClock(this.clock());
      const [eventSnap, attendeeSnap] = await tx.getAll(
        this.db.collection("events").doc(scope.eventId),
        this.db.collection("eventAttendees").doc(scope.attendeeId));
      const event = eventSnap.data();
      const attendee = attendeeSnap.data();
      if (!event || !attendee || attendee.linkedUid !== uid ||
          attendee.eventId !== scope.eventId) throw unavailable();
      const context = {mode: "live" as const, eventId: scope.eventId,
        organizerId: event.organizerId ?? event.clubId};
      const source = guestSourceFactsFromSnapshots(context, scope.attendeeId,
        eventSnap, attendeeSnap);
      const [runtimeSnap, planSnap] = await tx.getAll(
        this.db.collection(RUNTIME_CONFIGS).doc(runtimeConfigId(context)),
        this.db.collection("eventSuccessPlans").doc(scope.eventId));
      const runtime = runtimeSnap.exists ? parseRuntimeConfig(
        runtimeSnap.data(), context, now) : null;
      const runtimeSource = runtimeConfigSource(context, eventSnap, planSnap,
        now);
      // A paused execution can retain its saved sender for consent review.
      // A replaced source/configuration cannot offer the old default.
      const route = runtime?.sourceGeneration === runtimeSource.generation &&
          runtime.sourceHash === runtimeSource.hash ?
        runtime.configuration?.options.routes.find((r) =>
          r.routeId === "catchEventRcs") : null;
      const configuredSenderId = route?.senderId ?? null;
      // The index checker consumes this declaration as one line.
      // eslint-disable-next-line max-len
      // firestore-index: eventAssistanceRcsPermissions (context.mode:ASCENDING, context.organizerId:ASCENDING, context.eventId:ASCENDING, attendeeId:ASCENDING, subjectUid:ASCENDING, __name__:ASCENDING)
      let query = this.db.collection(rcsConsentCollections.permissions)
        .where("context.mode", "==", "live")
        .where("context.organizerId", "==", context.organizerId)
        .where("context.eventId", "==", context.eventId)
        .where("attendeeId", "==", scope.attendeeId)
        .where("subjectUid", "==", uid)
        .orderBy(FieldPath.documentId()).limit(pageSize + 1);
      if (scope.cursor) query = query.startAfter(scope.cursor);
      const snapshot = await tx.get(query);
      const scanned = snapshot.docs.slice(0, pageSize);
      const previous = new Set<string>();
      for (const doc of scanned) {
        const permission = parseRcsPermission(doc.data());
        if (permission.permissionId !== doc.id ||
            permission.context.eventId !== context.eventId ||
            permission.context.organizerId !== context.organizerId ||
            permission.attendeeId !== scope.attendeeId ||
            permission.subjectUid !== uid || permission.updatedAt > now) {
          throw new HttpsError("internal", "RCS preference identity invalid.");
        }
        if (permission.senderId !== configuredSenderId &&
            permission.sourceGeneration === source.sourceGeneration &&
            permission.attendeeGeneration === source.attendeeGeneration &&
            permission.phoneE164 === attendee.phoneE164) {
          previous.add(permission.senderId);
        }
      }
      const serverTime = rcsCallbackClock(this.clock());
      if (serverTime < now) {
        throw new HttpsError("unavailable", "RCS preference clock is behind.");
      }
      return {eventId: scope.eventId, attendeeId: scope.attendeeId, serverTime,
        configuredSenderId, previousSenderIds: [...previous],
        // Advance by scanned rows, including ones filtered after source repair.
        nextCursor: snapshot.docs.length > pageSize ?
          scanned[scanned.length - 1].id : null};
    });
  }
}
