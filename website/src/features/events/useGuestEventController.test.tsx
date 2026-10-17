import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {type PropsWithChildren} from "react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import type {User} from "../../firebase";
const api = vi.hoisted(() => ({read: vi.fn(), watch: vi.fn(), otp: vi.fn()}));
vi.mock("../../firebase", () => ({getGuestEventViewerState: api.read,
  watchPublicFormAuthState: api.watch, beginPublicEventPhoneVerification: api.otp}));
import {useGuestEventController} from "./useGuestEventController";
let auth: (user: User | null) => void;
let initial: User | null;
let client: QueryClient;
const user = {uid: "one", phoneNumber: "+919000000001"} as User;
const resultFor = (eventId = "event1") => ({viewer: {eventId,
  guest: {action: "registered", expiresAtMillis: Date.now() + 30000}}});
function wrapper({children}: PropsWithChildren) {
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
beforeEach(() => {
  vi.resetAllMocks(); initial = user;
  client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  api.watch.mockImplementation((callback) => {auth = callback; callback(initial); return vi.fn();});
  api.read.mockResolvedValue(resultFor());
});
afterEach(() => {cleanup(); client.clear();});
it("does not read guest status until phone authentication", async () => {
  initial = null;
  const {result} = renderHook(() => useGuestEventController("event1"), {wrapper});
  await waitFor(() => expect(result.current.user).toBeNull());
  expect(api.read).not.toHaveBeenCalled();
});
it("reuses an existing phone session without OTP", async () => {
  const {result} = renderHook(() => useGuestEventController("event1"), {wrapper});
  await waitFor(() => expect(result.current.viewer?.guest?.action).toBe("registered"));
  expect(api.otp).not.toHaveBeenCalled();
  expect(api.read).toHaveBeenCalledWith("event1");
});
it("late results from a previous account never populate a signed-out screen", async () => {
  let resolve!: (value: unknown) => void;
  api.read.mockImplementation(() => new Promise((done) => {resolve = done;}));
  const {result} = renderHook(() => useGuestEventController("event1"), {wrapper});
  await waitFor(() => expect(api.read).toHaveBeenCalledOnce());
  act(() => auth(null));
  await act(async () => resolve(resultFor()));
  expect(result.current.viewer).toBeNull();
});
it.each(["wrong event", "expired"])("rejects %s status", async (kind) => {
  const response = resultFor(kind === "wrong event" ? "event2" : "event1");
  if (kind === "expired") response.viewer.guest.expiresAtMillis = 1;
  api.read.mockResolvedValue(response);
  const {result} = renderHook(() => useGuestEventController("event1"), {wrapper});
  await waitFor(() => expect(result.current.error).toBe(true));
  expect(result.current.viewer).toBeNull();
});
it("background refresh preserves the current form until new status arrives", async () => {
  const {result} = renderHook(() => useGuestEventController("event1"), {wrapper});
  await waitFor(() => expect(result.current.viewer).toBeTruthy());
  api.read.mockImplementation(() => new Promise(() => undefined));
  act(() => {void result.current.refresh();});
  expect(result.current.viewer).toBeTruthy();
  expect(result.current.loading).toBe(false);
});

it("lets a guest correct the phone number after requesting a code", async () => {
  initial = null;
  const clear = vi.fn();
  api.otp.mockResolvedValue({confirm: vi.fn(), clear});
  const {result} = renderHook(() => useGuestEventController("event1"), {wrapper});
  act(() => result.current.setPhone("+919000000001"));
  await act(() => result.current.submit({preventDefault: vi.fn()} as unknown as React.FormEvent));
  await waitFor(() => expect(result.current.codeSent).toBe(true));
  act(() => result.current.changePhone());
  expect(clear).toHaveBeenCalledOnce();
  expect(result.current.codeSent).toBe(false);
  expect(result.current.code).toBe("");
});
