import {act, render, screen} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {App} from "./App";

const mocks = vi.hoisted(() => ({
  dataMode: vi.fn(),
  getIdTokenResult: vi.fn(),
  onAuthStateChanged: vi.fn(),
  signInWithGoogle: vi.fn(),
  signOutAdmin: vi.fn(),
}));

vi.mock("firebase/auth", () => ({
  getIdTokenResult: mocks.getIdTokenResult,
  onAuthStateChanged: mocks.onAuthStateChanged,
}));

vi.mock("../shared/api/dataMode", () => ({
  dataMode: mocks.dataMode,
}));

vi.mock("../shared/api/firebase", () => ({
  auth: {},
  signInWithGoogle: mocks.signInWithGoogle,
  signOutAdmin: mocks.signOutAdmin,
}));

describe("App live deep-link ownership", () => {
  beforeEach(() => {
    mocks.dataMode.mockReturnValue("live");
    mocks.getIdTokenResult.mockReset();
    mocks.onAuthStateChanged.mockReset();
    mocks.signInWithGoogle.mockReset();
    mocks.signOutAdmin.mockReset();
    window.history.replaceState({}, "", "/overview");
  });

  it("preserves a requested route while Firebase authentication resolves", async () => {
    mocks.onAuthStateChanged.mockImplementation(() => () => undefined);
    window.history.replaceState({}, "", "/safety/reports%2Freport-1");

    render(<App />);

    expect(await screen.findByRole("button", {name: "Sign in with Google"}))
      .not.toBeNull();
    expect(window.location.pathname).toBe("/safety/reports%2Freport-1");
  });

  it("preserves a requested route while admin claims resolve", async () => {
    const user = {email: "admin@catch.local", uid: "admin-uid"};
    let resolveClaims: ((value: {claims: Record<string, unknown>}) => void) |
      null = null;
    mocks.onAuthStateChanged.mockImplementation((
      _auth: unknown,
      callback: (nextUser: typeof user) => void
    ) => {
      callback(user);
      return () => undefined;
    });
    mocks.getIdTokenResult.mockReturnValue(new Promise((resolve) => {
      resolveClaims = resolve;
    }));
    window.history.replaceState({}, "", "/organizers/afterfly");

    render(<App />);

    expect(await screen.findByRole("heading", {name: "Checking admin access"}))
      .not.toBeNull();
    expect(window.location.pathname).toBe("/organizers/afterfly");

    await act(async () => {
      resolveClaims?.({claims: {}});
    });
    expect(await screen.findByRole("heading", {name: "Admin claim required"}))
      .not.toBeNull();
    expect(window.location.pathname).toBe("/organizers/afterfly");
  });
});
