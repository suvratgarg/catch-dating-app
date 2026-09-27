import {cleanup, fireEvent, render, screen, waitFor} from
  "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {afterEach, expect, it, vi} from "vitest";
import type {IntelligenceApi} from "../api/salesIntelligenceTypes";
import {SalesIntelligenceWorkspace} from "./SalesIntelligenceWorkspace";

afterEach(() => {cleanup(); vi.unstubAllGlobals();});
const evaluatedAt = "2026-09-28T10:00:00.000Z";
const hash = "a".repeat(64);
function fixture() {
  const policy = {policyId: "policy-one", version: "v1", revision: 1,
    status: "active" as const, factors: ["a", "b", "c", "d", "e", "f", "g"]
      .map((id) => ({id, weight: 14, claimKeys: ["operation" as const],
        maxAgeDays: 30})), priorityBands: {high: 80, medium: 50},
    promptVersion: "prompt-v1", playbookVersion: "playbook-v1"};
  const clause = (clauseId: string, kind: "observation" | "capability" |
    "cta", text: string) => ({clauseId, organizerId: "org-one", revision: 1,
    kind, text, state: "approved" as const, evidenceIds: [],
    validUntil: "2099-01-01T00:00:00.000Z", permission: "not_required" as const,
    reviewedAt: evaluatedAt});
  const api = {catalog: vi.fn(async () => ({policy, assessments: [],
    clauses: [clause("observation-one", "observation", "Host uses applications."),
      clause("capability-one", "capability", "Catch collects applications."),
      clause("cta-one", "cta", "Would a walkthrough help?")], evaluatedAt})),
  score: vi.fn(async () => ({snapshot: {status: "needs_research",
    score: null, priority: "unranked", policyVersion: "v1", evaluatedAt,
    factors: []}})),
  account: vi.fn(async () => ({account: {organizerId: "org-one", revision: 1,
    researchStatus: "qualified", suppressionStatus: "clear"},
  organizerSummary: {name: "Example Host"}, activities: [], tasks: [],
  opportunities: [{opportunityId: "opportunity-one", organizerId: "org-one",
    motion: "first_pilot", stage: "ready_to_contact", ownerUid: "employee-one",
    nextStep: null, nextStepAt: null, revision: 1}]})),
  contacts: vi.fn(async () => ({rows: [{contactId: "contact-one",
    displayName: "Example Contact", relationship: {revision: 1,
      role: "organizer", decisionInfluence: "operator", primary: true,
      contactabilityStatus: "draft_reviewed", sendAuthority: false}}],
    nextCursor: null})),
  evidence: vi.fn(async () => ({rows: [], nextCursor: null})),
  drafts: vi.fn(async () => ({rows: [{draftId: "draft-one",
    contactId: "contact-one", opportunityId: "opportunity-one",
    subject: "Private note", status: "approved", contentHash: hash,
    createdAt: evaluatedAt, reviewedAt: evaluatedAt}]})),
  draft: vi.fn(async () => ({draftId: "draft-one", status: "approved",
    reviewedAt: evaluatedAt, reviewedBy: "employee-one",
    sendAuthority: false, draft: {draftId: "draft-one", subject: "Private note",
      text: "Approved text", contentHash: hash, sendAuthority: false,
      model: {modelId: "deterministic", usage: {inputTokens: 0,
        outputTokens: 0, costMicros: 0}}, sentences: []}})),
  job: vi.fn(), assess: vi.fn(), saveClause: vi.fn(), reviewClause: vi.fn(),
  generate: vi.fn(async () => ({status: "completed" as const,
    result: {draftId: "draft-one", contentHash: hash}})),
  review: vi.fn(), copy: vi.fn(async () => ({draftId: "draft-one",
    exactContentHash: hash, subject: "Private note", text: "Approved text",
    copiedAt: evaluatedAt, sendAuthority: false, providerConfirmed: false}))} as
    IntelligenceApi;
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const view = (isAdminOwner = false) => render(<QueryClientProvider client={client}>
    <SalesIntelligenceWorkspace organizerId="org-one" organizerName="Example Host"
      currentUserUid="employee-one" isAdminOwner={isAdminOwner} api={api} />
  </QueryClientProvider>);
  return {api, view};
}

it("selects current approved sources and prepares a real private draft request", async () => {
  const {api, view} = fixture();
  view();
  await screen.findByText("Host uses applications.");
  fireEvent.change(screen.getByLabelText("Reviewed contact"),
    {target: {value: "contact-one"}});
  fireEvent.change(screen.getByLabelText("Opportunity ready for contact"),
    {target: {value: "opportunity-one"}});
  fireEvent.change(screen.getByLabelText("Host observation"),
    {target: {value: "observation-one"}});
  fireEvent.change(screen.getByLabelText("Catch capability"),
    {target: {value: "capability-one"}});
  fireEvent.change(screen.getByLabelText("Question or next step"),
    {target: {value: "cta-one"}});
  fireEvent.click(screen.getByRole("button", {name: "Prepare private draft"}));
  await waitFor(() => expect(api.generate).toHaveBeenCalledOnce());
  expect(vi.mocked(api.generate).mock.calls[0][0].sourceRequest).toEqual({
    organizerId: "org-one", contactId: "contact-one",
    opportunityId: "opportunity-one", observationIds: ["observation-one"],
    capabilityIds: ["capability-one"], referenceIds: [], ctaIds: ["cta-one"],
    channel: "email", purpose: "first_message"});
  expect(screen.queryByRole("button", {name: /send/iu})).toBeNull();
});

it("offers copy only after server-reviewed draft and never claims delivery", async () => {
  const {api, view} = fixture();
  const writeText = vi.fn(async () => undefined);
  vi.stubGlobal("navigator", {...navigator, clipboard: {writeText}});
  view();
  fireEvent.click(await screen.findByRole("button", {name: "Open draft"}));
  fireEvent.click(await screen.findByRole("button", {name: "Copy approved text"}));
  await waitFor(() => expect(api.copy).toHaveBeenCalledOnce());
  expect(vi.mocked(api.copy).mock.calls[0][0].expectedContentHash).toBe(hash);
  await waitFor(() => expect(writeText).toHaveBeenCalledWith(
    "Private note\n\nApproved text"));
  expect(screen.getByText(/Sending, if appropriate, is a separate manual action/u))
    .toBeTruthy();
});

it("keeps wording approval unavailable to non-owner staff", async () => {
  const {api, view} = fixture();
  view(false);
  await screen.findByText("Host uses applications.");
  expect(screen.queryByRole("button", {name: "Approve wording"})).toBeNull();
  expect(screen.queryByRole("button", {name: "Save sentence for approval"}))
    .toBeNull();
  expect(api.reviewClause).not.toHaveBeenCalled();
});
