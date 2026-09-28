import {createHash, randomBytes} from "node:crypto";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {isOrganizerManager} from "../shared/organizerHosts";
import type {OrganizerEventOfferRecipientDocument as Grant} from
  "../shared/generated/organizerEventOfferRecipientDocument";
import {validateOrganizerEventOfferRecipientDocument} from
  "../shared/generated/validators/organizerEventOfferRecipientDocument";
import {OfferRecipientScope, readOfferRecipientSource,
  recipientId, recipientUnavailable} from "./sourceAuthority";

const COLLECTION = "organizerEventOfferRecipients";
export interface CurrentRecipientAuth {
  uid: string; phoneNumber?: string | null; disabled?: boolean;
}
export type LoadRecipientAuth = (uid: string) => Promise<CurrentRecipientAuth>;
const loadAuth: LoadRecipientAuth = (uid) => admin.auth().getUser(uid);

/** Token is only returned to the manager once; storage contains its hash. */
export function offerRecipientGrantId(token: string): string {
  if (!/^[A-Za-z0-9_-]{43}$/u.test(token)) recipientUnavailable();
  return createHash("sha256").update(`offer-recipient\u001f${token}`)
    .digest("hex");
}

async function assertAccountAvailable(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, uid: string, requireProfile: boolean) {
  if (!recipientId(uid)) recipientUnavailable();
  const [user, deleted] = await Promise.all([
    tx.get(db.collection("users").doc(uid)),
    tx.get(db.collection("deletedUsers").doc(uid)),
  ]);
  if (deleted.exists || requireProfile && !user.exists ||
      user.data()?.deleted === true || user.data()?.deletedAt != null) {
    recipientUnavailable();
  }
}

/** Preparation only: caller controls the manual handoff; never sends a link. */
export async function issueOfferRecipientInvitation(params: {
  db: FirebaseFirestore.Firestore; actorUid: string;
  scope: OfferRecipientScope; expectedOfferGeneration: number;
  expectedOfferRevision: number; nowMillis?: () => number;
}): Promise<{token: string; grantId: string; expiresAtMillis: number}> {
  const {db, actorUid, scope} = params;
  const token = randomBytes(32).toString("base64url");
  const grantId = offerRecipientGrantId(token);
  return db.runTransaction(async (tx) => {
    await assertAccountAvailable(db, tx, actorUid, true);
    const nowMillis = (params.nowMillis ?? Date.now)();
    const source = await readOfferRecipientSource({db, tx, scope, nowMillis});
    if (!isOrganizerManager(source.organizer, actorUid)) {
      throw new HttpsError("permission-denied", "Organizer access required.");
    }
    if (source.offer.generation !== params.expectedOfferGeneration ||
        source.offer.revision !== params.expectedOfferRevision) {
      recipientUnavailable();
    }
    const grant: Grant = {...scope, originId: source.originId,
      contactId: source.offer.contactId, phoneHash: source.phoneHash,
      offerGeneration: source.offer.generation,
      offerRevision: source.offer.revision, issuedByUid: actorUid,
      issuedAtMillis: nowMillis, expiresAtMillis: source.offer.expiresAtMillis,
      recipientUid: null, claimedAtMillis: null, revokedAtMillis: null};
    if (!validateOrganizerEventOfferRecipientDocument(grant)) {
      recipientUnavailable();
    }
    tx.create(db.collection(COLLECTION).doc(grantId), grant);
    return {token, grantId, expiresAtMillis: grant.expiresAtMillis};
  });
}

/** Reread the immutable source and phone binding in the consuming tx. */
async function readGrant(params: {
  db: FirebaseFirestore.Firestore; tx: FirebaseFirestore.Transaction;
  grantId: string; uid: string; currentAuth: CurrentRecipientAuth;
  nowMillis: number; allowUnclaimed?: boolean;
}) {
  const {db, tx, grantId, uid, currentAuth, nowMillis} = params;
  if (!/^[a-f0-9]{64}$/u.test(grantId) || !recipientId(uid) ||
      currentAuth.uid !== uid || currentAuth.disabled ||
      typeof currentAuth.phoneNumber !== "string") recipientUnavailable();
  const snap = await tx.get(db.collection(COLLECTION).doc(grantId));
  const raw = snap.data();
  if (!validateOrganizerEventOfferRecipientDocument(raw)) {
    recipientUnavailable();
  }
  const grant = raw as Grant;
  if (grant.revokedAtMillis !== null || nowMillis < grant.issuedAtMillis ||
      nowMillis >= grant.expiresAtMillis ||
      grant.recipientUid !== null && grant.recipientUid !== uid ||
      !params.allowUnclaimed && grant.recipientUid !== uid ||
      (grant.recipientUid === null) !== (grant.claimedAtMillis === null) ||
      grant.claimedAtMillis !== null &&
        (grant.claimedAtMillis < grant.issuedAtMillis ||
          grant.claimedAtMillis > nowMillis)) recipientUnavailable();
  await assertAccountAvailable(db, tx, uid, false);
  const source = await readOfferRecipientSource({db, tx, scope: grant,
    nowMillis});
  if (source.offer.generation !== grant.offerGeneration ||
      source.offer.revision !== grant.offerRevision ||
      source.offer.expiresAtMillis !== grant.expiresAtMillis ||
      source.originId !== grant.originId ||
      source.offer.contactId !== grant.contactId ||
      source.phoneHash !== grant.phoneHash ||
      source.phoneE164 !== currentAuth.phoneNumber ||
      source.contact.linkedUid !== null && source.contact.linkedUid !== uid ||
      source.response.respondentUid !== null &&
        source.response.respondentUid !== uid) recipientUnavailable();
  return {grant, source};
}

/** Existing Catch OTP establishes auth.uid and auth.token.phone_number.
 * The caller must pass that authenticated claim, never a payload phone field.
 * Admin Auth is reread on every transaction retry to reject changed/disabled
 * accounts. No form identity or contact-link mutation occurs here.
 */
export async function claimOfferRecipientInvitation(params: {
  db: FirebaseFirestore.Firestore; token: string; uid: string;
  authTokenPhoneNumber: string; nowMillis?: () => number;
  loadCurrentAuthUser?: LoadRecipientAuth;
}): Promise<{grantId: string; expiresAtMillis: number}> {
  const {db, uid, authTokenPhoneNumber} = params;
  const grantId = offerRecipientGrantId(params.token);
  return db.runTransaction(async (tx) => {
    const currentAuth = await (params.loadCurrentAuthUser ?? loadAuth)(uid);
    if (!authTokenPhoneNumber ||
        authTokenPhoneNumber !== currentAuth.phoneNumber) {
      recipientUnavailable();
    }
    const nowMillis = (params.nowMillis ?? Date.now)();
    const {grant} = await readGrant({db, tx, grantId, uid, currentAuth,
      nowMillis, allowUnclaimed: true});
    if (grant.recipientUid === null) {
      tx.update(db.collection(COLLECTION).doc(grantId), {
        recipientUid: uid, claimedAtMillis: nowMillis,
      });
    }
    return {grantId, expiresAtMillis: grant.expiresAtMillis};
  });
}

/** Server-only consumer, also usable by webhook transaction workers. */
export async function readVerifiedOfferRecipient(params: {
  db: FirebaseFirestore.Firestore; tx: FirebaseFirestore.Transaction;
  grantId: string; uid: string; nowMillis: number;
  loadCurrentAuthUser?: LoadRecipientAuth;
}) {
  const currentAuth = await (params.loadCurrentAuthUser ?? loadAuth)(
    params.uid);
  return readGrant({...params, currentAuth});
}
