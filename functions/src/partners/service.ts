import * as admin from "firebase-admin";
import {prepareHostSalesIntent} from "../waitlist/hostSalesIntent";
import {assertSalesPrivacyOpen} from "../admin/salesPrivacy/model";
import {PARTNER_TERMS_VERSION, MEMBERSHIPS, ASSIGNMENTS,
  employee, expectRevision, fail, future, hash, id, object, officialUrl,
  requestId, revision, text, type PartnerActor, type PartnerAssignment,
  type PartnerDeps, type PartnerMembership} from "./model";

type Tx = FirebaseFirestore.Transaction;

export async function requirePartner(deps: PartnerDeps, actor: PartnerActor,
  tx: Tx): Promise<PartnerMembership> {
  await deps.checkAuth(actor, false);
  const [snap, deleted] = await Promise.all([
    tx.get(deps.db.collection(MEMBERSHIPS).doc(actor.uid)),
    tx.get(deps.db.collection("deletedUsers").doc(actor.uid)),
  ]);
  const row = snap.data() as PartnerMembership | undefined;
  if (deleted.exists || row?.uid !== actor.uid || row.schemaVersion !== 1 ||
      row.classification !== "sales_private" || row.status !== "active" ||
      row.termsVersion !== PARTNER_TERMS_VERSION ||
      !Number.isFinite(Date.parse(row.expiresAt)) ||
      Date.parse(row.expiresAt) <= deps.now().getTime()) {
    return fail("permission-denied", "Current accepted partner membership is required.");
  }
  return row;
}

/** One organizer-scoped assignment is the cross-channel reservation. */
export async function requireAssignment(deps: PartnerDeps, actor: PartnerActor,
  tx: Tx, organizerId: string, accepted = true, allowDeclined = false): Promise<PartnerAssignment> {
  await requirePartner(deps, actor, tx);
  await assertSalesPrivacyOpen(tx, deps.db, organizerId);
  const [snap, account, organizer] = await Promise.all([
    tx.get(deps.db.collection(ASSIGNMENTS).doc(organizerId)),
    tx.get(deps.db.collection("organizerSalesAccounts").doc(organizerId)),
    tx.get(deps.db.collection("organizers").doc(organizerId)),
  ]);
  const row = snap.data() as PartnerAssignment | undefined;
  if (row?.classification !== "sales_private" || row.schemaVersion !== 1 ||
      row.organizerId !== organizerId || row.partnerUid !== actor.uid ||
      !(allowDeclined ? ["offered", "accepted", "declined"] : ["offered", "accepted"]).includes(row.status) ||
      accepted && row.status !== "accepted" ||
      !Number.isFinite(Date.parse(row.expiresAt)) ||
      Date.parse(row.expiresAt) <= deps.now().getTime()) {
    return fail("permission-denied", "Current organizer assignment is required.");
  }
  const sales = account.data();
  if (!organizer.exists || organizer.data()?.archived === true ||
      organizer.data()?.status === "archived" ||
      sales?.organizerId !== organizerId || sales.classification !== "sales_private" ||
      sales.researchStatus === "archived" || sales.suppressionStatus !== "clear" ||
      sales.duplicateReviewRequired) {
    return fail("failed-precondition", "Organizer identity or suppression blocks partner work.");
  }
  return row;
}

async function mutate(deps: PartnerDeps, actor: PartnerActor, action: string,
  request: string, material: Record<string, unknown>, employeeReview: boolean,
  authorize: (tx: Tx) => Promise<unknown>,
  apply: (tx: Tx, now: string) => Promise<Record<string, unknown>>,
): Promise<Record<string, unknown>> {
  if (employeeReview) employee(actor);
  await deps.checkAuth(actor, employeeReview);
  const requestHash = hash({action, material});
  const receipt = deps.db.collection("salesActionReceipts")
    .doc(hash(`${actor.uid}\u0000${request}`));
  return deps.db.runTransaction(async (tx) => {
    await deps.checkAuth(actor, employeeReview);
    await authorize(tx);
    const prior = (await tx.get(receipt)).data();
    if (prior) {
      if (prior.actorUid !== actor.uid || prior.action !== action ||
          prior.requestHash !== requestHash) {
        return fail("already-exists", "Request ID belongs to different partner work.");
      }
      return prior.result as Record<string, unknown>;
    }
    const now = deps.now().toISOString();
    const result = await apply(tx, now);
    tx.create(receipt, {schemaVersion: 1, classification: "sales_private",
      actorUid: actor.uid, action, requestId: request,
      requestHash, organizerId: material.organizerId ?? null,
      result,
      createdAt: now, clientId: null, clientAuthUid: null, delegationId: null});
    return result;
  });
}

