import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesPrincipal} from "../sales/types";
import {commercialQuoteId} from "./ids";
import type {CommercialDecision, EvidenceReference,
  HostSettlementAttestation, HostSettlementAttestationInput,
  QuoteHead, QuoteVersion} from "./types";

const attestations = "salesHostSettlementAttestations";
const evidenceUses = "salesHostSettlementEvidenceUses";
const accounts = "organizerSalesAccounts";
const opportunities = "salesOpportunities";
const quotes = "salesQuotes";
const versions = "salesQuoteVersions";
const decisions = "salesCommercialDecisions";
const evidenceCollection = "salesEvidence";

function hash(value: unknown): string {
  const canonical = (item: unknown): string => {
    if (Array.isArray(item)) return `[${item.map(canonical).join(",")}]`;
    if (item && typeof item === "object") {
      return `{${Object.entries(item).sort(([a], [b]) => a.localeCompare(b))
        .map(([key, child]) => `${JSON.stringify(key)}:${canonical(child)}`)
        .join(",")}}`;
    }
    return JSON.stringify(item);
  };
  return createHash("sha256").update(canonical(value)).digest("hex");
}

export function hostSettlementAttestationId(quoteId: string,
  termVersion: number): string {
  return `host-settlement-${quoteId}-v${termVersion}`;
}

function requireFinanceOwner(principal: SalesPrincipal): void {
  if (!principal.uid || !principal.roles.includes("adminOwner") ||
    principal.clientId) {
    throw new HttpsError("permission-denied",
      "Admin Owner finance review is required for manual settlement.");
  }
}

async function acceptedQuote(tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore, organizerId: string,
  opportunityId: string, expectedQuoteRevision?: number,
  expectedTermVersion?: number): Promise<{head: QuoteHead;
  version: QuoteVersion; acceptance: CommercialDecision}> {
  const quoteId = commercialQuoteId(opportunityId);
  const headSnap = await tx.get(db.collection(quotes).doc(quoteId));
  if (!headSnap.exists) {
    throw new HttpsError("failed-precondition",
      "An accepted quote is required.");
  }
  const head = headSnap.data() as QuoteHead;
  if (head.classification !== "sales_private" ||
    head.organizerId !== organizerId ||
    head.opportunityId !== opportunityId || head.quoteId !== quoteId ||
    head.status !== "accepted_reviewed" || !head.acceptedDecisionId ||
    expectedQuoteRevision !== undefined &&
      head.revision !== expectedQuoteRevision ||
    expectedTermVersion !== undefined &&
      head.termVersion !== expectedTermVersion) {
    throw new HttpsError("aborted",
      "Accepted quote changed since finance review.");
  }
  const [versionSnap, acceptanceSnap] = await Promise.all([
    tx.get(db.collection(versions).doc(`${quoteId}-v${head.termVersion}`)),
    tx.get(db.collection(decisions).doc(head.acceptedDecisionId)),
  ]);
  const version = versionSnap.data() as QuoteVersion | undefined;
  const acceptance = acceptanceSnap.data() as CommercialDecision | undefined;
  if (!versionSnap.exists || !acceptanceSnap.exists ||
    !version || !acceptance ||
    version.classification !== "sales_private" ||
    version.organizerId !== organizerId ||
    version.opportunityId !== opportunityId || version.quoteId !== quoteId ||
    version.termVersion !== head.termVersion ||
    acceptance.classification !== "sales_private" ||
    acceptance.kind !== "terms_acceptance_reviewed" ||
    acceptance.organizerId !== organizerId ||
    acceptance.opportunityId !== opportunityId ||
    acceptance.quoteId !== quoteId ||
    acceptance.termVersion !== head.termVersion ||
    acceptance.termsHash !== version.termsHash) {
    throw new HttpsError("failed-precondition",
      "Accepted terms need the exact reviewed quote version.");
  }
  return {head, version, acceptance};
}

async function settlementEvidence(tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore, organizerId: string,
  evidenceId: string, now: string): Promise<EvidenceReference> {
  const snap = await tx.get(db.collection(evidenceCollection).doc(evidenceId));
  const value = snap.data();
  if (!snap.exists || value?.classification !== "sales_private" ||
    value?.organizerId !== organizerId || !value?.reviewerUid ||
    !["first_party", "import_artifact"].includes(value?.sourceType) ||
    Date.parse(value?.observedAt) > Date.parse(now) ||
    value?.validThrough && Date.parse(value.validThrough) < Date.parse(now)) {
    throw new HttpsError("failed-precondition",
      "Current reviewed first-party settlement evidence is required.");
  }
  return {evidenceId, sourceRef: value.sourceRef,
    contentHash: hash(value), observedAt: value.observedAt};
}

