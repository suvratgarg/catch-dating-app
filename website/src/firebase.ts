import type {FirebaseApp} from "firebase/app";
import type {Auth, User} from "firebase/auth";
import type {Functions} from "firebase/functions";
import type {Firestore} from "firebase/firestore";
import type {CheckInEventRuntimeCallablePayload} from "../../functions/src/shared/generated/checkInEventRuntimeCallablePayload";
import type {CheckInEventRuntimeCallableResponse} from "../../functions/src/shared/generated/checkInEventRuntimeCallableResponse";
import type {ClaimEventRuntimeAccessCallablePayload} from "../../functions/src/shared/generated/claimEventRuntimeAccessCallablePayload";
import type {ClaimEventRuntimeAccessCallableResponse} from "../../functions/src/shared/generated/claimEventRuntimeAccessCallableResponse";
import type {CompleteEventSuccessFirstHelloMissionCallablePayload} from "../../functions/src/shared/generated/completeEventSuccessFirstHelloMissionCallablePayload";
import type {BeginOrganizerFormResponseCallablePayload} from "../../functions/src/shared/generated/beginOrganizerFormResponseCallablePayload";
import type {BeginOrganizerFormResponseCallableResponse} from "../../functions/src/shared/generated/beginOrganizerFormResponseCallableResponse";
import type {CreateEventInviteLinkCallablePayload} from "../../functions/src/shared/generated/createEventInviteLinkCallablePayload";
import type {CreatePublicOrganizerReviewCallablePayload} from "../../functions/src/shared/generated/createPublicOrganizerReviewCallablePayload";
import type {CreatePublicOrganizerReviewCallableResponse} from "../../functions/src/shared/generated/createPublicOrganizerReviewCallableResponse";
import type {EventSuccessAssignmentDocument} from "../../functions/src/shared/generated/eventSuccessAssignmentDocument";
import type {EventSuccessLateArrivalDocument} from "../../functions/src/shared/generated/eventSuccessLateArrivalDocument";
import type {EventSuccessStandingsDocument} from "../../functions/src/shared/generated/eventSuccessStandingsDocument";
export {
  deriveEventSuccessMomentSeed,
  eventSuccessMomentPresentationCatalog,
  eventSuccessMomentPresentationFor,
  eventSuccessSocialMissionPromptFor,
  resolveEventSuccessCeremonyTimeline,
} from "../../functions/src/shared/generated/eventSuccessMomentPresentations";
export type {
  EventSuccessCeremonyTimeline,
  EventSuccessMomentPresentationContract,
  EventSuccessDisclosureLevel,
  EventSuccessInteractionModel,
  EventSuccessSocialMissionPromptContract,
} from "../../functions/src/shared/generated/eventSuccessMomentPresentations";
import type {EventIdCallablePayload} from "../../functions/src/shared/generated/eventIdCallablePayload";
import type {FetchEventSuccessWingmanCandidatesCallableResponse} from "../../functions/src/shared/generated/fetchEventSuccessWingmanCandidatesCallableResponse";
import type {GetEventRuntimeBootstrapCallablePayload} from "../../functions/src/shared/generated/getEventRuntimeBootstrapCallablePayload";
import type {GetEventRuntimeBootstrapCallableResponse} from "../../functions/src/shared/generated/getEventRuntimeBootstrapCallableResponse";
import type {GetPublicOrganizerFormCallablePayload} from "../../functions/src/shared/generated/getPublicOrganizerFormCallablePayload";
import type {GetPublicOrganizerFormCallableResponse} from "../../functions/src/shared/generated/getPublicOrganizerFormCallableResponse";
import type {GetEventSuccessConversationGraphCallableResponse} from "../../functions/src/shared/generated/getEventSuccessConversationGraphCallableResponse";
import type {HeartbeatEventSuccessPresenceCallableResponse} from "../../functions/src/shared/generated/heartbeatEventSuccessPresenceCallableResponse";
import type {ListPublicOrganizerReviewsCallablePayload} from "../../functions/src/shared/generated/listPublicOrganizerReviewsCallablePayload";
import type {ListPublicOrganizerReviewsCallableResponse} from "../../functions/src/shared/generated/listPublicOrganizerReviewsCallableResponse";
import type {RecordOrganizerAnalyticsEventCallablePayload} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallablePayload";
import type {RecordOrganizerAnalyticsEventCallableResponse} from "../../functions/src/shared/generated/recordOrganizerAnalyticsEventCallableResponse";
import type {RecordEventInviteLinkOpenCallablePayload} from "../../functions/src/shared/generated/recordEventInviteLinkOpenCallablePayload";
import type {RecordEventShareIntentCallablePayload} from "../../functions/src/shared/generated/recordEventShareIntentCallablePayload";
import type {RegisterPublicEventCallablePayload} from "../../functions/src/shared/generated/registerPublicEventCallablePayload";
import type {RegisterPublicEventCallableResponse} from "../../functions/src/shared/generated/registerPublicEventCallableResponse";
import type {ResolveEventInviteLandingCallablePayload} from "../../functions/src/shared/generated/resolveEventInviteLandingCallablePayload";
import type {ResolveEventInviteLandingCallableResponse} from "../../functions/src/shared/generated/resolveEventInviteLandingCallableResponse";
import type {SaveOrganizerFormResponseDraftCallablePayload} from "../../functions/src/shared/generated/saveOrganizerFormResponseDraftCallablePayload";
import type {SaveOrganizerFormResponseDraftCallableResponse} from "../../functions/src/shared/generated/saveOrganizerFormResponseDraftCallableResponse";
import type {RequestOrganizerClaimCallablePayload} from "../../functions/src/shared/generated/requestOrganizerClaimCallablePayload";
import type {RequestOrganizerClaimCallableResponse} from "../../functions/src/shared/generated/requestOrganizerClaimCallableResponse";
import type {StartEventSuccessFirstHelloMissionCallablePayload} from "../../functions/src/shared/generated/startEventSuccessFirstHelloMissionCallablePayload";
import type {SubmitEventRuntimeProfileCallablePayload} from "../../functions/src/shared/generated/submitEventRuntimeProfileCallablePayload";
import type {SubmitEventRuntimeProfileCallableResponse} from "../../functions/src/shared/generated/submitEventRuntimeProfileCallableResponse";
import type {SubmitEventSuccessConversationGraphCallablePayload} from "../../functions/src/shared/generated/submitEventSuccessConversationGraphCallablePayload";
import type {SubmitEventSuccessConversationGraphCallableResponse} from "../../functions/src/shared/generated/submitEventSuccessConversationGraphCallableResponse";
import type {SubmitEventSuccessWingmanRequestCallablePayload} from "../../functions/src/shared/generated/submitEventSuccessWingmanRequestCallablePayload";
import type {SubmitOrganizerFormResponseCallablePayload} from "../../functions/src/shared/generated/submitOrganizerFormResponseCallablePayload";
import type {SubmitOrganizerFormResponseCallableResponse} from "../../functions/src/shared/generated/submitOrganizerFormResponseCallableResponse";
import type {WithdrawOrganizerFormResponseCallablePayload} from "../../functions/src/shared/generated/withdrawOrganizerFormResponseCallablePayload";
import type {WithdrawOrganizerFormResponseCallableResponse} from "../../functions/src/shared/generated/withdrawOrganizerFormResponseCallableResponse";
import {
  appCheckSiteKey,
  claimFirebaseConfigured,
  eventRuntimeFirebaseConfigured,
  firebaseConfig as config,
  publicAnalyticsFirebaseConfigured,
  publicEventRegistrationFirebaseConfigured,
  publicFormsFirebaseConfigured,
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
export type RegisterPublicEventPayload = RegisterPublicEventCallablePayload;
export type RegisterPublicEventResponse = RegisterPublicEventCallableResponse;
export type EventRuntimeBootstrap = GetEventRuntimeBootstrapCallableResponse;
export type EventSuccessConversationGraph =
  GetEventSuccessConversationGraphCallableResponse;
export type EventInviteLanding = ResolveEventInviteLandingCallableResponse;
export type PublicOrganizerForm = GetPublicOrganizerFormCallableResponse;
export type PublicOrganizerFormDraft =
  BeginOrganizerFormResponseCallableResponse;
export type PublicOrganizerFormReceipt =
  SubmitOrganizerFormResponseCallableResponse;

export interface PublicEventPhoneVerification {
  clear: () => void;
  confirm: (code: string) => Promise<User>;
}

export interface EventRuntimeAttendeeInviteLink {
  inviteLinkId: string;
  inviteToken: string;
  eventId: string;
  label: string;
  source: string | null;
}

let runtimePromise: Promise<FirebaseRuntime | null> | null = null;

interface FirebaseRuntime {
  app: FirebaseApp;
  auth: Auth;
  firestore: Firestore;
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

export const watchEventRuntimeAuthState = watchClaimAuthState;
export const watchPublicFormAuthState = watchClaimAuthState;

export async function getPublicOrganizerForm(
  payload: GetPublicOrganizerFormCallablePayload
): Promise<GetPublicOrganizerFormCallableResponse> {
  return invokeWebsiteCallable(
    "getPublicOrganizerForm",
    payload,
    publicFormsFirebaseConfigured,
    "Public forms"
  );
}

export async function beginOrganizerFormResponse(
  payload: BeginOrganizerFormResponseCallablePayload
): Promise<BeginOrganizerFormResponseCallableResponse> {
  return invokeWebsiteCallable(
    "beginOrganizerFormResponse",
    payload,
    publicFormsFirebaseConfigured,
    "Public forms"
  );
}

export async function saveOrganizerFormResponseDraft(
  payload: SaveOrganizerFormResponseDraftCallablePayload
): Promise<SaveOrganizerFormResponseDraftCallableResponse> {
  return invokeWebsiteCallable(
    "saveOrganizerFormResponseDraft",
    payload,
    publicFormsFirebaseConfigured,
    "Public forms"
  );
}

export async function submitOrganizerFormResponse(
  payload: SubmitOrganizerFormResponseCallablePayload
): Promise<SubmitOrganizerFormResponseCallableResponse> {
  return invokeWebsiteCallable(
    "submitOrganizerFormResponse",
    payload,
    publicFormsFirebaseConfigured,
    "Public forms"
  );
}

export async function withdrawOrganizerFormResponse(
  payload: WithdrawOrganizerFormResponseCallablePayload
): Promise<WithdrawOrganizerFormResponseCallableResponse> {
  return invokeWebsiteCallable(
    "withdrawOrganizerFormResponse",
    payload,
    publicFormsFirebaseConfigured,
    "Public forms"
  );
}

export async function sendPublicFormEmailSignInLink(
  email: string,
  returnUrl: string
): Promise<void> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicFormsFirebaseConfigured) {
    throw new Error("Public forms are not configured for this build.");
  }
  const {sendSignInLinkToEmail} = await import("firebase/auth");
  await sendSignInLinkToEmail(runtime.auth, email, {
    url: returnUrl,
    handleCodeInApp: true,
  });
}

