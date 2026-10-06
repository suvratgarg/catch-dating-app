import {DEMO_CAPABILITY, preview, text as demoText, id as demoId, type Preview} from "./model";
import {expectRevision, fail, hash, id, object, revision, requestId,
  type PartnerActor, type PartnerDeps} from "../partners/model";
import {requireAssignment, requirePartner, mutatePartnerAction} from "../partners/service";

/** Owner opt-in, separate from blueprint approval and invitation authority. */
export interface PartnerDemoReviewGrant {
  revision: number;
  state: "active" | "withdrawn";
  partnerUid: string;
  assignmentRevision: number;
  blueprintRevision: number;
  previewHash: string;
  expiresAt: string;
  ownerReviewedByUid: string;
  ownerReviewedAt: string;
}
export interface PartnerDemoReview {
  organizerId: string;
  assignmentRevision: number;
  blueprintId: string;
  blueprintRevision: number;
  preview: Preview;
  previewHash: string;
  validUntil: string;
  evaluatedAt: string;
  synthetic: true;
  interactiveAvailable: false;
  sendAuthority: false;
  capabilityApprovalAuthority: false;
  organizerControlAuthority: false;
}

/** The owner sharing action must hash this exact minimal projection. */
export function partnerDemoPreviewMaterial(source: Record<string, unknown>) {
  let approvedPreview: Preview;
  try {approvedPreview = preview(source.preview);}
  catch {return fail("failed-precondition", "Current reviewed preview is unavailable.");}
  if (approvedPreview.limitations.length === 0) {
    return fail("failed-precondition", "Simulation limitations are required.");
  }
  return {blueprintId: source.blueprintId, blueprintRevision: source.revision,
    organizerId: source.organizerId, capability: source.capability,
    capabilityRevision: source.capabilityRevision, evidenceRevision: source.evidenceRevision,
    preview: approvedPreview};
}

/** Assignment and blueprint approval are insufficient without exact sharing opt-in. */
export function projectPartnerDemoReview(source: Record<string, unknown>,
  grant: PartnerDemoReviewGrant | undefined, scope: {actorUid: string; organizerId: string;
    assignmentRevision: number}, capability: Record<string, unknown>, at: Date): PartnerDemoReview {
  if (source.schemaVersion !== 1 || source.classification !== "sales_private" ||
      source.organizerId !== scope.organizerId || source.candidateId !== null ||
      source.state !== "reviewed" || !Number.isSafeInteger(source.revision) ||
      Number(source.revision) < 1 || source.capability !== DEMO_CAPABILITY ||
      capability.capability !== DEMO_CAPABILITY || capability.enabled !== true ||
      typeof capability.revision !== "string" || capability.revision.length < 3 ||
      typeof capability.evidenceRevision !== "string" || capability.evidenceRevision.length < 3 ||
      source.capabilityRevision !== capability.revision || source.evidenceRevision !== capability.evidenceRevision ||
      typeof source.reviewedByUid !== "string" || !source.reviewedByUid ||
      typeof source.reviewedAt !== "string" || !Number.isFinite(Date.parse(source.reviewedAt)) || Date.parse(source.reviewedAt) > at.getTime()) {
    return fail("failed-precondition", "Current reviewed demo capability and preview are required.");
  }
  const material = partnerDemoPreviewMaterial(source);
  const previewHash = hash(material);
  if (!grant || grant.state !== "active" || !Number.isSafeInteger(grant.revision) || grant.revision < 1 || grant.partnerUid !== scope.actorUid ||
      grant.assignmentRevision !== scope.assignmentRevision || grant.blueprintRevision !== source.revision ||
      grant.previewHash !== previewHash || !Number.isFinite(Date.parse(grant.expiresAt)) ||
      Date.parse(grant.expiresAt) <= at.getTime() ||
      typeof grant.ownerReviewedByUid !== "string" || !grant.ownerReviewedByUid ||
      !Number.isFinite(Date.parse(grant.ownerReviewedAt)) || Date.parse(grant.ownerReviewedAt) > at.getTime()) {
    return fail("permission-denied", "Current owner-approved partner preview sharing is required.");
  }
  return {organizerId: scope.organizerId, assignmentRevision: scope.assignmentRevision,
    blueprintId: demoId(source.blueprintId), blueprintRevision: Number(source.revision),
    preview: material.preview, previewHash, validUntil: grant.expiresAt, evaluatedAt: at.toISOString(),
    synthetic: true, interactiveAvailable: false, sendAuthority: false,
    capabilityApprovalAuthority: false, organizerControlAuthority: false};
}

