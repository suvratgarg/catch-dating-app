import {readFileSync} from "node:fs";
import {dirname, resolve} from "node:path";
import {fileURLToPath} from "node:url";
import {beforeEach, expect, it, vi} from "vitest";
const f = vi.hoisted(() => ({auth: {currentUser: {uid: "operator"}},
  app: {options: {projectId: "catch-prod-synthetic"}},
  config: {settings: {}, defaultConfig: {other_parameter: "preserved"}, lastFetchStatus: "success"},
  fetch: vi.fn(), value: true, source: "remote"}));
vi.mock("../../../shared/api/firebase", () => ({auth: f.auth}));
vi.mock("../../../shared/api/firebaseCore", () => ({firebaseApp: f.app, adminAppCheck: {}}));
vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => "live"}));
vi.mock("firebase/remote-config", () => ({isSupported: async () => true,
  getRemoteConfig: () => f.config, fetchAndActivate: f.fetch,
  getValue: (_config: unknown, key: string) => {
    expect(key).toBe("catch_whatsapp_support_enabled");
    return {getSource: () => f.source, asBoolean: () => f.value};
  }}));
const scope = {projectId: "catch-prod-synthetic", actorUid: "operator",
  sessionKey: "current-session", isCurrent: () => true};
beforeEach(() => {
  vi.resetModules(); f.fetch.mockReset().mockResolvedValue(true);
  f.auth.currentUser = {uid: "operator"}; f.config.lastFetchStatus = "success";
  f.config.defaultConfig = {other_parameter: "preserved"};
  f.source = "remote"; f.value = true;
  vi.stubEnv("VITE_ADMIN_APPCHECK_SITE_KEY", "synthetic-site-key");
});

it("declares matching false client/template defaults and allows current-project remote true", async () => {
  const here = dirname(fileURLToPath(import.meta.url));
  const template = JSON.parse(readFileSync(resolve(here,
    "../../../../../firebase/remote_config.template.json"), "utf8"));
  expect(template.parameters.catch_whatsapp_support_enabled.defaultValue.value).toBe("false");
  expect(template.parameters.catch_whatsapp_support_enabled.conditionalValues).toBeUndefined();
  const api = await import("./catchWhatsappAvailability");
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(false);
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(true);
  expect(f.config.defaultConfig).toEqual({other_parameter: "preserved",
    catch_whatsapp_support_enabled: false});
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(true);
  expect(api.catchWhatsappSupportAvailable({...scope, sessionKey: "other"})).toBe(false);
  expect(api.catchWhatsappSupportAvailable({...scope, projectId: "catchdates-dev"})).toBe(false);
});

it.each([
  ["static", false], ["default", false], ["static", true], ["default", true], ["remote", false],
])("keeps absent/default/local values and remote false closed (%s, %s)", async (source, value) => {
  const api = await import("./catchWhatsappAvailability");
  f.source = source as string; f.value = value as boolean;
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(false);
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(false);
});

it("rejects a different initialized project before fetching", async () => {
  const api = await import("./catchWhatsappAvailability");
  expect(await api.refreshCatchWhatsappAvailability({...scope, projectId: "catchdates-dev"})).toBe(false);
  expect(f.fetch).not.toHaveBeenCalled();
});

it("invalidates prior remote true when fetching fails or reports an unsuccessful status", async () => {
  const api = await import("./catchWhatsappAvailability");
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(true);
  f.fetch.mockRejectedValueOnce(new Error("private upstream detail"));
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(false);
  expect(api.catchWhatsappSupportAvailable(scope)).toBe(false);
  expect(await api.refreshCatchWhatsappAvailability(scope)).toBe(true);
  f.config.lastFetchStatus = "failure";
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
