import {cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
const api = vi.hoisted(() => ({begin: vi.fn(), register: vi.fn(), confirm: vi.fn(), clear: vi.fn()}));
vi.mock("../../firebase", () => ({beginPublicEventPhoneVerification: api.begin,
  registerPublicEvent: api.register}));
vi.mock("../eventMessaging/EventSmsPreferencePanel", () => ({
  EventSmsPreferencePanel: ({eventId, attendeeId}: {eventId: string; attendeeId: string}) =>
    <section aria-label="Event text preferences">{eventId}:{attendeeId}</section>,
}));
import {PublicEventRegistration} from "./PublicEventRegistration";
import {eventDetailCopy} from "../../content/events";
const copy = eventDetailCopy.hero.webRegistration;
afterEach(cleanup);
beforeEach(() => {
  vi.clearAllMocks();
  api.begin.mockResolvedValue({confirm: api.confirm, clear: api.clear});
  api.confirm.mockResolvedValue(undefined);
});
async function register() {
  render(<PublicEventRegistration eventId="event-1" />);
  expect(screen.queryByRole("region", {name: "Event text preferences"})).toBeNull();
  fireEvent.change(screen.getByLabelText(copy.nameLabel), {target: {value: "Fixture Guest"}});
  fireEvent.change(screen.getByLabelText(copy.phoneLabel), {target: {value: "+919999999999"}});
  fireEvent.click(screen.getByRole("button", {name: copy.sendCodeAction}));
  fireEvent.change(await screen.findByLabelText(copy.codeLabel), {target: {value: "123456"}});
  fireEvent.click(screen.getByRole("button", {name: copy.confirmAction}));
  await waitFor(() => expect(api.register).toHaveBeenCalledOnce());
}
it.each(["registered", "alreadyRegistered"])("offers separate event texts after %s", async (status) => {
  api.register.mockResolvedValue({eventId: "event-1", attendeeId: "verified-guest", status});
  await register();
  expect((await screen.findByRole("region", {name: "Event text preferences"})).textContent)
    .toBe("event-1:verified-guest");
  expect(api.register.mock.calls[0][0].organizerUpdates)
    .toEqual({whatsapp: false, sms: false, termsVersion: "organizer-updates-v1"});
});
it("does not offer event-service texts for a waitlist place", async () => {
  api.register.mockResolvedValue({eventId: "event-1", attendeeId: "waitlisted", status: "waitlisted"});
  await register();
  await screen.findByText(copy.waitlisted);
  expect(screen.queryByRole("region", {name: "Event text preferences"})).toBeNull();
});
