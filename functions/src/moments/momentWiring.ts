import * as admin from "firebase-admin";
import type {Firestore} from "firebase-admin/firestore";
import {
  metaWhatsappAppId,
  metaWhatsappAppSecret,
  metaWhatsappConfigId,
  metaWhatsappGraphVersion,
} from "../organizers/organizerMessagingSetup";
import {
  MetaWhatsappProvider,
  OrganizerTokenStore,
  metaTemplateFromDocument,
} from "../organizers/organizerWhatsappProvider";
import {
  activityNotificationId,
  allowsPushPreference,
  createActivityNotificationIfAbsent,
  eventActivityNotificationCopy,
  sendFcmNotification,
  type ActivityNotificationType,
  type NotificationPreference,
  type NotificationPreferenceDocument,
} from "../shared/notifications";
import type {
  OrganizerMessageTemplateDocument,
  OrganizerSenderConnectionDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {
  MomentDefinition,
  MomentScope,
} from "./momentModel";
import type {ResolvedRecipient} from "./momentDocuments";
import type {ConsentFacts, QuietHours} from "./momentPolicy";
import type {MomentRunnerDeps} from "./momentRunner";

/**
 * Production seams for the moment runner. The runner decides who/whether;
 * this module owns how: Meta WhatsApp templates through the same provider +
 * token store the campaign dispatcher uses, FCM + activity items through
 * shared/notifications, and consent facts from household consent or user
 * notification preferences.
 *
 * Quiet hours default to 21:00-08:00 local in the scope's timezone; a scope
 * doc may override with `messagingQuietHours {startMinute,endMinute}` and
 * `messagingDailyCap` (per-endpoint sends per local day; default 4).
 */

const DEFAULT_TIMEZONE = "Asia/Kolkata";
const DEFAULT_QUIET_HOURS: QuietHours = {startMinute: 21 * 60, endMinute: 480};
const DEFAULT_DAILY_CAP = 4;

const ACTIVITY_TYPES: ReadonlySet<string> = new Set([
  "message", "match", "eventReminder", "eventSignup", "waitlistPromotion",
  "waitlistOffer", "waitlistOfferExpiring", "waitlistOfferExpired",
  "eventCancelled", "eventUpdated", "clubUpdate", "organizerUpdate",
  "formResponse", "crossPathsInvitation", "crossPathsInvitationAccepted",
  "crossPathsInvitationDeclined", "crossPathsPlanCancelled",
]);

const PREFERENCE_KEYS: ReadonlySet<string> = new Set([
  "matches", "messages", "eventReminders", "eventStatusUpdates",
  "clubUpdates", "crossPathsInvitations",
]);

export function buildMomentRunnerDeps(
  overrides?: Partial<MomentRunnerDeps>,
): MomentRunnerDeps {
  const firestore = overrides?.firestore ?? (() => admin.firestore());
  const tokenStore = new OrganizerTokenStore();
  const provider = () => new MetaWhatsappProvider({
    appId: metaWhatsappAppId.value(),
    appSecret: metaWhatsappAppSecret.value(),
    configId: metaWhatsappConfigId.value(),
    graphVersion: metaWhatsappGraphVersion.value(),
  });
  const timezoneCache = new Map<string, Promise<string>>();
  const timezoneFor = (scope: MomentScope): Promise<string> => {
    const key = `${scope.kind}:${scopeIdOf(scope)}`;
    if (!timezoneCache.has(key)) {
      timezoneCache.set(key, loadScopeTimezone(firestore(), scope));
    }
    return timezoneCache.get(key)!;
  };

  const deps: MomentRunnerDeps = {
    firestore,
    nowMillis: () => Date.now(),
    quietEndMillis: async (scope, nowMillis) => {
      const tz = await timezoneFor(scope);
      const quiet = await loadQuietHours(firestore(), scope);
      return quietEndWith(quiet, tz, nowMillis);
    },
    localDayKey: async (scope, nowMillis) =>
      localDayKeyAt(nowMillis, await timezoneFor(scope)),
    localMinuteOfDay: async (scope, nowMillis) =>
      localMinuteAt(nowMillis, await timezoneFor(scope)),
    quietHoursFor: (scope) => loadQuietHours(firestore(), scope),
    dailyCapFor: (scope) => loadDailyCap(firestore(), scope),
    pushCopyFor: (moment) => pushCopy(firestore(), moment),
    sendTemplateToPhone: (params) =>
      sendTemplate(firestore(), tokenStore, provider(), params),
    sendPushToUid: (params) => sendPush(firestore(), params),
    writeStaffAttention: (params) => staffAttention(firestore(), params),
    loadConsentFacts: (recipient, moment) =>
      consentFacts(firestore(), recipient, moment),
    ...overrides,
  };
  return deps;
}

// --- Scope facts -----------------------------------------------------------

function scopeIdOf(scope: MomentScope): string {
  return scope.kind === "event" ? scope.eventId : scope.programId;
}

function scopeDocRef(db: Firestore, scope: MomentScope) {
  return scope.kind === "event" ?
    db.collection("events").doc(scope.eventId) :
    db.collection("organizerPrograms").doc(scope.programId);
}

async function loadScopeTimezone(
  db: Firestore,
  scope: MomentScope,
): Promise<string> {
  const snap = await scopeDocRef(db, scope).get();
  const tz = (snap.data() as Record<string, unknown> | undefined)?.timezone;
  return typeof tz === "string" && tz.length > 0 ? tz : DEFAULT_TIMEZONE;
}

async function loadQuietHours(
  db: Firestore,
  scope: MomentScope,
): Promise<QuietHours | null> {
  const snap = await scopeDocRef(db, scope).get();
  const raw = (snap.data() as Record<string, unknown> | undefined)
    ?.messagingQuietHours;
  if (typeof raw === "object" && raw !== null) {
    const row = raw as Record<string, unknown>;
    if (Number.isSafeInteger(row.startMinute) &&
        Number.isSafeInteger(row.endMinute)) {
      return {
        startMinute: row.startMinute as number,
        endMinute: row.endMinute as number,
      };
    }
  }
  return DEFAULT_QUIET_HOURS;
}

async function loadDailyCap(
  db: Firestore,
  scope: MomentScope,
): Promise<number> {
  const snap = await scopeDocRef(db, scope).get();
  const raw = (snap.data() as Record<string, unknown> | undefined)
    ?.messagingDailyCap;
  return Number.isSafeInteger(raw) && (raw as number) >= 0 ?
    raw as number : DEFAULT_DAILY_CAP;
}

// --- Local-time helpers ------------------------------------------------------

function localMinuteAt(nowMillis: number, timeZone: string): number {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone, hour12: false, hour: "2-digit", minute: "2-digit",
  }).formatToParts(new Date(nowMillis));
  const hour = Number(parts.find((p) => p.type === "hour")?.value ?? 0) % 24;
  const minute = Number(parts.find((p) => p.type === "minute")?.value ?? 0);
  return hour * 60 + minute;
}

