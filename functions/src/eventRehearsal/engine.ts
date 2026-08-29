import {
  EventRehearsalActorDocument,
  EventRehearsalDocument,
} from "../shared/generated/firestoreAdminTypes";
import {ControlEventRehearsalCallablePayload} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {ControlEventRehearsalSpatialCallablePayload} from
  "../shared/generated/controlEventRehearsalSpatialCallablePayload";
import {InjectEventRehearsalBehaviorCallablePayload} from
  "../shared/generated/injectEventRehearsalBehaviorCallablePayload";
import {SubmitEventRehearsalGuestActionCallablePayload} from
  "../shared/generated/submitEventRehearsalGuestActionCallablePayload";

export const REHEARSAL_MAX_ACTORS = 50;
export const REHEARSAL_MAX_ACTIONS = 500;
export const REHEARSAL_MAX_ACTIVE_SESSIONS = 5;
export const REHEARSAL_RETENTION_MILLIS = 24 * 60 * 60 * 1000;

/** Maps retries of one client action to one Firestore receipt document. */
export function eventRehearsalActionDocumentId(
  sessionId: string,
  namespace: string,
  clientActionId: string
): string {
  return `${sessionId}_${namespace}_${clientActionId}`;
}

export const rehearsalGuestMoments = [
  "welcome",
  "checkIn",
  "firstHello",
  "assignment",
  "rotation",
  "pause",
  "reveal",
  "afterglow",
  "complete",
] as const;

type ActorStatus = EventRehearsalActorDocument["status"];
type GuestMoment = EventRehearsalActorDocument["guestMoment"];
type Behavior = NonNullable<
  InjectEventRehearsalBehaviorCallablePayload["behavior"]
>;
type ControlAction = ControlEventRehearsalCallablePayload["action"];
type SpatialAction = ControlEventRehearsalSpatialCallablePayload["action"];
type GuestAction = SubmitEventRehearsalGuestActionCallablePayload["action"];

export interface RehearsalControlResult {
  status: EventRehearsalDocument["status"];
  activeStepIndex: number;
  virtualNowMillis: number;
}

export interface ScenarioCue {
  atMinute: number;
  behavior: Behavior;
  actorIndex: number;
}

const names = [
  "Aarav", "Aisha", "Arjun", "Diya", "Ishaan", "Kabir", "Maya", "Meera",
  "Naina", "Neel", "Rhea", "Rohan", "Sana", "Tara", "Veer", "Zoya",
] as const;

const personas: EventRehearsalActorDocument["persona"][] = [
  "firstTimer",
  "regular",
  "quiet",
  "connector",
  "external",
  "sparseProfile",
  "accessibilityNeeds",
];

const scenarioCues: Record<
  EventRehearsalDocument["scenarioId"],
  ScenarioCue[]
> = {
  smoothRun: [
    {atMinute: 1, behavior: "arrive", actorIndex: 0},
    {atMinute: 4, behavior: "arrive", actorIndex: 1},
  ],
  lateAndNoShow: [
    {atMinute: 10, behavior: "arriveLate", actorIndex: 2},
    {atMinute: 15, behavior: "markNoShow", actorIndex: 5},
  ],
  earlyExitAndReturn: [
    {atMinute: 18, behavior: "leaveEarly", actorIndex: 3},
    {atMinute: 32, behavior: "return", actorIndex: 3},
  ],
  rosterAndCapacity: [
    {atMinute: 12, behavior: "leaveEarly", actorIndex: 4},
    {atMinute: 13, behavior: "walkIn", actorIndex: 14},
  ],
  walkInAndAmbiguousClaim: [
    {atMinute: 3, behavior: "walkIn", actorIndex: 11},
    {atMinute: 5, behavior: "ambiguousClaim", actorIndex: 6},
  ],
  privacyAndKeepApart: [
    {atMinute: 7, behavior: "optOut", actorIndex: 7},
    {atMinute: 8, behavior: "keepApart", actorIndex: 8},
  ],
  lowConnectivity: [
    {atMinute: 6, behavior: "disconnect", actorIndex: 2},
    {atMinute: 16, behavior: "reconnect", actorIndex: 2},
  ],
  concurrentHosts: [],
  revealInterrupted: [
    {atMinute: 25, behavior: "disconnect", actorIndex: 1},
    {atMinute: 27, behavior: "reconnect", actorIndex: 1},
  ],
  externalProfiles: [
    {atMinute: 2, behavior: "ambiguousClaim", actorIndex: 10},
  ],
  accountabilitySweep: [
    {atMinute: 40, behavior: "leaveEarly", actorIndex: 2},
    {atMinute: 41, behavior: "disconnect", actorIndex: 4},
  ],
};

