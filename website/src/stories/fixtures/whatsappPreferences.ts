import type {EventWhatsappPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventWhatsappPreferenceCallableResponse";
import type {ListEventWhatsappPreferencesCallableResponse as Options} from "../../shared/contracts/generated/listEventWhatsappPreferencesOutput";

export const whatsappOptionsFixture: Options = {eventId: "event", attendeeId: "attendee",
  serverTime: 1000, configuredSenderId: "organizer-whatsapp", previousSenderIds: ["earlier-whatsapp"], nextCursor: null};
export const whatsappPreferenceFixture: Response = {outcome: "read", view: {
  eventId: "event", attendeeId: "attendee", senderId: "organizer-whatsapp", serverTime: 1000,
  revision: null, preference: "notSet", canEnable: true, availability: "ready",
  phoneLastFour: "9999", expiresAt: null, stopRecordHash: null, reviewHash: "d".repeat(64),
  sender: {displayName: "Courtyard Social Club", displayPhoneNumber: "+91 88888 88888", bindingHash: "a".repeat(64)},
  consent: {version: "catch-event-service-whatsapp-v1",
    text: "Receive WhatsApp messages from the organizer shown here about joining, changes and follow-up for this event, until 24 hours after it ends. I can turn them off here."},
}};
export const whatsappEnabledFixture: Response = {outcome: "applied", view: {...whatsappPreferenceFixture.view,
  preference: "enabled", revision: 1, serverTime: 1001, expiresAt: 100_000}};
