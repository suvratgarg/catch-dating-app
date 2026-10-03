import {describe, expect, it} from "vitest";
import {CatchWhatsappReplyAttempts, CatchWhatsappReplySession} from "./catchWhatsappReplySession";

const eventId = "cwhe_" + "a".repeat(64);
const context = {sessionKey: "session-1", actorUid: "staff",
  projectId: "catchdates-dev", enabled: true};
const inbound = {purpose: "serviceSupport" as const, inboundEventId: eventId,
  inboundText: "Private support request", reviewedInboundTextHash: "b".repeat(64),
  deadlineMillis: 10000};
const result = {operationId: "cwreply_" + "c".repeat(64),
  providerMessageId: "wamid.test", deliveryStatus: "accepted" as const,
  replayed: false};
function reviewed(attempts?: CatchWhatsappReplyAttempts,
  scope = context) {
  const session = new CatchWhatsappReplySession(attempts);
  session.setContext(scope);
  const ticket = session.startReview(eventId);
  session.acceptReview(ticket, inbound, 1000);
  session.editReply("Exact reviewed reply");
  return session;
}

describe("controlled Catch reply operator state", () => {
  it("defaults off and requires current review and explicit confirmation", () => {
    const session = new CatchWhatsappReplySession();
    expect(() => session.startReview(eventId)).toThrow(/disabled/);
    const active = reviewed();
    expect(() => active.takeConfirmedCommand(2000)).toThrow(/confirmation/);
    active.confirmSupportRequest(2000);
    const ticket = active.takeConfirmedCommand(2000);
    expect(ticket.command).toEqual({purpose: "serviceSupport",
      inboundEventId: eventId, reviewedInboundTextHash: inbound.reviewedInboundTextHash,
      confirmSupportRequest: true, body: "Exact reviewed reply"});
    expect(Object.isFrozen(ticket.command)).toBe(true);
    expect(active.snapshot().phase).toBe("unknown");
  });

  it("invalidates confirmation after every edit and deadline expiry", () => {
    const session = reviewed();
    session.confirmSupportRequest(2000);
    session.editReply("Changed");
    session.editReply("Exact reviewed reply");
    expect(() => session.takeConfirmedCommand(2000)).toThrow(/confirmation/);
    session.confirmSupportRequest(2000);
    expect(() => session.takeConfirmedCommand(10000)).toThrow(/current review/);
    session.editReply(" ");
    expect(() => session.confirmSupportRequest(2000)).toThrow();
    session.editReply("x".repeat(4097));
    expect(() => session.confirmSupportRequest(2000)).toThrow();
  });

  it("consumes before dispatch and cannot retry any uncertain outcome", () => {
    const session = reviewed();
    session.confirmSupportRequest(2000);
    const ticket = session.takeConfirmedCommand(2000);
    expect(() => session.takeConfirmedCommand(2000)).toThrow();
    expect(() => session.editReply("Retry")).toThrow();
    expect(() => session.startReview(eventId)).toThrow();
    expect(() => session.acceptResult(ticket, {...result,
      providerMessageId: ""})).toThrow(/reconciliation/);
    expect(session.snapshot().phase).toBe("unknown");
    session.setContext(null);
    session.setContext({...context, sessionKey: "session-2"});
    expect(() => session.startReview(eventId)).toThrow();
  });

  it("drops private state and stale async results on any identity change", () => {
    for (const next of [null, {...context, sessionKey: "new"},
      {...context, actorUid: "other"}, {...context, projectId: "other"},
      {...context, enabled: false}]) {
      const session = reviewed();
      session.confirmSupportRequest(2000);
      const ticket = session.takeConfirmedCommand(2000);
      session.setContext(next);
      expect(session.acceptResult(ticket, result)).toBe(false);
      expect(session.snapshot().inbound).toBeNull();
      expect(session.snapshot().replyBody).toBe("");
      expect(session.snapshot().result).toBeNull();
    }
  });

  it("rejects stale, mismatched and expired inbound review responses", () => {
    const session = new CatchWhatsappReplySession();
    session.setContext(context);
    const first = session.startReview(eventId);
    const second = session.startReview(eventId);
    expect(session.acceptReview(first, inbound, 1000)).toBe(false);
    expect(() => session.acceptReview(second, {...inbound,
      inboundEventId: "cwhe_" + "d".repeat(64)}, 1000)).toThrow();
    expect(session.snapshot().inbound).toBeNull();
    const third = session.startReview(eventId);
    expect(() => session.acceptReview(third, inbound, 10000)).toThrow();
    const fourth = session.startReview(eventId);
    session.setContext(null);
    expect(session.acceptReview(fourth, inbound, 1000)).toBe(false);
  });

  it("projects immutable private data and accepts only the reserved result", () => {
    const session = reviewed();
    session.confirmSupportRequest(2000);
    const ticket = session.takeConfirmedCommand(2000);
    expect(session.acceptResult({...ticket}, result)).toBe(false);
    expect(session.acceptResult(ticket, result)).toBe(true);
    expect(Object.isFrozen(session.snapshot().result)).toBe(true);
    expect(Object.isFrozen(session.snapshot().inbound)).toBe(true);
    expect(() => session.startReview(eventId)).toThrow();
    expect(session.acceptResult(ticket, result)).toBe(false);
  });
});

it("shares only project-scoped attempt markers across new private sessions", () => {
  const attempts = new CatchWhatsappReplyAttempts();
  const first = reviewed(attempts);
  first.confirmSupportRequest(2000);
  first.takeConfirmedCommand(2000);
  first.setContext(null);
  expect(first.snapshot()).toEqual({phase: "disabled", inbound: null,
    replyBody: "", result: null});
  const replacement = new CatchWhatsappReplySession(attempts);
  replacement.setContext({...context, actorUid: "other", sessionKey: "new"});
  expect(() => replacement.startReview(eventId)).toThrow(/fresh eligible/);
  replacement.setContext({...context, projectId: "different"});
  expect(() => replacement.startReview(eventId)).not.toThrow();
  replacement.setContext(context);
  expect(() => replacement.startReview(eventId)).toThrow(/fresh eligible/);
});
it("reserves synchronously across sessions that already reviewed the same inbound", () => {
  const attempts = new CatchWhatsappReplyAttempts();
  const first = reviewed(attempts);
  const second = reviewed(attempts);
  first.confirmSupportRequest(2000);
  second.confirmSupportRequest(2000);
  first.takeConfirmedCommand(2000);
  expect(() => second.takeConfirmedCommand(2000)).toThrow(/confirmation/);
});
