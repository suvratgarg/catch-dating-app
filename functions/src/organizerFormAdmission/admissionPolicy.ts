import {createHash} from "node:crypto";

/**
 * These facts are read and validated by the server adapter in one Firestore
 * transaction. Neither this type nor this pure function is a callable input.
 * In particular, a caller-supplied `managerAuthorized` or `seat` is never
 * admission authority.
 */
export interface AdmissionFacts {
  manager: {organizerId: string; actorUid: string; authorized: boolean;
    accountDeleted: boolean; organizerActive: boolean};
  source: {organizerId: string; responseId: string; formId: string;
    versionId: string; status: "submitted" | "withdrawn" | "other";
    withdrawn: boolean;
    /** The immutable version recorded by this response exists and validates. */
    submittedVersionValid: boolean;
    purpose: string; targetKind: string;
    targetId: string | null; crmReceiptCompleted: boolean;
    crmReceiptContactId: string | null};
  origin: {organizerId: string; responseId: string; formId: string;
    originContactId: string; currentContactId: string} | null;
  contact: {organizerId: string; contactId: string; available: boolean;
    ambiguous: boolean} | null;
  event: {organizerId: string; eventId: string; active: boolean;
    startsAtMillis: number; sourceRevision: number};
  offer: {offerId: string; organizerId: string; eventId: string;
    contactId: string;
    responseId: string; sourceKind: string; status: string;
    generation: number; revision: number; expiresAtMillis: number;
    payment: PaymentSnapshot; manual: ManualPaymentEvidence};
  seat: {ready: boolean; ledgerRevision: number;
    capacityRevision: number; migrationRevision: number;
    canonicalKey: string; identityRevision: number;
    occupancySource: "none" | "imported" | "catch";
    seatAlreadyOccupied: boolean; sourceAttendeeId: string | null;
    rosterTarget: "absent" | "sameImported" | "sameCatch" |
      "foreign";
    /** Active participation + UID alias proved in this same transaction. */
    catchParticipation: {eventId: string; uid: string;
      status: "signedUp" | "attended";
      canonicalKey: string; verifiedResponseUid: string} | null};
  /** Request-scoped immutable receipt, read inside the command transaction. */
  receipt: AdmissionReceipt | null;
  /** Deterministic organizer/event/response ownership marker. */
  sourceAdmission: AdmissionOwnership | null;
  nowMillis: number;
}

export interface PaymentSnapshot {
  eventPaymentRevision: number;
  eventPaymentHash: string;
  expectedAmountMinor: number | null;
  currency: string | null;
  collectionMode: "manualInstructions" | "reusablePage" |
    "personalRequest" | "catchCheckout" | null;
  reusablePaymentPageUrl: string | null;
  personalPaymentLink: string | null;
  paymentInstructions: string | null;
  expiresAtMillis: number;
}

export interface ManualPaymentEvidence {
  status: "none" | "evidenceSubmitted" |
    "hostAttestedReceived" | "rejected";
  evidenceRecordedAtMillis: number | null;
  bankReceiptChecked: boolean;
  reviewedByUid: string | null;
  reviewedAtMillis: number | null;
  reviewNote: string | null;
  attestedAmountMinor: number | null;
  attestedCurrency: string | null;
  attestedEventPaymentRevision: number | null;
  attestedEventPaymentHash: string | null;
}

/** Only reviewed, immutable command identity is hashed; no live facts are. */
export interface AdmissionCommand {
  actorUid: string;
  organizerId: string;
  eventId: string;
  responseId: string;
  contactId: string;
  offerId: string;
  requestId: string;
  expectedOfferRevision: number;
  expectedOfferGeneration: number;
  expectedLedgerRevision: number;
}

