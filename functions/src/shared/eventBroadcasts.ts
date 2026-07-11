import {createHash} from "node:crypto";

/** Namespaces a client idempotency key by actor and event. */
export function eventBroadcastId(params: {
  actorUid: string;
  eventId: string;
  requestId: string;
}): string {
  const digest = createHash("sha256")
    .update(JSON.stringify([
      "eventBroadcast:v1",
      params.actorUid,
      params.eventId,
      params.requestId,
    ]))
    .digest("hex");
  return `eventBroadcast_${digest}`;
}

/** Hides recipient ids inside the delivery-evidence map. */
export function eventBroadcastDeliveryKey(uid: string): string {
  return createHash("sha256")
    .update(JSON.stringify(["eventBroadcastDelivery:v1", uid]))
    .digest("hex");
}