function localDayKeyAt(nowMillis: number, timeZone: string): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone, year: "numeric", month: "2-digit", day: "2-digit",
  }).formatToParts(new Date(nowMillis));
  const get = (type: string) =>
    parts.find((p) => p.type === type)?.value ?? "";
  return `${get("year")}-${get("month")}-${get("day")}`;
}

/** Ms timestamp when the quiet window ends, or null when now is sendable.
 *  Exported for tests; walks forward in bounded 15-minute steps so a
 *  malformed window can never loop. */
export function quietEndWith(
  quiet: QuietHours | null,
  timeZone: string,
  nowMillis: number,
): number | null {
  if (quiet === null) return null;
  if (quiet.startMinute === quiet.endMinute) return null;
  const inQuiet = (ms: number) => {
    const minute = localMinuteAt(ms, timeZone);
    if (quiet.startMinute < quiet.endMinute) {
      return minute >= quiet.startMinute && minute < quiet.endMinute;
    }
    return minute >= quiet.startMinute || minute < quiet.endMinute;
  };
  if (!inQuiet(nowMillis)) return null;
  // Walk forward in 15-minute steps until outside quiet hours; bounded to
  // 97 steps (>24h) so a malformed window can never loop forever.
  let candidate = nowMillis;
  for (let i = 0; i < 97; i += 1) {
    candidate += 15 * 60_000;
    if (!inQuiet(candidate)) return candidate;
  }
  return nowMillis + 24 * 60 * 60_000;
}

// --- Delivery seams ----------------------------------------------------------

async function sendTemplate(
  db: Firestore,
  tokenStore: OrganizerTokenStore,
  provider: MetaWhatsappProvider,
  params: {
    e164: string;
    connectionId: string;
    templateId: string;
    variables: Readonly<Record<string, string>>;
    runId: string;
    recipientKey: string;
  },
): Promise<void> {
  const [connSnap, templateSnap] = await Promise.all([
    db.collection("organizerSenderConnections").doc(params.connectionId)
      .get(),
    db.collection("organizerMessageTemplates").doc(params.templateId).get(),
  ]);
  const connection = connSnap.data() as
    OrganizerSenderConnectionDocument | undefined;
  const template = templateSnap.data() as
    OrganizerMessageTemplateDocument | undefined;
  if (!connection?.secretVersionResource || !connection.phoneNumberId ||
      !template) {
    throw new Error(
      "Moment send blocked: connection/template incomplete " +
      `(run ${params.runId}).`);
  }
  const accessToken = await tokenStore.access(
    connection.secretVersionResource);
  await provider.sendTemplate({
    accessToken,
    phoneNumberId: connection.phoneNumberId,
    toE164: params.e164,
    template: metaTemplateFromDocument(template),
    variables: {...params.variables},
    callbackData: `moment:${params.runId}:${params.recipientKey}`,
  });
}