export interface AdmissionReceipt {
  organizerId: string;
  eventId: string;
  responseId: string;
  contactId: string;
  offerId: string;
  requestId: string;
  receiptId: string;
  requestHash: string;
  expectedOfferRevision: number;
  expectedOfferGeneration: number;
  expectedLedgerRevision: number;
  attendeeId: string;
  canonicalSeatKey: string;
  resultingLedgerRevision: number;
  admittedAtMillis: number;
  seatAlreadyOccupied: boolean;
  actorUid: string;
}

export interface AdmissionOwnership {
  organizerId: string;
  eventId: string;
  responseId: string;
  receiptId: string;
  attendeeId: string;
  canonicalSeatKey: string;
  offerId: string;
  offerRevision: number;
  offerGeneration: number;
}

export type AdmissionDecision =
  {kind: "replay"; requestHash: string; receipt: AdmissionReceipt} |
  {kind: "commit"; requestHash: string;
    seatAction: "reserve" | "retain";
    rosterAction: "create" | "linkExisting" | "preserveCatch";
    sourceAttendeeId: string | null;
    paymentAuthority: "explicitFree" | "hostAttested"};

export class AdmissionPolicyError extends Error {
  constructor(readonly code: "invalid" | "denied" | "stale" |
    "conflict" | "unavailable", message: string) {
    super(message);
  }
}

const id = /^[A-Za-z0-9][A-Za-z0-9_-]{0,179}$/u;
const requestId = /^[A-Za-z0-9][A-Za-z0-9_-]{7,119}$/u;
const hash64 = /^[a-f0-9]{64}$/u;
const positive = (value: unknown): value is number =>
  Number.isSafeInteger(value) && Number(value) > 0;
function fail(code: AdmissionPolicyError["code"], message: string): never {
  throw new AdmissionPolicyError(code, message);
}

/** Stable retry identity. Current source changes are checked separately. */
export function admissionRequestHash(command: AdmissionCommand): string {
  return createHash("sha256").update(JSON.stringify([
    "form-admission-v1", command.organizerId,
    command.eventId, command.responseId, command.contactId,
    command.offerId, command.requestId,
    command.expectedOfferRevision, command.expectedOfferGeneration,
    command.expectedLedgerRevision,
  ])).digest("hex");
}

