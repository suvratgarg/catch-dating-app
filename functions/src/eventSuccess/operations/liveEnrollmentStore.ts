import {runAssistanceTransaction as transact} from "./transactionCallback";
import type {Firestore} from "firebase-admin/firestore";
import {operationCollections} from "../../operations/collections";
import {operationContentHash} from "../../operations/durableActions";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {Guest, currentGuest, guestCollections, guestIdentity,
  guestSourceFactsFromSnapshots, parseGuest} from "./guestRecords";
import {invalidWork, liveWorkBasis, liveWorkIds, newLiveWorkRecords,
  parseLiveWork, readLiveWorkRecords} from "./liveWorkRecords";
import {readRuntimeConfigAuthority, RuntimeBinding, RuntimeContext,
  RuntimeUnavailable} from "./runtimeConfigRecords";

type EnrollmentResult =
  {kind: "held"; reason: RuntimeUnavailable | "attendeeUnavailable" |
    "participationUnavailable"} |
  {kind: "enrolled" | "current" | "rebindRequired" | "completed" | "expired";
    workItemId: string; episodeId: string; binding: RuntimeBinding};

/** Atomic enrollment; no guest response or attendance inferred. */
export class LiveAssistanceEnrollmentStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async ensure(context: RuntimeContext, attendeeId: string,
    binding: RuntimeBinding): Promise<EnrollmentResult> {
    const frozen = structuredClone({context, attendeeId, binding});
    const guestId = guestIdentity(frozen.context, frozen.attendeeId);
    return transact(this.db, async (tx) => {
      const now = this.clock();
      const authority = await readRuntimeConfigAuthority(this.db, tx,
        frozen.context, frozen.binding, now);
      if (authority.kind !== "ready") {
        return {kind: "held", reason: authority.reason};
      }
      const guestRef = this.db.collection(guestCollections.guests).doc(guestId);
      const [eventSnap, attendeeSnap, guestSnap] = await tx.getAll(
        this.db.collection("events").doc(frozen.context.eventId),
        this.db.collection("eventAttendees").doc(frozen.attendeeId), guestRef);
      if (!attendeeSnap.exists) {
        return {kind: "held", reason: "attendeeUnavailable"};
      }
      const attendee = attendeeSnap.data();
      if (!validateEventAttendeeDocument(attendee)) throw invalidWork();
      const source = guestSourceFactsFromSnapshots(frozen.context,
        frozen.attendeeId, eventSnap, attendeeSnap);
      if (source.attendeeStatus !== "registered" &&
          source.attendeeStatus !== "checkedIn") {
        return {kind: "held", reason: "attendeeUnavailable"};
      }
      const existing = guestSnap.exists ? parseGuest(guestSnap.data()) : null;
      if (existing && (existing.guestId !== guestId ||
          existing.updatedAt > now)) throw invalidWork();
      const sameRegistration = existing !== null &&
        existing.sourceGeneration === source.sourceGeneration &&
        existing.attendeeGeneration === source.attendeeGeneration;
      // Closure, breaks, departure and not-coming are never re-entry signals.
      if (sameRegistration && !currentGuest(existing!, source)) {
        return {kind: "held", reason: "participationUnavailable"};
      }
      const guest: Guest = sameRegistration ? existing! : parseGuest({
        schemaVersion: 1, guestId, context: frozen.context,
        attendeeId: frozen.attendeeId,
        attendeeGeneration: source.attendeeGeneration,
        sourceGeneration: source.sourceGeneration,
        episodeId: "episode:" + operationContentHash([
          "roster-enrollment/v1", guestId, source.sourceGeneration,
          source.attendeeGeneration]),
        participation: {state: "active", resumeAtUnit: null},
        revision: existing ? existing.revision + 1 : 0, lifecycle: "active",
        intention: {kind: "unknown"}, createdAt: existing?.createdAt ?? now,
        updatedAt: now});
      const payload = parseLiveWork({schemaVersion: 1, kind: "liveLateJoin",
        scope: {context: frozen.context, attendeeId: frozen.attendeeId,
          episodeId: guest.episodeId}, ...authority.configuration,
        runtimeBinding: frozen.binding,
        checkpoint: {dueAt: now, evaluatedAt: null, evaluations: 0,
          sourceHash: null, observation: null, publication: null}}, now);
      const ids = liveWorkIds(payload.scope);
      const runRef = this.db.collection(operationCollections.runs)
        .doc(ids.runId);
      const itemRef = this.db.collection(operationCollections.workItems)
        .doc(ids.workItemId);
      const [runSnap, itemSnap] = await tx.getAll(runRef, itemRef);
      const result = {workItemId: ids.workItemId, episodeId: guest.episodeId,
        binding: frozen.binding};
      if (runSnap.exists || itemSnap.exists) {
        // Missing participation cannot be recreated over existing work.
        if (!sameRegistration) throw invalidWork();
        const records = readLiveWorkRecords(runSnap.data(), itemSnap.data(),
          ids.workItemId, now);
        if (records.run.status === "completed") {
          return {...result, kind: "completed"};
        }
        if (now >= records.payload.expiresAt) {
          return {...result, kind: "expired"};
        }
        return {...result, kind: operationContentHash(
          liveWorkBasis(records.payload)) === operationContentHash(
          liveWorkBasis(payload)) ? "current" : "rebindRequired"};
      }
      const records = newLiveWorkRecords(payload, now);
      const committedAt = this.clock();
      if (committedAt < now || committedAt >= payload.expiresAt) {
        throw invalidWork();
      }
      if (!sameRegistration) tx.set(guestRef, guest);
      tx.create(runRef, records.run);
      tx.create(itemRef, records.item);
      return {...result, kind: "enrolled"};
    });
  }
}
