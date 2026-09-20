import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import test from "node:test";
import {configureRuntime} from "./runtimeConfigTestHarness";
import {setup} from "./liveLateJoinTestHarness";

test("event-wide joining choices publish only for the guest's approved plan",
  async () => {
    const h = await setup();
    assert.ok(h.intent.kind === "joiningUpdate");
    const current = {label: "Meet us here",
      target: h.intent.guidance.destination};
    const other = {label: "Another pace group", target: {
      kind: "groupCheckpoint" as const, routeId: "other-route",
      groupId: "other-group", checkpointId: "other-checkpoint"}};
    const options = {...h.options, laterChoices: [current, other]};
    const r = await configureRuntime(h, {options,
      expiresAt: h.clock.now + 60_000, maxEvaluations: 10});
    const publicationOptions = {...options, runtimeBinding: r.binding};
    const published = await h.publisher.publish(h.scope, publicationOptions);
    assert.ok(published.kind === "published");
    assert.ok(published.intent.kind === "joiningUpdate");
    assert.deepEqual(published.intent.choices.map((c) => c.label),
      ["I'm on my way", "I can't make it", "I need help", current.label]);
    assert.deepEqual(r.saved.view.runtime!.configuration!.options.laterChoices,
      [current, other], "selection must not rewrite the saved event choices");
    const retry = await h.publisher.publish(h.scope, publicationOptions);
    assert.ok(retry.kind === "published");
    assert.equal(retry.messageId, published.messageId);
    const changed = await h.publisher.publish(h.scope, {...publicationOptions,
      laterChoices: [current]});
    assert.equal(changed.kind, "held");
    if (changed.kind === "held") {
      assert.deepEqual(changed.evaluation,
        {kind: "runtimeUnavailable", reason: "configurationChanged"});
    }
    const delivery = await h.delivery(published);
    assert.equal((await delivery.claim()).kind, "claimed",
      "dispatch must validate against the full frozen runtime configuration");
  });

test("non-applicable joining choices retain the default response options",
  async () => {
    const h = await setup();
    const options = {...h.options, laterChoices: [{label: "Other group",
      target: {
        kind: "groupCheckpoint" as const, routeId: "elsewhere",
        groupId: "other", checkpointId: "water-stop"}}]};
    const r = await configureRuntime(h, {options,
      expiresAt: h.clock.now + 60_000,
      maxEvaluations: 10});
    const result = await h.publisher.publish(h.scope,
      {...options, runtimeBinding: r.binding});
    assert.ok(result.kind === "published");
    assert.ok(result.intent.kind === "joiningUpdate");
    assert.equal(result.intent.choices.length, 3);
  });

test("duplicate joining destinations cannot save ambiguous labels or work",
  async () => {
    const h = await setup();
    const r = await configureRuntime(h);
    assert.ok(h.intent.kind === "joiningUpdate");
    const target = h.intent.guidance.destination;
    const before = h.fake.entries();
    await assert.rejects(r.store.set("host-1", {...r.input,
      requestId: randomUUID(), expectedRevision: 1,
      command: {kind: "configure", configuration: {...r.configuration,
        options: {...h.options, laterChoices: [
          {label: "First label", target}, {label: "Other label", target}]}}}}),
    {code: "invalid-argument"});
    assert.deepEqual(h.fake.entries(), before);
  });
