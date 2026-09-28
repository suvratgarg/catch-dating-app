import test from "node:test";
import assert from "node:assert/strict";
import {adminCallableNames} from "./callable_inventory.mjs";

test("catalog and validator discovery cover central and feature-owned APIs", () => {
  assert.deepEqual(adminCallableNames(`
    httpsCallable<Request, Response>(functions, "adminLegacy")(payload);
    call("adminSalesRead", {organizerId});
    call<Request, Response>("adminSalesWrite", payload);
    call("adminSalesRead", input);
    const unrelated = "adminNotInvoked";
  `), ["adminLegacy", "adminSalesRead", "adminSalesWrite"]);
});
