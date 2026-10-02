import {createHash} from "node:crypto";
import {FieldPath, Timestamp} from "firebase-admin/firestore";
import type {OrganizerFormResponseDocument as Response,
  OrganizerFormVersionDocument as Version} from
  "../shared/generated/firestoreAdminTypes";
import {validateOrganizerFormResponseDocument} from
  "../shared/generated/validators/organizerFormResponseDocument";
import {validateOrganizerFormVersionDocument} from
  "../shared/generated/validators/organizerFormVersionDocument";

/** Distinguishes malformed caller paging input from infrastructure errors. */
export class ParticipantActivityInputError extends RangeError {}

/** Internal source proof, not a callable DTO or an editable activity record. */
export interface ParticipantFormActivitySource {
  responseId: string;
  organizerId: string;
  formId: string;
  versionId: string;
  formTitle: string;
  purpose: Version["definition"]["purpose"];
  /** Configured form target only; not proof of event admission. */
  eventId: string | null;
  submittedAtMillis: number;
}

/**
 * Own submission metadata is independent of profile claims and Host grants.
 * This internal reader requires the future callable's Auth-derived uid.
 * A caller may share its existing transaction.
 */
export async function readParticipantFormActivitySource(params: {
  db: FirebaseFirestore.Firestore;
  tx?: FirebaseFirestore.Transaction;
  uid: string;
  responseId: string;
  nowMillis?: number;
}): Promise<ParticipantFormActivitySource | null> {
  const {db, uid, responseId} = params;
  const nowMillis = params.nowMillis ?? Date.now();
  if (!documentId(uid) || !documentId(responseId) ||
      !Number.isFinite(nowMillis) || nowMillis < 0) return null;
  const read = async (tx: FirebaseFirestore.Transaction) => {
    const [responseSnap, available] = await Promise.all([
      tx.get(db.collection("organizerFormResponses").doc(responseId)),
      accountAvailable(db, tx, uid),
    ]);
    return available ? readSnapshot({db, tx, uid, responseId,
      nowMillis, value: responseSnap.data()}) : null;
  };
  return params.tx ? read(params.tx) : db.runTransaction(read);
}

/** Bounded internal page; deleted subjects are unavailable. */
export async function readParticipantFormActivityPageSource(params: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  limit: number;
  cursor: string | null;
  nowMillis?: number;
}): Promise<{sources: ParticipantFormActivitySource[];
  nextCursor: string | null} | null> {
  const {db, uid, limit} = params;
  const nowMillis = params.nowMillis ?? Date.now();
  if (!documentId(uid) || !Number.isInteger(limit) || limit < 1 || limit > 30 ||
      !Number.isFinite(nowMillis) || nowMillis < 0) {
    throw new ParticipantActivityInputError("Invalid form activity page.");
  }
  const after = decodeCursor(params.cursor, uid);
  return db.runTransaction(async (tx) => {
    if (!await accountAvailable(db, tx, uid)) return null;
    let query = db.collection("organizerFormResponses")
      .where("respondentUid", "==", uid).orderBy(FieldPath.documentId())
      .limit(limit + 1);
    if (after) query = query.startAfter(after);
    const snapshot = await tx.get(query);
    const page = snapshot.docs.slice(0, limit);
    const versions = new Map<string, Promise<unknown>>();
    const sources = await Promise.all(page.map((row) => readSnapshot({
      db, tx, uid, responseId: row.id, value: row.data(), nowMillis, versions,
    })));
    return {sources: sources.filter((source) => source !== null),
      nextCursor: snapshot.docs.length > limit ?
        encodeCursor(page.at(-1)!.id, uid) : null};
  });
}

async function accountAvailable(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, uid: string): Promise<boolean> {
  const [deleted, user] = await Promise.all([
    tx.get(db.collection("deletedUsers").doc(uid)),
    tx.get(db.collection("users").doc(uid)),
  ]);
  return !deleted.exists && user.data()?.deleted !== true;
}

