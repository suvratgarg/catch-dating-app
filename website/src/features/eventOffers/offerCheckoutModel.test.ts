import {describe, expect, it, vi} from "vitest";
import {captureOfferCredential} from "./offerCredential";
import {assertOfferResponse, paymentCopy} from "./offerCheckoutModel";
describe("private invitation contract", () => {
  it("strips the fragment and keeps a stable opaque page instance", () => {
    const replace = vi.fn();
    const location = {pathname: "/offer", hash: `#${"a".repeat(43)}`};
    const first = captureOfferCredential(location, replace);
    expect(first?.token).toBe("a".repeat(43));
    expect(first?.instance).not.toContain(first?.token);
    expect(captureOfferCredential(location, replace)).toBe(first);
    expect(replace).toHaveBeenCalledWith("/offer");
    expect(captureOfferCredential({...location, hash: "#invalid"}, replace)).toBeNull();
  });
  it("restores only a non-secret payment reference from the history entry", async () => {
    vi.resetModules();
    const {captureOfferCredential: capture, rememberOfferPayment} = await import("./offerCredential");
    const id = `ep_${"b".repeat(32)}`;
    window.history.replaceState({key: "router-key"}, "", "/offer");
    rememberOfferPayment(id);
    expect(window.history.state).toEqual({key: "router-key", catchOfferPaymentId: id});
    const recovered = capture({pathname: "/offer", hash: ""}, vi.fn(), window.history.state);
    expect(recovered?.paymentId).toBe(id);
    expect(recovered?.token).toBeUndefined();
    expect(capture({pathname: "/offer", hash: "#bad"}, vi.fn(), window.history.state)).toBeNull();
    window.history.replaceState(null, "", "/");
  });
  it("rejects unknown fields and mismatched checkout amounts", () => {
    const payment = {paymentId: `ep_${"a".repeat(32)}`, status: "checkoutReady",
      amountPaise: 10000, currency: "INR", mode: "test", refundedAmountPaise: 0, cancellationReason: null,
      expiresAtMillis: 9e12, checkout: {publicToken: "rzp_test_key", orderId: "order_one",
        amountPaise: 10001, currency: "INR", description: "", expiresAtMillis: 9e12}};
    expect(() => assertOfferResponse({grant: null, payment, serverTimeMillis: 1000})).toThrow();
    expect(() => assertOfferResponse({grant: null, payment: null, serverTimeMillis: 1000, secret: "private"})).toThrow();
  });
  it("only server admission uses confirmation language", () => {
    const payment = {paymentId: `ep_${"a".repeat(32)}`, status: "captured" as const,
      amountPaise: 10000, currency: "INR" as const, mode: "test" as const,
      refundedAmountPaise: 0, cancellationReason: null, expiresAtMillis: 9e12, checkout: null};
    expect(paymentCopy(payment).title).toBe("Checking your payment");
    expect(paymentCopy({...payment, status: "admitted"}).title).toBe("You’re on the guest list");
    expect(paymentCopy({...payment, status: "refundPending", cancellationReason: "eventCancelled"}).title)
      .toBe("The event was cancelled");
    expect(paymentCopy({...payment, status: "refunded", cancellationReason: "eventCancelled"}).body)
      .toContain("event was cancelled");
    expect(() => assertOfferResponse({grant: null, serverTimeMillis: 1000,
      payment: {...payment, status: "admitted", cancellationReason: "eventCancelled"}})).toThrow();
  });
});
