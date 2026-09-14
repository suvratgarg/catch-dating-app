import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import {readFileSync} from "node:fs";
import test from "node:test";

test("component lexicon resolves both app and extracted package surfaces", () => {
  const result = spawnSync(
    process.execPath,
    ["tool/design/check_component_lexicon.mjs"],
    {cwd: process.cwd(), encoding: "utf8"}
  );
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Component lexicon check passed/u);
});

test("component lexicon rejects a declared surface symbol that does not exist", () => {
  const result = spawnSync(
    process.execPath,
    ["tool/design/check_component_lexicon.mjs", "--known-bad"],
    {cwd: process.cwd(), encoding: "utf8"}
  );
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /__KnownMissingWebsiteSymbol__.*was not found/u);
});

test("structural labels remain distinct from status badges on every stack", () => {
  const registry = JSON.parse(
    readFileSync("design/components/catch.components.json", "utf8")
  );
  const byId = new Map(registry.components.map((component) => [component.id, component]));
  assert.deepEqual(byId.get("catch.ui_label")?.surfaces, {
    flutter: "CatchSectionHeaderTitle",
    website: "UiLabel",
    admin: "AdminEyebrow",
    webui: "UiLabel",
  });
  assert.deepEqual(byId.get("catch.badge")?.surfaces, {
    flutter: "CatchBadge",
    website: "StatusBadge",
    admin: "StatusChip",
    webui: "BadgeControl",
  });
});

test("component lexicon rejects a third boolean on a production constructor", () => {
  const result = spawnSync(process.execPath,
    ["tool/design/check_component_lexicon.mjs", "--known-bad-api"],
    {cwd: process.cwd(), encoding: "utf8"});
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /CatchField.input: exposes 3 booleans.*unreviewedFlag/u);
});

test("website surface checks work without Dart while full API checks fail closed", () => {
  const run = (args) => spawnSync(process.execPath,
    ["tool/design/check_component_lexicon.mjs", ...args],
    {cwd: process.cwd(), encoding: "utf8", env: {...process.env, PATH: ""}});
  const surfaces = run(["--surfaces-only"]);
  assert.equal(surfaces.status, 0, surfaces.stderr);
  assert.match(surfaces.stdout, /surface symbols only/u);
  assert.doesNotMatch(surfaces.stdout, /0 shared API/u);
  const full = run([]);
  assert.equal(full.status, 1);
  assert.match(full.stderr, /Component API collection failed/u);
  assert.equal(run(["--surfaces-only", "--known-bad-api"]).status, 64);
  const manifest = JSON.parse(readFileSync("tool/tools_manifest.json", "utf8"));
  const gate = manifest.tools.find(({id}) => id === "design:component-lexicon");
  assert.ok(gate.ciRequirements.setup.includes("flutter-pub"));
  assert.ok(gate.checks.includes("node tool/design/check_component_lexicon.mjs"));
});
