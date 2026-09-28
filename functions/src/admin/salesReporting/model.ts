/* eslint-disable max-len */
import {HttpsError} from "firebase-functions/v2/https";

export const stages = ["new_enquiry", "ready_to_contact", "contacted",
  "in_conversation", "demo_arranged", "demo_completed", "pilot_agreed",
  "pilot_running", "commercial_discussion", "closed_won", "closed_lost"];
export interface ReportRow {id: string; data: Record<string, unknown>}
export interface FunnelInput {since: string}
const ms = (value: unknown) => typeof value === "string" ? Date.parse(value) : NaN;
export function validateInput(value: unknown, now: string): FunnelInput {
  const input = value as FunnelInput;
  if (!input || typeof input !== "object" || Array.isArray(input) ||
      Object.keys(input).length !== 1 || !Number.isFinite(ms(input.since)) ||
      new Date(ms(input.since)).toISOString() !== input.since ||
      ms(input.since) > ms(now) || ms(now) - ms(input.since) > 90 * 86400000) {
    throw new HttpsError("invalid-argument", "Choose a reporting start within the last 90 days.");
  }
  return input;
}

/** Counts all loaded records, never a UI page. Each metric states its grain. */
export function summarizeFunnel(input: FunnelInput, now: string,
  accounts: ReportRow[], opportunities: ReportRow[], tasks: ReportRow[],
  history: ReportRow[], restrictedIds: Set<string> = new Set()) {
  const known = new Map(accounts.filter(({id, data}) =>
    data.organizerId === id && data.classification === "sales_private" &&
    data.researchStatus !== "archived" && !restrictedIds.has(id))
    .map(({id, data}) => [id, data]));
  const current = opportunities.filter(({id, data}) =>
    data.opportunityId === id && data.classification === "sales_private" &&
    known.has(String(data.organizerId)));
  if (current.some(({data}) => !stages.includes(String(data.stage)))) {
    throw new HttpsError("failed-precondition", "Review unsupported opportunity stages before reporting.");
  }
  const entered = history.filter(({data}) =>
    data.classification === "sales_private" && known.has(String(data.organizerId)) &&
    ms(data.changedAt) >= ms(input.since) && ms(data.changedAt) <= ms(now));
  const open = tasks.filter(({data}) => data.classification === "sales_private" &&
    known.has(String(data.organizerId)) && data.status === "open");
  const countHosts = (rows: ReportRow[]) =>
    new Set(rows.map(({data}) => data.organizerId)).size;
  const rows = stages.map((stage) => {
    const atStage = current.filter(({data}) => data.stage === stage);
    const movements = entered.filter(({data}) => data.toStage === stage);
    return {stage, opportunities: atStage.length, distinctHosts: countHosts(atStage),
      enteredInWindow: movements.length, distinctHostsEntered: countHosts(movements)};
  });
  const active = current.filter(({data}) =>
    !["closed_won", "closed_lost"].includes(String(data.stage)));
  const overdue = active.filter(({data}) =>
    Number.isFinite(ms(data.nextStepAt)) && ms(data.nextStepAt) < ms(now));
  const missingNextStep = active.filter(({data}) =>
    typeof data.nextStep !== "string" || !data.nextStep.trim() ||
    !Number.isFinite(ms(data.nextStepAt)));
  // Replies and existing commitments remain visible even on an outreach hold.
  const obligations = open.filter(({data}) =>
    ["reply", "service_commitment", "opt_out", "duplicate_review", "pilot"]
      .includes(String(data.kind)));
  return {schemaVersion: 1 as const, asOf: now, since: input.since,
    coverage: "complete_bounded_snapshot" as const,
    activeHosts: known.size, opportunities: current.length,
    hostsWithOpportunities: countHosts(current), stages: rows,
    overdueOpportunities: overdue.length, hostsWithOverdueOpportunities: countHosts(overdue),
    opportunitiesMissingNextStep: missingNextStep.length,
    openObligations: obligations.length,
    overdueObligations: obligations.filter(({data}) =>
      Number.isFinite(ms(data.dueAt)) && ms(data.dueAt) < ms(now)).length,
    heldHosts: [...known.values()].filter((data) => data.suppressionStatus !== "clear").length,
    duplicateReviewHosts: [...known.values()].filter((data) => data.duplicateReviewRequired === true).length,
    excludedArchivedOrRestrictedHosts: accounts.length - known.size,
    movementEvents: entered.length,
    revenueStatus: "not_calculated" as const};
}