/** Read-only composition review; creates no invitation, session, grant or activity. */
export async function getPartnerDemoReview(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<PartnerDemoReview> {
  const input = object(payload, ["organizerId", "expectedAssignmentRevision", "blueprintId"]);
  const organizerId = id(input.organizerId);
  const expected = revision(input.expectedAssignmentRevision);
  const blueprintId = demoId(input.blueprintId);
  await deps.checkAuth(actor, false);
  return deps.db.runTransaction(async (tx) => {
    const access = async () => {
      const assignment = await requireAssignment(deps, actor, tx, organizerId);
      expectRevision(assignment.revision, expected);
      return assignment;
    };
    await access();
    const [blueprint, capability] = await Promise.all([
      tx.get(deps.db.collection("salesDemoBlueprints").doc(blueprintId)),
      tx.get(deps.db.collection("salesDemoCapabilities").doc(DEMO_CAPABILITY)),
    ]);
    const source = blueprint.data();
    if (!source || source.blueprintId !== blueprintId) {
      return fail("failed-precondition", "Current shared preview is unavailable.");
    }
    // Recheck actual participant authority after all awaited source reads.
    const assignment = await access();
    const membership = await requirePartner(deps, actor, tx);
    // Auth can change while the final membership reads are awaiting I/O.
    await deps.checkAuth(actor, false);
    const evaluatedAt = deps.now();
    if (Date.parse(membership.expiresAt) <= evaluatedAt.getTime() ||
        Date.parse(assignment.expiresAt) <= evaluatedAt.getTime()) {
      return fail("permission-denied", "Partner access expired during preview review.");
    }
    const result = projectPartnerDemoReview(source, source.partnerReviewGrant,
      {actorUid: actor.uid, organizerId, assignmentRevision: expected}, capability.data() ?? {}, evaluatedAt);
    // The read cannot outlive its assignment, even if a malformed grant claims a later expiry.
    return {...result, validUntil: new Date(Math.min(Date.parse(result.validUntil),
      Date.parse(assignment.expiresAt), Date.parse(membership.expiresAt))).toISOString()};
  });
}


export interface PartnerDemoPreviewProposal {
  revision: number; state: "pending_owner_review";
  partnerUid: string; assignmentRevision: number; blueprintRevision: number;
  sourcePreviewHash: string; wording: {headline: string; scenario: string; cta: string};
  proposedAt: string;
}

/** Only exact approved editable fields may cross either UI boundary. */
export function proposalWording(proposal: PartnerDemoPreviewProposal | undefined) {
  if (!proposal) return null;
  if (!Number.isSafeInteger(proposal.revision) || proposal.revision < 1 ||
      !Number.isFinite(Date.parse(proposal.proposedAt))) {
    return fail("failed-precondition", "Current wording proposal is unavailable.");
  }
  const words = object(proposal.wording, ["headline", "scenario", "cta"]);
  return {headline: demoText(words.headline), scenario: demoText(words.scenario), cta: demoText(words.cta)};
}

async function currentProposalSource(deps: PartnerDeps, actor: PartnerActor,
  tx: FirebaseFirestore.Transaction, organizerId: string, expected: number, blueprintId: string) {
  const assignment = await requireAssignment(deps, actor, tx, organizerId);
  expectRevision(assignment.revision, expected);
  const [blueprint, capability] = await Promise.all([
    tx.get(deps.db.collection("salesDemoBlueprints").doc(blueprintId)),
    tx.get(deps.db.collection("salesDemoCapabilities").doc(DEMO_CAPABILITY)),
  ]);
  const source = blueprint.data();
  if (!source || source.blueprintId !== blueprintId) return fail("failed-precondition", "Shared preview unavailable.");
  const finalAssignment = await requireAssignment(deps, actor, tx, organizerId);
  expectRevision(finalAssignment.revision, expected);
  const membership = await requirePartner(deps, actor, tx);
  await deps.checkAuth(actor, false);
  const at = deps.now();
  if (Date.parse(finalAssignment.expiresAt) <= at.getTime() || Date.parse(membership.expiresAt) <= at.getTime()) {
    return fail("permission-denied", "Partner access expired during preview preparation.");
  }
  const projected = projectPartnerDemoReview(source, source.partnerReviewGrant,
    {actorUid: actor.uid, organizerId, assignmentRevision: expected}, capability.data() ?? {}, at);
  return {source, projected, at};
}

/** Wording is an unapproved human proposal, never a capability or published demo change. */
export async function proposePartnerDemoWording(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const body = object(payload, ["requestId", "organizerId", "expectedAssignmentRevision", "blueprintId",
    "expectedPreviewHash", "expectedProposalRevision", "wording"]);
  const stableRequestId = requestId(body.requestId); const organizerId = id(body.organizerId);
  const expected = revision(body.expectedAssignmentRevision); const blueprintId = demoId(body.blueprintId);
  const expectedProposalRevision = revision(body.expectedProposalRevision);
  if (typeof body.expectedPreviewHash !== "string" || !/^[a-f0-9]{64}$/u.test(body.expectedPreviewHash)) {
    return fail("invalid-argument", "Exact current preview hash is required.");
  }
  const words = object(body.wording, ["headline", "scenario", "cta"]);
  const wording = {headline: demoText(words.headline), scenario: demoText(words.scenario), cta: demoText(words.cta)};
  const material = {organizerId, expectedAssignmentRevision: expected, blueprintId,
    expectedPreviewHash: body.expectedPreviewHash, expectedProposalRevision, wording};
  const authorize = async (tx: FirebaseFirestore.Transaction) => {
    const value = await currentProposalSource(deps, actor, tx, organizerId, expected, blueprintId);
    if (value.projected.previewHash !== body.expectedPreviewHash) return fail("failed-precondition", "Preview changed; review again.");
    return value;
  };
  const result = await mutatePartnerAction(deps, actor, "partner.demo.wording.propose", stableRequestId,
    material, false, authorize, async (tx) => {
      const value = await authorize(tx);
      const prior = value.source.partnerPreviewProposal as PartnerDemoPreviewProposal | undefined;
      if (prior && prior.partnerUid !== actor.uid) {
        return fail("failed-precondition", "Owner review of an earlier private proposal is required.");
      }
      if (prior) proposalWording(prior);
      const priorRevision = prior?.revision ?? 0;
      expectRevision(priorRevision, expectedProposalRevision);
      const proposal: PartnerDemoPreviewProposal = {revision: expectedProposalRevision + 1,
        state: "pending_owner_review", partnerUid: actor.uid, assignmentRevision: expected,
        blueprintRevision: value.projected.blueprintRevision, sourcePreviewHash: value.projected.previewHash,
        wording, proposedAt: value.at.toISOString()};
      tx.update(deps.db.collection("salesDemoBlueprints").doc(blueprintId), {partnerPreviewProposal: proposal});
      return {organizerId, blueprintId, proposalRevision: proposal.revision,
        sourcePreviewHash: proposal.sourcePreviewHash, state: proposal.state,
        sendAuthority: false, capabilityApprovalAuthority: false, organizerControlAuthority: false};
    });
  // A receipt recovers only the same current own proposal; it never restores an old version.
  await deps.db.runTransaction(async (tx) => {
    const value = await authorize(tx);
    const proposal = value.source.partnerPreviewProposal as PartnerDemoPreviewProposal | undefined;
    if (proposal?.partnerUid !== actor.uid || proposal.assignmentRevision !== expected ||
        proposal.revision !== result.proposalRevision || proposal.sourcePreviewHash !== body.expectedPreviewHash ||
        hash(proposal.wording) !== hash(wording) || proposal.state !== "pending_owner_review") {
      return fail("failed-precondition", "Proposal receipt is no longer current.");
    }
  });
  return result;
}

/** Bounded discovery of explicitly shared previews, without invitations or grants. */
export async function listPartnerDemoReviews(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const body = object(payload, ["organizerId", "expectedAssignmentRevision"]);
  const organizerId = id(body.organizerId); const expected = revision(body.expectedAssignmentRevision);
  await deps.checkAuth(actor, false);
  return deps.db.runTransaction(async (tx) => {
    const assignment = await requireAssignment(deps, actor, tx, organizerId);
    expectRevision(assignment.revision, expected);
    const [blueprints, capability] = await Promise.all([
      tx.get(deps.db.collection("salesDemoBlueprints").where("organizerId", "==", organizerId).limit(21)),
      tx.get(deps.db.collection("salesDemoCapabilities").doc(DEMO_CAPABILITY)),
    ]);
    if (blueprints.size > 20) return fail("resource-exhausted", "Demo previews need curation before partner review.");
    const finalAssignment = await requireAssignment(deps, actor, tx, organizerId);
    expectRevision(finalAssignment.revision, expected);
    const membership = await requirePartner(deps, actor, tx);
    await deps.checkAuth(actor, false);
    const at = deps.now();
    if (Date.parse(finalAssignment.expiresAt) <= at.getTime() || Date.parse(membership.expiresAt) <= at.getTime()) {
      return fail("permission-denied", "Partner access expired during preview preparation.");
    }
    const rows = [];
    for (const snapshot of blueprints.docs) {
      const source = snapshot.data();
      if (source.blueprintId !== snapshot.id || source.partnerReviewGrant?.partnerUid !== actor.uid) continue;
      try {
        const row = projectPartnerDemoReview(source, source.partnerReviewGrant,
          {actorUid: actor.uid, organizerId, assignmentRevision: expected}, capability.data() ?? {}, at);
        const proposal = source.partnerPreviewProposal as PartnerDemoPreviewProposal | undefined;
        const proposalCurrent = proposal?.partnerUid === actor.uid && proposal.assignmentRevision === expected &&
          proposal.blueprintRevision === row.blueprintRevision && proposal.sourcePreviewHash === row.previewHash &&
          proposal.state === "pending_owner_review";
        rows.push({...row, validUntil: new Date(Math.min(Date.parse(row.validUntil),
          Date.parse(finalAssignment.expiresAt), Date.parse(membership.expiresAt))).toISOString(),
          proposalRevision: proposalCurrent ? proposal!.revision : 0,
          proposedWording: proposalCurrent ? proposalWording(proposal) : null});
      } catch (error) {
        if (error instanceof Error && "code" in error &&
            ["permission-denied", "failed-precondition"].includes(String(error.code))) continue;
        throw error;
      }
    }
    return {organizerId, assignmentRevision: expected, rows, evaluatedAt: at.toISOString(),
      sendAuthority: false, capabilityApprovalAuthority: false, organizerControlAuthority: false};
  });
}
