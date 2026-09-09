import {HttpsError} from "firebase-functions/v2/https";
import {FieldPath, Firestore} from "firebase-admin/firestore";
import {operationContentHash as hash} from "../operations/durableActions";
import type {EventAttendanceReportCallableResponse as Response} from
  "../shared/generated/eventAttendanceReportCallableResponse";
import {validateGetEventAttendanceReportCallablePayload} from
  "../shared/generated/validators/getEventAttendanceReportInput";
import {validateEventAttendanceReportCallableResponse} from
  "../shared/generated/validators/eventAttendanceReportOutput";
import {guestCollections, guestIdentity} from
  "../eventSuccess/operations/guestRecords";
import {invalidSource, timestampEvidence} from
  "../eventSuccess/operations/groupProgressSource";
import {attendanceClosure, dispositionIdentity, dispositionView, View} from
  "./attendanceDispositionPolicy";
import {attendanceEventAuthority, attendanceDispositionStateFromSnapshots,
  dispositionCollections} from "./attendanceDispositionReader";

type Report = Response["view"];
type Classification = Report["members"][number]["classification"];
const rosterLimit = 1000;
const batchSize = 100;

/** Canonical Host roster, including guests without profiles or bookings. */
export class EventAttendanceReportStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown): Promise<Response> {
    if (!validateGetEventAttendanceReportCallablePayload(input)) {
      throw new HttpsError("invalid-argument", "Invalid attendance scope.");
    }
    const {context} = input;
    return this.db.runTransaction(async (tx) => {
      const [eventSnap, organizerSnap, planSnap] = await tx.getAll(
        this.db.collection("events").doc(context.eventId),
        this.db.collection("organizers").doc(context.organizerId),
        this.db.collection("eventSuccessPlans").doc(context.eventId));
      const authority = attendanceEventAuthority(actorUid, context, eventSnap,
        organizerSnap, planSnap);
      const roster = await tx.get(this.db.collection("eventAttendees")
        .where("eventId", "==", context.eventId)
        .orderBy(FieldPath.documentId()).limit(rosterLimit + 1));
      if (roster.size > rosterLimit) {
        throw new HttpsError("resource-exhausted",
          "This roster exceeds the attendance report limit.");
      }
      const rows = [];
      for (let offset = 0; offset < roster.size; offset += batchSize) {
        const attendees = roster.docs.slice(offset, offset + batchSize);
        const related = await tx.getAll(...attendees.flatMap((attendee) => [
          this.db.collection(guestCollections.guests)
            .doc(guestIdentity(context, attendee.id)),
          this.db.collection(dispositionCollections.records)
            .doc(dispositionIdentity(context, attendee.id)),
        ]));
        for (const [i, attendee] of attendees.entries()) {
          rows.push({attendee, guest: related[2 * i],
            record: related[2 * i + 1]});
        }
      }
      const now = this.clock();
      if (!Number.isSafeInteger(now) || now < 0) throw invalidSource();
      const closure = attendanceClosure({...authority, now});
      const counts: Report["counts"] = {attended: 0,
        recordedNoShow: {hostConfirmed: 0, guestDeclined: 0},
        unresolved: {unreviewed: 0, cleared: 0, sourceChanged: 0,
          superseded: 0},
        notExpected: {invited: 0, waitlisted: 0, cancelled: 0,
          eventCancelled: 0}};
      const sourceHashes: string[] = [];
      const members = rows.map(({attendee, guest, record}) => {
        const state = attendanceDispositionStateFromSnapshots(authority,
          attendee, guest, record, now);
        const view = dispositionView(state.source, state.record);
        sourceHashes.push(view.sourceHash);
        const classification = classifyAttendance(view);
        switch (classification.kind) {
        case "attended": counts.attended++; break;
        case "recordedNoShow":
          counts.recordedNoShow[classification.evidence]++; break;
        case "unresolved":
          counts.unresolved[classification.reason]++; break;
        case "notExpected":
          counts.notExpected[classification.reason]++; break;
        default:
          invalidClassification(classification);
        }
        return {attendeeId: attendee.id, classification};
      });
      const {event, plan, planGeneration} = authority;
      const sourceHash = hash([context, timestampEvidence(eventSnap.createTime),
        event.status, timestampEvidence(event.startTime),
        timestampEvidence(event.endTime), plan ?
          timestampEvidence(planGeneration) : null, plan?.status ?? null,
        plan?.completedAt == null ? null : timestampEvidence(plan.completedAt),
        closure, sourceHashes]);
      const result: Response = {view: {context, serverTime: now, sourceHash,
        closure, source: "eventAttendees", coverage: roster.empty ?
          "emptyRoster" : "completeRoster", rosterCount: roster.size,
        counts, members}};
      if (!validateEventAttendanceReportCallableResponse(result)) {
        throw invalidSource();
      }
      return result;
    }, {readOnly: true});
  }
}

/** Physical attendance wins; an unresolved registration never means no-show. */
export function classifyAttendance(view: View): Classification {
  if (view.attendance.checkedIn) return {kind: "attended"};
  switch (view.attendance.status) {
  case "invited": case "waitlisted": case "cancelled":
    return {kind: "notExpected", reason: view.attendance.status};
  }
  if (view.closure.kind === "cancelled") {
    return {kind: "notExpected", reason: "eventCancelled"};
  }
  const disposition = view.disposition;
  switch (disposition.kind) {
  case "recorded":
    return {kind: "recordedNoShow", evidence: disposition.evidence.kind};
  case "unreviewed": case "cleared": case "sourceChanged": case "superseded":
    return {kind: "unresolved", reason: disposition.kind};
  }
}

function invalidClassification(classification: never): never {
  throw new Error("Unhandled attendance classification: " +
    String(classification));
}
