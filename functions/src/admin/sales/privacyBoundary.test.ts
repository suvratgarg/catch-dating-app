import assert from "node:assert/strict";
import test from "node:test";
import {assertSalesMaterialPrivacyOpen, filterSalesPrivacyRows,
  salesMaterialOrganizerIds} from "./privacyBoundary";
const db = {collection: () => ({doc: (id: string) => ({get: async () =>
  ({exists: id === "restricted"})})})} as unknown as
  FirebaseFirestore.Firestore;
test("mixed receipts cannot replay a restricted source", async () => {
  const receipt = {organizerId: null, result: {rows: [
    {organizerId: "open"}, {organizerId: "restricted"}]}};
  assert.deepEqual(salesMaterialOrganizerIds(receipt), ["open", "restricted"]);
  await assert.rejects(assertSalesMaterialPrivacyOpen(db, receipt),
    /processing is restricted/u);
});
test("page filtering withholds restricted rows", async () => {
  assert.deepEqual(await filterSalesPrivacyRows(db,
    [{organizerId: "restricted", privateText: "hidden"},
      {organizerId: "open", privateText: "visible"}]),
  [{organizerId: "open", privateText: "visible"}]);
});
