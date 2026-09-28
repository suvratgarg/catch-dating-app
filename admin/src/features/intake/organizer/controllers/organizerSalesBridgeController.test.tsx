import {act, renderHook, waitFor} from "@testing-library/react";
import {expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../../shared/test/queryHarness";

const link = vi.hoisted(() => vi.fn());
vi.mock("../api/organizerSalesBridgeRepository", () => ({
  linkOrganizerIntakeToSales: link,
}));
vi.mock("./loadOrganizerIntakeBridge", async (importOriginal) => {
  const actual = await importOriginal<typeof import(
    "./loadOrganizerIntakeBridge")>();
  return {...actual, loadOrganizerIntakeBridge: async () => ({
    ...await actual.loadOrganizerIntakeBridge(), source: "firestore" as const,
  })};
});

import {useOrganizerIntakeController} from "./useOrganizerIntakeController";

it("resumes private Sales linking after Intake draft succeeded", async () => {
  const {wrapper} = createQueryHarness();
  const onError = vi.fn();
  const onOrganizerDraftCreated = vi.fn();
  const {result} = renderHook(() => useOrganizerIntakeController({
    onError, onNotice: vi.fn(), onOrganizerDraftCreated,
  }), {wrapper});
  await waitFor(() => expect(result.current.bridge.searchCandidates.candidates)
    .toHaveLength(2));
  const candidate = result.current.bridge.searchCandidates.candidates.find(
    (entry) => entry.existingEntityMatches.length === 0);
  if (!candidate) throw new Error("Expected new candidate.");
  link.mockRejectedValueOnce(new Error("temporary network failure"));
  await act(async () => {
    await result.current.handleCreateOrganizerDraft(candidate);
  });
  const draft = result.current.localOrganizerDrafts[candidate.candidateId];
  expect(draft?.organizerId).toBe("sampleOrg00000000001");
  expect(onOrganizerDraftCreated).not.toHaveBeenCalled();
  expect(onError).toHaveBeenCalledWith(expect.stringContaining(
    "Sales linking needs review"));
  expect(link.mock.calls[0][0]).toMatchObject({
    candidateId: candidate.candidateId,
    expectedWorkItemRevision: candidate.workItemRevision,
    expectedCandidateHash: candidate.candidateHash,
    organizerId: draft.organizerId,
    curationPath: draft.curationPath,
  });
  link.mockResolvedValueOnce({link: {linkId: "intake-sales-1",
    organizerId: draft.organizerId}, account: {organizerId: draft.organizerId,
    researchStatus: "new"}, accountCreated: true});
  await act(async () => {
    expect(await result.current.handleRetrySalesLink(candidate)).toBe(true);
  });
  expect(result.current.localSalesLinks[candidate.candidateId]
    ?.link.linkId).toBe("intake-sales-1");
});
