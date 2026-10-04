import {programGuestDocumentSchema} from
  "../shared/generated/schemas/programGuestDocument";
import {lazyValidator} from "../shared/generated/schemaValidationRuntime";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {validateWorkspaceMembershipAssertionDocument} from
  "../shared/generated/validators/workspaceMembershipAssertionDocument";
import type {ProgramGuestDocument} from
  "../shared/generated/firestoreAdminTypes";
import {assertMembershipEvidenceCreate, membershipAssertionMatches,
  selectWorkspaceMembership, suggestWorkspaceMembership} from
  "./workspaceMembershipAuthority";
import type {WorkspaceMembershipAssertion, WorkspaceMembershipContext,
  WorkspaceMembershipProjection, WorkspaceMembershipSelection} from
  "./workspaceMembershipAuthority";

export type ScopedMembershipGuest = ProgramGuestDocument & {
  membershipSelections?: WorkspaceMembershipSelection[];
  membershipSuggestions?: WorkspaceMembershipSelection[];
};
export interface MembershipEvidenceWrite {path: string; data: object}
const pointerCap = 100;
const membershipFields = ["groupIds", "membershipSelections",
  "membershipSuggestions"];
const guestProperties = programGuestDocumentSchema.properties as
  Record<string, unknown>;
const validateMembershipFields = lazyValidator({type: "object",
  additionalProperties: false, required: membershipFields,
  properties: Object.fromEntries(membershipFields.map((key) =>
    [key, guestProperties[key]]))});


export function programMembershipContext(programId: string,
  organizerId: string, guestId: string, groupId: string):
    WorkspaceMembershipContext {
  return {workspaceRef: {kind: "program", id: programId}, organizerId,
    relationshipRef: {kind: "programGuest", id: guestId}, groupId};
}

export function programMembershipProjection(
  guest: Partial<ScopedMembershipGuest>):
    WorkspaceMembershipProjection {
  // Only absent fields use legacy defaults. Explicit null and malformed
  // elements must satisfy the exact generated field contracts before writes.
  const fields = {
    groupIds: guest.groupIds === undefined ? [] : guest.groupIds,
    membershipSelections: guest.membershipSelections === undefined ?
      [] : guest.membershipSelections,
    membershipSuggestions: guest.membershipSuggestions === undefined ?
      [] : guest.membershipSuggestions,
  };
  if (!validateMembershipFields(fields)) {
    throw new HttpsError("failed-precondition",
      "Membership evidence pointers need reconciliation.");
  }
  const groupIds = [...fields.groupIds];
  const selections = structuredClone(fields.membershipSelections);
  const suggestions = structuredClone(fields.membershipSuggestions);
  for (const pointers of [selections, suggestions]) {
    if (new Set(pointers.map((p) => p.assertionId)).size !== pointers.length) {
      throw new HttpsError("failed-precondition",
        "Membership evidence pointers need reconciliation.");
    }
  }
  if (new Set(selections.map((p) => p.groupId)).size !== selections.length) {
    throw new HttpsError("failed-precondition", "Ambiguous membership choice.");
  }
  return {groupIds, selections, suggestions};
}

/** Import assertions remain suggestions. Neither a new list nor a repeated
 * import changes canonical membership or replaces manual includes/excludes. */
export function planImportedMembership(params: {
  guest: Partial<ScopedMembershipGuest>; programId: string; organizerId: string;
  guestId: string; groupIds: string[]; operationId: string; rowIndex: number;
  actorUid: string; observedAtMillis: number;
}): {projection: WorkspaceMembershipProjection;
  writes: MembershipEvidenceWrite[]} {
  let projection = programMembershipProjection(params.guest);
  const writes: MembershipEvidenceWrite[] = [];
  for (const groupId of [...new Set(params.groupIds)]) {
    const context = programMembershipContext(params.programId,
      params.organizerId, params.guestId, groupId);
    const assertion: WorkspaceMembershipAssertion = {...context,
      schemaVersion: 1, programId: params.programId, included: true,
      sourceKind: "manifestRow",
      sourceId: `${params.operationId}:${params.rowIndex}`,
      sourceVersion: 1, sourceLabel: `Manifest row ${params.rowIndex + 1}`,
      actorUid: params.actorUid, observedAtMillis: params.observedAtMillis};
    const id = assertMembershipEvidenceCreate(assertion, undefined);
    if (projection.suggestions.filter((p) =>
      p.groupId === groupId).length >= 20 &&
        !projection.suggestions.some((p) => p.assertionId === id)) {
      throw new HttpsError("resource-exhausted",
        "Review this group's membership suggestions before importing more.");
    }
    projection = suggestWorkspaceMembership(projection, context, assertion);
    if (projection.suggestions.length > pointerCap) {
      throw new HttpsError("resource-exhausted",
        "Review membership suggestions before importing more lists.");
    }
    writes.push({path: `workspaceMembershipAssertions/${id}`, data: assertion});
  }
  return {projection, writes};
}

