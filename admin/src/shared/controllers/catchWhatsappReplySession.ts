import type {
  CatchInboundReview, CatchReplyCommand, CatchReplyResult,
} from "../contracts/catchWhatsappReplyContracts";

type Context = Readonly<{
  // Rotate on sign-out, account/session or project changes, even for the same UID.
  sessionKey: string;
  actorUid: string;
  projectId: string;
  enabled: boolean;
}>;
type ReviewTicket = Readonly<{generation: number; request: number; eventId: string}>;
type SendTicket = Readonly<{
  generation: number; request: number; command: Readonly<CatchReplyCommand>;
}>;
type Phase = "disabled" | "empty" | "reviewing" | "reviewed" |
  "confirmed" | "unknown" | "sent";

/** Only opaque receipt IDs and their project scope; never private payloads. */
export class CatchWhatsappReplyAttempts {
  private readonly consumed = new Set<string>();

  has(projectId: string, eventId: string): boolean {
    return this.consumed.has(JSON.stringify([projectId, eventId]));
  }

  reserve(projectId: string, eventId: string): boolean {
    const key = JSON.stringify([projectId, eventId]);
    if (this.consumed.has(key)) return false;
    this.consumed.add(key);
    return true;
  }
}

/**
 * In-memory state for a single controlled reply. No I/O, persistence, routing
 * or provider authority. A future mounted caller must use canonical runtime
 * validators, current Auth/App Check and the console pending-operation lease.
 * Server readiness/STOP/consent/atomic claims remain authoritative on every call.
 * Never log or persist the returned snapshots, tickets or private message text.
 */
export class CatchWhatsappReplySession {
  private context: Context | null = null;
  private generation = 0;
  private sequence = 0;
  private reviewTicket: ReviewTicket | null = null;
  private sendTicket: SendTicket | null = null;
  private inbound: Readonly<CatchInboundReview> | null = null;
  private replyBody = "";
  private phase: Phase = "disabled";
  private result: Readonly<CatchReplyResult> | null = null;
  constructor(private readonly attempts = new CatchWhatsappReplyAttempts()) {}

  setContext(context: Context | null): void {
    if (context && this.context &&
        context.sessionKey === this.context.sessionKey &&
        context.actorUid === this.context.actorUid &&
        context.projectId === this.context.projectId &&
        context.enabled === this.context.enabled) return;
    this.context = context ? Object.freeze({...context}) : null;
    this.generation++;
    this.reviewTicket = null;
    this.sendTicket = null;
    this.inbound = null;
    this.replyBody = "";
    this.result = null;
    this.phase = this.enabled() ? "empty" : "disabled";
  }

  snapshot() {
    return Object.freeze({phase: this.phase, inbound: this.inbound,
      replyBody: this.replyBody, result: this.result});
  }

  startReview(eventId: string): ReviewTicket {
    this.requireEnabled();
    if (this.phase === "unknown" || this.phase === "sent" ||
        this.attempts.has(this.context!.projectId, eventId) ||
        !/^cwhe_[a-f0-9]{64}$/u.test(eventId)) {
      throw new Error("A fresh eligible inbound review is required.");
    }
    this.inbound = null;
    this.replyBody = "";
    this.result = null;
    this.sendTicket = null;
    this.phase = "reviewing";
    this.reviewTicket = Object.freeze({generation: this.generation,
      request: ++this.sequence, eventId});
    return this.reviewTicket;
  }

  acceptReview(ticket: ReviewTicket, review: CatchInboundReview,
    nowMillis: number): boolean {
    if (ticket !== this.reviewTicket || !this.enabled() ||
        ticket.generation !== this.generation) return false;
    this.reviewTicket = null;
    this.phase = "empty";
    if (review.purpose !== "serviceSupport" ||
        review.inboundEventId !== ticket.eventId ||
        !/^[a-f0-9]{64}$/u.test(review.reviewedInboundTextHash) ||
        typeof review.inboundText !== "string" ||
        review.inboundText.length < 1 || review.inboundText.length > 4096 ||
        !this.liveDeadline(review.deadlineMillis, nowMillis)) {
      throw new Error("Inbound review is unavailable or expired.");
    }
    // Explicit projection prevents unknown wire fields entering private state.
    this.inbound = Object.freeze({purpose: review.purpose,
      inboundEventId: review.inboundEventId, inboundText: review.inboundText,
      reviewedInboundTextHash: review.reviewedInboundTextHash,
      deadlineMillis: review.deadlineMillis});
    this.phase = "reviewed";
    return true;
  }