/** Pure gate; the service must prepare the seat plan and write atomically. */
export function decideFormAdmission(command: AdmissionCommand,
  facts: AdmissionFacts): AdmissionDecision {
  if (![command.actorUid, command.organizerId, command.eventId,
    command.responseId, command.contactId, command.offerId]
    .every((value) => id.test(value)) ||
    !requestId.test(command.requestId) ||
    ![command.expectedOfferRevision, command.expectedOfferGeneration,
      command.expectedLedgerRevision].every(positive) ||
    !Number.isSafeInteger(facts.nowMillis) || facts.nowMillis < 0) {
    fail("invalid", "Invalid reviewed admission command.");
  }
  const manager = facts.manager;
  if (manager.organizerId !== command.organizerId ||
      manager.actorUid !== command.actorUid || !manager.authorized ||
      manager.accountDeleted || !manager.organizerActive) {
    fail("denied", "Current organizer manager authority is required.");
  }
  const requestHash = admissionRequestHash(command);
  const receipt = facts.receipt;
  const sourceAdmission = facts.sourceAdmission;
  if (receipt) {
    if (receipt.organizerId !== command.organizerId ||
        receipt.eventId !== command.eventId ||
        receipt.responseId !== command.responseId ||
        receipt.contactId !== command.contactId ||
        receipt.offerId !== command.offerId ||
        receipt.requestId !== command.requestId ||
        receipt.requestHash !== requestHash ||
        !id.test(receipt.receiptId) ||
        receipt.expectedOfferRevision !== command.expectedOfferRevision ||
        receipt.expectedOfferGeneration !== command.expectedOfferGeneration ||
        receipt.expectedLedgerRevision !== command.expectedLedgerRevision ||
        !id.test(receipt.attendeeId) ||
        !id.test(receipt.canonicalSeatKey) ||
        !id.test(receipt.actorUid) ||
        !positive(receipt.resultingLedgerRevision) ||
        !positive(receipt.admittedAtMillis) ||
        typeof receipt.seatAlreadyOccupied !== "boolean" ||
        !sourceAdmission ||
        sourceAdmission.organizerId !== command.organizerId ||
        sourceAdmission.eventId !== command.eventId ||
        sourceAdmission.responseId !== command.responseId ||
        sourceAdmission.receiptId !== receipt.receiptId ||
        sourceAdmission.attendeeId !== receipt.attendeeId ||
        sourceAdmission.canonicalSeatKey !== receipt.canonicalSeatKey ||
        sourceAdmission.offerId !== command.offerId ||
        sourceAdmission.offerRevision !== command.expectedOfferRevision ||
        sourceAdmission.offerGeneration !==
          command.expectedOfferGeneration) {
      fail("conflict", "Admission command conflicts with its receipt.");
    }
    return {kind: "replay", requestHash, receipt};
  }
  if (sourceAdmission) {
    fail("conflict", "Response is already admitted for this event.");
  }
  const source = facts.source;
  const origin = facts.origin;
  const contact = facts.contact;
  if (source.organizerId !== command.organizerId ||
      source.responseId !== command.responseId ||
      !id.test(source.formId) || !id.test(source.versionId) ||
      source.status !== "submitted" || source.withdrawn ||
      !source.submittedVersionValid ||
      !["registration", "intake"].includes(source.purpose) ||
      source.targetKind === "campaign" ||
      source.targetKind === "event" &&
        source.targetId !== command.eventId ||
      source.targetKind === "organizer" &&
        source.targetId !== null ||
      !["event", "organizer"].includes(source.targetKind) ||
      !source.crmReceiptCompleted ||
      source.crmReceiptContactId === null || !origin || !contact ||
      origin.organizerId !== command.organizerId ||
      origin.responseId !== command.responseId ||
      origin.formId !== source.formId ||
      origin.originContactId !== source.crmReceiptContactId ||
      origin.currentContactId !== command.contactId ||
      contact.organizerId !== command.organizerId ||
      contact.contactId !== command.contactId ||
      !contact.available || contact.ambiguous) {
    fail("unavailable", "Current response or CRM provenance is unavailable.");
  }
  const event = facts.event;
  if (event.organizerId !== command.organizerId ||
      event.eventId !== command.eventId || !event.active ||
      !positive(event.startsAtMillis) ||
      event.startsAtMillis <= facts.nowMillis ||
      !positive(event.sourceRevision)) {
    fail("unavailable", "Current event is unavailable for admission.");
  }
  const offer = facts.offer;
  if (offer.offerId !== command.offerId ||
      offer.organizerId !== command.organizerId ||
      offer.eventId !== command.eventId ||
      offer.contactId !== command.contactId ||
      offer.responseId !== command.responseId ||
      offer.sourceKind !== "formResponse" ||
      offer.status !== "offered" ||
      !positive(offer.expiresAtMillis) ||
      offer.expiresAtMillis <= facts.nowMillis ||
      !positive(offer.generation) || !positive(offer.revision)) {
    fail("unavailable", "Current issued offer is unavailable.");
  }
  if (offer.generation !== command.expectedOfferGeneration ||
      offer.revision !== command.expectedOfferRevision) {
    fail("stale", "Offer changed; review admission again.");
  }
  const payment = offer.payment;
  if (!positive(payment.eventPaymentRevision) ||
      !hash64.test(payment.eventPaymentHash) ||
      payment.expiresAtMillis !== offer.expiresAtMillis ||
      payment.expectedAmountMinor === null ||
      !Number.isSafeInteger(payment.expectedAmountMinor) ||
      payment.expectedAmountMinor < 0 ||
      payment.expectedAmountMinor > 0 &&
        !/^[A-Z]{3}$/u.test(payment.currency ?? "")) {
    fail("unavailable", "Issued payment terms are incomplete.");
  }
  let paymentAuthority: "explicitFree" | "hostAttested";
  if (payment.expectedAmountMinor === 0) {
    if (offer.manual.status !== "none") {
      fail("unavailable", "Free offer has conflicting payment evidence.");
    }
    paymentAuthority = "explicitFree";
  } else {
    if (payment.collectionMode === "catchCheckout") {
      fail("unavailable", "Provider payment proof is not integrated.");
    }
    if (payment.collectionMode === "manualInstructions" &&
        !payment.paymentInstructions?.trim() ||
        payment.collectionMode === "reusablePage" &&
          !payment.reusablePaymentPageUrl?.startsWith("https://") ||
        payment.collectionMode === "personalRequest" &&
          !payment.personalPaymentLink?.startsWith("https://")) {
      fail("unavailable", "Issued payment route is incomplete.");
    }
    if (!["manualInstructions", "reusablePage", "personalRequest"]
      .includes(payment.collectionMode ?? "") ||
        offer.manual.status !== "hostAttestedReceived" ||
        offer.manual.bankReceiptChecked !== true ||
        !positive(offer.manual.evidenceRecordedAtMillis) ||
        !id.test(offer.manual.reviewedByUid ?? "") ||
        !positive(offer.manual.reviewedAtMillis) ||
        offer.manual.evidenceRecordedAtMillis! >
          offer.manual.reviewedAtMillis! ||
        offer.manual.reviewedAtMillis! > facts.nowMillis ||
        !offer.manual.reviewNote?.trim() ||
        offer.manual.attestedAmountMinor !==
          payment.expectedAmountMinor ||
        offer.manual.attestedCurrency !== payment.currency ||
        offer.manual.attestedEventPaymentRevision !==
          payment.eventPaymentRevision ||
        offer.manual.attestedEventPaymentHash !==
          payment.eventPaymentHash) {
      fail("unavailable", "Exact manual payment review is required.");
    }
    paymentAuthority = "hostAttested";
  }
  const seat = facts.seat;
  if (!seat.ready || !positive(seat.ledgerRevision) ||
      !positive(seat.capacityRevision) ||
      !positive(seat.migrationRevision) ||
      !id.test(seat.canonicalKey) ||
      !positive(seat.identityRevision)) {
    fail("unavailable", "Canonical seat authority is unavailable.");
  }
  if (seat.ledgerRevision !== command.expectedLedgerRevision) {
    fail("stale", "Seat authority changed; review admission again.");
  }
  const imported = seat.occupancySource === "imported" &&
    seat.seatAlreadyOccupied && seat.rosterTarget === "sameImported" &&
    id.test(seat.sourceAttendeeId ?? "") &&
    seat.catchParticipation === null;
  const catchSeat = seat.occupancySource === "catch" &&
    seat.seatAlreadyOccupied && seat.sourceAttendeeId === null &&
    ["absent", "sameCatch"].includes(seat.rosterTarget) &&
    seat.catchParticipation?.eventId === command.eventId &&
    ["signedUp", "attended"].includes(seat.catchParticipation.status) &&
    seat.catchParticipation.canonicalKey === seat.canonicalKey &&
    id.test(seat.catchParticipation.uid) &&
    seat.catchParticipation.uid ===
      seat.catchParticipation.verifiedResponseUid;
  const newSeat = seat.occupancySource === "none" &&
    !seat.seatAlreadyOccupied && seat.rosterTarget === "absent" &&
    seat.sourceAttendeeId === null && seat.catchParticipation === null;
  if (!imported && !catchSeat && !newSeat) {
    fail("conflict", "Existing roster identity needs reconciliation.");
  }
  return {kind: "commit", requestHash,
    seatAction: newSeat ? "reserve" : "retain",
    rosterAction: imported ? "linkExisting" :
      catchSeat ? "preserveCatch" : "create",
    sourceAttendeeId: seat.sourceAttendeeId,
    paymentAuthority};
}
