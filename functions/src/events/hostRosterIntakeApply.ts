import * as admin from "firebase-admin";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventAttendeeDocument,
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {ImportEventAttendeesCallablePayload} from
  "../shared/generated/importEventAttendeesCallablePayload";
import {
  eventOrganizerRef,
  isEventOrganizerManager,
  requireEventOrganizer,
} from "../shared/eventOrganizers";
import {requireDoc} from "../shared/validation";
import {
  EventAttendeeImportResult,
  importEventAttendeesForHost,
} from "./eventAttendees";
import {
  approveHostRosterIntakeApply,
  HostRosterCurrentRow,
  HostRosterIntakeDraft,
} from "./hostRosterIntakeCore";
import {
  AuthorizeHostRosterSession,
  HostRosterAppliedReview,
  HostRosterIntakeSessionStore,
} from "./hostRosterIntakeSessionStore";

type CommitSource = NonNullable<Parameters<
  typeof importEventAttendeesForHost>[0]["commitSource"]>;
type AuthorizeSource = NonNullable<Parameters<
  typeof importEventAttendeesForHost>[0]["authorizeSource"]>;

export interface HostRosterIntakeApplyStore {
  get(params: {sessionId: string; hostUid: string},
    authorize: AuthorizeHostRosterSession):
    Promise<HostRosterIntakeDraft | null>;
  getAppliedReview(params: {sessionId: string; hostUid: string},
    authorize: AuthorizeHostRosterSession):
    Promise<HostRosterAppliedReview | null>;
  prepareCompletion(params: Parameters<
    HostRosterIntakeSessionStore["prepareCompletion"]>[0]):
    Promise<() => void>;
}

export interface HostRosterIntakeApplyDeps {
  store: HostRosterIntakeApplyStore;
  authorize: AuthorizeHostRosterSession;
  loadInitialCurrentRows(draft: HostRosterIntakeDraft):
    Promise<ReadonlyMap<string, HostRosterCurrentRow>>;
  loadTransactionCurrentRows(tx: Transaction, draft: HostRosterIntakeDraft):
    Promise<ReadonlyMap<string, HostRosterCurrentRow>>;
  importCanonical(params: {
    hostUid: string;
    payload: ImportEventAttendeesCallablePayload;
    authorizeSource: AuthorizeSource;
    commitSource: CommitSource;
  }): Promise<EventAttendeeImportResult>;
}

/** Runs one reviewed approval through the canonical roster transaction. */
export async function applyHostRosterIntake(params: {
  hostUid: string;
  sessionId: string;
  reviewHash: string;
}, deps?: HostRosterIntakeApplyDeps): Promise<EventAttendeeImportResult> {
  const runtime = deps ?? defaultApplyDeps();
  const draft = await runtime.store.get({sessionId: params.sessionId,
    hostUid: params.hostUid}, runtime.authorize);
  if (!draft) throw new HttpsError("not-found", "Roster intake not found.");

  let payload: ImportEventAttendeesCallablePayload;
  let expectedReviewHash: string;
  if (draft.state === "applied") {
    const applied = await runtime.store.getAppliedReview({
      sessionId: params.sessionId, hostUid: params.hostUid,
    }, runtime.authorize);
    if (!applied || applied.preview.reviewHash !== params.reviewHash) {
      throw new HttpsError("failed-precondition",
        "Roster intake approval does not match its receipt.");
    }
    payload = applied.payload;
    expectedReviewHash = applied.preview.reviewHash;
  } else {
    const currentRows = await runtime.loadInitialCurrentRows(draft);
    const approved = approveHostRosterIntakeApply({draft, currentRows,
      reviewHash: params.reviewHash});
    payload = approved.payload;
    expectedReviewHash = approved.reviewHash;
  }

  const completion = async (tx: Transaction, importId: string,
    committedPayload: ImportEventAttendeesCallablePayload,
    replayed: boolean) => {
    const commit = await runtime.store.prepareCompletion({tx,
      sessionId: draft.sessionId, hostUid: params.hostUid,
      expectedDraft: draft, expectedReviewHash, committedPayload,
      importId, replayed, authorize: runtime.authorize,
      loadCurrentRows: runtime.loadTransactionCurrentRows});
    commit();
  };
  return runtime.importCanonical({hostUid: params.hostUid, payload,
    authorizeSource: async (tx, replayed, importId) => {
      if (replayed) await completion(tx, importId, payload, true);
    },
    commitSource: async (tx, importId, canonicalPayload) => {
      await completion(tx, importId, canonicalPayload, false);
    }});
}

function defaultApplyDeps(): HostRosterIntakeApplyDeps {
  const db = admin.firestore();
  const authorize = managerAuthorizer(db);
  const store = new HostRosterIntakeSessionStore(db);
  const load = (tx: Transaction, draft: HostRosterIntakeDraft) =>
    loadCurrentRows(db, tx, draft);
  return {store, authorize,
    loadInitialCurrentRows: (draft) => db.runTransaction(async (tx) => {
      await authorize({tx, hostUid: draft.hostUid,
        organizerId: draft.organizerId, eventId: draft.eventId});
      return load(tx, draft);
    }),
    loadTransactionCurrentRows: load,
    importCanonical: (input) => importEventAttendeesForHost(input)};
}

function managerAuthorizer(db: Firestore): AuthorizeHostRosterSession {
  return async ({tx, hostUid, organizerId, eventId}) => {
    const eventSnap = await tx.get(db.collection("events").doc(eventId));
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
    if ((event.organizerId ?? event.clubId) !== organizerId ||
        event.status === "cancelled") {
      throw new HttpsError("failed-precondition",
        "Roster intake event scope is no longer current.");
    }
    const organizerSnap = await tx.get(eventOrganizerRef(db, event));
    const organizer = requireEventOrganizer(organizerSnap, event);
    if (!isEventOrganizerManager(organizer, event, hostUid)) {
      throw new HttpsError("permission-denied",
        "Only an organizer manager can review this roster intake.");
    }
  };
}

async function loadCurrentRows(db: Firestore, tx: Transaction,
  draft: HostRosterIntakeDraft):
  Promise<ReadonlyMap<string, HostRosterCurrentRow>> {
  const snap = await tx.get(db.collection("eventAttendees")
    .where("eventId", "==", draft.eventId).limit(1001));
  if (snap.size > 1000) {
    throw new HttpsError("resource-exhausted",
      "Roster is too large for one reviewed intake operation.");
  }
  return new Map(snap.docs.map((doc) => {
    const row = requireDoc<EventAttendeeDocument>(doc,
      "EventAttendeeDocument");
    return [doc.id, currentRow(doc.id, row)];
  }));
}

export function currentRow(attendeeId: string,
  row: EventAttendeeDocument): HostRosterCurrentRow {
  return {eventId: row.eventId, attendeeId, source: row.source,
    displayName: row.displayName, status: row.status,
    linkedUid: row.linkedUid, phoneE164: row.phoneE164,
    email: row.email, cityMarketId: row.cityMarketId ?? null,
    externalReference: row.externalReference,
    arrivalGroup: row.arrivalGroup, ticketType: row.ticketType,
    revenueAmountMinor: row.revenueAmountMinor ?? null,
    revenueCurrency: row.revenueCurrency ?? null,
    revenueSource: row.revenueSource ?? null,
    updatedAtMillis: row.updatedAt.toMillis()};
}
