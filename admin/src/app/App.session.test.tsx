import {act, cleanup, render, screen, waitFor} from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import type {User} from "firebase/auth";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {sampleHostAnalytics, sampleOverview} from "../shared/api/sampleData";
import {App} from "./App";

const mocks = vi.hoisted(() => ({
  getIdTokenResult: vi.fn(), onIdTokenChanged: vi.fn(), signOutAdmin: vi.fn(),
  loadFinanceOverview: vi.fn(), loadFinanceHostAnalytics: vi.fn(),
}));
vi.mock("firebase/auth", () => ({
  getIdTokenResult: mocks.getIdTokenResult, onIdTokenChanged: mocks.onIdTokenChanged,
}));
vi.mock("../shared/api/dataMode", () => ({dataMode: () => "live"}));
vi.mock("../shared/api/firebase", () => ({
  auth: {}, signOutAdmin: mocks.signOutAdmin, resetPhoneSignIn: vi.fn(),
  confirmPhoneSignInCode: vi.fn(), requestPhoneSignInCode: vi.fn(),
}));
vi.mock("../features/finance/api/financeOpsRepository", () => ({
  loadFinanceOverview: mocks.loadFinanceOverview,
  loadFinanceHostAnalytics: mocks.loadFinanceHostAnalytics,
  loadMessagingBudgetReview: vi.fn(), recordMessagingBudgetDecision: vi.fn(),
  stageApprovedMessagingBudget: vi.fn(), loadOrganizerEntitlement: vi.fn(),
  grantOrganizerEntitlement: vi.fn(), revokeOrganizerEntitlementGrant: vi.fn(),
}));
vi.mock("../features/overview/ui/OverviewRouteScreen", () => ({
  OverviewRouteScreen: () => <p>Permitted overview</p>,
}));

const owner = {uid: "owner", email: "owner@example.invalid"} as User;
const finance = {uid: "finance", email: "finance@example.invalid"} as User;
const eventTitle = sampleHostAnalytics.topEvents[0]!.title;
const paymentTitle = sampleOverview.queues.paymentIssues[0]!.title;
let tokenChanged: (user: User | null) => void;

afterEach(cleanup);
beforeEach(() => {
  window.history.replaceState({}, "", "/finance");
  window.sessionStorage.clear();
  mocks.onIdTokenChanged.mockImplementation((_auth, callback) => {
    tokenChanged = callback;
    callback(owner);
    return vi.fn();
  });
  mocks.getIdTokenResult.mockResolvedValue({claims: {adminOwner: true}});
  mocks.loadFinanceOverview.mockResolvedValue(sampleOverview);
  mocks.loadFinanceHostAnalytics.mockResolvedValue(sampleHostAnalytics);
  mocks.signOutAdmin.mockImplementation(async () => { tokenChanged(null); });
});

describe("App with real Finance controllers and session cache", () => {
  it("drops owner data before sign-out completes, then loads only the next identity's allowed sources", async () => {
    const user = userEvent.setup();
    render(<App />);
    await screen.findByText(eventTitle);
    const neverCompletes = new Promise<void>(() => undefined);
    mocks.signOutAdmin.mockReturnValue(neverCompletes);
    await user.click(screen.getByText(owner.email!));
    await user.click(screen.getByRole("button", {name: "Sign out"}));
    expect(screen.queryByText(eventTitle)).toBeNull();
    expect(screen.getByRole("textbox", {name: "Phone number"})).not.toBeNull();

    mocks.getIdTokenResult.mockResolvedValue({claims: {finance: true}});
    const financeOverview = {
      ...sampleOverview,
      queues: {...sampleOverview.queues, paymentIssues: []},
    };
    mocks.loadFinanceOverview.mockResolvedValue(financeOverview);
    act(() => tokenChanged(finance));
    await screen.findByRole("heading", {name: "Finance"});
    await waitFor(() => expect(mocks.loadFinanceOverview).toHaveBeenCalledTimes(2));
    expect(mocks.loadFinanceHostAnalytics).toHaveBeenCalledOnce();
    expect(screen.queryByText(eventTitle)).toBeNull();
    expect(screen.queryByText(paymentTitle)).toBeNull();
    await user.click(screen.getByText("Source status, scope, and authority boundary"));
    expect(screen.getByText("Your Finance role can manage messaging budgets without host analytics access.")).not.toBeNull();
    await user.click(screen.getByRole("button", {name: "Overview"}));
    await screen.findByText("Permitted overview");
  });

  it("removes cached owner data during same-UID claim resolution and after a failed new query", async () => {
    render(<App />);
    await screen.findByText(eventTitle);
    let resolveClaims!: (value: {claims: {finance: boolean}}) => void;
    mocks.getIdTokenResult.mockReturnValue(new Promise((resolve) => { resolveClaims = resolve; }));
    mocks.loadFinanceOverview.mockRejectedValue(new Error("new session unavailable"));
    act(() => tokenChanged(owner));
    expect(screen.queryByText(eventTitle)).toBeNull();
    expect(screen.queryByText(paymentTitle)).toBeNull();
    expect(screen.getByRole("heading", {name: "Checking admin access"})).not.toBeNull();
    await act(async () => { resolveClaims({claims: {finance: true}}); });
    await screen.findByText("Finance sources unavailable", {}, {timeout: 2500});
    expect(screen.queryByText(eventTitle)).toBeNull();
    expect(screen.queryByText(paymentTitle)).toBeNull();
    expect(mocks.loadFinanceHostAnalytics).toHaveBeenCalledOnce();
  });

  it("cannot restore data when an old non-abortable analytics request finishes after revocation", async () => {
    let complete!: (value: typeof sampleHostAnalytics) => void;
    mocks.loadFinanceHostAnalytics.mockReturnValue(new Promise((resolve) => { complete = resolve; }));
    render(<App />);
    await waitFor(() => expect(mocks.loadFinanceHostAnalytics).toHaveBeenCalledOnce());
    mocks.getIdTokenResult.mockResolvedValue({claims: {finance: true}});
    act(() => tokenChanged(owner));
    await screen.findByRole("heading", {name: "Finance"});
    await act(async () => { complete(sampleHostAnalytics); });
    expect(screen.queryByText(eventTitle)).toBeNull();
    expect(mocks.loadFinanceHostAnalytics).toHaveBeenCalledOnce();
    await screen.findByText(paymentTitle);
  });
});
