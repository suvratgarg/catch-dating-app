import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import {readFileSync} from "node:fs";
import test from "node:test";

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
    flutter: "CatchSectionLabel",
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
