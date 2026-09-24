import {createHash} from "node:crypto";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventDocument, OrganizerApplicationDocument,
  OrganizerContactDocument, OrganizerContactOriginDocument,
  OrganizerFormResponseDocument, OrganizerFormVersionDocument,
  OrganizerFormConversionReceiptDocument,
} from "../shared/generated/firestoreAdminTypes";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";
import {organizerApplicationAccess, genericFormApplicationId} from
  "../organizers/organizerApplicationAccess";
import {formConversionReceiptId} from
  "../organizers/organizerFormAdmissionIdentity";
import {EventOffer, OfferActionReceipt, OfferDomainError, eventOfferId} from
  "./eventOfferDomain";
import {
  OfferApplication, OfferAuditEntry, OfferBatchReceipt, OfferContact,
  OfferEvent, OfferOrigin, OfferRepository, OfferSourceState,
  OfferTransaction,
} from "./eventOfferService";

/**
 * Server-only storage adapter, intentionally not registered as a callable.
 * New collection contracts, rules/indexes, rate limits and API schemas must
 * be reviewed with the shared-contract owner before endpoint registration.
 * The new collections remain client-denied by the Firestore default rule.
 */
const collections = {
  offers: "organizerEventOffers",
  actions: "organizerEventOfferActionReceipts",
  batches: "organizerEventOfferBatchReceipts",
  audit: "organizerEventOfferAudits",
} as const;

function key(...parts: string[]): string {
  return createHash("sha256").update(parts.join("\u001f"))
    .digest("hex");
}

function object(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" &&
    !Array.isArray(value);
}

export function parseStoredEventOffer(value: unknown, id: string): EventOffer {
  if (!object(value) || value.offerId !== id ||
      typeof value.organizerId !== "string" ||
      typeof value.eventId !== "string" ||
      typeof value.contactId !== "string" ||
      typeof value.applicationId !== "string" ||
      !["application", "formResponse"].includes(
        String(value.sourceKind ?? "application")) ||
      !["draft", "offered", "withdrawn", "expired"].includes(
        String(value.status)) ||
      !Number.isSafeInteger(value.generation) ||
      Number(value.generation) < 1 ||
      !Number.isSafeInteger(value.revision) ||
      Number(value.revision) < 1 ||
      !Number.isSafeInteger(value.expiresAtMillis) ||
      !Number.isSafeInteger(value.createdAtMillis) ||
      !Number.isSafeInteger(value.updatedAtMillis) ||
      !(value.offeredAtMillis === null ||
        Number.isSafeInteger(value.offeredAtMillis)) ||
      !(value.organizerPaymentLink === null ||
        typeof value.organizerPaymentLink === "string") ||
      !object(value.manualPayment) ||
      !["none", "evidenceSubmitted", "hostAttestedReceived",
        "rejected"].includes(String(value.manualPayment.status)) ||
      !(value.manualPayment.evidenceReference === null ||
        typeof value.manualPayment.evidenceReference === "string") ||
      !(value.manualPayment.evidenceRecordedAtMillis === null ||
        Number.isSafeInteger(value.manualPayment.evidenceRecordedAtMillis)) ||
      !(value.manualPayment.reviewedByUid === null ||
        typeof value.manualPayment.reviewedByUid === "string") ||
      !(value.manualPayment.reviewedAtMillis === null ||
        Number.isSafeInteger(value.manualPayment.reviewedAtMillis)) ||
      !(value.manualPayment.reviewNote === null ||
        typeof value.manualPayment.reviewNote === "string") ||
      typeof value.manualPayment.bankReceiptChecked !== "boolean" ||
      (value.status === "offered" && value.offeredAtMillis === null) ||
      (value.status === "draft" && value.offeredAtMillis !== null) ||
      (value.manualPayment.status === "none" &&
        (value.manualPayment.evidenceReference !== null ||
          value.manualPayment.evidenceRecordedAtMillis !== null ||
          value.manualPayment.reviewedByUid !== null ||
          value.manualPayment.reviewedAtMillis !== null)) ||
      (value.manualPayment.status !== "none" &&
        (value.offeredAtMillis === null ||
          value.manualPayment.evidenceReference === null ||
          value.manualPayment.evidenceRecordedAtMillis === null)) ||
      (value.manualPayment.status === "hostAttestedReceived" &&
        value.manualPayment.bankReceiptChecked !== true) ||
      (["hostAttestedReceived", "rejected"].includes(
        String(value.manualPayment.status)) &&
        (value.manualPayment.reviewedByUid === null ||
          value.manualPayment.reviewedAtMillis === null ||
          typeof value.manualPayment.reviewNote !== "string" ||
          value.manualPayment.reviewNote.trim().length < 3))) {
    throw new OfferDomainError("conflict", "Stored offer is malformed.");
  }
  try {
    if (eventOfferId({organizerId: value.organizerId as string,
      eventId: value.eventId as string,
      contactId: value.contactId as string}) !== id) {
      throw new Error("identity mismatch");
    }
  } catch {
    throw new OfferDomainError("conflict", "Stored offer identity changed.");
  }
  return value as unknown as EventOffer;
}

