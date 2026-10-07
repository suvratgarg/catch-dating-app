import {beforeEach, expect, it, vi} from "vitest";
const f = vi.hoisted(() => ({
  user: {uid: "staff", getIdToken: vi.fn()},
  auth: {currentUser: null as unknown},
  app: {options: {projectId: "catchdates-dev"}},
  token: vi.fn(), fetch: vi.fn(),
  available: true, refresh: vi.fn(),
}));
vi.mock("../../../shared/api/firebase", () => ({auth: f.auth}));
vi.mock("../../../shared/api/firebaseCore", () =>
  ({firebaseApp: f.app, adminAppCheck: {}}));
vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => "live"}));
vi.mock("firebase/app-check", () => ({getToken: f.token}));
vi.mock("./catchWhatsappAvailability", () => ({
  catchWhatsappSupportAvailable: () => f.available,
  refreshCatchWhatsappAvailability: f.refresh,
}));
import {catchWhatsappTrialApi} from
  "./catchWhatsappTrialRepository";
const scope = {actorUid: "staff", projectId: "catchdates-dev",
  sessionKey: "session", isCurrent: () => true};
const eventId = "cwhe_" + "a".repeat(64);
const review = {purpose: "serviceSupport", inboundEventId: eventId,
  inboundText: "Private request", reviewedInboundTextHash: "b".repeat(64),
  deadlineMillis: 10000};
beforeEach(() => {
  vi.stubEnv("VITE_ADMIN_APPCHECK_SITE_KEY", "test-site-key");
  vi.stubGlobal("fetch", f.fetch);
  f.app.options.projectId = "catchdates-dev";
  f.auth.currentUser = f.user;
  f.user.getIdToken.mockResolvedValue("auth-token");
  f.token.mockResolvedValue({token: "app-check-token"});
  f.available = true; f.refresh.mockResolvedValue(true);
  f.fetch.mockResolvedValue({ok: true, json: async () => ({result: review})});
});

it("does not dispatch when Remote Config availability is absent or disabled", async () => {
  f.available = false; f.refresh.mockResolvedValue(false);
  await expect(catchWhatsappTrialApi.prepare(scope)).rejects.toThrow();
  await expect(catchWhatsappTrialApi.review(eventId, scope)).rejects.toThrow();
  expect(f.fetch).not.toHaveBeenCalled();
});

it("uses the configured production project with the same one-use guarded protocol", async () => {
  f.app.options.projectId = "catch-prod-synthetic";
  const production = {...scope, projectId: f.app.options.projectId};
  await catchWhatsappTrialApi.prepare(production);
  await catchWhatsappTrialApi.review(eventId, production);
  expect(f.fetch).toHaveBeenCalledWith(
    "https://asia-south1-catch-prod-synthetic.cloudfunctions.net/adminReviewCatchWhatsappInbound",
    expect.objectContaining({method: "POST", redirect: "error"}));
});

it("fences current actor, project and session before any request", async () => {
  for (const changed of [{...scope, actorUid: "other"},
    {...scope, projectId: "other"}, {...scope, isCurrent: () => false}]) {
    await expect(catchWhatsappTrialApi.review(eventId, changed)).rejects.toThrow();
  }
  expect(f.fetch).not.toHaveBeenCalled();
});

it("never dispatches when a session retires during final token resolution",
  async () => {
    let current = true;
    let release!: (token: string) => void;
    f.user.getIdToken.mockImplementationOnce(() =>
      new Promise((resolve) => {release = resolve;}));
    const scoped = {...scope, isCurrent: () => current};
    const preparation = catchWhatsappTrialApi.prepare(scoped);
    current = false; release("auth-token");
    await expect(preparation).rejects.toThrow();
    await expect(catchWhatsappTrialApi.review(eventId, scoped)).rejects.toThrow();
    expect(f.fetch).not.toHaveBeenCalled();
  });

it("performs no async token work after its final dispatch fence", async () => {
  await catchWhatsappTrialApi.prepare(scope);
  expect(await catchWhatsappTrialApi.review(eventId, scope)).toEqual(review);
  expect(f.user.getIdToken).toHaveBeenCalledOnce();
  expect(f.token).toHaveBeenCalledOnce();
  expect(f.fetch).toHaveBeenCalledWith(
    "https://asia-south1-catchdates-dev.cloudfunctions.net/adminReviewCatchWhatsappInbound",
    expect.objectContaining({method: "POST", redirect: "error",
      body: JSON.stringify({data: {purpose: "serviceSupport", inboundEventId: eventId}}),
      headers: {"Content-Type": "application/json", Authorization: "Bearer auth-token",
        "X-Firebase-AppCheck": "app-check-token"}}));
  await expect(catchWhatsappTrialApi.review(eventId, scope)).rejects.toThrow();
  expect(f.fetch).toHaveBeenCalledOnce();
});

it("fences account changes after preparation and immediately before fetch", async () => {
  const guard = await catchWhatsappTrialApi.prepare(scope);
  f.auth.currentUser = {...f.user};
  expect(guard).toThrow(/session/);
  await expect(catchWhatsappTrialApi.review(eventId, scope)).rejects.toThrow();
  expect(f.fetch).not.toHaveBeenCalled();
});

it("validates both wire schemas and drops unexpected private response fields",
  async () => {
    await catchWhatsappTrialApi.prepare(scope);
    await expect(catchWhatsappTrialApi.review("invalid", scope)).rejects.toThrow();
    expect(f.fetch).not.toHaveBeenCalled();
    f.fetch.mockResolvedValue({ok: true,
      json: async () => ({data: {...review, accessToken: "private"}})});
    await expect(catchWhatsappTrialApi.review(eventId, scope)).rejects.toThrow();
  });

it("drops late results and sanitizes upstream errors and details", async () => {
  let current = true;
  const scoped = {...scope, isCurrent: () => current};
  await catchWhatsappTrialApi.prepare(scoped);
  f.fetch.mockImplementation(async () => {
    current = false;
    return {ok: true, json: async () => ({data: review})};
  });
  await expect(catchWhatsappTrialApi.review(eventId, scoped)).rejects.toThrow(
    "Support action outcome is unavailable.");
  current = true;
  await catchWhatsappTrialApi.prepare(scoped);
  f.fetch.mockResolvedValue({ok: true,
    json: async () => ({error: {message: "PRIVATE", details: "PRIVATE"}})});
  await expect(catchWhatsappTrialApi.review(eventId, scoped)).rejects.toThrow(
    "Support action outcome is unavailable.");
});
