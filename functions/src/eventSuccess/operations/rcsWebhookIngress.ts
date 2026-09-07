import type {Request, Response} from "express";
import {RCS_CALLBACK_MAX_BYTES, VerifiedRcsCallback,
  verifyRcsWebhookChallenge} from "./rcsWebhookProtocol";

interface Dependencies {
  enabled: () => boolean;
  /** Resolve a trusted endpoint configuration, never an agent from the body. */
  credentials: () => Promise<{agentId: string; clientToken: string}>;
  /** Resolve after durable storage; apply no domain effects here. */
  enqueue: (callback: VerifiedRcsCallback) =>
    Promise<"stored" | "duplicate" | "conflict">;
  clock: () => number;
  failed: () => void;
}
type RawRequest = Request & {rawBody?: Buffer};

/**
 * Dependency-injected HTTP boundary; deliberately no onRequest export or
 * production defaults until the private queue and credential owner are wired.
 */
export function createRcsWebhookIngress(deps: Dependencies) {
  return async (request: RawRequest, response: Response): Promise<void> => {
    response.set({"Cache-Control": "private, no-store, max-age=0",
      "Content-Type": "text/plain; charset=utf-8",
      "X-Content-Type-Options": "nosniff", "Referrer-Policy": "no-referrer"});
    const unavailable = () => {
      response.set("Retry-After", "30");
      response.status(503).send("Unavailable");
    };
    try {
      if (!deps.enabled()) return unavailable();
      if (request.method !== "POST") {
        response.set("Allow", "POST");
        response.status(405).send("Method not allowed");
        return;
      }
      const body = request.rawBody;
      if (!Buffer.isBuffer(body) || body.length === 0) {
        response.status(400).send("Invalid callback");
        return;
      }
      if (body.length > RCS_CALLBACK_MAX_BYTES) {
        response.status(413).send("Callback too large");
        return;
      }
      const type = request.headers["x-goog-webhook-type"];
      const signature = request.headers["x-goog-signature"];
      if (type !== undefined && type !== "verification" &&
          type !== "message_callback" && type !== "agent_callback" ||
          Array.isArray(signature)) {
        response.status(400).send("Invalid callback");
        return;
      }
      const credentials = await deps.credentials();
      if (type === "verification") {
        // Relabeling a signed message cannot turn it into a valid challenge.
        const secret = verifyRcsWebhookChallenge(body, credentials.clientToken);
        response.status(secret === null ? 403 : 200)
          .send(secret ?? "Invalid callback");
        return;
      }
      const result = VerifiedRcsCallback.receive({rawBody: body, signature,
        clientToken: credentials.clientToken,
        expectedAgentId: credentials.agentId,
        receivedAt: deps.clock()});
      if (result.kind === "rejected") {
        response.status(result.reason === "payload" ? 400 : 403)
          .send("Invalid callback");
        return;
      }
      if (result.kind === "verified") {
        const saved = await deps.enqueue(result.callback);
        if (saved !== "stored" && saved !== "duplicate" &&
            saved !== "conflict") {
          throw new Error("RCS callback was not durably accepted");
        }
      }
      // Conflicts are acknowledged only after the queue preserves them for
      // review. Unsupported authenticated traffic has no assistance effect.
      response.status(200).send("ok");
    } catch {
      // Provider failures may contain message text, phones, tokens or URLs.
      deps.failed();
      unavailable();
    }
  };
}
