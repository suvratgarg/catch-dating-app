/* eslint-disable require-jsdoc */
import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  ClubHostClaimDocument,
  HostPaymentAccountDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {normalizePayloadStrings} from "../shared/callablePayloadNormalization";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {publicDisplayName} from "../shared/profileProjection";
import {
  CreateStripeHostOnboardingLinkCallablePayload,
} from "../shared/generated/createStripeHostOnboardingLinkCallablePayload";
import {
  RefreshStripeHostPaymentAccountCallablePayload,
} from "../shared/generated/refreshStripeHostPaymentAccountCallablePayload";
import {
  validateCreateStripeHostOnboardingLinkCallablePayload,
  validateRefreshStripeHostPaymentAccountCallablePayload,
} from "../shared/generated/schemaValidators";
import {
  createStripeClient,
  StripeAccountSnapshot,
  StripeClient,
  stripeConnectRefreshUrlValue,
  stripeConnectReturnUrlValue,
  stripeSecretKey,
} from "./stripe";

interface StripeHostAccountDeps {
  firestore: () => FirebaseFirestore.Firestore;
  stripe: () => StripeClient;
  serverTimestamp: () => unknown;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: StripeHostAccountDeps = {
  firestore: () => admin.firestore(),
  stripe: createStripeClient,
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

export async function createStripeHostOnboardingLinkHandler(
  request: CallableRequest<unknown>,
  deps: StripeHostAccountDeps = defaultDeps
): Promise<{accountId: string; onboardingUrl: string}> {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<
    CreateStripeHostOnboardingLinkCallablePayload
  >(
    request,
    validateCreateStripeHostOnboardingLinkCallablePayload,
    normalizeStripeHostOnboardingPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "createStripeHostOnboardingLink");

  const [userSnap, hostClaimSnap, accountSnap] = await Promise.all([
    db.collection("users").doc(uid).get(),
    db.collection("clubHostClaims").doc(uid).get(),
    db.collection("hostPaymentAccounts").doc(uid).get(),
  ]);
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }
  if (!hostClaimSnap.exists) {
    throw new HttpsError(
      "permission-denied",
      "Only club owners can set up payouts."
    );
  }

  const user = requireDoc<UserProfileDocument>(
    userSnap,
    "UserProfileDocument"
  );
  requireDoc<ClubHostClaimDocument>(
    hostClaimSnap,
    "ClubHostClaimDocument"
  );
  const stripe = deps.stripe();
  const existingAccount = accountSnap.exists ?
    requireDoc<HostPaymentAccountDocument>(
      accountSnap,
      "HostPaymentAccountDocument"
    ) :
    null;
  const account = existingAccount === null ?
    await stripe.createConnectedAccount({
      contactEmail: user.email,
      displayName: publicDisplayName(user),
      country: payload.country ?? "US",
      defaultCurrency: payload.defaultCurrency ?? "USD",
    }) :
    await stripe.retrieveConnectedAccount(existingAccount.stripeAccountId);

  await writeHostPaymentAccount({
    db,
    uid,
    account,
    createdAt: existingAccount === null ? deps.serverTimestamp() : undefined,
    updatedAt: deps.serverTimestamp(),
  });

  const link = await stripe.createAccountLink({
    accountId: account.id,
    returnUrl: stripeConnectReturnUrlValue(),
    refreshUrl: stripeConnectRefreshUrlValue(),
  });
  return {accountId: account.id, onboardingUrl: link.url};
}

export async function refreshStripeHostPaymentAccountHandler(
  request: CallableRequest<unknown>,
  deps: StripeHostAccountDeps = defaultDeps
): Promise<{account: HostPaymentAccountDocument | null}> {
  const uid = requireAuth(request);
  validateCallableWithAjv<RefreshStripeHostPaymentAccountCallablePayload>(
    request,
    validateRefreshStripeHostPaymentAccountCallablePayload,
    normalizeRefreshStripeHostPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "refreshStripeHostPaymentAccount");
  const accountRef = db.collection("hostPaymentAccounts").doc(uid);
  const accountSnap = await accountRef.get();
  if (!accountSnap.exists) {
    return {account: null};
  }
  const existingAccount = requireDoc<HostPaymentAccountDocument>(
    accountSnap,
    "HostPaymentAccountDocument"
  );
  const account = await deps.stripe().retrieveConnectedAccount(
    existingAccount.stripeAccountId
  );
  const next = hostPaymentAccountDocument({
    uid,
    account,
    createdAt: existingAccount.createdAt,
    updatedAt: deps.serverTimestamp(),
    lastStripeEventId: existingAccount.lastStripeEventId ?? null,
  });
  await accountRef.set(next, {merge: true});
  return {account: next};
}

export async function syncHostPaymentAccountByStripeAccountId({
  db,
  stripeAccountId,
  account,
  serverTimestamp,
  lastStripeEventId,
}: {
  db: FirebaseFirestore.Firestore;
  stripeAccountId: string;
  account: StripeAccountSnapshot;
  serverTimestamp: unknown;
  lastStripeEventId?: string;
}): Promise<void> {
  const snap = await db
    .collection("hostPaymentAccounts")
    .where("stripeAccountId", "==", stripeAccountId)
    .limit(1)
    .get();
  if (snap.empty) return;
  const doc = snap.docs[0];
  const existing = requireDoc<HostPaymentAccountDocument>(
    doc,
    "HostPaymentAccountDocument"
  );
  await doc.ref.set(
    hostPaymentAccountDocument({
      uid: existing.userId,
      account,
      createdAt: existing.createdAt,
      updatedAt: serverTimestamp,
      lastStripeEventId: lastStripeEventId ??
        existing.lastStripeEventId ??
        null,
    }),
    {merge: true}
  );
}

function hostPaymentAccountDocument({
  uid,
  account,
  createdAt,
  updatedAt,
  lastStripeEventId = null,
}: {
  uid: string;
  account: StripeAccountSnapshot;
  createdAt: unknown;
  updatedAt: unknown;
  lastStripeEventId?: string | null;
}): HostPaymentAccountDocument {
  return {
    userId: uid,
    provider: "stripe",
    country: account.country,
    defaultCurrency: account.defaultCurrency,
    stripeAccountId: account.id,
    chargesEnabled: account.chargesEnabled,
    payoutsEnabled: account.payoutsEnabled,
    detailsSubmitted: account.detailsSubmitted,
    onboardingStatus: onboardingStatus(account),
    disabledReason: account.requirements.disabledReason,
    requirementsCurrentlyDue: unique(account.requirements.currentlyDue),
    requirementsPastDue: unique(account.requirements.pastDue),
    requirementsPendingVerification:
      unique(account.requirements.pendingVerification),
    lastStripeEventId,
    createdAt: createdAt as FirebaseFirestore.Timestamp,
    updatedAt: updatedAt as FirebaseFirestore.Timestamp,
  };
}

async function writeHostPaymentAccount({
  db,
  uid,
  account,
  createdAt,
  updatedAt,
}: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  account: StripeAccountSnapshot;
  createdAt?: unknown;
  updatedAt: unknown;
}) {
  const ref = db.collection("hostPaymentAccounts").doc(uid);
  const base = hostPaymentAccountDocument({
    uid,
    account,
    createdAt: createdAt ?? updatedAt,
    updatedAt,
  });
  await ref.set(base, {merge: true});
}

