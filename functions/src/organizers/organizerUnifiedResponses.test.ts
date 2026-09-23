import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import type {CallableRequest} from "firebase-functions/v2/https";
import type {ListOrganizerFormResponsesCallablePayload as Query} from
  "../shared/generated/listOrganizerFormResponsesCallablePayload";
import type {OrganizerFormResponseDocument as Response} from
  "../shared/generated/firestoreAdminTypes";
import {genericFormApplicationId} from "./organizerApplicationAccess";
import {listUnifiedResponses} from "./organizerUnifiedResponses";
import {listOrganizerFormResponsesHandler} from "./organizerFormOperations";
import {organizerContactOriginId} from "../shared/organizerContactOrigins";

type Data = Record<string, Record<string, unknown>>;
const timestamp = (millis: number) =>
  admin.firestore.Timestamp.fromMillis(millis);
const defaults: Query = {organizerId: "org", formId: null, versionId: null,
  statuses: [], identityKinds: [], sourceLinkId: null, query: null,
  fromMillis: null, toMillis: null, cursor: null, limit: 2,
  includeApplications: true};
function response(id: string, time: number): Data {
  return {[`organizerFormResponses/${id}`]: {
    organizerId: "org", formId: "form", versionId: "v1",
    status: "submitted", submittedAt: timestamp(time),
    answerSnapshots: [], withdrawnAt: null,
    respondentUid: null, identityKind: "anonymous", sourceLinkId: null,
    identity: {displayName: id, searchName: id, email: null, phoneE164: null,
      origin: "anonymous"},
  }};
}
function application(id: string, time: number,
  nativeSource?: string, status = "submitted"): Data {
  const responseId = nativeSource ?? `${id}-answer`;
  const source = {kind: nativeSource ? "native" : "tabularImport",
    externalResponseId: responseId, providerId: null};
  return {[`organizerApplications/${id}`]: {
    organizerId: "org", formId: "form", formVersionId: "v1",
    targetKind: "organizer", targetId: null, contactId: null,
    applicantDisplayName: id, applicantDisplayNameNormalized: id,
    reviewStatus: status, latestResponseId: responseId,
    linkedUid: null, source, revision: 1, submittedAt: timestamp(time),
  }, [`organizerApplicationResponses/${responseId}`]: {
    organizerId: "org", applicationId: id, formId: "form",
    formVersionId: "v1", linkedUid: null, source, answers: [],
  }, "organizerFormVersions/v1": {organizerId: "org", formId: "form",
    version: 1, definition: {sections: []}}};
}
async function list(docs: Data, overrides: Partial<Query> = {},
  matches: (row: Response) => Promise<boolean> = async () => true) {
  const data = {...defaults, ...overrides};
  return listUnifiedResponses({db: fakeDb(docs), data,
    filterHash: JSON.stringify({...data, organizerId: null, cursor: null}),
    answerFilterOptions: [], matches,
    project: async (snaps) => snaps.map((snap) => {
      const row = snap.data() as Response;
      return {responseId: snap.id, formId: "form", formTitle: "Form",
        versionId: "v1", version: 1, status: row.status,
        identityKind: row.identityKind, identity: row.identity,
        sourceLinkId: null, sourceLabel: null,
        submittedAtMillis: row.submittedAt.toMillis(), withdrawnAtMillis: null,
        highlights: [], conversionKinds: []};
    })});
}

test(
  "combines native and imported sources once, globally ordered across pages",
  async () => {
    const appId = genericFormApplicationId("native");
    const docs = {...response("ordinary", 100), ...response("native", 300),
      ...application(appId, 300, "native", "approved"),
      ...application("import", 200), ...application("older", 50)};
    const first = await list(docs);
    assert.deepEqual(first.entries?.map((e) => e.entryId),
      ["response:native", "application:import"]);
    assert.equal(first.entries?.[0].application?.reviewStatus, "approved");
    assert.equal(first.entries?.[1].response, null);
    const second = await list(docs, {cursor: first.nextCursor});
    assert.deepEqual(second.entries?.map((e) => e.entryId),
      ["response:ordinary", "application:older"]);
    assert.equal(second.entries?.[0].application, null);
    assert.equal(second.nextCursor, null);
  });

test(
  "lifecycle spans both application sources, excluding ordinary responses",
  async () => {
    const docs = {...response("ordinary", 400), ...response("native", 300),
      ...application(genericFormApplicationId("native"), 300,
        "native", "approved"),
      ...application("approved-import", 200, undefined, "approved"),
      ...application("new-import", 100)};
    const result = await list(docs, {reviewStatus: "approved", limit: 10});
    assert.deepEqual(result.entries?.map((e) => e.entryId),
      ["response:native", "application:approved-import"]);
  });

