import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  schemaProfileDecisionCollectionPath,
  schemaProfileDecisionOutgoingSubcollectionPath,
} from "../shared/generated/schemaPaths";

export const SUVBOT_UID = "suvbot";
export const SUVBOT_DISPLAY_NAME = "Suvbot";
export const SUVBOT_ACCESS_COLLECTION = "demoSelfServiceAccess";
export const SUVBOT_REQUEST_COLLECTION = "demoOpsRequests";
const DEMO_MANIFEST_COLLECTION = "demoOpsEvents";
const SUVBOT_CONFIRMATION_COLLECTION = "demoOpsConfirmations";
const DEFAULT_DEMO_SEED_PREFIX = "suvbot_2026";
const MAX_SYNTHETIC_MATCHES = 3;
const MAX_BATCH_WRITES = 450;
const CONFIRMATION_WINDOW_MS = 2 * 60 * 1000;

export type SuvbotAction =
  | "listActions"
  | "help"
  | "message"
  | "checkDemoState"
  | "refreshDemoState"
  | "clearDemoState"
  | "warmSignupState"
  | "warmPostEventState"
  | "warmChatState"
  | "warmPaymentState"
  | "resetChats"
  | "resetBookings"
  | "resetNotifications"
  | "matchTesterByPhone";

type ResetScope = "all" | "bookings" | "chats" | "notifications";
type WarmMode = "full" | "signup" | "postEvent" | "chat" | "payment";

export interface SuvbotActionDescriptor {
  id: SuvbotAction;
  label: string;
  description: string;
  icon: string;
  destructive?: boolean;
  requiresText?: boolean;
}

interface DemoDocWrite {
  path: string;
  data: FirebaseFirestore.DocumentData;
}

interface DeletePlan {
  paths: string[];
  eventIds: Set<string>;
  clubIds: Set<string>;
  matchIds: Set<string>;
}

interface WarmPlan {
  docs: DemoDocWrite[];
  eventIds: Set<string>;
}

interface DemoSummary {
  savedEvents: number;
  activeEventParticipations: number;
  attendedEvents: number;
  demoMatches: number;
  payments: number;
  unreadSuvbotMessages: number;
}

export interface SuvbotDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  timestampFromDate: (date: Date) => FirebaseFirestore.Timestamp;
  now: () => Date;
}

export interface SuvbotOperationResult {
  ok: boolean;
  action: string;
  matchId: string;
  reply: string;
  actions: SuvbotActionDescriptor[];
}

export interface SuvbotRunOptions {
  skipConfirmation?: boolean;
  requireAccess?: boolean;
}

const defaultDeps: SuvbotDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  timestampFromDate: (date) => admin.firestore.Timestamp.fromDate(date),
  now: () => new Date(),
};

const SUVBOT_ACTION_CATALOG: readonly SuvbotActionDescriptor[] = [
  {
    id: "refreshDemoState",
    label: "Refresh demo state",
    description: "Clear demo-owned state and warm everything again.",
    icon: "refresh",
    destructive: true,
  },
  {
    id: "clearDemoState",
    label: "Fresh start",
    description: "Delete demo-owned state without creating fresh data.",
    icon: "clean",
    destructive: true,
  },
  {
    id: "warmSignupState",
    label: "Warm signups",
    description: "Create saved, signed-up, and waitlisted demo events.",
    icon: "event",
  },
  {
    id: "warmPostEventState",
    label: "Warm post-event",
    description: "Create attended-event state for recap and swipe testing.",
    icon: "flag",
  },
  {
    id: "warmChatState",
    label: "Warm chats",
    description: "Create seeded match threads for chat testing.",
    icon: "chat",
  },
  {
    id: "warmPaymentState",
    label: "Warm payments",
    description: "Create demo payment history for a paid demo event.",
    icon: "payment",
  },
  {
    id: "resetChats",
    label: "Reset chats",
    description: "Delete demo-owned matches, swipe edges, and chat alerts.",
    icon: "chatReset",
    destructive: true,
  },
  {
    id: "resetBookings",
    label: "Reset bookings",
    description: "Delete demo-owned saved events, bookings, locks, payments.",
    icon: "eventReset",
    destructive: true,
  },
  {
    id: "resetNotifications",
    label: "Reset alerts",
    description: "Delete demo-owned notifications only.",
    icon: "notifications",
    destructive: true,
  },
  {
    id: "matchTesterByPhone",
    label: "Match tester",
    description: "Type a tester phone number to create a seeded match.",
    icon: "personAdd",
    requiresText: true,
  },
  {
    id: "checkDemoState",
    label: "Check setup",
    description: "Show what seeded state is ready right now.",
    icon: "check",
  },
  {
    id: "help",
    label: "Help",
    description: "Explain the available Suvbot controls.",
    icon: "help",
  },
];

/**
 * Callable entry point for button-driven Suvbot demo operations.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {SuvbotDeps} deps Injectable dependencies for tests.
 * @return {Promise<SuvbotOperationResult>} Result.
 */
export async function requestSuvbotDemoOperationHandler(
  request: CallableRequest<unknown>,
  deps: SuvbotDeps = defaultDeps
): Promise<SuvbotOperationResult> {
  const uid = requireAuth(request);
  const data = normalizeSuvbotRequest(request.data);
  return runSuvbotDemoOperationForUser({
    uid,
    action: data.action,
    text: data.text,
    targetPhone: data.targetPhone,
    deps,
  });
}

/**
 * Callable entry point for the backend-owned Suvbot action catalog.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {SuvbotDeps} deps Injectable dependencies for tests.
 * @return {Promise<{actions: SuvbotActionDescriptor[], matchId: string}>}
 * Catalog response.
 */
export async function listSuvbotDemoActionsHandler(
  request: CallableRequest<unknown>,
  deps: SuvbotDeps = defaultDeps
): Promise<{actions: SuvbotActionDescriptor[]; matchId: string}> {
  const uid = requireAuth(request);
  const db = deps.firestore();
  await assertSuvbotAccess(db, uid);
  const {matchId} = await ensureSuvbotThread(db, uid, deps);
  return {actions: suvbotActionCatalog(), matchId};
}

/**
 * Runs one Suvbot action for an explicit user. This is used by both the
 * callable and local admin tooling so command behavior has one source.
 * @param {object} params Operation parameters.
 * @return {Promise<SuvbotOperationResult>} Operation result.
 */
export async function runSuvbotDemoOperationForUser({
  uid,
  action,
  text,
  targetPhone,
  deps = defaultDeps,
  options = {},
}: {
  uid: string;
  action: string;
  text?: string;
  targetPhone?: string;
  deps?: SuvbotDeps;
  options?: SuvbotRunOptions;
}): Promise<SuvbotOperationResult> {
  if (!isSuvbotAction(action)) {
    throw new HttpsError("invalid-argument", "Unsupported Suvbot action.");
  }
  const db = deps.firestore();

  if (options.requireAccess !== false) {
    await assertSuvbotAccess(db, uid);
  }
  const {matchId} = await ensureSuvbotThread(db, uid, deps);
  const requestRef = db.collection(SUVBOT_REQUEST_COLLECTION).doc();
  const operationId = requestRef.id;

  await requestRef.set({
    uid,
    action,
    status: "started",
    matchId,
    createdAt: deps.serverTimestamp(),
    updatedAt: deps.serverTimestamp(),
    text: text ?? null,
    targetPhone: targetPhone ?? null,
  });

  if (action === "message" && text) {
    await writeConversationMessage({
      db,
      matchId,
      senderId: uid,
      recipientId: SUVBOT_UID,
      text,
      deps,
    });
  } else if (action !== "message" && action !== "listActions") {
    await writeConversationMessage({
      db,
      matchId,
      senderId: uid,
      recipientId: SUVBOT_UID,
      text: userFacingActionText(action),
      deps,
    });
  }

  let reply = "";
  try {
    reply = await runSuvbotAction({
      db,
      uid,
      action,
      text,
      targetPhone,
      operationId,
      deps,
      options,
    });
    if (reply) {
      await writeConversationMessage({
        db,
        matchId,
        senderId: SUVBOT_UID,
        recipientId: uid,
        text: reply,
        deps,
      });
    }
    await requestRef.update({
      status: "completed",
      updatedAt: deps.serverTimestamp(),
      completedAt: deps.serverTimestamp(),
    });
  } catch (error) {
    logger.error("Suvbot operation failed", {uid, action, error});
    await writeConversationMessage({
      db,
      matchId,
      senderId: SUVBOT_UID,
      recipientId: uid,
      text: [
        "I could not finish that.",
        "Try again in a minute, or send this chat to Suvrat.",
      ].join(" "),
      deps,
    });
    await requestRef.update({
      status: "failed",
      updatedAt: deps.serverTimestamp(),
      failedAt: deps.serverTimestamp(),
      errorMessage: error instanceof Error ? error.message : String(error),
    });
    throw error;
  }

  return {ok: true, action, matchId, reply, actions: suvbotActionCatalog()};
}