export async function registerPartner(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["requestId", "displayName", "termsVersion"]);
  const request = requestId(input.requestId);
  const displayName = text(input.displayName, 100);
  if (input.termsVersion !== PARTNER_TERMS_VERSION) {
    return fail("invalid-argument", "Accept the current bounded referral role terms.");
  }
  return mutate(deps, actor, "partner.register", request, {displayName,
    termsVersion: PARTNER_TERMS_VERSION}, false, async (tx) => {
    if ((await tx.get(deps.db.collection("deletedUsers").doc(actor.uid))).exists) {
      fail("permission-denied", "This account cannot join the partner workspace.");
    }
    const prior = (await tx.get(deps.db.collection(MEMBERSHIPS).doc(actor.uid))).data();
    if (prior && (prior.uid !== actor.uid || prior.schemaVersion !== 1 ||
        prior.classification !== "sales_private" || prior.status !== "active" ||
        prior.termsVersion !== PARTNER_TERMS_VERSION ||
        !Number.isFinite(Date.parse(String(prior.expiresAt))) ||
        Date.parse(String(prior.expiresAt)) <= deps.now().getTime())) {
      fail("permission-denied", "Membership needs employee review before renewal.");
    }
  }, async (tx, now) => {
    const ref = deps.db.collection(MEMBERSHIPS).doc(actor.uid);
    const prior = (await tx.get(ref)).data();
    if (prior) return {uid: actor.uid, status: prior.status, revision: prior.revision};
    const row: PartnerMembership = {schemaVersion: 1, classification: "sales_private",
      uid: actor.uid, revision: 1, status: "active", termsVersion: PARTNER_TERMS_VERSION,
      acceptedAt: now, expiresAt: new Date(Date.parse(now) + 90 * 86400000).toISOString(),
      displayName, createdAt: now, updatedAt: now, marketingGrants: []};
    tx.create(ref, row);
    return {uid: actor.uid, status: row.status, revision: row.revision};
  });
}

/** A nomination is an unverified inbound observation, never an identity claim. */
export async function nominateOrganizer(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["requestId", "name", "city", "url", "relationshipContext"]);
  const request = requestId(input.requestId);
  const name = text(input.name, 140);
  const city = text(input.city, 80);
  const url = officialUrl(input.url);
  const relationshipContext = input.relationshipContext === null ? null :
    text(input.relationshipContext, 1000);
  return mutate(deps, actor, "partner.nominate", request,
    {name, city, url, relationshipContext}, false,
    (tx) => requirePartner(deps, actor, tx), async (tx, now) => {
      const membership = await requirePartner(deps, actor, tx);
      const intent = prepareHostSalesIntent({waitlistId: `partner:${actor.uid}`,
        requestId: request, fullName: membership.displayName,
        email: null, city, role: "host", entryRoute: "/partners/",
        hostApplication: {organizationName: name, communityLink: url,
          operatingCity: city, operatingNotes: relationshipContext}})!;
      const row = {...intent, source: "partner", partnerUid: actor.uid,
        email: null, alreadyJoined: false,
        createdAt: admin.firestore.Timestamp.fromDate(new Date(now)),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date(now))};
      // Identity includes the actor and submission; repeated exact nominations
      // recover their immutable receipt without overwriting employee linkage.
      tx.create(deps.db.collection("salesInboundIntents").doc(row.intentId), row);
      return {intentId: row.intentId, status: "needs_identity_review",
        evidenceStatus: "self_reported", organizerId: null};
    });
}

