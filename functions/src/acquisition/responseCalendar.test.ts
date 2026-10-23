import {strict as assert} from "node:assert";
import {test} from "node:test";
import {hostResponseDueAt} from "./responseCalendar";

const at = (local: string) => Date.parse(`${local}+05:30`);

test("Host response calendar counts working hours, not calendar days", () => {
  const cases = [
    ["2026-10-19T08:00:00", "2026-10-19T18:00:00"],
    ["2026-10-19T09:00:00", "2026-10-19T18:00:00"],
    ["2026-10-19T12:30:00", "2026-10-20T12:30:00"],
    ["2026-10-19T18:00:00", "2026-10-20T18:00:00"],
    ["2026-10-19T23:00:00", "2026-10-20T18:00:00"],
    ["2026-10-23T17:00:00", "2026-10-24T17:00:00"],
    ["2026-10-24T17:00:00", "2026-10-26T17:00:00"],
    ["2026-10-24T18:00:00", "2026-10-26T18:00:00"],
    ["2026-10-25T09:00:00", "2026-10-26T18:00:00"],
    ["2026-10-25T23:59:59", "2026-10-26T18:00:00"],
  ];
  for (const [accepted, due] of cases) {
    assert.equal(hostResponseDueAt(at(accepted)), at(due), accepted);
  }
});

test("calendar keeps milliseconds and crosses year and leap boundaries", () => {
  assert.equal(hostResponseDueAt(at("2026-12-31T17:59:59.999")),
    at("2027-01-01T17:59:59.999"));
  assert.equal(hostResponseDueAt(at("2028-02-28T17:00:00")),
    at("2028-02-29T17:00:00"));
  // No implicit public-holiday exemption or host-machine timezone.
  assert.equal(hostResponseDueAt(at("2027-01-25T12:00:00")),
    at("2027-01-26T12:00:00"));
});

test("invalid receipt timestamps do not produce usable deadlines", () => {
  for (const value of [NaN, Infinity, -1, 0.5, 8.64e15,
    Number.MAX_SAFE_INTEGER]) {
    assert.equal(hostResponseDueAt(value), null);
  }
});
