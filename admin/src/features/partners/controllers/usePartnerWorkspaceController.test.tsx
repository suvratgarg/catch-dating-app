import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {usePartnerWorkspaceController} from "./usePartnerWorkspaceController";
const api = vi.hoisted(() => ({readPartnerWorkspace: vi.fn(), writePartner: vi.fn()}));
vi.mock("../api/partnerRepository", () => api);
afterEach(cleanup);
beforeEach(() => {vi.clearAllMocks(); api.readPartnerWorkspace.mockResolvedValue({membership: {uid: "partner", expiresAt: new Date(Date.now() + 3600_000).toISOString()}, leads: [], submissions: [], nextCursor: null});});
describe("partner workspace recovery", () => {
  it("keeps the exact request identity after an uncertain failure and blocks duplicate concurrent writes", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => usePartnerWorkspaceController({actorUid: "partner", isCurrentSession: () => true}), {wrapper});
    await waitFor(() => expect(result.current.workspace.isSuccess).toBe(true));
    api.writePartner.mockRejectedValueOnce(new Error("Connection interrupted"));
    const material = {name: "Synthetic organizer", url: "https://synthetic.example", city: "Mumbai", relationshipContext: null};
    await act(async () => {expect(await result.current.save("nominate", material)).toBe(false);});
    const first = api.writePartner.mock.calls[0][1];
    let complete!: (value: unknown) => void;
    api.writePartner.mockImplementationOnce(() => new Promise((resolve) => {complete = resolve;}));
    let pending!: Promise<boolean>;
    await act(async () => {pending = result.current.save("nominate", material);});
    await act(async () => {expect(await result.current.save("nominate", material)).toBe(false);});
    expect(api.writePartner).toHaveBeenCalledTimes(2);
    expect(api.writePartner.mock.calls[1][1]).toEqual(first);
    await act(async () => {complete({}); expect(await pending).toBe(true);});
    expect(result.current.error).toBe(null);
  });
  it("blocks changed material until an uncertain save is reconciled", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => usePartnerWorkspaceController({actorUid: "partner", isCurrentSession: () => true}), {wrapper});
    await waitFor(() => expect(result.current.workspace.isSuccess).toBe(true));
    api.writePartner.mockRejectedValue(new Error("Interrupted"));
    await act(async () => {await result.current.save("nominate", {name: "One"});});
    await act(async () => {await result.current.save("nominate", {name: "Two"});});
    expect(api.writePartner).toHaveBeenCalledTimes(1);
    expect(result.current.needsRetry).toBe(true);
    api.writePartner.mockResolvedValue({});
    await act(async () => {await result.current.retry();});
    expect(api.writePartner.mock.calls[1][1]).toEqual(api.writePartner.mock.calls[0][1]);
  });
  it("blocks private writes after a successful read is followed by authority denial", async () => {
    const {wrapper, client} = createQueryHarness();
    const {result} = renderHook(() => usePartnerWorkspaceController({actorUid: "partner", isCurrentSession: () => true}), {wrapper});
    await waitFor(() => expect(result.current.workspace.isSuccess).toBe(true));
    api.readPartnerWorkspace.mockRejectedValue(Object.assign(new Error("Revoked"), {code: "functions/permission-denied"}));
    await act(async () => {await client.invalidateQueries({queryKey: ["partner-workspace"]});});
    await waitFor(() => expect(result.current.workspace.isError).toBe(true));
    await act(async () => {expect(await result.current.save("nominate", {name: "One"})).toBe(false);});
    expect(api.writePartner).not.toHaveBeenCalled();
  });
  it("ignores a prior actor's delayed save after an identity change", async () => {
    const {wrapper} = createQueryHarness();
    api.readPartnerWorkspace.mockImplementation((_cursor, actorUid) => Promise.resolve({
      membership: {uid: actorUid, expiresAt: new Date(Date.now() + 3600_000).toISOString()},
      leads: [], submissions: [], nextCursor: null}));
    let finish!: (value: unknown) => void;
    api.writePartner.mockImplementationOnce(() => new Promise((resolve) => {finish = resolve;}));
    const {result, rerender} = renderHook(({actorUid}) => usePartnerWorkspaceController({actorUid,
      isCurrentSession: () => true}), {initialProps: {actorUid: "partner-one"}, wrapper});
    await waitFor(() => expect(result.current.data?.membership.uid).toBe("partner-one"));
    let saved!: Promise<boolean>;
    await act(async () => {saved = result.current.save("nominate", {name: "Old actor nomination"});});
    rerender({actorUid: "partner-two"});
    await waitFor(() => expect(result.current.data?.membership.uid).toBe("partner-two"));
    await act(async () => {finish({}); expect(await saved).toBe(false);});
    expect(result.current.notice).toBeNull(); expect(result.current.error).toBeNull();
    expect(result.current.needsRetry).toBe(false);
  });
  it("withholds another actor's membership projection even if a mocked transport returns it", async () => {
    api.readPartnerWorkspace.mockResolvedValue({membership: {uid: "other-partner",
      expiresAt: new Date(Date.now() + 3600_000).toISOString()}, leads: [], submissions: [], nextCursor: null});
    const {result} = renderHook(() => usePartnerWorkspaceController({actorUid: "partner",
      isCurrentSession: () => true}), createQueryHarness());
    await waitFor(() => expect(result.current.workspace.isSuccess).toBe(true));
    expect(result.current.data).toBeUndefined();
    await act(async () => {expect(await result.current.save("nominate", {name: "Attempt"})).toBe(false);});
    expect(api.writePartner).not.toHaveBeenCalled();
  });
});