/**
 * Normalizes and allowlists Suvbot action payloads.
 * @param {unknown} raw Raw callable payload.
 * @return {object} Normalized payload.
 */
function normalizeSuvbotRequest(
  raw: unknown
): {action: SuvbotAction; text?: string; targetPhone?: string} {
  const data = isRecord(raw) ? raw : {};
  const action = typeof data.action === "string" ?
    data.action.trim() :
    "help";
  if (!isSuvbotAction(action)) {
    throw new HttpsError("invalid-argument", "Unsupported Suvbot action.");
  }

  const text = typeof data.text === "string" ?
    data.text.trim().slice(0, 500) :
    undefined;
  if (action === "message" && !text) {
    throw new HttpsError("invalid-argument", "Message text is required.");
  }
  const targetPhone = typeof data.targetPhone === "string" ?
    normalizePhone(data.targetPhone) :
    undefined;

  return {action, ...(text && {text}), ...(targetPhone && {targetPhone})};
}

/**
 * Checks that a signed-in user has self-service demo access.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid Current auth uid.
 */
async function assertSuvbotAccess(
  db: FirebaseFirestore.Firestore,
  uid: string
): Promise<void> {
  const [accessSnap, userSnap] = await Promise.all([
    db.collection(SUVBOT_ACCESS_COLLECTION).doc(uid).get(),
    db.collection("users").doc(uid).get(),
  ]);
  const access = accessSnap.data();
  if (!userSnap.exists) {
    throw new HttpsError("failed-precondition", "Complete onboarding first.");
  }
  if (access?.enabled !== true) {
    throw new HttpsError(
      "permission-denied",
      "Suvbot is only enabled for seeded beta accounts."
    );
  }
}

/**
 * Creates the Suvbot profile and deterministic chat thread if needed.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid Current auth uid.
 * @param {SuvbotDeps} deps Injectable dependencies.
 * @return {Promise<{matchId: string, created: boolean}>} Thread identity.
 */
export async function ensureSuvbotThread(
  db: FirebaseFirestore.Firestore,
  uid: string,
  deps: SuvbotDeps = defaultDeps
): Promise<{matchId: string; created: boolean}> {
  const matchId = suvbotMatchId(uid);
  const matchRef = db.collection("matches").doc(matchId);
  const matchSnap = await matchRef.get();
  const batch = db.batch();

  batch.set(
    db.collection("publicProfiles").doc(SUVBOT_UID),
    suvbotPublicProfileDoc(),
    {merge: true}
  );

  if (!matchSnap.exists) {
    const welcomeText =
      "I can refresh your seeded demo state or check what is ready to test.";
    const messageRef = matchRef.collection("messages").doc("suvbot_welcome");
    batch.set(matchRef, {
      demoOps: true,
      demoOpsCommand: "suvbot-thread",
      seedPrefix: DEFAULT_DEMO_SEED_PREFIX,
      user1Id: SUVBOT_UID,
      user2Id: uid,
      eventIds: ["suvbot"],
      createdAt: deps.serverTimestamp(),
      lastMessageAt: deps.serverTimestamp(),
      lastMessagePreview: welcomeText,
      lastMessageSenderId: SUVBOT_UID,
      unreadCounts: {[SUVBOT_UID]: 0, [uid]: 1},
      status: "active",
      blockedBy: null,
      blockedAt: null,
      participantIds: [SUVBOT_UID, uid],
    });
    batch.set(messageRef, {
      demoOps: true,
      demoOpsCommand: "suvbot-thread",
      seedPrefix: DEFAULT_DEMO_SEED_PREFIX,
      senderId: SUVBOT_UID,
      text: welcomeText,
      imageUrl: null,
      sentAt: deps.serverTimestamp(),
    });
  }

  await batch.commit();
  return {matchId, created: !matchSnap.exists};
}

/**
 * Runs a single self-scoped Suvbot operation.
 * @param {object} params Operation parameters.
 * @return {Promise<string>} Bot reply text.
 */
async function runSuvbotAction({
  db,
  uid,
  action,
  text,
  targetPhone,
  operationId,
  deps,
  options,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  action: SuvbotAction;
  text?: string;
  targetPhone?: string;
  operationId: string;
  deps: SuvbotDeps;
  options: SuvbotRunOptions;
}): Promise<string> {
  switch (action) {
  case "listActions":
    return "";
  case "help":
    return helpText();
  case "message":
    return text ?
      runTextCommandOrRespond({db, uid, text, operationId, deps, options}) :
      helpText();
  case "checkDemoState": {
    const summary = await summarizeDemoState(db, uid);
    return summaryText(summary);
  }
  case "refreshDemoState": {
    const confirmation = await requireConfirmation({
      db,
      uid,
      action,
      deps,
      skip: options.skipConfirmation === true,
    });
    if (confirmation) return confirmation;
    const result = await refreshDemoState({db, uid, operationId, deps});
    return [
      "Done. I refreshed your seeded demo state.",
      `${result.deletedCount} old demo docs removed.`,
      `${result.writtenCount} fresh demo docs written.`,
      "Reopen Dashboard, Catches, and Chats if a screen was already loaded.",
    ].join("\n");
  }
  case "clearDemoState": {
    const confirmation = await requireConfirmation({
      db,
      uid,
      action,
      deps,
      skip: options.skipConfirmation === true,
    });
    if (confirmation) return confirmation;
    const result = await clearDemoState({db, uid, operationId, deps});
    return `Done. I removed ${result.deletedCount} demo-owned docs.`;
  }
  case "warmSignupState": {
    const result = await warmDemoState({
      db,
      uid,
      operationId,
      deps,
      mode: "signup",
    });
    if (result.writtenCount === 0) {
      return "I could not find upcoming seeded demo events for your city.";
    }
    return `Done. I warmed signup testing with ${result.writtenCount} docs.`;
  }
  case "warmPostEventState": {
    const result = await warmDemoState({
      db,
      uid,
      operationId,
      deps,
      mode: "postEvent",
    });
    if (result.writtenCount === 0) {
      return "I could not find a past seeded demo event for your city.";
    }
    return [
      "Done. I warmed post-event testing.",
      `${result.writtenCount} demo docs written.`,
    ].join("\n");
  }
  case "warmChatState": {
    const result = await warmDemoState({
      db,
      uid,
      operationId,
      deps,
      mode: "chat",
    });
    if (result.writtenCount === 0) {
      return [
        "I could not create chat test data yet.",
        "You need a seeded past event and synthetic profiles in your city.",
      ].join(" ");
    }
    return `Done. I warmed chat testing with ${result.writtenCount} docs.`;
  }
  case "warmPaymentState": {
    const result = await warmDemoState({
      db,
      uid,
      operationId,
      deps,
      mode: "payment",
    });
    if (result.writtenCount === 0) {
      return "I could not find a paid seeded demo event for your city.";
    }
    return `Done. I warmed payment history with ${result.writtenCount} docs.`;
  }
  case "resetChats": {
    const confirmation = await requireConfirmation({
      db,
      uid,
      action,
      deps,
      skip: options.skipConfirmation === true,
    });
    if (confirmation) return confirmation;
    const result = await resetScopedDemoState({
      db,
      uid,
      operationId,
      deps,
      scope: "chats",
    });
    return `Done. I removed ${result.deletedCount} demo chat docs.`;
  }
  case "resetBookings": {
    const confirmation = await requireConfirmation({
      db,
      uid,
      action,
      deps,
      skip: options.skipConfirmation === true,
    });
    if (confirmation) return confirmation;
    const result = await resetScopedDemoState({
      db,
      uid,
      operationId,
      deps,
      scope: "bookings",
    });
    return `Done. I removed ${result.deletedCount} demo booking docs.`;
  }
  case "resetNotifications": {
    const confirmation = await requireConfirmation({
      db,
      uid,
      action,
      deps,
      skip: options.skipConfirmation === true,
    });
    if (confirmation) return confirmation;
    const result = await resetScopedDemoState({
      db,
      uid,
      operationId,
      deps,
      scope: "notifications",
    });
    return `Done. I removed ${result.deletedCount} demo alerts.`;
  }
  case "matchTesterByPhone":
    return matchTesterByPhone({
      db,
      uid,
      targetPhone,
      text,
      operationId,
      deps,
    });
  }
  throw new HttpsError("invalid-argument", "Unsupported Suvbot action.");
}

