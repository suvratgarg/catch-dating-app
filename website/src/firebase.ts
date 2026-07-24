import type {FirebaseApp} from "firebase/app";
import type {Auth, User} from "firebase/auth";
import type {Functions} from "firebase/functions";
import type {CreatePublicOrganizerReviewCallablePayload} from "../../functions/src/shared/generated/createPublicOrganizerReviewCallablePayload";
import type {CreatePublicOrganizerReviewCallableResponse} from "../../functions/src/shared/generated/createPublicOrganizerReviewCallableResponse";
import type {ListPublicOrganizerReviewsCallablePayload} from "../../functions/src/shared/generated/listPublicOrganizerReviewsCallablePayload";
import type {ListPublicOrganizerReviewsCallableResponse} from "../../functions/src/shared/generated/listPublicOrganizerReviewsCallableResponse";
import type {RecordOrganizerAnalyticsEventCallablePayload} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallablePayload";
import type {RecordOrganizerAnalyticsEventCallableResponse} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallableResponse";
import type {RequestOrganizerClaimCallablePayload} from "../../functions/src/shared/generated/requestOrganizerClaimCallablePayload";
import type {RequestOrganizerClaimCallableResponse} from "../../functions/src/shared/generated/requestOrganizerClaimCallableResponse";
import {
  appCheckSiteKey,
  claimFirebaseConfigured,
  firebaseConfig as config,
  publicAnalyticsFirebaseConfigured,
  publicReviewsFirebaseConfigured,
} from "./firebaseConfig";

export type RequestOrganizerClaimPayload = RequestOrganizerClaimCallablePayload;
export type OrganizerClaimRole = RequestOrganizerClaimPayload["requesterRole"];
export type RequestOrganizerClaimResponse = RequestOrganizerClaimCallableResponse;
export type PublicOrganizerReview =
  CreatePublicOrganizerReviewCallableResponse["review"];

export type CreatePublicOrganizerReviewPayload =
  CreatePublicOrganizerReviewCallablePayload;
export type CreatePublicOrganizerReviewResponse =
  CreatePublicOrganizerReviewCallableResponse;

export type ListPublicOrganizerReviewsPayload =
  ListPublicOrganizerReviewsCallablePayload;
export type ListPublicOrganizerReviewsResponse =
  ListPublicOrganizerReviewsCallableResponse;

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

export async function requestOrganizerClaim(
  payload: RequestOrganizerClaimPayload
): Promise<RequestOrganizerClaimResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !claimFirebaseConfigured) {
    throw new Error("Claim requests are not configured for this build.");
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    RequestOrganizerClaimPayload,
    RequestOrganizerClaimResponse
  >(runtime.functions, "requestOrganizerClaim");
  const result = await callable(payload);
  return result.data;
}

export async function createPublicOrganizerReview(
  payload: CreatePublicOrganizerReviewPayload
): Promise<CreatePublicOrganizerReviewResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicReviewsFirebaseConfigured) {
    throw new Error("Public review writes are not configured for this build.");
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    CreatePublicOrganizerReviewPayload,
    CreatePublicOrganizerReviewResponse
  >(runtime.functions, "createPublicOrganizerReview");
  const result = await callable(payload);
  return result.data;
}

export async function listPublicOrganizerReviews(
  payload: ListPublicOrganizerReviewsPayload
): Promise<ListPublicOrganizerReviewsResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicReviewsFirebaseConfigured) {
    return {reviews: []};
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    ListPublicOrganizerReviewsPayload,
    ListPublicOrganizerReviewsResponse
  >(runtime.functions, "listPublicOrganizerReviews");
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