test(
  "scan boundaries defer imports without dropping sparse matches",
  async () => {
    const docs: Data = {...application("old-import", 1)};
    for (let i = 0; i < 601; i++) {
      Object.assign(docs,
        response(`r${String(i).padStart(4, "0")}`, 1000 - i));
    }
    const matches = async (row: Response) =>
      row.identity.displayName === "r0600";
    const first = await list(docs, {}, matches);
    assert.deepEqual(first.entries, []);
    assert.ok(first.nextCursor);
    const second = await list(docs, {cursor: first.nextCursor}, matches);
    assert.deepEqual(second.entries?.map((e) => e.entryId),
      ["response:r0600", "application:old-import"]);
  });

test(
  "over 500 equal-timestamp responses page correctly in both orders",
  async () => {
    const docs: Data = {...application("tie", 100)};
    for (let i = 0; i < 505; i++) {
      Object.assign(docs,
        response(`r${String(i).padStart(4, "0")}`, 100));
    }
    for (const sortDirection of ["asc", "desc"] as const) {
      const ids: string[] = [];
      let cursor: string | null = null;
      for (let page = 0; page < 10; page++) {
        const result = await list(docs, {sortDirection, cursor, limit: 100});
        ids.push(...result.entries!.map((e) => e.entryId));
        cursor = result.nextCursor;
        if (!cursor) break;
      }
      assert.equal(cursor, null);
      assert.equal(ids.length, 506);
      assert.equal(new Set(ids).size, 506);
    }
  });

test(
  "review or grant changes invalidate outstanding merged cursors",
  async () => {
    const docs = {...application("a", 300), ...application("b", 200),
      ...response("c", 100)};
    const first = await list(docs);
    docs["organizerApplications/a"].revision = 2;
    await assert.rejects(list(docs, {cursor: first.nextCursor}),
      {code: "invalid-argument"});
    await assert.rejects(list(docs, {cursor: "bad"}),
      {code: "invalid-argument"});
  });

test(
  "revoked native application identities are masked before search",
  async () => {
    const docs = application("private-name", 100, "legacy-answer");
    const all = await list(docs);
    assert.equal(all.entries?.[0].application?.applicantDisplayName,
      "Withdrawn applicant");
    assert.deepEqual((await list(docs, {query: "private-name"})).entries, []);
  });

test(
  "withdrawn generic submissions retain one withdrawn lifecycle row",
  async () => {
    const id = genericFormApplicationId("native");
    const docs = {...response("native", 100),
      ...application(id, 100, "native", "approved")};
    docs["organizerFormResponses/native"].status = "withdrawn";
    const result = await list(docs, {reviewStatus: "withdrawn"});
    assert.equal(result.entries?.length, 1);
    assert.equal(result.entries?.[0].entryId, "response:native");
    assert.equal(result.entries?.[0].application?.reviewStatus, "withdrawn");
    assert.equal(result.entries?.[0].application?.dataAccessState,
      "revokedParticipantGrant");
  });

test(
  "generic-only answer and identity filters do not invent imported evidence",
  async () => {
    const docs = {...application("import", 100)};
    assert.deepEqual((await list(docs,
      {identityKinds: ["catchAccount"]})).entries, []);
    assert.deepEqual((await list(docs, {answerFilters:
    [{questionId: "q", values: ["yes"]}]})).entries, []);
    assert.deepEqual((await list(docs, {formId: "other"})).entries, []);
  });

test(
  "contact filters follow canonical origins and reject unavailable contacts",
  async () => {
    const docs: Data = {...response("linked", 100), ...response("other", 90),
      "organizerContacts/contact": {organizerId: "org", deletedAt: null,
        hiddenAt: null, identityState: "unlinked", linkedUid: null}};
    const originId = organizerContactOriginId({organizerId: "org",
      sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
      sourceEntityId: "linked"});
    docs[`organizerContactOrigins/${originId}`] = {
      organizerId: "org", currentContactId: "contact"};
    const result = await list(docs, {contactId: "contact"});
    assert.deepEqual(result.entries?.map((e) => e.entryId),
      ["response:linked"]);
    docs["organizerContacts/contact"].organizerId = "foreign";
    await assert.rejects(list(docs, {contactId: "contact"}),
      {code: "not-found"});
  });

test(
  "application queue overflow fails explicitly",
  async () => {
    const docs: Data = {};
    for (let i = 0; i < 501; i++) Object.assign(docs, application(`a${i}`, i));
    await assert.rejects(list(docs), {code: "resource-exhausted"});
  });

test(
  "unified callable retains organizer manager authority",
  async () => {
    const db = fakeDb({"organizers/org": {ownerUserId: "owner",
      hostUserIds: [], hostProfiles: []}});
    const request = {data: defaults, auth: {uid: "stranger"}} as
    CallableRequest<unknown>;
    await assert.rejects(listOrganizerFormResponsesHandler(request, {
      firestore: () => db, checkRateLimit: async () => undefined,
      timestamp: () => timestamp(0), storageBucket: () => {
        throw Error();
      },
    }), {code: "permission-denied"});
  });

