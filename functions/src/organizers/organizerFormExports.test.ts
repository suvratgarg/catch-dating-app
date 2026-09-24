import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {processOrganizerFormExport} from "./organizerFormExports";
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
