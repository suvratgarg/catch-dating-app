import {auth} from "../../../shared/api/firebase";
import {adminAppCheck, firebaseApp} from "../../../shared/api/firebaseCore";
import {dataMode} from "../../../shared/api/dataMode";
import type {CatchTrialScope} from "./catchWhatsappTrialRepository";

// This names the owner's existing Remote Config parameter; it is not an
// enablement value and has no default that could activate the production UI.
const configuredKey = () => import.meta.env.VITE_CATCH_WHATSAPP_REMOTE_CONFIG_KEY;
let observed: {projectId: string; actorUid: string; sessionKey: string;
  key: string; expiresAt: number; enabled: boolean} | undefined;
let generation = 0;

function current(scope: CatchTrialScope): boolean {
  return dataMode() === "live" && Boolean(adminAppCheck) &&
    Boolean(import.meta.env.VITE_ADMIN_APPCHECK_SITE_KEY) &&
    /^[A-Za-z][A-Za-z0-9_]{0,127}$/u.test(configuredKey() ?? "") &&
    /^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(scope.projectId) &&
    scope.projectId === firebaseApp.options.projectId &&
    Boolean(scope.sessionKey) && scope.actorUid === auth.currentUser?.uid &&
    scope.isCurrent();
}

export function catchWhatsappSupportAvailable(scope: CatchTrialScope): boolean {
  return current(scope) && observed?.enabled === true &&
    observed.projectId === scope.projectId && observed.actorUid === scope.actorUid &&
    observed.sessionKey === scope.sessionKey && observed.key === configuredKey() &&
    observed.expiresAt > Date.now();
}

export async function refreshCatchWhatsappAvailability(scope: CatchTrialScope): Promise<boolean> {
  const request = ++generation;
  if (!catchWhatsappSupportAvailable(scope)) observed = undefined;
  const unavailable = () => {
    if (request === generation) observed = undefined;
    return false;
  };
  if (!current(scope)) return false;
  const key = configuredKey()!;
  try {
    const {fetchAndActivate, getRemoteConfig, getValue, isSupported} =
      await import("firebase/remote-config");
    if (!await isSupported() || !current(scope) || request !== generation) return unavailable();
    const config = getRemoteConfig(firebaseApp);
    config.settings = {minimumFetchIntervalMillis: 0, fetchTimeoutMillis: 10000};
    await fetchAndActivate(config);
    if (!current(scope) || configuredKey() !== key || request !== generation ||
        config.lastFetchStatus !== "success") return unavailable();
    const value = getValue(config, key);
    observed = {projectId: scope.projectId, actorUid: scope.actorUid,
      sessionKey: scope.sessionKey, key, expiresAt: Date.now() + 30000,
      enabled: value.getSource() === "remote" && value.asBoolean()};
    return catchWhatsappSupportAvailable(scope);
  } catch {
    return unavailable();
  }
}
