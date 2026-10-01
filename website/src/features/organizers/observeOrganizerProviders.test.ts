import {beforeEach, describe, expect, it, vi} from "vitest";
import {waitFor} from "@testing-library/react";
import {setMarketingConsent} from "../../analytics";
import {hostListings} from "./data";
import {observeOrganizerProviders, trackOrganizerProviderOutboundClick} from "./observeOrganizerProviders";
import type {OrganizerTrackingSettings, ProviderSessionConfiguration} from "./trackingProviders";

const listing = {...hostListings[0], publicApi: {...hostListings[0].publicApi, state: "enabled" as const}};
let sequence = 0;
beforeEach(() => { localStorage.clear(); sessionStorage.clear(); sequence++; });
function setup() {
  const eventId = `event-${sequence}`;
  window.history.replaceState(null, "", `/events/${eventId}/?secret=never-send#private`);
  const settings: OrganizerTrackingSettings = {organizerId: listing.id, eventId, enabled: true,
    googleMeasurementId: "G-TEST123456", metaPixelId: "1234567890"};
  const readSettings = vi.fn().mockResolvedValue(settings);
  const sessions: {configuration: ProviderSessionConfiguration; send: ReturnType<typeof vi.fn>; destroy: ReturnType<typeof vi.fn>}[] = [];
  const transport = (configuration: ProviderSessionConfiguration) => {
    const session = {configuration, send: vi.fn(), destroy: vi.fn()}; sessions.push(session); return session;
  };
  return {eventId, settings, readSettings, transport, sessions};
}

describe("public organizer provider lifecycle integration", () => {
  it("fetches no configuration before consent and then reads the scoped callable and safe public path", async () => {
    const state = setup();
    const stop = observeOrganizerProviders(listing, state.eventId, state);
    expect(state.readSettings).not.toHaveBeenCalled();
    setMarketingConsent("essential"); expect(state.readSettings).not.toHaveBeenCalled();
    setMarketingConsent("accepted");
    await waitFor(() => expect(state.sessions).toHaveLength(2));
    expect(state.readSettings).toHaveBeenCalledWith({organizerId: listing.id, eventId: state.eventId});
    expect(state.sessions[0].configuration.publicPath).toBe(`/events/${state.eventId}/`);
    expect(state.sessions[0].send).toHaveBeenCalledWith("page_view");
    trackOrganizerProviderOutboundClick(listing.id, state.eventId);
    expect(state.sessions[0].send).toHaveBeenCalledWith("outbound_booking_click");
    stop(); expect(state.sessions.every((session) => session.destroy.mock.calls.length === 1)).toBe(true);
  });
  it("revokes immediately and ignores the in-flight granted configuration", async () => {
    const state = setup(); let resolve: (settings: OrganizerTrackingSettings) => void = () => {};
    state.readSettings.mockImplementation(() => new Promise<OrganizerTrackingSettings>((done) => {resolve = done;}));
    setMarketingConsent("accepted"); const stop = observeOrganizerProviders(listing, state.eventId, state);
    setMarketingConsent("essential"); resolve(state.settings);
    await Promise.resolve(); await Promise.resolve(); expect(state.sessions).toEqual([]);
    stop();
  });
  it("destroys mounted vendors when consent is revoked and prevents outbound events", async () => {
    const state = setup(); setMarketingConsent("accepted");
    const stop = observeOrganizerProviders(listing, state.eventId, state);
    await waitFor(() => expect(state.sessions).toHaveLength(2));
    setMarketingConsent("essential"); trackOrganizerProviderOutboundClick(listing.id, state.eventId);
    expect(state.sessions.every((session) => session.destroy.mock.calls.length === 1)).toBe(true);
    expect(state.sessions[0].send).toHaveBeenCalledTimes(1);
    stop();
  });
  it("ignores late responses after route navigation and only collects approved matching events", async () => {
    const state = setup(); let resolve: (settings: OrganizerTrackingSettings) => void = () => {};
    state.readSettings.mockImplementation(() => new Promise<OrganizerTrackingSettings>((done) => {resolve = done;}));
    setMarketingConsent("accepted"); const stop = observeOrganizerProviders(listing, state.eventId, state);
    window.history.replaceState(null, "", "/events/next-event/"); resolve(state.settings);
    await Promise.resolve(); expect(state.sessions).toEqual([]); stop();
    state.readSettings.mockResolvedValue(state.settings);
    window.history.replaceState(null, "", `/events/${state.eventId}/`);
    const stopAgain = observeOrganizerProviders(listing, state.eventId, state);
    await waitFor(() => expect(state.sessions).toHaveLength(2));
    trackOrganizerProviderOutboundClick("other-organizer", state.eventId);
    trackOrganizerProviderOutboundClick(listing.id, "sensitive-unapproved-event");
    expect(state.sessions[0].send).toHaveBeenCalledTimes(1); stopAgain();
  });
  it("does not load tags on denied/unknown ownership, sensitive policy or private pages", async () => {
    const state = setup(); setMarketingConsent("accepted");
    state.readSettings.mockRejectedValue(new Error("permission-denied"));
    const stop = observeOrganizerProviders(listing, state.eventId, state);
    await Promise.resolve(); expect(state.sessions).toEqual([]); stop();
    state.readSettings.mockResolvedValue({...state.settings, enabled: false, metaPixelId: null, googleMeasurementId: null});
    const stopSensitive = observeOrganizerProviders(listing, state.eventId, state);
    await Promise.resolve(); expect(state.sessions).toEqual([]); stopSensitive();
    state.readSettings.mockClear(); window.history.replaceState(null, "", "/booking/private-token/");
    const stopPrivate = observeOrganizerProviders(listing, state.eventId, state);
    expect(state.readSettings).not.toHaveBeenCalled(); stopPrivate();
  });
  it("deduplicates page views across remounts, while event cards on a listing cannot imply event approval", async () => {
    const state = setup(); setMarketingConsent("accepted");
    const stop = observeOrganizerProviders(listing, state.eventId, state);
    await waitFor(() => expect(state.sessions).toHaveLength(2)); stop();
    const stopAgain = observeOrganizerProviders(listing, state.eventId, state);
    await waitFor(() => expect(state.sessions).toHaveLength(4));
    expect(state.sessions[2].send).not.toHaveBeenCalled(); stopAgain();
    window.history.replaceState(null, "", listing.path);
    state.readSettings.mockResolvedValue({...state.settings, eventId: null});
    const stopListing = observeOrganizerProviders(listing, null, state);
    await waitFor(() => expect(state.sessions).toHaveLength(6));
    trackOrganizerProviderOutboundClick(listing.id, state.eventId);
    expect(state.sessions[4].send).toHaveBeenCalledTimes(1); stopListing();
  });
});
