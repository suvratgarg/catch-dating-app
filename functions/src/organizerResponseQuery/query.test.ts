import assert from "node:assert/strict";
import test from "node:test";
import {compileResponseQuery, materializeResponseQuery,
  pageResponseQuery, resolveSelectedResponseIds,
  responseQueryFieldCatalog} from "./query";
import type {ResponseQueryRow} from "./query";

type Definition = Parameters<typeof compileResponseQuery>[1];
const definition = {sections: [{questions: [
  {questionId: "city", kind: "singleChoice", options: [
    {value: "Delhi"}, {value: "Mumbai"}]},
  {questionId: "interests", kind: "multiChoice", options: [
    {value: "Music"}, {value: "Food"}]},
  {questionId: "age", kind: "number", options: []},
  {questionId: "note", kind: "shortText", options: []},
  {questionId: "joined", kind: "date", options: []},
  {questionId: "agreed", kind: "boolean", options: []},
  {questionId: "proof", kind: "file", options: []},
  {questionId: "secret", kind: "shortText", privacyClass: "sensitive",
    options: []},
]}]} as unknown as Definition;

const base = {organizerId: "org-1", formId: "form-1",
  versionId: "version-1", statuses: ["submitted"], predicate: null,
  sort: {questionId: "age", direction: "asc", nulls: "last"},
  limit: 2, cursor: null};

function row(id: string, answers: ResponseQueryRow["answers"],
  status: ResponseQueryRow["status"] = "submitted"): ResponseQueryRow {
  return {id, organizerId: "org-1", formId: "form-1",
    versionId: "version-1", status, submittedAtMillis: 1000, answers};
}

test("ALL/ANY typed filters share exact page and selected IDs", async () => {
  const predicate = {all: [
    {questionId: "city", op: "choiceAny", values: ["Delhi"]},
    {any: [
      {questionId: "age", op: "numberBetween", minimum: 20, maximum: 30},
      {questionId: "note", op: "textContains", value: " ART "},
    ]},
  ]};
  const input = {...base, predicate};
  const query = compileResponseQuery(input, definition);
  const reordered = compileResponseQuery({...input, predicate: {all: [
    predicate.all[1], predicate.all[0]]}}, definition);
  assert.equal(query.hash, reordered.hash);
  const source = {readAll: async () => [
    row("c", {city: "Delhi", age: 25}),
    row("b", {city: "Delhi", age: 25}),
    row("a", {city: "Delhi", age: 50, note: "art show"}),
    row("z", {city: "Mumbai", age: 22}),
  ]};
  const result = await materializeResponseQuery(query, source);
  assert.deepEqual(result.selectedIds, ["b", "c", "a"]);
  const first = pageResponseQuery(query, result);
  assert.deepEqual(first.items.map((item) => item.id), ["b", "c"]);
  assert.equal(first.total, 3);
  assert.ok(first.nextCursor);
  assert.deepEqual(resolveSelectedResponseIds(query, result, ["b", "a"],
    result.resultHash), ["b", "a"]);
  assert.throws(() => resolveSelectedResponseIds(query, result,
    ["z"], result.resultHash), {code: "invalid-argument"});
  assert.throws(() => resolveSelectedResponseIds(query, result,
    ["b"], "stale"), {code: "invalid-argument"});
  const next = compileResponseQuery({...input, limit: 1,
    cursor: first.nextCursor}, definition);
  assert.equal(next.hash, query.hash, "page size does not change selection");
  assert.deepEqual(pageResponseQuery(next, result).items.map((item) =>
    item.id), ["a"]);
  const changed = compileResponseQuery({...input, predicate: {all: [
    {questionId: "city", op: "choiceAny", values: ["Mumbai"]}]},
  cursor: first.nextCursor}, definition);
  assert.throws(() => pageResponseQuery(changed, result),
    {code: "invalid-argument"});
  const stale = await materializeResponseQuery(query, {readAll: async () =>
    [...await source.readAll(), row("new", {city: "Delhi", age: 21})]});
  assert.throws(() => pageResponseQuery(next, stale),
    {code: "invalid-argument", message: /Refresh/u});
});

