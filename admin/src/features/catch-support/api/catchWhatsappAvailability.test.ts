import {beforeEach, expect, it, vi} from "vitest";
const f = vi.hoisted(() => ({auth: {currentUser: {uid: "operator"}},
  app: {options: {projectId: "catch-prod-synthetic"}},
  config: {settings: {}, lastFetchStatus: "success"},
  fetch: vi.fn(), value: true, source: "remote"}));
vi.mock("../../../shared/api/firebase", () => ({auth: f.auth}));
vi.mock("../../../shared/api/firebaseCore", () => ({firebaseApp: f.app, adminAppCheck: {}}));
vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => "live"}));
vi.mock("firebase/remote-config", () => ({isSupported: async () => true,
  getRemoteConfig: () => f.config, fetchAndActivate: f.fetch,
  getValue: (_config: unknown, key: string) => {
    expect(key).toBe("synthetic_owner_key");
    return {getSource: () => f.source, asBoolean: () => f.value};
  }}));
const scope = {projectId: "catch-prod-synthetic", actorUid: "operator",
  sessionKey: "current-session", isCurrent: () => true};
beforeEach(() => {
  vi.resetModules(); f.fetch.mockReset().mockResolvedValue(true);
  f.auth.currentUser = {uid: "operator"}; f.config.lastFetchStatus = "success";
  f.source = "remote"; f.value = true;
  vi.stubEnv("VITE_CATCH_WHATSAPP_REMOTE_CONFIG_KEY", "synthetic_owner_key");
  vi.stubEnv("VITE_ADMIN_APPCHECK_SITE_KEY", "synthetic-site-key");
});

it("allows the initialized production project only from successful remote availability", async () => {
  const api = await import("./catchWhatsappAvailability");
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(false);
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(true);
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(true);
  expect(api.catchWhatsappSupportAvailable({...scope, sessionKey: "other"})).toBe(false);
  expect(api.catchWhatsappSupportAvailable({...scope, projectId: "catchdates-dev"})).toBe(false);
});

it("rejects missing key, default/local values and failed fetch without a usable gate", async () => {
  const api = await import("./catchWhatsappAvailability");
  vi.stubEnv("VITE_CATCH_WHATSAPP_REMOTE_CONFIG_KEY", "");
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(false);
  expect(f.fetch).not.toHaveBeenCalled();
  vi.stubEnv("VITE_CATCH_WHATSAPP_REMOTE_CONFIG_KEY", "synthetic_owner_key");
  for (const source of ["default", "static"]) {
    f.source = source;
    expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(false);
  }
  f.source = "remote"; f.fetch.mockRejectedValue(new Error("private upstream detail"));
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(false);
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(false);
});

it("preserves a still-current value during refresh, then invalidates on disabled result", async () => {
  const api = await import("./catchWhatsappAvailability");
  await api.refreshCatchWhatsappAvailability(scope);
  let release!: () => void;
  f.fetch.mockImplementationOnce(() => new Promise<void>(resolve => {release = resolve;}));
  const pending = api.refreshCatchWhatsappAvailability(scope);
  await vi.waitFor(() => expect(release).toBeTypeOf("function"));
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(true);
  f.value = false; release();
  expect(await pending).toBe(false);
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(false);
});

it("drops a result after session retirement and never enables a different actor", async () => {
  const api = await import("./catchWhatsappAvailability");
  let current = true; let release!: () => void;
  f.fetch.mockImplementationOnce(() => new Promise<void>(resolve => {release = resolve;}));
  const pending = api.refreshCatchWhatsappAvailability({...scope, isCurrent: () => current});
  await vi.waitFor(() => expect(release).toBeTypeOf("function"));
  current = false; f.auth.currentUser = {uid: "other"}; release();
  expect(await pending).toBe(false);
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(false);
});
