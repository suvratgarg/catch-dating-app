import {cleanup, fireEvent, render, screen, waitFor} from
  "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {afterEach, expect, it, vi} from "vitest";
import {AdminFeedbackProvider} from "../../../shared/feedback/AdminFeedbackContext";
import type {SalesAccountDetail, SalesEvidence} from "../api/salesTypes";
import {renderSalesCommercialWorkspace} from "./SalesCommercialWorkspace";

const mocks = vi.hoisted(() => ({mode: "sample" as "sample" | "live",
  detail: vi.fn(), report: vi.fn(), pilot: vi.fn(), quote: vi.fn(),
  approve: vi.fn(), accept: vi.fn(), attest: vi.fn(), close: vi.fn()}));
vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => mocks.mode}));
vi.mock("../api/salesCommercialRepository", () => ({
  getCommercialDetail: mocks.detail, listCommercialReport: mocks.report,
  upsertCommercialPilot: mocks.pilot, reviseCommercialQuote: mocks.quote,
  approveCommercialQuote: mocks.approve, acceptCommercialQuote: mocks.accept,
  attestHostSettlement: mocks.attest, closeWonWithFinance: mocks.close,
}));
afterEach(() => {cleanup(); vi.clearAllMocks(); mocks.mode = "sample";});

const account = {account: {organizerId: "org-1"},
  opportunities: [{opportunityId: "opp-1", motion: "first_workflow_pilot",
    stage: "pilot_agreed"}]} as SalesAccountDetail;
const evidence = [{evidenceId: "evidence-1", claimKey: "operation",
  sourceRef: "Reviewed host interview"}] as SalesEvidence[];
function view(isAdminOwner = false) {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  return render(<QueryClientProvider client={client}>
    <AdminFeedbackProvider onError={vi.fn()} onNotice={vi.fn()}>
      {renderSalesCommercialWorkspace(account, evidence, isAdminOwner)}
    </AdminFeedbackProvider>
  </QueryClientProvider>);
}

it("does not offer sample approvals as if they were live records", () => {
  view();
  expect(screen.getByText(/Sample hosts are not approval evidence/u)).toBeTruthy();
  expect(mocks.detail).not.toHaveBeenCalled();
  expect(mocks.approve).not.toHaveBeenCalled();
});

it("submits a reviewed pilot with selected evidence and revision", async () => {
  mocks.mode = "live";
  mocks.detail.mockResolvedValue({opportunity: {opportunityId: "opp-1",
    organizerId: "org-1", stage: "pilot_agreed"}, pilotPlan: null,
  quote: null, quoteVersion: null, approvedDecision: null, acceptedDecision: null,
  history: [], historyTruncated: false, paymentStatus: "unknown",
  bookedHostRevenueMinor: null});
  mocks.report.mockResolvedValue({rows: [], nextCursor: null, pageScope: true});
  mocks.pilot.mockResolvedValue({pilotPlan: {revision: 1}});
  view();
  await screen.findByText("Pilot plan");
  fireEvent.change(screen.getByLabelText("Pilot status"),
    {target: {value: "reviewed"}});
  fireEvent.change(screen.getByLabelText("Workflow key"),
    {target: {value: "sample-pilot"}});
  fireEvent.change(screen.getByLabelText("Objective"),
    {target: {value: "Review application workflow"}});
  fireEvent.change(screen.getByLabelText("Success measures, one per line"),
    {target: {value: "Document the outcome"}});
  fireEvent.change(screen.getByLabelText("Reviewed plan evidence"),
    {target: {value: "evidence-1"}});
  fireEvent.click(screen.getByRole("button", {name: "Save pilot plan"}));
  await waitFor(() => expect(mocks.pilot).toHaveBeenCalledOnce());
  expect(mocks.pilot.mock.calls[0][0]).toMatchObject({organizerId: "org-1",
    opportunityId: "opp-1", expectedRevision: 0, plan: {status: "reviewed",
      reviewEvidence: {evidenceId: "evidence-1"}}});
});

