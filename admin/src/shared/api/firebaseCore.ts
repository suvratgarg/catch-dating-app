import {initializeApp} from "firebase/app";
import {initializeAppCheck, ReCaptchaV3Provider} from "firebase/app-check";

import {developmentFirebaseConfig, firebaseConfigFromEnvironment} from "@catch/web-config/firebase";

export function firebaseConfig() {
  // Preserve the existing Admin environment policy; production build validation
  // separately requires the configured project. Public surfaces fail closed.
  return firebaseConfigFromEnvironment(import.meta.env, developmentFirebaseConfig)!;
}

export const firebaseApp = initializeApp(firebaseConfig());
const appCheckSiteKey = import.meta.env.VITE_ADMIN_APPCHECK_SITE_KEY;

export const adminAppCheck = appCheckSiteKey ? initializeAppCheck(firebaseApp, {
  provider: new ReCaptchaV3Provider(appCheckSiteKey),
  isTokenAutoRefreshEnabled: true,
}) : null;
