import assert from "node:assert/strict";
import test from "node:test";
import {effectiveOrganizerAudienceCoverage} from
  "./organizerAudienceCoverage";

test("empty and manual-only organizers have exact audience coverage", () => {
  assert.equal(effectiveOrganizerAudienceCoverage(undefined, false), "exact");
  assert.equal(effectiveOrganizerAudienceCoverage("partial", false), "exact");
});

test("canonical history stays partial until it has been projected", () => {
  assert.equal(effectiveOrganizerAudienceCoverage(undefined, true), "partial");
  assert.equal(effectiveOrganizerAudienceCoverage("partial", true), "partial");
  assert.equal(effectiveOrganizerAudienceCoverage("exact", true), "exact");
});
