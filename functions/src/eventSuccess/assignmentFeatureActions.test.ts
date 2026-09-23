import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {AudienceTestStore} from
  "../organizers/organizerAudienceTestStore";
import {assignmentFeatureConsentId} from
  "./assignmentFeatureConsent";
import {configureEventAssignmentFeaturesHandler,
  setEventAssignmentFeatureConsentHandler} from
  "./assignmentFeatureActions";

const stamp = {_seconds: 1, _nanoseconds: 0};
const rule = {featureId: "feature-1", formId: "form-1",
  versionId: "version-1", questionId: "question-1",
  transformVersion: 1, kind: "category", mode: "preferSimilar",
  weight: 5, optionIds: ["option-1"]};

function fixture() {
  const store = new AudienceTestStore({
    "events/event-1": {organizerId: "org-1", clubId: "org-1",
      status: "active"},
    "organizers/org-1": {hostUserId: "host-1", hostUserIds: [],
      hostProfiles: []},
    "eventSuccessPlans/event-1": {eventId: "event-1", clubId: "org-1",
      status: "setup", structureConfig: {topology: "set"}},
    "organizerFormVersions/version-1": {organizerId: "org-1",
      formId: "form-1", publishedAt: stamp,
      definition: {sections: [{questions: [{questionId: "question-1",
        privacyClass: "organizerCustom", kind: "singleChoice",
        options: [{optionId: "option-1", value: "answer-1"}]}]}]}},
    "eventParticipations/event-1_user-1": {eventId: "event-1",
      uid: "user-1", status: "signedUp"},
    "organizerFormResponses/response-1": {organizerId: "org-1",
      formId: "form-1", versionId: "version-1", status: "submitted",
      respondentUid: "user-1", identityKind: "phoneVerified",
      identity: {phoneE164: "+919900001111"}, withdrawnAt: null,
      answers: {"question-1": "answer-1"}},
  });
  const docs = store.docs as Record<string,
    Record<string, unknown> | undefined>;
  const deps = {db: () => store.asFirestore(), now: () => stamp,
    rateLimit: async () => {}};
  return {store, docs, deps};
}

test("Host mapping does not grant use; verified owner can grant and revoke",
  async () => {
    const {docs, deps} = fixture();
    const host = {auth: {uid: "host-1"}, data: {eventId: "event-1",
      expectedRevision: 0, requestId: "config-1", rules: [rule]}};
    const configured = await configureEventAssignmentFeaturesHandler(
      host as never, deps as never);
    assert.equal(configured.revision, 1);
    assert.equal((await configureEventAssignmentFeaturesHandler(
      host as never, deps as never)).replayed, true);
    const consentPath = `eventAssignmentFeatureConsents/${
      assignmentFeatureConsentId("event-1", "user-1", "feature-1")}`;
    assert.equal(Object.hasOwn(docs, consentPath), false);

    const grant = {auth: {uid: "user-1",
      token: {phone_number: "+919900001111"}},
    data: {eventId: "event-1", featureId: "feature-1",
      responseId: "response-1", decision: "grant",
      expectedRevision: 0, requestId: "grant-1"}};
    const granted = await setEventAssignmentFeatureConsentHandler(
      grant as never, deps as never);
    assert.equal(granted.status, "granted");
    assert.equal((await setEventAssignmentFeatureConsentHandler(
      grant as never, deps as never)).replayed, true);
    assert.equal(docs[consentPath]?.purpose,
      "eventAssignmentMatching");

    const withdraw = {auth: {uid: "user-1", token: {}},
      data: {...grant.data, decision: "withdraw", expectedRevision: 1,
        requestId: "withdraw-1"}};
    const withdrawn = await setEventAssignmentFeatureConsentHandler(
      withdraw as never, deps as never);
    assert.equal(withdrawn.status, "withdrawn");
    assert.equal(docs[consentPath]?.status, "withdrawn");
  });

test("mismatched endpoint cannot grant matching answer use", async () => {
  const {docs, deps} = fixture();
  docs["eventSuccessPlans/event-1"]!.assignmentFeatureRules = [rule];
  const request = {auth: {uid: "user-1",
    token: {phone_number: "+919900002222"}},
  data: {eventId: "event-1", featureId: "feature-1",
    responseId: "response-1", decision: "grant",
    expectedRevision: 0, requestId: "grant-1"}};
  await assert.rejects(() => setEventAssignmentFeatureConsentHandler(
    request as never, deps as never), (error: unknown) =>
    error instanceof HttpsError && error.code === "permission-denied");
  assert.equal(docs[`eventAssignmentFeatureConsents/${
    assignmentFeatureConsentId("event-1", "user-1", "feature-1")}`],
  undefined);
});
