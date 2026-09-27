import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {describe, expect, it, vi} from "vitest";
import type {SalesDemoAuth, SalesDemoViewer} from "./salesDemoAuth";
import type {SalesDemoApi, SalesDemoPreview, SalesDemoSession} from
  "./salesDemoModel";
import {useSalesDemoController} from "./useSalesDemoController";

const grantToken = "A".repeat(43);
const preview: SalesDemoPreview = {schemaVersion: 1, synthetic: true,
  invitationId: "invite-1", expiresAt: "2099-01-01T00:00:00.000Z",
  interactiveAvailable: true,
  notice: "Sample workflow only. No real messages, charges or admission.",
  preview: {brandName: "Example Host", headline: "Sample workflow",
    scenario: "Review a sample application", steps: ["Review", "Reply", "Admit"],
    retainedTools: [], limitations: [], cta: "Try it"}};
const session: SalesDemoSession = {schemaVersion: 1, synthetic: true,
  sessionId: "session-1", invitationId: "invite-1", blueprintId: "blueprint-1",
  blueprintRevision: 1, createdAt: "2026-09-28T00:00:00.000Z",
  expiresAt: "2099-01-01T00:00:00.000Z", status: "active", revision: 1,
  actionCount: 0, step: "application",
  allowedActions: ["reviewApplication", "prepareReply", "admitGuest",
    "requestAssistance"],
  application: {applicantName: "Sample Applicant",
    request: "Sample event application", review: "pending"},
  reply: {status: "none", template: "none"},
  guest: {status: "not_admitted", displayName: "Sample Applicant"},
  assistanceRequested: false};
const verified: SalesDemoViewer = {uid: "user-one", email: "owner@example.test",
  emailVerified: true, phoneNumber: null};

function harness(token: string | null = grantToken) {
  let authCallback: (viewer: SalesDemoViewer | null) => void = () => undefined;
  const auth: SalesDemoAuth = {
    watch: (callback) => {authCallback = callback; callback(verified);
      return () => undefined;},
    signInGoogle: vi.fn(), beginPhone: vi.fn(),
  };
  const api: SalesDemoApi = {preview: vi.fn().mockResolvedValue(preview),
    start: vi.fn().mockResolvedValue(session),
    getSession: vi.fn().mockResolvedValue(session),
    advance: vi.fn().mockResolvedValue({...session, revision: 2, step: "reply",
      application: {...session.application, review: "approved"}})};
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  const hook = renderHook(() => useSalesDemoController({
    invitationId: "invite-1", grantToken: token, api, auth,
  }), {wrapper});
  return {...hook, client, api, setViewer: (viewer: SalesDemoViewer | null) =>
    act(() => authCallback(viewer))};
}

describe("private Sales demo controller", () => {
  it("fetches a safe preview without materializing a session or caching the grant", async () => {
    const h = harness(null);
    await waitFor(() => expect(h.result.current.preview.data).toEqual(preview));
    expect(h.api.start).not.toHaveBeenCalled();
    expect(h.result.current.canTry).toBe(false);
    expect(JSON.stringify(h.client.getQueryCache().getAll().map((query) =>
      [query.queryKey, query.state]))).not.toContain(grantToken);
    h.unmount();
  });

  it("starts only on an explicit tap and reuses the request after uncertain failure", async () => {
    const h = harness();
    vi.mocked(h.api.start).mockRejectedValueOnce(new Error("network timeout"));
    await waitFor(() => expect(h.result.current.canTry).toBe(true));
    expect(h.api.start).not.toHaveBeenCalled();
    await act(async () => h.result.current.start());
    expect(h.result.current.session).toBeNull();
    await act(async () => h.result.current.start());
    expect(h.api.start).toHaveBeenCalledTimes(2);
    expect(vi.mocked(h.api.start).mock.calls[1][0].requestId)
      .toBe(vi.mocked(h.api.start).mock.calls[0][0].requestId);
    expect(h.result.current.session).toEqual(session);
    h.unmount();
  });

  it("reconciles an uncertain action and holds a different choice", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.canTry).toBe(true));
    await act(async () => h.result.current.start());
    vi.mocked(h.api.advance).mockRejectedValueOnce(new Error("network timeout"));
    await act(async () => h.result.current.advance({
      action: "reviewApplication", choice: "approve"}));
    expect(h.result.current.retryAction).toEqual({
      action: "reviewApplication", choice: "approve"});
    await act(async () => h.result.current.advance({
      action: "reviewApplication", choice: "needs_info"}));
    expect(h.api.advance).toHaveBeenCalledTimes(1);
    await act(async () => h.result.current.advance({
      action: "reviewApplication", choice: "approve"}));
    expect(h.api.advance).toHaveBeenCalledTimes(2);
    expect(vi.mocked(h.api.advance).mock.calls[1][0].requestId)
      .toBe(vi.mocked(h.api.advance).mock.calls[0][0].requestId);
    expect(h.result.current.session?.step).toBe("reply");
    expect(JSON.stringify(h.client.getMutationCache().getAll().map((mutation) =>
      mutation.state))).not.toContain(grantToken);
    h.unmount();
  });

  it("discards private session state when the signed-in identity changes", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.canTry).toBe(true));
    await act(async () => h.result.current.start());
    h.setViewer({...verified, uid: "other-user"});
    expect(h.result.current.session).toBeNull();
    expect(h.result.current.fresh).toBe(false);
    h.unmount();
  });
});
