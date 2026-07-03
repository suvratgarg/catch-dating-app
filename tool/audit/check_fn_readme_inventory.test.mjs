import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  extractDocumentedFunctionNames,
  extractFunctionExports,
  scanFunctionReadmeInventory,
} from "./check_fn_readme_inventory.mjs";

test("extractFunctionExports reads direct and re-exported names", () => {
  const exports = extractFunctionExports(`
    export const directCallable = onCall(() => {});
    export function httpEndpoint() {}
    export {
      createEvent,
      updateEvent as updateEventCallable,
    } from "./events/mutateEvent";
  `);

  assert.deepEqual(exports, [
    "createEvent",
    "directCallable",
    "httpEndpoint",
    "updateEventCallable",
  ]);
});

test("extractDocumentedFunctionNames reads backticked function names", () => {
  const documented = extractDocumentedFunctionNames(
    "| `createEvent` / `updateEvent` | `src/events/` |\n",
  );

  assert.deepEqual([...documented].sort(), ["createEvent", "updateEvent"]);
});

test("scanFunctionReadmeInventory flags exports missing from README", () => {
  const root = createFixture({
    "functions/src/index.ts": `
      export {createEvent, updateEvent} from "./events/mutateEvent";
    `,
    "functions/README.md": "| `createEvent` | `src/events/` |\n",
  });

  const result = scanFunctionReadmeInventory({root});

  assert.deepEqual(result.findings.map((finding) => finding.function), [
    "updateEvent",
  ]);
});

test("scanFunctionReadmeInventory passes documented exports", () => {
  const root = createFixture({
    "functions/src/index.ts": `
      export {createEvent, updateEvent} from "./events/mutateEvent";
    `,
    "functions/README.md": "| `createEvent` / `updateEvent` | `src/events/` |\n",
  });

  assert.deepEqual(scanFunctionReadmeInventory({root}).findings, []);
});

test("scanFunctionReadmeInventory ratchets baseline findings", () => {
  const root = createFixture({
    "functions/src/index.ts": `
      export {createEvent, updateEvent} from "./events/mutateEvent";
      export {deleteEvent} from "./events/deleteEvent";
    `,
    "functions/README.md": "| `createEvent` | `src/events/` |\n",
  });
  const baseline = {
    allowedFindings: [
      {rule: "missingReadmeFunction", function: "updateEvent"},
    ],
  };

  const result = scanFunctionReadmeInventory({root, baseline});

  assert.deepEqual(result.baselineFindings.map((finding) => finding.function), [
    "updateEvent",
  ]);
  assert.deepEqual(result.findings.map((finding) => finding.function), [
    "deleteEvent",
  ]);
});

function createFixture(files) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-fn-readme-"));
  for (const [relativePath, source] of Object.entries(files)) {
    const file = path.join(root, relativePath);
    fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, source);
  }
  return root;
}
