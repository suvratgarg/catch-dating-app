import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import type {firestore} from "firebase-admin";
import {
  activateOrganizerFormDomain, markOrganizerFormCertificateReady,
  reserveOrganizerFormDomain, resolveOrganizerFormDomain,
  revokeOrganizerFormDomain, verifyOrganizerFormDomain,
} from "./organizerFormDomainRegistry";

const now = 1_700_000_000_000;
function fakeDb() {
  const rows = new Map<string, Record<string, unknown>>([
    ["organizerForms/form-a", {organizerId: "organizer-a", status: "published",
      publicFormId: "public-a"}],
  ]);
  const ref = (path: string) => ({path, get: async () => snap(path)});
  const snap = (path: string) => {
    const value = rows.get(path);
    return {exists: !!value, data: () => value,
      get: (field: string) => value?.[field]};
  };
  const db = {
    collection: (name: string) => ({doc: (id: string) => ref(`${name}/${id}`)}),
    runTransaction: async <T>(operation: (tx: {
      get: (document: {path: string}) => Promise<ReturnType<typeof snap>>;
      set: (document: {path: string}, value: Record<string, unknown>) => void;
      update: (document: {path: string},
        value: Record<string, unknown>) => void;
    }) => Promise<T>) => operation({
      get: async (document) => snap(document.path),
      set: (document, value) => {
        rows.set(document.path, value);
      },
      update: (document, value) => {
        rows.set(document.path,
          {...rows.get(document.path), ...value});
      },
    }),
  } as unknown as firestore.Firestore;
  return {db, rows};
}

const manager = async () => undefined;
const input = {hostname: "apply.client.example", organizerId: "organizer-a",
  formId: "form-a", actorUid: "manager-a"};
const hostingTarget = "custom.catchdates.com";

