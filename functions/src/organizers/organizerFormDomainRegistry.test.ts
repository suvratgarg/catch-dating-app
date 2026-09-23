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
      update: (document: {path: string}, value: Record<string, unknown>) => void;
    }) => Promise<T>) => operation({
      get: async (document) => snap(document.path),
      set: (document, value) => { rows.set(document.path, value); },
      update: (document, value) => { rows.set(document.path,
        {...rows.get(document.path), ...value}); },
    }),
  } as unknown as firestore.Firestore;
  return {db, rows};
}

const manager = async () => undefined;
const input = {hostname: "apply.client.example", organizerId: "organizer-a",
  formId: "form-a", actorUid: "manager-a", expectedCname: "custom.catch-hosting.example"};

describe("organizer form domain registry", () => {
  it("reserves one exact host, checks live evidence, and revokes routing", async () => {
    const {db, rows} = fakeDb();
    const pending = await reserveOrganizerFormDomain(db, input, now, manager);
    assert.equal(pending.status, "pending");
    await assert.rejects(reserveOrganizerFormDomain(db, input, now, manager));
    const probe = {hostname: input.hostname,
      txtValues: [pending.ownershipChallenge], cnameTarget: input.expectedCname,
      checkedAtMillis: now};
    assert.equal(await resolveOrganizerFormDomain(db, input.hostname, probe, now), null);
    await assert.rejects(verifyOrganizerFormDomain(db, input.hostname,
      {...probe, txtValues: []}, now));
    const verified = await verifyOrganizerFormDomain(db, input.hostname, probe, now);
    await assert.rejects(activateOrganizerFormDomain(db, input.hostname, probe, now));
    await markOrganizerFormCertificateReady(db, input.hostname, verified.generation);
    await activateOrganizerFormDomain(db, input.hostname, probe, now);
    assert.deepEqual(await resolveOrganizerFormDomain(db, input.hostname, probe, now), {
      organizerId: "organizer-a", publicFormId: "public-a",
    });
    rows.set("organizerForms/form-a", {organizerId: "organizer-b",
      publicFormId: "public-a", status: "published"});
    assert.equal(await resolveOrganizerFormDomain(db, input.hostname, probe, now), null);
    rows.set("organizerForms/form-a", {organizerId: "organizer-a",
      publicFormId: "public-a", status: "published"});
    assert.equal(await resolveOrganizerFormDomain(db, input.hostname,
      {...probe, cnameTarget: "other.example"}, now), null);
    await revokeOrganizerFormDomain(db, input.hostname, input.organizerId,
      input.actorUid, manager);
    assert.equal(await resolveOrganizerFormDomain(db, input.hostname, probe, now), null);
    const replacement = await reserveOrganizerFormDomain(db,
      {...input, organizerId: "organizer-a"}, now, manager);
    assert.equal(replacement.generation, 2);
    assert.notEqual(replacement.ownershipChallenge, pending.ownershipChallenge);
    assert.equal(await resolveOrganizerFormDomain(db, input.hostname, probe, now), null);
  });
});
