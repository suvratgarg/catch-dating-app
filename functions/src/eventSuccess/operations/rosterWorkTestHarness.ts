import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import type {Firestore} from "firebase-admin/firestore";
import {guestCollections, guestIdentity, parseGuest} from "./guestRecords";
import {liveWorkIds} from "./liveWorkRecords";
import {LiveAssistanceWorkRunner} from "./liveWorkRunner";
import {AssistanceRosterWorkStore} from "./rosterWorkStore";
import {AssistanceSourceWorkStore} from "./sourceWorkStore";
import {setup} from "./liveLateJoinTestHarness";
import {configureRuntime} from "./runtimeConfigTestHarness";
import type {RosterWorkInput} from "./rosterWorkRecords";

export async function rosterHarness(count = 1, db?: Firestore) {
  const h = await setup(db);
  const runtime = await configureRuntime(h);
  const roster = new AssistanceRosterWorkStore(h.db, () => h.clock.now);
  const runner = new LiveAssistanceWorkRunner(h.db, () => h.clock.now);
  const source = new AssistanceSourceWorkStore(h.db, () => h.clock.now);
  const ids = [h.scope.attendeeId];
  const row = (await h.read(h.attendeePath))!;
  for (let i = 1; i < count; i++) {
    const id = (i % 2 ? "B" : "a") + i.toString().padStart(3, "0") +
      "-" + h.context.eventId;
    ids.push(id);
    await h.write("eventAttendees/" + id, row);
  }
  const input: Omit<RosterWorkInput, "runtimeBinding"> = {
    scope: {context: h.context, attendeeId: null},
    source: {collection: "eventAssistanceRuntimeConfigs",
      documentId: runtime.binding.runtimeId, eventId: randomUUID(),
      occurredAt: h.clock.now}};
  const enqueue = async (request = input, store = roster) => {
    const result = await store.enqueueCurrent(request);
    assert.ok(result.kind === "queued");
    return result;
  };
  const scan = async (id: string, store = roster) => {
    for (let i = 0; i < 20; i++) {
      await store.process(id);
      const record = await store.get(id);
      if (record.payload.checkpoint.phase !== "scan") return record;
    }
    throw new Error("Test roster did not complete its bounded scan");
  };
  const currentWork = async (attendeeId: string) => {
    const guest = parseGuest(await h.read(guestCollections.guests + "/" +
      guestIdentity(h.context, attendeeId)));
    return runner.store.get(liveWorkIds({context: h.context, attendeeId,
      episodeId: guest.episodeId}).workItemId);
  };
  const pause = async () => {
    const view = (await runtime.store.get("host-1", {context: h.context})).view;
    return runtime.store.set("host-1", {context: h.context,
      requestId: randomUUID(), expectedRevision: view.revision,
      expectedSourceHash: view.sourceHash, command: {kind: "pause"}});
  };
  return {...h, runtime, roster, runner, source, ids, row, input, enqueue,
    scan, currentWork, pause};
}