/**
 * Deletes prior demo-owned state for one user and writes a fresh warm state.
 * @param {object} params Refresh parameters.
 * @return {Promise<{deletedCount: number, writtenCount: number}>} Counts.
 */
async function refreshDemoState({
  db,
  uid,
  operationId,
  deps,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  operationId: string;
  deps: SuvbotDeps;
}): Promise<{deletedCount: number; writtenCount: number}> {
  const deletePlan = await buildResetPlan(db, uid, "all");
  await applyDeletePlan(db, deletePlan.paths);

  const marker = demoMarker({operationId, command: "suvbot-refresh", deps});
  const warmPlan = await buildWarmPlan({db, uid, marker, deps, mode: "full"});
  await applyWritePlan(db, warmPlan.docs);

  const eventIds = new Set([...deletePlan.eventIds, ...warmPlan.eventIds]);
  await repairEventAggregates(db, eventIds);
  await repairClubMemberCounts(db, deletePlan.clubIds);
  await writeDemoManifest({
    db,
    uid,
    operationId,
    command: "suvbot-refresh",
    paths: [...deletePlan.paths, ...warmPlan.docs.map((doc) => doc.path)],
    deps,
  });

  return {
    deletedCount: deletePlan.paths.length,
    writtenCount: warmPlan.docs.length,
  };
}

/**
 * Deletes all demo-owned state for one user without warming fresh data.
 * @param {object} params Clear parameters.
 * @return {Promise<{deletedCount: number}>} Delete count.
 */
async function clearDemoState({
  db,
  uid,
  operationId,
  deps,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  operationId: string;
  deps: SuvbotDeps;
}): Promise<{deletedCount: number}> {
  const deletePlan = await buildResetPlan(db, uid, "all");
  await applyDeletePlan(db, deletePlan.paths);
  await repairEventAggregates(db, deletePlan.eventIds);
  await repairClubMemberCounts(db, deletePlan.clubIds);
  await writeDemoManifest({
    db,
    uid,
    operationId,
    command: "suvbot-clear",
    paths: deletePlan.paths,
    deps,
  });
  return {deletedCount: deletePlan.paths.length};
}

/**
 * Deletes one scoped family of demo-owned docs for a user.
 * @param {object} params Reset parameters.
 * @return {Promise<{deletedCount: number}>} Delete count.
 */
async function resetScopedDemoState({
  db,
  uid,
  operationId,
  deps,
  scope,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  operationId: string;
  deps: SuvbotDeps;
  scope: ResetScope;
}): Promise<{deletedCount: number}> {
  const deletePlan = await buildResetPlan(db, uid, scope);
  await applyDeletePlan(db, deletePlan.paths);
  await repairEventAggregates(db, deletePlan.eventIds);
  await repairClubMemberCounts(db, deletePlan.clubIds);
  await writeDemoManifest({
    db,
    uid,
    operationId,
    command: `suvbot-reset-${scope}`,
    paths: deletePlan.paths,
    deps,
  });
  return {deletedCount: deletePlan.paths.length};
}

/**
 * Writes one scoped family of demo-owned docs for a user.
 * @param {object} params Warm parameters.
 * @return {Promise<{writtenCount: number}>} Write count.
 */
async function warmDemoState({
  db,
  uid,
  operationId,
  deps,
  mode,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  operationId: string;
  deps: SuvbotDeps;
  mode: WarmMode;
}): Promise<{writtenCount: number}> {
  const marker = demoMarker({
    operationId,
    command: `suvbot-warm-${mode}`,
    deps,
  });
  const warmPlan = await buildWarmPlan({db, uid, marker, deps, mode});
  await applyWritePlan(db, warmPlan.docs);
  await repairEventAggregates(db, warmPlan.eventIds);
  await writeDemoManifest({
    db,
    uid,
    operationId,
    command: `suvbot-warm-${mode}`,
    paths: warmPlan.docs.map((doc) => doc.path),
    deps,
  });
  return {writtenCount: warmPlan.docs.length};
}

/**
 * Builds the reset delete list for one user's demo-owned state.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid User id.
 * @param {ResetScope} scope Reset scope.
 * @return {Promise<DeletePlan>} Delete plan.
 */
async function buildResetPlan(
  db: FirebaseFirestore.Firestore,
  uid: string,
  scope: ResetScope = "all"
): Promise<DeletePlan> {
  const paths = new Set<string>();
  const eventIds = new Set<string>();
  const clubIds = new Set<string>();
  const matchIds = new Set<string>();

  const collectPath = (
    snap: FirebaseFirestore.QueryDocumentSnapshot,
    data = snap.data()
  ) => {
    if (!isDemoOwned(data)) return;
    paths.add(snap.ref.path);
    collectString(data.eventId, eventIds);
    collectString(data.clubId, clubIds);
  };

  if (scope === "all") {
    const manifestSnap = await db.collection(DEMO_MANIFEST_COLLECTION)
      .where("users", "array-contains", uid)
      .get();
    for (const doc of manifestSnap.docs) {
      const data = doc.data();
      for (const path of Array.isArray(data.paths) ? data.paths : []) {
        if (typeof path === "string" && !isSuvbotPath(path, uid)) {
          paths.add(path);
        }
      }
      if (!isSuvbotPath(doc.ref.path, uid)) paths.add(doc.ref.path);
    }
  }

  if (scope === "all") {
    await collectTopLevelQuery(db, "clubMemberships", "uid", uid, collectPath);
  }
  if (scope === "all" || scope === "bookings") {
    await collectTopLevelQuery(
      db,
      "eventParticipations",
      "uid",
      uid,
      collectPath
    );
    await collectTopLevelQuery(
      db,
      "userEventScheduleLocks",
      "uid",
      uid,
      collectPath
    );
    await collectTopLevelQuery(db, "savedEvents", "uid", uid, collectPath);
    await collectTopLevelQuery(db, "payments", "userId", uid, collectPath);
  }
  if (scope === "all" || scope === "chats") {
    await collectDemoMatches(db, uid, paths, matchIds, eventIds);
    await collectOutgoingSwipes(db, uid, paths, eventIds);
    await collectIncomingSwipes(db, uid, paths, eventIds);
  }
  if (scope === "all" || scope === "chats" || scope === "notifications") {
    await collectNotifications(db, uid, paths, matchIds);
  }

  return {
    paths: [...paths].filter((path) => !isSuvbotPath(path, uid)).sort(),
    eventIds,
    clubIds,
    matchIds,
  };
}

/**
 * Builds fresh demo-owned docs around the signed-in user's existing profile.
 * @param {object} params Build parameters.
 * @return {Promise<WarmPlan>} Write plan.
 */