test(
  "callable preserves search, date, status and version filters",
  async () => {
    const docs = {...response("match", 100), ...response("other", 200),
      ...application("import-match", 150),
      "organizers/org": {ownerUserId: "owner", hostUserIds: ["owner"],
        hostProfiles: []},
      "organizerForms/form": {organizerId: "org", title: "Form"}};
    const db = fakeDb(docs);
    const result = await listOrganizerFormResponsesHandler({
      data: {...defaults, query: "match", fromMillis: 50, toMillis: 175,
        statuses: ["submitted"], versionId: "v1"}, auth: {uid: "owner"},
    } as CallableRequest<unknown>, {
      firestore: () => db, checkRateLimit: async () => undefined,
      timestamp: () => timestamp(0), storageBucket: () => {
        throw Error();
      },
    });
    assert.deepEqual(result.entries?.map((e) => e.entryId),
      ["application:import-match", "response:match"]);
  });

test("unified cursors cannot be replayed across organizers", async () => {
  const docs = {...response("a", 300), ...response("b", 200),
    ...response("c", 100)};
  const page = await list(docs);
  await assert.rejects(list(docs, {organizerId: "other",
    cursor: page.nextCursor}), {code: "invalid-argument"});
});

test("answer filters without a version bind to the active version and cursor",
  async () => {
    const docs: Data = {...response("old", 300),
      ...response("new-a", 200), ...response("new-b", 100),
      "organizers/org": {ownerUserId: "owner", hostUserIds: ["owner"],
        hostProfiles: []},
      "organizerForms/form": {organizerId: "org", activeVersionId: "v2"},
    };
    const definition = {sections: [{questions: [{questionId: "city",
      label: "City", kind: "singleChoice", hostPresentation: "filterable",
      options: [{value: "same", label: "Same label"}]}]}]};
    docs["organizerFormVersions/v1"] = {organizerId: "org", formId: "form",
      version: 1, definition};
    docs["organizerFormVersions/v2"] = {organizerId: "org", formId: "form",
      version: 2, definition};
    for (const id of ["old", "new-a", "new-b"]) {
      docs[`organizerFormResponses/${id}`].versionId =
        id === "old" ? "v1" : "v2";
      docs[`organizerFormResponses/${id}`].answerSnapshots = [
        {questionId: "city", answer: "same"}];
    }
    const deps = {firestore: () => fakeDb(docs),
      checkRateLimit: async () => undefined,
      timestamp: () => timestamp(0), storageBucket: () => {
        throw Error();
      }};
    const query = {...defaults, formId: "form", limit: 1,
      answerFilters: [{questionId: "city", values: ["same"]}]};
    const run = (overrides: Partial<Query> = {}) =>
      listOrganizerFormResponsesHandler({data: {...query, ...overrides},
        auth: {uid: "owner"}} as CallableRequest<unknown>, deps);
    const first = await run();
    assert.deepEqual(first.entries?.map((row) => row.entryId),
      ["response:new-a"]);
    assert.ok(first.nextCursor);
    const second = await run({cursor: first.nextCursor});
    assert.deepEqual(second.entries?.map((row) => row.entryId),
      ["response:new-b"]);
    assert.deepEqual((await run({versionId: "v1"})).entries?.map((row) =>
      row.entryId), ["response:old"]);
    await assert.rejects(run({versionId: "v1", cursor: first.nextCursor}),
      {code: "invalid-argument"});
    docs["organizerForms/form"].activeVersionId = "v1";
    await assert.rejects(run({cursor: first.nextCursor}),
      {code: "invalid-argument"});
  });

test("sparse active-version matches retain continuation at the scan bound",
  async () => {
    const docs: Data = {
      "organizers/org": {ownerUserId: "owner", hostUserIds: ["owner"],
        hostProfiles: []},
      "organizerForms/form": {organizerId: "org", activeVersionId: "v2"},
      "organizerFormVersions/v2": {organizerId: "org", formId: "form",
        version: 2, definition: {sections: [{questions: [{questionId: "city",
          label: "City", kind: "singleChoice",
          hostPresentation: "filterable", options: [
            {value: "yes", label: "Yes"}]}]}]}},
    };
    for (let i = 0; i < 501; i++) {
      const id = `old-${String(i).padStart(3, "0")}`;
      Object.assign(docs, response(id, 1000 - i));
    }
    Object.assign(docs, response("current", 1));
    docs["organizerFormResponses/current"].versionId = "v2";
    docs["organizerFormResponses/current"].answerSnapshots = [
      {questionId: "city", answer: "yes"}];
    const deps = {firestore: () => fakeDb(docs),
      checkRateLimit: async () => undefined,
      timestamp: () => timestamp(0), storageBucket: () => {
        throw Error();
      }};
    for (const includeApplications of [false, true]) {
      const query = {...defaults, formId: "form", includeApplications,
        answerFilters: [{questionId: "city", values: ["yes"]}]};
      const run = (cursor: string | null) =>
        listOrganizerFormResponsesHandler({data: {...query, cursor},
          auth: {uid: "owner"}} as CallableRequest<unknown>, deps);
      const first = await run(null);
      assert.deepEqual(first.items, []);
      assert.ok(first.nextCursor);
      const second = await run(first.nextCursor);
      assert.deepEqual(second.items.map((row) => row.responseId),
        ["current"]);
    }
  });