function storedActionReceipt(value: unknown, offerId: string,
  requestId: string): OfferActionReceipt {
  if (!object(value) || value.offerId !== offerId ||
      value.requestId !== requestId ||
      typeof value.requestHash !== "string" ||
      !Number.isSafeInteger(value.resultingGeneration) ||
      !Number.isSafeInteger(value.resultingRevision)) {
    throw new OfferDomainError("conflict",
      "Stored action receipt is malformed.");
  }
  return value as unknown as OfferActionReceipt;
}

function storedBatchReceipt(value: unknown, organizerId: string,
  requestId: string): OfferBatchReceipt {
  if (!object(value) || value.organizerId !== organizerId ||
      value.requestId !== requestId ||
      typeof value.eventId !== "string" ||
      typeof value.requestHash !== "string" ||
      !Array.isArray(value.results) ||
      !value.results.every((row) => object(row) &&
        typeof row.offerId === "string" &&
        Number.isSafeInteger(row.revision) &&
        Number.isSafeInteger(row.generation))) {
    throw new OfferDomainError("conflict",
      "Stored batch receipt is malformed.");
  }
  return value as unknown as OfferBatchReceipt;
}

export class FirestoreEventOfferRepository implements OfferRepository {
  constructor(private readonly db: FirebaseFirestore.Firestore,
    private readonly serverClock: () => number = Date.now) {}

