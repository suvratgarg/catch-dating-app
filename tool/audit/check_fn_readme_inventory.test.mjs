import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
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

test("README baseline cleanup rejects resolved, removed and reintroduced omissions through the CLI", (t) => {
  const allowance = {rule: "missingReadmeFunction", function: "createEvent"};
  const root = createFixture({
    "functions/src/index.ts": "export {createEvent} from './events';\n",
    "functions/README.md": "# Functions\n",
    "baseline.json": JSON.stringify({allowedFindings: [allowance]}),
  });
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const readme = path.join(root, "functions/README.md");
  const baseline = path.join(root, "baseline.json");
  const index = path.join(root, "functions/src/index.ts");
  const check = (status, rule) => {
    const before = [readme, baseline, index].map(file => fs.readFileSync(file, "utf8"));
    const result = spawnSync(process.execPath, [
      fileURLToPath(new URL("./check_fn_readme_inventory.mjs", import.meta.url)),
      "--root", root, "--baseline", baseline, "--json",
    ], {encoding: "utf8"});
    assert.equal(result.status, status, result.stderr);
    const report = JSON.parse(result.stdout);
    assert.deepEqual(report.findings.map(finding => finding.rule), rule ? [rule] : []);
    assert.deepEqual([readme, baseline, index].map(file => fs.readFileSync(file, "utf8")), before);
    return report;
  };
  assert.equal(check(0).baselineFindings.length, 1);
  fs.writeFileSync(readme, "| `createEvent` | documented |\n");
  assert.deepEqual(check(1, "staleBaselineAllowance").allFindings, []);
  fs.writeFileSync(index, "// Export was removed.\n");
  check(1, "staleBaselineAllowance");
  fs.writeFileSync(baseline, JSON.stringify({allowedFindings: []}));
  check(0);
  fs.writeFileSync(index, "export {createEvent} from './events';\n");
  fs.writeFileSync(readme, "# Functions\n");
  check(1, "missingReadmeFunction");
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