describe("organizer form domain registry", () => {
  it("reclaims only expired pending leases with a new generation", async () => {
    const {db, rows} = fakeDb();
    rows.set("organizerForms/form-b", {organizerId: "organizer-b",
      status: "published", publicFormId: "public-b"});
    const first = await reserveOrganizerFormDomain(db, input, now,
      hostingTarget, manager);
    const other = {...input, organizerId: "organizer-b", formId: "form-b"};
    await assert.rejects(reserveOrganizerFormDomain(db, other,
      now + 48 * 60 * 60 * 1000 - 1, hostingTarget, manager));
    await assert.rejects(verifyOrganizerFormDomain(db, input.hostname,
      {hostname: input.hostname,
        txtValues: [first.ownershipChallenge],
        cnameTarget: hostingTarget, checkedAtMillis:
          now + 48 * 60 * 60 * 1000},
      now + 48 * 60 * 60 * 1000));
    const replacement = await reserveOrganizerFormDomain(db, other,
      now + 48 * 60 * 60 * 1000, hostingTarget, manager);
    assert.equal(replacement.generation, first.generation + 1);
    assert.notEqual(replacement.ownershipChallenge,
      first.ownershipChallenge);
    await assert.rejects(verifyOrganizerFormDomain(db, input.hostname,
      {hostname: input.hostname,
        txtValues: [first.ownershipChallenge],
        cnameTarget: hostingTarget, checkedAtMillis:
          now + 48 * 60 * 60 * 1000},
      now + 48 * 60 * 60 * 1000, input.organizerId));
    await assert.rejects(markOrganizerFormCertificateReady(db,
      input.hostname, first.generation));
  });

  it("reserves one host, checks evidence, and revokes routing", async () => {
    const {db, rows} = fakeDb();
    const pending = await reserveOrganizerFormDomain(db, input, now,
      hostingTarget, manager);
    assert.equal(pending.status, "pending");
    assert.equal(pending.expectedCname, hostingTarget);
    await assert.rejects(reserveOrganizerFormDomain(db, input, now,
      hostingTarget, manager));
    const probe = {hostname: input.hostname,
      txtValues: [pending.ownershipChallenge], cnameTarget: hostingTarget,
      checkedAtMillis: now};
    let dnsCalls = 0;
    const loadProbe = async () => {
      dnsCalls++;
      return probe;
    };
    assert.equal(await resolveOrganizerFormDomain(
      db, "absent.client.example", loadProbe, now), null);
    assert.equal(await resolveOrganizerFormDomain(
      db, input.hostname, loadProbe, now), null);
    assert.equal(dnsCalls, 0);
    assert.equal(await resolveOrganizerFormDomain(
      db, input.hostname, probe, now), null);
    await assert.rejects(verifyOrganizerFormDomain(db, input.hostname,
      {...probe, txtValues: []}, now));
    await assert.rejects(verifyOrganizerFormDomain(db, input.hostname,
      probe, now, "organizer-b"));
    const verified = await verifyOrganizerFormDomain(
      db, input.hostname, probe, now);
    await assert.rejects(activateOrganizerFormDomain(
      db, input.hostname, probe, now));
    await markOrganizerFormCertificateReady(
      db, input.hostname, verified.generation);
    await activateOrganizerFormDomain(db, input.hostname, probe, now);
    assert.deepEqual(await resolveOrganizerFormDomain(
      db, input.hostname, loadProbe, now), {
      organizerId: "organizer-a", publicFormId: "public-a",
    });
    assert.equal(dnsCalls, 1);
    let afterDns = now;
    assert.deepEqual(await resolveOrganizerFormDomain(
      db, input.hostname, async () => {
        afterDns = now + 500;
        return {...probe, checkedAtMillis: afterDns};
      }, () => afterDns), {
      organizerId: "organizer-a", publicFormId: "public-a",
    });
    assert.equal(await resolveOrganizerFormDomain(
      db, input.hostname, {...probe, checkedAtMillis: now + 500}, now),
    null);
    assert.deepEqual(await resolveOrganizerFormDomain(
      db, input.hostname, probe, now), {
      organizerId: "organizer-a", publicFormId: "public-a",
    });
    rows.set("organizerForms/form-a", {organizerId: "organizer-b",
      publicFormId: "public-a", status: "published"});
    assert.equal(await resolveOrganizerFormDomain(
      db, input.hostname, probe, now), null);
    rows.set("organizerForms/form-a", {organizerId: "organizer-a",
      publicFormId: "public-a", status: "published"});
    assert.equal(await resolveOrganizerFormDomain(db, input.hostname,
      {...probe, cnameTarget: "other.example"}, now), null);
    await revokeOrganizerFormDomain(db, input.hostname, input.organizerId,
      input.actorUid, manager);
    assert.equal(await resolveOrganizerFormDomain(
      db, input.hostname, loadProbe, now), null);
    assert.equal(dnsCalls, 1);
    assert.equal(await resolveOrganizerFormDomain(
      db, input.hostname, probe, now), null);
    const replacement = await reserveOrganizerFormDomain(db,
      {...input, organizerId: "organizer-a"}, now, hostingTarget, manager);
    assert.equal(replacement.generation, 2);
    assert.notEqual(replacement.ownershipChallenge, pending.ownershipChallenge);
    assert.equal(await resolveOrganizerFormDomain(
      db, input.hostname, probe, now), null);
    await assert.rejects(markOrganizerFormCertificateReady(db,
      input.hostname, pending.generation));
    await assert.rejects(verifyOrganizerFormDomain(db, input.hostname,
      probe, now));
  });

  for (const change of ["unchanged", "revoked", "deleted", "certificate",
    "generation", "reassigned", "wrong-form", "unpublished", "form-owner",
    "public-id", "no-proof"] as const) {
    it(`revalidates ${change} binding after a held DNS probe`, async () => {
      const {db, rows} = fakeDb();
      const pending = await reserveOrganizerFormDomain(db, input, now,
        hostingTarget, manager);
      let proof = {hostname: input.hostname,
        txtValues: [pending.ownershipChallenge], cnameTarget: hostingTarget,
        checkedAtMillis: now};
      await verifyOrganizerFormDomain(db, input.hostname, proof, now);
      await markOrganizerFormCertificateReady(db, input.hostname,
        pending.generation);
      await activateOrganizerFormDomain(db, input.hostname, proof, now);
      let started!: () => void;
      let release!: () => void;
      const probeStarted = new Promise<void>((resolve) => {
        started = resolve;
      });
      const probeHeld = new Promise<void>((resolve) => {
        release = resolve;
      });
      const lookup = resolveOrganizerFormDomain(db, input.hostname,
        async () => {
          started();
          await probeHeld;
          return change === "no-proof" ? null : proof;
        }, () => now);
      await probeStarted;
      if (change === "no-proof") {
        db.runTransaction = async () => {
          throw new Error("Unavailable DNS must not start a transaction");
        };
      }
      const domainPath = `organizerFormDomains/${input.hostname}`;
      const formPath = "organizerForms/form-a";
      if (["revoked", "generation", "reassigned"].includes(change)) {
        await revokeOrganizerFormDomain(db, input.hostname,
          input.organizerId, input.actorUid, manager);
      }
      if (change === "generation" || change === "reassigned") {
        const nextInput = change === "generation" ? input : {...input,
          organizerId: "organizer-b", formId: "form-b"};
        rows.set(`organizerForms/${nextInput.formId}`, {
          organizerId: nextInput.organizerId, status: "published",
          publicFormId: change === "generation" ? "public-a" : "public-b",
        });
        const next = await reserveOrganizerFormDomain(db, nextInput, now,
          hostingTarget, manager);
        // DNS now genuinely proves the replacement. The original in-flight
        // lookup must still not cross its reservation generation boundary.
        proof = {...proof, txtValues: [next.ownershipChallenge]};
        await verifyOrganizerFormDomain(db, input.hostname, proof, now);
        await markOrganizerFormCertificateReady(db, input.hostname,
          next.generation);
        await activateOrganizerFormDomain(db, input.hostname, proof, now);
      }
      if (change === "deleted") rows.delete(domainPath);
      if (change === "certificate") {
        rows.set(domainPath,
          {...rows.get(domainPath), certificateStatus: "failed"});
      }
      if (change === "wrong-form") {
        rows.set("organizerForms/form-b", {...rows.get(formPath)});
        rows.set(domainPath, {...rows.get(domainPath), formId: "form-b"});
      }
      if (change === "unpublished") {
        rows.set(formPath,
          {...rows.get(formPath), status: "draft"});
      }
      if (change === "form-owner") {
        rows.set(formPath,
          {...rows.get(formPath), organizerId: "organizer-b"});
      }
      if (change === "public-id") {
        rows.set(formPath,
          {...rows.get(formPath), publicFormId: "public-b"});
      }
      release();
      assert.deepEqual(await lookup, change === "unchanged" ? {
        organizerId: "organizer-a", publicFormId: "public-a",
      } : null);
    });
  }
});
