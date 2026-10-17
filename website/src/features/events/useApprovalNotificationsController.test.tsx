import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {type PropsWithChildren, type FormEvent} from "react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import type {User} from "../../firebase";
const api = vi.hoisted(() => ({manage: vi.fn(), verify: vi.fn(), refresh: vi.fn()}));
vi.mock("../../firebase", () => ({manageEventApprovalNotifications: api.manage,
  verifyGuestEmail: api.verify, refreshGuestIdentity: api.refresh}));
import {useApprovalNotificationsController} from "./useApprovalNotificationsController";
let client: QueryClient;
const user = {uid: "one", phoneNumber: "+919000000001", email: null} as User;
const value = () => ({eventId: "event1", revision: 0,
  choices: {phoneUpdates: false, emailUpdates: false}, phoneVerified: true,
  emailVerified: false, available: true, terms: {version: "event-approval-v1",
    phone: "Optional phone updates", email: "Optional email updates"}});
const submit = {preventDefault: vi.fn()} as unknown as FormEvent;
function wrapper({children}: PropsWithChildren) {
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
beforeEach(() => {
  vi.resetAllMocks();
  client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  api.manage.mockResolvedValue(value());
});
afterEach(() => {cleanup(); client.clear();});
it("starts with both channels off and fences reads and writes to the account", async () => {
  const {result} = renderHook(() => useApprovalNotificationsController("event1", user), {wrapper});
  await waitFor(() => expect(result.current.choices).toEqual(value().choices));
  expect(api.manage).toHaveBeenCalledWith({eventId: "event1", expectedUid: "one", action: "get"});
  act(() => result.current.choose("phoneUpdates", true));
  api.manage.mockResolvedValue({...value(), revision: 1, choices: {phoneUpdates: true, emailUpdates: false}});
  act(() => result.current.save(submit));
  await waitFor(() => expect(result.current.message).toContain("saved"));
  expect(api.manage).toHaveBeenLastCalledWith({eventId: "event1", expectedUid: "one",
    action: "save", expectedRevision: 0, termsVersion: "event-approval-v1",
    choices: {phoneUpdates: true, emailUpdates: false}});
});
it("verification does not automatically opt into email updates", async () => {
  const {result} = renderHook(() => useApprovalNotificationsController("event1", user), {wrapper});
  await waitFor(() => expect(result.current.value).toBeTruthy());
  act(() => result.current.setEmail("guest@example.com"));
  await act(() => result.current.verify());
  expect(api.verify).toHaveBeenCalledWith("one", "guest@example.com", "event1");
  expect(result.current.choices?.emailUpdates).toBe(false);
  expect(api.manage).toHaveBeenCalledTimes(1);
});
it("refresh rechecks current Auth before reading server verification", async () => {
  const {result} = renderHook(() => useApprovalNotificationsController("event1", user), {wrapper});
  await waitFor(() => expect(result.current.value).toBeTruthy());
  api.manage.mockResolvedValue({...value(), emailVerified: true});
  await act(() => result.current.refresh());
  expect(api.refresh).toHaveBeenCalledWith("one");
  await waitFor(() => expect(result.current.value?.emailVerified).toBe(true));
  expect(result.current.choices?.emailUpdates).toBe(false);
});
it("late saves after account unmount do not repopulate private cache", async () => {
  const {result, unmount} = renderHook(() => useApprovalNotificationsController("event1", user), {wrapper});
  await waitFor(() => expect(result.current.value).toBeTruthy());
  let resolve!: (value: unknown) => void;
  api.manage.mockImplementation(() => new Promise((done) => {resolve = done;}));
  act(() => result.current.save(submit));
  await waitFor(() => expect(result.current.pending).toBe(true));
  unmount();
  await act(async () => resolve({...value(), revision: 1}));
  expect(client.getQueryData(["event-approval-notifications", "event1", "one"])).toBeUndefined();
});
it("failed verification leaves choices editable and reports a recoverable error", async () => {
  const {result} = renderHook(() => useApprovalNotificationsController("event1", user), {wrapper});
  await waitFor(() => expect(result.current.value).toBeTruthy());
  api.verify.mockRejectedValue(new Error("account changed"));
  await act(() => result.current.verify());
  expect(result.current.message).toContain("Refresh");
  expect(result.current.choices?.emailUpdates).toBe(false);
});