async function buildWarmPlan({
  db,
  uid,
  marker,
  deps,
  mode = "full",
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  marker: FirebaseFirestore.DocumentData;
  deps: SuvbotDeps;
  mode?: WarmMode;
}): Promise<WarmPlan> {
  const userSnap = await db.collection("users").doc(uid).get();
  const user = userSnap.data();
  if (!user) {
    throw new HttpsError("failed-precondition", "Complete onboarding first.");
  }

  const now = deps.now();
  const docs: DemoDocWrite[] = [];
  const eventIds = new Set<string>();
  const {upcoming, past} = await findDemoEvents(db, user.city, now);
  const signedUpEvent = upcoming[0];
  const waitlistedEvent = upcoming[1];
  const attendedEvent = past[0];
  const paidEvent = upcoming.find((event) =>
    Number(event.data.priceInPaise ?? 0) > 0
  );

  if (mode === "full" || mode === "signup") {
    for (const event of upcoming.slice(0, 3)) {
      await pushDemoDoc(db, docs, {
        path: `savedEvents/${uid}_${event.id}`,
        data: {
          ...marker,
          uid,
          eventId: event.id,
          savedAt: deps.timestampFromDate(offsetDate(now, {hours: -2})),
        },
      });
    }
  }

  const eventStates: Array<[DemoEvent | undefined, string]> = [];
  if (mode === "full" || mode === "signup") {
    eventStates.push([signedUpEvent, "signedUp"]);
    eventStates.push([waitlistedEvent, "waitlisted"]);
  }
  if (mode === "full" || mode === "postEvent") {
    eventStates.push([attendedEvent, "attended"]);
  }
  for (const [event, status] of eventStates) {
    if (!event) continue;
    eventIds.add(event.id);
    await pushDemoDoc(db, docs, {
      path: `eventParticipations/${event.id}_${uid}`,
      data: participationDoc({
        uid,
        event,
        status,
        genderAtSignup: typeof user.gender === "string" ?
          user.gender :
          "other",
        marker,
        now,
        deps,
      }),
    });
  }

  if (mode === "full" || mode === "signup" || mode === "postEvent") {
    docs.push(...notificationDocs({
      uid,
      marker,
      signedUpEvent: mode === "postEvent" ? undefined : signedUpEvent,
      waitlistedEvent: mode === "postEvent" ? undefined : waitlistedEvent,
      attendedEvent: mode === "signup" ? undefined : attendedEvent,
      now,
      deps,
    }));
  }

  if ((mode === "full" || mode === "chat" || mode === "postEvent") &&
      attendedEvent) {
    const targets = await findSyntheticTargets(db, user.city, uid);
    for (const [index, target] of targets.entries()) {
      docs.push(...syntheticMatchDocs({
        uid,
        target,
        event: attendedEvent,
        marker,
        now,
        offsetMinutes: index * 8,
        deps,
      }));
    }
  }

  if ((mode === "full" || mode === "payment") && paidEvent) {
    docs.push(...paymentDemoDocs({
      uid,
      event: paidEvent,
      marker,
      user,
      now,
      deps,
    }));
    eventIds.add(paidEvent.id);
  }

  await ensureSuvbotThread(db, uid, deps);
  return {docs: uniqueDocsByPath(docs), eventIds};
}

/**
 * Writes one chat message and updates match preview metadata immediately.
 * @param {object} params Message parameters.
 */
async function writeConversationMessage({
  db,
  matchId,
  senderId,
  recipientId,
  text,
  deps,
}: {
  db: FirebaseFirestore.Firestore;
  matchId: string;
  senderId: string;
  recipientId: string;
  text: string;
  deps: SuvbotDeps;
}): Promise<void> {
  const matchRef = db.collection("matches").doc(matchId);
  const messageRef = matchRef.collection("messages").doc();
  const preview = previewText(text);
  const batch = db.batch();
  batch.set(messageRef, {
    senderId,
    text,
    imageUrl: null,
    sentAt: deps.serverTimestamp(),
  });
  batch.update(matchRef, {
    lastMessageAt: deps.serverTimestamp(),
    lastMessagePreview: preview,
    lastMessageSenderId: senderId,
    [`unreadCounts.${senderId}`]: 0,
    [`unreadCounts.${recipientId}`]: senderId === SUVBOT_UID ? 1 : 0,
  });
  await batch.commit();
}

interface DemoEvent {
  id: string;
  data: FirebaseFirestore.DocumentData;
}

/**
 * Finds seeded/demo-owned events in the user's city.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {unknown} city User city.
 * @param {Date} now Current time.
 * @return {Promise<{upcoming: DemoEvent[], past: DemoEvent[]}>} Events.
 */
async function findDemoEvents(
  db: FirebaseFirestore.Firestore,
  city: unknown,
  now: Date
): Promise<{upcoming: DemoEvent[]; past: DemoEvent[]}> {
  const snap = await db.collection("events")
    .where("status", "==", "active")
    .limit(200)
    .get();
  const cityName = typeof city === "string" ? city : null;
  const events = snap.docs
    .map((doc) => ({id: doc.id, data: doc.data()}))
    .filter((event) => isDemoOwned(event.data))
    .filter((event) => !cityName || event.data.city === cityName);
  const upcoming = events
    .filter((event) => dateFromTimestamp(event.data.startTime) > now)
    .sort((a, b) =>
      dateFromTimestamp(a.data.startTime).getTime() -
      dateFromTimestamp(b.data.startTime).getTime()
    );
  const past = events
    .filter((event) => dateFromTimestamp(event.data.endTime) < now)
    .sort((a, b) =>
      dateFromTimestamp(b.data.endTime).getTime() -
      dateFromTimestamp(a.data.endTime).getTime()
    );
  return {upcoming, past};
}

/**
 * Finds synthetic public profiles for seeded match warmup.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {unknown} city User city.
 * @param {string} uid Current user id.
 * @return {Promise<Array<{uid: string, data: FirebaseFirestore.DocumentData}>>}
 * Synthetic targets.
 */
async function findSyntheticTargets(
  db: FirebaseFirestore.Firestore,
  city: unknown,
  uid: string
): Promise<Array<{uid: string; data: FirebaseFirestore.DocumentData}>> {
  const snap = await db.collection("publicProfiles")
    .where("synthetic", "==", true)
    .limit(24)
    .get();
  const cityName = typeof city === "string" ? city : null;
  return snap.docs
    .map((doc) => ({uid: doc.id, data: doc.data()}))
    .filter((target) => target.uid !== uid)
    .filter((target) => !cityName || target.data.city === cityName)
    .slice(0, MAX_SYNTHETIC_MATCHES);
}

/**
 * Returns one demo participation document.
 * @param {object} params Participation parameters.
 * @return {FirebaseFirestore.DocumentData} Firestore data.
 */
function participationDoc({
  uid,
  event,
  status,
  genderAtSignup,
  paymentId,
  marker,
  now,
  deps,
}: {
  uid: string;
  event: DemoEvent;
  status: string;
  genderAtSignup: string;
  paymentId?: string;
  marker: FirebaseFirestore.DocumentData;
  now: Date;
  deps: SuvbotDeps;
}): FirebaseFirestore.DocumentData {
  const createdAt = offsetDate(now, {days: status === "attended" ? -10 : -1});
  const attendedAt = status === "attended" ?
    dateFromTimestamp(event.data.endTime) :
    null;
  return {
    ...marker,
    eventId: event.id,
    clubId: event.data.clubId,
    uid,
    status,
    createdAt: deps.timestampFromDate(createdAt),
    updatedAt: deps.timestampFromDate(now),
    signedUpAt: ["signedUp", "attended"].includes(status) ?
      deps.timestampFromDate(createdAt) :
      null,
    waitlistedAt: status === "waitlisted" ?
      deps.timestampFromDate(createdAt) :
      null,
    attendedAt: attendedAt ? deps.timestampFromDate(attendedAt) : null,
    cancelledAt: null,
    deletedAt: null,
    genderAtSignup,
    paymentId: paymentId ?? null,
  };
}

/**
 * Builds Suvbot warmup notifications.
 * @param {object} params Notification parameters.
 * @return {DemoDocWrite[]} Notification docs.
 */
function notificationDocs({
  uid,
  marker,
  signedUpEvent,
  waitlistedEvent,
  attendedEvent,
  now,
  deps,
}: {
  uid: string;
  marker: FirebaseFirestore.DocumentData;
  signedUpEvent?: DemoEvent;
  waitlistedEvent?: DemoEvent;
  attendedEvent?: DemoEvent;
  now: Date;
  deps: SuvbotDeps;
}): DemoDocWrite[] {
  const docs: DemoDocWrite[] = [];
  if (signedUpEvent) {
    docs.push({
      path: `notifications/${uid}/items/suvbot_signup_${signedUpEvent.id}`,
      data: {
        ...marker,
        uid,
        type: "eventSignup",
        title: "Demo event ready",
        body: "You have a seeded upcoming event to test.",
        createdAt: deps.timestampFromDate(offsetDate(now, {minutes: -55})),
        readAt: null,
        eventId: signedUpEvent.id,
        clubId: signedUpEvent.data.clubId,
      },
    });
  }
  if (waitlistedEvent) {
    docs.push({
      path: `notifications/${uid}/items/suvbot_waitlist_${waitlistedEvent.id}`,
      data: {
        ...marker,
        uid,
        type: "waitlistPromotion",
        title: "Waitlist state seeded",
        body: "You have a seeded waitlist state to test.",
        createdAt: deps.timestampFromDate(offsetDate(now, {minutes: -40})),
        readAt: null,
        eventId: waitlistedEvent.id,
        clubId: waitlistedEvent.data.clubId,
      },
    });
  }
  if (attendedEvent) {
    docs.push({
      path: `notifications/${uid}/items/suvbot_attended_${attendedEvent.id}`,
      data: {
        ...marker,
        uid,
        type: "match",
        title: "Catches are ready",
        body: "Your seeded attended event can unlock recap and swipe testing.",
        createdAt: deps.timestampFromDate(offsetDate(now, {minutes: -25})),
        readAt: null,
        eventId: attendedEvent.id,
        clubId: attendedEvent.data.clubId,
      },
    });
  }
  return docs;
}

