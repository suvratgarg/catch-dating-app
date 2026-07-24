import {act, cleanup, render, screen} from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {App} from "./App";

const mocks = vi.hoisted(() => ({
  dataMode: vi.fn(),
  getIdTokenResult: vi.fn(),
  onAuthStateChanged: vi.fn(),
  confirmPhoneSignInCode: vi.fn(),
  requestPhoneSignInCode: vi.fn(),
  resetPhoneSignIn: vi.fn(),
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
  confirmPhoneSignInCode: mocks.confirmPhoneSignInCode,
  requestPhoneSignInCode: mocks.requestPhoneSignInCode,
  resetPhoneSignIn: mocks.resetPhoneSignIn,
  signOutAdmin: mocks.signOutAdmin,
}));

describe("App live deep-link ownership", () => {
  afterEach(cleanup);

  beforeEach(() => {
    mocks.dataMode.mockReturnValue("live");
    mocks.getIdTokenResult.mockReset();
    mocks.onAuthStateChanged.mockReset();
    mocks.confirmPhoneSignInCode.mockReset();
    mocks.requestPhoneSignInCode.mockReset();
    mocks.resetPhoneSignIn.mockReset();
    mocks.signOutAdmin.mockReset();
    window.history.replaceState({}, "", "/overview");
  });

  it("supports only phone OTP and completes the sign-in flow", async () => {
    const user = userEvent.setup();
    mocks.onAuthStateChanged.mockImplementation(() => () => undefined);
    mocks.requestPhoneSignInCode.mockResolvedValue(undefined);
    mocks.confirmPhoneSignInCode.mockResolvedValue(undefined);

    render(<App />);

    expect(screen.queryByRole("button", {name: "Sign in with Google"}))
      .toBeNull();
    await user.type(
      screen.getByRole("textbox", {name: "Phone number"}),
      "+91 90000 00000"
    );
    await user.click(screen.getByRole("button", {
      name: "Send verification code",
    }));

    expect(mocks.requestPhoneSignInCode).toHaveBeenCalledWith("+919000000000");
    await user.type(
      await screen.findByRole("textbox", {name: "Verification code"}),
      "123456"
    );
    await user.click(screen.getByRole("button", {name: "Verify and sign in"}));

    expect(mocks.confirmPhoneSignInCode).toHaveBeenCalledWith("123456");
    expect(await screen.findByRole("textbox", {name: "Phone number"}))
      .not.toBeNull();
  });

  it("preserves a requested route while Firebase authentication resolves", async () => {
    mocks.onAuthStateChanged.mockImplementation(() => () => undefined);
    window.history.replaceState({}, "", "/safety/reports%2Freport-1");

    render(<App />);

    expect(await screen.findByRole("button", {name: "Send verification code"}))
      .not.toBeNull();
    expect(screen.queryByRole("button", {name: "Sign in with Google"}))
      .toBeNull();
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
