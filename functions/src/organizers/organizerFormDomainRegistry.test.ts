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
});
