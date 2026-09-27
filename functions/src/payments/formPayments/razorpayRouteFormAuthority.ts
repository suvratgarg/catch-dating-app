import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerDocument, HostPaymentAccountDocument as Account,
  OrganizerFormPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import {organizerOwnerUserId} from "../../shared/organizerHosts";
import {requireDoc} from "../../shared/validation";
import {validateHostPaymentAccountDocument} from
  "../../shared/generated/validators/hostPaymentAccountDocument";
import {hostPaymentAccountDocumentId} from "../hostPaymentAccounts";
import {assertPaymentRouteSnapshot, paymentRoutingSnapshotsMatch,
  type PaymentRoutingSnapshot} from
  "../paymentRouting";
import type {RazorpayPlatformPaymentConfig} from
  "../razorpayPlatformPaymentConfig";
import type {FormPaymentAuthority, FormPaymentMerchant} from
  "./formPaymentProcessor";

/** Reads server records; provider readiness is checked before reservation. */
export async function readReadyRouteAccount(params: {
  db: FirebaseFirestore.Firestore; tx?: FirebaseFirestore.Transaction;
  organizerId: string; expectedBindingId?: string;
}): Promise<{bindingId: string; account: Account}> {
  const {db, tx, organizerId} = params;
  const organizerRef = db.collection("organizers").doc(organizerId);
  const organizerSnap = tx ? await tx.get(organizerRef) :
    await organizerRef.get();
  const owner = organizerOwnerUserId(requireDoc<OrganizerDocument>(
    organizerSnap,
    "OrganizerDocument"));
  if (!owner) unavailable();
  const bindingId = hostPaymentAccountDocumentId(owner, "razorpay");
  if (params.expectedBindingId && params.expectedBindingId !== bindingId) {
    unavailable();
  }
  const accountRef = db.collection("hostPaymentAccounts").doc(bindingId);
  const accountSnap = tx ? await tx.get(accountRef) : await accountRef.get();
  const account = accountSnap.exists ? requireDoc<Account>(accountSnap,
    "HostPaymentAccountDocument") : null;
  if (!account || !validateHostPaymentAccountDocument(account) ||
      account.userId !== owner || account.provider !== "razorpay" ||
      account.country !== "IN" ||
      account.defaultCurrency.toUpperCase() !== "INR" ||
      !account.chargesEnabled || !account.payoutsEnabled ||
      !account.detailsSubmitted || account.onboardingStatus !== "complete" ||
      !account.providerAccountId || !account.razorpayProductId ||
      account.providerAccountId !== account.razorpayAccountId ||
      account.disabledReason || account.requirementsCurrentlyDue.length > 0 ||
      account.requirementsPastDue.length > 0) unavailable();
  return {bindingId, account};
}

/** One authority is constructed with one payment's immutable platform profile.
 * Existing captures/refunds continue on that profile even after owner/default
 * changes. Only a new order requires the current organizer binding to be ready.
 */
export class RazorpayRouteFormAuthority implements FormPaymentAuthority {
  constructor(private readonly db: FirebaseFirestore.Firestore,
    private readonly snapshot: PaymentRoutingSnapshot,
    private readonly config: RazorpayPlatformPaymentConfig) {
    assertPaymentRouteSnapshot(snapshot, {organizerId: snapshot.organizerId,
      purpose: "formFee", currency: "INR"});
    if (snapshot.selection.route !== "razorpayRoute" ||
        snapshot.selection.mode !== config.mode ||
        snapshot.merchantAccountId !== config.platformAccountId ||
        snapshot.checkoutKey !== config.keyId || snapshot.settlementHold) {
      unavailable();
    }
  }

  async resolve(payment: Payment): Promise<FormPaymentMerchant> {
    this.assertBound(payment);
    return {accountId: this.config.platformAccountId, mode: this.config.mode,
      authorizationHandle: this.config.keyId, checkoutKey: this.config.keyId,
      expiresAtMillis: Number.MAX_SAFE_INTEGER};
  }

  async assertReady(tx: FirebaseFirestore.Transaction, payment: Payment,
    merchant: FormPaymentMerchant): Promise<void> {
    this.assertBound(payment);
    const {account} = await readReadyRouteAccount({db: this.db, tx,
      organizerId: payment.organizerId,
      expectedBindingId: this.snapshot.bindingId});
    if (account.providerAccountId !== this.snapshot.destinationAccountId ||
        merchant.accountId !== this.config.platformAccountId ||
        merchant.checkoutKey !== this.config.keyId ||
        merchant.mode !== this.config.mode) unavailable();
  }

  private assertBound(payment: Payment): void {
    if (!payment.routing) unavailable();
    assertPaymentRouteSnapshot(payment.routing, {
      organizerId: payment.organizerId,
      purpose: "formFee", currency: payment.currency,
      amountMinor: payment.amountPaise});
    if (!paymentRoutingSnapshotsMatch(payment.routing, this.snapshot)) {
      unavailable();
    }
    if (payment.connectionId !== null ||
        payment.accountId !== this.config.platformAccountId ||
        payment.mode !== this.config.mode) unavailable();
  }
}

function unavailable(): never {
  throw new HttpsError("failed-precondition",
    "The organizer's Catch collection account is not ready for this payment.");
}
