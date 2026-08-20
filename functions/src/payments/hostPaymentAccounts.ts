import {
  HostPaymentAccountDocument,
} from "../shared/generated/firestoreAdminTypes";

export type HostPaymentProvider = "razorpay" | "stripe";

export function hostPaymentAccountDocumentId(
  uid: string,
  provider: HostPaymentProvider
): string {
  return `${uid}_${provider}`;
}

export async function findHostPaymentAccount(
  db: FirebaseFirestore.Firestore,
  uid: string,
  provider: HostPaymentProvider
): Promise<{
  ref: FirebaseFirestore.DocumentReference;
  snap: FirebaseFirestore.DocumentSnapshot;
  account: HostPaymentAccountDocument | null;
}> {
  const canonicalRef = db.collection("hostPaymentAccounts")
    .doc(hostPaymentAccountDocumentId(uid, provider));
  const canonicalSnap = await canonicalRef.get();
  if (canonicalSnap.exists) {
    return {
      ref: canonicalRef,
      snap: canonicalSnap,
      account: canonicalSnap.data() as HostPaymentAccountDocument,
    };
  }

  if (provider === "stripe") {
    const legacyRef = db.collection("hostPaymentAccounts").doc(uid);
    const legacySnap = await legacyRef.get();
    if (legacySnap.exists) {
      return {
        ref: legacyRef,
        snap: legacySnap,
        account: legacySnap.data() as HostPaymentAccountDocument,
      };
    }
  }

  return {ref: canonicalRef, snap: canonicalSnap, account: null};
}

export function providerAccountId(
  account: HostPaymentAccountDocument
): string {
  if (account.providerAccountId) return account.providerAccountId;
  return account.provider === "razorpay" ?
    account.razorpayAccountId :
    account.stripeAccountId;
}
