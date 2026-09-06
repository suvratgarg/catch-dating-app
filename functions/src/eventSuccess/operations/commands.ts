import type {
  EventAssistanceCommand,
} from "../../shared/generated/eventAssistanceCommand";
import {
  validateEventAssistanceCommand,
} from "../../shared/generated/validators/eventAssistanceCommand";

export type CommandKind = EventAssistanceCommand["kind"];
export type Authority =
  | "guestSelf"
  | "checkIn"
  | "groupLead"
  | "eventLead"
  | "authorizedSafetyOperator"
  | "systemWithinPolicy";
export const COMMAND_AUTHORITY = {
  confirmDeparture: ["groupLead", "eventLead"],
  setJoinIntent: ["guestSelf"],
  // Guest proof remains a separate check-in port.
  checkInGuest: ["checkIn", "eventLead"],
  publishGuidance: ["systemWithinPolicy"],
  sendOperationalMessage: ["systemWithinPolicy"],
  openHostCase: ["systemWithinPolicy"],
  setParticipation: ["guestSelf", "eventLead"],
  proposeAllocation: ["systemWithinPolicy", "eventLead"],
  publishAllocation: ["eventLead"],
  confirmPlacement: ["eventLead"],
  changeResource: ["eventLead"],
  transferGroup: ["groupLead", "eventLead"],
  recordCheckpoint: ["groupLead", "eventLead"],
  changeProgramme: ["eventLead"],
  recordOutcome: ["eventLead"],
  changeRoute: ["eventLead"],
  resolveAccountability: ["groupLead", "eventLead"],
  resolveClaim: ["checkIn", "eventLead"],
  admitGuest: ["eventLead"],
  assignResponsibility: ["eventLead"],
  resolveAssistance: ["groupLead", "eventLead"],
  reconcileAttendance: ["checkIn", "eventLead"],
  requestRequiredData: ["systemWithinPolicy"],
  reconcileRoster: ["systemWithinPolicy", "eventLead"],
  reconcileFinance: ["systemWithinPolicy", "eventLead"],
  repairDelivery: ["systemWithinPolicy", "eventLead"],
  resumeOperation: ["systemWithinPolicy", "eventLead"],
  completeEvent: ["eventLead"],
  controlUnitProgress: ["groupLead", "eventLead"],
  controlReveal: ["eventLead"],
  applyOverride: ["eventLead"],
  setLocationSharing: ["groupLead", "eventLead"],
  requestCheckpointReport: ["systemWithinPolicy"],
  recordNoShow: ["eventLead"],
  routeRestrictedCase: ["systemWithinPolicy", "authorizedSafetyOperator"],
  resolveRestrictedCase: ["authorizedSafetyOperator"],
} as const satisfies {[K in CommandKind]: readonly Authority[]};

/**
 * Structural and context checks; domain ports must re-read ownership and
 * grants.
 */
export function assertCommandContext(
  command: EventAssistanceCommand,
  expected: EventAssistanceCommand["context"]
): void {
  if (!validateEventAssistanceCommand(command)) {
    throw new Error("Invalid assistance command");
  }
  const context = command.context;
  if (context.mode !== expected.mode) {
    throw new Error("Execution mode mismatch");
  }
  if (context.mode === "live" && expected.mode === "live") {
    if (
      context.eventId !== expected.eventId ||
      context.organizerId !== expected.organizerId ||
      command.eventId !== expected.eventId
    ) {
      throw new Error("Event or organizer context mismatch");
    }
  } else if (context.mode === "rehearsal" && expected.mode === "rehearsal") {
    if (
      context.rehearsalId !== expected.rehearsalId ||
      context.virtualEventId !== expected.virtualEventId ||
      context.clockId !== expected.clockId ||
      command.eventId !== expected.virtualEventId
    ) {
      throw new Error("Rehearsal context mismatch");
    }
  }
  if (
    "scope" in command.payload &&
    command.payload.scope.eventId !== command.eventId
  ) {
    throw new Error("Command subject belongs to another event");
  }
}

/**
 * A role label is insufficient: the caller supplies freshly resolved scoped
 * grants.
 */
export function assertCommandRole(
  command: EventAssistanceCommand,
  roles: readonly Authority[]
): void {
  const permitted: readonly Authority[] = COMMAND_AUTHORITY[command.kind];
  if (!roles.some((role) => permitted.includes(role))) {
    throw new Error("Command authority denied");
  }
}
