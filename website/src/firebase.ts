import type {FirebaseApp} from "firebase/app";
import type {Auth, User} from "firebase/auth";
import type {Functions} from "firebase/functions";
import type {CreatePublicClubReviewCallablePayload} from "../../functions/src/shared/generated/createPublicClubReviewCallablePayload";
import type {CreatePublicClubReviewCallableResponse} from "../../functions/src/shared/generated/createPublicClubReviewCallableResponse";
import type {ListPublicClubReviewsCallablePayload} from "../../functions/src/shared/generated/listPublicClubReviewsCallablePayload";
import type {ListPublicClubReviewsCallableResponse} from "../../functions/src/shared/generated/listPublicClubReviewsCallableResponse";
import type {RecordOrganizerAnalyticsEventCallablePayload} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallablePayload";
import type {RecordOrganizerAnalyticsEventCallableResponse} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallableResponse";
import type {RequestClubClaimCallablePayload} from "../../functions/src/shared/generated/requestClubClaimCallablePayload";
import type {RequestClubClaimCallableResponse} from "../../functions/src/shared/generated/requestClubClaimCallableResponse";
import {
  appCheckSiteKey,
  claimFirebaseConfigured,
  firebaseConfig as config,
  publicAnalyticsFirebaseConfigured,
  publicReviewsFirebaseConfigured,
} from "./firebaseConfig";

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

let runtimePromise: Promise<FirebaseRuntime | null> | null = null;

interface FirebaseRuntime {
  app: FirebaseApp;
  auth: Auth;
  functions: Functions;
}

export type {User};

export function watchClaimAuthState(
  callback: (user: User | null) => void
): () => void {
  if (!claimFirebaseConfigured) {
    callback(null);
    return () => undefined;
  }
  let cancelled = false;
  let unsubscribe: () => void = () => undefined;
  void getFirebaseRuntime()
    .then(async (runtime) => {
      if (!runtime) {
        callback(null);
        return;
      }
      const {onAuthStateChanged} = await import("firebase/auth");
      if (cancelled) return;
      unsubscribe = onAuthStateChanged(runtime.auth, callback);
    })
    .catch(() => {
      callback(null);
    });
  return () => {
    cancelled = true;
    unsubscribe();
  };
}

export async function signInForClaim() {
  const runtime = await getFirebaseRuntime();
  if (!runtime) {
    throw new Error("Claim sign-in is not configured for this build.");
  }
  const {GoogleAuthProvider, signInWithPopup} = await import("firebase/auth");
  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({prompt: "select_account"});
  await signInWithPopup(runtime.auth, provider);
}

export async function signOutClaimUser() {
  const runtime = await getFirebaseRuntime();
  if (!runtime) return;
  const {signOut} = await import("firebase/auth");
  await signOut(runtime.auth);
}

export async function requestClubClaim(
  payload: RequestClubClaimPayload
): Promise<RequestClubClaimResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !claimFirebaseConfigured) {
    throw new Error("Claim requests are not configured for this build.");
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    RequestClubClaimPayload,
    RequestClubClaimResponse
  >(runtime.functions, "requestClubClaim");
  const result = await callable(payload);
  return result.data;
}

export async function createPublicClubReview(
  payload: CreatePublicClubReviewPayload
): Promise<CreatePublicClubReviewResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicReviewsFirebaseConfigured) {
    throw new Error("Public review writes are not configured for this build.");
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    CreatePublicClubReviewPayload,
    CreatePublicClubReviewResponse
  >(runtime.functions, "createPublicClubReview");
  const result = await callable(payload);
  return result.data;
}

export async function listPublicClubReviews(
  payload: ListPublicClubReviewsPayload
): Promise<ListPublicClubReviewsResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicReviewsFirebaseConfigured) {
    return {reviews: []};
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    ListPublicClubReviewsPayload,
    ListPublicClubReviewsResponse
  >(runtime.functions, "listPublicClubReviews");
  const result = await callable(payload);
  return result.data;
}

export async function recordOrganizerAnalyticsEvent(
  payload: RecordOrganizerAnalyticsEventPayload
): Promise<RecordOrganizerAnalyticsEventResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicAnalyticsFirebaseConfigured) {
    return {accepted: false};
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    RecordOrganizerAnalyticsEventPayload,
    RecordOrganizerAnalyticsEventResponse
  >(runtime.functions, "recordOrganizerAnalyticsEvent");
  const result = await callable(payload);
  return result.data;
}

async function getFirebaseRuntime() {
  if (!config || !appCheckSiteKey) return null;
  runtimePromise ??= loadFirebaseRuntime();
  return runtimePromise;
}

async function loadFirebaseRuntime(): Promise<FirebaseRuntime | null> {
  if (!config || !appCheckSiteKey) return null;
  const [
    {initializeApp},
    {initializeAppCheck, ReCaptchaV3Provider},
    {getAuth},
    {getFunctions},
  ] = await Promise.all([
    import("firebase/app"),
    import("firebase/app-check"),
    import("firebase/auth"),
    import("firebase/functions"),
  ]);
  const app = initializeApp(config);
  initializeAppCheck(app, {
    provider: new ReCaptchaV3Provider(appCheckSiteKey),
    isTokenAutoRefreshEnabled: true,
  });
  return {
    app,
    auth: getAuth(app),
    functions: getFunctions(app, "asia-south1"),
  };
}
