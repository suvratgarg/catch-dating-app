import {developmentFirebaseConfig, firebaseConfigFromEnvironment} from "@catch/web-config/firebase";
export type {FirebaseConfig} from "@catch/web-config/firebase";

export const firebaseConfig = firebaseConfigFromEnvironment(import.meta.env) ??
  (import.meta.env.DEV ? developmentFirebaseConfig : null);
export const appCheckSiteKey = import.meta.env.VITE_WEBSITE_APPCHECK_SITE_KEY;

export const claimFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
export const publicReviewsFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
export const publicAnalyticsFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
export const publicEventRegistrationFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
export const eventRuntimeFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
export const publicFormsFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
