import assert from "node:assert/strict";
import test from "node:test";
import ExcelJS from "exceljs";
import * as admin from "firebase-admin";
import {processOrganizerFormExport, requestOrganizerFormExportHandler}
  from "./organizerFormExports";
import {runFirestoreResponseQuery} from
  "../organizerResponseQuery/firestoreAdapter";
import {AudienceTestStore} from "./organizerAudienceTestStore";

function exportFixture(overflow: boolean) {
  const timestamp = admin.firestore.Timestamp.fromMillis(1000);
  const docs: Record<string, Record<string, unknown>> = {
    "organizerFormExports/export-1": {
      organizerId: "org-1", formId: "form-1", status: "pending",
      format: "csv", statuses: ["submitted"], versionId: null,
      fromMillis: null, toMillis: null, rowCount: 0, storagePath: null,
    },
    "organizerFormVersions/version-1": {version: 1},
  };
  const addResponse = (index: number, status: string) => {
    const responseId = `response-${String(index).padStart(5, "0")}`;
    docs[`organizerFormResponses/${responseId}`] = {
      organizerId: "org-1", formId: "form-1", versionId: "version-1",
      status, submittedAt: admin.firestore.Timestamp.fromMillis(index + 1000),
      withdrawnAt: null, identityKind: "anonymous",
      identity: {displayName: "Guest", email: null, phoneE164: null,
        origin: "respondent"}, sourceLinkId: null,
      consentVersion: "v1", completionMillis: 10, answerSnapshots: [],
    };
  };
  // Forty-four full scan pages contain exactly 10,000 matching rows and
  // 1,000 nonmatches. The following sparse page proves whether there is a
  // further match after the apparent export boundary.
  for (let index = 0; index < 11_000; index++) {
    addResponse(index, index % 11 === 0 ? "withdrawn" : "submitted");
  }
  for (let index = 11_000; index < 11_017; index++) {
    addResponse(index, "withdrawn");
  }
  if (overflow) addResponse(11_017, "submitted");
  const store = new AudienceTestStore(docs);
  const saves: Array<{path: string; buffer: Buffer}> = [];
  const bucket = {file: (path: string) => ({save: async (buffer: Buffer) => {
    saves.push({path, buffer});
  }})} as unknown as ReturnType<ReturnType<typeof admin.storage>["bucket"]>;
  const deps = {firestore: () => store.asFirestore(),
    storageBucket: () => bucket, checkRateLimit: async () => undefined,
    timestamp: () => timestamp};
  return {store, saves, deps};
}

test("form export completes exactly 10,000 sparse matches", async () => {
  const {store, saves, deps} = exportFixture(false);
  await processOrganizerFormExport("export-1", deps);
  const receipt = store.docs["organizerFormExports/export-1"];
  assert.equal(receipt.status, "completed");
  assert.equal(receipt.rowCount, 10_000);
  assert.equal(saves.length, 1);
  assert.equal(saves[0].buffer.toString("utf8").split("\r\n").length,
    10_002);
});

test("form export rejects a partial 10,001-row file", async () => {
  const {store, saves, deps} = exportFixture(true);
  await assert.rejects(processOrganizerFormExport("export-1", deps),
    {code: "resource-exhausted"});
  const receipt = store.docs["organizerFormExports/export-1"];
  assert.equal(receipt.status, "failed");
  assert.equal(receipt.rowCount, 0);
  assert.equal(receipt.storagePath, null);
  assert.match(String(receipt.errorMessage), /10,000 responses/u);
  assert.equal(saves.length, 0);
});

test("form export rejects an exhausted scan budget before saving", async () => {
  const {store, saves, deps} = exportFixture(false);
  const withdrawn = store.docs["organizerFormResponses/response-11016"];
  for (let index = 11_017; index <= 50_000; index++) {
    store.docs[`organizerFormResponses/response-${index}`] = {
      ...withdrawn,
      submittedAt: admin.firestore.Timestamp.fromMillis(index + 1000),
    };
  }
  await assert.rejects(processOrganizerFormExport("export-1", deps),
    {code: "resource-exhausted"});
  const receipt = store.docs["organizerFormExports/export-1"];
  assert.equal(receipt.status, "failed");
  assert.match(String(receipt.errorMessage), /50,000 responses/u);
  assert.equal(saves.length, 0);
});