/**
 * Builds a demo payment record and linked signup for payment-history testing.
 * @param {object} params Payment parameters.
 * @return {DemoDocWrite[]} Demo payment docs.
 */
function paymentDemoDocs({
  uid,
  event,
  marker,
  user,
  now,
  deps,
}: {
  uid: string;
  event: DemoEvent;
  marker: FirebaseFirestore.DocumentData;
  user: FirebaseFirestore.DocumentData;
  now: Date;
  deps: SuvbotDeps;
}): DemoDocWrite[] {
  const paymentId = `${DEFAULT_DEMO_SEED_PREFIX}_payment_${event.id}_${uid}`;
  return [
    {
      path: `payments/${paymentId}`,
      data: {
        ...marker,
        userId: uid,
        orderId: `${DEFAULT_DEMO_SEED_PREFIX}_order_${event.id}_${uid}`,
        paymentId,
        eventId: event.id,
        amount: Number(event.data.priceInPaise ?? 29900) || 29900,
        currency: "INR",
        status: "completed",
        signUpFailed: false,
        createdAt: deps.timestampFromDate(offsetDate(now, {days: -1})),
      },
    },
    {
      path: `eventParticipations/${event.id}_${uid}`,
      data: participationDoc({
        uid,
        event,
        status: "signedUp",
        genderAtSignup: typeof user.gender === "string" ?
          user.gender :
          "other",
        paymentId,
        marker,
        now,
        deps,
      }),
    },
    {
      path: `notifications/${uid}/items/suvbot_payment_${event.id}`,
      data: {
        ...marker,
        uid,
        type: "payment",
        title: "Payment history seeded",
        body: "You have a completed demo payment to inspect.",
        createdAt: deps.timestampFromDate(offsetDate(now, {minutes: -30})),
        readAt: null,
        eventId: event.id,
        clubId: event.data.clubId,
      },
    },
  ];
}

/**
 * Builds one synthetic match thread with starter messages.
 * @param {object} params Match parameters.
 * @return {DemoDocWrite[]} Match and message docs.
 */
function syntheticMatchDocs({
  uid,
  target,
  event,
  marker,
  now,
  offsetMinutes,
  deps,
}: {
  uid: string;
  target: {uid: string; data: FirebaseFirestore.DocumentData};
  event: DemoEvent;
  marker: FirebaseFirestore.DocumentData;
  now: Date;
  offsetMinutes: number;
  deps: SuvbotDeps;
}): DemoDocWrite[] {
  const [user1Id, user2Id] = [uid, target.uid].sort();
  const matchId = `${user1Id}_${user2Id}`;
  const targetName = typeof target.data.name === "string" ?
    target.data.name :
    "A seeded runner";
  const texts = [
    {
      senderId: target.uid,
      text: [
        `That ${event.data.title ?? "demo event"} was fun.`,
        "Same pace next time?",
      ].join(" "),
    },
    {senderId: uid, text: "Absolutely. I wanted to test this chat too."},
    {senderId: target.uid, text: "Perfect. Suvbot just refreshed this thread."},
  ];
  const docs: DemoDocWrite[] = [];
  const unreadCounts: Record<string, number> = {[user1Id]: 0, [user2Id]: 0};
  let lastMessagePreview: string | null = null;
  let lastMessageSenderId: string | null = null;
  let lastMessageAt: FirebaseFirestore.Timestamp | null = null;

  for (const [index, message] of texts.entries()) {
    const sentAt = deps.timestampFromDate(
      offsetDate(now, {minutes: -30 + offsetMinutes + index * 6})
    );
    lastMessageAt = sentAt;
    lastMessagePreview = previewText(message.text);
    lastMessageSenderId = message.senderId;
    const recipientId = message.senderId === user1Id ? user2Id : user1Id;
    unreadCounts[message.senderId] = 0;
    unreadCounts[recipientId] = message.senderId === target.uid ? 1 : 0;
    docs.push({
      path: `matches/${matchId}/messages/suvbot_${index + 1}`,
      data: {
        ...marker,
        senderId: message.senderId,
        text: message.text,
        imageUrl: null,
        sentAt,
      },
    });
  }

  docs.push({
    path: `matches/${matchId}`,
    data: {
      ...marker,
      demoOpsEntityType: "matchThread",
      demoOpsDisposalPolicy: "deleteThreadWithMessages",
      user1Id,
      user2Id,
      eventIds: [event.id],
      createdAt: deps.timestampFromDate(offsetDate(now, {minutes: -35})),
      lastMessageAt,
      lastMessagePreview,
      lastMessageSenderId,
      unreadCounts,
      status: "active",
      blockedBy: null,
      blockedAt: null,
      participantIds: [user1Id, user2Id],
    },
  });

  docs.push({
    path: `notifications/${uid}/items/suvbot_match_${matchId}`,
    data: {
      ...marker,
      uid,
      type: "match",
      title: "It's a catch",
      body: `You and ${targetName} have a seeded chat to test.`,
      createdAt: deps.timestampFromDate(offsetDate(now, {minutes: -20})),
      readAt: null,
      matchId,
      eventId: event.id,
      actorUid: target.uid,
      actorName: targetName,
    },
  });

  return docs;
}

/**
 * Summarizes the current user's seeded demo readiness.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid User id.
 * @return {Promise<DemoSummary>} Demo summary.
 */
async function summarizeDemoState(
  db: FirebaseFirestore.Firestore,
  uid: string
): Promise<DemoSummary> {
  const [saved, participations, matches, payments, suvbot] = await Promise.all([
    db.collection("savedEvents").where("uid", "==", uid).get(),
    db.collection("eventParticipations").where("uid", "==", uid).get(),
    db.collection("matches").where("participantIds", "array-contains", uid)
      .get(),
    db.collection("payments").where("userId", "==", uid).get(),
    db.collection("matches").doc(suvbotMatchId(uid)).get(),
  ]);
  const activeParticipations = participations.docs
    .map((doc) => doc.data())
    .filter((data) => ["signedUp", "waitlisted", "attended"]
      .includes(data.status));
  return {
    savedEvents: saved.docs.filter((doc) => isDemoOwned(doc.data())).length,
    activeEventParticipations: activeParticipations
      .filter((data) => isDemoOwned(data))
      .length,
    attendedEvents: activeParticipations
      .filter((data) => data.status === "attended" && isDemoOwned(data))
      .length,
    demoMatches: matches.docs
      .filter((doc) => doc.id !== suvbotMatchId(uid))
      .filter((doc) => isDemoOwned(doc.data()))
      .length,
    payments: payments.docs.filter((doc) => isDemoOwned(doc.data())).length,
    unreadSuvbotMessages: Number(
      suvbot.data()?.unreadCounts?.[uid] ?? 0
    ) || 0,
  };
}

/**
 * Recomputes aggregate fields for touched events.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {Set<string>} eventIds Touched event ids.
 */
async function repairEventAggregates(
  db: FirebaseFirestore.Firestore,
  eventIds: Set<string>
): Promise<void> {
  for (const eventId of eventIds) {
    const [eventSnap, participationsSnap] = await Promise.all([
      db.collection("events").doc(eventId).get(),
      db.collection("eventParticipations").where("eventId", "==", eventId)
        .get(),
    ]);
    if (!eventSnap.exists) continue;
    const aggregate = {
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      genderCounts: {} as Record<string, number>,
    };
    for (const doc of participationsSnap.docs) {
      const data = doc.data();
      if (data.status === "signedUp" || data.status === "attended") {
        aggregate.bookedCount += 1;
        if (typeof data.genderAtSignup === "string") {
          aggregate.genderCounts[data.genderAtSignup] =
            (aggregate.genderCounts[data.genderAtSignup] ?? 0) + 1;
        }
      }
      if (data.status === "attended") aggregate.checkedInCount += 1;
      if (data.status === "waitlisted") aggregate.waitlistedCount += 1;
    }
    await eventSnap.ref.update(aggregate);
  }
}