test("typed operators, missingness and withdrawn privacy", async () => {
  const rows = [row("one", {interests: ["Music", "Food"],
    joined: "2026-09-24", agreed: false, proof: ["asset"],
    secret: "submitted secret"}),
  row("two", {interests: ["Music"], joined: "2026-09-25",
    agreed: true}), row("withdrawn", {city: "Delhi",
    secret: "never expose me"}, "withdrawn")];
  const select = async (predicate: unknown, statuses = ["submitted"]) => {
    const query = compileResponseQuery({...base, statuses, predicate},
      definition);
    return (await materializeResponseQuery(query, {readAll: async () => rows}))
      .selectedIds;
  };
  assert.deepEqual(await select({questionId: "interests", op: "choiceAll",
    values: ["Food", "Music"]}), ["one"]);
  assert.deepEqual(await select({questionId: "interests", op: "choiceNone",
    values: ["Food"]}), ["two"]);
  assert.deepEqual(await select({questionId: "joined", op: "dateBefore",
    value: "2026-09-25"}), ["one"]);
  assert.deepEqual(await select({questionId: "agreed", op: "booleanIs",
    value: false}), ["one"]);
  assert.deepEqual(await select({questionId: "proof", op: "present"}),
    ["one"]);
  assert.deepEqual(await select({questionId: "city", op: "missing"},
    ["withdrawn"]), []);
  assert.deepEqual(await select({questionId: "city", op: "choiceAny",
    values: ["Delhi"]}, ["withdrawn"]), []);
  const historyQuery = compileResponseQuery({...base,
    statuses: ["withdrawn"]}, definition);
  const history = await materializeResponseQuery(historyQuery,
    {readAll: async () => rows});
  assert.deepEqual(history.selectedIds, ["withdrawn"]);
  assert.deepEqual(history.rows[0].answers, {});
  assert.ok(!JSON.stringify(history).includes("never expose me"));
  assert.ok(!JSON.stringify(await materializeResponseQuery(
    compileResponseQuery(base, definition), {readAll: async () => rows}))
    .includes("submitted secret"));
  assert.ok(!responseQueryFieldCatalog(definition).some((field) =>
    field.questionId === "secret"));
});

test("answer sort is stable across nulls, zero and both directions",
  async () => {
    const rows = [row("null", {}), row("zero", {age: 0}),
      row("same-b", {age: 20}), row("same-a", {age: 20})];
    for (const direction of ["asc", "desc"]) {
      const query = compileResponseQuery({...base,
        sort: {questionId: "age", direction, nulls: "first"}}, definition);
      const result = await materializeResponseQuery(query,
        {readAll: async () => rows});
      const expected = direction === "asc" ?
        ["null", "zero", "same-a", "same-b"] :
        ["null", "same-a", "same-b", "zero"];
      assert.deepEqual(result.selectedIds, expected);
      const first = pageResponseQuery(query, result);
      const second = pageResponseQuery(compileResponseQuery({...base,
        sort: {questionId: "age", direction, nulls: "first"},
        cursor: first.nextCursor}, definition), result);
      assert.deepEqual([...first.items, ...second.items].map((item) =>
        item.id), expected);
    }
  });

test("invalid fields, types and scan budget fail closed", async () => {
  for (const predicate of [
    {questionId: "unknown", op: "present"},
    {questionId: "proof", op: "textContains", value: "asset"},
    {questionId: "city", op: "choiceAny", values: ["Dubai"]},
    {questionId: "joined", op: "dateOn", value: "2026-02-30"},
    {questionId: "age", op: "numberBetween", minimum: 30, maximum: 20},
    {all: [{all: [{all: [{questionId: "age", op: "present"}]}]}]},
    {any: Array.from({length: 21}, () =>
      ({questionId: "age", op: "present"}))},
    {questionId: "age", op: "numberEq", value: 20, secret: true},
    {questionId: "secret", op: "present"},
  ]) {
    assert.throws(() => compileResponseQuery({...base, predicate},
      definition), {code: "invalid-argument"});
  }
  const query = compileResponseQuery(base, definition);
  assert.throws(() => compileResponseQuery({...base,
    sort: {...base.sort, questionId: "secret"}}, definition),
  {code: "invalid-argument"});
  await assert.rejects(materializeResponseQuery(query, {readAll: async (
    maxRows) => Array.from({length: maxRows + 1}, (_, index) =>
    row(String(index), {}))}), {code: "resource-exhausted"});
  await assert.rejects(materializeResponseQuery(query, {readAll: async () =>
    [{...row("foreign", {}), organizerId: "org-2"}]}),
  {code: "permission-denied"});
  await assert.rejects(materializeResponseQuery(query, {readAll: async () =>
    [row("large", {note: "x".repeat(8 * 1024 * 1024)})]}),
  {code: "resource-exhausted", message: /8 MiB/u});
});