async function pushCopy(
  db: Firestore,
  moment: MomentDefinition,
): Promise<{title: string; body: string}> {
  if (moment.scope.kind === "event" &&
      moment.action.kind === "push" &&
      ACTIVITY_TYPES.has(moment.action.notificationType)) {
    const eventSnap = await db.collection("events")
      .doc(moment.scope.eventId).get();
    const event = eventSnap.data() as
      Parameters<typeof eventActivityNotificationCopy>[1] | undefined;
    if (event) {
      return eventActivityNotificationCopy(
        moment.action.notificationType as ActivityNotificationType, event);
    }
  }
  return {title: moment.name, body: ""};
}

async function sendPush(
  db: Firestore,
  params: {
    uid: string;
    title: string;
    body: string;
    notificationType: string;
    scope: MomentScope;
    runId: string;
    recipientKey: string;
  },
): Promise<void> {
  const type = ACTIVITY_TYPES.has(params.notificationType) ?
    params.notificationType as ActivityNotificationType : "organizerUpdate";
  await createActivityNotificationIfAbsent(db, {
    id: activityNotificationId(type, `${params.runId}`),
    uid: params.uid,
    type,
    title: params.title,
    body: params.body,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    ...(params.scope.kind === "event" ?
      {eventId: params.scope.eventId} : {}),
  });
  const userSnap = await db.collection("users").doc(params.uid).get();
  const user = userSnap.data() as UserProfileDocument | undefined;
  if (!user?.fcmToken) return;
  await sendFcmNotification({
    token: user.fcmToken,
    title: params.title,
    body: params.body,
    type: params.notificationType,
    notificationId: activityNotificationId(type, `${params.runId}`),
    recipientUid: params.uid,
    appRole: "host",
    ...(params.scope.kind === "event" ?
      {eventId: params.scope.eventId} : {}),
  });
}

async function staffAttention(
  db: Firestore,
  params: {
    uid: string;
    duty: string;
    scopeIds: ReadonlyArray<string> | null;
    severity: "info" | "warning" | "urgent";
    title: string;
    scope: MomentScope;
    runId: string;
  },
): Promise<void> {
  // Attention-item projection ownership lives in organizerAttention; the
  // durable signal to the staff member is an activity item + push.
  const id = activityNotificationId(
    "organizerUpdate", `${params.runId}_${params.uid}`);
  await createActivityNotificationIfAbsent(db, {
    id,
    uid: params.uid,
    type: "organizerUpdate",
    title: params.title,
    body: params.title,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    ...(params.scope.kind === "event" ?
      {eventId: params.scope.eventId} : {}),
  });
  const userSnap = await db.collection("users").doc(params.uid).get();
  const user = userSnap.data() as UserProfileDocument | undefined;
  if (!user?.fcmToken) return;
  await sendFcmNotification({
    token: user.fcmToken,
    title: params.title,
    body: params.title,
    type: "organizerUpdate",
    notificationId: id,
    recipientUid: params.uid,
    appRole: "host",
  });
}

// --- Consent facts ---------------------------------------------------------

async function consentFacts(
  db: Firestore,
  recipient: ResolvedRecipient,
  moment: MomentDefinition,
): Promise<ConsentFacts> {
  const facts: ConsentFacts = {};
  if (recipient.householdId !== null) {
    const snap = await db.collection("programHouseholds")
      .doc(recipient.householdId).get();
    const consent = (snap.data() as Record<string, unknown> | undefined)
      ?.messagingConsent;
    if (typeof consent === "object" && consent !== null &&
        typeof (consent as {granted?: unknown}).granted === "boolean") {
      facts.householdConsentGranted =
        (consent as {granted: boolean}).granted;
    }
  }
  if (recipient.endpoint.kind === "uid" &&
      moment.action.kind === "push") {
    const snap = await db.collection("users")
      .doc(recipient.endpoint.uid).get();
    const user = snap.data() as NotificationPreferenceDocument | undefined;
    const key = PREFERENCE_KEYS.has(moment.action.preferenceKey) ?
      moment.action.preferenceKey as NotificationPreference : null;
    // Unknown preference keys fail closed; a missing user doc is treated
    // as opted out, matching allowsPushPreference's default.
    facts.communicationPermission =
      key !== null && allowsPushPreference(user, key) ?
        "optedIn" : "optedOut";
  }
  return facts;
}
