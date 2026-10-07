import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {usePartnerOutreachController} from "./usePartnerOutreachController";
import type {PartnerDraft, PartnerOutreachApi, PartnerPreparation} from "../api/partnerOutreachTypes";
const hash = "a".repeat(64);
const scope = {organizerId: "synthetic", expectedAssignmentRevision: 1};
function fixture() {
  const at = Date.now();
  const preparation: PartnerPreparation = {organizerId: scope.organizerId, assignmentRevision: 1,
    researchStatus: "qualified", contacts: [], opportunities: [], clauses: [],
    evaluatedAt: new Date(at).toISOString(), sendAuthority: false, capabilityApprovalAuthority: false};
  const draft: PartnerDraft = {draftId: "draft-own", status: "pending_review", reviewedAt: null,
    sendAuthority: false, draft: {draftId: "draft-own", organizerId: "synthetic", contactId: "contact",
      opportunityId: "opportunity", channel: "message", subject: null, text: "Reviewed wording.",
      contentHash: hash, sendAuthority: false, model: {modelId: "deterministic",
        usage: {inputTokens: 0, outputTokens: 0, costMicros: 0}}, sentences: []}};
  const completed = {status: "completed" as const, result: {draftId: "draft-own", contentHash: hash}, idempotentReplay: false};
  const api = {preparation: vi.fn().mockResolvedValue(preparation), generate: vi.fn().mockResolvedValue(completed),
    job: vi.fn().mockResolvedValue({...completed, failure: null, retryAfterSeconds: null}),
    draft: vi.fn().mockResolvedValue(draft), review: vi.fn().mockResolvedValue({}),
    copy: vi.fn().mockResolvedValue({draftId: "draft-own", subject: null, text: draft.draft.text,
      exactContentHash: hash, copiedAt: new Date(at).toISOString(), sendAuthority: false, providerConfirmed: false}),
    record: vi.fn().mockResolvedValue({})};
  const props = {actorUid: "partner-one", organizerId: "synthetic", assignmentRevision: 1,
    accessExpiresAt: new Date(at + 3600_000).toISOString(), isCurrentSession: () => true,
    api: api as PartnerOutreachApi};
  return {api, props, draft};
}
const source = {organizerId: "synthetic", contactId: "contact", opportunityId: "opportunity",
  observationIds: ["observation"], capabilityIds: ["capability"], referenceIds: [], ctaIds: ["cta"],
  channel: "message" as const, purpose: "first_message" as const};
