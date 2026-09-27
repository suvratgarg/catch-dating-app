import * as admin from "firebase-admin";
import Razorpay from "razorpay";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerPaymentConnectionDocument as Connection,
  OrganizerFormPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../../shared/validation";
import {PaymentRoutingRegistry, readPaymentRoute, assertPaymentRouteSnapshot,
  type PaymentRoutingSnapshot} from "../paymentRouting";
import {RazorpayPlatformPaymentConfigLoader,
  razorpayPlatformPaymentConfigVersion,
  type RazorpayPlatformPaymentConfig} from "../razorpayPlatformPaymentConfig";
import {formPaymentRuntime} from "./formPaymentRuntime";
import {requireReadyFormPaymentConnection} from "./formPaymentConnectionPolicy";
import {FormPaymentProcessor, type FormPaymentAuthority} from
  "./formPaymentProcessor";
import {RazorpayRouteProvider} from "./razorpayRouteProvider";
import {RazorpayRouteFormAuthority, readReadyRouteAccount} from
  "./razorpayRouteFormAuthority";

export interface FormPaymentExecution {
  processor: FormPaymentProcessor;
  authority?: FormPaymentAuthority;
}
let platformConfig: RazorpayPlatformPaymentConfigLoader | undefined;

function platformLoader(): RazorpayPlatformPaymentConfigLoader {
  const projectId = admin.app().options.projectId ??
    process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT ?? "";
  platformConfig ??= new RazorpayPlatformPaymentConfigLoader(projectId);
  return platformConfig;
}

interface RoutingDeps {
  oauth: typeof formPaymentRuntime;
  platformVersion: () => string;
  platform: (version: string) => Promise<RazorpayPlatformPaymentConfig>;
  verifyDestination: (profile: RazorpayPlatformPaymentConfig,
    accountId: string, productId: string) => Promise<void>;
}
const defaults: RoutingDeps = {
  oauth: formPaymentRuntime,
  platformVersion: () => razorpayPlatformPaymentConfigVersion.value().trim(),
  platform: (version) => platformLoader().load(version),
  verifyDestination: async (profile, accountId, productId) => {
    try {
      const client = new Razorpay({key_id: profile.keyId,
        key_secret: profile.keySecret});
      const [account, product] = await Promise.all([
        client.accounts.fetch(accountId),
        client.products.fetch(accountId, productId),
      ]);
      const accountData = account as unknown as {id: string; status: string};
      const productData = product as unknown as {
        id: string; activation_status: string};
      if (accountData.id !== accountId ||
          !["created", "activated"].includes(accountData.status) ||
          productData.id !== productId ||
          productData.activation_status !== "activated") unavailable();
    } catch {
      // Provider replies can include onboarding details. Keep errors bounded.
      unavailable();
    }
  },
};

/** Only new attempts choose policy. */
export async function prepareFormPaymentRouting(input: {
  db: FirebaseFirestore.Firestore; paymentId: string; organizerId: string;
  connectionId: string | null; amountPaise: number;
}, deps: RoutingDeps = defaults):
  Promise<{snapshot: PaymentRoutingSnapshot; runtime: FormPaymentExecution}> {
  const {db, organizerId, paymentId, connectionId, amountPaise} = input;
  const connectionSnap = connectionId ? await db
    .collection("organizerPaymentConnections").doc(connectionId).get() : null;
  const connection = connectionSnap?.exists ? requireDoc<Connection>(
    connectionSnap, "OrganizerPaymentConnectionDocument") : null;
  const selected = await readPaymentRoute({db, organizerId, purpose: "formFee",
    legacySelection: connection ? {route: "razorpayOAuth",
      mode: connection.mode, currency: "INR", merchantCountry: "IN"} :
      undefined});
  const registry = new PaymentRoutingRegistry<FormPaymentExecution>({
    razorpayOAuth: {
      prepare: async ({selection}) => {
        const ready = requireReadyFormPaymentConnection(connection,
          organizerId, Date.now());
        if (!connectionId || ready.mode !== selection.mode) unavailable();
        const runtime = await deps.oauth();
        if (runtime.mode !== selection.mode) unavailable();
        await runtime.credentials.access({organizerId, connectionId,
          accountId: ready.accountId!, mode: ready.mode});
        return {bindingId: connectionId, merchantAccountId: ready.accountId!,
          destinationAccountId: null, checkoutKey: ready.publicToken!,
          configurationVersion: runtime.configurationVersion,
          transferAmountMinor: null, settlementHold: null};
      },
      resume: (snapshot) => executionForSnapshot(db, paymentId, snapshot, deps),
    },
    razorpayRoute: {
      prepare: async ({selection}) => {
        const configurationVersion = deps.platformVersion();
        const profile = await deps.platform(configurationVersion);
        if (profile.mode !== selection.mode) unavailable();
        const {bindingId, account} = await readReadyRouteAccount({db,
          organizerId});
        await deps.verifyDestination(profile, account.providerAccountId,
          account.razorpayProductId!);
        const feeMinor = Math.floor(amountPaise *
          profile.feeBasisPoints.formFee / 10000);
        const transferAmountMinor = amountPaise - feeMinor;
        if (transferAmountMinor < 100) unavailable();
        return {bindingId, merchantAccountId: profile.platformAccountId,
          destinationAccountId: account.providerAccountId,
          checkoutKey: profile.keyId, configurationVersion,
          transferAmountMinor, settlementHold: false};
      },
      resume: (snapshot) => executionForSnapshot(db, paymentId, snapshot, deps),
    },
  });
  return registry.prepare({organizerId, purpose: "formFee", currency: "INR",
    amountMinor: amountPaise, selected});
}