/** Invoked after Sales authority and receipt replay checks. */
export async function attestHostSettlementInTransaction(
  tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal, input: HostSettlementAttestationInput,
  now: string): Promise<Record<string, unknown>> {
  requireFinanceOwner(principal);
  const [accountSnap, opportunitySnap] = await Promise.all([
    tx.get(db.collection(accounts).doc(input.organizerId)),
    tx.get(db.collection(opportunities).doc(input.opportunityId)),
  ]);
  if (!accountSnap.exists ||
    accountSnap.data()?.classification !== "sales_private" ||
    !opportunitySnap.exists ||
    opportunitySnap.data()?.organizerId !== input.organizerId ||
    opportunitySnap.data()?.stage === "closed_lost") {
    throw new HttpsError("failed-precondition",
      "An open same-host opportunity is required.");
  }
  const {head, version} = await acceptedQuote(tx, db, input.organizerId,
    input.opportunityId, input.expectedQuoteRevision, input.termVersion);
  if (version.terms.billingCadence === "usage_based" ||
    version.terms.amountMinor <= 0 ||
    version.terms.amountMinor !== input.amountMinor ||
    version.terms.currency !== input.currency ||
    input.purpose !== "host_subscription") {
    throw new HttpsError("failed-precondition",
      "Manual settlement must match exact positive accepted host terms.");
  }
  if (Date.parse(input.receivedAt) > Date.parse(now)) {
    throw new HttpsError("invalid-argument",
      "Settlement date cannot be future.");
  }
  const recurring = ["monthly", "annual"].includes(
    version.terms.billingCadence);
  if (recurring !== Boolean(input.servicePeriod) ||
    input.servicePeriod && Date.parse(input.servicePeriod.startsAt) >=
      Date.parse(input.servicePeriod.endsAt)) {
    throw new HttpsError("invalid-argument",
      "Recurring settlement needs one valid service period.");
  }
  const attestationId = hostSettlementAttestationId(head.quoteId,
    head.termVersion);
  const [existing, evidenceUse, evidence] = await Promise.all([
    tx.get(db.collection(attestations).doc(attestationId)),
    tx.get(db.collection(evidenceUses).doc(input.evidence.evidenceId)),
    settlementEvidence(tx, db, input.organizerId,
      input.evidence.evidenceId, now),
  ]);
  if (existing.exists || evidenceUse.exists) {
    throw new HttpsError("already-exists",
      "This accepted quote or payment evidence is already attested.");
  }
  const attestation: HostSettlementAttestation = {
    schemaVersion: 1, classification: "sales_private", revision: 1,
    attestationId,
    organizerId: input.organizerId, opportunityId: input.opportunityId,
    quoteId: head.quoteId, termVersion: head.termVersion,
    termsHash: version.termsHash, amountMinor: input.amountMinor,
    currency: input.currency, purpose: "host_subscription",
    receivedAt: input.receivedAt,
    settlementMethod: input.settlementMethod,
    servicePeriod: input.servicePeriod, evidence,
    status: "manual_attested_collected", providerConfirmed: false,
    actorUid: principal.uid, attestedAt: now,
  };
  tx.create(db.collection(attestations).doc(attestationId), attestation);
  tx.create(db.collection(evidenceUses).doc(evidence.evidenceId), {
    schemaVersion: 1, classification: "sales_private",
    evidenceId: evidence.evidenceId, attestationId,
    organizerId: input.organizerId, opportunityId: input.opportunityId,
    createdAt: now,
  });
  return {attestation};
}

/** Generic opportunities.upsert calls this before its canonical won write. */
export async function validateHostFinanceCloseInTransaction(
  tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal, organizerId: string, opportunityId: string,
  attestationId: string | null, now: string):
  Promise<HostSettlementAttestation> {
  requireFinanceOwner(principal);
  const {head, version} = await acceptedQuote(tx, db, organizerId,
    opportunityId);
  const expectedId = hostSettlementAttestationId(head.quoteId,
    head.termVersion);
  if (!attestationId || attestationId !== expectedId) {
    throw new HttpsError("failed-precondition",
      "Closed won needs this accepted quote's finance attestation.");
  }
  const snap = await tx.get(db.collection(attestations).doc(attestationId));
  const attestation = snap.data() as HostSettlementAttestation | undefined;
  if (!snap.exists || !attestation ||
    attestation.classification !== "sales_private" ||
    attestation.organizerId !== organizerId ||
    attestation.opportunityId !== opportunityId ||
    attestation.quoteId !== head.quoteId ||
    attestation.termVersion !== head.termVersion ||
    attestation.termsHash !== version.termsHash ||
    attestation.amountMinor !== version.terms.amountMinor ||
    attestation.currency !== version.terms.currency ||
    attestation.purpose !== "host_subscription" ||
    attestation.status !== "manual_attested_collected" ||
    attestation.providerConfirmed !== false) {
    throw new HttpsError("failed-precondition",
      "Finance attestation does not match accepted host terms.");
  }
  const currentEvidence = await settlementEvidence(tx, db, organizerId,
    attestation.evidence.evidenceId, now);
  if (currentEvidence.contentHash !== attestation.evidence.contentHash) {
    throw new HttpsError("failed-precondition",
      "Settlement evidence changed since attestation.");
  }
  return attestation;
}
