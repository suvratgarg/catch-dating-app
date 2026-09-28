import {eventPaymentProviderFor} from "../eventCheckout/eventPaymentRuntime";
import {razorpayCollectionRoutingDefaults,
  type RazorpayCollectionRoutingDeps} from "../razorpayCollectionRouting";
import {OfferPaymentProcessor} from "./offerPaymentProcessor";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";

/** Source adapter validates the full offer ledger before merchant recovery. */
export async function offerPaymentDependenciesFor(input: {
  db: FirebaseFirestore.Firestore; paymentId: string;
}, deps: RazorpayCollectionRoutingDeps = razorpayCollectionRoutingDefaults) {
  const {db, paymentId} = input;
  const payment = parseOfferPayment((await db
    .collection(OFFER_PAYMENT_COLLECTION).doc(paymentId).get()).data(),
  paymentId);
  return {...await eventPaymentProviderFor({db, routing: payment.routing,
    organizerId: payment.organizerId, currency: payment.currency,
    amountPaise: payment.amountPaise}, deps), paymentId};
}

export async function offerPaymentExecutionFor(input: {
  db: FirebaseFirestore.Firestore; paymentId: string;
}, deps: RazorpayCollectionRoutingDeps = razorpayCollectionRoutingDefaults) {
  return new OfferPaymentProcessor(await offerPaymentDependenciesFor(input,
    deps));
}
