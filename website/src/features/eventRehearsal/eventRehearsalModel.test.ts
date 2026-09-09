import {describe, expect, it} from "vitest";
import {eventRehearsalCopy} from "../../content/eventRehearsal";
import type {EventRehearsalGuestBootstrap} from "../../firebase";
import {
  availableEventRehearsalGuestActions,
  eventRehearsalGuestActionClientId,
  reconcileRehearsalProjection,
} from "./eventRehearsalModel";

const bootstrap: EventRehearsalGuestBootstrap = {
  slotToken: "slot_1234567890123456_token_12345678901234567890",
  practiceBanner: "Practice",
  session: {
    title: eventRehearsalCopy.brand,
    locationName: "Studio",
    status: "running",
    activeStepIndex: 1,
    virtualNowMillis: 1,
    attendeePrompt: "Say hello",
    moduleIds: ["arrival"],
    runtimeRevision: 1,
    faultId: "none",
  },
  actor: {
    actorId: "actor-01",
    displayName: "Rhea",
    status: "expected",
    guestMoment: "checkIn",
    optedOut: false,
    helpRequested: false,
    promptCompleted: false,
  },
};

describe("eventRehearsalModel", () => {
  it("preserves a confirmed instruction but accepts a reset's new identity", () => {
    const message = {messageId: `outbox:${"a".repeat(64)}`,
      intentId: `message:${"b".repeat(64)}`, intentRevision: 1,
      text: "Join us here", choices: [], lifecycle: "responded" as const,
      expiresAt: 1000, canRespond: false, responseChoiceId: "on-my-way"};
    const previous = {...bootstrap, session: {...bootstrap.session, runtimeRevision: 10},
      actor: {...bootstrap.actor, assistanceMessage: message}};
    const stale = {...previous, session: {...previous.session, runtimeRevision: 9},
      actor: {...previous.actor, assistanceMessage: {...message,
        lifecycle: "active" as const, responseChoiceId: null}}};
    expect(reconcileRehearsalProjection(previous, stale)).toBe(previous);
    const reset = {...bootstrap, session: {...bootstrap.session, runtimeRevision: 0}};
    expect(reconcileRehearsalProjection(previous, reset)).toBe(reset);
    const restarted = {...reset, actor: {...reset.actor,
      assistanceMessage: {...message, messageId: `outbox:${"c".repeat(64)}`}}};
    expect(reconcileRehearsalProjection(previous, restarted)).toBe(restarted);
  });
  it("offers bounded actions for an expected synthetic guest", () => {
    expect(availableEventRehearsalGuestActions(bootstrap)).toEqual([
      "checkIn",
      "optOut",
      "askForHelp",
      "completePrompt",
    ]);
  });

  it("removes completed and already-applied actions", () => {
    expect(availableEventRehearsalGuestActions({
      ...bootstrap,
      session: {...bootstrap.session, status: "complete"},
      actor: {
        ...bootstrap.actor,
        optedOut: true,
        helpRequested: true,
        promptCompleted: true,
      },
    })).toEqual([]);
  });

  it("keeps guest controls closed until the Host starts the run", () => {
    expect(availableEventRehearsalGuestActions({
      ...bootstrap,
      session: {...bootstrap.session, status: "ready"},
    })).toEqual([]);
  });

  it("builds contract-safe idempotency keys", () => {
    expect(eventRehearsalGuestActionClientId("device-1234567890123456", 42))
      .toMatch(/^guest_[A-Za-z0-9_-]+_[a-z0-9]+$/u);
  });

  it("connection state neither creates nor removes arrival actions", () => {
    for (const status of ["expected", "present", "noShow", "departed"] as const) {
      const actor = {...bootstrap.actor, status};
      expect(availableEventRehearsalGuestActions({
        ...bootstrap, actor: {...actor, connectionState: "disconnected"},
      })).toEqual(availableEventRehearsalGuestActions({
        ...bootstrap, actor: {...actor, connectionState: "connected"},
      }));
    }
    expect(availableEventRehearsalGuestActions({
      ...bootstrap, actor: {...bootstrap.actor, status: "present",
        connectionState: "disconnected"},
    })).not.toContain("confirmArrival");
  });
});
