import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {PropsWithChildren} from "react";
import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import type {User} from "../../firebase";
const api = vi.hoisted(() => ({register: vi.fn(), watch: vi.fn(), otp: vi.fn()}));
vi.mock("../../firebase", () => ({registerPublicEvent: api.register,
  watchPublicFormAuthState: api.watch, beginPublicEventPhoneVerification: api.otp}));
import {useFreeEventRegistrationController} from "./useFreeEventRegistrationController";
let auth: (user: User | null) => void;
const user = {uid: "one", phoneNumber: "+919000000001"} as User;
const submit = {preventDefault: vi.fn()} as unknown as React.FormEvent<HTMLFormElement>;
let client: QueryClient;
function wrapper({children}: PropsWithChildren) {
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
beforeEach(() => {
  client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  vi.resetAllMocks();
  api.watch.mockImplementation((callback) => {auth = callback; callback(user); return vi.fn();});
  api.register.mockResolvedValue({eventId: "event1", attendeeId: "one", status: "registered"});
});
afterEach(cleanup);
it("registers an existing phone identity without another OTP and keeps consents optional", async () => {
  const {result} = renderHook(() => useFreeEventRegistrationController("event1"), {wrapper});
  act(() => result.current.setDisplayName("Guest"));
  await act(() => result.current.handleSubmit(submit));
  expect(result.current.stage).toBe("success");
  expect(api.otp).not.toHaveBeenCalled();
  expect(api.register.mock.calls[0][0].organizerUpdates).toMatchObject({sms: false, whatsapp: false});
});
it("discards an old account's registration response after sign-out", async () => {
  let resolve!: (value: unknown) => void;
  api.register.mockImplementation(() => new Promise((done) => {resolve = done;}));
  const {result} = renderHook(() => useFreeEventRegistrationController("event1"), {wrapper});
  act(() => result.current.setDisplayName("Guest"));
  let pending!: Promise<void>;
  act(() => {pending = result.current.handleSubmit(submit);});
  await waitFor(() => expect(api.register).toHaveBeenCalledOnce());
  act(() => auth(null));
  await act(async () => {resolve({eventId: "event1", attendeeId: "one", status: "registered"}); await pending;});
  expect(result.current.registeredScope).toBeNull();
  expect(result.current.stage).toBe("details");
});
