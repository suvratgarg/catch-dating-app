"use strict";
const assert = require("node:assert/strict");
const test = require("node:test");
const {parseFlags, validateTarget} = require(
  "../scripts/operations/review-event-messaging.cjs");

const valid = ["--environment", "dev", "--project", "demo-catch",
  "--event", "event", "--organizer", "organizer", "--route", "catchEventRcs",
  "--sender", "sender", "--purpose", "planChanged"];

test("review rejects ambiguous targets and has no apply or credential option", () => {
  assert.equal(parseFlags(valid).route, "catchEventRcs");
  assert.equal(parseFlags(valid).purpose, "planChanged");
  for (const flags of [[], [...valid, "--apply"], [...valid, "--sender", "other"],
    [...valid.slice(0, -1), "../sender"], [...valid, "--access-token", "secret"],
    [...valid, "--purpose", "unknown"], [...valid, "--all"],
    ["--event", "event"]]) assert.throws(() => parseFlags(flags));
});

test("review requires the exact environment project before opening Firestore", () => {
  const flags = parseFlags(valid);
  assert.throws(() => validateTarget(flags, {dev: "other-project"}));
  assert.throws(() => validateTarget(flags, {prod: flags.project}));
  assert.doesNotThrow(() => validateTarget(flags, {dev: flags.project}));
});