async function readSnapshot(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  uid: string;
  responseId: string;
  value: unknown;
  nowMillis: number;
  versions?: Map<string, Promise<unknown>>;
}): Promise<ParticipantFormActivitySource | null> {
  const {db, tx, uid, responseId, nowMillis, versions} = params;
  const response = params.value as Response | undefined;
  if (!documentId(responseId) ||
      !validateOrganizerFormResponseDocument(response) || !response ||
      !documentId(response.organizerId) || !documentId(response.formId) ||
      !documentId(response.versionId) || response.respondentUid !== uid ||
      response.status !== "submitted" || response.withdrawnAt !== null ||
      response.identityKind === "anonymous") return null;
  let pending = versions?.get(response.versionId);
  if (!pending) {
    pending = tx.get(db.collection("organizerFormVersions")
      .doc(response.versionId)).then((snapshot) => snapshot.data());
    versions?.set(response.versionId, pending);
  }
  const version = await pending as Version | undefined;
  if (!validateOrganizerFormVersionDocument(version) || !version ||
      version.organizerId !== response.organizerId ||
      version.formId !== response.formId ||
      version.definition.consent.consentVersion !== response.consentVersion ||
      (version.definition.defaultTargetKind === "event" &&
        !documentId(version.definition.defaultTargetId ?? "")) ||
      !accountIdentityMatches(version.definition.identityPolicy,
        response.identityKind)) return null;
  const submittedAtMillis = timestampMillis(response.submittedAt);
  const publishedAtMillis = timestampMillis(version.publishedAt);
  if (submittedAtMillis === null || publishedAtMillis === null ||
      submittedAtMillis < publishedAtMillis || submittedAtMillis > nowMillis ||
      publishedAtMillis > nowMillis) return null;
  // No answers, endpoint snapshots, tokens, review notes or profile pointers.
  // The immutable version describes this submission, not today's live form.
  return {responseId, organizerId: response.organizerId,
    formId: response.formId, versionId: response.versionId,
    formTitle: version.definition.title, purpose: version.definition.purpose,
    eventId: version.definition.defaultTargetKind === "event" ?
      version.definition.defaultTargetId : null,
    submittedAtMillis};
}

function cursorScope(uid: string): string {
  return createHash("sha256").update(`formResponse:${uid}`).digest("hex");
}
function encodeCursor(after: string, uid: string): string {
  const payload = {version: 1, scope: cursorScope(uid), after};
  return Buffer.from(JSON.stringify(payload)).toString("base64url");
}
function decodeCursor(value: string | null, uid: string): string | null {
  if (value === null) return null;
  try {
    if (typeof value !== "string" || value.length > 8192 ||
        !/^[A-Za-z0-9_-]+$/u.test(value)) throw new Error();
    const bytes = Buffer.from(value, "base64url");
    if (bytes.toString("base64url") !== value) throw new Error();
    const decoded = JSON.parse(bytes.toString("utf8"));
    if (!decoded || Array.isArray(decoded) ||
        Object.keys(decoded).sort().join(",") !== "after,scope,version" ||
        decoded.version !== 1 || decoded.scope !== cursorScope(uid) ||
        typeof decoded.after !== "string" || decoded.after.length === 0 ||
        Buffer.byteLength(decoded.after, "utf8") > 1500 ||
        decoded.after === "." || decoded.after === ".." ||
        decoded.after.includes("/")) throw new Error();
    return decoded.after;
  } catch {
    throw new ParticipantActivityInputError("Invalid form activity cursor.");
  }
}

function accountIdentityMatches(policy: Version["definition"]["identityPolicy"],
  kind: Response["identityKind"]): boolean {
  if (policy === "anonymous" || kind === "anonymous") return false;
  if (policy === "phoneVerified") return kind === "phoneVerified";
  if (policy === "emailVerified" || policy === "emailOrPhoneVerified") {
    // The actual writer chooses phone first for a dual-verified account.
    return kind === "phoneVerified" || kind === "emailVerified";
  }
  return policy === "catchAccount";
}

function documentId(value: string): boolean {
  return typeof value === "string" && value.length > 0 && value.length <= 180 &&
    value !== "." && value !== ".." && !value.includes("/") &&
    [...value].every((character) => character.charCodeAt(0) >= 32);
}

function timestampMillis(value: unknown): number | null {
  if (!(value instanceof Timestamp)) return null;
  const millis = value.toMillis();
  return Number.isFinite(millis) && millis >= 0 ? millis : null;
}
