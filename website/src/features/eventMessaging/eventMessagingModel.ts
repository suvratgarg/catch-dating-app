import type {EventAssistanceSmsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventAssistanceSmsPreferenceCallableResponse";

export type SmsPreferenceView = Response["view"];
export type EventMessagingState =
  | {kind: "hidden" | "loading" | "error"}
  | {kind: "ready"; view: SmsPreferenceView; pending: boolean;
      uncertain: boolean; notice: string};

export function newerSmsPreference(previous: Response | undefined,
  incoming: Response): Response {
  if (!previous || previous.view.eventId !== incoming.view.eventId ||
      previous.view.attendeeId !== incoming.view.attendeeId) return incoming;
  const oldRevision = previous.view.revision ?? 0;
  const nextRevision = incoming.view.revision ?? 0;
  if (nextRevision !== oldRevision) return nextRevision > oldRevision ? incoming : previous;
  return incoming.view.serverTime >= previous.view.serverTime ? incoming : previous;
}
