import type {ListEventRcsPreferencesCallableResponse as Options} from "../../shared/contracts/generated/listEventRcsPreferencesOutput";

export type PreferenceChannel = "rcs" | "whatsapp";
export type SenderPreferenceScope = {eventId: string; attendeeId: string; senderId: string};
export interface SenderPreferenceView extends SenderPreferenceScope {
  serverTime: number; revision: number | null;
  preference: "notSet" | "enabled" | "disabled" | "expired";
  canEnable: boolean;
}
export interface SenderPreferenceResponse {
  outcome: "read" | "applied" | "replayed" | "conflict";
  view: SenderPreferenceView;
}
export interface SenderPreferenceSubmission extends SenderPreferenceScope {
  requestId: string; expectedRevision: number | null;
  decision: {kind: "grant"} | {kind: "revoke"};
}
export type SenderPreferenceState<View extends SenderPreferenceView> =
  {kind: "hidden" | "loading" | "error"} | {kind: "ready"; view: View;
    pending: boolean; uncertain: boolean; notice: string; earlier: boolean};

/** Each channel owns validation, consent evidence and its exact wire payload. */
export interface SenderPreferencePort<Response extends SenderPreferenceResponse,
  Submission extends SenderPreferenceSubmission> {
  channel: PreferenceChannel;
  copy: {changed: string; savedOn: string; savedOff: string; rejected: string; uncertain: string};
  list: (scope: Omit<SenderPreferenceScope, "senderId"> & {cursor: string | null}) => Promise<Options>;
  read: (scope: SenderPreferenceScope) => Promise<Response>;
  write: (submission: Submission) => Promise<Response>;
  reviewKey: (view: Response["view"]) => string;
  submission: (scope: SenderPreferenceScope, requestId: string,
    view: Response["view"], decision: "grant" | "revoke") => Submission;
}

export function newerSenderPreference<Response extends SenderPreferenceResponse>(
  previous: Response | undefined, next: Response): Response {
  if (!previous) return next;
  const old = previous.view; const fresh = next.view;
  if ((old.revision ?? 0) > (fresh.revision ?? 0) ||
      old.revision === fresh.revision && old.serverTime > fresh.serverTime) return previous;
  return next;
}

export interface SenderPreferenceNavigation {
  earlier: boolean; showEarlier: boolean; showCurrent: boolean;
  showPrevious: boolean; showNext: boolean; busy: boolean;
}
export interface SenderPreferenceControls {
  navigation: SenderPreferenceNavigation;
  enable: () => void; disable: () => void; retry: () => void; refresh: () => void;
  next: () => Promise<void>; previous: () => void; current: () => void;
  manageEarlier: () => void;
}
