import {HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {accountabilityResolutionFields, currentAccountabilityResolution} from
  "../accountability";
import {eventSuccessPrimitivesFor} from "../formatPrimitives";
import type {EventAssistanceAccountabilityCallableResponse as Response} from
  "../../shared/generated/eventAssistanceAccountabilityCallableResponse";
import type {GetEventAssistanceAccountabilityCallablePayload as Scope} from
  "../../shared/generated/getEventAssistanceAccountabilityCallablePayload";
import {validateGetEventAssistanceAccountabilityCallablePayload} from
  "../../shared/generated/validators/getEventAssistanceAccountabilityInput";
import {validateResolveEventAssistanceAccountabilityCallablePayload} from
  "../../shared/generated/validators/resolveEventAssistanceAccountabilityInput";
import {validateEventAssistanceAccountabilityCallableResponse} from
  "../../shared/generated/validators/eventAssistanceAccountabilityOutput";
import {validateEventAssistanceAccountabilityReceiptDocument} from
  // eslint-disable-next-line max-len -- Canonical individual validator path.
  "../../shared/generated/validators/eventAssistanceAccountabilityReceiptDocument";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {assertCommandContext, assertCommandRole} from "./commands";
import {currentGuest, guestIdentity} from "./guestRecords";
import {invalidSource, timestampEvidence} from "./groupProgressSource";
import {requireGroupPermission, denied} from "./groupStaffAuthority";
import {readMembership, currentMembership} from "./membershipReader";

export const ACCOUNTABILITY_RECEIPTS = "eventAssistanceAccountabilityReceipts";

/** Records an observed sweep result, never attendance or reported intent. */
export class EventAccountabilityStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown): Promise<Response> {
    if (!validateGetEventAssistanceAccountabilityCallablePayload(input)) {
      throw new HttpsError("invalid-argument", "Invalid accountability scope.");
    }
    return this.db.runTransaction(async (tx) =>
      response("read", await this.read(tx, actorUid, input)));
  }

  async resolve(actorUid: string, input: unknown): Promise<Response> {
    if (!validateResolveEventAssistanceAccountabilityCallablePayload(input) ||
        input.command.context.mode !== "live") {
      throw new HttpsError("invalid-argument",
        "Invalid accountability result.");
    }
    const {command} = input;
    const {context, payload} = command;
    if (context.mode !== "live") throw invalidSource();
    try {
      assertCommandContext(command, context);
    } catch {
      throw new HttpsError("invalid-argument",
        "Accountability context mismatch.");
    }
    const scope: Scope = {context, groupId: input.groupId,
      attendeeId: payload.attendeeId};
    const guestId = guestIdentity(context, payload.attendeeId);
    const requestHash = operationContentHash([actorUid, input]);
    const receiptId = "accountability-action:" + operationContentHash([
      context, payload.attendeeId, command.operationId]);
    return this.db.runTransaction(async (tx) => {
      const state = await this.read(tx, actorUid, scope);
      assertCommandRole(command, [state.access.role]);
      const ref = this.db.collection(ACCOUNTABILITY_RECEIPTS).doc(receiptId);
      const receipt = (await tx.get(ref)).data();
      const now = this.clock();
      if (!Number.isSafeInteger(now) || now < state.member.now) {
        throw invalidSource();
      }
      if (now >= state.access.validUntil) throw denied();
      state.member.now = now;
      const revision = state.member.attendee.accountabilityRevision ?? 0;
      if (receipt !== undefined) {
        if (!validateEventAssistanceAccountabilityReceiptDocument(receipt) ||
            receipt.receiptId !== receiptId || receipt.guestId !== guestId ||
            receipt.requestHash !== requestHash ||
            receipt.sourceGeneration !== state.member.source.sourceGeneration ||
            receipt.attendeeGeneration !==
              state.member.source.attendeeGeneration ||
            receipt.checkInHash !== checkInHash(state) ||
            receipt.episodeId !== episodeId(state) ||
            receipt.disposition !== payload.disposition ||
            receipt.revision > revision || receipt.createdAt > now) {
          throw conflict();
        }
        return response("replayed", state, receipt.revision);
      }
      if (availability(state).kind !== "ready") {
        throw new HttpsError("failed-precondition",
          "This guest's current check-in cannot be resolved here.");
      }
      if (input.expectedSourceHash !== sourceHash(state) ||
          payload.episodeId !== episodeId(state)) throw conflict();
      const fields = accountabilityResolutionFields(state.member.attendee,
        payload.disposition, actorUid, Timestamp.fromMillis(now));
      const attendee = {...state.member.attendee, ...fields};
      if (!validateEventAttendeeDocument(attendee)) throw invalidSource();
      const saved = {receiptId, guestId, requestHash,
        sourceGeneration: state.member.source.sourceGeneration,
        attendeeGeneration: state.member.source.attendeeGeneration,
        checkInHash: checkInHash(state), episodeId: episodeId(state),
        revision: fields.accountabilityRevision,
        disposition: payload.disposition, createdAt: now};
      if (!validateEventAssistanceAccountabilityReceiptDocument(saved)) {
        throw invalidSource();
      }
      const result = response("applied", {...state,
        member: {...state.member, attendee}}, saved.revision);
      tx.set(this.db.collection("eventAttendees").doc(scope.attendeeId),
        attendee);
      tx.create(ref, saved);
      return result;
    });
  }

  private async read(tx: Transaction, actorUid: string, scope: Scope) {
    const member = await readMembership(this.db, tx,
      {context: scope.context, attendeeId: scope.attendeeId}, actorUid,
      this.clock);
    const access = await requireGroupPermission(this.db, tx, scope.context,
      scope.groupId, actorUid, "resolveAccountability", this.clock);
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < member.now) throw invalidSource();
    if (now >= access.validUntil) throw denied();
    member.now = now;
    // A receiving duty cannot resolve a guest before the handover is accepted.
    // The whole-event duty is explicitly event-wide; it needs no subgroup.
    if (scope.groupId !== "event:whole" && (!currentMembership(member) ||
        member.membership?.accepted?.groupId !== scope.groupId)) throw denied();
    return {scope, member, access};
  }
}

