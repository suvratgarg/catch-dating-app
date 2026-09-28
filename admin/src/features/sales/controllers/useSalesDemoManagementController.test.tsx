import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";
import {afterEach, expect, it, vi} from "vitest";
import type {DemoManagementApi, DemoSaveInput} from
  "../api/salesDemoManagement";
import {useSalesDemoManagementController} from "./useSalesDemoManagementController";

afterEach(cleanup);
const capability = {capability: "synthetic_forms_v1" as const,
  revision: "revision-001", evidenceRevision: "evidence-001", enabled: true,
  templateOptions: [{templateId: "basic", title: "Basic form"}]};
function fixture() {
  const saveBlueprint = vi.fn<DemoManagementApi["saveBlueprint"]>();
  const api = {capability: vi.fn(async () => capability),
    listBlueprints: vi.fn(async () => ({rows: [], nextCursor: null})),
    listInvitations: vi.fn(async () => ({rows: [], nextCursor: null})),
    getBlueprint: vi.fn(), getInvitation: vi.fn(), saveBlueprint,
    reviewBlueprint: vi.fn(), withdrawBlueprint: vi.fn(),
    issueInvitation: vi.fn(), revokeInvitation: vi.fn()} as DemoManagementApi;
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: {children: ReactNode}) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {api, saveBlueprint, wrapper};
}
const draft: Omit<DemoSaveInput, "requestId"> = {
  blueprintId: "blueprint-001", expectedRevision: 0,
  organizerId: "organizer-001", candidateId: null, opportunityId: null,
  evidenceRevision: "evidence-001",
  preview: {brandName: "Example", headline: "Try an example",
    scenario: "Sample review", steps: ["Review", "Reply", "Admit"],
    retainedTools: [], limitations: ["Synthetic only"], cta: "Try"},
  formCapabilityReview: {questionTypes: "manual", branching: "manual",
    requiredFields: "manual", scoringApproval: "unsupported",
    uploads: "retained"}, fieldMappings: [],
  setupPlan: {mode: "manual", requirements: ["Review form requirements"]},
};

it("retries uncertain save with frozen material and the same request ID",
  async () => {
    const {api, saveBlueprint, wrapper} = fixture();
    saveBlueprint.mockRejectedValueOnce(new Error("network lost"))
      .mockResolvedValueOnce({blueprintId: "blueprint-001", revision: 1,
        state: "draft"});
    const {result} = renderHook(() => useSalesDemoManagementController({
      isAdminOwner: true, actorUid: "owner-001", organizerId: "organizer-001",
      api,
    }), {wrapper});
    await waitFor(() => expect(result.current.capability.data).toEqual(capability));
    await act(async () => {expect(await result.current.save(draft)).toBe(false);});
    expect(result.current.pending).not.toBeNull();
    expect(saveBlueprint).toHaveBeenCalledTimes(1);
    await act(async () => {expect(await result.current.retry()).toBe(true);});
    expect(saveBlueprint).toHaveBeenCalledTimes(2);
    expect(saveBlueprint.mock.calls[1][0]).toEqual(saveBlueprint.mock.calls[0][0]);
    expect(result.current.pending).toBeNull();
  });

it("frees a definitively rejected revision for reviewed resubmission",
  async () => {
    const {api, saveBlueprint, wrapper} = fixture();
    saveBlueprint.mockRejectedValueOnce(Object.assign(new Error("stale"),
      {code: "functions/failed-precondition"}));
    const {result} = renderHook(() => useSalesDemoManagementController({
      isAdminOwner: true, actorUid: "owner-001", organizerId: "organizer-001",
      api,
    }), {wrapper});
    await act(async () => {expect(await result.current.save(draft)).toBe(false);});
    expect(result.current.pending).toBeNull();
    expect(result.current.error).toContain("rejected");
    expect(saveBlueprint).toHaveBeenCalledOnce();
  });

it("treats an aborted transaction as a definitive no-effect rejection",
  async () => {
    const {api, saveBlueprint, wrapper} = fixture();
    saveBlueprint.mockRejectedValueOnce(Object.assign(new Error("aborted"),
      {code: "functions/aborted"}));
    const {result} = renderHook(() => useSalesDemoManagementController({
      isAdminOwner: true, actorUid: "owner-001", organizerId: "organizer-001",
      api,
    }), {wrapper});
    await act(async () => {expect(await result.current.save(draft)).toBe(false);});
    expect(result.current.pending).toBeNull();
    expect(result.current.error).toContain("rejected");
  });

it("does not read or mutate demos for a non-owner", async () => {
  const {api, saveBlueprint, wrapper} = fixture();
  const {result} = renderHook(() => useSalesDemoManagementController({
    isAdminOwner: false, actorUid: "staff-001", organizerId: "organizer-001",
    api,
  }), {wrapper});
  await act(async () => {expect(await result.current.save(draft)).toBe(false);});
  expect(api.capability).not.toHaveBeenCalled();
  expect(api.listBlueprints).not.toHaveBeenCalled();
  expect(saveBlueprint).not.toHaveBeenCalled();
});