test("legacy imported form and version scopes work", async () => {
  const docs: Data = {...application("import", 100),
    "organizers/org": {ownerUserId: "owner", hostUserIds: ["owner"],
      hostProfiles: []},
    "organizerApplicationForms/form": {organizerId: "org"},
    "organizerApplicationFormVersions/v1": {organizerId: "org",
      formId: "form"}};
  const db = fakeDb(docs);
  const request = {data: {...defaults, formId: "form", versionId: "v1"},
    auth: {uid: "owner"}} as CallableRequest<unknown>;
  const deps = {firestore: () => db, checkRateLimit: async () => undefined,
    timestamp: () => timestamp(0), storageBucket: () => {
      throw Error();
    }};
  const result = await listOrganizerFormResponsesHandler(request, deps);
  assert.equal(result.entries?.[0].entryId, "application:import");
  assert.deepEqual(result.answerFilterOptions, []);
  docs["organizerApplicationFormVersions/v1"].organizerId = "foreign";
  await assert.rejects(listOrganizerFormResponsesHandler(request, deps),
    {code: "not-found"});
  docs["organizerApplicationForms/form"].organizerId = "foreign";
  await assert.rejects(listOrganizerFormResponsesHandler(request, deps),
    {code: "not-found"});
});

function fakeDb(docs: Data): FirebaseFirestore.Firestore {
  class Snapshot {
    constructor(readonly path: string) {}
    get id() {
      return this.path.split("/").at(-1)!;
    }
    get exists() {
      return !!docs[this.path];
    }
    data() {
      return docs[this.path];
    }
  }
  class Collection {
    filters: [string, unknown][] = [];
    orders: [string, string][] = [];
    count = Infinity;
    position: unknown[] | null = null;
    inclusive = false;
    constructor(readonly path: string) {}
    doc(id: string) {
      return {path: `${this.path}/${id}`,
        get: async () => new Snapshot(`${this.path}/${id}`)};
    }
    where(field: string, _operator: string, value: unknown) {
      this.filters.push([field, value]); return this;
    }
    orderBy(field: string | object, direction = "asc") {
      this.orders.push([typeof field === "string" ? field : "__name__",
        direction]);
      return this;
    }
    limit(count: number) {
      this.count = count; return this;
    }
    startAfter(...values: unknown[]) {
      this.position = values; return this;
    }
    startAt(...values: unknown[]) {
      this.position = values; this.inclusive = true; return this;
    }
    async get() {
      const value = (snap: Snapshot, key: string) => key === "__name__" ?
        snap.id : snap.data()[key];
      const scalar = (v: unknown) => v instanceof admin.firestore.Timestamp ?
        v.toMillis() : v as string | number;
      const compare = (snap: Snapshot, right: unknown[]) => {
        for (let i = 0; i < right.length; i++) {
          const [key, direction] = this.orders[i];
          const a = scalar(value(snap, key)); const b = scalar(right[i]);
          const result = a < b ? -1 : a > b ? 1 : 0;
          if (result) return direction === "asc" ? result : -result;
        }
        return 0;
      };
      let rows = Object.keys(docs).filter((path) =>
        path.startsWith(`${this.path}/`)).map((path) => new Snapshot(path))
        .filter((snap) => this.filters
          .every(([key, v]) => snap.data()[key] === v));
      rows.sort((a, b) => compare(a, this.orders
        .map(([key]) => value(b, key))));
      if (this.position) {
        const [first] = this.position;
        const anchor = first instanceof Snapshot ?
          this.orders.map(([key]) => value(first, key)) : this.position;
        rows = rows.filter((snap) => this.inclusive ?
          compare(snap, anchor) >= 0 : compare(snap, anchor) > 0);
      }
      rows = rows.slice(0, this.count);
      return {docs: rows, size: rows.length, empty: !rows.length};
    }
  }
  return {collection: (path: string) => new Collection(path),
    getAll: async (...refs: {path: string}[]) =>
      refs.map((ref) => new Snapshot(ref.path))} as unknown as
    FirebaseFirestore.Firestore;
}