/** Creates deterministic, synthetic-only actors for a rehearsal. */
export function buildRehearsalActors(
  sessionId: string,
  actorCount: number,
  seed: number,
  now: FirebaseFirestore.Timestamp
): EventRehearsalActorDocument[] {
  const random = seededRandom(seed);
  const usedNames = new Map<string, number>();
  return Array.from({length: actorCount}, (_, index) => {
    const baseName = names[Math.floor(random() * names.length)] ?? names[0];
    const count = (usedNames.get(baseName) ?? 0) + 1;
    usedNames.set(baseName, count);
    return {
      sessionId,
      actorId: actorIdFor(index),
      displayName: count === 1 ? baseName : `${baseName} ${count}`,
      persona: personas[(index + seed) % personas.length] ?? "regular",
      status: "expected",
      guestMoment: "welcome",
      optedOut: false,
      keepApartActorIds: [],
      helpRequested: false,
      promptCompleted: false,
      layoutUnitId: `table-${Math.floor(index / 4) + 1}`,
      confirmedLayoutUnitId: null,
      lastActionAt: null,
      createdAt: now,
      updatedAt: now,
    };
  });
}

/** Resolves a valid lifecycle/clock transition without side effects. */
export function resolveRehearsalControl(
  session: EventRehearsalDocument,
  action: ControlAction,
  minutes = 5
): RehearsalControlResult {
  const currentMillis = session.virtualNow.toMillis();
  switch (action) {
  case "markReady":
    assertStatus(session.status, ["draft", "ready"], action);
    return result("ready", session.activeStepIndex, currentMillis);
  case "start":
    assertStatus(session.status, ["draft", "ready"], action);
    return result(
      "running",
      Math.max(1, session.activeStepIndex),
      currentMillis
    );
  case "pause":
    assertStatus(session.status, ["running"], action);
    return result("paused", session.activeStepIndex, currentMillis);
  case "resume":
    assertStatus(session.status, ["paused"], action);
    return result("running", session.activeStepIndex, currentMillis);
  case "advance":
    assertStatus(session.status, ["running", "paused"], action);
    return result(
      session.status,
      Math.min(rehearsalGuestMoments.length - 1, session.activeStepIndex + 1),
      currentMillis
    );
  case "previous":
    assertStatus(session.status, ["running", "paused"], action);
    return result(
      session.status,
      Math.max(0, session.activeStepIndex - 1),
      currentMillis
    );
  case "advanceClock":
    assertStatus(session.status, ["running", "paused"], action);
    return result(
      session.status,
      session.activeStepIndex,
      currentMillis + minutes * 60000
    );
  case "complete":
    assertStatus(session.status, ["running", "paused"], action);
    return result("complete", rehearsalGuestMoments.length - 1, currentMillis);
  }
}

/** Returns cues crossed by a virtual-clock change, exactly once per window. */
export function cuesBetween(
  scenarioId: EventRehearsalDocument["scenarioId"],
  startMillis: number,
  fromMillis: number,
  toMillis: number
): ScenarioCue[] {
  const fromMinute = Math.floor((fromMillis - startMillis) / 60000);
  const toMinute = Math.floor((toMillis - startMillis) / 60000);
  return scenarioCues[scenarioId].filter(
    (cue) => cue.atMinute > fromMinute && cue.atMinute <= toMinute
  );
}

/** Applies a synthetic behavior to an actor while retaining safety state. */
export function applyRehearsalBehavior(
  actor: EventRehearsalActorDocument,
  behavior: Behavior,
  otherActorIds: string[],
  now: FirebaseFirestore.Timestamp
): EventRehearsalActorDocument {
  const patch: Partial<EventRehearsalActorDocument> = {};
  switch (behavior) {
  case "arrive":
    patch.status = "present";
    patch.guestMoment = "checkIn";
    patch.confirmedLayoutUnitId = actor.layoutUnitId;
    break;
  case "arriveLate":
    patch.status = "late";
    patch.guestMoment = "assignment";
    break;
  case "markNoShow":
    patch.status = "noShow";
    break;
  case "leaveEarly":
    patch.status = "departed";
    break;
  case "return":
    patch.status = "returned";
    patch.confirmedLayoutUnitId = actor.layoutUnitId;
    break;
  case "walkIn":
    patch.status = "walkIn";
    patch.persona = "walkIn";
    patch.guestMoment = "checkIn";
    break;
  case "ambiguousClaim":
    patch.status = "ambiguousClaim";
    break;
  case "resolveClaim":
    patch.status = "present";
    patch.confirmedLayoutUnitId = actor.layoutUnitId;
    break;
  case "optOut":
    patch.optedOut = true;
    break;
  case "optIn":
    patch.optedOut = false;
    break;
  case "keepApart": {
    const target = otherActorIds.find((id) => id !== actor.actorId);
    patch.keepApartActorIds = target ? [target] : [];
    break;
  }
  case "disconnect":
    patch.status = "disconnected";
    break;
  case "reconnect":
    patch.status = actor.status === "disconnected" ? "present" : actor.status;
    break;
  }
  return {...actor, ...patch, lastActionAt: now, updatedAt: now};
}

