import type {ReadOutboxFacts, FirestoreMessageOutbox} from
  "./firestoreMessageOutbox";
import type {PermitResult} from "./messageOutbox";
import type {EventServiceRouteId} from "./messagingPolicy";

export type ChannelUnavailableReason =
  "senderUnavailable" | "credentialUnavailable";
export type ChannelDispatchResult<Outcome> =
  | {kind: "withheld"; reason: "permitExpired" |
      Extract<PermitResult, {kind: "withheld"}>["reason"]}
  | {kind: "submitted"; outcome: Outcome};

/** In-memory credential snapshot; never a persisted send authority. */
export type PreparedMessageChannel<Outcome> = {
  kind: "ready";
  routeId: EventServiceRouteId;
  readFacts: ReadOutboxFacts;
  dispatchReserved(outbox: FirestoreMessageOutbox, messageId: string,
    attemptId: string): Promise<ChannelDispatchResult<Outcome>>;
} | {kind: "unavailable"; reason: ChannelUnavailableReason};
