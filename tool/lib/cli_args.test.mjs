import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {parseCommonArgs} from "./cli_args.mjs";

test("common arguments preserve command fields while accepting standard option syntax", () => {
  assert.deepEqual(
    parseCommonArgs([
      "--env=dev",
      "--project", "catch-dev",
      "--apply",
      "--allow-prod",
      "--confirm-prod",
      "--json",
      "--check",
      "--import-plan=plans/import.json",
      "task-id",
    ], {
      booleanFlags: ["--check"],
      valueFlags: ["--import-plan"],
    }),
    {
      env: "dev",
      project: "catch-dev",
      emulatorHost: null,
      apply: true,
      allowProd: true,
      confirmProd: true,
      json: true,
      help: false,
      positionals: ["task-id"],
      check: true,
      import_plan: "plans/import.json",
    },
  );
});

test("common arguments retain repeat and emulator precedence in token order", () => {
  assert.equal(
    parseCommonArgs(["--emulator-host", "custom:9000", "--emulator"]).emulatorHost,
    "127.0.0.1:8080",
  );
  assert.equal(
    parseCommonArgs(["--emulator", "--emulator-host=custom:9000"]).emulatorHost,
    "custom:9000",
  );
  assert.equal(
    parseCommonArgs(["--env", "staging", "--env=prod"]).env,
    "prod",
  );
  assert.equal(parseCommonArgs(["-h"]).help, true);
});

test("common arguments can project strict command-specific flags as camel case", () => {
  const parsed = parseCommonArgs([
    "--allow-empty",
    "--summary-only",
    "--source-label=fixture",
  ], {
    booleanFlags: ["--allow-empty", "--summary-only"],
    valueFlags: ["--source-label"],
    allowPositionals: false,
    customFieldCase: "camel",
  });

  assert.equal(parsed.allowEmpty, true);
  assert.equal(parsed.summaryOnly, true);
  assert.equal(parsed.sourceLabel, "fixture");
  assert.throws(
    () => parseCommonArgs(["unexpected"], {allowPositionals: false}),
    /Unexpected argument 'unexpected'/u,
  );
});

test("common arguments fail closed on malformed option input and declarations", () => {
  assert.throws(
    () => parseCommonArgs(["--unknown"]),
    /Unknown option '--unknown'/u,
  );
  assert.throws(
    () => parseCommonArgs(["--env", "--json"]),
    /argument is ambiguous/u,
  );
  assert.throws(
    () => parseCommonArgs([], {booleanFlags: ["-q"]}),
    /must be a long flag/u,
  );
  assert.throws(
    () => parseCommonArgs([], {customFieldCase: "pascal"}),
    /Unsupported custom CLI field case/u,
  );
});

test("the fourteen common migration and intake commands retain the shared parser", () => {
  for (const path of [
    "tool/firebase/create_config_cities.mjs",
    "tool/data/backfill_location_market_fields.mjs",
    "tool/data/backfill_event_meeting_locations.mjs",
    "tool/data/migrate_clubs_to_organizers.mjs",
    "tool/organizer_intake/publish_event_supply_readiness.mjs",
    "tool/organizer_intake/export_curation_decisions_from_firestore.mjs",
    "tool/organizer_intake/export_event_location_resolutions_from_firestore.mjs",
    "tool/organizer_intake/export_event_review_decisions_from_firestore.mjs",
    "tool/organizer_intake/export_policy_gap_decisions_from_firestore.mjs",
    "tool/organizer_intake/export_review_decisions_from_firestore.mjs",
    "tool/data/backfill_event_admin_search.mjs",
    "tool/data/backfill_event_discovery_fields.mjs",
    "tool/data/backfill_organizer_admin_search.mjs",
    "tool/data/recompute_public_profiles.mjs",
  ]) {
    assert.match(
      fs.readFileSync(path, "utf8"),
      /parseCommonArgs.*cli_args\.mjs|cli_args\.mjs.*parseCommonArgs/su,
      path,
    );
  }
});
