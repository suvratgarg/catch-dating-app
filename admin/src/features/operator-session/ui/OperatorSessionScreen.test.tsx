// @vitest-environment-options {"url":"https://console.example.invalid/operator-session"}
import {act, cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import {OperatorSessionScreen} from "./OperatorSessionScreen";
const mocks = vi.hoisted(() => ({transfer: vi.fn(), authListener: vi.fn()}));
vi.mock("firebase/auth", () => ({getIdTokenResult: vi.fn(), onIdTokenChanged: mocks.authListener}));
vi.mock("../../../shared/api/firebaseCore", () => ({firebaseApp: {options: {projectId: "demo-catch-setup"}}}));
vi.mock("../../../shared/api/firebase", () => ({auth: {app: {options: {projectId: "demo-catch-setup"}}},
  confirmPhoneSignInCode: vi.fn(), requestPhoneSignInCode: vi.fn(), resetPhoneSignIn: vi.fn(),
  signInWithGoogleAdmin: vi.fn(), signOutAdmin: vi.fn()}));
vi.mock("../api/operatorSessionHandoff", async importOriginal => ({
  ...await importOriginal<typeof import("../api/operatorSessionHandoff")>(), transferSession: mocks.transfer,
}));
const origin = "http://127.0.0.1:12345";
const opener = {closed: false, postMessage: vi.fn()} as unknown as Window;
const request = () => ({kind: "catch-operator-session-request", schemaVersion: 1,
  challenge: "a".repeat(64), projectId: "demo-catch-setup", actorUid: "fake-google-actor",
  actorEmailSha256: "b".repeat(64), scopeSha256: "c".repeat(64), sourceSha: "d".repeat(40),
  expiresAtMillis: Date.now() + 300000});
function message(data: unknown, source = opener, eventOrigin = origin) {
  act(() => window.dispatchEvent(new MessageEvent("message", {data, source, origin: eventOrigin})));
}
beforeEach(() => {
  Object.defineProperty(window, "opener", {value: opener, configurable: true});
  vi.mocked(opener.postMessage).mockClear();
  mocks.transfer.mockResolvedValue({kind: "catch-operator-session-transfer", challenge: "a".repeat(64), idToken: "synthetic.private.signature"});
});
afterEach(cleanup);
it("ignores unbound, forged and wrong-project handshakes without exposing an admin workspace", () => {
  render(<OperatorSessionScreen />);
  message(request(), {} as Window); message(request(), opener, "https://evil.invalid");
  message({...request(), projectId: "other-project"}); message({...request(), unexpected: true});
  expect((screen.getByRole("button", {name: "Transfer my current Google session"}) as HTMLButtonElement).disabled).toBe(true);
  expect(opener.postMessage).not.toHaveBeenCalled(); expect(mocks.transfer).not.toHaveBeenCalled();
});
it("binds once to the exact opener/origin, requires a user click and never renders the token", async () => {
  render(<OperatorSessionScreen />); const initial = request(); message(initial);
  expect(opener.postMessage).toHaveBeenCalledExactlyOnceWith({kind: "catch-operator-session-ready", challenge: initial.challenge}, origin);
  expect(mocks.transfer).not.toHaveBeenCalled();
  message({...initial, actorUid: "other"}); expect(screen.queryByText(/Account: other/u)).toBeNull();
  fireEvent.click(screen.getByRole("button", {name: "Transfer my current Google session"}));
  await waitFor(() => expect(opener.postMessage).toHaveBeenCalledTimes(2));
  expect(opener.postMessage).toHaveBeenLastCalledWith({kind: "catch-operator-session-transfer", challenge: initial.challenge, idToken: "synthetic.private.signature"}, origin);
  expect(document.body.textContent).not.toContain("synthetic.private.signature");
  fireEvent.click(screen.getByRole("button", {name: "Transfer my current Google session"})); expect(mocks.transfer).toHaveBeenCalledOnce();
});
it.each(["cancel", "unmount", "opener"])("prevents a pending transfer after %s", async drift => {
  let resolve!: (value: unknown) => void;
  mocks.transfer.mockReturnValue(new Promise(r => {resolve = r;}));
  const view = render(<OperatorSessionScreen />); message(request());
  fireEvent.click(screen.getByRole("button", {name: "Transfer my current Google session"}));
  const isCurrent = mocks.transfer.mock.calls[0]![2] as () => boolean;
  if (drift === "cancel") message({kind: "catch-operator-session-cancel", challenge: "a".repeat(64)});
  if (drift === "unmount") view.unmount();
  if (drift === "opener") Object.defineProperty(window, "opener", {value: {} as Window, configurable: true});
  expect(isCurrent()).toBe(false);
  // The real exporter checks this predicate before returning a token.
  await act(async () => resolve(undefined));
  expect(opener.postMessage).toHaveBeenCalledTimes(1);
});
it("uses fixed error text even when an SDK failure contains a token", async () => {
  mocks.transfer.mockRejectedValue(new Error("synthetic.private.signature"));
  render(<OperatorSessionScreen />); message(request());
  fireEvent.click(screen.getByRole("button", {name: "Transfer my current Google session"}));
  await screen.findByText(/Use Catch’s normal Google sign-in UI/u);
  expect(document.body.textContent).not.toContain("synthetic.private.signature");
  expect(opener.postMessage).toHaveBeenCalledTimes(1);
});
it("does not claim an already transferred session was undone by Cancel", async () => {
  render(<OperatorSessionScreen />); message(request());
  fireEvent.click(screen.getByRole("button", {name: "Transfer my current Google session"}));
  await screen.findByText(/Session transferred to the selected local helper/u);
  fireEvent.click(screen.getByRole("button", {name: "Cancel"}));
  expect(screen.getByText(/Cancellation requested. Check the local helper/u)).not.toBeNull();
  expect(opener.postMessage).toHaveBeenLastCalledWith({kind: "catch-operator-session-cancel", challenge: "a".repeat(64)}, origin);
});
it("retains cancellation status when a pending SDK request rejects later", async () => {
  let reject!: (reason: Error) => void;
  mocks.transfer.mockReturnValue(new Promise((_resolve, r) => {reject = r;}));
  render(<OperatorSessionScreen />); message(request());
  fireEvent.click(screen.getByRole("button", {name: "Transfer my current Google session"}));
  fireEvent.click(screen.getByRole("button", {name: "Cancel"}));
  await act(async () => reject(new Error("synthetic.private.signature")));
  expect(screen.getByText(/Cancellation requested. Check the local helper/u)).not.toBeNull();
  expect(document.body.textContent).not.toContain("synthetic.private.signature");
  expect(opener.postMessage).toHaveBeenCalledTimes(2);
});
