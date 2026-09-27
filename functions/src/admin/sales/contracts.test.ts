import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import path from "node:path";
import test from "node:test";
import {SALES_ACTION_SCHEMAS, SALES_READ_SCHEMAS} from "./schemas";

const root = path.resolve(__dirname, "../../../../contracts");

test("Sales catalog requests match the runtime validator authority", () => {
  const catalog = JSON.parse(readFileSync(path.join(root,
    "admin/admin_action_catalog.json"), "utf8")) as {
    actions: Array<{actionId: string; callable: string;
      requestSchema: string}>;
  };
  const actions = {...SALES_READ_SCHEMAS, ...SALES_ACTION_SCHEMAS};
  const entries = catalog.actions.filter((entry) =>
    entry.actionId.startsWith("sales.") &&
    !entry.actionId.startsWith("sales.demo."));
  assert.equal(entries.length, Object.keys(actions).length);
  for (const entry of entries) {
    const action = entry.actionId.slice("sales.".length);
    const expected = actions[action as keyof typeof actions];
    assert.ok(expected, `Unknown Sales action ${action}`);
    assert.match(entry.callable, /^admin[A-Z]/u);
    const schemaPath = path.join(root, "..", entry.requestSchema);
    const schema = JSON.parse(readFileSync(schemaPath, "utf8")) as
      Record<string, unknown>;
    delete schema.$schema;
    delete schema.$id;
    delete schema.title;
    delete schema.description;
    assert.deepEqual(schema, expected, `Contract drift: ${action}`);
  }
});
