import {act, cleanup, render, screen, waitFor} from "@testing-library/react";
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

vi.mock("../features/marketing/ui/MarketingOpsScreen", async () => {
  const {useState} = await import("react");
  const {AdminButton, AdminTextField} = await import(
    "../shared/ui/AdminPrimitives"
  );
  return {
    MarketingOpsScreen: ({
      onTabChange,
      onUnsavedChangesChange,
    }: {
      onTabChange: (tab: "posts") => void;
      onUnsavedChangesChange: (dirty: boolean) => void;
    }) => {
      const [caption, setCaption] = useState("Original caption");
      return (
        <section aria-label="Marketing fixture">
          <AdminTextField
            label="Draft caption"
            value={caption}
            onChange={(value) => {
              setCaption(value);
              onUnsavedChangesChange(true);
            }}
          />
          <AdminButton onClick={() => onTabChange("posts")}>Posts within Marketing</AdminButton>
        </section>
      );
    },
  };
});

vi.mock("../features/overview/ui/OverviewRouteScreen", () => ({
  OverviewRouteScreen: () => <p>Overview fixture</p>,
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

describe("Marketing unsaved route transitions", () => {
  afterEach(() => {
    cleanup();
    vi.restoreAllMocks();
  });

  beforeEach(() => {
    mocks.dataMode.mockReturnValue("sample");
    window.history.replaceState({}, "", "/marketing/drafts/sample-draft/source");
  });

  it("keeps edited input after cancellation, then leaves after discard confirmation", async () => {
    const user = userEvent.setup();
    const confirm = vi.spyOn(window, "confirm").mockReturnValueOnce(false)
      .mockReturnValueOnce(true);
    render(<App />);
    const caption = await screen.findByRole("textbox", {name: "Draft caption"});
    await user.type(caption, " updated");

    await user.click(screen.getByRole("button", {name: "Overview"}));
    await waitFor(() => expect(confirm).toHaveBeenCalledTimes(1));
    expect(window.location.pathname).toBe("/marketing/drafts/sample-draft/source");
    expect((caption as HTMLInputElement).value).toBe("Original caption updated");

    await user.click(screen.getByRole("button", {name: "Posts within Marketing"}));
    expect(window.location.pathname).toBe("/marketing/posts");
    expect(confirm).toHaveBeenCalledTimes(1);
    expect((caption as HTMLInputElement).value).toBe("Original caption updated");

    await user.click(screen.getByRole("button", {name: "Overview"}));
    await waitFor(() => expect(screen.getByText("Overview fixture")).not.toBeNull());
    expect(confirm).toHaveBeenCalledTimes(2);
    expect(window.location.pathname).toBe("/overview");
  });

  it("guards browser Back and preserves the draft when cancelled", async () => {
    const user = userEvent.setup();
    const confirm = vi.spyOn(window, "confirm").mockReturnValueOnce(false)
      .mockReturnValueOnce(true);
    window.history.replaceState({}, "", "/overview");
    render(<App />);
    await user.click(screen.getByRole("button", {name: "Marketing"}));
    const caption = await screen.findByRole("textbox", {name: "Draft caption"});
    await user.type(caption, " updated");

    act(() => window.history.back());
    await waitFor(() => expect(confirm).toHaveBeenCalledTimes(1));
    await waitFor(() => expect(window.location.pathname).toBe("/marketing"));
    expect((caption as HTMLInputElement).value).toBe("Original caption updated");

    act(() => window.history.back());
    await waitFor(() => expect(screen.getByText("Overview fixture")).not.toBeNull());
    expect(confirm).toHaveBeenCalledTimes(2);
    expect(window.location.pathname).toBe("/overview");
  });

  it("guards browser Forward after returning to Marketing with a clean draft", async () => {
    const user = userEvent.setup();
    const confirm = vi.spyOn(window, "confirm").mockReturnValue(false);
    window.history.replaceState({}, "", "/marketing");
    render(<App />);
    await screen.findByRole("textbox", {name: "Draft caption"});
    await user.click(screen.getByRole("button", {name: "Overview"}));
    await waitFor(() => expect(window.location.pathname).toBe("/overview"));
    expect(confirm).not.toHaveBeenCalled();

    act(() => window.history.back());
    const caption = await screen.findByRole("textbox", {name: "Draft caption"});
    await user.type(caption, " updated");
    act(() => window.history.forward());
    await waitFor(() => expect(confirm).toHaveBeenCalledTimes(1));
    await waitFor(() => expect(window.location.pathname).toBe("/marketing"));
    expect((caption as HTMLInputElement).value).toBe("Original caption updated");
  });
});
