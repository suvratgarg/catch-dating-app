import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {assignedSalesAccountIds, assertSalesStaffAccount,
  assertSalesStaffScope, isAssignedSalesStaff} from "./staffAccess";
import type {SalesPrincipal} from "./types";

const staff: SalesPrincipal = {uid: "staff-1", roles: ["salesStaff"],
  organizerIds: ["org-1"]};
const denied = (error: unknown) =>
  error instanceof HttpsError && error.code === "permission-denied";

function fixture() {
  let account: Record<string, unknown> | undefined = {schemaVersion: 1,
    classification: "sales_private", organizerId: "org-1",
    assignedOwnerUid: "staff-1"};
  const ref = {get: async () => ({data: () => account})};
  const db = {collection: () => ({doc: () => ref})} as
    unknown as FirebaseFirestore.Firestore;
  return {db, replace: (value?: Record<string, unknown>) => {
    account = value;
  }};
}

test("staff assignment uses private canonical transaction reads", async () => {
  const {db, replace} = fixture();
  let reads = 0;
  const tx = {get: async (ref: {get: () => Promise<unknown>}) => {
    reads++; return ref.get();
  }} as unknown as FirebaseFirestore.Transaction;
  await assertSalesStaffAccount(db, staff, "org-1", tx);
  assert.equal(reads, 1);
  await assert.rejects(assertSalesStaffAccount(db, staff, "other", tx), denied);
  assert.equal(reads, 1);
  for (const account of [undefined,
    {classification: "sales_private", organizerId: "org-1",
      assignedOwnerUid: "other"},
    {classification: "public", organizerId: "org-1",
      assignedOwnerUid: "staff-1"},
    {classification: "sales_private", organizerId: "other",
      assignedOwnerUid: "staff-1"}]) {
    replace(account);
    await assert.rejects(
      assertSalesStaffAccount(db, staff, "org-1", tx), denied);
  }
});

test("staff scope is bounded and empty scope is safe", async () => {
  const {db} = fixture();
  await assertSalesStaffScope(db, {...staff, organizerIds: []});
  await assert.rejects(assertSalesStaffScope(db,
    {...staff, organizerIds: undefined}), denied);
  await assert.rejects(assertSalesStaffScope(db,
    {...staff, organizerIds: Array.from({length: 31},
      (_, index) => `org-${index}`)}), denied);
  assert.equal(isAssignedSalesStaff(
    {...staff, roles: ["salesStaff", "support"]}), true);
  assert.equal(isAssignedSalesStaff(
    {...staff, roles: ["salesStaff", "adminOwner"]}), false);
  await assertSalesStaffAccount(db,
    {uid: "owner", roles: ["adminOwner"]}, "other");
});

test("assignment lookup is server-owned, bounded and ordered", async () => {
  let count = 2;
  const db = {collection: (name: string) => {
    assert.equal(name, "organizerSalesAccounts");
    return {where: (field: string, op: string, uid: string) => {
      assert.deepEqual([field, op, uid],
        ["assignedOwnerUid", "==", "staff-1"]);
      return {limit: (limit: number) => {
        assert.equal(limit, 31);
        return {get: async () => ({size: count, docs: [{id: "z"}, {id: "a"}]})};
      }};
    }};
  }} as unknown as FirebaseFirestore.Firestore;
  assert.deepEqual(await assignedSalesAccountIds(db, "staff-1"), ["a", "z"]);
  count = 31;
  await assert.rejects(assignedSalesAccountIds(db, "staff-1"),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "resource-exhausted");
});
