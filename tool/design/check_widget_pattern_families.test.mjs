import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {checkPatternFamilies} from "./check_widget_pattern_families.mjs";

const scriptPath = fileURLToPath(
  new URL("./check_widget_pattern_families.mjs", import.meta.url),
);
const defaultRegistryPath =
  "docs/design_parity/widget_consolidation/pattern_families.json";

function validRegistry() {
  return {
    schemaVersion: 1,
    families: [
      {
        id: "pill-chip-family",
        title: "Pills and chips",
        intent: "One ergonomic contract for compact labels and selections.",
        priority: "P0",
        status: "approved",
        targetContract: "CatchChip",
        qualityReference: "CatchChip",
        decisionSource: "widgetbook-compare:app-pill-chip-family",
        acceptedVisualDelta: "Selected chips use the stronger inverse fill.",
        members: [
          {
            symbol: "CatchChip",
            disposition: "canonical",
            preview: "required",
            rationale: "Owns the target contract and complete state model.",
          },
          {
            symbol: "LegacyChip",
            disposition: "unify",
            target: "CatchChip",
            preview: "source-only",
            rationale: "Migrates to the stronger canonical chip contract.",
          },
          {
            symbol: "RepairChip",
            disposition: "repair",
            target: "CatchChip",
            preview: "source-only",
            rationale: "Keeps its semantic identity while adopting the target treatment.",
          },
          {
            symbol: "DecorativeChip",
            disposition: "discard",
            preview: "not-applicable",
            rationale: "Has no durable product contract or runtime consumer.",
          },
        ],
      },
    ],
  };
}

function createFixture(t, {registry = validRegistry(), registryPath = defaultRegistryPath} = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-pattern-families-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));

  writeFile(
    root,
    registryPath,
    `${JSON.stringify(registry, null, 2)}\n`,
  );
  writeFile(
    root,
    "widgetbook/lib/main.directories.g.dart",
    [
      "final directories = [",
      "  WidgetbookComponent(",
      "    name: 'CatchChip',",
      "    useCases: const [],",
      "  ),",
      "];",
    ].join("\n"),
  );
  writeFile(
    root,
    "docs/audit_registry/widget_classification.json",
    `${JSON.stringify({widgets: [{name: "LegacyChip"}]}, null, 2)}\n`,
  );
  writeFile(
    root,
    "lib/design/repair_chip.dart",
    "class RepairChip extends StatelessWidget {}\n",
  );
  return {root, registryPath};
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function writeFile(root, relativePath, contents) {
  const fullPath = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(fullPath), {recursive: true});
  fs.writeFileSync(fullPath, contents);
}

function errorsFor(t, mutate) {
  const registry = clone(validRegistry());
  mutate(registry);
  const {root} = createFixture(t, {registry});
  return checkPatternFamilies({repoRoot: root}).errors;
}

test("accepts a valid family with required, source-only, and explicit not-applicable previews", (t) => {
  const {root} = createFixture(t);

  const result = checkPatternFamilies({repoRoot: root});

  assert.deepEqual(result.errors, []);
  assert.equal(result.familyCount, 1);
  assert.equal(result.memberCount, 4);
});

test("rejects invalid JSON without throwing", (t) => {
  const {root} = createFixture(t);
  writeFile(root, defaultRegistryPath, "{ not-json\n");

  const result = checkPatternFamilies({repoRoot: root});

  assert.equal(result.errors.length, 1);
  assert.match(result.errors[0], /registry is not valid JSON/u);
});

test("rejects a non-object registry", (t) => {
  const {root} = createFixture(t, {registry: []});

  const result = checkPatternFamilies({repoRoot: root});

  assert.deepEqual(result.errors, ["registry must be a JSON object"]);
});

test("rejects a family with zero members", (t) => {
  const errors = errorsFor(t, (registry) => {
    registry.families[0].members = [];
  });

  assert.ok(errors.includes("families[0].members must be a nonempty array"));
});

test("requires every member to acknowledge its preview state", (t) => {
  const errors = errorsFor(t, (registry) => {
    delete registry.families[0].members[3].preview;
  });

  assert.ok(errors.some((error) => error.startsWith("families[0].members[3].preview")));
});

test("rejects duplicate family ids", (t) => {
  const errors = errorsFor(t, (registry) => {
    registry.families.push(clone(registry.families[0]));
  });

  assert.ok(errors.some((error) => error.includes("duplicates family id 'pill-chip-family'")));
});

test("rejects an invalid disposition", (t) => {
  const errors = errorsFor(t, (registry) => {
    registry.families[0].members[1].disposition = "maybe";
  });

  assert.ok(errors.some((error) => error.includes(".disposition must be one of")));
});

test("requires a target for unify", (t) => {
  const errors = errorsFor(t, (registry) => {
    delete registry.families[0].members[1].target;
  });

  assert.ok(
    errors.includes(
      "families[0].members[1].target is required when disposition is 'unify'",
    ),
  );
});

test("requires qualityReference to name a member", (t) => {
  const errors = errorsFor(t, (registry) => {
    registry.families[0].qualityReference = "UnknownChip";
  });

  assert.ok(
    errors.includes(
      "families[0].qualityReference 'UnknownChip' must name a family member",
    ),
  );
});

test("requires an accepted visual delta for approved families", (t) => {
  const errors = errorsFor(t, (registry) => {
    registry.families[0].acceptedVisualDelta = "";
  });

  assert.ok(
    errors.includes(
      "families[0].acceptedVisualDelta is required when status is 'approved'",
    ),
  );
});

test("rejects a required preview missing from generated Widgetbook directories", (t) => {
  const errors = errorsFor(t, (registry) => {
    registry.families[0].members.push({
      symbol: "MissingPreviewChip",
      disposition: "register",
      preview: "required",
      rationale: "Must be visible before this family can be reviewed.",
    });
  });

  assert.ok(
    errors.some(
      (error) =>
        error.includes("'MissingPreviewChip'") &&
        error.includes("widgetbook/lib/main.directories.g.dart"),
    ),
  );
});

test("rejects a source-only symbol with no classification or Dart source evidence", (t) => {
  const errors = errorsFor(t, (registry) => {
    registry.families[0].members.push({
      symbol: "MissingSourceChip",
      disposition: "discard",
      preview: "source-only",
      rationale: "Its source identity must still be auditable before removal.",
    });
  });

  assert.ok(
    errors.some(
      (error) =>
        error.includes("'MissingSourceChip'") &&
        error.includes("no current Dart classification or lib source evidence"),
    ),
  );
});

test("allows target on repair but rejects it on other non-unify dispositions", (t) => {
  const valid = createFixture(t);
  assert.deepEqual(checkPatternFamilies({repoRoot: valid.root}).errors, []);

  const errors = errorsFor(t, (registry) => {
    registry.families[0].members[0].target = "CatchChip";
  });
  assert.ok(
    errors.includes(
      "families[0].members[0].target is only allowed for 'repair' or 'unify'",
    ),
  );
});

test("CLI supports --check with custom --file and --repo-root", (t) => {
  const registryPath = "fixtures/custom_pattern_families.json";
  const {root} = createFixture(t, {registryPath});

  const result = spawnSync(
    process.execPath,
    [scriptPath, "--check", "--repo-root", root, "--file", registryPath],
    {encoding: "utf8"},
  );

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Widget pattern families OK/u);
  assert.match(result.stdout, /1 families, 4 members/u);
});
