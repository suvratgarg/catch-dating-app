import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {assertOutboundContentAllowed} from "./outboundContentPolicy";

test("managed outbound content accepts ordinary route copy", () => {
  assert.doesNotThrow(() => assertOutboundContentAllowed(
    ["See you at the east gate", "Sunday Social"],
    "Content cannot be delivered.",
  ));
});

test("managed outbound content rejects blocked or review-only copy", () => {
  for (const value of ["kill yourself", "That was a shit show"]) {
    assert.throws(
      () => assertOutboundContentAllowed(
        ["Allowed value", value],
        "Content cannot be delivered.",
      ),
      (error) => error instanceof HttpsError &&
        error.code === "invalid-argument" &&
        error.message === "Content cannot be delivered.",
    );
  }
});
