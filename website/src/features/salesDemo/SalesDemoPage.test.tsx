import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {BrowserRouter, Route, Routes} from "react-router";
import {afterEach, describe, expect, it, vi} from "vitest";
import type {SalesDemoAuth} from "./salesDemoAuth";
import type {SalesDemoApi, SalesDemoPreview, SalesDemoSession} from
  "./salesDemoModel";
import {SalesDemoPage} from "./SalesDemoPage";

const grant = "A".repeat(43);
const preview: SalesDemoPreview = {schemaVersion: 1, synthetic: true,
  invitationId: "invite-1", interactiveAvailable: true,
  expiresAt: "2099-01-01T00:00:00.000Z",
  notice: "Sample workflow only. No real messages, charges or admission.",
  preview: {brandName: "Sample Host", headline: "A private sample",
    scenario: "Try a synthetic application", steps: ["Review", "Reply", "Admit"],
    retainedTools: ["Current booking tool"], limitations: ["No real sends"],
    cta: "Try sample"}};

describe("private demo landing", () => {
  afterEach(() => {cleanup(); window.history.replaceState(null, "", "/");});

  it("removes the fragment and leaves the anonymous preview read-only", async () => {
    window.history.replaceState(null, "", `/demo/invite-1#grant=${grant}`);
    const api: SalesDemoApi = {preview: vi.fn().mockResolvedValue(preview),
      start: vi.fn().mockResolvedValue({} as SalesDemoSession),
      getSession: vi.fn(), advance: vi.fn()};
    const auth: SalesDemoAuth = {watch: (callback) => {
      callback({uid: "user-one", email: "host@example.test", emailVerified: true,
        phoneNumber: null}); return () => undefined;},
    signInGoogle: vi.fn(), beginPhone: vi.fn()};
    const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
    render(<QueryClientProvider client={client}><BrowserRouter><Routes>
      <Route path="/demo/:invitationId" element={<SalesDemoPage api={api} auth={auth} />} />
    </Routes></BrowserRouter></QueryClientProvider>);
    await waitFor(() => expect(screen.getByText("A private sample")).toBeTruthy());
    expect(window.location.hash).toBe("");
    expect(api.preview).toHaveBeenCalledWith({invitationId: "invite-1"});
    expect(api.start).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("button", {name: "Open interactive example"}));
    await waitFor(() => expect(api.start).toHaveBeenCalledWith({
      invitationId: "invite-1", grantToken: grant, requestId: expect.any(String),
    }));
  });

  it("lets a verified account change identity and retry without losing the grant", async () => {
    window.history.replaceState(null, "", `/demo/invite-1#grant=${grant}`);
    const api: SalesDemoApi = {preview: vi.fn().mockResolvedValue(preview),
      start: vi.fn().mockRejectedValue(new Error("permission-denied")),
      getSession: vi.fn(), advance: vi.fn()};
    let updateViewer: Parameters<SalesDemoAuth["watch"]>[0] = () => undefined;
    const auth: SalesDemoAuth = {watch: (callback) => {
      updateViewer = callback;
      callback({uid: "wrong-user", email: "wrong@example.test", emailVerified: true,
        phoneNumber: null}); return () => undefined;},
    signInGoogle: vi.fn(async () => updateViewer({uid: "invited-user",
      email: "invited@example.test", emailVerified: true, phoneNumber: null})),
    beginPhone: vi.fn()};
    const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
    render(<QueryClientProvider client={client}><BrowserRouter><Routes>
      <Route path="/demo/:invitationId" element={<SalesDemoPage api={api} auth={auth} />} />
    </Routes></BrowserRouter></QueryClientProvider>);
    fireEvent.click(await screen.findByRole("button", {name: "Open interactive example"}));
    await screen.findByText(/This account does not match/);
    fireEvent.click(screen.getByRole("button", {name: "Use another Google account"}));
    await waitFor(() => expect(auth.signInGoogle).toHaveBeenCalledOnce());
    await screen.findByText(/invited@example.test/);
    fireEvent.click(screen.getByRole("button", {name: "Open interactive example"}));
    await waitFor(() => expect(api.start).toHaveBeenCalledTimes(2));
    const calls = vi.mocked(api.start).mock.calls;
    expect(calls[1][0].grantToken).toBe(grant);
    expect(calls[1][0].requestId).not.toBe(calls[0][0].requestId);
    expect(window.location.hash).toBe("");
    expect(screen.getByLabelText("Or verify phone (international format)")).toBeTruthy();
  });

  it("recovers an expired SMS challenge in place without sending automatically", async () => {
    window.history.replaceState(null, "", `/demo/invite-1#grant=${grant}`);
    const challenge = {confirm: vi.fn().mockRejectedValue(new Error("auth/code-expired")),
      clear: vi.fn()};
    const api: SalesDemoApi = {preview: vi.fn().mockResolvedValue(preview),
      start: vi.fn(), getSession: vi.fn(), advance: vi.fn()};
    const auth: SalesDemoAuth = {watch: (callback) => {
      callback(null); return () => undefined;}, signInGoogle: vi.fn(),
    beginPhone: vi.fn().mockResolvedValue(challenge)};
    const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
    render(<QueryClientProvider client={client}><BrowserRouter><Routes>
      <Route path="/demo/:invitationId" element={<SalesDemoPage api={api} auth={auth} />} />
    </Routes></BrowserRouter></QueryClientProvider>);
    fireEvent.change(await screen.findByLabelText("Or verify phone (international format)"),
      {target: {value: "+15555550123"}});
    fireEvent.click(screen.getByRole("button", {name: "Send verification code"}));
    fireEvent.change(await screen.findByLabelText("Verification code"),
      {target: {value: "123456"}});
    fireEvent.click(screen.getByRole("button", {name: "Verify phone"}));
    await screen.findByText(/That verification code could not be confirmed/);
    fireEvent.click(screen.getByRole("button", {name: "Change number or resend code"}));
    expect(challenge.clear).toHaveBeenCalledOnce();
    expect(auth.beginPhone).toHaveBeenCalledOnce();
    fireEvent.click(screen.getByRole("button", {name: "Send verification code"}));
    await waitFor(() => expect(auth.beginPhone).toHaveBeenCalledTimes(2));
    expect(api.start).not.toHaveBeenCalled();
    expect(window.location.hash).toBe("");
  });
});
