import assert from "node:assert/strict";
import test from "node:test";
import {
  assertEventVisibilityWithinOrganizerCeiling,
  effectiveEventVisibility,
  SupplyVisibilityControls,
} from "./supplyVisibilityPolicy";

const visible: SupplyVisibilityControls = {
  publishStatus: "published",
  indexStatus: "indexed",
  appVisibility: "discoverable",
};

test("effectiveEventVisibility applies each organizer ceiling independently",
  () => {
    assert.deepEqual(effectiveEventVisibility(visible, {
      publishStatus: "published",
      indexStatus: "noindex",
      appVisibility: "hidden",
    }), {
      publishStatus: "published",
      indexStatus: "noindex",
      appVisibility: "hidden",
    });
  });

test("event visibility cannot exceed its organizer on either surface", () => {
  assert.throws(
    () => assertEventVisibilityWithinOrganizerCeiling(visible, {
      publishStatus: "draft",
      indexStatus: "noindex",
      appVisibility: "hidden",
    }),
    (error) => {
      assert.equal((error as {code?: string}).code, "failed-precondition");
      return true;
    }
  );
});

test("event visibility at the organizer ceiling is allowed", () => {
  assert.doesNotThrow(
    () => assertEventVisibilityWithinOrganizerCeiling(visible, visible)
  );
});
