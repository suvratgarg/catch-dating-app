import {randomUUID} from "node:crypto";
import assert from "node:assert/strict";
import type {Firestore} from "firebase-admin/firestore";
import {setup} from "./liveLateJoinTestHarness";
import {start} from "./whatsappTestHarness";
import {EventAssistanceRuntimeConfigStore} from "./runtimeConfigStore";
import type {RuntimeConfiguration} from "./runtimeConfigRecords";

export async function configureRuntime(h: Awaited<ReturnType<typeof setup>>,
  configuration: RuntimeConfiguration = {options: h.options,
    expiresAt: start + 3_600_000, maxEvaluations: 100}) {
  const store = new EventAssistanceRuntimeConfigStore(h.db, () => h.clock.now);
  const view = (await store.get("host-1", {context: h.context})).view;
  const input = {context: h.context, requestId: randomUUID(),
    expectedRevision: view.revision, expectedSourceHash: view.sourceHash,
    command: {kind: "configure" as const, configuration}};
  const saved = await store.set("host-1", input);
  const binding = {runtimeId: saved.view.runtime!.runtimeId,
    revision: saved.view.revision};
  return {store, input, configuration, binding, saved};
}

export async function setupRuntimePublication(db?: Firestore) {
  const h = await setup(db);
  const runtime = await configureRuntime(h);
  const options = {...h.options, runtimeBinding: runtime.binding};
  const publish = () => h.publisher.publish(h.scope, options);
  const publishReady = async () => {
    const result = await publish();
    assert.ok(result.kind === "published");
    return result;
  };
  return {...h, options, publish, publishReady, runtime};
}