afterEach(() => {cleanup(); vi.restoreAllMocks();});
describe("partner outreach current authority and exact recovery", () => {
  it("recovers an interrupted generation with the unchanged request and blocks changed material", async () => {
    const {api, props} = fixture();
    api.generate.mockRejectedValueOnce(new Error("Interrupted"));
    api.job.mockRejectedValueOnce(Object.assign(new Error("Not confirmed"), {code: "functions/not-found"}));
    const {result} = renderHook(() => usePartnerOutreachController(props), createQueryHarness());
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    await act(async () => {await result.current.generate(source);});
    await waitFor(() => expect(result.current.ticket).not.toBeNull());
    const original = api.generate.mock.calls[0][0];
    await act(async () => {await result.current.generate({...source, observationIds: ["changed"]});});
    expect(api.generate).toHaveBeenCalledTimes(1);
    await act(async () => {await result.current.retry();});
    expect(api.generate.mock.calls[1][0]).toEqual(original);
    await waitFor(() => expect(result.current.currentDraft?.draftId).toBe("draft-own"));
  });
  it("blocks simultaneous operations before React can render their pending state", async () => {
    const {api, props} = fixture(); let complete!: (v: unknown) => void;
    api.generate.mockImplementationOnce(() => new Promise((resolve) => {complete = resolve;}));
    const {result} = renderHook(() => usePartnerOutreachController(props), createQueryHarness());
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    let first!: Promise<unknown>;
    await act(async () => {first = result.current.generate(source); expect(await result.current.generate(source)).toBeNull();});
    expect(api.generate).toHaveBeenCalledTimes(1);
    await act(async () => {complete({status: "running", retryAfterSeconds: 5}); await first;});
  });
  it("retains exact work but refuses retry while the parent access gate is closed", async () => {
    const {api, props} = fixture(); api.generate.mockRejectedValueOnce(new Error("Interrupted"));
    api.job.mockRejectedValue(Object.assign(new Error("Not yet confirmed"), {code: "functions/not-found"}));
    const {result, rerender} = renderHook((p) => usePartnerOutreachController(p), {
      initialProps: {...props, parentAccessCurrent: true}, ...createQueryHarness()});
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    await act(async () => {await result.current.generate(source);});
    const original = api.generate.mock.calls[0][0];
    rerender({...props, parentAccessCurrent: false});
    expect(result.current.prepared).toBeNull(); expect(result.current.currentDraft).toBeNull();
    await act(async () => {expect(await result.current.retry()).toBeNull();});
    expect(api.generate).toHaveBeenCalledTimes(1); expect(result.current.ticket).not.toBeNull();
    rerender({...props, parentAccessCurrent: true});
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    await act(async () => {await result.current.retry();});
    expect(api.generate.mock.calls[1][0]).toEqual(original);
  });
  it("ignores an old actor's late generation when the workspace changes identity", async () => {
    const {api, props} = fixture(); let complete!: (v: unknown) => void;
    api.generate.mockImplementationOnce(() => new Promise((resolve) => {complete = resolve;}));
    const {result, rerender} = renderHook((p) => usePartnerOutreachController(p),
      {initialProps: props, ...createQueryHarness()});
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    let first!: Promise<unknown>;
    await act(async () => {first = result.current.generate(source);});
    rerender({...props, actorUid: "partner-two"});
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    await act(async () => {complete({status: "completed", result: {draftId: "foreign", contentHash: hash}, idempotentReplay: false}); await first;});
    expect(result.current.currentDraft).toBeNull();
    expect(result.current.notice).toBeNull(); expect(result.current.ticket).toBeNull();
    expect(api.draft).not.toHaveBeenCalled();
  });
  it("hides a previously loaded draft after denial and blocks its review", async () => {
    const {api, props} = fixture(); const harness = createQueryHarness();
    const {result} = renderHook(() => usePartnerOutreachController(props), harness);
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    await act(async () => {await result.current.generate(source);});
    await waitFor(() => expect(result.current.currentDraft).not.toBeNull());
    api.draft.mockRejectedValue(Object.assign(new Error("Revoked"), {code: "functions/permission-denied"}));
    await act(async () => {await result.current.refresh();});
    await waitFor(() => expect(result.current.draft.isError).toBe(true));
    expect(result.current.currentDraft).toBeNull();
    await act(async () => {expect(await result.current.review()).toBeNull();});
    expect(api.review).not.toHaveBeenCalled();
  });
  it("refuses expired reads and mismatched copy material before presenting a copy result", async () => {
    const {api, props, draft} = fixture(); draft.status = "approved"; draft.reviewedAt = new Date().toISOString();
    const {result} = renderHook(() => usePartnerOutreachController(props), createQueryHarness());
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    await act(async () => {await result.current.generate(source);});
    await waitFor(() => expect(result.current.currentDraft).not.toBeNull());
    api.copy.mockResolvedValueOnce({text: "Changed", subject: null});
    await act(async () => {expect(await result.current.copy()).toBeNull();});
    const before = api.copy.mock.calls.length;
    vi.spyOn(Date, "now").mockReturnValue(Date.now() + 61_000);
    await act(async () => {expect(await result.current.copy()).toBeNull();});
    expect(api.copy).toHaveBeenCalledTimes(before);
  });
  it("keeps an interrupted manual-send attestation exact and never asks a provider to send", async () => {
    const {api, props, draft} = fixture(); draft.status = "approved"; draft.reviewedAt = new Date().toISOString();
    api.record.mockRejectedValueOnce(new Error("Interrupted"));
    const {result} = renderHook(() => usePartnerOutreachController(props), createQueryHarness());
    await waitFor(() => expect(result.current.prepared).not.toBeNull());
    await act(async () => {await result.current.generate(source);});
    await waitFor(() => expect(result.current.currentDraft).not.toBeNull());
    const occurredAt = new Date().toISOString();
    await act(async () => {await result.current.record("whatsapp", occurredAt);});
    await act(async () => {await result.current.record("other", new Date().toISOString());});
    expect(api.record).toHaveBeenCalledTimes(1);
    await act(async () => {await result.current.retry();});
    expect(api.record.mock.calls[1][0]).toEqual(api.record.mock.calls[0][0]);
    expect(api.record.mock.calls[0][0]).toEqual(expect.objectContaining({occurredAt,
      channel: "whatsapp", attestation: "i_manually_sent_this_reviewed_draft"}));
    expect(result.current.notice).toContain("No delivery confirmation");
  });
});