export async function assignPartner(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["requestId", "organizerId", "partnerUid", "expectedRevision",
    "nextAction", "reviewAt", "expiresAt", "reason", "originatorUid"]);
  const request = requestId(input.requestId);
  const organizerId = id(input.organizerId);
  const partnerUid = id(input.partnerUid);
  const expectedRevision = revision(input.expectedRevision);
  const nextAction = text(input.nextAction, 500);
  const reason = text(input.reason, 1000);
  const reviewAt = future(input.reviewAt, deps.now(), 30);
  const expiresAt = future(input.expiresAt, deps.now(), 90);
  if (reviewAt > expiresAt) fail("invalid-argument", "Review must occur before reservation expiry.");
  const originatorUid = input.originatorUid === null ? null : id(input.originatorUid);
  return mutate(deps, actor, "partner.assign", request,
    {organizerId, partnerUid, expectedRevision, nextAction, reviewAt, expiresAt, reason,
      originatorUid}, true, async (tx) => {
    await assertSalesPrivacyOpen(tx, deps.db, organizerId);
    const [member, canonical, account, deleted] = await Promise.all([
      tx.get(deps.db.collection(MEMBERSHIPS).doc(partnerUid)),
      tx.get(deps.db.collection("organizers").doc(organizerId)),
      tx.get(deps.db.collection("organizerSalesAccounts").doc(organizerId)),
      tx.get(deps.db.collection("deletedUsers").doc(partnerUid)),
    ]);
    const m = member.data(); const a = account.data();
    if (deleted.exists || !canonical.exists || canonical.data()?.archived === true ||
        canonical.data()?.status === "archived" || m?.uid !== partnerUid ||
        m.schemaVersion !== 1 || m.classification !== "sales_private" ||
        m.status !== "active" || m.termsVersion !== PARTNER_TERMS_VERSION ||
        !Number.isFinite(Date.parse(String(m.expiresAt))) ||
        Date.parse(m.expiresAt) <= deps.now().getTime() ||
        a?.organizerId !== organizerId || a.classification !== "sales_private" ||
        a.suppressionStatus !== "clear" || a.researchStatus === "archived" ||
        a.duplicateReviewRequired) {
      fail("failed-precondition", "Reviewed canonical identity and eligible partner are required.");
    }
  }, async (tx, now) => {
    const ref = deps.db.collection(ASSIGNMENTS).doc(organizerId);
    const prior = (await tx.get(ref)).data() as PartnerAssignment | undefined;
    expectRevision(prior?.revision ?? 0, expectedRevision);
    if (prior && ["offered", "accepted"].includes(prior.status) &&
        Date.parse(prior.expiresAt) > Date.parse(now) && prior.partnerUid !== partnerUid) {
      fail("failed-precondition", "Resolve the current outreach reservation before reassignment.");
    }
    const row: PartnerAssignment = {schemaVersion: 1, classification: "sales_private",
      organizerId, partnerUid, revision: expectedRevision + 1, status: "offered",
      catchOwnerUid: actor.uid, activationOwnerUid: null, originatorUid,
      introducingSenderUid: null, relationshipContext: null, relationshipConfirmedAt: null,
      channel: null, nextAction, reviewAt, expiresAt, assignedAt: now, updatedAt: now, reason};
    tx.set(ref, row);
    return {organizerId, partnerUid, revision: row.revision, status: row.status};
  });
}

export async function decideAssignment(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["requestId", "organizerId", "expectedRevision", "decision",
    "relationshipContext", "channel"]);
  const request = requestId(input.requestId);
  const organizerId = id(input.organizerId);
  const expectedRevision = revision(input.expectedRevision);
  const decision = input.decision;
  if (decision !== "accept" && decision !== "decline") fail("invalid-argument", "Accept or decline the lead.");
  const relationshipContext = input.relationshipContext === null ? null : text(input.relationshipContext, 1000);
  const channel = input.channel;
  if (decision === "accept" && !["email", "whatsapp", "other"].includes(String(channel)) ||
      decision === "decline" && channel !== null) {
    fail("invalid-argument", "Choose an established channel when accepting.");
  }
  return mutate(deps, actor, "partner.assignment.decide", request,
    {organizerId, expectedRevision, decision, relationshipContext, channel}, false,
    async (tx) => {
      const current = await requireAssignment(deps, actor, tx, organizerId, false, true);
      if (current.revision !== expectedRevision && current.revision !== expectedRevision + 1) {
        fail("aborted", "Assignment generation changed; refresh before reviewing.");
      }
    }, async (tx, now) => {
      const row = await requireAssignment(deps, actor, tx, organizerId, false);
      expectRevision(row.revision, expectedRevision);
      if (row.status !== "offered") fail("failed-precondition", "Lead was already accepted.");
      const next: PartnerAssignment = {...row, revision: row.revision + 1,
        status: decision === "accept" ? "accepted" : "declined", relationshipContext,
        relationshipConfirmedAt: decision === "accept" ? now : null,
        channel: channel as PartnerAssignment["channel"], updatedAt: now};
      tx.set(deps.db.collection(ASSIGNMENTS).doc(organizerId), next);
      return {organizerId, revision: next.revision, status: next.status};
    });
}

