import {createHash} from "node:crypto";
import {publicWebhookUrl} from "../organizers/organizerAutomationWebhook";

/**
 * Pure offer rules. The server-only storage adapter and service are not
 * registered as deployed endpoints. They must derive current manager/source,
 * CRM contact and event authority transactionally; a context flag supplied
 * by a client is never authority. This model does not hold a seat, admit a
 * guest, capture payment, send a message or confirm external delivery.
 * Evidence correction/replacement and reissue after recorded financial
 * evidence require an immutable history/archive adapter; both are rejected
 * here rather than erasing an earlier financial assertion.
 */
export interface CurrentOfferContext {
  organizerId: string;
  eventId: string;
  contactId: string;
  applicationId: string;
  /** Application review or a submitted registration/intake form response. */
  sourceKind?: "application" | "formResponse";
  applicationTargetKind: "organizer" | "event" | "campaign";
  applicationTargetId: string | null;
  /** Authenticated manager or trusted expiry worker, checked by the adapter. */
  actorUid: string;
  actorAuthorized: boolean;
  /** Approved application, or eligible submitted registration/intake form. */
  applicationApproved: boolean;
  sourceCurrent: boolean;
  contactCurrent: boolean;
  eventCurrent: boolean;
  eventStartsAtMillis: number;
}

export type OfferStatus = "draft" | "offered" | "withdrawn" | "expired";
export type PaymentReviewStatus =
  "none" | "evidenceSubmitted" | "hostAttestedReceived" | "rejected";

export interface ManualPaymentReview {
  status: PaymentReviewStatus;
  /** Text/reference only; no asset URL or payment token. */
  evidenceReference: string | null;
  evidenceRecordedAtMillis: number | null;
  reviewedByUid: string | null;
  reviewedAtMillis: number | null;
  reviewNote: string | null;
  bankReceiptChecked: boolean;
}

export interface EventOffer {
  offerId: string;
  organizerId: string;
  eventId: string;
  contactId: string;
  applicationId: string;
  sourceKind?: "application" | "formResponse";
  status: OfferStatus;
  /** Reissue advances generation so an old offer cannot authorize a new one. */
  generation: number;
  revision: number;
  expiresAtMillis: number;
  organizerPaymentLink: string | null;
  /** A withdrawn draft never became an offer and cannot receive evidence. */
  offeredAtMillis: number | null;
  manualPayment: ManualPaymentReview;
  createdAtMillis: number;
  updatedAtMillis: number;
}

interface ActionBase {
  requestId: string;
  expectedRevision: number;
}
type Terms = {expiresAtMillis: number; organizerPaymentLink: string | null};
export type OfferAction =
  | (ActionBase & {kind: "createDraft"; terms: Terms})
  | (ActionBase & {kind: "reissueDraft"; expectedGeneration: number;
      terms: Terms})
  | (ActionBase & {kind: "offer" | "withdraw" | "expire";
      expectedGeneration: number})
  | (ActionBase & {kind: "recordEvidence";
      expectedGeneration: number; evidenceReference: string})
  | (ActionBase & {kind: "reconcileEvidence";
      expectedGeneration: number; decision: "hostAttestedReceived" |
      "rejected"; reviewNote: string; bankReceiptChecked: boolean});

/** The adapter stores one immutable receipt per offer ID and request ID. */
export interface OfferActionReceipt {
  offerId: string;
  requestId: string;
  requestHash: string;
  resultingGeneration: number;
  resultingRevision: number;
}

export interface OfferTransition {
  offer: EventOffer;
  receipt: OfferActionReceipt;
  replayed: boolean;
}

export class OfferDomainError extends Error {
  constructor(readonly code: "invalid" | "denied" | "conflict",
    message: string) {
    super(message);
  }
}

function requireValid(condition: boolean, message: string): void {
  if (!condition) throw new OfferDomainError("invalid", message);
}

function validId(value: string): boolean {
  return typeof value === "string" && value.length >= 1 &&
    value.length <= 180 && value !== "." && value !== ".." &&
    !value.includes("/") &&
    !Array.from(value).some((character) => character.charCodeAt(0) < 32);
}

function validRequestId(value: string): boolean {
  return typeof value === "string" &&
    /^[A-Za-z0-9][A-Za-z0-9_-]{7,119}$/u.test(value);
}

