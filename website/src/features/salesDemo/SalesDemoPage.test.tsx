import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {fireEvent, render, screen, waitFor} from "@testing-library/react";
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
  afterEach(() => window.history.replaceState(null, "", "/"));

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
});
