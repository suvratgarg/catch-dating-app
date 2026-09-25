import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {OrganizerFormVersionDocument, ParticipantIntakeProfileDocument}
  from "../shared/generated/firestoreAdminTypes";
import {canonicalCityMarketId, publicFormCityOptions,
  publicFormPrefillSuggestions, reusablePublicFormFields} from
  "./organizerFormPublicFields";

type Definition = OrganizerFormVersionDocument["definition"];
const catchQuestion = (id: string, canonicalFieldId: string,
  kind = "shortText") => ({questionId: id, canonicalFieldId, kind,
  answerDestination: "catchProfile", prefillPolicy: "participantReviewRequired",
  options: []});
const definition = {sections: [{questions: [
  catchQuestion("name", "displayName"),
  catchQuestion("city", "city"),
  catchQuestion("phone", "phoneNumber", "phone"),
  {questionId: "organizerSecret", canonicalFieldId: null,
    answerDestination: "organizerOnly", prefillPolicy: "never",
    kind: "shortText", options: []},
]}]} as unknown as Definition;

test("public form cities come from canonical Indian markets", () => {
  const options = publicFormCityOptions();
  assert.ok(options.some((city) => city.marketId === "in-mh-mumbai" &&
    city.cityId === "in-mh-mumbai" && city.label === "Mumbai"));
  assert.ok(options.every((city) => city.countryIsoCode === "IN"));
  assert.equal(canonicalCityMarketId("Mumbai"), "in-mh-mumbai");
  assert.equal(canonicalCityMarketId("unknown"), null);
});

test("verified respondent sees only reusable Catch fields", () => {
  const now = Timestamp.fromMillis(1000);
  const intake: ParticipantIntakeProfileDocument = {revision: 1,
    createdAt: now, updatedAt: now, fields: [{canonicalFieldId: "city", value: {
      valueKind: "text", textValue: "in-mh-mumbai", numberValue: null,
      booleanValue: null, dateValue: null, optionValues: [], assetIds: [],
    }, sourceApplicationId: null, reviewedByParticipantAt: now,
    updatedAt: now}]};
  assert.deepEqual(publicFormPrefillSuggestions({definition, intake,
    verifiedPhone: "+919999999999"}), {
    city: "in-mh-mumbai", phone: "+919999999999",
  });
});

test("submission saves only reviewed Catch fields into private intake", () => {
  const now = Timestamp.fromMillis(1000);
  const fields = reusablePublicFormFields(definition, {
    name: "Ada", city: "in-mh-mumbai", phone: "+919999999999",
    organizerSecret: "Only this organizer may see this",
  }, now);
  assert.deepEqual(fields.map((field) => field.canonicalFieldId),
    ["displayName", "city", "phoneNumber"]);
  assert.equal(fields.find((field) => field.canonicalFieldId === "city")?.value
    .textValue, "in-mh-mumbai");
  assert.ok(fields.every((field) => field.sourceApplicationId === null));
});