it("attests host collection before a separate reviewed close", async () => {
  mocks.mode = "live";
  const quote = {quoteId: "quote-1", revision: 3, termVersion: 1,
    status: "accepted_reviewed"};
  const terms = {currency: "INR", amountMinor: 120000,
    billingCadence: "monthly", scope: "One reviewed month",
    validUntil: "2026-10-01T00:00:00.000Z", sourceFactRefs: ["evidence-1"]};
  const base = {opportunity: {opportunityId: "opp-1",
    organizerId: "org-1", stage: "commercial_discussion", revision: 7,
    motion: "first_workflow_pilot", ownerUid: "owner-1",
    nextStep: "Review terms", nextStepAt: "2026-10-01T00:00:00.000Z"},
  pilotPlan: null, quote, quoteVersion: {terms},
  approvedDecision: null, acceptedDecision: null,
  history: [], historyTruncated: false, paymentStatus: "unknown",
  bookedHostRevenueMinor: null};
  const settled = {...base, paymentStatus: "manual_attested",
    settlementAttestation: {attestationId: "host-settlement-quote-1-v1",
      quoteId: "quote-1", termVersion: 1, amountMinor: 120000,
      currency: "INR", purpose: "host_subscription",
      receivedAt: "2026-09-27T12:00:00.000Z",
      settlementMethod: "bank_transfer", providerConfirmed: false,
      settlementReference: "BANK UTR 123456",
      recipientAccountScope: "Catch India ledger",
      evidence: {sourceRef: "Bank confirmation"}}};
  mocks.detail.mockResolvedValueOnce({...base, settlementAttestation: null})
    .mockResolvedValue(settled);
  mocks.report.mockResolvedValue({rows: [], nextCursor: null, pageScope: true});
  mocks.attest.mockResolvedValue({attestation: settled.settlementAttestation});
  mocks.close.mockResolvedValue({opportunity: {...base.opportunity,
    stage: "closed_won"}});
  const financeEvidence: SalesEvidence[] = [
    {...evidence[0], sourceType: "first_party"},
  ];
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  render(<QueryClientProvider client={client}>
    <AdminFeedbackProvider onError={vi.fn()} onNotice={vi.fn()}>
      {renderSalesCommercialWorkspace(account, financeEvidence, true)}
    </AdminFeedbackProvider>
  </QueryClientProvider>);
  await screen.findByText("Attest manual host collection");
  fireEvent.change(screen.getByLabelText("Received on"),
    {target: {value: "2026-09-27T12:00"}});
  fireEvent.change(screen.getByLabelText("Service period start"),
    {target: {value: "2026-09-27T00:00"}});
  fireEvent.change(screen.getByLabelText("Service period end"),
    {target: {value: "2026-10-27T00:00"}});
  fireEvent.change(screen.getByLabelText("Reviewed settlement evidence"),
    {target: {value: "evidence-1"}});
  fireEvent.change(screen.getByLabelText("External settlement reference"),
    {target: {value: "BANK UTR 123456"}});
  fireEvent.change(screen.getByLabelText("Recipient ledger or account label"),
    {target: {value: "Catch India ledger"}});
  fireEvent.click(screen.getByRole("button", {
    name: "Record manual host collection"}));
  await waitFor(() => expect(mocks.attest).toHaveBeenCalledOnce());
  expect(mocks.attest.mock.calls[0][0]).toMatchObject({
    expectedQuoteRevision: 3, termVersion: 1, amountMinor: 120000,
    currency: "INR", purpose: "host_subscription",
    settlementReference: "BANK UTR 123456",
    recipientAccountScope: "Catch India ledger",
    evidence: {evidenceId: "evidence-1"}});
  fireEvent.click(await screen.findByRole("button", {
    name: "Review current quote and finance proof"}));
  fireEvent.click(screen.getByRole("button", {name: "Mark closed won"}));
  await waitFor(() => expect(mocks.close).toHaveBeenCalledOnce());
  expect(mocks.close.mock.calls[0][0]).toMatchObject({expectedRevision: 7,
    financeAttestationId: "host-settlement-quote-1-v1",
    fields: {stage: "closed_won", nextStep: null, nextStepAt: null}});
});