/**
 * Recomputes memberCount for touched clubs.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {Set<string>} clubIds Touched club ids.
 */
async function repairClubMemberCounts(
  db: FirebaseFirestore.Firestore,
  clubIds: Set<string>
): Promise<void> {
  for (const clubId of clubIds) {
    const [clubSnap, membershipsSnap] = await Promise.all([
      db.collection("clubs").doc(clubId).get(),
      db.collection("clubMemberships")
        .where("clubId", "==", clubId)
        .where("status", "==", "active")
        .get(),
    ]);
    if (clubSnap.exists) {
      await clubSnap.ref.update({memberCount: membershipsSnap.size});
    }
  }
}

/**
 * Writes a demo-operation manifest for cleanup and audit.
 * @param {object} params Manifest parameters.
 */
async function writeDemoManifest({
  db,
  uid,
  operationId,
  command,
  paths,
  deps,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  operationId: string;
  command: string;
  paths: string[];
  deps: SuvbotDeps;
}): Promise<void> {
  await db.collection(DEMO_MANIFEST_COLLECTION).doc(operationId).set({
    demoOps: true,
    demoOpsId: operationId,
    demoOpsCommand: command,
    seedPrefix: DEFAULT_DEMO_SEED_PREFIX,
    command,
    operationId,
    applied: true,
    createdAt: deps.serverTimestamp(),
    users: [uid],
    phones: [],
    paths: [...new Set(paths)].sort(),
    pathCount: new Set(paths).size,
  });
}

/**
 * Applies set writes in Firestore batch chunks.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {DemoDocWrite[]} docs Docs to write.
 */
async function applyWritePlan(
  db: FirebaseFirestore.Firestore,
  docs: DemoDocWrite[]
): Promise<void> {
  for (const chunk of chunks(docs, MAX_BATCH_WRITES)) {
    const batch = db.batch();
    for (const doc of chunk) {
      batch.set(db.doc(doc.path), doc.data);
    }
    await batch.commit();
  }
}

/**
 * Applies delete writes in Firestore batch chunks.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string[]} paths Docs to delete.
 */
async function applyDeletePlan(
  db: FirebaseFirestore.Firestore,
  paths: string[]
): Promise<void> {
  for (const chunk of chunks(paths, MAX_BATCH_WRITES)) {
    const batch = db.batch();
    for (const path of chunk) batch.delete(db.doc(path));
    await batch.commit();
  }
}

/**
 * Adds a write if it would not overwrite a non-demo document.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {DemoDocWrite[]} docs Mutable docs array.
 * @param {DemoDocWrite} doc Candidate doc.
 */
async function pushDemoDoc(
  db: FirebaseFirestore.Firestore,
  docs: DemoDocWrite[],
  doc: DemoDocWrite
): Promise<void> {
  const snap = await db.doc(doc.path).get();
  if (snap.exists && !isDemoOwned(snap.data())) return;
  docs.push(doc);
}

/**
 * Collects top-level query docs through a callback.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} collection Collection name.
 * @param {string} field Query field.
 * @param {string} value Query value.
 * @param {Function} collect Callback.
 */
async function collectTopLevelQuery(
  db: FirebaseFirestore.Firestore,
  collection: string,
  field: string,
  value: string,
  collect: (snap: FirebaseFirestore.QueryDocumentSnapshot) => void
): Promise<void> {
  const snap = await db.collection(collection).where(field, "==", value).get();
  for (const doc of snap.docs) collect(doc);
}

/**
 * Collects demo-owned matches involving the user.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid User id.
 * @param {Set<string>} paths Mutable path set.
 * @param {Set<string>} matchIds Mutable match id set.
 * @param {Set<string>} eventIds Mutable event id set.
 */
async function collectDemoMatches(
  db: FirebaseFirestore.Firestore,
  uid: string,
  paths: Set<string>,
  matchIds: Set<string>,
  eventIds: Set<string>
): Promise<void> {
  const snap = await db.collection("matches")
    .where("participantIds", "array-contains", uid)
    .get();
  for (const doc of snap.docs) {
    const data = doc.data();
    if (doc.id === suvbotMatchId(uid) || !isDemoOwned(data)) continue;
    matchIds.add(doc.id);
    for (const eventId of Array.isArray(data.eventIds) ? data.eventIds : []) {
      collectString(eventId, eventIds);
    }
    const messages = await doc.ref.collection("messages").get();
    for (const message of messages.docs) paths.add(message.ref.path);
    paths.add(doc.ref.path);
  }
}

/**
 * Collects outgoing demo-owned swipes.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid User id.
 * @param {Set<string>} paths Mutable path set.
 * @param {Set<string>} eventIds Mutable event id set.
 */
async function collectOutgoingSwipes(
  db: FirebaseFirestore.Firestore,
  uid: string,
  paths: Set<string>,
  eventIds: Set<string>
): Promise<void> {
  const snap = await db
    .collection(schemaProfileDecisionCollectionPath)
    .doc(uid)
    .collection(schemaProfileDecisionOutgoingSubcollectionPath)
    .get();
  for (const doc of snap.docs) {
    const data = doc.data();
    if (!isDemoOwned(data)) continue;
    paths.add(doc.ref.path);
    collectString(data.eventId, eventIds);
  }
}

/**
 * Collects incoming demo-owned swipes by scanning beta-sized swipe roots.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid User id.
 * @param {Set<string>} paths Mutable path set.
 * @param {Set<string>} eventIds Mutable event id set.
 */
async function collectIncomingSwipes(
  db: FirebaseFirestore.Firestore,
  uid: string,
  paths: Set<string>,
  eventIds: Set<string>
): Promise<void> {
  const swipers = await db
    .collection(schemaProfileDecisionCollectionPath)
    .get();
  for (const swiperDoc of swipers.docs) {
    if (swiperDoc.id === uid) continue;
    const outgoing = await swiperDoc.ref
      .collection(schemaProfileDecisionOutgoingSubcollectionPath)
      .get();
    for (const doc of outgoing.docs) {
      const data = doc.data();
      if (data.targetId !== uid || !isDemoOwned(data)) continue;
      paths.add(doc.ref.path);
      collectString(data.eventId, eventIds);
    }
  }
}

/**
 * Collects demo-owned notifications for a user.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid User id.
 * @param {Set<string>} paths Mutable path set.
 * @param {Set<string>} matchIds Demo match ids.
 */
async function collectNotifications(
  db: FirebaseFirestore.Firestore,
  uid: string,
  paths: Set<string>,
  matchIds: Set<string>
): Promise<void> {
  const snap = await db.collection("notifications").doc(uid)
    .collection("items")
    .get();
  for (const doc of snap.docs) {
    const data = doc.data();
    if (isDemoOwned(data) || matchIds.has(data.matchId)) {
      paths.add(doc.ref.path);
    }
  }
}

/**
 * Builds the common demo metadata marker.
 * @param {object} params Marker parameters.
 * @return {FirebaseFirestore.DocumentData} Marker fields.
 */
function demoMarker({
  operationId,
  command,
  deps,
}: {
  operationId: string;
  command: string;
  deps: SuvbotDeps;
}): FirebaseFirestore.DocumentData {
  return {
    demoOps: true,
    demoOpsId: operationId,
    demoOpsCommand: command,
    seedPrefix: DEFAULT_DEMO_SEED_PREFIX,
    createdAt: deps.serverTimestamp(),
  };
}

/**
 * Returns Suvbot's public profile document.
 * @return {FirebaseFirestore.DocumentData} Public profile data.
 */
function suvbotPublicProfileDoc(): FirebaseFirestore.DocumentData {
  return {
    demoOps: true,
    demoOpsCommand: "suvbot-thread",
    seedPrefix: DEFAULT_DEMO_SEED_PREFIX,
    name: SUVBOT_DISPLAY_NAME,
    age: 99,
    gender: "other",
    profilePrompts: [],
    photoUrls: [],
    photoThumbnailUrls: [],
    photoPrompts: [],
    profilePhotos: [],
    city: "mumbai",
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: [],
    runningReasons: ["community"],
    preferredRunTimes: [],
    runPreferencesVersion: 1,
  };
}

/**
 * Returns the deterministic Suvbot match id for one user.
 * @param {string} uid User id.
 * @return {string} Match id.
 */
