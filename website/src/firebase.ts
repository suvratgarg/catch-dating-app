import {initializeApp} from "firebase/app";
import {initializeAppCheck, ReCaptchaV3Provider} from "firebase/app-check";
import {
  getAuth,
  GoogleAuthProvider,
  onAuthStateChanged,
  signInWithPopup,
  signOut,
  User,
} from "firebase/auth";
import {getFunctions, httpsCallable} from "firebase/functions";
import type {CreatePublicClubReviewCallablePayload} from "../../functions/src/shared/generated/createPublicClubReviewCallablePayload";
import type {CreatePublicClubReviewCallableResponse} from "../../functions/src/shared/generated/createPublicClubReviewCallableResponse";
import type {ListPublicClubReviewsCallablePayload} from "../../functions/src/shared/generated/listPublicClubReviewsCallablePayload";
import type {ListPublicClubReviewsCallableResponse} from "../../functions/src/shared/generated/listPublicClubReviewsCallableResponse";
import type {RecordOrganizerAnalyticsEventCallablePayload} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallablePayload";
import type {RecordOrganizerAnalyticsEventCallableResponse} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallableResponse";
import type {RequestClubClaimCallablePayload} from "../../functions/src/shared/generated/requestClubClaimCallablePayload";
import type {RequestClubClaimCallableResponse} from "../../functions/src/shared/generated/requestClubClaimCallableResponse";

const devFirebaseConfig = {
  apiKey: "AIzaSyAl271K9YGiYZOEcNgoEwZiOQV0ydpWfrg",
  appId: "1:619661127800:web:b0673ad370947b2f077d8d",
  messagingSenderId: "619661127800",
  projectId: "catchdates-dev",
  authDomain: "catchdates-dev.firebaseapp.com",
  storageBucket: "catchdates-dev.firebasestorage.app",
  measurementId: "G-TCR62QJVH9",
};

interface FirebaseConfig {
  apiKey: string;
  authDomain: string;
  projectId: string;
  storageBucket: string;
  messagingSenderId: string;
  appId: string;
  measurementId?: string;
}

export type RequestClubClaimPayload = RequestClubClaimCallablePayload;
export type ClubClaimRole = RequestClubClaimPayload["requesterRole"];
export type RequestClubClaimResponse = RequestClubClaimCallableResponse;
export type PublicClubReview = CreatePublicClubReviewCallableResponse["review"];

export type CreatePublicClubReviewPayload =
  CreatePublicClubReviewCallablePayload;
export type CreatePublicClubReviewResponse =
  CreatePublicClubReviewCallableResponse;

export type ListPublicClubReviewsPayload = ListPublicClubReviewsCallablePayload;
export type ListPublicClubReviewsResponse =
  ListPublicClubReviewsCallableResponse;

export type RecordOrganizerAnalyticsEventPayload =
  RecordOrganizerAnalyticsEventCallablePayload;
export type RecordOrganizerAnalyticsEventResponse =
  RecordOrganizerAnalyticsEventCallableResponse;

const config = resolveFirebaseConfig();
const app = config ? initializeApp(config) : null;
const appCheckSiteKey = import.meta.env.VITE_WEBSITE_APPCHECK_SITE_KEY;

if (app && appCheckSiteKey) {
  initializeAppCheck(app, {
    provider: new ReCaptchaV3Provider(appCheckSiteKey),
    isTokenAutoRefreshEnabled: true,
  });
}

export const claimFirebaseConfigured = Boolean(app && appCheckSiteKey);
export const publicReviewsFirebaseConfigured = Boolean(app && appCheckSiteKey);
export const publicAnalyticsFirebaseConfigured = Boolean(app && appCheckSiteKey);
export const auth = app ? getAuth(app) : null;
const functions = app ? getFunctions(app, "asia-south1") : null;

export type {User};

export function watchClaimAuthState(
  callback: (user: User | null) => void
): () => void {
  if (!auth) {
    callback(null);
    return () => undefined;
  }
  return onAuthStateChanged(auth, callback);
}

export async function signInForClaim() {
  if (!auth) {
    throw new Error("Claim sign-in is not configured for this build.");
  }
  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({prompt: "select_account"});
  await signInWithPopup(auth, provider);
}

export async function signOutClaimUser() {
  if (!auth) return;
  await signOut(auth);
}

export async function requestClubClaim(
  payload: RequestClubClaimPayload
): Promise<RequestClubClaimResponse> {
  if (!functions || !claimFirebaseConfigured) {
    throw new Error("Claim requests are not configured for this build.");
  }
  const callable = httpsCallable<
    RequestClubClaimPayload,
    RequestClubClaimResponse
  >(functions, "requestClubClaim");
  const result = await callable(payload);
  return result.data;
}

export async function createPublicClubReview(
  payload: CreatePublicClubReviewPayload
): Promise<CreatePublicClubReviewResponse> {
  if (!functions || !publicReviewsFirebaseConfigured) {
    throw new Error("Public review writes are not configured for this build.");
  }
  const callable = httpsCallable<
    CreatePublicClubReviewPayload,
    CreatePublicClubReviewResponse
  >(functions, "createPublicClubReview");
  const result = await callable(payload);
  return result.data;
}

export async function listPublicClubReviews(
  payload: ListPublicClubReviewsPayload
): Promise<ListPublicClubReviewsResponse> {
  if (!functions || !publicReviewsFirebaseConfigured) {
    return {reviews: []};
  }
  const callable = httpsCallable<
    ListPublicClubReviewsPayload,
    ListPublicClubReviewsResponse
  >(functions, "listPublicClubReviews");
  const result = await callable(payload);
  return result.data;
}

export async function recordOrganizerAnalyticsEvent(
  payload: RecordOrganizerAnalyticsEventPayload
): Promise<RecordOrganizerAnalyticsEventResponse> {
  if (!functions || !publicAnalyticsFirebaseConfigured) {
    return {accepted: false};
  }
  const callable = httpsCallable<
    RecordOrganizerAnalyticsEventPayload,
    RecordOrganizerAnalyticsEventResponse
  >(functions, "recordOrganizerAnalyticsEvent");
  const result = await callable(payload);
  return result.data;
}

function resolveFirebaseConfig(): FirebaseConfig | null {
  const explicitConfig = {
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
    authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
    projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
    storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
    appId: import.meta.env.VITE_FIREBASE_APP_ID,
    measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID,
  };

  if (
    explicitConfig.apiKey &&
    explicitConfig.authDomain &&
    explicitConfig.projectId &&
    explicitConfig.storageBucket &&
    explicitConfig.messagingSenderId &&
    explicitConfig.appId
  ) {
    return explicitConfig;
  }

  return import.meta.env.DEV ? devFirebaseConfig : null;
}
