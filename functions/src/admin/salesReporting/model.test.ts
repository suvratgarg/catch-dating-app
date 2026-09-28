/* eslint-disable max-len */
import assert from "node:assert/strict";
import test from "node:test";
import {summarizeFunnel, validateInput, type ReportRow} from "./model";
import {getSalesFunnel, type FunnelDeps} from "./service";
const now = "2026-09-28T10:00:00.000Z";
const since = "2026-09-21T10:00:00.000Z";
const row = (id: string, data: Record<string, unknown>): ReportRow =>
  ({id, data: {classification: "sales_private", ...data}});
const accounts = ["a", "b", "c"].map((id) => row(id,
  {organizerId: id, researchStatus: "qualified", suppressionStatus: "clear"}));
const opportunity = (id: string, organizerId: string, stage: string) =>
  row(id, {opportunityId: id, organizerId, stage, nextStep: "Follow up", nextStepAt: since});
test("distinct hosts differ from opportunity totals and repeated movements", () => {
  const result = summarizeFunnel({since}, now, accounts,
    [opportunity("one", "a", "contacted"), opportunity("two", "a", "contacted"),
      opportunity("three", "a", "closed_lost"), opportunity("four", "b", "new_enquiry")],
    [], [row("h1", {organizerId: "a", toStage: "contacted", changedAt: since}),
      row("h2", {organizerId: "a", toStage: "contacted", changedAt: now})]);
  assert.equal(result.activeHosts, 3);
  assert.equal(result.opportunities, 4);
  assert.equal(result.hostsWithOpportunities, 2);
  assert.deepEqual(result.stages.find((item) => item.stage === "contacted"),
    {stage: "contacted", opportunities: 2, distinctHosts: 1,
      enteredInWindow: 2, distinctHostsEntered: 1});
  assert.equal(result.overdueOpportunities, 3);
  assert.equal(result.revenueStatus, "not_calculated");
});
test("restrictions exclude records; held hosts retain service commitments", () => {
  const result = summarizeFunnel({since}, now,
    [row("a", {...accounts[0].data, suppressionStatus: "suppressed"}),
      row("b", {...accounts[1].data, researchStatus: "archived"}), accounts[2]],
    [opportunity("one", "a", "contacted"), opportunity("two", "b", "closed_won"),
      opportunity("three", "c", "closed_won")],
    [row("t1", {organizerId: "a", status: "open", kind: "service_commitment", dueAt: since}),
      row("t2", {organizerId: "c", status: "open", kind: "reply", dueAt: since})],
    [], new Set(["c"]));
  assert.equal(result.activeHosts, 1);
  assert.equal(result.excludedArchivedOrRestrictedHosts, 2);
  assert.equal(result.opportunities, 1);
  assert.equal(result.heldHosts, 1);
  assert.equal(result.openObligations, 1);
  assert.equal(result.overdueObligations, 1);
});
test("missing steps differ from overdue, and malformed or unbounded dates fail", () => {
  const result = summarizeFunnel({since}, now, accounts,
    [row("one", {opportunityId: "one", organizerId: "a", stage: "new_enquiry"})], [], []);
  assert.equal(result.opportunitiesMissingNextStep, 1);
  assert.equal(result.overdueOpportunities, 0);
  for (const value of [{}, {since: "2026-01-01T00:00:00.000Z"},
    {since: "2027-01-01T00:00:00.000Z"}, {since, extra: true}]) {
    assert.throws(() => validateInput(value, now), /reporting start/u);
  }
});
function fakeDeps(overflow = false) {
  const calls: string[] = [];
  const query = (name: string) => ({where: () => query(name),
    limit: (limit: number) => ({name, limit})});
  const deps = {now: () => new Date(now), authorize: async () => {
    calls.push("auth");
  },
  db: {collection: query, runTransaction: async (fn: (tx: unknown) => unknown,
    options: unknown) => {
    assert.deepEqual(options, {readOnly: true});
    return fn({get: async ({name, limit}: {name: string; limit: number}) => {
      calls.push(name);
      const records = name === "organizerSalesAccounts" ? accounts : [];
      return {size: overflow ? limit : records.length,
        docs: records.map((record) => ({id: record.id, data: () => record.data}))};
    }});
  }}} as unknown as FunnelDeps;
  return {deps, calls};
}
test("consistent complete snapshot and fresh authority before returning", async () => {
  const {deps, calls} = fakeDeps();
  const report = await getSalesFunnel(deps, {uid: "employee", roles: ["admin"]}, {since});
  assert.equal(report.activeHosts, 3);
  assert.equal(calls[0], "auth");
  assert.equal(calls.at(-1), "auth");
  assert.equal(calls.filter((item) => item === "auth").length, 2);
});
test("overflow, delegated scope and revoked employee fail without partial totals", async () => {
  const {deps} = fakeDeps(true);
  await assert.rejects(getSalesFunnel(deps, {uid: "employee", roles: ["admin"]}, {since}),
    /No partial company totals/u);
  await assert.rejects(getSalesFunnel(deps,
    {uid: "employee", roles: ["admin"], clientId: "assistant"}, {since}), /employee session/u);
  const fresh = fakeDeps(); let count = 0;
  fresh.deps.authorize = async () => {
    if (++count === 2) throw new Error("Role revoked");
  };
  await assert.rejects(getSalesFunnel(fresh.deps,
    {uid: "employee", roles: ["admin"]}, {since}), /Role revoked/u);
});
