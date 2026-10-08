// @vitest-environment-options {"url":"https://console.example.invalid/operator-session"}
import {StrictMode} from "react";
import {act, cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import {OperatorSessionScreen} from "./OperatorSessionScreen";
const mocks = vi.hoisted(() => ({transfer: vi.fn(), take: vi.fn(), bootstrap: vi.fn(), post: vi.fn(), request: vi.fn(), unload: vi.fn()}));
vi.mock("../../../shared/api/firebase", () => ({auth: {app: {options: {projectId: "demo-catch-setup"}}}}));
vi.mock("../api/operatorSessionHandoff", () => ({transferSession: mocks.transfer}));
vi.mock("../api/operatorSessionTransport", () => ({takeSessionLaunch: mocks.take,
  createSessionTransport: () => ({bootstrap: mocks.bootstrap, post: mocks.post, cancelOnUnload: mocks.unload}), sessionRequest: mocks.request}));
const launch = {serverEncryptionKey: "fake-original-encryption-key", serverSigningKey: "fake-original-signing-key", challenge: "a".repeat(64), sourceSha: "b".repeat(40), expiresAtMillis: Date.now() + 300000};
const initial = {csrf: "c".repeat(64), profile: {synthetic: true}, runtime: {sourceSha: launch.sourceSha, executionSha256: "d".repeat(64)}, home: "/fake/owner-only/home"};
const request = {...launch, projectId: "demo-catch-setup", actorUid: "fake-google-actor", scopeSha256: "e".repeat(64)};
beforeEach(() => {
  mocks.take.mockReturnValue(launch); mocks.bootstrap.mockResolvedValue(initial); mocks.request.mockImplementation(value => value);
  mocks.post.mockImplementation(async route => route === "/configure" ? {request} : route === "/cancel" ? {state: "cancelled"} : {state: "saved", expiresAtMillis: Date.now() + 3600000});
  mocks.transfer.mockResolvedValue({challenge: launch.challenge, sealedSession: {ciphertext: "opaque", wrappedKey: "opaque", iv: "opaque"}});
});
afterEach(cleanup);
async function configure() {
  await screen.findByRole("button", {name: "Validate configuration"});
  fireEvent.click(screen.getByRole("button", {name: "Validate configuration"}));
  await screen.findByText(/Google account: fake-google-actor/u);
}
it("requires owner-private launch material and never requests a token on page load", () => {
  mocks.take.mockReturnValue(null); render(<OperatorSessionScreen />);
  expect((screen.getByRole("button", {name: "Save my current Google session"}) as HTMLButtonElement).disabled).toBe(true);
  expect(mocks.bootstrap).not.toHaveBeenCalled(); expect(mocks.transfer).not.toHaveBeenCalled();
});
it("bootstraps once under StrictMode and saves only after configuration and an explicit click", async () => {
  render(<StrictMode><OperatorSessionScreen /></StrictMode>); await configure();
  expect(mocks.bootstrap).toHaveBeenCalledOnce(); expect(mocks.transfer).not.toHaveBeenCalled();
  fireEvent.click(screen.getByRole("button", {name: "Save my current Google session"}));
  await screen.findByText(/Session saved. It expires at/u);
  expect(mocks.transfer).toHaveBeenCalledOnce();
  expect(mocks.post).toHaveBeenLastCalledWith("/session", {challenge: launch.challenge, sealedSession: {ciphertext: "opaque", wrappedKey: "opaque", iv: "opaque"}}, initial.csrf);
  fireEvent.click(screen.getByRole("button", {name: "Save my current Google session"})); expect(mocks.transfer).toHaveBeenCalledOnce();
});
it.each(["serverEncryptionKey", "serverSigningKey", "challenge", "sourceSha", "expiresAtMillis", "projectId"])("rejects configure response drift in %s", async field => {
  mocks.post.mockResolvedValue({request: {...request, [field]: "replacement"}});
  render(<OperatorSessionScreen />); await screen.findByRole("button", {name: "Validate configuration"});
  fireEvent.click(screen.getByRole("button", {name: "Validate configuration"}));
  await screen.findByText(/Configuration unavailable/u); expect(mocks.transfer).not.toHaveBeenCalled();
});
it.each(["cancel", "unmount"])("stops a pending token export after %s", async drift => {
  let reject!: (error: Error) => void;
  mocks.transfer.mockReturnValue(new Promise((_resolve, r) => {reject = r;}));
  const view = render(<OperatorSessionScreen />); await configure();
  fireEvent.click(screen.getByRole("button", {name: "Save my current Google session"}));
  const isCurrent = mocks.transfer.mock.calls[0]![2] as () => boolean;
  if (drift === "cancel") fireEvent.click(screen.getByRole("button", {name: "Cancel"})); else view.unmount();
  expect(isCurrent()).toBe(false);
  await act(async () => reject(new Error("synthetic.private.signature")));
  expect(mocks.post.mock.calls.some(call => call[0] === "/session")).toBe(false);
  if (drift === "cancel") await screen.findByText(/Cancelled. The helper confirmed/u);
  expect(document.body.textContent).not.toContain("synthetic.private.signature");
});
it("a lost save receipt reports an unknown outcome and never retries", async () => {
  mocks.post.mockImplementation(async route => {if (route === "/session") throw new Error("synthetic.private.signature"); return {request};});
  render(<OperatorSessionScreen />); await configure();
  fireEvent.click(screen.getByRole("button", {name: "Save my current Google session"}));
  await screen.findByText(/Session or save status unconfirmed/u);
  expect(document.body.textContent).not.toContain("synthetic.private.signature");
  fireEvent.click(screen.getByRole("button", {name: "Save my current Google session"})); expect(mocks.transfer).toHaveBeenCalledOnce();
});
it("allows cancellation while save verification is pending and reports an already committed save accurately", async () => {
  let resolve!: (value: unknown) => void;
  mocks.post.mockImplementation(async route => route === "/configure" ? {request} : route === "/cancel" ? {state: "saved"} : new Promise(r => {resolve = r;}));
  render(<OperatorSessionScreen />); await configure(); fireEvent.click(screen.getByRole("button", {name: "Save my current Google session"}));
  await waitFor(() => expect(mocks.post.mock.calls.some(call => call[0] === "/session")).toBe(true));
  fireEvent.click(screen.getByRole("button", {name: "Cancel"}));
  await screen.findByText(/The session was already saved/u);
  await act(async () => resolve({state: "saved", expiresAtMillis: Date.now() + 3600000}));
  expect(screen.getByText(/The session was already saved/u)).not.toBeNull();
});