export async function completePublicFormEmailSignIn(
  email: string,
  emailLink: string
): Promise<User> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicFormsFirebaseConfigured) {
    throw new Error("Public forms are not configured for this build.");
  }
  const {isSignInWithEmailLink, signInWithEmailLink} = await import(
    "firebase/auth"
  );
  if (!isSignInWithEmailLink(runtime.auth, emailLink)) {
    throw new Error("This email verification link is invalid or expired.");
  }
  return (await signInWithEmailLink(runtime.auth, email, emailLink)).user;
}

export interface EventRuntimeMission {
  observerUid: string;
  targetUid: string;
  targetDisplayName: string;
  targetContext: string;
  question: string;
  answerOptions: Array<{id: string; label: string}>;
  status: "active" | "completed" | "expired";
  selectedAnswerId?: string | null;
}

export interface EventRuntimeLiveState {
  assignments: EventSuccessAssignmentDocument[];
  compatibilityAnswerIds: string[];
  feedback: EventRuntimeFeedback | null;
  mission: EventRuntimeMission | null;
  lateArrival: EventSuccessLateArrivalDocument | null;
  plan: EventRuntimePlanState | null;
  standings: EventSuccessStandingsDocument | null;
  wingmanTargetUid: string | null;
}

export interface EventRuntimePlanState {
  attendeePrompt: string | null;
  activeStepIndex: number;
  activeRevealRoundIndex: number;
  publishedRevealRoundIndex: number;
  publishedRotationRoundIndex: number;
  revealCountdownSeconds: number | null;
  revealStartedAtMillis: number | null;
  revealStatus: "idle" | "countingDown" | "revealed";
  status: "setup" | "live" | "complete";
}