const typedQuery = {organizerId: "org-1", formId: "form-1",
  versionId: "version-1", statuses: ["submitted"],
  predicate: {questionId: "city", op: "choiceAny", values: ["Delhi"]},
  sort: {questionId: "score", direction: "desc", nulls: "last"},
  limit: 1, cursor: null};

async function typedFixture(format = "csv") {
  const h = exportFixture(false);
  for (const path of Object.keys(h.store.docs)) {
    if (path.startsWith("organizerFormResponses/")) delete h.store.docs[path];
  }
  h.store.docs["organizers/org-1"] = {ownerUserId: "host-1",
    hostUserIds: ["host-1"], hostProfiles: []};
  h.store.docs["organizerForms/form-1"] = {organizerId: "org-1",
    title: "Registrations"};
  h.store.docs["organizerFormVersions/version-1"] = {organizerId: "org-1",
    formId: "form-1", version: 1, definition: {sections: [{questions: [
      {questionId: "city", kind: "singleChoice", label: "City", options: [
        {value: "Delhi", label: "Delhi"},
        {value: "Mumbai", label: "Mumbai"}]},
      {questionId: "score", kind: "number", label: "Score", options: []},
      {questionId: "secret", kind: "shortText", label: "Secret",
        privacyClass: "sensitive", options: []},
    ]}]}};
  for (const [id, city, score] of [
    ["a", "Delhi", 1], ["b", "Mumbai", 9], ["c", "Delhi", 3],
  ] as const) {
    h.store.docs[`organizerFormResponses/${id}`] = {
      organizerId: "org-1", formId: "form-1", versionId: "version-1",
      status: "submitted", submittedAt: admin.firestore.Timestamp
        .fromMillis(1000), withdrawnAt: null, identityKind: "anonymous",
      identity: {displayName: "=unsafe", email: null, phoneE164: null,
        origin: "respondent", searchName: "unsafe"}, sourceLinkId: null,
      consentVersion: "v1", completionMillis: 10,
      answers: {city, score, secret: "do-not-export"}, answerSnapshots: [],
    };
  }
  const scope = {db: h.store.asFirestore(), actorUid: "host-1",
    organizerId: "org-1", formId: "form-1", versionId: "version-1"};
  const result = await runFirestoreResponseQuery(scope, typedQuery);
  h.store.docs["organizerFormExports/export-1"] = {
    ...h.store.docs["organizerFormExports/export-1"],
    versionId: "version-1", requestedByUid: "host-1", format,
    responseQuery: typedQuery, expectedResultHash: result.resultHash,
    expectedQueryHash: result.queryHash,
  };
  return {...h, result, scope};
}

test("typed CSV exports all sorted matches, not the visible page", async () => {
  const h = await typedFixture();
  assert.equal(h.result.items.length, 1);
  await processOrganizerFormExport("export-1", h.deps);
  const csv = h.saves[0].buffer.toString("utf8");
  const lines = csv.split("\r\n");
  assert.match(lines[1], /^"c",/u);
  assert.match(lines[2], /^"a",/u);
  assert.equal(lines.length, 4);
  assert.ok(csv.includes("'=unsafe"));
  assert.ok(!csv.includes("Mumbai"));
  assert.ok(!csv.includes("do-not-export"));
  assert.ok(!csv.includes("Secret"));
  assert.equal(h.store.docs["organizerFormExports/export-1"].rowCount, 2);
});

test("typed XLSX preserves rows and formula-safe cells", async () => {
  const h = await typedFixture("xlsx");
  await processOrganizerFormExport("export-1", h.deps);
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.load(h.saves[0].buffer as never);
  const sheet = workbook.worksheets[0];
  assert.equal(sheet.rowCount, 3);
  assert.equal(sheet.getCell(2, 1).value, "c");
  assert.equal(sheet.getCell(3, 1).value, "a");
  assert.equal(sheet.getCell(2, 9).value, "'=unsafe");
});