/** Pinned provider and authority are always resolved together, per payment. */
export async function formPaymentExecutionFor(input: {
  db: FirebaseFirestore.Firestore; paymentId: string; payment: Payment;
}, deps: RoutingDeps = defaults): Promise<FormPaymentExecution> {
  const {db, paymentId, payment} = input;
  if (!payment.routing) {
    // Compatibility for the existing, necessarily OAuth-only ledger shape.
    if (!payment.connectionId) unavailable();
    const runtime = await deps.oauth();
    return {processor: new FormPaymentProcessor({...runtime, db,
      boundPaymentId: paymentId})};
  }
  assertPaymentRouteSnapshot(payment.routing, {
    organizerId: payment.organizerId,
    purpose: "formFee", currency: payment.currency,
    amountMinor: payment.amountPaise});
  return executionForSnapshot(db, paymentId, payment.routing, deps);
}

async function executionForSnapshot(db: FirebaseFirestore.Firestore,
  paymentId: string, snapshot: PaymentRoutingSnapshot, deps: RoutingDeps):
  Promise<FormPaymentExecution> {
  assertPaymentRouteSnapshot(snapshot, {organizerId: snapshot.organizerId,
    purpose: "formFee", currency: "INR"});
  if (snapshot.selection.route === "razorpayOAuth") {
    const runtime = await deps.oauth(snapshot.configurationVersion);
    if (runtime.mode !== snapshot.selection.mode) unavailable();
    return {processor: new FormPaymentProcessor({...runtime, db,
      boundPaymentId: paymentId, expectedRouting: snapshot})};
  }
  if (snapshot.selection.route !== "razorpayRoute") unavailable();
  const profile = await deps.platform(snapshot.configurationVersion);
  const authority = new RazorpayRouteFormAuthority(db, snapshot, profile);
  const provider = new RazorpayRouteProvider({keyId: profile.keyId,
    keySecret: profile.keySecret, mode: profile.mode, terms: {
      paymentAmountMinor: snapshot.amountMinor,
      destinationAccountId: snapshot.destinationAccountId!,
      transferAmountMinor: snapshot.transferAmountMinor!,
      settlementHold: snapshot.settlementHold!,
    }});
  return {authority, processor: new FormPaymentProcessor({db, provider,
    authority, boundPaymentId: paymentId, expectedRouting: snapshot})};
}

function unavailable(): never {
  throw new HttpsError("failed-precondition",
    "The selected payment collection route is not ready.");
}

/** Recovery does not depend on current routing configuration. */
export function routedFormPaymentProcessor(db: FirebaseFirestore.Firestore) {
  return {reconcile: async (paymentId: string, providerPaymentId?: string) => {
    const payment = requireDoc<Payment>(await db
      .collection("organizerFormPayments").doc(paymentId).get(),
    "OrganizerFormPaymentDocument");
    const {processor} = await formPaymentExecutionFor({db, paymentId, payment});
    return processor.reconcile(paymentId, providerPaymentId);
  }};
}

/** Safe Host setup projection without fallback to another route. */
export async function formPaymentCollectionSetup(input: {
  db: FirebaseFirestore.Firestore; organizerId: string;
}, deps: RoutingDeps = defaults): Promise<{
  route: "disabled" | PaymentRoutingSnapshot["selection"]["route"];
  mode: "test" | "live" | null; ready: boolean;
} | null> {
  let selected;
  try {
    selected = await readPaymentRoute({...input, purpose: "formFee",
      legacySelection: {route: "razorpayOAuth", mode: "test",
        currency: "INR", merchantCountry: "IN"}});
  } catch {
    return {route: "disabled", mode: null, ready: false};
  }
  if (selected.policySource === "legacy") return null;
  const {route, mode, currency, merchantCountry} = selected.selection;
  const result = {route, mode, ready: false};
  if (currency !== "INR" || merchantCountry !== "IN") return result;
  try {
    if (route === "razorpayRoute") {
      const profile = await deps.platform(deps.platformVersion());
      if (profile.mode !== mode) return result;
      const {account} = await readReadyRouteAccount(input);
      await deps.verifyDestination(profile, account.providerAccountId,
        account.razorpayProductId!);
      return {...result, ready: true};
    }
    if (route === "razorpayOAuth") {
      const runtime = await deps.oauth();
      return {...result, ready: runtime.mode === mode};
    }
  } catch {
    return result;
  }
  return result;
}

export function loadFormPlatformProfile(configurationVersion: string) {
  return platformLoader().load(configurationVersion);
}
