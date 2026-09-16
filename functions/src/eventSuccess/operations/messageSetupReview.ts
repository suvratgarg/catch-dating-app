import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import type {EventMessagingSetupReview} from
  "../../shared/generated/eventMessagingSetupReview";
import {validateEventMessagingSetupReview} from
  "../../shared/generated/validators/eventMessagingSetupReview";
import {parseSmsConfig} from "./smsProtocol";
import {parseSmsBudget, smsBudgetId, smsBudgetScopes} from "./smsDispatchStore";
import {smsCollections} from "./smsPermissionRecords";
import {parseRcsConfig} from "./rcsProtocol";
import {parseRcsBudget, rcsBudgetId, rcsBudgetScopes, RCS_BUDGETS} from
  "./rcsDispatchRecords";
import {rcsConsentCollections} from "./rcsConsent";
import {WHATSAPP_POLICIES} from "./whatsappTemplate";
import {whatsappConsentSender} from "./whatsappConsentSender";
import {parseWhatsappBudget, whatsappBudgetId, whatsappBudgetScopes,
  WHATSAPP_BUDGETS} from "./whatsappSpend";
import {readMessageSenderChoice} from
  "./runtimeSenderSetup";
import {parseRuntimeConfig, runtimeConfigId, runtimeConfigSource,
  runtimeConfigStatus, RUNTIME_CONFIGS, RuntimeContext} from
  "./runtimeConfigRecords";
import {requireDocumentId} from "./guestRecords";

type Budget = ReturnType<typeof parseSmsBudget | typeof parseRcsBudget |
  typeof parseWhatsappBudget>;
type BudgetScope = Budget["scope"];
export type MessageBudgetReview = Extract<
  EventMessagingSetupReview["budgets"],
  {kind: "reviewed"}
>["event"];
export type MessageSetupScope = Pick<EventMessagingSetupReview,
  "context" | "routeId" | "senderId" | "purpose">;
export type MessageSetupReview = EventMessagingSetupReview;

/** Exact operator reads without credentials, roster access or writes. */
export async function reviewEventMessageSetup(db: Firestore,
  input: MessageSetupScope, clock: () => number = Date.now):
  Promise<MessageSetupReview> {
  return db.runTransaction((tx) =>
    reviewEventMessageSetupInTransaction(db, tx, input, clock),
  {readOnly: true});
}

/**
 * Reads one setup review inside an existing transaction. Privileged decision
 * boundaries use this form so the evidence they store and the decision
 * revision are observed atomically.
 */
export async function reviewEventMessageSetupInTransaction(db: Firestore,
  tx: Transaction, input: MessageSetupScope,
  clock: () => number = Date.now): Promise<MessageSetupReview> {
  requireDocumentId(input.senderId);
  if (input.context.mode !== "live") throw new Error("Live setup required");
  const runtimeId = runtimeConfigId(input.context);
  if (!["catchEventSms", "catchEventRcs", "organizerEventWhatsapp"]
    .includes(input.routeId)) throw new Error("Invalid message channel");
  const now = clock();
  const [event, plan, runtime] = await tx.getAll(
    db.collection("events").doc(input.context.eventId),
    db.collection("eventSuccessPlans").doc(input.context.eventId),
    db.collection(RUNTIME_CONFIGS).doc(runtimeId));
  const source = runtimeConfigSource(input.context, event, plan, now);
  const record = runtime.exists ?
    parseRuntimeConfig(runtime.data(), input.context, now) : null;
  const sender = await readMessageSenderChoice(db, tx, input.context,
    input, input.purpose, now);
  const budgetSource = sender ? await readBudgetSource(db, tx, input) : null;
  let budgets: MessageSetupReview["budgets"] = {kind: "senderUnavailable"};
  if (budgetSource) {
    const scopes = budgetSource.scopes(input.context, now);
    const ids = scopes.map(budgetSource.id);
    const snapshots = await tx.getAll(...ids.map((id) =>
      db.collection(budgetSource.collection).doc(id)));
    const reviews = snapshots.map((snap, i) => reviewBudget(snap.data(),
      scopes[i], ids[i], budgetSource, now));
    budgets = {kind: "reviewed", currency: budgetSource.currency,
      sourceHash: budgetSource.sourceHash,
      event: reviews[0], senderDay: reviews[1]};
  }
  const completedAt = clock();
  if (!Number.isSafeInteger(completedAt) || completedAt < now) {
    throw new Error("Invalid setup review clock");
  }
  // A review that crosses a billing-day boundary must not display yesterday's
  // sender-day ceiling. Re-run the bounded read instead of guessing a budget.
  if (budgetSource && operationContentHash(budgetSource.scopes(input.context,
    completedAt)) !== operationContentHash(budgetSource.scopes(input.context,
    now))) throw new Error("Message setup review crossed a billing day");
  const review: MessageSetupReview = {schemaVersion: 1,
    kind: "recordedSetupReview", ...input, observedAt: now, completedAt,
    grantsDispatchAuthority: false,
    runtime: {appliesToPurpose: input.purpose === "joiningUpdate",
      status: runtimeConfigStatus(record, source, now),
      revision: record?.revision ?? null, sourceHash: source.hash,
      eventEnd: source.eventEnd,
      selected: input.purpose === "joiningUpdate" &&
        (record?.configuration?.options.routes.some((r) =>
          r.routeId === input.routeId &&
          r.senderId === input.senderId) ?? false)},
    sender, budgets};
  if (!validateEventMessagingSetupReview(review)) {
    throw new Error("Invalid event messaging setup review");
  }
  return review;
}

