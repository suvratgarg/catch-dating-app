import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import {runInNewContext} from "node:vm";
import {describe, expect, it, vi} from "vitest";
import {safeAcquisitionEvent} from "../../analytics/catchMeasurement";
import {catchLiveDestinations, catchMeasurementMode, configuredCatchTransport, createCatchLiveGoogleSession} from "../../analytics/catchLiveTransport";

const channel = "00000000-0000-4000-8000-000000000000";
const lead = safeAcquisitionEvent({name: "lead_accepted", form: "host_application",
  eventId: `catch_1792486200000_${channel}`, receipt: {ok: true, alreadyJoined: false}},
{path: "/host/apply/", consent: {version: 4, analytics: true, marketing: true, updatedAt: "2026-10-20T00:00:00Z"}})!;

describe("Catch controlled Google transport", () => {
  it("keeps production disabled and does not create frames for either provider", () => {
    const create = vi.spyOn(document, "createElement");
    expect(catchLiveDestinations.enabled).toBe(false);
    expect(catchMeasurementMode("https://catchdates.com")).toBe("disabled");
    expect(catchMeasurementMode(catchLiveDestinations.previewOrigin)).toBe("google-preview-v1");
    expect(catchMeasurementMode("https://unreviewed-preview.example")).toBe("disabled");
    for (const provider of ["google", "meta"] as const) configuredCatchTransport(provider).send(lead);
    expect(create).not.toHaveBeenCalled();
  });

  it("removes the opaque frame and cancels pending events after consent withdrawal", () => {
    let onload: (() => void) | undefined;
    const postMessage = vi.fn();
    const frame = {contentWindow: {postMessage}, remove: vi.fn(), removeEventListener: vi.fn(),
      addEventListener: vi.fn((_name, handler) => {onload = handler;})};
    const session = createCatchLiveGoogleSession({create: () => frame as never,
      mount: vi.fn(), channel: () => channel});
    session.send(lead);
    session.destroy();
    onload!();
    session.send(lead);
    expect(postMessage).not.toHaveBeenCalled();
    expect(frame.remove).toHaveBeenCalledOnce();
  });

  it("uses a storage-isolated frame with no parent referrer", () => {
    const session = createCatchLiveGoogleSession();
    const frame = document.querySelector("iframe")!;
    expect(frame.getAttribute("sandbox")).toBe("allow-scripts");
    expect(frame.referrerPolicy).toBe("no-referrer");
    expect(frame.getAttribute("src")).toBe("/catch-acquisition-runtime.html");
    session.destroy();
    expect(document.querySelector("iframe")).toBeNull();
  });

  it("marks the exact preview as internal debug traffic and never sends Ads conversions", () => {
    const parent = {};
    let listener: (message: unknown) => void;
    const runtime: Record<string, any> = {addEventListener: (_: string, fn: typeof listener) => {listener = fn;}};
    runInNewContext(readFileSync(resolve(process.cwd(), "public/catch-acquisition-runtime.js"), "utf8"), {
      parent, URLSearchParams, window: runtime,
      document: {createElement: () => ({}), head: {appendChild() {}}},
    });
    const origin = catchLiveDestinations.previewOrigin;
    listener!({source: parent, origin, data: {type: "catch:acquisition-init", channel,
      measurementId: catchLiveDestinations.googleMeasurementId, leadDestination: catchLiveDestinations.googleAdsLeadDestination}});
    listener!({source: parent, origin, data: {type: "catch:acquisition-event", channel, event: lead}});
    const rows = runtime.dataLayer.map((row: ArrayLike<unknown>) => Array.from(row));
    expect(rows.filter((r: unknown[]) => r[1] === "conversion")).toHaveLength(0);
    expect(rows.find((r: unknown[]) => r[1] === "generate_lead")[2]).toMatchObject({debug_mode: true, traffic_type: "internal"});
  });

  it("binds messages to the parent/channel, suppresses automatic collection, and separates Ads consent", () => {
    const parent = {};
    const loaded: unknown[] = [];
    let listener: (message: unknown) => void;
    const runtime: Record<string, any> = {addEventListener: (_: string, fn: typeof listener) => {listener = fn;}};
    runInNewContext(readFileSync(resolve(process.cwd(), "public/catch-acquisition-runtime.js"), "utf8"), {
      parent, URLSearchParams, window: runtime, document: {createElement: () => ({}), head: {appendChild: (script: unknown) => loaded.push(script)}},
    });
    const init = {type: "catch:acquisition-init", channel,
      measurementId: catchLiveDestinations.googleMeasurementId,
      leadDestination: catchLiveDestinations.googleAdsLeadDestination};
    const dispatch = (data: unknown, source = parent, origin = "https://catchdates.com") =>
      listener!({data, source, origin});
    dispatch(init, {});
    expect(loaded).toHaveLength(0);
    dispatch(init);
    expect(loaded).toHaveLength(1);
    const rows = () => runtime.dataLayer.map((row: ArrayLike<unknown>) => Array.from(row));
    expect(rows()[0]).toEqual(["consent", "default", {analytics_storage: "denied",
      ad_storage: "denied", ad_user_data: "denied", ad_personalization: "denied"}]);
    dispatch({type: "catch:acquisition-event", channel: "wrong", event: lead});
    expect(rows().filter((r: unknown[]) => r[0] === "event")).toHaveLength(0);
    dispatch({type: "catch:acquisition-event", channel,
      event: {...lead, consent: {analytics: true, marketing: false},
        parameters: {...lead.parameters, event_id: `catch_1792486200001_${channel}`}}});
    expect(rows().filter((r: unknown[]) => r[1] === "conversion")).toHaveLength(0);
    dispatch({type: "catch:acquisition-event", channel, event: lead});
    expect(rows().find((r: unknown[]) => r[0] === "config")?.[2]).toMatchObject({send_page_view: false,
      allow_google_signals: false, page_referrer: "", page_title: "Catch"});
    const conversions = rows().filter((r: unknown[]) => r[1] === "conversion");
    expect(conversions).toHaveLength(1);
    expect(conversions[0][2]).toMatchObject({send_to: catchLiveDestinations.googleAdsLeadDestination,
      transaction_id: lead.parameters.event_id});
    dispatch({type: "catch:acquisition-event", channel, event: {...lead,
      parameters: {...lead.parameters, event_id: `catch_1792486200002_${channel}`,
        utm_source: "google", utm_medium: "cpc", utm_campaign: "host_acquisition_2026"},
      attribution: {clientId: "12345.1792486200", sessionId: 1792486200,
        gclid: "SyntheticClick12345", fbclid: "MetaOnlyClick12345", email: "private@example.test"}}});
    const attributed = rows().filter((r: unknown[]) => r[1] === "conversion").at(-1)[2];
    expect(attributed).toMatchObject({client_id: "12345.1792486200", session_id: 1792486200,
      campaign_source: "google", campaign_medium: "cpc", campaign_name: "host_acquisition_2026",
      page_location: "https://catchdates.com/host/apply/?gclid=SyntheticClick12345"});
    expect(JSON.stringify(attributed)).not.toMatch(/MetaOnly|private@example|fbclid|email/u);
    dispatch({type: "catch:acquisition-event", channel, event: {...lead,
      name: "cta_click", consent: {analytics: true, marketing: false},
      attribution: {clientId: "12345.1792486200", sessionId: 1792486200, gclid: "SyntheticClick12345"}}});
    expect(rows().filter((r: unknown[]) => r[1] === "cta_click").at(-1)[2].page_location)
      .toBe("https://catchdates.com/host/apply/");
    const count = rows().length;
    dispatch({type: "catch:acquisition-event", channel,
      event: {...lead, parameters: {...lead.parameters, page_path: "/booking/private/"}}});
    expect(rows()).toHaveLength(count);
  });
});
