import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {describe, expect, it, vi} from "vitest";
import type {SalesDemoAuth, SalesDemoViewer} from "./salesDemoAuth";
import type {SalesDemoApi, SalesDemoPreview, SalesDemoSession, SalesDemoSetup} from
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
const completed: SalesDemoSession = {...session, status: "completed",
  step: "complete", revision: 4, allowedActions: []};
const readySetup: SalesDemoSetup = {schemaVersion: 1,
  setupHash: "a".repeat(64), organizerId: "organizer-1", formId: null,
  editorPath: null, publicationAuthority: false, status: "ready",
  plan: {mode: "template", requirements: ["Review your draft"],
    templateId: "basic", templateVersion: 1, templateHash: "b".repeat(64),
    materializerVersion: 1, title: "Example form"}};

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
      application: {...session.application, review: "approved"}}),
    getSetup: vi.fn().mockResolvedValue(readySetup),
    prepareSetup: vi.fn().mockResolvedValue({...readySetup,
      status: "prepared", formId: "demo_123",
      editorPath: "/host/audience/forms/demo_123"})};
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

  it("requires a completed session and explicit setup read before preparing", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.canTry).toBe(true));
    await act(async () => h.result.current.start());
    await act(async () => h.result.current.readSetup());
    expect(h.api.getSetup).not.toHaveBeenCalled();
    expect(h.api.prepareSetup).not.toHaveBeenCalled();
    vi.mocked(h.api.getSession).mockResolvedValue(completed);
    await act(async () => h.result.current.refresh());
    await act(async () => h.result.current.readSetup());
    expect(h.result.current.setup?.status).toBe("ready");
    await act(async () => h.result.current.prepareSetup());
    expect(h.api.prepareSetup).toHaveBeenCalledWith({sessionId: "session-1",
      grantToken, setupHash: readySetup.setupHash});
    expect(h.result.current.setup?.status).toBe("prepared");
    h.unmount();
  });

  it("clears a reviewed setup on viewer change and ignores a late read", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.canTry).toBe(true));
    vi.mocked(h.api.start).mockResolvedValue(completed);
    await act(async () => h.result.current.start());
    let completeRead!: (value: SalesDemoSetup) => void;
    vi.mocked(h.api.getSetup).mockImplementation(() => new Promise((resolve) => {
      completeRead = resolve;
    }));
    let pending!: Promise<void>;
    act(() => {pending = h.result.current.readSetup();});
    await waitFor(() => expect(h.api.getSetup).toHaveBeenCalledOnce());
    h.setViewer({...verified, uid: "another-user"});
    completeRead(readySetup);
    await act(async () => pending);
    expect(h.result.current.setup).toBeNull();
    expect(h.result.current.setupFresh).toBe(false);
    h.unmount();
  });

  it("reads current setup after uncertain prepare and does not create twice", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.canTry).toBe(true));
    vi.mocked(h.api.start).mockResolvedValue(completed);
    await act(async () => h.result.current.start());
    await act(async () => h.result.current.readSetup());
    vi.mocked(h.api.prepareSetup).mockRejectedValueOnce(new Error("network timeout"));
    vi.mocked(h.api.getSetup).mockResolvedValueOnce({...readySetup,
      status: "prepared", formId: "demo_123",
      editorPath: "/host/audience/forms/demo_123"});
    await act(async () => h.result.current.prepareSetup());
    expect(h.result.current.setup?.status).toBe("prepared");
    expect(h.api.prepareSetup).toHaveBeenCalledOnce();
    h.unmount();
  });
});