export interface EventRuntimeFeedback {
  welcomeRating: number;
  structureRating: number;
  metNewPeopleCount: number;
  safetyConcern: boolean;
  privateNote: string | null;
}

export interface EventRuntimeContext {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
}

export async function getEventRuntimeBootstrap(
  payload: GetEventRuntimeBootstrapCallablePayload
): Promise<GetEventRuntimeBootstrapCallableResponse> {
  return invokeWebsiteCallable(
    "getEventRuntimeBootstrap",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function claimEventRuntimeAccess(
  payload: ClaimEventRuntimeAccessCallablePayload
): Promise<ClaimEventRuntimeAccessCallableResponse> {
  return invokeWebsiteCallable(
    "claimEventRuntimeAccess",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function submitEventRuntimeProfile(
  payload: SubmitEventRuntimeProfileCallablePayload
): Promise<SubmitEventRuntimeProfileCallableResponse> {
  return invokeWebsiteCallable(
    "submitEventRuntimeProfile",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function checkInEventRuntime(
  payload: CheckInEventRuntimeCallablePayload
): Promise<CheckInEventRuntimeCallableResponse> {
  return invokeWebsiteCallable(
    "checkInEventRuntime",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function heartbeatEventRuntimePresence(
  eventId: string
): Promise<HeartbeatEventSuccessPresenceCallableResponse> {
  return invokeWebsiteCallable(
    "heartbeatEventSuccessPresence",
    {eventId, surface: "web"},
    eventRuntimeFirebaseConfigured
  );
}

export async function getEventSuccessConversationGraph(
  eventId: string
): Promise<GetEventSuccessConversationGraphCallableResponse> {
  return invokeWebsiteCallable(
    "getEventSuccessConversationGraph",
    {eventId},
    eventRuntimeFirebaseConfigured
  );
}

export async function submitEventSuccessConversationGraph(
  payload: SubmitEventSuccessConversationGraphCallablePayload
): Promise<SubmitEventSuccessConversationGraphCallableResponse> {
  return invokeWebsiteCallable(
    "submitEventSuccessConversationGraph",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function createEventRuntimeAttendeeInviteLink(
  eventId: string,
  label: string
): Promise<EventRuntimeAttendeeInviteLink> {
  const payload: CreateEventInviteLinkCallablePayload = {
    eventId,
    label,
    source: "runtime_web",
    linkKind: "attendeeReferrer",
  };
  return invokeWebsiteCallable(
    "createAttendeeInviteLink",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function recordEventRuntimeShareIntent(
  payload: Pick<
    RecordEventShareIntentCallablePayload,
    "eventId" | "inviteLinkId" | "channelHint"
  >
): Promise<{recorded: boolean}> {
  return invokeWebsiteCallable(
    "recordEventShareIntent",
    {...payload, surface: "runtimeWeb"},
    eventRuntimeFirebaseConfigured
  );
}

export async function startEventRuntimeFirstHello(
  payload: StartEventSuccessFirstHelloMissionCallablePayload
): Promise<{missionId: string; attended?: boolean}> {
  return invokeWebsiteCallable(
    "startEventSuccessFirstHelloMission",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function completeEventRuntimeFirstHello(
  payload: CompleteEventSuccessFirstHelloMissionCallablePayload
): Promise<{attended: boolean}> {
  return invokeWebsiteCallable(
    "completeEventSuccessFirstHelloMission",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function fetchEventRuntimeWingmanCandidates(
  payload: EventIdCallablePayload
): Promise<FetchEventSuccessWingmanCandidatesCallableResponse> {
  return invokeWebsiteCallable(
    "fetchEventSuccessWingmanCandidates",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function submitEventRuntimeWingmanRequest(
  payload: SubmitEventSuccessWingmanRequestCallablePayload
): Promise<{saved: boolean}> {
  return invokeWebsiteCallable(
    "submitEventSuccessWingmanRequest",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function withdrawEventRuntimeWingmanRequest(
  payload: EventIdCallablePayload
): Promise<{withdrawn: boolean}> {
  return invokeWebsiteCallable(
    "withdrawEventSuccessWingmanRequest",
    payload,
    eventRuntimeFirebaseConfigured
  );
}

export async function watchEventRuntimeLiveState(
  context: EventRuntimeContext,
  onValue: (state: EventRuntimeLiveState) => void,
  onError: (error: Error) => void
): Promise<() => void> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !eventRuntimeFirebaseConfigured) {
    throw new Error("Event runtime is not configured for this build.");
  }
  const {doc, onSnapshot} = await import("firebase/firestore");
  const state: EventRuntimeLiveState = {
    assignments: [],
    compatibilityAnswerIds: [],
    feedback: null,
    mission: null,
    lateArrival: null,
    plan: null,
    standings: null,
    wingmanTargetUid: null,
  };
  const assignmentByModule = new Map<string, EventSuccessAssignmentDocument>();
  const emit = () => onValue({
    ...state,
    assignments: [...assignmentByModule.values()],
    compatibilityAnswerIds: [...state.compatibilityAnswerIds],
  });
  const subscriptions = ["micro_pods", "guided_rotations"].map((moduleId) =>
    onSnapshot(
      doc(
        runtime.firestore,
        "eventSuccessAssignments",
        `${context.eventId}_${moduleId}_${context.uid}`
      ),
      (snapshot) => {
        if (snapshot.exists()) {
          assignmentByModule.set(
            moduleId,
            snapshot.data() as EventSuccessAssignmentDocument
          );
        } else {
          assignmentByModule.delete(moduleId);
        }
        emit();
      },
      (error) => onError(error)
    ));
  subscriptions.push(onSnapshot(
    doc(runtime.firestore, "eventSuccessPlans", context.eventId),
    (snapshot) => {
      const data = snapshot.data();
      const structureConfig = isRecord(data?.structureConfig) ?
        data.structureConfig : null;
      state.plan = data ? {
        attendeePrompt: typeof data.attendeePrompt === "string" ?
          data.attendeePrompt : null,
        activeStepIndex: Number.isInteger(data.activeStepIndex) ?
          Number(data.activeStepIndex) : 0,
        activeRevealRoundIndex: Number.isInteger(data.activeRevealRoundIndex) ?
          Number(data.activeRevealRoundIndex) : 0,
        publishedRevealRoundIndex: Number.isInteger(data.publishedRevealRoundIndex) ?
          Number(data.publishedRevealRoundIndex) : -1,
        publishedRotationRoundIndex: Number.isInteger(
          data.publishedRotationRoundIndex
        ) ? Number(data.publishedRotationRoundIndex) : -1,
        revealCountdownSeconds: Number.isInteger(
          structureConfig?.revealCountdownSeconds
        ) ? Number(structureConfig?.revealCountdownSeconds) : null,
        revealStartedAtMillis: eventRuntimeTimestampMillis(
          data.revealStartedAt
        ),
        revealStatus: data.revealStatus === "countingDown" ||
          data.revealStatus === "revealed" ? data.revealStatus : "idle",
        status: data.status === "live" || data.status === "complete" ?
          data.status : "setup",
      } : null;
      emit();
    },
    (error) => onError(error)
  ));
  subscriptions.push(onSnapshot(
    doc(
      runtime.firestore,
      "eventSuccessLateArrivals",
      `${context.eventId}_${context.uid}`
    ),
    (snapshot) => {
      state.lateArrival = snapshot.exists() ?
        snapshot.data() as EventSuccessLateArrivalDocument : null;
      emit();
    },
    (error) => onError(error)
  ));
  subscriptions.push(onSnapshot(
    doc(runtime.firestore, "eventSuccessStandings", context.eventId),
    (snapshot) => {
      state.standings = snapshot.exists() ?
        snapshot.data() as EventSuccessStandingsDocument : null;
      emit();
    },
    (error) => onError(error)
  ));
  subscriptions.push(onSnapshot(
    doc(
      runtime.firestore,
      "eventSuccessArrivalMissions",
      `${context.eventId}_${context.uid}`
    ),
    (snapshot) => {
      state.mission = snapshot.exists() ?
        snapshot.data() as EventRuntimeMission : null;
      emit();
    },
    (error) => onError(error)
  ));
  subscriptions.push(onSnapshot(
    doc(
      runtime.firestore,
      "eventSuccessFeedback",
      `${context.eventId}_${context.uid}`
    ),
    (snapshot) => {
      const data = snapshot.data();
      state.feedback = data ? {
        welcomeRating: Number(data.welcomeRating),
        structureRating: Number(data.structureRating),
        metNewPeopleCount: Number(data.metNewPeopleCount),
        safetyConcern: data.safetyConcern === true,
        privateNote: typeof data.privateNote === "string" ? data.privateNote : null,
      } : null;
      emit();
    },
    (error) => onError(error)
  ));
  subscriptions.push(onSnapshot(
    doc(
      runtime.firestore,
      "eventSuccessCompatibilityResponses",
      `${context.eventId}_${context.uid}`
    ),
    (snapshot) => {
      const answerIds = snapshot.data()?.answerIds;
      state.compatibilityAnswerIds = Array.isArray(answerIds) ?
        answerIds.filter((value): value is string => typeof value === "string") :
        [];
      emit();
    },
    (error) => onError(error)
  ));
  subscriptions.push(onSnapshot(
    doc(
      runtime.firestore,
      "eventSuccessWingmanRequests",
      `${context.eventId}_${context.uid}`
    ),
    (snapshot) => {
      const data = snapshot.data();
      state.wingmanTargetUid = data?.status === "active" &&
        typeof data.targetUid === "string" ? data.targetUid : null;
      emit();
    },
    (error) => onError(error)
  ));
  return () => subscriptions.forEach((unsubscribe) => unsubscribe());
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

export function eventRuntimeTimestampMillis(value: unknown): number | null {
  if (!isRecord(value)) return null;
  const toMillis = value.toMillis;
  if (typeof toMillis === "function") {
    const millis = Number(toMillis.call(value));
    return Number.isFinite(millis) ? millis : null;
  }
  const seconds = value.seconds ?? value._seconds;
  const nanoseconds = value.nanoseconds ?? value._nanoseconds ?? 0;
  if (typeof seconds !== "number" || typeof nanoseconds !== "number") {
    return null;
  }
  const millis = seconds * 1000 + Math.floor(nanoseconds / 1_000_000);
  return Number.isFinite(millis) ? millis : null;
}

export async function saveEventRuntimeCompatibilityAnswers(
  context: EventRuntimeContext,
  answerIds: string[]
): Promise<void> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !eventRuntimeFirebaseConfigured) {
    throw new Error("Event runtime is not configured for this build.");
  }
  const {doc, getDoc, serverTimestamp, setDoc} = await import(
    "firebase/firestore"
  );
  const ref = doc(
    runtime.firestore,
    "eventSuccessCompatibilityResponses",
    `${context.eventId}_${context.uid}`
  );
  const existing = await getDoc(ref);
  await setDoc(ref, {
    eventId: context.eventId,
    clubId: context.clubId,
    organizerId: context.organizerId,
    uid: context.uid,
    answerIds,
    createdAt: existing.data()?.createdAt ?? serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
}

export async function saveEventRuntimeFeedback(
  context: EventRuntimeContext,
  feedback: EventRuntimeFeedback
): Promise<void> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !eventRuntimeFirebaseConfigured) {
    throw new Error("Event runtime is not configured for this build.");
  }
  const {doc, getDoc, serverTimestamp, setDoc} = await import(
    "firebase/firestore"
  );
  const ref = doc(
    runtime.firestore,
    "eventSuccessFeedback",
    `${context.eventId}_${context.uid}`
  );
  const existing = await getDoc(ref);
  await setDoc(ref, {
    eventId: context.eventId,
    clubId: context.clubId,
    uid: context.uid,
    ...feedback,
    createdAt: existing.data()?.createdAt ?? serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
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

export async function beginPublicEventPhoneVerification(
  phoneNumber: string,
  recaptchaContainerId: string
): Promise<PublicEventPhoneVerification> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !(
    publicEventRegistrationFirebaseConfigured || publicFormsFirebaseConfigured
  )) {
    throw new Error("Website phone verification is not configured for this build.");
  }
  const {RecaptchaVerifier, signInWithPhoneNumber} = await import("firebase/auth");
  const verifier = new RecaptchaVerifier(
    runtime.auth,
    recaptchaContainerId,
    {size: "invisible"}
  );
  try {
    const confirmation = await signInWithPhoneNumber(
      runtime.auth,
      phoneNumber,
      verifier
    );
    return {
      clear: () => verifier.clear(),
      confirm: async (code) => (await confirmation.confirm(code)).user,
    };
  } catch (error) {
    verifier.clear();
    throw error;
  }
}

export async function registerPublicEvent(
  payload: RegisterPublicEventPayload
): Promise<RegisterPublicEventResponse> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !publicEventRegistrationFirebaseConfigured) {
    throw new Error("Website event registration is not configured for this build.");
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<
    RegisterPublicEventPayload,
    RegisterPublicEventResponse
  >(runtime.functions, "registerPublicEvent");
  return (await callable(payload)).data;
}

export async function recordEventInviteLinkOpen(
  payload: RecordEventInviteLinkOpenCallablePayload
): Promise<{accepted: boolean; inviteLinkId: string}> {
  return invokeWebsiteCallable(
    "recordEventInviteLinkOpen",
    payload,
    publicEventRegistrationFirebaseConfigured || eventRuntimeFirebaseConfigured
  );
}

export async function resolveEventInviteLanding(
  payload: ResolveEventInviteLandingCallablePayload
): Promise<ResolveEventInviteLandingCallableResponse> {
  return invokeWebsiteCallable(
    "resolveEventInviteLanding",
    payload,
    publicEventRegistrationFirebaseConfigured || eventRuntimeFirebaseConfigured
  );
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
    {getFirestore},
    {getFunctions},
  ] = await Promise.all([
    import("firebase/app"),
    import("firebase/app-check"),
    import("firebase/auth"),
    import("firebase/firestore"),
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
    firestore: getFirestore(app),
    functions: getFunctions(app, "asia-south1"),
  };
}

async function invokeWebsiteCallable<Request, Response>(
  name: string,
  payload: Request,
  configured: boolean,
  capabilityLabel = "Event runtime"
): Promise<Response> {
  const runtime = await getFirebaseRuntime();
  if (!runtime || !configured) {
    throw new Error(`${capabilityLabel} are not configured for this build.`);
  }
  const {httpsCallable} = await import("firebase/functions");
  const callable = httpsCallable<Request, Response>(runtime.functions, name);
  return (await callable(payload)).data;
}