  failReview(ticket: ReviewTicket): void {
    if (ticket !== this.reviewTicket) return;
    this.reviewTicket = null;
    this.phase = "empty";
  }

  editReply(body: string): void {
    this.requireEnabled();
    if (!this.inbound || !["reviewed", "confirmed"].includes(this.phase)) {
      throw new Error("Review is required before editing.");
    }
    // Any edit, even restoring previous text, requires renewed confirmation.
    this.replyBody = body;
    this.phase = "reviewed";
  }

  confirmSupportRequest(nowMillis: number): void {
    this.requireReviewed(nowMillis);
    this.phase = "confirmed";
  }

  takeConfirmedCommand(nowMillis: number): SendTicket {
    this.requireReviewed(nowMillis);
    if (this.phase !== "confirmed" || !this.inbound ||
        !this.attempts.reserve(this.context!.projectId,
          this.inbound.inboundEventId)) {
      throw new Error("Explicit confirmation is required.");
    }
    const command: Readonly<CatchReplyCommand> = Object.freeze({
      purpose: "serviceSupport", inboundEventId: this.inbound.inboundEventId,
      reviewedInboundTextHash: this.inbound.reviewedInboundTextHash,
      confirmSupportRequest: true, body: this.replyBody,
    });
    this.sendTicket = Object.freeze({generation: this.generation,
      request: ++this.sequence, command});
    // Reserve before dispatch. Every error, timeout or missing settlement stays
    // uncertain/consumed. There is deliberately no reset or retry method.
    this.phase = "unknown";
    return this.sendTicket;
  }

  acceptResult(ticket: SendTicket, result: CatchReplyResult): boolean {
    if (ticket !== this.sendTicket || !this.enabled() ||
        ticket.generation !== this.generation || this.phase !== "unknown") {
      return false;
    }
    if (!/^cwreply_[a-f0-9]{64}$/u.test(result.operationId) ||
        typeof result.providerMessageId !== "string" ||
        result.providerMessageId.length < 1 ||
        result.providerMessageId.length > 240 ||
        /[\s\u0000-\u001f]/u.test(result.providerMessageId) ||
        !["accepted", "sent", "delivered", "read", "failed"]
          .includes(result.deliveryStatus) ||
        typeof result.replayed !== "boolean") {
      throw new Error("Reply outcome requires reconciliation.");
    }
    this.result = Object.freeze({operationId: result.operationId,
      providerMessageId: result.providerMessageId,
      deliveryStatus: result.deliveryStatus, replayed: result.replayed});
    this.phase = "sent";
    return true;
  }

  private enabled(): boolean {
    return this.context?.enabled === true &&
      Boolean(this.context.sessionKey && this.context.actorUid &&
        this.context.projectId);
  }

  private requireEnabled(): void {
    if (!this.enabled()) throw new Error("Controlled reply is disabled.");
  }

  private liveDeadline(deadline: number, now: number): boolean {
    return Number.isSafeInteger(now) && now >= 0 &&
      Number.isSafeInteger(deadline) && deadline > now;
  }

  private requireReviewed(nowMillis: number): void {
    this.requireEnabled();
    if (!this.inbound || !["reviewed", "confirmed"].includes(this.phase) ||
        !this.liveDeadline(this.inbound.deadlineMillis, nowMillis) ||
        !this.replyBody.trim() || this.replyBody.length > 4096) {
      throw new Error("A current review and bounded reply are required.");
    }
  }
}
