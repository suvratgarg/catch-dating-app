// @vitest-environment-options {"url":"https://console.example.invalid/operator-session"}
import {cleanup, render, screen} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {App} from "./App";
const mocks = vi.hoisted(() => ({session: vi.fn(), getIdTokenResult: vi.fn()}));
vi.mock("./useAdminSession", () => ({useAdminSession: mocks.session}));
vi.mock("firebase/auth", () => ({getIdTokenResult: mocks.getIdTokenResult}));
vi.mock("../shared/api/firebaseCore", () => ({firebaseApp: {options: {projectId: "demo-catch-setup"}}}));
vi.mock("../shared/api/firebase", () => ({auth: {app: {options: {projectId: "demo-catch-setup"}}},
  confirmPhoneSignInCode: vi.fn(), requestPhoneSignInCode: vi.fn(), resetPhoneSignIn: vi.fn(),
  signInWithGoogleAdmin: vi.fn(), signOutAdmin: vi.fn()}));
afterEach(cleanup);
it("routes the export-only view without starting the role-gated Admin workspace or requesting a token", async () => {
  window.history.replaceState({}, "", "/operator-session");
  render(<App />);
  await screen.findByRole("heading", {name: "Catch operator session"});
  expect(mocks.session).not.toHaveBeenCalled();
  expect(mocks.getIdTokenResult).not.toHaveBeenCalled();
  expect((screen.getByRole("button", {name: "Transfer my current Google session"}) as HTMLButtonElement).disabled).toBe(true);
});
