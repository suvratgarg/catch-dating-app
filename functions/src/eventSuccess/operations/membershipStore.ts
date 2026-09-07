import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {validateGetEventAssistanceMembershipCallablePayload} from
  "../../shared/generated/validators/getEventAssistanceMembershipInput";
import {validateTransferEventAssistanceGroupCallablePayload} from
  "../../shared/generated/validators/transferEventAssistanceGroupInput";
import {validateEventAssistanceMembershipReceiptDocument} from
  "../../shared/generated/validators/eventAssistanceMembershipReceiptDocument";
import {assertCommandContext, assertCommandRole} from "./commands";
import {requireGroupPermission} from "./groupStaffAuthority";
import {invalidSource} from "./groupProgressSource";
import {MEMBERSHIPS, MEMBERSHIP_RECEIPTS, readMembership,
  canReadMembership, membershipDenied, parseMembership} from
  "./membershipReader";
import {membershipResponse, transitionMembership, membershipConflict} from
  "./membershipTransitions";

export class EventMembershipStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown) {
    if (!validateGetEventAssistanceMembershipCallablePayload(input)) {
      throw new HttpsError("invalid-argument",
        "Invalid group membership scope.");
    }
    return this.db.runTransaction(async (tx) => {
      const state = await readMembership(this.db, tx, input, actorUid,
        this.clock);
      if (!canReadMembership(state)) throw membershipDenied();
      return membershipResponse("read", state);
    });
  }

  async transfer(actorUid: string, input: unknown) {
    if (!validateTransferEventAssistanceGroupCallablePayload(input) ||
        input.command.context.mode !== "live") {
      throw new HttpsError("invalid-argument",
        "Invalid group membership action.");
    }
    const {command} = input;
    const context = command.context;
    if (context.mode !== "live") throw invalidSource();
    try {
      assertCommandContext(command, context);
    } catch {
      throw new HttpsError("invalid-argument",
        "Group action context mismatch.");
    }
    const {payload} = command;
    const scope = {context, attendeeId: payload.attendeeId};
    const requestHash = operationContentHash([actorUid, input]);
    const receiptId = "membership-action:" + operationContentHash([
      scope, command.operationId]);
    return this.db.runTransaction(async (tx) => {
      const state = await readMembership(this.db, tx, scope, actorUid,
        this.clock);
      if (!canReadMembership(state)) throw membershipDenied();
      assertCommandRole(command, [state.manager ? "eventLead" : "groupLead"]);
      const receiptRef = this.db.collection(MEMBERSHIP_RECEIPTS).doc(receiptId);
      const receipt = (await tx.get(receiptRef)).data();
      // Only a current target operator can be named as the receiving party.
      const decision = payload.decision;
      const targetAccess = !receipt && decision.kind === "propose" ?
        await requireGroupPermission(this.db, tx, context, decision.to,
          decision.receivingOperatorId, "transferGroup", this.clock) : null;
      const now = this.clock();
      if (!Number.isSafeInteger(now) || now < state.now) throw invalidSource();
      state.now = now;
      if (!canReadMembership(state) || targetAccess &&
          now >= targetAccess.validUntil) throw membershipDenied();
      if (receipt !== undefined) {
        if (!validateEventAssistanceMembershipReceiptDocument(receipt) ||
            receipt.receiptId !== receiptId ||
            receipt.membershipId !== state.membershipId ||
            receipt.actorUid !== actorUid ||
            receipt.requestHash !== requestHash ||
            receipt.sourceGeneration !== state.source.sourceGeneration ||
            receipt.episodeId !== state.guest?.episodeId ||
            !state.membership || receipt.revision > state.membership.revision ||
            operationContentHash([actorUid, {command: receipt.command,
              expectedSourceHash: input.expectedSourceHash}]) !== requestHash ||
            receipt.createdAt > now) throw membershipConflict();
        return membershipResponse("replayed", state, receipt.revision);
      }
      if (payload.expectedMembershipRevision !==
          (state.membership?.revision ?? 0) ||
          payload.expectedParticipationRevision !==
            (state.guest?.revision ?? 0) ||
          payload.episodeId !== state.guest?.episodeId ||
          input.expectedSourceHash !== state.sourceHash) {
        throw membershipConflict();
      }
      const membership = transitionMembership(state, input);
      parseMembership(membership, scope, now);
      const savedReceipt = {receiptId, membershipId: state.membershipId,
        sourceGeneration: state.source.sourceGeneration,
        episodeId: membership.episodeId, actorUid, requestHash, command,
        revision: membership.revision, createdAt: now};
      if (!validateEventAssistanceMembershipReceiptDocument(savedReceipt)) {
        throw invalidSource();
      }
      const response = membershipResponse("applied", {...state, membership},
        membership.revision);
      tx.set(this.db.collection(MEMBERSHIPS).doc(state.membershipId),
        membership);
      tx.create(receiptRef, savedReceipt);
      return response;
    });
  }
}
