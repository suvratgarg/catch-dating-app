import type {Response} from "express";
import {getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {onRequest, Request} from "firebase-functions/v2/https";
import {createRcsWebhookIngress} from "./rcsWebhookIngress";
import {RcsWebhookKeyStore, validRcsEndpointId} from "./rcsWebhookKeyStore";
import {RcsCallbackStore} from "./rcsCallbackStore";
import {eventRcsWebhookEnabled} from "./rcsLiveConfig";

interface Dependencies {
  enabled: () => boolean;
  keys: Pick<RcsWebhookKeyStore, "access">;
  inbox: Pick<RcsCallbackStore, "enqueue">;
  clock: () => number;
  failed: () => void;
}
let keyStore: RcsWebhookKeyStore | undefined;
const defaults: Dependencies = {
  enabled: () => eventRcsWebhookEnabled.value(),
  keys: {access: (id) => (keyStore ??= new RcsWebhookKeyStore()).access(id)},
  inbox: {enqueue: (callback) => new RcsCallbackStore(getFirestore())
    .enqueue(callback)},
  clock: Date.now,
  failed: () => logger.error("Event RCS callback processing failed"),
};

/** The path selects a trusted binding; it cannot supply provider identity. */
export async function eventAssistanceRcsWebhookHandler(request: Request,
  response: Response, deps: Dependencies = defaults): Promise<void> {
  const path = request.path;
  const endpointId = typeof path === "string" && path.startsWith("/") ?
    path.slice(1) : null;
  if (!validRcsEndpointId(endpointId)) {
    response.set({"Cache-Control": "private, no-store, max-age=0",
      "Content-Type": "text/plain; charset=utf-8",
      "X-Content-Type-Options": "nosniff", "Referrer-Policy": "no-referrer"});
    response.status(404).send("Unavailable");
    return;
  }
  return createRcsWebhookIngress({enabled: deps.enabled,
    credentials: async () => {
      const endpoint = await deps.keys.access(endpointId);
      if (endpoint.endpointId !== endpointId) {
        throw new Error("RCS webhook binding unavailable");
      }
      return endpoint;
    }, clock: deps.clock,
    enqueue: (callback) => deps.inbox.enqueue(callback),
    failed: deps.failed})(request, response);
}

export const eventAssistanceRcsWebhook = onRequest({invoker: "public",
  cors: false, maxInstances: 5, concurrency: 20, timeoutSeconds: 30},
(request, response) => eventAssistanceRcsWebhookHandler(request, response));
