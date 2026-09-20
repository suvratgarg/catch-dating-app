import type {MessageRecord} from "./messageOutbox";

/** Pending submissions outrank failures on other routes. */
export function hostDeliveryStatus(message: MessageRecord):
  MessageRecord["attempts"][number]["state"]["kind"] |
    "conflictingEvidence" | "notSubmitted" {
  if (message.deliveryConflict) return "conflictingEvidence";
  const states = message.attempts.map((a) => a.state.kind);
  for (const state of ["read", "delivered", "unknown", "accepted",
    "reserved"] as const) {
    if (states.includes(state)) return state;
  }
  return message.attempts.at(-1)?.state.kind ?? "notSubmitted";
}

/** Source owners supply relevance separately from delivery evidence. */
export function manualDeliveryActions(message: MessageRecord,
  relevant: boolean, ownerCurrent: boolean): "manualHandoff"[] {
  const resolved = message.response !== null ||
    message.attempts.some((a) =>
      a.state.kind === "read" || a.state.kind === "delivered");
  return relevant && !resolved && !ownerCurrent ? ["manualHandoff"] : [];
}