test("changed results fail before saving export", async () => {
  const h = await typedFixture();
  h.store.docs["organizerFormResponses/a"].status = "withdrawn";
  await assert.rejects(processOrganizerFormExport("export-1", h.deps),
    {code: "aborted", details: {reason: "response-query-stale",
      action: "refresh"}});
  assert.equal(h.saves.length, 0);
  assert.equal(h.store.docs["organizerFormExports/export-1"].status, "failed");
});

test("export rechecks manager and account authority", async () => {
  for (const deleted of [false, true]) {
    const h = await typedFixture();
    if (deleted) h.store.docs["deletedUsers/host-1"] = {status: "deleted"};
    else {
      h.store.docs["organizers/org-1"] = {ownerUserId: "other",
        hostUserIds: ["other"], hostProfiles: []};
    }
    await assert.rejects(processOrganizerFormExport("export-1", h.deps),
      {code: "permission-denied"});
    assert.equal(h.saves.length, 0);
  }
});

test("export rejects ambiguous scope and page cursor", async () => {
  const h = await typedFixture();
  const data = {organizerId: "org-1", formId: "form-1",
    requestId: "typed-export-request", format: "csv", statuses: ["submitted"],
    versionId: "version-1", fromMillis: null, toMillis: null,
    responseQuery: typedQuery, expectedResultHash: h.result.resultHash,
    expectedQueryHash: h.result.queryHash};
  const request = (value: unknown) => ({auth: {uid: "host-1"}, data: value}) as
    import("firebase-functions/v2/https").CallableRequest<unknown>;
  for (const patch of [{fromMillis: 1}, {versionId: null},
    {expectedResultHash: null}, {expectedQueryHash: null},
    {responseQuery: null},
    {responseQuery: {...typedQuery, cursor: h.result.nextCursor}},
    {responseQuery: {...typedQuery, predicate: {questionId: "secret",
      op: "textEquals", value: "do-not-export"}}}]) {
    await assert.rejects(requestOrganizerFormExportHandler(
      request({...data, ...patch}), h.deps), {code: "invalid-argument"});
  }
  const first = await requestOrganizerFormExportHandler(request(data), h.deps);
  const repeated = await requestOrganizerFormExportHandler(
    request({...data, responseQuery: {...typedQuery,
      sort: {nulls: "last", direction: "desc", questionId: "score"}}}), h.deps);
  assert.equal(first.exportId, repeated.exportId);
  const ascending = {...typedQuery, sort: {...typedQuery.sort,
    direction: "asc"}};
  const changed = await runFirestoreResponseQuery(h.scope, ascending);
  await assert.rejects(requestOrganizerFormExportHandler(request({...data,
    expectedQueryHash: changed.queryHash, responseQuery: ascending}), h.deps),
  {code: "already-exists"});
});

test("export binds published definition even if response values match",
  async () => {
    const h = await typedFixture();
    const version = h.store.docs["organizerFormVersions/version-1"];
    const definition = version.definition as {sections: Array<{
      questions: Array<{label: string}>}>};
    definition.sections[0].questions[0].label = "Changed city label";
    await assert.rejects(processOrganizerFormExport("export-1", h.deps),
      {code: "aborted"});
    assert.equal(h.saves.length, 0);
  });

test("withdrawn export keeps history without answers", async () => {
  const h = await typedFixture();
  h.store.docs["organizerFormResponses/a"].status = "withdrawn";
  const query = {...typedQuery, statuses: ["withdrawn"], predicate: null};
  const result = await runFirestoreResponseQuery(h.scope, query);
  Object.assign(h.store.docs["organizerFormExports/export-1"], {
    statuses: query.statuses, responseQuery: query,
    expectedResultHash: result.resultHash, expectedQueryHash: result.queryHash,
  });
  await processOrganizerFormExport("export-1", h.deps);
  const csv = h.saves[0].buffer.toString("utf8");
  assert.match(csv, /"withdrawn"/u);
  assert.ok(!csv.includes("Delhi"));
  assert.ok(!csv.includes("do-not-export"));
});

