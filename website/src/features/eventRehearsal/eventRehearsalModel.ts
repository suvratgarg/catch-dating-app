import type {
  EventRehearsalGuestAction,
  EventRehearsalGuestBootstrap,
} from "../../firebase";

export type RehearsalInstruction = NonNullable<
  EventRehearsalGuestBootstrap["actor"]["assistanceMessage"]>;
export type RehearsalReply = Pick<RehearsalInstruction,
  "messageId" | "intentRevision"> & {choiceId: string};
export interface RehearsalReplyState {
  fresh: boolean;
  pendingChoice: string | null;
  retryChoice: string | null;
  notice: string;
}

export function canReplyToRehearsal(bootstrap: EventRehearsalGuestBootstrap) {
  const message = bootstrap.actor.assistanceMessage;
  return Boolean(message?.canRespond && message.lifecycle === "active" &&
    message.responseChoiceId === null &&
    bootstrap.session.virtualNowMillis < message.expiresAt &&
    ["running", "paused"].includes(bootstrap.session.status));
}

/** A confirmed instruction cannot regress when an older poll arrives. */
export function reconcileRehearsalProjection(
  previous: EventRehearsalGuestBootstrap | undefined,
  next: EventRehearsalGuestBootstrap
): EventRehearsalGuestBootstrap {
  const before = previous?.actor.assistanceMessage;
  const after = next.actor.assistanceMessage;
  if (previous && before && after && previous.slotToken === next.slotToken &&
      previous.actor.actorId === next.actor.actorId &&
      before.messageId === after.messageId && before.intentRevision === after.intentRevision &&
      previous.session.runtimeRevision > next.session.runtimeRevision) return previous;
  // Reset has a new message identity (or none) and may restart at revision 0.
  return next;
}

export function availableEventRehearsalGuestActions(
  bootstrap: EventRehearsalGuestBootstrap
): EventRehearsalGuestAction[] {
  if (bootstrap.session.status !== "running" &&
      bootstrap.session.status !== "paused") {
    return [];
  }
  const actions: EventRehearsalGuestAction[] = [];
  switch (bootstrap.actor.status) {
    case "expected":
    case "noShow":
    case "ambiguousClaim":
      actions.push("checkIn");
      break;
    case "late":
    case "departed":
    case "disconnected":
      actions.push("confirmArrival");
      break;
    case "present":
    case "returned":
    case "walkIn":
      break;
  }
  actions.push(bootstrap.actor.optedOut ? "optIn" : "optOut");
  if (!bootstrap.actor.helpRequested) actions.push("askForHelp");
  if (!bootstrap.actor.promptCompleted) actions.push("completePrompt");
  return actions;
}

export function eventRehearsalGuestActionClientId(
  clientInstanceId: string,
  nowMicros: number
): string {
  return `guest_${clientInstanceId.slice(0, 18)}_${nowMicros.toString(36)}`;
}
