/* eslint-disable max-len */
import {strict as assert} from "node:assert";
import {test} from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {inventorySalesOrganizer, type InventoryPort,
  type InventoryRow} from "./inventory";

function memory(rows: InventoryRow[]): InventoryPort {
  const data = new Map(rows.map((row) => [row.path, row]));
  return {
    get: async (path) => data.get(path) ?? null,
    scan: async (collection, organizerId) => [...data.values()].filter((row) =>
      row.path.split("/").length === 2 && row.path.startsWith(`${collection}/`) &&
      (!organizerId || row.data.organizerId === organizerId)),
    scanChild: async (parent, child) => [...data.values()].filter((row) =>
      row.path.startsWith(`${parent}/${child}/`) &&
      row.path.split("/").length === 4),
  };
}
const privateRow = (path: string, data: Record<string, unknown>): InventoryRow =>
  ({path, data: {schemaVersion: 1, classification: "sales_private", ...data}});

test("inventory deletes only the target relationship and preserves a shared contact", async () => {
  const port = memory([
    privateRow("organizerSalesAccounts/org-a", {organizerId: "org-a"}),
    privateRow("organizerSalesAccounts/org-a/customValues/sales.rank",
      {organizerId: "org-a", value: "lead"}),
    privateRow("salesContactRelationships/rel-a", {organizerId: "org-a",
      contactId: "contact-1"}),
    privateRow("salesContactRelationships/rel-b", {organizerId: "org-b",
      contactId: "contact-1"}),
    privateRow("salesContacts/contact-1", {contactId: "contact-1",
      displayName: "Shared Person"}),
  ]);
  const result = await inventorySalesOrganizer(port, "org-a");
  assert.deepEqual(result.items.map((item) => item.path), [
    "organizerSalesAccounts/org-a",
    "organizerSalesAccounts/org-a/customValues/sales.rank",
    "salesContactRelationships/rel-a",
  ]);
  assert.equal(result.items.some((item) => item.path ===
    "salesContacts/contact-1"), false);
  assert.equal(result.counts.unresolved >= 3, true);
  assert.equal((await inventorySalesOrganizer(port, "org-a")).inventoryHash,
    result.inventoryHash);
});

test("inventory includes nested import originals but quarantines mixed jobs and receipts", async () => {
  const port = memory([
    privateRow("salesImportRows/line-a", {organizerId: "org-a",
      originalCells: [{column: "notes", value: "private"}]}),
    privateRow("salesImportJobs/job-one", {accountEffects: [
      {organizerId: "org-a"}], importId: "job-one"}),
    privateRow("salesImportJobs/job-one/rows/001", {organizerId: "org-a",
      originalCells: [{column: "notes", value: "private"}]}),
    privateRow("salesImportJobs/job-mixed", {accountEffects: [
      {organizerId: "org-a"}, {organizerId: "org-b"}]}),
    privateRow("salesActionReceipts/receipt-mixed", {organizerId: null,
      result: {rows: [{organizerId: "org-a"}, {organizerId: "org-b"}]}}),
    privateRow("salesImportHistoryRows/history-a", {organizerId: "org-a",
      originalCells: [{column: "score", value: "old"}]}),
  ]);
  const result = await inventorySalesOrganizer(port, "org-a");
  assert.ok(result.items.some((item) => item.path ===
    "salesImportJobs/job-one/rows/001"));
  assert.ok(result.items.some((item) => item.path ===
    "salesImportHistoryRows/history-a"));
  assert.ok(result.blockers.some((item) => item.code === "mixed_organizers"));
  assert.equal(result.items.some((item) => item.path.includes("mixed")), false);
  assert.equal(result.blockers.some((item) => item.fingerprint.includes(
    "receipt-mixed")), false);
});

test("overflow is explicit and never misreported as complete", async () => {
  const port = memory([]);
  const original = port.scan;
  port.scan = async (collection, organizerId) => {
    if (collection === "salesActionReceipts") {
      throw new HttpsError(
        "resource-exhausted", "bounded scan");
    }
    return original(collection, organizerId);
  };
  const result = await inventorySalesOrganizer(port, "org-a");
  assert.equal(result.overflow, true);
  assert.ok(result.blockers.some((item) => item.code === "scan_overflow"));
});

test("assistant delegation scopes remain unresolved and shared clients are untouched", async () => {
  const port = memory([
    privateRow("assistantDelegations/delegation-a", {
      organizerIds: ["org-a", "org-b"], clientId: "client-a"}),
    privateRow("assistantManagementReceipts/receipt-a", {
      result: {organizerIds: ["org-a"]}}),
    privateRow("assistantClients/client-a", {clientId: "client-a"}),
  ]);
  const result = await inventorySalesOrganizer(port, "org-a");
  assert.ok(result.blockers.some((item) =>
    item.code === "mixed_assistant_scope"));
  assert.ok(result.blockers.some((item) =>
    item.code === "assistant_scope_retirement_required"));
  assert.equal(result.items.some((item) =>
    item.path.startsWith("assistant")), false);
});
