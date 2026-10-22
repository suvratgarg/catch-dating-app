import {beforeEach, expect, it, vi} from "vitest";
import {createHostServerConsent, hostServerConsentStorageKey} from "../../analytics/hostServerConsent";

const now = 1792512000000;
const consent = {version: 4, analytics: true, marketing: true, updatedAt: new Date(now).toISOString()};
const input = {enabled: true, path: "/host/apply/", consent};
const expiresAt = now + 30 * 24 * 60 * 60 * 1000;
const active = {ok: true, status: "active", expiresAt};
beforeEach(() => localStorage.clear());
function fixture(request = vi.fn(async (_request: unknown): Promise<unknown> => active)) {
  const owner = createHostServerConsent({storage: localStorage, now: () => now,
    withLock: run => run(), isCurrentChoice: () => true,
    randomCapability: () => "a".repeat(64), request});
  return {owner, request};
}

it("sends nothing for disabled, old, denied or private contexts", async () => {
  for (const override of [{enabled: false}, {consent: null},
    {consent: {...consent, version: 3}}, {consent: {...consent, analytics: false}},
    {path: "/"}, {path: "/booking/private/"}]) {
    const {owner, request} = fixture();
    await owner.sync({...input, ...override});
    expect(request).not.toHaveBeenCalled();
    expect(owner.snapshot(consent.updatedAt)).toBeNull();
  }
});
it("requires a matching server acknowledgement and current stored permission", async () => {
  const {owner, request} = fixture();
  expect(owner.snapshot(consent.updatedAt)).toBeNull();
  await owner.sync(input);
  expect(owner.snapshot(consent.updatedAt)).toBe("a".repeat(64));
  expect(request).toHaveBeenCalledWith({action: "grant", capability: "a".repeat(64),
    choice: {version: 1, purpose: "host_acquisition_measurement",
      analytics: true, advertising: true, chosenAt: now}});
  expect(owner.snapshot("another-revision")).toBeNull();
  localStorage.removeItem(hostServerConsentStorageKey);
  expect(owner.snapshot(consent.updatedAt)).toBeNull();
});
it("does not resend or invalidate permission on repeated page events", async () => {
  const {owner, request} = fixture();
  await Promise.all([owner.sync(input), owner.sync(input)]);
  await owner.sync({...input, path: "/host/"});
  expect(request).toHaveBeenCalledOnce();
  expect(owner.snapshot(consent.updatedAt)).toBe("a".repeat(64));
});
it("immediately stops locally and persists a failed withdrawal for reload retry", async () => {
  const {owner, request} = fixture();
  await owner.sync(input);
  request.mockResolvedValueOnce(null);
  const withdrawal = owner.sync({...input, consent: null});
  expect(owner.snapshot(consent.updatedAt)).toBeNull();
  await withdrawal;
  expect(JSON.parse(localStorage.getItem(hostServerConsentStorageKey)!)).toMatchObject({withdrawing: true});
  const afterReload = fixture(vi.fn(async () => ({ok: true, status: "revoked"})));
  await afterReload.owner.sync({...input, consent: null});
  expect(afterReload.request).toHaveBeenCalledWith({action: "revoke", capability: "a".repeat(64)});
  expect(localStorage.getItem(hostServerConsentStorageKey)).toBeNull();
});
it("withdraws a delayed grant instead of authorizing the old revision", async () => {
  let resolve!: (value: unknown) => void;
  const pending = new Promise<unknown>(r => { resolve = r; });
  const {owner, request} = fixture(vi.fn(async (r: unknown) =>
    (r as {action: string}).action === "grant" ? pending : {ok: true, status: "revoked"}));
  const grant = owner.sync(input);
  await vi.waitFor(() => expect(request).toHaveBeenCalledTimes(1));
  const withdrawal = owner.sync({...input, consent: null});
  resolve(active);
  await Promise.all([grant, withdrawal]);
  expect(owner.snapshot(consent.updatedAt)).toBeNull();
  expect(request).toHaveBeenLastCalledWith({action: "revoke", capability: "a".repeat(64)});
  expect(localStorage.getItem(hostServerConsentStorageKey)).toBeNull();
});
it("does not grant again while an earlier withdrawal remains unacknowledged", async () => {
  const {owner, request} = fixture();
  await owner.sync(input);
  request.mockResolvedValue(null);
  await owner.sync({...input, consent: null});
  await owner.sync(input);
  expect(request.mock.calls.slice(1).every(([r]) => (r as {action: string}).action === "revoke")).toBe(true);
  expect(owner.snapshot(consent.updatedAt)).toBeNull();
});
it("fails closed for unavailable storage and invalid or disabled acknowledgements", async () => {
  for (const result of [null, {ok: true, status: "disabled", expiresAt: null},
    {...active, expiresAt: expiresAt + 1}]) {
    localStorage.clear();
    const {owner} = fixture(vi.fn(async () => result));
    await owner.sync(input);
    expect(owner.snapshot(consent.updatedAt)).toBeNull();
  }
  const request = vi.fn();
  const owner = createHostServerConsent({storage: {
    getItem() { throw new Error("storage denied"); }, setItem() {}, removeItem() {},
  }, withLock: run => run(), isCurrentChoice: () => true, now: () => now, randomCapability: () => "a".repeat(64), request});
  await owner.sync(input);
  expect(request).not.toHaveBeenCalled();
});

it("serializes sibling-tab capabilities and prevents a stale tab from restoring an old choice", async () => {
  let work = Promise.resolve();
  const withLock = (run: () => Promise<void>) => { work = work.then(run); return work; };
  let current = consent;
  let sequence = 0;
  const request = vi.fn(async (r: {action: string}) => r.action === "grant" ? active : {ok: true, status: "revoked"});
  const port = {storage: localStorage, now: () => now, request, withLock,
    randomCapability: () => (++sequence).toString(16).padStart(64, "0"),
    isCurrentChoice: (choice: typeof consent | null) => choice?.updatedAt === current.updatedAt};
  const first = createHostServerConsent(port);
  const second = createHostServerConsent(port);
  await Promise.all([first.sync(input), second.sync(input)]);
  expect(sequence).toBe(1);
  expect(first.snapshot(consent.updatedAt)).toBe(second.snapshot(consent.updatedAt));
  current = {...consent, updatedAt: new Date(now + 1).toISOString(), analytics: false, marketing: false};
  await second.sync({...input, consent: current});
  await first.sync(input);
  expect(localStorage.getItem(hostServerConsentStorageKey)).toBeNull();
  expect(request.mock.calls.filter(([r]) => r.action === "grant")).toHaveLength(2);
  expect(first.snapshot(consent.updatedAt)).toBeNull();
});
