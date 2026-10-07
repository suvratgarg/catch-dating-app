import {auth} from "../../../shared/api/firebase";
import {adminAppCheck, firebaseApp} from "../../../shared/api/firebaseCore";
import {dataMode} from "../../../shared/api/dataMode";
import type {CatchTrialScope} from "./catchWhatsappTrialRepository";

// Canonical client availability contract. Only remote-origin true may open it;
// source defaults never approve setup, grant access or authorize a reply.
const availabilityKey = "catch_whatsapp_support_enabled";
let observed: {projectId: string; actorUid: string; sessionKey: string;
  expiresAt: number; enabled: boolean} | undefined;
let generation = 0;

function current(scope: CatchTrialScope): boolean {
  return dataMode() === "live" && Boolean(adminAppCheck) &&
    Boolean(import.meta.env.VITE_ADMIN_APPCHECK_SITE_KEY) &&
    /^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(scope.projectId) &&
    scope.projectId === firebaseApp.options.projectId &&
    Boolean(scope.sessionKey) && scope.actorUid === auth.currentUser?.uid &&
    scope.isCurrent();
}

export function catchWhatsappSupportAvailable(scope: CatchTrialScope): boolean {
  return current(scope) && observed?.enabled === true &&
    observed.projectId === scope.projectId && observed.actorUid === scope.actorUid &&
    observed.sessionKey === scope.sessionKey &&
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
  try {
    const {fetchAndActivate, getRemoteConfig, getValue, isSupported} =
      await import("firebase/remote-config");
    if (!await isSupported() || !current(scope) || request !== generation) return unavailable();
    const config = getRemoteConfig(firebaseApp);
    config.defaultConfig = {...config.defaultConfig, [availabilityKey]: false};
    config.settings = {minimumFetchIntervalMillis: 0, fetchTimeoutMillis: 10000};
    await fetchAndActivate(config);
    if (!current(scope) || request !== generation ||
        config.lastFetchStatus !== "success") return unavailable();
    const value = getValue(config, availabilityKey);
    observed = {projectId: scope.projectId, actorUid: scope.actorUid,
      sessionKey: scope.sessionKey, expiresAt: Date.now() + 30000,
      enabled: value.getSource() === "remote" && value.asBoolean()};
    return catchWhatsappSupportAvailable(scope);
  } catch {
    return unavailable();
  }
}