function onboardingStatus(
  account: StripeAccountSnapshot
): HostPaymentAccountDocument["onboardingStatus"] {
  if (account.requirements.pastDue.length > 0 ||
      account.requirements.disabledReason !== null) {
    return "restricted";
  }
  if (
    account.chargesEnabled &&
    account.payoutsEnabled &&
    account.requirements.currentlyDue.length === 0
  ) {
    return "complete";
  }
  return "pending";
}

function normalizeStripeHostOnboardingPayload(data: unknown): unknown {
  const normalized = normalizePayloadStrings(data, {
    stringFields: ["country", "defaultCurrency"],
  });
  if (normalized === null || typeof normalized !== "object") return normalized;
  const payload = normalized as Record<string, unknown>;
  if (typeof payload.country === "string") {
    payload.country = payload.country.toUpperCase();
  }
  if (typeof payload.defaultCurrency === "string") {
    payload.defaultCurrency = payload.defaultCurrency.toUpperCase();
  }
  return payload;
}

function normalizeRefreshStripeHostPayload(data: unknown): unknown {
  return data ?? {};
}

function unique(values: string[]): string[] {
  return [...new Set(values)];
}

export const createStripeHostOnboardingLink = onCall(
  appCheckCallableOptionsWithSecrets([stripeSecretKey]),
  (request) => createStripeHostOnboardingLinkHandler(request)
);

export const refreshStripeHostPaymentAccount = onCall(
  appCheckCallableOptionsWithSecrets([stripeSecretKey]),
  (request) => refreshStripeHostPaymentAccountHandler(request)
);
