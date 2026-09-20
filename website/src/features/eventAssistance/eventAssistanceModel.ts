import type {EventAssistanceGuestViewCallableResponse as GuestView} from "../../shared/contracts/generated/eventAssistanceGuestViewCallableResponse";
import type {GetEventAssistanceGuestViewCallablePayload as Credential} from "../../shared/contracts/generated/getEventAssistanceGuestViewCallablePayload";

export type {GuestView, Credential};
export type ReadyView = Extract<GuestView, {status: "ready"}>;
export interface GuestSnapshot {
  view: GuestView;
  freshUntil: number;
}

/** Route-owned fragment. Never accept a secret from query parameters. */
export function assistanceCredential(linkId: string, hash: string): Credential | null {
  const secret = hash.slice(1);
  return /^[a-f0-9]{32}$/.test(linkId) && /^[A-Za-z0-9_-]{43}$/.test(secret)
    ? {linkId, secret} : null;
}

/** Subtract the entire request duration, conservatively, from server validity. */
export function guestSnapshot(view: GuestView, requestStarted: number): GuestSnapshot {
  return {view, freshUntil: view.status === "ready"
    ? requestStarted + Math.min(30_000, Math.max(0, view.expiresAt - view.serverTime))
    : requestStarted};
}

/** A delayed read must not erase a response already confirmed by the server. */
export function newerGuestSnapshot(previous: GuestSnapshot | undefined, next: GuestSnapshot) {
  if (!previous) return next;
  if (previous.view.serverTime > next.view.serverTime) return previous;
  const left = previous.view;
  const right = next.view;
  if (left.status === "ready" && right.status === "ready" &&
      left.intentId === right.intentId && left.intentRevision === right.intentRevision &&
      left.response && !right.response) return previous;
  return next;
}

export type AssistanceScreen =
  | {kind: "loading"}
  | {kind: "unavailable"; reason: "invalid" | "network" | Extract<GuestView, {status: "unavailable"}>["reason"]}
  | {kind: "ready"; view: ReadyView; fresh: boolean; pending: boolean;
      pendingChoice: string | null; retryChoice: string | null; notice: string};