test("empty typed export retains authorized field headings", async () => {
  const h = await typedFixture();
  for (const id of ["a", "c"]) {
    h.store.docs[`organizerFormResponses/${id}`].status = "withdrawn";
  }
  const result = await runFirestoreResponseQuery(h.scope, typedQuery);
  h.store.docs["organizerFormExports/export-1"].expectedResultHash =
    result.resultHash;
  await processOrganizerFormExport("export-1", h.deps);
  const csv = h.saves[0].buffer.toString("utf8");
  assert.ok(csv.includes("Version 1: City"));
  assert.equal(h.store.docs["organizerFormExports/export-1"].rowCount, 0);
});

test("oversized typed export fails without a partial storage object",
  async () => {
    const h = await typedFixture();
    const row = h.store.docs["organizerFormResponses/b"];
    for (let index = 0; index < 4998; index++) {
      h.store.docs[`organizerFormResponses/more-${index}`] = {...row};
    }
    await assert.rejects(processOrganizerFormExport("export-1", h.deps),
      {code: "resource-exhausted"});
    assert.equal(h.saves.length, 0);
  });


test("export freshness includes consent and completion metadata", async () => {
  for (const change of [{consentVersion: "v2"}, {completionMillis: 99}]) {
    const h = await typedFixture();
    Object.assign(h.store.docs["organizerFormResponses/a"], change);
    await assert.rejects(processOrganizerFormExport("export-1", h.deps),
      {code: "aborted"});
    assert.equal(h.saves.length, 0);
  }
});

test("status replay exposes typed stale failure without another export",
  async () => {
    const h = await typedFixture();
    const data = {organizerId: "org-1", formId: "form-1",
      requestId: "stale-export-request", format: "csv",
      statuses: ["submitted"], versionId: "version-1",
      fromMillis: null, toMillis: null, responseQuery: typedQuery,
      expectedResultHash: h.result.resultHash,
      expectedQueryHash: h.result.queryHash};
    const request = {auth: {uid: "host-1"}, data} as
      import("firebase-functions/v2/https").CallableRequest<unknown>;
    const first = await requestOrganizerFormExportHandler(request, h.deps);
    h.store.docs["organizerFormResponses/a"].status = "withdrawn";
    await assert.rejects(processOrganizerFormExport(first.exportId, h.deps),
      {code: "aborted"});
    const status = await requestOrganizerFormExportHandler(request, h.deps);
    assert.equal(status.exportId, first.exportId);
    assert.equal(status.status, "failed");
    assert.equal(status.errorCode, "response-query-stale");
    assert.equal(status.downloadUrl, null);
    assert.equal(h.saves.length, 0);
  });


test("typed export shows attachment presence without private asset IDs",
  async () => {
    const h = await typedFixture();
    const version = h.store.docs["organizerFormVersions/version-1"];
    const definition = version.definition as {sections: Array<{
      questions: unknown[]}>};
    definition.sections[0].questions.push(
      {questionId: "photo", kind: "file", label: "Photo", options: []},
      {questionId: "signature", kind: "signature", label: "Signature",
        options: []});
    Object.assign(h.store.docs["organizerFormResponses/a"].answers as object,
      {photo: ["private-photo-id"], signature: "private-signature-id"});
    const result = await runFirestoreResponseQuery(h.scope, typedQuery);
    Object.assign(h.store.docs["organizerFormExports/export-1"], {
      expectedResultHash: result.resultHash,
      expectedQueryHash: result.queryHash,
    });
    await processOrganizerFormExport("export-1", h.deps);
    const csv = h.saves[0].buffer.toString("utf8");
    assert.ok(csv.includes("Attached"));
    assert.ok(!csv.includes("private-photo-id"));
    assert.ok(!csv.includes("private-signature-id"));
  });
