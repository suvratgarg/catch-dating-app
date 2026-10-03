import {createHash} from "node:crypto";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {ProgramAccess} from "../shared/programAuthority";
import type {ProgramGuestDocument, ProgramGuestGroupDocument,
  ProgramHotelDocument, ProgramRoomBlockDocument, ProgramStayDocument}
  from "../shared/generated/firestoreAdminTypes";
import {validateProgramLodgingSourceVersionDocument} from
  "../shared/generated/validators/programLodgingSourceVersionDocument";
import type {ProgramLodgingSourceVersionDocument} from
  "../shared/generated/programLodgingSourceVersionDocument";
import type {LodgingRevisions, LodgingSnapshot} from "./programLodgingTypes";

type ScopedRow<T> = {id: string; data: T};
export interface CanonicalLodgingRecords {
  guests: ScopedRow<ProgramGuestDocument>[];
  groups: ScopedRow<ProgramGuestGroupDocument>[];
  hotels: ScopedRow<ProgramHotelDocument>[];
  blocks: ScopedRow<ProgramRoomBlockDocument>[];
  stays: ScopedRow<ProgramStayDocument>[];
}

/** Complete bounded native source, never an inbound-travel roster. Every read
 * uses the caller's existing authoritative transaction. A cap is an error,
 * not a silently partial snapshot that could invent spare capacity. */
export async function readCanonicalLodgingRecords(
  tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
  access: ProgramAccess, programId: string,
): Promise<CanonicalLodgingRecords> {
  if (access.role === "staff" && access.grant?.programId !== programId) {
    throw new HttpsError("permission-denied", "Foreign program source.");
  }
  const organizerId = access.program.organizerId;
  const read = async <T>(collection: string, cap: number) => {
    const snap = await tx.get(db.collection(collection)
      .where("programId", "==", programId)
      .where("organizerId", "==", organizerId).limit(cap + 1));
    if (snap.size > cap) {
      throw new HttpsError("resource-exhausted",
        "Lodging source exceeds its complete-read limit.");
    }
    return snap.docs.map((doc) => ({id: doc.id, data: doc.data() as T}))
      .sort((a, b) => a.id < b.id ? -1 : a.id > b.id ? 1 : 0);
  };
  const [guests, groups, hotels, blocks, stays] = await Promise.all([
    read<ProgramGuestDocument>("programGuests", 500),
    read<ProgramGuestGroupDocument>("programGuestGroups", 500),
    read<ProgramHotelDocument>("programHotels", 500),
    read<ProgramRoomBlockDocument>("programRoomBlocks", 500),
    read<ProgramStayDocument>("programStays", 2000),
  ]);
  return {guests, groups, hotels, blocks, stays};
}

const domains = ["source", "inventory", "layout", "published"] as const;
export type LodgingRevisionEvidence = Record<typeof domains[number], unknown>;

/** Fingerprints are internal evidence identities, not truncated numeric
 * hashes. Counters advance transactionally when a domain's content changes.
 * Callers project source fields deliberately; array order remains meaningful,
 * while native rows are sorted by stable document ID before hashing. */
export function lodgingEvidenceFingerprint(value: unknown): string {
  const normalize = (entry: unknown): unknown => {
    if (entry === null) return ["null"];
    if (typeof entry === "string" || typeof entry === "boolean") {
      return [typeof entry, entry];
    }
    if (typeof entry === "number" && Number.isFinite(entry)) {
      return ["number", entry];
    }
    if (Array.isArray(entry)) return ["array", entry.map(normalize)];
    if (entry instanceof Timestamp) {
      return ["timestamp", entry.seconds, entry.nanoseconds];
    }
    if (entry && typeof entry === "object" &&
        [null, Object.prototype].includes(Object.getPrototypeOf(entry))) {
      return ["map", Object.entries(entry)
        .sort(([a], [b]) => a < b ? -1 : a > b ? 1 : 0)
        .map(([key, child]) => [key, normalize(child)])];
    }
    throw new HttpsError("failed-precondition",
      "Unsupported lodging source evidence value.");
  };
  return createHash("sha256").update(JSON.stringify(normalize(value)))
    .digest("hex");
}

/** Prepare all reads first. persist() and publish() only enqueue writes in
 * this SAME transaction, after the Store has read proposal/receipt/workflow.
 * A preview persists its fence before searching outside the transaction;
 * later native edits therefore cannot reuse its source revision. */
export async function prepareLodgingRevisionFence(
  tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
  scope: LodgingSnapshot["scope"], evidence: LodgingRevisionEvidence,
) {
  const ref = db.collection("programLodgingSourceVersions")
    .doc(scope.programId);
  const snap = await tx.get(ref);
  const existing = snap.data() as ProgramLodgingSourceVersionDocument |
    undefined;
  if (existing && (!validateProgramLodgingSourceVersionDocument(existing) ||
      existing.programId !== scope.programId ||
      existing.organizerId !== scope.organizerId)) {
    throw new HttpsError("failed-precondition",
      "Invalid lodging source fence.");
  }
  const document: ProgramLodgingSourceVersionDocument = {...scope,
    versions: {} as ProgramLodgingSourceVersionDocument["versions"]};
  const revisions = {} as LodgingRevisions;
  for (const domain of domains) {
    const fingerprint = lodgingEvidenceFingerprint(evidence[domain]);
    const prior = existing?.versions[domain];
    const revision = prior?.fingerprint === fingerprint ? prior.revision :
      (prior?.revision ?? 0) + 1;
    if (!Number.isSafeInteger(revision)) {
      throw new HttpsError("failed-precondition",
        "Source revision exhausted.");
    }
    document.versions[domain] = {revision, fingerprint};
    revisions[domain] = revision;
  }
  return {
    revisions,
    persist: () => tx.set(ref, document),
    publish: (publishedEvidence: unknown) => {
      const fingerprint = lodgingEvidenceFingerprint(publishedEvidence);
      const revision = revisions.published + 1;
      if (!Number.isSafeInteger(revision)) {
        throw new HttpsError("failed-precondition",
          "Source revision exhausted.");
      }
      // Publication is an operation even when the placements were unchanged.
      tx.set(ref, {...document, versions: {...document.versions,
        published: {revision, fingerprint}}});
    },
  };
}
