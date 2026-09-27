import {HttpsError} from "firebase-functions/v2/https";
import {assertPaymentRouteSnapshot} from "../paymentRouting";
import {razorpayCollectionRoutingDefaults,
  assertRazorpayCollectionBindingReady,
  type RazorpayCollectionRoutingDeps} from "../razorpayCollectionRouting";
import {RazorpayRouteProvider} from "../formPayments/razorpayRouteProvider";
import {OfferPaymentProcessor, type OfferPaymentAuthority,
  type OfferPaymentProcessorDeps} from "./offerPaymentProcessor";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";

/** Recovery loads the frozen configuration, regardless of today's default. */
export async function offerPaymentExecutionFor(input: {
  db: FirebaseFirestore.Firestore; paymentId: string;
}, deps: RazorpayCollectionRoutingDeps = razorpayCollectionRoutingDefaults) {
  const {db, paymentId} = input;
  const payment = parseOfferPayment((await db
    .collection(OFFER_PAYMENT_COLLECTION)
    .doc(paymentId).get()).data(), paymentId);
  const snapshot = payment.routing;
  assertPaymentRouteSnapshot(snapshot, {organizerId: payment.organizerId,
    purpose: "eventAdmission", currency: payment.currency,
    amountMinor: payment.amountPaise});
  let provider: OfferPaymentProcessorDeps["provider"];
  let resolve: OfferPaymentAuthority["resolve"];
  if (snapshot.selection.route === "razorpayRoute") {
    const profile = await deps.platform(snapshot.configurationVersion);
    if (profile.mode !== snapshot.selection.mode ||
        profile.platformAccountId !== snapshot.merchantAccountId ||
        profile.keyId !== snapshot.checkoutKey || !snapshot.settlementHold) {
      unavailable();
    }
    provider = new RazorpayRouteProvider({keyId: profile.keyId,
      keySecret: profile.keySecret, mode: profile.mode, terms: {
        paymentAmountMinor: snapshot.amountMinor,
        destinationAccountId: snapshot.destinationAccountId!,
        transferAmountMinor: snapshot.transferAmountMinor!,
        settlementHold: true}});
    resolve = async () => ({accountId: profile.platformAccountId,
      mode: profile.mode, authorizationHandle: profile.keyId,
      checkoutKey: profile.keyId, expiresAtMillis: Number.MAX_SAFE_INTEGER});
  } else if (snapshot.selection.route === "razorpayOAuth") {
    const runtime = await deps.oauth(snapshot.configurationVersion);
    if (runtime.mode !== snapshot.selection.mode) unavailable();
    provider = runtime.provider;
    resolve = async () => {
      const credential = await runtime.credentials.access({
        organizerId: snapshot.organizerId, connectionId: snapshot.bindingId,
        accountId: snapshot.merchantAccountId, mode: snapshot.selection.mode});
      if (credential.accountId !== snapshot.merchantAccountId ||
          credential.mode !== snapshot.selection.mode ||
          credential.token.publicToken !== snapshot.checkoutKey ||
          credential.token.expiresAt <= Date.now()) unavailable();
      return {accountId: credential.accountId, mode: credential.mode,
        authorizationHandle: credential.token.accessToken,
        checkoutKey: credential.token.publicToken,
        expiresAtMillis: credential.token.expiresAt};
    };
  } else {
    unavailable();
  }
  const authority: OfferPaymentAuthority = {resolve,
    assertReady: (tx) => assertRazorpayCollectionBindingReady({db, tx,
      snapshot, nowMillis: Date.now()})};
  return new OfferPaymentProcessor({db, paymentId, routing: snapshot,
    authority, provider});
}
function unavailable(): never {
  throw new HttpsError("failed-precondition", "Payment route is unavailable.");
}
