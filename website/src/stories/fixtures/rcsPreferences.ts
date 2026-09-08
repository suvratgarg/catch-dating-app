import type {EventRcsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventRcsPreferenceOutput";
import type {ListEventRcsPreferencesCallableResponse as Options} from "../../shared/contracts/generated/listEventRcsPreferencesOutput";

// Synthetic fixtures shared by deterministic stories and controller tests.
export const rcsOptionsFixture: Options = {eventId: "event", attendeeId: "attendee",
  serverTime: 1000, configuredSenderId: "catch-events", previousSenderIds: ["earlier-sender"], nextCursor: null};
export const rcsPreferenceFixture: Response = {outcome: "read", view: {
  eventId: "event", attendeeId: "attendee", senderId: "catch-events", eventTitle: "Courtyard Social",
  serverTime: 1000, revision: null, preference: "notSet", canEnable: true, availability: "ready",
  phoneLastFour: "9999", expiresAt: null, reviewHash: "a".repeat(64),
  sender: {displayName: "Catch Events"}, consent: {version: "catch-event-service-rcs-v1",
    text: "Receive RCS messages from Catch about joining, changes and follow-up for this event, until 24 hours after it ends. I can turn them off here."},
}};
export const rcsEnabledFixture: Response = {outcome: "applied", view: {...rcsPreferenceFixture.view,
  preference: "enabled", revision: 1, serverTime: 1001, expiresAt: 100_000}};
