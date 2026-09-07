import {getFirestore, Firestore} from "firebase-admin/firestore";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions";
import {AssistanceSourceWorkStore} from "./sourceWorkStore";
import {AssistanceRosterWorkStore} from "./rosterWorkStore";
import {AssistanceDeliveryWorkStore} from "./deliveryWorkStore";
import {LiveAssistanceWorkRunner} from "./liveWorkRunner";
import {enqueueAssistanceSourceChange} from "./sourceWorkSignals";
import type {SourceWork} from "./sourceWorkRecords";

type Collection = SourceWork["source"]["collection"];
type WorkPorts = {
  delivery: Pick<AssistanceDeliveryWorkStore, "process" | "listDue">;
  roster: Pick<AssistanceRosterWorkStore, "process" | "listDue">;
  source: Pick<AssistanceSourceWorkStore, "process" | "listDue">;
  guest: Pick<LiveAssistanceWorkRunner, "process"> & {
    store: Pick<LiveAssistanceWorkRunner["store"], "listDue">;
  };
};

function ports(db: Firestore, clock: () => number): WorkPorts {
  return {roster: new AssistanceRosterWorkStore(db, clock),
    delivery: new AssistanceDeliveryWorkStore(db, clock),
    source: new AssistanceSourceWorkStore(db, clock),
    guest: new LiveAssistanceWorkRunner(db, clock)};
}

export async function processChangedAssistanceWork(workItemId: string,
  value: unknown, worker: WorkPorts, now: number) {
  if (!value || typeof value !== "object") return;
  const payload = (value as {normalizedPayload?: {
    kind?: string; checkpoint?: {dueAt?: number | null};
  }}).normalizedPayload;
  const dueAt = payload?.checkpoint?.dueAt;
  if (typeof dueAt !== "number" || !Number.isSafeInteger(dueAt) ||
      dueAt < 0 || dueAt > now) return;
  let busy: boolean;
  if (payload?.kind === "liveMessageDelivery") {
    busy = (await worker.delivery.process(workItemId)).kind === "busy";
  } else if (payload?.kind === "liveRosterEnrollment") {
    busy = (await worker.roster.process(workItemId)).kind === "busy";
  } else if (payload?.kind === "liveSourceWake") {
    busy = (await worker.source.process(workItemId)).kind === "busy";
  } else if (payload?.kind === "liveLateJoin") {
    busy = (await worker.guest.process(workItemId,
      {kind: "evaluate"})).kind === "busy";
  } else return;
  if (busy) throw new AssistanceWorkBusy();
}

/** Scheduled recovery evaluates saved due work, never an inferred event. */
export async function evaluateDueAssistanceWork(worker: WorkPorts) {
  const [rosters, sources, guests, deliveries] = await Promise.all([
    worker.roster.listDue(5), worker.source.listDue(10),
    worker.guest.store.listDue(30), worker.delivery.listDue(10)]);
  const failed: string[] = [];
  let busy = 0;
  for (const [kind, id] of [
    ...rosters.map((id) => ["roster", id] as const),
    ...sources.map((id) => ["source", id] as const),
    ...guests.map((item) => ["guest", item.workItemId] as const),
    ...deliveries.map((id) => ["delivery", id] as const),
  ]) {
    try {
      const result = kind === "roster" ? await worker.roster.process(id) :
        kind === "source" ? await worker.source.process(id) :
          kind === "delivery" ? await worker.delivery.process(id) :
            await worker.guest.process(id, {kind: "evaluate"});
      if (result.kind === "busy") busy += 1;
    } catch {
      failed.push(id);
    }
  }
  if (failed.length) {
    logger.error("Event assistance due work needs retry",
      {workItemIds: failed});
    throw new Error("Some event assistance work could not advance");
  }
  return {rosterItems: rosters.length, sourceItems: sources.length,
    guestItems: guests.length, deliveryItems: deliveries.length, busy};
}

function sourceTrigger(collection: Collection) {
  return onDocumentWritten({document: collection + "/{documentId}",
    retry: true, timeoutSeconds: 60, maxInstances: 5}, async (event) => {
    if (!event.data) return;
    const snapshot = (side: "before" | "after") => {
      const s = event.data![side];
      return s.exists ? {value: s.data()!, generation: s.createTime} : null;
    };
    await enqueueAssistanceSourceChange(
      new AssistanceSourceWorkStore(getFirestore()), {
        source: {eventId: event.id, collection,
          documentId: event.params.documentId,
          occurredAt: Date.parse(event.time)},
        before: snapshot("before"), after: snapshot("after"),
      }, new AssistanceRosterWorkStore(getFirestore()));
    if (collection === "eventAssistanceMessages" && event.data.after.exists) {
      const result = await new AssistanceDeliveryWorkStore(getFirestore())
        .processMessage(event.params.documentId);
      if (result.kind === "busy") throw new AssistanceWorkBusy();
    }
  });
}

export const onAssistanceEventChanged = sourceTrigger("events");
export const onAssistanceRosterChanged = sourceTrigger("eventAttendees");
export const onAssistanceRuntimeChanged = sourceTrigger("eventSuccessPlans");
export const onAssistanceGuestChanged = sourceTrigger("eventAssistanceGuests");
export const onAssistanceSettingChanged = sourceTrigger(
  "eventAssistanceSettings");
export const onAssistanceRuntimeConfigChanged = sourceTrigger(
  "eventAssistanceRuntimeConfigs");
export const onAssistanceProgressChanged = sourceTrigger(
  "eventAssistanceGroupProgress");
export const onAssistanceMembershipChanged = sourceTrigger(
  "eventAssistanceMemberships");
export const onAssistanceMessageChanged = sourceTrigger(
  "eventAssistanceMessages");

export const onAssistanceWorkChanged = onDocumentWritten({
  document: "operationWorkItems/{workItemId}", retry: true,
  timeoutSeconds: 120, maxInstances: 5,
}, async (event) => {
  const value = event.data?.after.data();
  if (!value) return;
  await processChangedAssistanceWork(event.params.workItemId, value,
    ports(getFirestore(), Date.now), Date.now());
});

export const evaluateDueEventAssistanceWork = onSchedule({
  schedule: "every 1 minutes", timeZone: "UTC",
  timeoutSeconds: 540, maxInstances: 1,
}, async () => {
  await evaluateDueAssistanceWork(ports(getFirestore(), Date.now));
});

export class AssistanceWorkBusy extends Error {
  constructor() {
    super("Event assistance work is held by another live worker");
    this.name = "AssistanceWorkBusy";
  }
}
