import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import type {PublicOrganizerFormPayment} from "../../firebase";

const api = vi.hoisted(() => ({prepare: vi.fn(), get: vi.fn(), open: vi.fn()}));
vi.mock("../../firebase", () => ({prepareOrganizerFormPayment: api.prepare,
  getOrganizerFormPayment: api.get}));
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

beforeEach(() => {vi.clearAllMocks(); window.localStorage.clear();});
afterEach(cleanup);

describe("form payment recovery", () => {
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
});
