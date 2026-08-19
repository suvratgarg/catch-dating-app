import {describe, expect, it} from "vitest";
import {eventRehearsalCopy} from "../../content/eventRehearsal";
import type {EventRehearsalGuestBootstrap} from "../../firebase";
import {
  availableEventRehearsalGuestActions,
  eventRehearsalGuestActionClientId,
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
});
