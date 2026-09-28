import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";
import {afterEach, expect, it, vi} from "vitest";
import type {IntelligenceApi} from "../api/salesIntelligenceTypes";
import {useSalesIntelligenceController} from "./useSalesIntelligenceController";

afterEach(cleanup);
const organizerId = "org-one";
const source = {organizerId, contactId: "contact-one",
  opportunityId: "opportunity-one", observationIds: ["observation-one"],
  capabilityIds: ["capability-one"], referenceIds: [], ctaIds: ["cta-one"],
  channel: "email" as const, purpose: "first_message" as const};
function fixture() {
  const api = {catalog: vi.fn(async () => ({policy: null, assessments: [],
    clauses: [], evaluatedAt: "2026-09-28T10:00:00.000Z"})),
  score: vi.fn(async () => ({snapshot: {status: "needs_research", score: null,
    priority: "unranked", policyVersion: "v1", evaluatedAt: "2026-09-28T10:00:00.000Z",
    factors: []}})),
  account: vi.fn(), contacts: vi.fn(), evidence: vi.fn(),
  drafts: vi.fn(async () => ({rows: []})), draft: vi.fn(),
  job: vi.fn(), assess: vi.fn(), savePolicy: vi.fn(), saveClause: vi.fn(),
  reviewClause: vi.fn(),
  generate: vi.fn(), review: vi.fn(), copy: vi.fn()} as IntelligenceApi;
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: {children: ReactNode}) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {api, wrapper};
}

it("keeps frozen request material for uncertain generation retry", async () => {
  const {api, wrapper} = fixture();
  vi.mocked(api.generate).mockRejectedValueOnce(new Error("network lost"))
    .mockResolvedValueOnce({status: "completed", result: {draftId: "draft-one",
      contentHash: "a".repeat(64)}});
  vi.mocked(api.job).mockRejectedValue(Object.assign(new Error("not found"),
    {code: "functions/not-found"}));
  const {result} = renderHook(() => useSalesIntelligenceController({actorUid: "employee-one",
    organizerId, api}), {wrapper});
  await act(async () => {expect(await result.current.generate(source)).toBeNull();});
  await waitFor(() => expect(result.current.pending).not.toBeNull());
  await act(async () => {await result.current.retry();});
  expect(api.generate).toHaveBeenCalledTimes(2);
  expect(vi.mocked(api.generate).mock.calls[1][0])
    .toEqual(vi.mocked(api.generate).mock.calls[0][0]);
  expect(result.current.selectedDraftId).toBe("draft-one");
  expect(result.current.pending).toBeNull();
});

it("recovers a completed job after an uncertain callable response", async () => {
  const {api, wrapper} = fixture();
  vi.mocked(api.generate).mockRejectedValueOnce(new Error("response lost"));
  vi.mocked(api.job).mockResolvedValue({status: "completed",
    result: {draftId: "draft-recovered", contentHash: "b".repeat(64)},
    failure: null, retryAfterSeconds: null});
  const {result} = renderHook(() => useSalesIntelligenceController({actorUid: "employee-one",
    organizerId, api}), {wrapper});
  await act(async () => {await result.current.generate(source);});
  await waitFor(() => expect(result.current.selectedDraftId)
    .toBe("draft-recovered"));
  expect(result.current.pending).toBeNull();
  expect(api.generate).toHaveBeenCalledOnce();
});

it("definitive source rejection releases the pending request", async () => {
  const {api, wrapper} = fixture();
  vi.mocked(api.generate).mockRejectedValueOnce(Object.assign(
    new Error("source changed"), {code: "functions/aborted"}));
  const {result} = renderHook(() => useSalesIntelligenceController({actorUid: "employee-one",
    organizerId, api}), {wrapper});
  await act(async () => {await result.current.generate(source);});
  expect(result.current.pending).toBeNull();
  expect(result.current.error).toContain("rejected");
  expect(api.job).not.toHaveBeenCalled();
});

it("review and copy keep exact content hash in server receipts", async () => {
  const {api, wrapper} = fixture();
  const hash = "c".repeat(64);
  vi.mocked(api.review).mockResolvedValue({draftId: "draft-one",
    exactContentHash: hash, sendAuthority: false, providerConfirmed: false});
  vi.mocked(api.copy).mockResolvedValue({draftId: "draft-one",
    exactContentHash: hash, sendAuthority: false, providerConfirmed: false,
    subject: null, text: "Approved text", copiedAt: "2026-09-28T10:00:00.000Z"});
  const {result} = renderHook(() => useSalesIntelligenceController({actorUid: "employee-one",
    organizerId, api}), {wrapper});
  await act(async () => {await result.current.review("draft-one", hash);});
  await act(async () => {await result.current.copy("draft-one", hash);});
  expect(api.review).toHaveBeenCalledWith(expect.objectContaining({
    draftId: "draft-one", expectedContentHash: hash,
    factualValidity: "verified", tone: "approved",
    channelReadiness: "manual_copy_only"}));
  expect(api.copy).toHaveBeenCalledWith(expect.objectContaining({
    draftId: "draft-one", expectedContentHash: hash}));
});

it("retries an uncertain policy save with exactly the same material", async () => {
  const {api, wrapper} = fixture();
  const policy = {policyId: "policy-one", version: "revision_2",
    status: "paused" as const, factors: ["a", "b", "c", "d", "e", "f", "g"]
      .map((id, index) => ({id, weight: index === 6 ? 16 : 14,
        maxAgeDays: 30, claimKeys: ["operation" as const]})),
    priorityBands: {high: 80, medium: 50}, promptVersion: "zero_model_v1",
    playbookVersion: "reviewed_v1"};
  vi.mocked(api.savePolicy).mockRejectedValueOnce(new Error("response lost"))
    .mockResolvedValueOnce({policy: {...policy, revision: 2}});
  const {result} = renderHook(() => useSalesIntelligenceController({
    actorUid: "owner-one", organizerId, api}), {wrapper});
  await act(async () => {expect(await result.current.savePolicy(policy, 1))
    .toBeNull();});
  expect(result.current.pending).not.toBeNull();
  await act(async () => {await result.current.retry();});
  expect(api.savePolicy).toHaveBeenCalledTimes(2);
  expect(vi.mocked(api.savePolicy).mock.calls[1][0])
    .toEqual(vi.mocked(api.savePolicy).mock.calls[0][0]);
  expect(result.current.confirmedPolicy).toEqual({policyId: "policy-one",
    revision: 2});
  expect(result.current.pending).toBeNull();
});
