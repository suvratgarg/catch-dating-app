import {createHash} from "node:crypto";
import {isDeepStrictEqual} from "node:util";
import type {WorkspaceFieldContext} from "./workspaceFieldAuthority";

/** Typed companion to scalar field evidence. Membership is a scoped
 * guest/group relation, never a contact field or an invitation household. */
export interface WorkspaceMembershipContext extends WorkspaceFieldContext {
  workspaceRef: {kind: "program"; id: string};
  relationshipRef: {kind: "programGuest"; id: string};
  groupId: string;
}
export interface WorkspaceMembershipAssertion
  extends WorkspaceMembershipContext {
  schemaVersion: 1;
  programId: string;
  included: boolean;
  sourceKind: "manualEntry" | "manifestRow" | "contributorList";
  sourceId: string;
  sourceVersion: number;
  sourceLabel: string;
  actorUid: string;
  observedAtMillis: number;
}
export interface WorkspaceMembershipSelection {
  groupId: string;
  assertionId: string;
}
export interface WorkspaceMembershipProjection {
  /** Existing programGuests.groupIds remains the current membership truth. */
  groupIds: string[];
  selections: WorkspaceMembershipSelection[];
  suggestions: WorkspaceMembershipSelection[];
}
export interface WorkspaceMembershipDecision
  extends WorkspaceMembershipContext {
  schemaVersion: 1;
  programId: string;
  selectedAssertionId: string;
  previousAssertionId: string | null;
  relationshipRevision: number;
  actorUid: string;
  observedAtMillis: number;
}
function validId(value: string, max = 180): boolean {
  return typeof value === "string" && value.length > 0 && value.length <= max;
}
function validContext(context: WorkspaceMembershipContext): boolean {
  return context.workspaceRef?.kind === "program" &&
    context.relationshipRef?.kind === "programGuest" &&
    [context.organizerId, context.workspaceRef.id, context.relationshipRef.id,
      context.groupId].every((id) => validId(id));
}

/** Immutable source identity. Reusing a source version with changed contents
 * is an error at the create boundary, not an overwrite of previous evidence. */
export function workspaceMembershipAssertionId(
  assertion: WorkspaceMembershipAssertion,
): string {
  return "wma_" + createHash("sha256").update(JSON.stringify([
    assertion.workspaceRef.kind, assertion.workspaceRef.id,
    assertion.organizerId, assertion.relationshipRef.kind,
    assertion.relationshipRef.id, assertion.groupId, assertion.sourceKind,
    assertion.sourceId, assertion.sourceVersion,
  ])).digest("hex");
}
export function membershipAssertionMatches(
  assertion: WorkspaceMembershipAssertion | undefined, id: string,
  context: WorkspaceMembershipContext,
): assertion is WorkspaceMembershipAssertion {
  return Boolean(assertion && validContext(context) &&
    assertion.schemaVersion === 1 &&
    assertion.programId === context.workspaceRef.id &&
    assertion.workspaceRef?.kind === context.workspaceRef.kind &&
    assertion.workspaceRef.id === context.workspaceRef.id &&
    assertion.organizerId === context.organizerId &&
    assertion.relationshipRef?.kind === context.relationshipRef.kind &&
    assertion.relationshipRef.id === context.relationshipRef.id &&
    assertion.groupId === context.groupId &&
    typeof assertion.included === "boolean" &&
    ["manualEntry", "manifestRow", "contributorList"]
      .includes(assertion.sourceKind) &&
    validId(assertion.sourceId, 240) && validId(assertion.sourceLabel, 140) &&
    validId(assertion.actorUid) &&
    Number.isSafeInteger(assertion.sourceVersion) &&
    assertion.sourceVersion > 0 &&
    Number.isSafeInteger(assertion.observedAtMillis) &&
    assertion.observedAtMillis > 0 && /^wma_[a-f0-9]{64}$/.test(id) &&
    workspaceMembershipAssertionId(assertion) === id);
}

export function assertMembershipEvidenceCreate(
  incoming: WorkspaceMembershipAssertion,
  existing: WorkspaceMembershipAssertion | undefined,
): string {
  const id = workspaceMembershipAssertionId(incoming);
  if (!membershipAssertionMatches(incoming, id, incoming)) {
    throw new Error("Invalid membership evidence.");
  }
  if (existing && !isDeepStrictEqual(existing, incoming)) {
    throw new Error("Membership source version is immutable.");
  }
  return id;
}

/** Incoming lists only append bounded suggestions. Selected includes AND
 * excludes survive re-import; no import can silently approve its own claim. */
export function suggestWorkspaceMembership(
  projection: WorkspaceMembershipProjection,
  context: WorkspaceMembershipContext,
  assertion: WorkspaceMembershipAssertion,
): WorkspaceMembershipProjection {
  const assertionId = workspaceMembershipAssertionId(assertion);
  if (!membershipAssertionMatches(assertion, assertionId, context)) {
    throw new Error("Membership evidence belongs to another relationship.");
  }
  const next = structuredClone(projection);
  if (next.selections.some((row) => row.assertionId === assertionId) ||
      next.suggestions.some((row) => row.assertionId === assertionId)) {
    return next;
  }
  const groupSuggestions = next.suggestions.filter((row) =>
    row.groupId === context.groupId);
  if (groupSuggestions.length >= 20 || next.suggestions.length >= 500) {
    throw new Error("Review membership suggestions before importing more.");
  }
  next.suggestions.push({groupId: context.groupId, assertionId});
  return next;
}

/** Must run with canonical guest/group scope, authority and immutable
 * assertion read in the same transaction that updates groupIds/memberCount. */
export function selectWorkspaceMembership(params: {
  context: WorkspaceMembershipContext;
  projection: WorkspaceMembershipProjection;
  assertionId: string;
  assertion: WorkspaceMembershipAssertion;
  currentRevision: number;
  expectedRevision: number;
  actorUid: string;
  observedAtMillis: number;
}): {projection: WorkspaceMembershipProjection;
  decision: WorkspaceMembershipDecision} {
  const {context, assertion} = params;
  if (!Number.isSafeInteger(params.currentRevision) ||
      params.currentRevision < 1 ||
      params.currentRevision !== params.expectedRevision) {
    throw new Error("Stale guest membership revision.");
  }
  if (!validId(params.actorUid) ||
      !Number.isSafeInteger(params.observedAtMillis) ||
      params.observedAtMillis < 1 || !membershipAssertionMatches(
    assertion, params.assertionId, context)) {
    throw new Error("Invalid membership choice.");
  }
  const previous = params.projection.selections.filter((row) =>
    row.groupId === context.groupId);
  if (previous.length > 1) throw new Error("Ambiguous membership selection.");
  const next = structuredClone(params.projection);
  const groups = new Set(next.groupIds);
  if (assertion.included) groups.add(context.groupId);
  else groups.delete(context.groupId);
  next.groupIds = [...groups].sort();
  next.selections = [...next.selections.filter((row) =>
    row.groupId !== context.groupId),
  {groupId: context.groupId, assertionId: params.assertionId}];
  next.suggestions = next.suggestions.filter((row) =>
    row.assertionId !== params.assertionId);
  return {projection: next, decision: {...context, schemaVersion: 1,
    programId: context.workspaceRef.id, selectedAssertionId: params.assertionId,
    previousAssertionId: previous[0]?.assertionId ?? null,
    relationshipRevision: params.currentRevision, actorUid: params.actorUid,
    observedAtMillis: params.observedAtMillis}};
}
