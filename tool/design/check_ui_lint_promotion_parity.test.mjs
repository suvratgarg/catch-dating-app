import assert from "node:assert/strict";
import test from "node:test";

import {checkPromotionParity} from "./check_ui_lint_promotion_parity.mjs";

test("rejects retired categories and missing seeded fixtures", () => {
  const failures = checkPromotionParity({
    scannerSource: "Brittle widget-test timing and missed-tap patterns",
    harnessSource: "",
  });

  assert.ok(failures.some((failure) => failure.includes("retired scanner")));
  assert.ok(failures.some((failure) => failure.includes("missing parity fixture")));
});
