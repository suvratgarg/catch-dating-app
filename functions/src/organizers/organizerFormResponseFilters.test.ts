import assert from "node:assert/strict";
import test from "node:test";
import type {OrganizerFormResponseDocument, OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";
import {matchesAnswerFilters, responseFilterOptions, validateResponseFilters}
  from "./organizerFormResponseFilters";

type Definition = OrganizerFormVersionDocument["definition"];
function definition() {
  return {sections: [{questions: [
    {questionId: "city", label: "Which city?", kind: "singleChoice",
      hostPresentation: "filterable", options: [
        {value: "Mumbai", label: "Mumbai"},
        {value: "Dubai", label: "Dubai"}]},
    {questionId: "interests", label: "Interests", kind: "multiChoice",
      hostPresentation: "filterable", options: [
        {value: "sport", label: "Sport"}, {value: "art", label: "Art"}]},
    {questionId: "private", label: "Private note", kind: "shortText",
      hostPresentation: "detailOnly", options: []},
    {questionId: "sensitive", label: "Sensitive choice",
      kind: "singleChoice", privacyClass: "sensitive",
      hostPresentation: "filterable", options: [
        {value: "yes", label: "Yes"}]},
    {questionId: "sortOnly", label: "Sort-only choice",
      kind: "singleChoice", privacyClass: "organizerCustom",
      hostPresentation: "sortable", options: [
        {value: "yes", label: "Yes"}]},
  ]}]} as Definition;
}
function response(status: "submitted" | "withdrawn" = "submitted") {
  return {status, answerSnapshots: [
    {questionId: "city", label: "Old city label", answer: "Mumbai"},
    {questionId: "interests", answer: ["sport", "art"]},
    {questionId: "private", answer: "Mumbai"},
  ]} as OrganizerFormResponseDocument;
}

test("filters use stable ids, AND questions and OR selected values", () => {
  const def = definition();
  assert.equal(matchesAnswerFilters(response(), def, [
    {questionId: "city", values: ["Dubai", "Mumbai"]},
    {questionId: "interests", values: ["art"]},
  ]), true);
  assert.equal(matchesAnswerFilters(response(), def, [
    {questionId: "city", values: ["Dubai"]},
    {questionId: "interests", values: ["art"]},
  ]), false);
});

test("withdrawn, missing and detail-only answers never satisfy filters", () => {
  const def = definition();
  assert.equal(matchesAnswerFilters(response("withdrawn"), def,
    [{questionId: "city", values: ["Mumbai"]}]), false);
  assert.equal(matchesAnswerFilters(response(), def,
    [{questionId: "private", values: ["Mumbai"]}]), false);
  const incomplete = response();
  incomplete.answerSnapshots = [];
  assert.equal(matchesAnswerFilters(incomplete, def,
    [{questionId: "city", values: ["Mumbai"]}]), false);
  assert.equal(matchesAnswerFilters(response("withdrawn"), def, []), true);
});

test("filter eligibility follows each immutable response version", () => {
  const oldVersion = definition();
  oldVersion.sections[0].questions[0].hostPresentation = "detailOnly";
  assert.equal(matchesAnswerFilters(response(), oldVersion,
    [{questionId: "city", values: ["Mumbai"]}]), false);
});

test("only published categorical options can be queried", () => {
  const options = responseFilterOptions(definition());
  assert.deepEqual(options.map((item) => item.questionId),
    ["city", "interests"]);
  assert.doesNotThrow(() => validateResponseFilters(
    [{questionId: "city", values: ["Mumbai"]}], options));
  for (const filters of [
    [{questionId: "city", values: ["unknown"]}],
    [{questionId: "private", values: ["Mumbai"]}],
    [{questionId: "sensitive", values: ["yes"]}],
    [{questionId: "sortOnly", values: ["yes"]}],
    [{questionId: "city", values: ["Mumbai"]},
      {questionId: "city", values: ["Dubai"]}],
  ]) {
    assert.throws(() => validateResponseFilters(filters, options),
      {code: "invalid-argument"});
  }
});
