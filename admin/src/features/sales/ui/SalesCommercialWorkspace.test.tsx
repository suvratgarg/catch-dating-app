import {cleanup, fireEvent, render, screen, waitFor} from
  "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {afterEach, expect, it, vi} from "vitest";
import {AdminFeedbackProvider} from "../../../shared/feedback/AdminFeedbackContext";
import type {SalesAccountDetail, SalesEvidence} from "../api/salesTypes";
import {renderSalesCommercialWorkspace} from "./SalesCommercialWorkspace";

const mocks = vi.hoisted(() => ({mode: "sample" as "sample" | "live",
  detail: vi.fn(), report: vi.fn(), pilot: vi.fn(), quote: vi.fn(),
  approve: vi.fn(), accept: vi.fn()}));
vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => mocks.mode}));
vi.mock("../api/salesCommercialRepository", () => ({
  getCommercialDetail: mocks.detail, listCommercialReport: mocks.report,
  upsertCommercialPilot: mocks.pilot, reviseCommercialQuote: mocks.quote,
  approveCommercialQuote: mocks.approve, acceptCommercialQuote: mocks.accept,
}));
afterEach(() => {cleanup(); vi.clearAllMocks(); mocks.mode = "sample";});

const account = {account: {organizerId: "org-1"},
  opportunities: [{opportunityId: "opp-1", motion: "first_workflow_pilot",
    stage: "pilot_agreed"}]} as SalesAccountDetail;
const evidence = [{evidenceId: "evidence-1", claimKey: "operation",
  sourceRef: "Reviewed host interview"}] as SalesEvidence[];
function view() {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  return render(<QueryClientProvider client={client}>
    <AdminFeedbackProvider onError={vi.fn()} onNotice={vi.fn()}>
      {renderSalesCommercialWorkspace(account, evidence)}
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