export function suvbotMatchId(uid: string): string {
  return `${SUVBOT_UID}_${uid.replace(/\//g, "_")}`;
}

/**
 * Returns whether a path belongs to the Suvbot control thread.
 * @param {string} path Firestore path.
 * @param {string} uid User id.
 * @return {boolean} True for Suvbot paths.
 */
function isSuvbotPath(path: string, uid: string): boolean {
  return path === `matches/${suvbotMatchId(uid)}` ||
    path.startsWith(`matches/${suvbotMatchId(uid)}/`) ||
    path === `publicProfiles/${SUVBOT_UID}` ||
    path === `${SUVBOT_ACCESS_COLLECTION}/${uid}`;
}

/**
 * Returns whether a document is owned by seed/demo tooling.
 * @param {FirebaseFirestore.DocumentData | undefined} data Firestore data.
 * @return {boolean} True when demo-owned.
 */
function isDemoOwned(
  data: FirebaseFirestore.DocumentData | undefined
): boolean {
  return data?.demoOps === true ||
    data?.synthetic === true ||
    typeof data?.seedPrefix === "string";
}

/**
 * Returns the backend-owned action catalog for app and tooling surfaces.
 * @return {SuvbotActionDescriptor[]} Action descriptors.
 */
export function suvbotActionCatalog(): SuvbotActionDescriptor[] {
  return SUVBOT_ACTION_CATALOG.map((action) => ({...action}));
}

/**
 * Returns a confirmation prompt for destructive operations, or null to run.
 * @param {object} params Confirmation parameters.
 * @return {Promise<string | null>} Prompt when confirmation is still needed.
 */
async function requireConfirmation({
  db,
  uid,
  action,
  deps,
  skip,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  action: SuvbotAction;
  deps: SuvbotDeps;
  skip: boolean;
}): Promise<string | null> {
  if (skip || !actionDefinition(action)?.destructive) return null;
  const ref = db
    .collection(SUVBOT_CONFIRMATION_COLLECTION)
    .doc(`${uid}_${action}`);
  const snap = await ref.get();
  const expiresAt = dateFromTimestamp(snap.data()?.expiresAt);
  if (snap.exists && expiresAt.getTime() > deps.now().getTime()) {
    await ref.delete();
    return null;
  }
  await ref.set({
    uid,
    action,
    createdAt: deps.serverTimestamp(),
    expiresAt: deps.timestampFromDate(
      new Date(deps.now().getTime() + CONFIRMATION_WINDOW_MS)
    ),
  });
  return [
    `${userFacingActionText(action)} is a destructive demo operation.`,
    "Tap the same chip again within 2 minutes to confirm.",
  ].join("\n");
}

/**
 * Runs a parsed typed command or returns a normal help response.
 * @param {object} params Text command parameters.
 * @return {Promise<string>} Bot reply.
 */
async function runTextCommandOrRespond({
  db,
  uid,
  text,
  operationId,
  deps,
  options,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  text: string;
  operationId: string;
  deps: SuvbotDeps;
  options: SuvbotRunOptions;
}): Promise<string> {
  const parsed = parseTypedCommand(text);
  if (!parsed) return responseForFreeText(text);
  return runSuvbotAction({
    db,
    uid,
    action: parsed.action,
    text,
    targetPhone: parsed.targetPhone,
    operationId,
    deps,
    options,
  });
}

/**
 * Parses supported free-text shortcuts.
 * @param {string} text User text.
 * @return {object | null} Parsed command.
 */
function parseTypedCommand(
  text: string
): {action: SuvbotAction; targetPhone?: string} | null {
  const normalized = text.toLowerCase();
  const phone = extractPhone(text);
  if (phone && /(match|connect|tester|friend)/u.test(normalized)) {
    return {action: "matchTesterByPhone", targetPhone: phone};
  }
  if (/(fresh start|clear)/u.test(normalized)) {
    return {action: "clearDemoState"};
  }
  if (/(reset|clear).*(chat|match)/u.test(normalized)) {
    return {action: "resetChats"};
  }
  if (/(reset|clear).*(booking|event|signup|payment)/u.test(normalized)) {
    return {action: "resetBookings"};
  }
  if (/(reset|clear).*(notification|alert)/u.test(normalized)) {
    return {action: "resetNotifications"};
  }
  if (/(warm|seed).*(signup|booking|event)/u.test(normalized)) {
    return {action: "warmSignupState"};
  }
  if (/(warm|seed).*(post|attended|swipe|recap)/u.test(normalized)) {
    return {action: "warmPostEventState"};
  }
  if (/(warm|seed).*(chat|match)/u.test(normalized)) {
    return {action: "warmChatState"};
  }
  if (/(warm|seed).*(payment|refund)/u.test(normalized)) {
    return {action: "warmPaymentState"};
  }
  if (/(reset|refresh)/u.test(normalized)) {
    return {action: "refreshDemoState"};
  }
  if (/(check|status)/u.test(normalized)) {
    return {action: "checkDemoState"};
  }
  return null;
}

/**
 * Creates a seeded match with another allowlisted tester by phone number.
 * @param {object} params Match parameters.
 * @return {Promise<string>} Bot reply.
 */
async function matchTesterByPhone({
  db,
  uid,
  targetPhone,
  text,
  operationId,
  deps,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  targetPhone?: string;
  text?: string;
  operationId: string;
  deps: SuvbotDeps;
}): Promise<string> {
  const phone = targetPhone ?? (text ? extractPhone(text) : undefined);
  if (!phone) {
    return "Type the tester's phone number like: match +919999999999.";
  }
  const target = await resolveUserByPhone(db, phone);
  if (target.uid === uid) {
    throw new HttpsError("invalid-argument", "Use another tester's phone.");
  }
  const access = await db
    .collection(SUVBOT_ACCESS_COLLECTION)
    .doc(target.uid)
    .get();
  if (access.data()?.enabled !== true) {
    throw new HttpsError(
      "failed-precondition",
      "That phone is not enabled for seeded beta self-service."
    );
  }
  const matchId = matchIdFor(uid, target.uid);
  const matchRef = db.collection("matches").doc(matchId);
  const existing = await matchRef.get();
  if (existing.exists && !isDemoOwned(existing.data())) {
    return "You already have a real chat with that tester. I left it alone.";
  }
  const marker = demoMarker({
    operationId,
    command: "suvbot-match-tester",
    deps,
  });
  const event = await findContextEventForMatch(db, uid, deps.now());
  const docs = testerMatchDocs({
    uid,
    targetUid: target.uid,
    targetName: target.name,
    event,
    marker,
    deps,
  });
  await applyWritePlan(db, docs);
  await writeDemoManifest({
    db,
    uid,
    operationId,
    command: "suvbot-match-tester",
    paths: docs.map((doc) => doc.path),
    deps,
  });
  return `Done. I matched you with ${target.name}.`;
}

/**
 * Resolves a user by E.164 phone number.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} phone Phone number.
 * @return {Promise<{uid: string, name: string}>} User identity.
 */
async function resolveUserByPhone(
  db: FirebaseFirestore.Firestore,
  phone: string
): Promise<{uid: string; name: string}> {
  const normalized = normalizePhone(phone);
  const snap = await db.collection("users")
    .where("phoneNumber", "==", normalized)
    .limit(1)
    .get();
  if (snap.empty) {
    throw new HttpsError("not-found", `No user found for ${normalized}.`);
  }
  const doc = snap.docs[0];
  const data = doc.data();
  return {
    uid: doc.id,
    name: publicName(data) ?? "that tester",
  };
}

/**
 * Builds a direct seeded tester match.
 * @param {object} params Match doc parameters.
 * @return {DemoDocWrite[]} Docs.
 */