  transaction<T>(callback: (tx: OfferTransaction) => Promise<T>): Promise<T> {
    return this.db.runTransaction(async (firestoreTx) => {
      const applications = new Map<string, OrganizerApplicationDocument>();
      const formResponses = new Map<string, OrganizerFormResponseDocument>();
      const pendingOffers = new Map<string, EventOffer>();
      const actionReceipts: OfferActionReceipt[] = [];
      const batchReceipts: OfferBatchReceipt[] = [];
      const audits: OfferAuditEntry[] = [];
      const read = async (collection: string, id: string) =>
        (await firestoreTx.get(this.db.collection(collection).doc(id)))
          .data();
      const tx: OfferTransaction = {
        nowMillis: () => this.serverClock(),
        managerAuthorized: async (organizerId, actorUid) => {
          try {
            await requireOrganizerManager({db: this.db, organizerId,
              actorUid, transaction: firestoreTx});
            return true;
          } catch (error) {
            if (error instanceof HttpsError &&
                ["permission-denied", "not-found"].includes(error.code)) {
              return false;
            }
            throw error;
          }
        },
        application: async (applicationId, sourceKind):
          Promise<OfferApplication | null> => {
          if (sourceKind === "formResponse") {
            const response = await read("organizerFormResponses",
              applicationId) as OrganizerFormResponseDocument | undefined;
            if (!response) return null;
            const version = await read("organizerFormVersions",
              response.versionId) as OrganizerFormVersionDocument | undefined;
            const conversion = await read("organizerFormConversionReceipts",
              formConversionReceiptId(applicationId, "crmContact")) as
              OrganizerFormConversionReceiptDocument | undefined;
            if (!version || response.status !== "submitted" ||
                !["registration", "intake"].includes(
                  version.definition.purpose) ||
                version.organizerId !== response.organizerId ||
                version.formId !== response.formId ||
                !conversion || conversion.status !== "completed" ||
                conversion.kind !== "crmContact" ||
                conversion.organizerId !== response.organizerId ||
                conversion.formId !== response.formId ||
                conversion.responseId !== applicationId ||
                !conversion.resultId ||
                !["organizer", "event", "campaign"].includes(
                  version.definition.defaultTargetKind)) {
              return null;
            }
            formResponses.set(applicationId, response);
            return {sourceKind, organizerId: response.organizerId,
              applicationId, contactId: null,
              latestResponseId: applicationId,
              conversionContactId: conversion.resultId,
              conversionStatus: conversion.status,
              reviewStatus: response.status,
              revision: version.version,
              targetKind: version.definition.defaultTargetKind,
              targetId: version.definition.defaultTargetId};
          }
          const data = await read("organizerApplications", applicationId) as
            OrganizerApplicationDocument | undefined;
          if (!data) return null;
          if (typeof data.organizerId !== "string" ||
              typeof data.latestResponseId !== "string" ||
              !Number.isSafeInteger(data.revision) ||
              !["organizer", "event", "campaign"].includes(
                data.targetKind)) {
            throw new OfferDomainError("conflict",
              "Stored application is malformed.");
          }
          applications.set(applicationId, data);
          return {sourceKind, organizerId: data.organizerId, applicationId,
            contactId: data.contactId, latestResponseId: data.latestResponseId,
            reviewStatus: data.reviewStatus, revision: data.revision,
            targetKind: data.targetKind, targetId: data.targetId};
        },
        sourceState: async (applicationId): Promise<OfferSourceState> => {
          if (formResponses.has(applicationId)) {
            return "submittedFormResponse";
          }
          const application = applications.get(applicationId);
          if (!application) {
            throw new OfferDomainError("conflict",
              "Application must be read before its source.");
          }
          const access = await organizerApplicationAccess({db: this.db,
            applicationId, application, transaction: firestoreTx});
          return access.accessState;
        },
        contact: async (contactId): Promise<OfferContact | null> => {
          const data = await read("organizerContacts", contactId) as
            OrganizerContactDocument | undefined;
          if (!data) return null;
          if (typeof data.organizerId !== "string" ||
              !Number.isSafeInteger(data.revision)) {
            throw new OfferDomainError("conflict",
              "Stored CRM contact is malformed.");
          }
          return {organizerId: data.organizerId, contactId,
            deleted: data.deletedAt !== null,
            hidden: data.hiddenAt != null,
            mergedIntoContactId: data.mergedIntoContactId,
            revision: data.revision};
        },
        origin: async (applicationId, responseId):
          Promise<OfferOrigin | null> => {
          const application = applications.get(applicationId);
          const form = formResponses.get(applicationId);
          if (!application && !form ||
              application && application.latestResponseId !== responseId ||
              form && applicationId !== responseId) {
            return null;
          }
          const generic = !!form || application!.source.kind === "native" &&
            applicationId === genericFormApplicationId(responseId);
          const id = organizerContactOriginId({
            organizerId: form?.organizerId ?? application!.organizerId,
            sourceKind: "hostForm",
            sourceEntityKind: generic ? "hostFormResponse" :
              "hostApplicationResponse", sourceEntityId: responseId,
          });
          const data = await read("organizerContactOrigins", id) as
            OrganizerContactOriginDocument | undefined;
          if (!data) return null;
          if (typeof data.currentContactId !== "string" ||
              data.sourceEntityId !== responseId) {
            throw new OfferDomainError("conflict",
              "Stored CRM origin is malformed.");
          }
          return {organizerId: data.organizerId,
            sourceResponseId: data.sourceEntityId,
            currentContactId: data.currentContactId,
            originContactId: data.originContactId};
        },
        event: async (eventId): Promise<OfferEvent | null> => {
          const data = await read("events", eventId) as
            EventDocument | undefined;
          if (!data) return null;
          if (!data.startTime || !data.updatedAt ||
              typeof data.clubId !== "string" ||
              !["active", "cancelled"].includes(data.status)) {
            throw new OfferDomainError("conflict",
              "Stored event is malformed.");
          }
          return {organizerId: data.organizerId ?? data.clubId,
            eventId, startsAtMillis: data.startTime.toMillis(),
            cancelled: data.status === "cancelled",
            updatedAtMillis: data.updatedAt.toMillis()};
        },
        offer: async (offerId) => {
          const data = await read(collections.offers, offerId);
          return data ? parseStoredEventOffer(data, offerId) : null;
        },
        actionReceipt: async (offerId, requestId) => {
          const data = await read(collections.actions,
            key(offerId, requestId));
          return data ? storedActionReceipt(data, offerId, requestId) : null;
        },
        batchReceipt: async (organizerId, requestId) => {
          const data = await read(collections.batches,
            key(organizerId, requestId));
          return data ? storedBatchReceipt(data, organizerId,
            requestId) : null;
        },
        listOffers: async (organizerId, eventId, afterOfferId, limit) => {
          let query = this.db.collection(collections.offers)
            .where("organizerId", "==", organizerId)
            .where("eventId", "==", eventId)
            .orderBy(admin.firestore.FieldPath.documentId())
            .limit(limit);
          if (afterOfferId) query = query.startAfter(afterOfferId);
          const snapshot = await firestoreTx.get(query);
          return snapshot.docs.map((doc) =>
            parseStoredEventOffer(doc.data(), doc.id));
        },
        hasMergedContactOffer: async (organizerId, eventId,
          canonicalContactId) => {
          const query = this.db.collection("organizerContactOrigins")
            .where("organizerId", "==", organizerId)
            .where("currentContactId", "==", canonicalContactId)
            .limit(51);
          const origins = await firestoreTx.get(query);
          if (origins.size > 50) {
            throw new OfferDomainError("conflict",
              "Too many CRM origins; reconcile before offering.");
          }
          for (const doc of origins.docs) {
            const origin = doc.data() as OrganizerContactOriginDocument;
            if (origin.organizerId !== organizerId ||
                origin.currentContactId !== canonicalContactId ||
                typeof origin.originContactId !== "string") {
              throw new OfferDomainError("conflict",
                "Stored CRM origin is malformed.");
            }
            const priorId = eventOfferId({organizerId, eventId,
              contactId: origin.originContactId});
            if (priorId !== eventOfferId({organizerId, eventId,
              contactId: canonicalContactId}) &&
                await firestoreTx.get(this.db.collection(collections.offers)
                  .doc(priorId)).then((snapshot) => snapshot.exists)) {
              return true;
            }
          }
          return false;
        },
        putOffer: (offer) => {
          pendingOffers.set(offer.offerId, offer);
        },
        createActionReceipt: (receipt) => {
          actionReceipts.push(receipt);
        },
        createBatchReceipt: (receipt) => {
          batchReceipts.push(receipt);
        },
        appendAudit: (entry) => {
          audits.push(entry);
        },
      };
      const result = await callback(tx);
      // The service has completed all reads. Collapse draft->offered writes
      // to one final document while retaining both immutable action receipts.
      for (const offer of pendingOffers.values()) {
        firestoreTx.set(this.db.collection(collections.offers)
          .doc(offer.offerId), offer);
      }
      for (const receipt of actionReceipts) {
        firestoreTx.create(this.db.collection(collections.actions)
          .doc(key(receipt.offerId, receipt.requestId)), receipt);
      }
      for (const receipt of batchReceipts) {
        firestoreTx.create(this.db.collection(collections.batches)
          .doc(key(receipt.organizerId, receipt.requestId)), receipt);
      }
      for (const entry of audits) {
        firestoreTx.create(this.db.collection(collections.audit)
          .doc(key(entry.offerId, entry.requestId)), entry);
      }
      return result;
    });
  }
}
