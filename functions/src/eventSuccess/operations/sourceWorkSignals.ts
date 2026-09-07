import {operationContentHash} from "../../operations/durableActions";
import {guestIdentity} from "./guestRecords";
import type {SourceWork, SourceWorkInput} from "./sourceWorkRecords";
import type {AssistanceSourceWorkStore} from "./sourceWorkStore";

type Collection = SourceWork["source"]["collection"];
type Scope = SourceWork["scope"];
type Snapshot = {value: Record<string, unknown>; generation: unknown} | null;
export interface AssistanceSourceChange {
  source: SourceWorkInput["source"];
  before: Snapshot;
  after: Snapshot;
}

/** Trigger payloads request re-evaluation and supply no domain authority. */
export function sourceWakeScopes(change: AssistanceSourceChange): Scope[] {
  const before = projection(change.source.collection, change.before);
  const after = projection(change.source.collection, change.after);
  if (operationContentHash(before) === operationContentHash(after)) return [];
  const scopes = new Map<string, Scope>();
  for (const snapshot of [change.before, change.after]) {
    if (!snapshot) continue;
    const scope = scopeFor(change.source.collection, change.source.documentId,
      snapshot.value);
    if (scope) scopes.set(operationContentHash(scope), scope);
  }
  return [...scopes.values()];
}

export async function enqueueAssistanceSourceChange(
  store: Pick<AssistanceSourceWorkStore, "hasTargets" | "enqueue">,
  change: AssistanceSourceChange) {
  const queued: string[] = [];
  for (const scope of sourceWakeScopes(change)) {
    // A newly enrolled work item evaluates current facts on its first run,
    // including facts changed after this no-target check.
    if (!await store.hasTargets(scope)) continue;
    const work = await store.enqueue({scope, source: change.source});
    queued.push(work.item.workItemId);
  }
  return queued;
}

function scopeFor(collection: Collection, documentId: string,
  value: Record<string, unknown>): Scope | null {
  let context: unknown = value.context;
  let attendeeId: unknown = value.attendeeId ?? null;
  switch (collection) {
  case "events":
    context = {mode: "live", eventId: documentId,
      organizerId: value.organizerId ?? value.clubId};
    attendeeId = null;
    break;
  case "eventAttendees":
  case "eventSuccessPlans":
    context = {mode: "live", eventId: value.eventId ?? documentId,
      organizerId: value.organizerId ?? value.clubId};
    attendeeId = collection === "eventAttendees" ? documentId : null;
    break;
  case "eventAssistanceSettings":
  case "eventAssistanceRuntimeConfigs":
    if (value.workflowKind !== "lateJoin") return null;
    attendeeId = null;
    break;
  case "eventAssistanceGroupProgress": attendeeId = null; break;
  case "eventAssistanceGuests":
  case "eventAssistanceMemberships": break;
  case "eventAssistanceMessages": {
    const intent = object(value.intent);
    if (object(intent.workflow).kind !== "lateJoin") return null;
    context = intent.context;
    attendeeId = intent.attendeeId;
    break;
  }
  default: return unhandled(collection);
  }
  const c = object(context);
  if (c.mode !== "live" || typeof c.eventId !== "string" ||
      typeof c.organizerId !== "string" ||
      (attendeeId !== null && typeof attendeeId !== "string")) return null;
  const scope: Scope = {context: {mode: "live", eventId: c.eventId,
    organizerId: c.organizerId}, attendeeId};
  // Malformed identity cannot become a query against an unrelated scope.
  guestIdentity(scope.context, scope.attendeeId ?? "scope");
  return scope;
}

function projection(collection: Collection, snapshot: Snapshot) {
  if (!snapshot) return null;
  const value = snapshot.value;
  let fields: string[];
  switch (collection) {
  case "events": fields = ["organizerId", "clubId", "status", "eventFormat",
    "startTime", "endTime", "meetingLocation", "itinerary", "eventPolicy",
    "constraints", "capacityLimit", "priceInPaise", "currency",
    "publicRegistrationEnabled"]; break;
  case "eventAttendees": fields = ["eventId", "organizerId", "clubId",
    "status", "attendanceRevision", "createdAt", "phoneE164", "linkedUid"];
    break;
  case "eventSuccessPlans": fields = ["eventId", "organizerId", "clubId",
    "status"]; break;
  case "eventAssistanceGuests":
  case "eventAssistanceSettings":
  case "eventAssistanceGroupProgress":
  case "eventAssistanceMemberships":
  case "eventAssistanceMessages": fields = Object.keys(value); break;
  case "eventAssistanceRuntimeConfigs": fields = Object.keys(value); break;
  default: return unhandled(collection);
  }
  // SDK timestamps are data here, normalized for comparison only. The source
  // reader still uses precise canonical timestamps at the execution boundary.
  return JSON.parse(JSON.stringify([snapshot.generation,
    Object.fromEntries(fields.map((key) => [key, value[key] ?? null]))]));
}

function object(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> : {};
}
function unhandled(value: never): never {
  void value;
  throw new Error("Unhandled assistance source collection");
}