function testerMatchDocs({
  uid,
  targetUid,
  targetName,
  event,
  marker,
  deps,
}: {
  uid: string;
  targetUid: string;
  targetName: string;
  event?: DemoEvent;
  marker: FirebaseFirestore.DocumentData;
  deps: SuvbotDeps;
}): DemoDocWrite[] {
  const [user1Id, user2Id] = [uid, targetUid].sort();
  const matchId = matchIdFor(uid, targetUid);
  const now = deps.now();
  const unreadCounts = {[user1Id]: 0, [user2Id]: 0};
  unreadCounts[targetUid] = 1;
  return [
    {
      path: `matches/${matchId}`,
      data: {
        ...marker,
        demoOpsEntityType: "matchThread",
        demoOpsDisposalPolicy: "deleteThreadWithMessages",
        user1Id,
        user2Id,
        participantIds: [user1Id, user2Id],
        eventIds: event ? [event.id] : [],
        createdAt: deps.timestampFromDate(now),
        lastMessageAt: deps.timestampFromDate(now),
        lastMessagePreview: "Suvbot created this seeded tester match.",
        lastMessageSenderId: SUVBOT_UID,
        unreadCounts,
        status: "active",
        blockedBy: null,
        blockedAt: null,
      },
    },
    {
      path: `matches/${matchId}/messages/suvbot_intro`,
      data: {
        ...marker,
        senderId: SUVBOT_UID,
        text: `Suvbot matched you with ${targetName} for beta testing.`,
        imageUrl: null,
        sentAt: deps.timestampFromDate(now),
      },
    },
    {
      path: `notifications/${targetUid}/items/suvbot_match_${matchId}`,
      data: {
        ...marker,
        uid: targetUid,
        type: "match",
        title: "Seeded tester match",
        body: "Suvbot created a beta test chat.",
        createdAt: deps.timestampFromDate(now),
        readAt: null,
        matchId,
        eventId: event?.id ?? null,
        actorUid: uid,
        actorName: "A beta tester",
      },
    },
  ];
}

/**
 * Finds an optional event context for a tester match.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid Current user id.
 * @param {Date} now Current time.
 * @return {Promise<DemoEvent | undefined>} Event context.
 */
async function findContextEventForMatch(
  db: FirebaseFirestore.Firestore,
  uid: string,
  now: Date
): Promise<DemoEvent | undefined> {
  const user = (await db.collection("users").doc(uid).get()).data();
  const {upcoming, past} = await findDemoEvents(db, user?.city, now);
  return past[0] ?? upcoming[0];
}

/**
 * Returns a public-ish display name from user data.
 * @param {FirebaseFirestore.DocumentData} data User data.
 * @return {string | null} Name.
 */
function publicName(data: FirebaseFirestore.DocumentData): string | null {
  for (const key of ["name", "displayName", "firstName"]) {
    const value = data[key];
    if (typeof value === "string" && value.trim()) return value.trim();
  }
  return null;
}

/**
 * Finds and normalizes the first E.164-looking phone number in text.
 * @param {string} text Input text.
 * @return {string | undefined} Phone number.
 */
function extractPhone(text: string): string | undefined {
  const match = text.match(/\+[1-9][\d\s-]{7,20}\d/u);
  return match ? normalizePhone(match[0]) : undefined;
}

/**
 * Normalizes an E.164 phone number.
 * @param {string} raw Raw phone.
 * @return {string} Normalized phone.
 */
function normalizePhone(raw: string): string {
  const value = raw.replace(/[\s-]+/gu, "").trim();
  if (!/^\+[1-9]\d{7,14}$/u.test(value)) {
    throw new HttpsError("invalid-argument", `Invalid phone number: ${raw}`);
  }
  return value;
}

/**
 * Returns a stable match id for two users.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @return {string} Match id.
 */
function matchIdFor(uidA: string, uidB: string): string {
  return [uidA, uidB].sort().join("_");
}

/**
 * Returns metadata for one action.
 * @param {SuvbotAction} action Action id.
 * @return {SuvbotActionDescriptor | undefined} Descriptor.
 */
function actionDefinition(
  action: SuvbotAction
): SuvbotActionDescriptor | undefined {
  return SUVBOT_ACTION_CATALOG.find((item) => item.id === action);
}

/**
 * Builds the user-visible message for a tapped action.
 * @param {SuvbotAction} action Suvbot action.
 * @return {string} Message text.
 */
function userFacingActionText(action: SuvbotAction): string {
  if (action === "message") return "Message";
  if (action === "listActions") return "List Suvbot actions";
  return actionDefinition(action)?.label ?? action;
}

/**
 * Returns help text for Suvbot.
 * @return {string} Help text.
 */
function helpText(): string {
  const actionLines = SUVBOT_ACTION_CATALOG.map((action) =>
    `- ${action.label}: ${action.description}`
  );
  return [
    "I can run safe beta-demo actions for your account.",
    "The chips below are loaded from the backend.",
    "We can add actions without an app update.",
    ...actionLines,
    "You can also type shortcuts like `match +919999999999`.",
  ].join("\n");
}

/**
 * Returns a deterministic response for typed text.
 * @param {string} text User text.
 * @return {string} Bot reply.
 */
function responseForFreeText(text: string): string {
  const normalized = text.toLowerCase();
  if (normalized.includes("match") || normalized.includes("tester")) {
    return "Type the tester's phone number like: match +919999999999.";
  }
  if (normalized.includes("reset") || normalized.includes("refresh")) {
    return [
      "I can reset all demo state or only chats, bookings, or alerts.",
      "Use the chips so destructive actions get confirmation.",
    ].join(" ");
  }
  if (normalized.includes("check") || normalized.includes("status")) {
    return "Tap Check setup and I will inspect your seeded state.";
  }
  return helpText();
}

/**
 * Formats a demo summary for chat.
 * @param {DemoSummary} summary Summary counts.
 * @return {string} Bot reply.
 */
function summaryText(summary: DemoSummary): string {
  return [
    "Here is your seeded setup right now:",
    `${summary.savedEvents} saved demo events.`,
    `${summary.activeEventParticipations} active demo event states.`,
    `${summary.attendedEvents} attended demo events for recap/swipes.`,
    `${summary.demoMatches} seeded match threads.`,
    `${summary.payments} demo payment records.`,
  ].join("\n");
}

/**
 * Truncates chat preview text to the app preview limit.
 * @param {string} text Message text.
 * @return {string} Preview.
 */
function previewText(text: string): string {
  return text.length <= 80 ? text : `${text.slice(0, 80)}…`;
}

/**
 * Adds an offset to a date.
 * @param {Date} date Base date.
 * @param {object} offset Offset fields.
 * @return {Date} Offset date.
 */
function offsetDate(
  date: Date,
  offset: {days?: number; hours?: number; minutes?: number}
): Date {
  return new Date(
    date.getTime() +
    (offset.days ?? 0) * 24 * 60 * 60 * 1000 +
    (offset.hours ?? 0) * 60 * 60 * 1000 +
    (offset.minutes ?? 0) * 60 * 1000
  );
}

/**
 * Converts Firestore-like timestamps to Dates.
 * @param {unknown} value Timestamp-like value.
 * @return {Date} Date or epoch fallback.
 */
function dateFromTimestamp(value: unknown): Date {
  if (value && typeof value === "object" && "toDate" in value) {
    const toDate = (value as {toDate?: () => Date}).toDate;
    if (typeof toDate === "function") return toDate.call(value);
  }
  return new Date(0);
}

/**
 * Adds a string value to a set when present.
 * @param {unknown} value Candidate value.
 * @param {Set<string>} target Target set.
 */
function collectString(value: unknown, target: Set<string>): void {
  if (typeof value === "string" && value.length > 0) target.add(value);
}

/**
 * Deduplicates docs by path.
 * @param {DemoDocWrite[]} docs Docs.
 * @return {DemoDocWrite[]} Unique docs.
 */
function uniqueDocsByPath(docs: DemoDocWrite[]): DemoDocWrite[] {
  return [...new Map(docs.map((doc) => [doc.path, doc])).values()]
    .sort((a, b) => a.path.localeCompare(b.path));
}

/**
 * Splits an array into chunks.
 * @param {Array<*>} items Items.
 * @param {number} size Chunk size.
 * @return {Array<Array<*>>} Chunks.
 */
function chunks<T>(items: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    result.push(items.slice(i, i + size));
  }
  return result;
}

/**
 * Returns true when a value is a plain record.
 * @param {unknown} value Candidate value.
 * @return {boolean} True for object records.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Returns true when an action is allowlisted.
 * @param {string} action Candidate action.
 * @return {boolean} True when supported.
 */
export function isSuvbotAction(action: string): action is SuvbotAction {
  return action === "listActions" ||
    action === "message" ||
    SUVBOT_ACTION_CATALOG.some((item) => item.id === action);
}

export const listSuvbotDemoActions = onCall(
  appCheckCallableOptions,
  (request) => listSuvbotDemoActionsHandler(request)
);

export const requestSuvbotDemoOperation = onCall(
  appCheckCallableOptions,
  (request) => requestSuvbotDemoOperationHandler(request)
);