function hash(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

/** One aggregate per organizer/contact/event, across applications. */
export function eventOfferId(context: Pick<CurrentOfferContext,
  "organizerId" | "eventId" | "contactId">): string {
  for (const id of [context.organizerId, context.eventId,
    context.contactId]) requireValid(validId(id), "Invalid offer identity.");
  return "applicationoffer_" + hash([context.organizerId,
    context.eventId, context.contactId].join("\u001f")).slice(0, 40);
}

function requireActorAndScope(context: CurrentOfferContext,
  now: number): void {
  requireValid(validId(context.applicationId) && validId(context.actorUid) &&
    Number.isSafeInteger(now) && now >= 0 &&
    Number.isSafeInteger(context.eventStartsAtMillis),
  "Invalid offer context.");
  if (!context.actorAuthorized) {
    throw new OfferDomainError("denied",
      "Current actor authority is required.");
  }
}

function requireCurrentIssuance(context: CurrentOfferContext,
  now: number): void {
  if (!context.applicationApproved ||
    !context.sourceCurrent || !context.contactCurrent ||
    !context.eventCurrent) {
    throw new OfferDomainError("denied",
      "Current offer authority is required.");
  }
  if (context.applicationTargetKind === "event" &&
    context.applicationTargetId !== context.eventId ||
    context.applicationTargetKind === "campaign" ||
    context.applicationTargetKind === "organizer" &&
    context.applicationTargetId !== null) {
    throw new OfferDomainError("denied",
      "Application target does not allow this event.");
  }
  if (now >= context.eventStartsAtMillis) {
    throw new OfferDomainError("conflict", "The event has already started.");
  }
}

function actionHash(offerId: string, action: OfferAction): string {
  const base = [offerId, action.kind, action.requestId,
    action.expectedRevision];
  switch (action.kind) {
  case "createDraft":
    return hash(JSON.stringify([...base, action.terms.expiresAtMillis,
      action.terms.organizerPaymentLink]));
  case "reissueDraft":
    return hash(JSON.stringify([...base, action.expectedGeneration,
      action.terms.expiresAtMillis, action.terms.organizerPaymentLink]));
  case "recordEvidence":
    return hash(JSON.stringify([...base, action.expectedGeneration,
      action.evidenceReference.trim()]));
  case "reconcileEvidence":
    return hash(JSON.stringify([...base, action.expectedGeneration,
      action.decision, action.reviewNote.trim(), action.bankReceiptChecked]));
  default:
    return hash(JSON.stringify([...base, action.expectedGeneration]));
  }
}

function validatedTerms(terms: Terms, now: number,
  eventStartsAtMillis: number): Terms {
  requireValid(Number.isSafeInteger(terms.expiresAtMillis) &&
    terms.expiresAtMillis > now &&
    terms.expiresAtMillis <= eventStartsAtMillis,
  "Offer expiry must precede the event.");
  if (terms.organizerPaymentLink === null) return terms;
  requireValid(terms.organizerPaymentLink.length <= 2048,
    "Payment link is too long.");
  try {
    // Reuse the existing public HTTPS URL policy. It never performs a fetch.
    const url = publicWebhookUrl(terms.organizerPaymentLink);
    requireValid(url.toString() === terms.organizerPaymentLink,
      "Use a canonical public HTTPS payment link.");
  } catch {
    throw new OfferDomainError("invalid", "Use a public HTTPS payment link.");
  }
  return terms;
}

function blankPayment(): ManualPaymentReview {
  return {status: "none", evidenceReference: null,
    evidenceRecordedAtMillis: null, reviewedByUid: null,
    reviewedAtMillis: null, reviewNote: null, bankReceiptChecked: false};
}

/** Pure transition; callers must supply a transactionally current context. */
export function applyEventOfferAction(params: {
  current: EventOffer | null;
  context: CurrentOfferContext;
  action: OfferAction;
  nowMillis: number;
  priorReceipt?: OfferActionReceipt | null;
}): OfferTransition {
  const {current, context, action, nowMillis} = params;
  const offerId = eventOfferId(context);
  requireActorAndScope(context, nowMillis);
  requireValid(validRequestId(action.requestId) &&
    Number.isSafeInteger(action.expectedRevision) &&
    action.expectedRevision >= 0, "Invalid action identity or revision.");
  requireValid(["createDraft", "reissueDraft", "offer", "withdraw",
    "expire", "recordEvidence", "reconcileEvidence"].includes(action.kind),
  "Invalid offer action.");
  const requestHash = actionHash(offerId, action);
  if (current && (current.offerId !== offerId ||
      current.organizerId !== context.organizerId ||
      current.eventId !== context.eventId ||
      current.contactId !== context.contactId)) {
    throw new OfferDomainError("conflict", "Offer identity changed.");
  }
  const prior = params.priorReceipt;
  if (prior) {
    if (prior.offerId !== offerId || prior.requestId !== action.requestId ||
      prior.requestHash !== requestHash) {
      throw new OfferDomainError("conflict",
        "Request ID was reused for different work.");
    }
    if (!current || prior.resultingGeneration > current.generation ||
      prior.resultingRevision > current.revision) {
      throw new OfferDomainError("conflict",
        "Offer receipt is ahead of the offer.");
    }
    return {offer: current, receipt: prior, replayed: true};
  }
  if (action.kind === "createDraft") {
    requireCurrentIssuance(context, nowMillis);
    if (current || action.expectedRevision !== 0) {
      throw new OfferDomainError("conflict", "Offer already exists.");
    }
    const terms = validatedTerms(action.terms, nowMillis,
      context.eventStartsAtMillis);
    const created: EventOffer = {offerId,
      organizerId: context.organizerId, eventId: context.eventId,
      contactId: context.contactId, applicationId: context.applicationId,
      sourceKind: context.sourceKind ?? "application",
      status: "draft", generation: 1, revision: 1,
      expiresAtMillis: terms.expiresAtMillis,
      organizerPaymentLink: terms.organizerPaymentLink,
      offeredAtMillis: null,
      manualPayment: blankPayment(), createdAtMillis: nowMillis,
      updatedAtMillis: nowMillis};
    return result(created, action, requestHash);
  }
  if (!current || current.revision !== action.expectedRevision ||
      current.generation !== action.expectedGeneration) {
    throw new OfferDomainError("conflict", "Offer changed; review it again.");
  }
  if ((current.applicationId !== context.applicationId ||
      (current.sourceKind ?? "application") !==
        (context.sourceKind ?? "application")) &&
      action.kind !== "reissueDraft") {
    if (action.kind !== "withdraw" && action.kind !== "expire" &&
        action.kind !== "recordEvidence" &&
        action.kind !== "reconcileEvidence") {
      throw new OfferDomainError("conflict", "Application source changed.");
    }
  }
  let next: EventOffer;
  switch (action.kind) {
  case "reissueDraft": {
    requireCurrentIssuance(context, nowMillis);
    if (current.status !== "withdrawn" && current.status !== "expired" &&
        !(current.status === "draft" && nowMillis >= current.expiresAtMillis)) {
      throw new OfferDomainError("conflict",
        "Only a closed offer can be reissued.");
    }
    if (current.manualPayment.status !== "none") {
      throw new OfferDomainError("conflict",
        "Archive payment evidence before reissuing this offer.");
    }
    const terms = validatedTerms(action.terms, nowMillis,
      context.eventStartsAtMillis);
    next = {...current, applicationId: context.applicationId,
      sourceKind: context.sourceKind ?? "application",
      status: "draft", generation: current.generation + 1,
      expiresAtMillis: terms.expiresAtMillis,
      organizerPaymentLink: terms.organizerPaymentLink,
      offeredAtMillis: null,
      manualPayment: blankPayment()};
    break;
  }
  case "offer":
    requireCurrentIssuance(context, nowMillis);
    if (current.status !== "draft" || nowMillis >= current.expiresAtMillis) {
      throw new OfferDomainError("conflict", "Draft offer is unavailable.");
    }
    validatedTerms({expiresAtMillis: current.expiresAtMillis,
      organizerPaymentLink: current.organizerPaymentLink}, nowMillis,
    context.eventStartsAtMillis);
    next = {...current, status: "offered", offeredAtMillis: nowMillis};
    break;
  case "withdraw":
    if (current.status !== "draft" && current.status !== "offered") {
      throw new OfferDomainError("conflict", "Offer is already closed.");
    }
    next = {...current, status: "withdrawn"};
    break;
  case "expire":
    if ((current.status !== "draft" && current.status !== "offered") ||
        nowMillis < current.expiresAtMillis) {
      throw new OfferDomainError("conflict", "Offer is not due to expire.");
    }
    next = {...current, status: "expired"};
    break;
  case "recordEvidence": {
    if (current.offeredAtMillis === null ||
        current.manualPayment.status !== "none") {
      throw new OfferDomainError("conflict", "Offer cannot receive evidence.");
    }
    const reference = action.evidenceReference.trim();
    requireValid(reference.length >= 3 && reference.length <= 240 &&
      !/^[a-z]+:\/\//iu.test(reference),
    "Use a short payment reference, not a URL or uploaded asset.");
    next = {...current, manualPayment: {
      status: "evidenceSubmitted", evidenceReference: reference,
      evidenceRecordedAtMillis: nowMillis, reviewedByUid: null,
      reviewedAtMillis: null, reviewNote: null, bankReceiptChecked: false,
    }};
    break;
  }
  case "reconcileEvidence":
    if (current.manualPayment.status !== "evidenceSubmitted" ||
        !["hostAttestedReceived", "rejected"].includes(action.decision)) {
      throw new OfferDomainError("conflict",
        "Current evidence review is unavailable.");
    }
    requireValid(typeof action.reviewNote === "string" &&
      action.reviewNote.trim().length >= 3 &&
      action.reviewNote.trim().length <= 240 &&
      typeof action.bankReceiptChecked === "boolean" &&
      (action.decision !== "hostAttestedReceived" ||
        action.bankReceiptChecked),
    "Record a review reason and explicitly check the bank receipt.");
    next = {...current, manualPayment: {...current.manualPayment,
      status: action.decision, reviewedByUid: context.actorUid,
      reviewedAtMillis: nowMillis, reviewNote: action.reviewNote.trim(),
      bankReceiptChecked: action.bankReceiptChecked}};
    break;
  }
  return result({...next, revision: current.revision + 1,
    updatedAtMillis: nowMillis}, action, requestHash);
}

function result(offer: EventOffer, action: OfferAction,
  requestHash: string): OfferTransition {
  return {offer, receipt: {offerId: offer.offerId,
    requestId: action.requestId, requestHash,
    resultingGeneration: offer.generation,
    resultingRevision: offer.revision}, replayed: false};
}