/** Applies a bounded Room move without escaping the synthetic actor domain. */
export function applyRehearsalSpatialAction(
  actor: EventRehearsalActorDocument,
  action: SpatialAction,
  destinationUnitId: string | null,
  scope: ControlEventRehearsalSpatialCallablePayload["scope"],
  tableCount: number,
  now: FirebaseFirestore.Timestamp
): EventRehearsalActorDocument {
  const validUnitIds = new Set(
    Array.from({length: tableCount}, (_, index) => `table-${index + 1}`)
  );
  if (action === "reassign") {
    if (!destinationUnitId || !validUnitIds.has(destinationUnitId)) {
      throw new Error("Choose a valid rehearsal table.");
    }
    if (!scope) throw new Error("Choose how long this placement should last.");
    return {
      ...actor,
      layoutUnitId: destinationUnitId,
      confirmedLayoutUnitId: scope === "pinned" ? destinationUnitId : null,
      lastActionAt: now,
      updatedAt: now,
    };
  }
  if (!actor.layoutUnitId || !validUnitIds.has(actor.layoutUnitId)) {
    throw new Error("Place this practice guest before changing confirmation.");
  }
  return {
    ...actor,
    confirmedLayoutUnitId: action === "confirmPosition" ?
      actor.layoutUnitId : null,
    lastActionAt: now,
    updatedAt: now,
  };
}

/** Advances guest presentation without overriding attendance exceptions. */
export function actorAtMoment(
  actor: EventRehearsalActorDocument,
  moment: GuestMoment,
  now: FirebaseFirestore.Timestamp
): EventRehearsalActorDocument {
  return {...actor, guestMoment: moment, updatedAt: now};
}

/** Applies one anonymous guest action to its synthetic actor only. */
export function applyRehearsalGuestAction(
  actor: EventRehearsalActorDocument,
  action: GuestAction,
  now: FirebaseFirestore.Timestamp
): EventRehearsalActorDocument {
  switch (action) {
  case "checkIn":
  case "confirmArrival":
    return applyRehearsalBehavior(actor, "arrive", [], now);
  case "optOut":
    return applyRehearsalBehavior(actor, "optOut", [], now);
  case "optIn":
    return applyRehearsalBehavior(actor, "optIn", [], now);
  case "askForHelp":
    return {...actor, helpRequested: true, lastActionAt: now, updatedAt: now};
  case "completePrompt":
    return {...actor, promptCompleted: true, lastActionAt: now, updatedAt: now};
  }
}

export function momentForStep(activeStepIndex: number): GuestMoment {
  return rehearsalGuestMoments[
    Math.max(0, Math.min(rehearsalGuestMoments.length - 1, activeStepIndex))
  ] ?? "welcome";
}

export function actorIdFor(index: number): string {
  return `actor-${String(index + 1).padStart(2, "0")}`;
}

function result(
  status: EventRehearsalDocument["status"],
  activeStepIndex: number,
  virtualNowMillis: number
): RehearsalControlResult {
  return {status, activeStepIndex, virtualNowMillis};
}

function assertStatus(
  status: EventRehearsalDocument["status"],
  allowed: EventRehearsalDocument["status"][],
  action: ControlAction
): void {
  if (!allowed.includes(status)) {
    throw new Error(`Cannot ${action} while rehearsal is ${status}.`);
  }
}

function seededRandom(seed: number): () => number {
  let state = seed >>> 0;
  return () => {
    state = (Math.imul(1664525, state) + 1013904223) >>> 0;
    return state / 0x100000000;
  };
}

export function statusAfterBehavior(behavior: Behavior): ActorStatus | null {
  const statuses: Partial<Record<Behavior, ActorStatus>> = {
    arrive: "present",
    arriveLate: "late",
    markNoShow: "noShow",
    leaveEarly: "departed",
    return: "returned",
    walkIn: "walkIn",
    ambiguousClaim: "ambiguousClaim",
    resolveClaim: "present",
    disconnect: "disconnected",
  };
  return statuses[behavior] ?? null;
}
