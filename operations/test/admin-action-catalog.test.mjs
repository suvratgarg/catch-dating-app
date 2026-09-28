import assert from "node:assert/strict";
import test from "node:test";
import {checkAdminActionCatalog} from
  "../scripts/check-admin-action-catalog.mjs";
import {loadAdminActionCatalog} from "../src/admin/action-catalog.mjs";

test("admin action catalog validates every workflow example", async () => {
  const catalog = await loadAdminActionCatalog();
  for (const workflow of catalog.workflows) {
    for (const actionId of workflow.actions) {
      const action = catalog.actionsById.get(actionId);
      assert.ok(action, actionId);
      assert.equal(catalog.validateRequest(actionId, action.example), action.example);
    }
  }
});

test("catalog checker rejects GUI callable and workflow membership drift",
  async () => {
    const current = await loadAdminActionCatalog();
    const catalog = {
      ...current,
      actions: current.actions.map((action, index) => index === 0 ? {
        ...action,
        workflowIds: [],
      } : action),
    };
    const adminApiSource = '(functions, "adminUnknownAction")';
    const result = await checkAdminActionCatalog({
      catalog,
      adminApiSource,
      functionsIndexSource: "export {adminUnknownAction};",
      validatorSource: '"strictRequests": ["adminUnknownAction"]',
    });
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.id === "gui-callable-catalog-drift"));
    assert.ok(result.findings.some((finding) =>
      finding.id === "workflow-membership-drift"));
  });

test("catalog checker rejects mutations without explicit confirmation",
  async () => {
    const current = await loadAdminActionCatalog();
    const mutation = current.actions.find((action) =>
      action.kind === "mutation");
    const catalog = {
      ...current,
      actions: current.actions.map((action) =>
        action.actionId === mutation.actionId ?
          {...action, confirmation: undefined} : action),
    };
    const callables = current.actions.map((action) => action.callable);
    const result = await checkAdminActionCatalog({
      catalog,
      adminApiSource: callables.map((callable) =>
        `(functions, "${callable}")`).join("\n"),
      functionsIndexSource: callables.join("\n"),
      validatorSource: `"strictRequests": ${JSON.stringify(callables)}`,
    });
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.id === "mutation-confirmation-missing" &&
      finding.actionId === mutation.actionId));
  });


test("Owner control-plane GUI actions remain catalogued and strictly validated", async () => {
  const result = await checkAdminActionCatalog();
  assert.deepEqual(result.findings, []);
  const current = await loadAdminActionCatalog();
  const action = current.actions.find((entry) =>
    entry.callable === "adminApplySalesPrivacyBatch");
  assert.equal(action.controlPlane, true);
  const callables = current.actions.map((entry) => entry.callable);
  const missingValidator = await checkAdminActionCatalog({
    adminApiSource: callables.map((name) => `(functions, "${name}")`).join("\n"),
    validatorSource: `"strictRequests": ${JSON.stringify(
      callables.filter((name) => name !== action.callable))}`,
  });
  assert.ok(missingValidator.findings.some((finding) =>
    finding.id === "strict-request-validation-drift" &&
    finding.missing.includes(action.callable)));
});
