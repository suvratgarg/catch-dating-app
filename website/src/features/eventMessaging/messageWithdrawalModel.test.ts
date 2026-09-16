import {expect, it} from "vitest";
import {messageWithdrawalResponse} from "./messageWithdrawalModel";

const view = {serverTime: 1000, revision: 1, preference: "enabled", expiresAt: 2000};

it("retains every outcome and preference without sharing the response object", () => {
  for (const outcome of ["read", "applied", "replayed", "conflict"]) {
    for (const preference of ["enabled", "disabled", "expired"]) {
      const input = {outcome, view: {...view, preference}};
      const parsed = messageWithdrawalResponse(input, outcome === "read" ? "read" : "mutation");
      expect(parsed).toEqual(input);
      expect(parsed).not.toBe(input);
      expect(parsed.view).not.toBe(input.view);
    }
  }
});

it("rejects unknown shapes, unsafe revisions, identity fields and private provider data", () => {
  const valid = {outcome: "read", view};
  const invalid = [null, [], {}, {...valid, outcome: "success"},
    {...valid, outcome: "toString"}, {...valid, secret: "private"},
    {...valid, view: {...view, phone: "private"}},
    ...[null, [], {revision: 1}].map((view) => ({...valid, view})),
    ...[0, -1, 1.5, "1", NaN, Infinity, Number.MAX_SAFE_INTEGER + 1]
      .map((revision) => ({...valid, view: {...view, revision}})),
    ...["yes", "toString", null].map((preference) => ({...valid, view: {...view, preference}})),
    {...valid, view: {...view, expiresAt: -1}},
    {...valid, view: {...view, serverTime: NaN}}];
  for (const input of invalid) {
    expect(() => messageWithdrawalResponse(input, "read"))
      .toThrow("Invalid event message preference response");
  }
});

it("a read cannot masquerade as a saved withdrawal and a write cannot become a read", () => {
  expect(() => messageWithdrawalResponse({outcome: "read", view}, "mutation")).toThrow();
  for (const outcome of ["applied", "replayed", "conflict"]) {
    expect(() => messageWithdrawalResponse({outcome, view}, "read")).toThrow();
  }
});
