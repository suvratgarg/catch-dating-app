import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {OrganizerSavedAudienceDocument} from
  "../shared/generated/firestoreAdminTypes";
import {AudienceTestStore} from "./organizerAudienceTestStore";
import {genericFormApplicationId} from "./organizerApplicationAccess";
import {assertSavedAudienceSources, savedAudienceFilterOptions,
  savedAudienceSourceMatches} from "./organizerSavedAudienceSources";
import {savedAudienceDefinitionMatches, SavedAudienceEvaluationRow} from
  "./organizerSavedAudiences";

type Definition = OrganizerSavedAudienceDocument["definition"];
type Predicate = Definition["predicates"][number];
const answer: Predicate = {kind: "formAnswer", formId: "form-1",
  versionId: "v1", questionId: "drink", value: "tea"};
const attendance: Predicate = {kind: "attendedEvent", eventId: "event-1"};
const definition = (...predicates: Predicate[]) =>
  ({join: "all" as const, predicates});

function store() {
  return new AudienceTestStore({
    "organizerForms/form-1": {organizerId: "org-1", title: "New draft name"},
    "organizerFormVersions/v1": {organizerId: "org-1", formId: "form-1",
      version: 1, definition: {title: "Published application", sections: [{
        questions: [{questionId: "drink", label: "Drink", kind: "multiChoice",
          hostPresentation: "filterable", privacyClass: "organizerCustom",
          options: [{label: "Tea", value: "tea"}, {label: "Coffee",
            value: "coffee"}]},
        {questionId: "member", label: "Member", kind: "boolean",
          hostPresentation: "filterable", privacyClass: "organizerCustom",
          options: []},
        {questionId: "private", label: "Private", kind: "singleChoice",
          hostPresentation: "filterable", privacyClass: "sensitive",
          options: []},
        {questionId: "detail", label: "Detail only", kind: "singleChoice",
          hostPresentation: "detailOnly", privacyClass: "organizerCustom",
          options: []}],
      }]}},
    "organizerFormResponses/r1": {organizerId: "org-1", formId: "form-1",
      versionId: "v1", status: "submitted", respondentUid: null,
      answers: {drink: ["tea", "coffee"], member: false}},
    "organizerContactOrigins/origin-1": {organizerId: "org-1",
      sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
      sourceEntityId: "r1", currentContactId: "survivor",
      originContactId: "alias"},
    "events/event-1": {organizerId: "org-1", name: "Sunday social"},
    "organizerContactEventEdges/edge-1": {organizerId: "org-1",
      eventId: "event-1", contactId: "survivor", checkedIn: true,
      cancelled: false},
    "organizerContactEventEdges/edge-2": {organizerId: "org-1",
      eventId: "event-1", contactId: "registered", checkedIn: false,
      cancelled: false},
  });
}

test("choice, false boolean and event filters use current organizer facts",
  async () => {
    const db = store();
    const boolean: Predicate = {...answer, questionId: "member", value: false};
    const matches = await savedAudienceSourceMatches(db.asFirestore(), "org-1",
      definition(answer, boolean, attendance));
    for (const ids of matches.values()) {
      assert.deepEqual([...ids], ["survivor"]);
    }
    const row = {contactId: "survivor", contact: {manualTagIds: []},
      sourcePredicateKeys: new Set(matches.keys()),
    } as unknown as SavedAudienceEvaluationRow;
    const missing: Predicate = {kind: "manualTag", manualTagId: "missing"};
    assert.equal(savedAudienceDefinitionMatches(row,
      definition(answer, missing),
      Timestamp.now()), false);
    assert.equal(savedAudienceDefinitionMatches(row, {join: "any",
      predicates: [answer, missing]}, Timestamp.now()), true);
  });

test("withdrawn, wrong-version and foreign responses never target a " +
  "customer", async () => {
  for (const change of [{status: "withdrawn"}, {versionId: "v2"},
    {organizerId: "other"}]) {
    const db = store();
    Object.assign(db.docs["organizerFormResponses/r1"], change);
    const matches = await savedAudienceSourceMatches(db.asFirestore(), "org-1",
      definition(answer));
    assert.deepEqual([...matches.get(JSON.stringify(answer))!], []);
  }
});

test("private questions, invented values and foreign source references fail",
  async () => {
    const db = store();
    for (const predicate of [{...answer, questionId: "private"},
      {...answer, questionId: "detail"}, {...answer, value: "invented"},
      {...answer, formId: "other"}, {...attendance, eventId: "other"}]) {
      await assert.rejects(assertSavedAudienceSources(db.asFirestore(), "org-1",
        definition(predicate)), /unavailable|published version/);
    }
    db.docs["organizerFormVersions/v1"].organizerId = "other";
    await assert.rejects(assertSavedAudienceSources(db.asFirestore(), "org-1",
      definition(answer)), {code: "failed-precondition"});
  });

test("application status uses approved source evidence and follows " +
  "merged origins", async () => {
  const db = store();
  const applicationId = genericFormApplicationId("r1");
  const source = {kind: "native", externalResponseId: "r1"};
  db.docs[`organizerApplications/${applicationId}`] = {
    organizerId: "org-1", formId: "form-1", formVersionId: "v1",
    latestResponseId: "r1", reviewStatus: "approved", contactId: "alias",
    linkedUid: null, source,
  };
  db.docs["organizerApplicationResponses/r1"] = {
    organizerId: "org-1", applicationId, formId: "form-1", formVersionId: "v1",
    linkedUid: null, source, answers: [],
  };
  const predicate: Predicate = {kind: "applicationStatus", formId: "form-1",
    reviewStatus: "approved"};
  const run = () => savedAudienceSourceMatches(db.asFirestore(), "org-1",
    definition(predicate));
  assert.deepEqual([...((await run()).get(JSON.stringify(predicate))!)],
    ["survivor"]);
  db.docs["organizerFormResponses/r1"].status = "withdrawn";
  assert.equal((await run()).get(JSON.stringify(predicate))!.size, 0);
});

test("authoring exposes immutable version choices and excludes private " +
  "questions", async () => {
  const options = await savedAudienceFilterOptions(store().asFirestore(),
    "org-1");
  assert.equal(options.questions.length, 2);
  assert.equal(options.questions[0].formTitle, "Published application");
  assert.equal(options.questions[0].versionId, "v1");
  assert.deepEqual(options.events, [{eventId: "event-1",
    title: "Sunday social"}]);
});

test("over-limit evidence fails instead of returning an incomplete " +
  "match set", async () => {
  const db = store();
  for (let i = 0; i < 5001; i++) {
    db.docs[`organizerContactEventEdges/overflow-${i}`] = {
      organizerId: "org-1", eventId: "event-1", contactId: `p-${i}`,
      checkedIn: true, cancelled: false,
    };
  }
  await assert.rejects(savedAudienceSourceMatches(db.asFirestore(), "org-1",
    definition(attendance)), {code: "resource-exhausted"});
});