/** Reads selected immutable evidence before any guest/group mutation. A
 * corrupt/foreign pointer fails closed instead of lending authority to a
 * canonical membership update. Suggested evidence remains unapproved. */
export async function planManualMembership(params: {
  db: FirebaseFirestore.Firestore; tx: FirebaseFirestore.Transaction;
  guest: Partial<ScopedMembershipGuest>; programId: string; organizerId: string;
  guestId: string; groupIds: string[]; currentRevision: number;
  nextRevision: number; actorUid: string; observedAtMillis: number;
}): Promise<{projection: WorkspaceMembershipProjection;
  writes: MembershipEvidenceWrite[]}> {
  if (!Number.isSafeInteger(params.nextRevision) ||
      params.nextRevision <= params.currentRevision) {
    throw new HttpsError("failed-precondition",
      "Invalid next membership revision.");
  }
  let projection = programMembershipProjection(params.guest);
  const selected = [...new Set(params.groupIds)].sort();
  if (selected.length > 20) {
    throw new HttpsError("invalid-argument",
      "Too many selected social groups.");
  }
  for (const pointer of projection.selections) {
    const assertion = (await params.tx.get(params.db.collection(
      "workspaceMembershipAssertions").doc(pointer.assertionId))).data() as
      WorkspaceMembershipAssertion | undefined;
    const context = programMembershipContext(params.programId,
      params.organizerId, params.guestId, pointer.groupId);
    if (!validateWorkspaceMembershipAssertionDocument(assertion) ||
        !membershipAssertionMatches(assertion, pointer.assertionId, context) ||
        assertion.included !== projection.groupIds.includes(pointer.groupId)) {
      throw new HttpsError("failed-precondition",
        "Selected membership evidence needs reconciliation.");
    }
  }
  const affected = [...new Set([...projection.groupIds, ...selected,
    ...projection.selections.map((p) => p.groupId),
    ...projection.suggestions.map((p) => p.groupId)])];
  if (affected.length > pointerCap) {
    throw new HttpsError("resource-exhausted", "Too many membership choices.");
  }
  const writes: MembershipEvidenceWrite[] = [];
  for (const groupId of affected) {
    const context = programMembershipContext(params.programId,
      params.organizerId, params.guestId, groupId);
    const assertion: WorkspaceMembershipAssertion = {...context,
      schemaVersion: 1, programId: params.programId,
      included: selected.includes(groupId), sourceKind: "manualEntry",
      sourceId: params.guestId, sourceVersion: params.nextRevision,
      sourceLabel: "Host membership choice", actorUid: params.actorUid,
      observedAtMillis: params.observedAtMillis};
    const id = assertMembershipEvidenceCreate(assertion, undefined);
    const choice = selectWorkspaceMembership({context, projection,
      assertionId: id, assertion, currentRevision: params.currentRevision,
      expectedRevision: params.currentRevision, actorUid: params.actorUid,
      observedAtMillis: params.observedAtMillis});
    projection = choice.projection;
    // The host's complete manual group selection resolves this group's
    // pending suggestions. Immutable source history remains in the ledger.
    projection.suggestions = projection.suggestions.filter((p) =>
      p.groupId !== groupId);
    const decisionId = "wmd_" + createHash("sha256")
      .update(JSON.stringify([id, params.nextRevision])).digest("hex");
    writes.push({path: `workspaceMembershipAssertions/${id}`, data: assertion},
      {path: `workspaceMembershipDecisions/${decisionId}`,
        data: choice.decision});
  }
  return {projection, writes};
}
