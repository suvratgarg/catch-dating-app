import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import test from "node:test";

test("event_location_resolution draft prints a reviewed coordinate batch", () => {
  const result = spawnSync(process.execPath, [
    "tool/organizer_intake/event_location_resolution.mjs",
    "draft",
    "2026-06-17-afterfly-luma-events:pxgmph3b",
    "--queue",
    "tool/organizer_intake/fixtures/external_event_location_resolution_queue.expected.json",
    "--name",
    "Nehru Stadium",
    "--address",
    "Nehru Stadium, Indore, Madhya Pradesh",
    "--place-id",
    "ChIJ-afterfly-indore",
    "--latitude",
    "22.7196",
    "--longitude",
    "75.8577",
    "--reviewer",
    "codex-dry-run",
    "--date",
    "2026-06-17",
    "--note",
    "Manual location QA complete.",
    "--confirm-location-checklist",
    "--dry-run",
  ], {
    encoding: "utf8",
  });

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Would write/);
  assert.match(result.stdout, /"locationResolutionBatchId": "2026-06-17-afterfly-location-resolved"/);
  assert.match(result.stdout, /"latitude": 22.7196/);
  assert.match(result.stdout, /"longitude": 75.8577/);
  assert.match(result.stdout, /"sourceLocationReviewed": true/);
});

test("event_location_resolution draft requires checklist confirmation", () => {
  const result = spawnSync(process.execPath, [
    "tool/organizer_intake/event_location_resolution.mjs",
    "draft",
    "2026-06-17-afterfly-luma-events:pxgmph3b",
    "--queue",
    "tool/organizer_intake/fixtures/external_event_location_resolution_queue.expected.json",
    "--name",
    "Nehru Stadium",
    "--latitude",
    "22.7196",
    "--longitude",
    "75.8577",
    "--reviewer",
    "codex-dry-run",
    "--date",
    "2026-06-17",
    "--note",
    "Manual location QA complete.",
    "--dry-run",
  ], {
    encoding: "utf8",
  });

  assert.equal(result.status, 64);
  assert.match(result.stderr, /confirm-location-checklist/);
});
