import type {
  EventRehearsalGuestAction,
  EventRehearsalGuestBootstrap,
} from "../../firebase";

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