type State = {
    scope: Scope;
    member: Awaited<ReturnType<typeof readMembership>>;
    access: Awaited<ReturnType<typeof requireGroupPermission>>;
};
function checkInHash(s: State) {
  const a = s.member.attendee;
  return operationContentHash([a.status, a.attendanceRevision ?? 0,
    a.checkedInAt ? timestampEvidence(a.checkedInAt) : null]);
}
function sourceHash(s: State) {
  const a = s.member.attendee;
  const membership = s.member.membership;
  return operationContentHash([s.scope, s.member.sourceHash,
    s.member.event.eventFormat, episodeId(s),
    s.scope.groupId === "event:whole" || !membership ? null :
      [membership.episodeId, membership.sourceGeneration,
        membership.attendeeGeneration, membership.accepted],
    checkInHash(s), a.accountabilityRevision ?? 0,
    a.accountabilityResolution ?? null,
    a.accountabilityResolvedForCheckInAt ?
      timestampEvidence(a.accountabilityResolvedForCheckInAt) : null,
    a.accountabilityResolvedAt ?
      timestampEvidence(a.accountabilityResolvedAt) : null,
    a.accountabilityResolvedBy ?? null]);
}
function availability(s: State): Response["view"]["availability"] {
  const m = s.member;
  const reason = eventSuccessPrimitivesFor(m.event.eventFormat)
    .accountability !== "sweep" ? "notApplicable" :
    m.attendee.status !== "checkedIn" || !m.attendee.checkedInAt ?
      "notCheckedIn" : null;
  return reason ? {kind: "unavailable", reason} : {kind: "ready"};
}
function response(outcome: Response["outcome"], s: State,
  operationRevision: number | null = null): Response {
  const value: Response = {outcome, operationRevision, view: {
    ...s.scope, serverTime: s.member.now, sourceHash: sourceHash(s),
    revision: s.member.attendee.accountabilityRevision ?? 0,
    episodeId: episodeId(s),
    disposition: currentAccountabilityResolution(s.member.attendee) ??
      "unresolved", availability: availability(s)}};
  if (!validateEventAssistanceAccountabilityCallableResponse(value)) {
    throw invalidSource();
  }
  return value;
}
function conflict() {
  return new HttpsError("aborted",
    "Accountability changed. Refresh this guest and retry.");
}

function episodeId(s: State): string | null {
  const guest = s.member.guest;
  return guest && currentGuest(guest, s.member.source) ? guest.episodeId : null;
}
