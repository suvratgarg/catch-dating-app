import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest} from "firebase-functions/v2/https";
import {AudienceTestStore} from
  "../organizers/organizerAudienceTestStore";
import {queryOrganizerFormResponsesHandler,
  resolveOrganizerResponseSelectionHandler} from "./callable";

const query = {organizerId: "org-1", formId: "form-1",
  versionId: "version-1", statuses: ["submitted"], predicate: null,
  sort: {questionId: null, direction: "asc", nulls: "last"},
  limit: 1, cursor: null};

function fixture() {
  const store = new AudienceTestStore({
    "organizers/org-1": {ownerUserId: "host-1", hostUserIds: ["host-1"],
      hostProfiles: []},
    "organizerForms/form-1": {organizerId: "org-1", title: "Signup"},
    "organizerFormVersions/version-1": {organizerId: "org-1",
      formId: "form-1", version: 1, definition: {sections: [{questions: [
        {questionId: "city", kind: "singleChoice", label: "City",
          options: [{value: "Delhi", label: "Delhi"}]},
      ]}]}},
    "organizerFormResponses/one": {organizerId: "org-1", formId: "form-1",
      versionId: "version-1", status: "submitted",
      submittedAt: admin.firestore.Timestamp.fromMillis(1000),
      withdrawnAt: null, identityKind: "anonymous",
      identity: {displayName: "Guest", email: null, phoneE164: null,
        searchName: "guest", origin: "anonymous"}, sourceLinkId: null,
      answers: {city: "Delhi"}},
  });
  const calls: Array<{principal: string; action: string;
    maxRequests: number}> = [];
  const deps = {firestore: () => store.asFirestore(),
    checkRateLimit: async (_db: unknown, principal: string, action: string,
      config?: {maxRequests: number}) => {
      calls.push({principal, action, maxRequests: config?.maxRequests ?? 0});
    }};
  return {store, deps, calls};
}

function request(data: unknown, uid: string | null = "host-1") {
  return {data, auth: uid ? {uid} : undefined} as
    CallableRequest<unknown>;
}

test("callable page matches Host gateway DTO and selection rechecks result",
  async () => {
    const {store, deps, calls} = fixture();
    const page = await queryOrganizerFormResponsesHandler(
      request(query), deps);
    assert.equal(page.form.title, "Signup");
    assert.deepEqual(page.items.map((item) => item.responseId), ["one"]);
    assert.deepEqual(page.selectedIds, ["one"]);
    assert.equal(page.items[0].identity.displayName, "Guest");
    assert.equal(page.items[0].formTitle, "Signup");
    assert.equal(JSON.stringify(page).includes("answers"), false);
    assert.deepEqual(calls, [
      {principal: "host-1", action: "queryOrganizerFormResponses",
        maxRequests: 12},
      {principal: "org-1", action: "queryOrganizerFormResponsesOrg",
        maxRequests: 60},
    ]);
    const selection = {query, requestedIds: ["one"],
      expectedResultHash: page.resultHash};
    assert.deepEqual(await resolveOrganizerResponseSelectionHandler(
      request(selection), deps), {responseIds: ["one"],
      resultHash: page.resultHash});
    store.docs["organizerFormResponses/one"] = {
      ...store.docs["organizerFormResponses/one"],
      status: "withdrawn",
      withdrawnAt: admin.firestore.Timestamp.fromMillis(2000)};
    await assert.rejects(resolveOrganizerResponseSelectionHandler(
      request(selection), deps), {code: "aborted", details: {
      reason: "response-query-stale", action: "refresh"}});
  });

test("callable denies unauthenticated, deleted and revoked managers",
  async () => {
    const {store, deps, calls} = fixture();
    await assert.rejects(queryOrganizerFormResponsesHandler(
      request(query, null), deps), {code: "unauthenticated"});
    assert.equal(calls.length, 0);
    store.docs["deletedUsers/host-1"] = {status: "processing"};
    await assert.rejects(queryOrganizerFormResponsesHandler(
      request(query), deps), {code: "permission-denied"});
    assert.equal(calls.at(-1)?.action, "queryOrganizerFormResponses",
      "deleted actor cannot spend organizer budget");
    delete store.docs["deletedUsers/host-1"];
    store.docs["organizers/org-1"] = {ownerUserId: "someone-else",
      hostUserIds: [], hostProfiles: []};
    await assert.rejects(queryOrganizerFormResponsesHandler(
      request(query), deps), {code: "permission-denied"});
    assert.equal(calls.at(-1)?.action, "queryOrganizerFormResponses",
      "outsider cannot spend organizer budget");
  });

test("selection preflight rejects malformed intents before scanning",
  async () => {
    const {deps, calls} = fixture();
    await assert.rejects(resolveOrganizerResponseSelectionHandler(
      request({query, requestedIds: ["one"], expectedResultHash: "bad"}),
      deps), {code: "invalid-argument"});
    await assert.rejects(resolveOrganizerResponseSelectionHandler(
      request({query, requestedIds: Array(5_001).fill("one"),
        expectedResultHash: "a".repeat(64)}), deps),
    {code: "invalid-argument"});
    assert.deepEqual(calls, []);
  });