export async function revokePartnerAccess(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["requestId", "organizerId", "partnerUid", "expectedRevision", "reason"]);
  const request = requestId(input.requestId);
  const partnerUid = id(input.partnerUid);
  const organizerId = input.organizerId === null ? null : id(input.organizerId);
  const expectedRevision = revision(input.expectedRevision);
  const reason = text(input.reason, 1000);
  return mutate(deps, actor, "partner.revoke", request,
    {organizerId, partnerUid, expectedRevision, reason}, true, async () => undefined,
    async (tx, now) => {
      const ref = deps.db.collection(organizerId ? ASSIGNMENTS : MEMBERSHIPS)
        .doc(organizerId ?? partnerUid);
      const row = (await tx.get(ref)).data();
      if (!row || (organizerId ? row.partnerUid : row.uid) !== partnerUid) {
        fail("not-found", "Partner access record not found.");
      }
      expectRevision(row.revision, expectedRevision);
      tx.set(ref, {...row, revision: expectedRevision + 1, status: "revoked", updatedAt: now});
      return {organizerId, partnerUid, revision: expectedRevision + 1, status: "revoked"};
    });
}

/** No account summary, employee notes, contact inventory, or guest records. */
export async function getPartnerWorkspace(deps: PartnerDeps, actor: PartnerActor,
  payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["cursor"]);
  const cursor = input.cursor === null || input.cursor === undefined ? null : id(input.cursor);
  return deps.db.runTransaction(async (tx) => {
    const membership = await requirePartner(deps, actor, tx);
    let query = deps.db.collection(ASSIGNMENTS).where("partnerUid", "==", actor.uid)
      .orderBy(admin.firestore.FieldPath.documentId());
    if (cursor) query = query.startAfter(cursor);
    const page = await tx.get(query.limit(26));
    const leads = [];
    for (const snap of page.docs.slice(0, 25)) {
      try {
        const assignment = await requireAssignment(deps, actor, tx, snap.id, false);
        const organizer = (await tx.get(deps.db.collection("organizers").doc(snap.id))).data()!;
        leads.push({assignment: {organizerId: assignment.organizerId,
          revision: assignment.revision, status: assignment.status,
          nextAction: assignment.nextAction, reviewAt: assignment.reviewAt,
          expiresAt: assignment.expiresAt, relationshipContext: assignment.relationshipContext,
          channel: assignment.channel}, organizer: {organizerId: snap.id, name: organizer.name,
          city: organizer.cityName ?? null, claimState: organizer.claim?.state ?? "unclaimed"}});
      } catch (error) {
        if (!(error instanceof Error && "code" in error &&
            ["permission-denied", "failed-precondition"].includes(String(error.code)))) throw error;
      }
    }
    const submissions = await tx.get(deps.db.collection("salesInboundIntents")
      .where("partnerUid", "==", actor.uid).orderBy(admin.firestore.FieldPath.documentId()).limit(25));
    const ownSubmissions = [];
    for (const s of submissions.docs) {
      const row = s.data();
      if (typeof row.organizerId === "string") {
        try {await assertSalesPrivacyOpen(tx, deps.db, row.organizerId);}
        catch (error) {
          if (error instanceof Error && "code" in error && error.code === "failed-precondition") continue;
          throw error;
        }
      }
      ownSubmissions.push({intentId: s.id, status: row.status,
        name: row.hostApplication?.organizationName, organizerId: row.organizerId});
    }
    await requirePartner(deps, actor, tx);
    return {membership: {uid: membership.uid, displayName: membership.displayName,
      termsVersion: membership.termsVersion, expiresAt: membership.expiresAt}, leads,
    submissions: ownSubmissions,
    nextCursor: page.size > 25 ? page.docs[24].id : null, sendAuthority: false};
  });
}