interface BudgetSource {
  collection: string;
  currency: string;
  sourceHash: string;
  agentId?: string;
  id(scope: BudgetScope): string;
  scopes(context: RuntimeContext, now: number): [BudgetScope, BudgetScope];
  parse(value: unknown): Budget;
}

async function readBudgetSource(db: Firestore, tx: Transaction,
  input: MessageSetupScope): Promise<BudgetSource | null> {
  const read = async (collection: string) => (await tx.get(db
    .collection(collection).doc(input.senderId))).data();
  const value = await read({catchEventSms: smsCollections.senders,
    catchEventRcs: rcsConsentCollections.senders,
    organizerEventWhatsapp: WHATSAPP_POLICIES}[input.routeId]);
  const connection = input.routeId === "organizerEventWhatsapp" ?
    await read("organizerSenderConnections") : null;
  try {
    switch (input.routeId) {
    case "catchEventSms": {
      const sender = parseSmsConfig(value);
      if (sender.senderId !== input.senderId) return null;
      return {collection: smsCollections.budgets,
        currency: sender.quote.currency,
        sourceHash: operationContentHash(sender),
        scopes: smsBudgetScopes, parse: parseSmsBudget,
        id: (scope) => smsBudgetId(input.senderId, scope)};
    }
    case "catchEventRcs": {
      const sender = parseRcsConfig(value);
      if (sender.senderId !== input.senderId) return null;
      return {collection: RCS_BUDGETS, currency: sender.quote.currency,
        sourceHash: operationContentHash(sender), agentId: sender.agentId,
        scopes: rcsBudgetScopes, parse: parseRcsBudget,
        id: (scope) => rcsBudgetId(input.senderId, scope)};
    }
    case "organizerEventWhatsapp": {
      const policy = whatsappConsentSender(input.senderId,
        input.context.organizerId, connection, value)?.policy;
      if (!policy) return null;
      return {collection: WHATSAPP_BUDGETS, currency: policy.quote.currency,
        sourceHash: operationContentHash([connection, policy]),
        scopes: whatsappBudgetScopes, parse: parseWhatsappBudget,
        id: (scope) => whatsappBudgetId(input.senderId, policy.quote.currency,
          scope)};
    }
    }
  } catch {
    return null;
  }
}

function reviewBudget(value: unknown, scope: BudgetScope, budgetId: string,
  source: BudgetSource, now: number): MessageBudgetReview {
  const unavailable = (reason: "missing" | "invalid"): MessageBudgetReview =>
    ({budgetId, scope, kind: "unavailable", reason});
  if (value === undefined) return unavailable("missing");
  let budget: Budget;
  try {
    budget = source.parse(value);
  } catch {
    return unavailable("invalid");
  }
  if (budget.budgetId !== budgetId || budget.updatedAt > now) {
    return unavailable("invalid");
  }
  const issue = budget.currency !== source.currency ? "currencyChanged" :
    source.agentId && (!("agentId" in budget) ||
      source.agentId !== budget.agentId) ? "agentChanged" :
      budget.status !== "active" ? "paused" :
        budget.endsAt <= now ? "expired" :
          budget.limitMicros === budget.chargedMicros ? "exhausted" : null;
  return {budgetId, scope, kind: "recorded", issue, revision: budget.revision,
    approvalId: budget.approvalId, currency: budget.currency,
    limitMicros: budget.limitMicros, chargedMicros: budget.chargedMicros,
    remainingMicros: budget.limitMicros - budget.chargedMicros,
    startsAt: budget.startsAt, endsAt: budget.endsAt,
    reviewHash: operationContentHash(budget)};
}
