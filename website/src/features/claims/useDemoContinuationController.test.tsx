import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {describe, expect, it, vi} from "vitest";
import type {SalesDemoAuth, SalesDemoViewer} from "../../shared/auth/salesDemoAuth";
import type {SalesDemoContinuation, SalesDemoContinuationApi} from "../../shared/domain/salesDemoHandoff";
import {useDemoContinuationController} from "./useDemoContinuationController";

const continuationId = "c".repeat(64);
const viewer: SalesDemoViewer = {uid: "owner-one", email: "owner@example.invalid",
  emailVerified: true, phoneNumber: null};
const view: SalesDemoContinuation = {continuationId, expiresAt: "2099-01-01T00:00:00.000Z",
  organizer: {organizerId: "hidden-organizer", name: "Private organizer", claimState: "claimed"},
  setup: {schemaVersion: 1, setupHash: "a".repeat(64), organizerId: "hidden-organizer",
    publicationAuthority: false, status: "ready", formId: null, editorPath: null,
    plan: {mode: "template", requirements: ["Review consent"], title: "Private template",
      templateId: "blank", templateVersion: 1, templateHash: "b".repeat(64), materializerVersion: 1}}};
function harness() {
  let change: (next: SalesDemoViewer | null) => void = () => undefined;
  const auth: SalesDemoAuth = {watch: (callback) => {
    change = callback; callback(viewer); return () => undefined;
  }, signInGoogle: vi.fn(), beginPhone: vi.fn()};
  const api: SalesDemoContinuationApi = {get: vi.fn().mockResolvedValue(view),
    prepare: vi.fn().mockResolvedValue(view)};
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) => <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  const hook = renderHook(() => useDemoContinuationController(continuationId, api, auth), {wrapper});
  return {...hook, api, client, change: (next: SalesDemoViewer | null) => act(() => change(next))};
}
describe("private setup continuation", () => {
  it("hides retained private setup on a same-UID token recheck and denial", async () => {
    const h = harness(); await waitFor(() => expect(h.result.current.current).toEqual(view));
    vi.mocked(h.api.get).mockRejectedValue(new Error("permission-denied"));
    h.change({...viewer, phoneNumber: "+15555550100"});
    expect(h.result.current.current).toBeNull();
    await waitFor(() => expect(h.result.current.query.isError).toBe(true));
    expect(h.result.current.current).toBeNull();
    await act(async () => h.result.current.prepare());
    expect(h.api.prepare).not.toHaveBeenCalled(); h.unmount();
  });
  it("discards a delayed private reply after the account changes", async () => {
    const h = harness(); await waitFor(() => expect(h.result.current.current).toEqual(view));
    let resolve: (value: SalesDemoContinuation) => void = () => undefined;
    vi.mocked(h.api.get).mockImplementationOnce(() => new Promise((done) => {resolve = done;}));
    let refresh!: Promise<unknown>;
    act(() => {refresh = h.result.current.query.refetch();});
    h.change(null);
    expect(h.result.current.current).toBeNull();
    await act(async () => {resolve(view); await refresh;});
    expect(h.result.current.current).toBeNull(); h.unmount();
  });
  it("reconciles an interrupted draft preparation before another action", async () => {
    const h = harness(); await waitFor(() => expect(h.result.current.current).toEqual(view));
    vi.mocked(h.api.prepare).mockRejectedValueOnce(new Error("network timeout"));
    vi.mocked(h.api.get).mockResolvedValue({...view, setup: {...view.setup,
      status: "prepared", formId: "existing-draft", editorPath: "/host/audience/forms/existing-draft"}});
    await act(async () => h.result.current.prepare());
    await waitFor(() => expect(h.result.current.current?.setup.status).toBe("prepared"));
    await act(async () => h.result.current.prepare());
    expect(h.api.prepare).toHaveBeenCalledOnce(); h.unmount();
  });
});
