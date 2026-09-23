import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import type {PublicOrganizerFormPayment} from "../../firebase";

const api = vi.hoisted(() => ({prepare: vi.fn(), get: vi.fn(), open: vi.fn(), find: vi.fn()}));
vi.mock("../../firebase", () => ({prepareOrganizerFormPayment: api.prepare,
  getOrganizerFormPayment: api.get, findOrganizerFormPayment: api.find}));
vi.mock("./razorpayFormCheckout", () => ({openFormCheckout: api.open}));
import {usePublicFormPayment} from "./usePublicFormPayment";

function wrapper({children}: PropsWithChildren) {
  const client = new QueryClient({defaultOptions: {mutations: {retry: false}}});
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
const request = {draftId: "draft", draftToken: null,
  expectedRevision: 1, requestId: "request-00000000"};
const ready: PublicOrganizerFormPayment = {
  paymentId: `fp_${"a".repeat(32)}`, status: "checkoutReady", amountPaise: 10000,
  currency: "INR", mode: "test", refundPolicy: "Refunded if cancelled",
  refundedAmountPaise: 0, receipt: null, checkout: {
    publicToken: "rzp_test_oauth_public", orderId: "order_one", amountPaise: 10000,
    currency: "INR", description: "Application fee", expiresAtMillis: 9e12,
  },
};
const completed: PublicOrganizerFormPayment = {...ready, status: "submitted",
  checkout: null, receipt: {responseId: "response", formId: "form", versionId: "v1",
    status: "submitted", submittedAtMillis: 1000, withdrawalToken: null,
    completion: {title: "Received", message: null, actionKind: "none",
      actionLabel: null, actionUrl: null}}};

beforeEach(() => {vi.clearAllMocks(); window.localStorage.clear(); api.find.mockResolvedValue({payment: null});});
afterEach(() => {cleanup(); vi.restoreAllMocks();});

describe("form payment recovery", () => {
  it("discovers an owned receipt without local storage or starting checkout", async () => {
    api.find.mockResolvedValue({payment: completed});
    const onReceipt = vi.fn();
    const {result} = renderHook(() => usePublicFormPayment("public", vi.fn(), onReceipt), {wrapper});
    await act(async () => {expect(await result.current.resume("person")).toBe(true);});
    expect(api.find).toHaveBeenCalledExactlyOnceWith({publicFormId: "public"});
    expect(onReceipt).toHaveBeenCalledExactlyOnceWith(completed.receipt);
    expect(api.prepare).not.toHaveBeenCalled();
    expect(api.open).not.toHaveBeenCalled();
  });

  it("recovers an older receipt behind a locally stored ended retry", async () => {
    api.prepare.mockResolvedValue(ready);
    const first = renderHook(() => usePublicFormPayment("public", vi.fn(), vi.fn()), {wrapper});
    await act(async () => {await first.result.current.prepare(request, "person");});
    first.unmount();
    api.get.mockResolvedValue({...ready, status: "expired", checkout: null});
    const oldReceipt = {...completed, paymentId: `fp_${"b".repeat(32)}`};
    api.find.mockResolvedValue({payment: oldReceipt});
    const onReceipt = vi.fn();
    const second = renderHook(() => usePublicFormPayment("public", vi.fn(), onReceipt), {wrapper});
    await act(async () => {expect(await second.result.current.resume("person")).toBe(true);});
    expect(api.get).toHaveBeenCalledExactlyOnceWith({paymentId: ready.paymentId,
      callback: null});
    expect(api.find).toHaveBeenCalledExactlyOnceWith({publicFormId: "public"});
    expect(second.result.current.payment?.paymentId).toBe(oldReceipt.paymentId);
    expect(onReceipt).toHaveBeenCalledExactlyOnceWith(oldReceipt.receipt);
    expect(api.open).not.toHaveBeenCalled();
  });

  it("keeps payment and server recovery usable when all browser storage is denied", async () => {
    for (const method of ["getItem", "setItem", "removeItem"] as const) {
      vi.spyOn(Storage.prototype, method).mockImplementation(() => {throw new Error("Denied");});
    }
    api.prepare.mockResolvedValue(ready);
    const first = renderHook(() => usePublicFormPayment("public", vi.fn(), vi.fn()), {wrapper});
    await act(async () => {await first.result.current.prepare(request, "person");});
    expect(first.result.current.payment?.paymentId).toBe(ready.paymentId);
    first.unmount();
    api.find.mockResolvedValue({payment: ready});
    api.get.mockResolvedValue({...ready, checkout: null, status: "expired"});
    const second = renderHook(() => usePublicFormPayment("public", vi.fn(), vi.fn()), {wrapper});
    await act(async () => {expect(await second.result.current.resume("person")).toBe(true);});
    await act(async () => {expect(await second.result.current.restart()).toBe(true);});
    expect(second.result.current.payment).toBeNull();
  });

  it("deduplicates discovery and does not treat a failed lookup as no payment", async () => {
    let finish!: (value: {payment: PublicOrganizerFormPayment}) => void;
    api.find.mockImplementationOnce(() => new Promise((resolve) => {finish = resolve;}));
    const {result} = renderHook(() => usePublicFormPayment("public", vi.fn(), vi.fn()), {wrapper});
    let first!: Promise<boolean>; let second!: Promise<boolean>;
    act(() => {first = result.current.resume("person"); second = result.current.resume("person");});
    expect(api.find).toHaveBeenCalledTimes(1);
    await act(async () => {finish({payment: ready}); expect(await first).toBe(true); expect(await second).toBe(true);});
    act(() => result.current.resetSession());
    window.localStorage.clear();
    api.find.mockRejectedValueOnce(new Error("Lookup unavailable"));
    await act(async () => {await expect(result.current.resume("person")).rejects.toThrow("Lookup unavailable");});
    expect(api.prepare).not.toHaveBeenCalled();
  });

  it("ignores discovery after account changes, including returning to the same account", async () => {
    let finish!: (value: {payment: PublicOrganizerFormPayment}) => void;
    api.find.mockImplementationOnce(() => new Promise((resolve) => {finish = resolve;}));
    const onReceipt = vi.fn();
    const {result} = renderHook(() => usePublicFormPayment("public", vi.fn(), onReceipt), {wrapper});
    let old!: Promise<boolean>;
    act(() => {old = result.current.resume("person");});
    act(() => result.current.resetSession());
    await act(async () => {await result.current.resume("other");});
    act(() => result.current.resetSession());
    await act(async () => {await result.current.resume("person");});
    await act(async () => {finish({payment: completed}); await old;});
    expect(result.current.payment).toBeNull();
    expect(onReceipt).not.toHaveBeenCalled();
  });

  it("clears an old form's in-flight result when the route changes", async () => {
    let finish!: (value: {payment: PublicOrganizerFormPayment}) => void;
    api.find.mockImplementationOnce(() => new Promise((resolve) => {finish = resolve;}));
    const onReceipt = vi.fn();
    const {result, rerender} = renderHook(({id}) => usePublicFormPayment(id, vi.fn(), onReceipt),
      {wrapper, initialProps: {id: "first"}});
    let old!: Promise<boolean>;
    act(() => {old = result.current.resume("person");});
    rerender({id: "second"});
    await act(async () => {expect(await result.current.resume("person")).toBe(false);});
    await act(async () => {finish({payment: completed}); await old;});
    expect(onReceipt).not.toHaveBeenCalled();
    expect(result.current.payment).toBeNull();
  });

  it("persists before prepare, resumes a lost reply and never opens checkout automatically", async () => {
    const onReceipt = vi.fn();
    api.prepare.mockImplementationOnce(async () => {
      expect(window.localStorage.getItem("catch:form:public:payment")).toContain("draft");
      throw new Error("Lost reply");
    }).mockResolvedValue(ready);
    const first = renderHook(() => usePublicFormPayment("public", vi.fn(), onReceipt), {wrapper});
    await act(async () => {await expect(first.result.current.prepare(request, "person"))
      .rejects.toThrow("Lost reply");});
    first.unmount();
    const second = renderHook(() => usePublicFormPayment("public", vi.fn(), onReceipt), {wrapper});
    await act(async () => {expect(await second.result.current.resume("other")).toBe(false);});
    expect(api.prepare).toHaveBeenCalledTimes(1);
    await act(async () => {expect(await second.result.current.resume("person")).toBe(true);});
    expect(api.prepare).toHaveBeenLastCalledWith(request);
    expect(api.open).not.toHaveBeenCalled();
    expect(onReceipt).not.toHaveBeenCalled();
    expect(second.result.current.payment?.checkout?.orderId).toBe("order_one");
  });

  it("validates callback on the server and completes only with a receipt", async () => {
    const onReceipt = vi.fn();
    api.prepare.mockResolvedValue(ready);
    api.get.mockResolvedValueOnce(ready).mockResolvedValueOnce({...ready,
      status: "captured", checkout: null}).mockResolvedValue(completed);
    api.open.mockResolvedValue({paymentId: "pay_one", signature: "a".repeat(64)});
    const {result} = renderHook(() => usePublicFormPayment("public", vi.fn(), onReceipt), {wrapper});
    await act(async () => {await result.current.prepare(request, "person");});
    await act(async () => {await result.current.pay("RSVP");});
    expect(api.get).toHaveBeenLastCalledWith({paymentId: ready.paymentId,
      callback: {paymentId: "pay_one", signature: "a".repeat(64)}});
    expect(onReceipt).not.toHaveBeenCalled();
    await act(async () => {await result.current.refresh();});
    expect(onReceipt).toHaveBeenCalledExactlyOnceWith(completed.receipt);
  });

  it("does not open an already paid order and does not restart uncertain payments", async () => {
    api.prepare.mockResolvedValue(ready);
    api.get.mockResolvedValue(completed);
    const {result} = renderHook(() => usePublicFormPayment("public", vi.fn(), vi.fn()), {wrapper});
    await act(async () => {await result.current.prepare(request, "person");});
    await act(async () => {await result.current.pay("RSVP");});
    expect(api.open).not.toHaveBeenCalled();
    api.get.mockResolvedValue({...ready, status: "orderUnknown", checkout: null});
    await act(async () => {expect(await result.current.restart()).toBe(false);});
    expect(window.localStorage.getItem("catch:form:public:payment")).not.toBeNull();
    api.get.mockResolvedValue({...ready, status: "refunded", checkout: null});
    await act(async () => {expect(await result.current.restart()).toBe(true);});
    expect(window.localStorage.getItem("catch:form:public:payment")).toBeNull();
  });

  it("ignores an in-flight receipt after sign out or account switch", async () => {
    let release!: (value: PublicOrganizerFormPayment) => void;
    api.prepare.mockImplementation(() => new Promise((resolve) => {release = resolve;}));
    const onReceipt = vi.fn();
    const {result} = renderHook(() => usePublicFormPayment("public", vi.fn(), onReceipt), {wrapper});
    let pending!: Promise<void>;
    act(() => {pending = result.current.prepare(request, "person");});
    await waitFor(() => expect(api.prepare).toHaveBeenCalled());
    act(() => result.current.resetSession());
    await act(async () => {release(completed); await pending;});
    expect(result.current.payment).toBeNull();
    expect(onReceipt).not.toHaveBeenCalled();
  });

  it("does not show another account's delayed payment error", async () => {
    api.prepare.mockResolvedValue(ready);
    let rejectOld!: (error: Error) => void;
    api.get.mockImplementationOnce(() => new Promise((_, reject) => {rejectOld = reject;}));
    const {result} = renderHook(() => usePublicFormPayment("public", vi.fn(), vi.fn()), {wrapper});
    await act(async () => {await result.current.prepare(request, "person");});
    let old!: Promise<void>;
    act(() => {old = result.current.refresh();});
    await waitFor(() => expect(api.get).toHaveBeenCalled());
    act(() => result.current.resetSession());
    await act(async () => {rejectOld(new Error("Private prior account problem")); await old;});
    expect(result.current.status.message).toBe("");
    expect(result.current.payment).toBeNull();
  });
});
