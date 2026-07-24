import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {AdminActionReceiptStore} from "../src/admin/receipt-store.mjs";

test("admin receipt store is idempotent but never overwrites evidence", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "catch-admin-receipt-"));
  const store = new AdminActionReceiptStore(root);
  const receipt = {
    schemaVersion: 1,
    executionId: "11111111-1111-4111-8111-111111111111",
    actionId: "overview.get",
    status: "succeeded",
    requestHash: "a".repeat(64),
  };
  const first = await store.put(receipt);
  assert.equal(await store.put(receipt), first);
  await assert.rejects(
    () => store.put({...receipt, status: "failed"}),
    {code: "ADMIN_ACTION_RECEIPT_CONFLICT"}
  );
  assert.match(await fs.readFile(first, "utf8"), /"succeeded"/u);
  assert.equal((await fs.stat(first)).mode & 0o777, 0o600);
});
