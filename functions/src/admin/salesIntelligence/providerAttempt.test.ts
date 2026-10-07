import {strict as assert} from "node:assert";
import {test} from "node:test";
import {checkedProviderBudget, providerAttemptId} from "./providerAttempt";
import {createSalesWritingPreparationWorker} from "./providerRuntime";

test("writing defaults disabled before inspecting requests or ports", async () => {
  const request = {get jobId(): string {
    throw new Error("Synthetic private sentinel must not be read.");
  }, leaseOwner: "unused"};
  await assert.rejects(createSalesWritingPreparationWorker().run(request),
    {code: "failed-precondition", message: "Sales providers are disabled."});
});

test("provider budget requires every explicit bounded dimension", () => {
  const limits = {modelCalls: 1, networkRequests: 1, modelInputTokens: 100,
    modelOutputTokens: 50, modelCostMicros: 1000};
  assert.deepEqual(checkedProviderBudget(limits), limits);
  for (const row of [{...limits, modelCostMicros: -1},
    {...limits, modelCalls: Number.MAX_SAFE_INTEGER},
    {...limits, modelInputTokens: 0.5}, {...limits, unexpected: 1},
    {modelCalls: 1, networkRequests: 1, modelInputTokens: 100,
      modelOutputTokens: 50}]) {
    assert.throws(() => checkedProviderBudget(row),
      {code: "failed-precondition"});
  }
});

test("paid identity stays stable per job and distinct across jobs", () => {
  assert.equal(providerAttemptId("job-synthetic-one"),
    providerAttemptId("job-synthetic-one"));
  assert.notEqual(providerAttemptId("job-synthetic-one"),
    providerAttemptId("job-synthetic-two"));
});
