import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import test from "node:test";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getEmulatorFirestore} from "../shared/testing/emulatorFirestore";
import {
  activateOrganizerFormDomain, reserveOrganizerFormDomain,
  resolveOrganizerFormDomain, revokeOrganizerFormDomain,
  verifyOrganizerFormDomain,
} from "./organizerFormDomainRegistry";

const projectId = "demo-catch-rules";
const target = "domain-test-site.web.app";

async function fixture() {
  const id = randomUUID();
  const app = initializeApp({projectId}, `domain-${id}`);
  const db = getEmulatorFirestore(app);
  const now = Date.now();
  const input = {hostname: `forms-${id}.client.example`,
    organizerId: `domain-org-${id}`, formId: `domain-form-${id}`,
    actorUid: `domain-manager-${id}`};
  const organizer = db.doc(`organizers/${input.organizerId}`);
  const form = db.doc(`organizerForms/${input.formId}`);
  const domain = db.doc(`organizerFormDomains/${input.hostname}`);
  await organizer.set({hostUserId: input.actorUid,
    ownerUserId: input.actorUid, hostUserIds: [input.actorUid],
    hostProfiles: []});
  await form.set({organizerId: input.organizerId, status: "published",
    publicFormId: `domain-public-${id}`});
  const reserve = () => reserveOrganizerFormDomain(db, input, now, target);
  const verified = async () => {
    const pending = await reserve();
    const probe = {hostname: input.hostname,
      txtValues: [pending.ownershipChallenge], cnameTarget: target,
      checkedAtMillis: now};
    const expected = await verifyOrganizerFormDomain(db, input.hostname,
      probe, now, input.organizerId);
    return {expected, probe};
  };
  const activate = (proof: Awaited<ReturnType<typeof verified>>) =>
    activateOrganizerFormDomain(db, {...proof, actorUid: input.actorUid,
      trustedProjectId: projectId, certificate: {projectId,
        siteId: "domain-test-site", hostname: input.hostname,
        observedAtMillis: now, expiresAtMillis: now + 86_400_000}}, () => now);
  const revoke = () => revokeOrganizerFormDomain(db, input.hostname,
    input.organizerId, input.actorUid);
  const close = async () => {
    await Promise.all([domain, form, organizer].map((ref) => ref.delete()));
    await db.terminate();
    await deleteApp(app);
  };
  return {db, input, now, organizer, form, domain, reserve, verified,
    activate, revoke, close};
}

test("Firestore reserves one domain generation under competing requests",
  {skip: !process.env.FIRESTORE_EMULATOR_HOST}, async () => {
    const h = await fixture();
    try {
      const attempts = await Promise.allSettled([h.reserve(), h.reserve()]);
      assert.equal(attempts.filter((r) => r.status === "fulfilled").length, 1);
      assert.equal(attempts.filter((r) => r.status === "rejected").length, 1);
      const domain = (await h.domain.get()).data()!;
      assert.equal(domain.generation, 1);
      assert.equal(domain.status, "pending");
      assert.equal(domain.certificateStatus, "pending");
    } finally {
      await h.close();
    }
  });

test("Firestore atomically activates and idempotently resolves the exact form",
  {skip: !process.env.FIRESTORE_EMULATOR_HOST}, async () => {
    const h = await fixture();
    try {
      const proof = await h.verified();
      const result = await h.activate(proof);
      assert.equal(result.status, "active");
      assert.equal(result.certificateStatus, "ready");
      assert.deepEqual(await h.activate(proof), result);
      assert.deepEqual(await resolveOrganizerFormDomain(h.db,
        h.input.hostname, proof.probe, () => h.now), {
        organizerId: h.input.organizerId,
        publicFormId: result.publicFormId,
      });
    } finally {
      await h.close();
    }
  });

test("Firestore concurrent revocation wins over activation of old evidence",
  {skip: !process.env.FIRESTORE_EMULATOR_HOST}, async () => {
    const h = await fixture();
    try {
      const proof = await h.verified();
      const results = await Promise.allSettled([
        h.activate(proof), h.revoke(),
      ]);
      assert.equal(results[1].status, "fulfilled");
      assert.equal((await h.domain.get()).get("status"), "revoked");
      assert.equal((await h.domain.get()).get("certificateStatus"), "pending");
      await assert.rejects(h.activate(proof));
      assert.equal(await resolveOrganizerFormDomain(h.db, h.input.hostname,
        proof.probe, () => h.now), null);
    } finally {
      await h.close();
    }
  });

for (const change of ["manager", "unpublished", "reassigned"] as const) {
  test(`Firestore rejects ${change} after provider evidence was obtained`,
    {skip: !process.env.FIRESTORE_EMULATOR_HOST}, async () => {
      const h = await fixture();
      try {
        const proof = await h.verified();
        if (change === "manager") {
          await h.organizer.set({hostUserId: "replacement",
            ownerUserId: "replacement", hostUserIds: ["replacement"],
            hostProfiles: []});
        } else if (change === "unpublished") {
          await h.form.update({status: "draft"});
        } else {
          await h.revoke();
          const next = await h.reserve();
          assert.equal(next.generation, proof.expected.generation + 1);
          assert.notEqual(next.ownershipChallenge,
            proof.expected.ownershipChallenge);
        }
        const before = (await h.domain.get()).data();
        await assert.rejects(h.activate(proof));
        assert.deepEqual((await h.domain.get()).data(), before);
        assert.equal((await h.domain.get()).get("certificateStatus"),
          "pending");
      } finally {
        await h.close();
      }
    });
}

test("Firestore held DNS resolution cannot outlive committed revocation",
  {skip: !process.env.FIRESTORE_EMULATOR_HOST}, async () => {
    const h = await fixture();
    let release!: () => void;
    let lookup: ReturnType<typeof resolveOrganizerFormDomain> | undefined;
    try {
      const proof = await h.verified();
      await h.activate(proof);
      let started!: () => void;
      const began = new Promise<void>((resolve) => {
        started = resolve;
      });
      const held = new Promise<void>((resolve) => {
        release = resolve;
      });
      lookup = resolveOrganizerFormDomain(h.db, h.input.hostname, async () => {
        started(); await held; return proof.probe;
      }, () => h.now);
      await began;
      await h.revoke();
      release();
      assert.equal(await lookup, null);
    } finally {
      release?.();
      await lookup?.catch(() => undefined);
      await h.close();
    }
  });
