import {describe, expect, it, vi} from "vitest";
import Ajv from "ajv";
import {readFileSync} from "node:fs";
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
      amountPaise: 10000, currency: "INR", mode: "test", refundedAmountPaise: 0, cancellationReason: null, cancellationPolicy: null, cancellationQuote: null,
      expiresAtMillis: 9e12, checkout: {publicToken: "rzp_test_key", orderId: "order_one",
        amountPaise: 10001, currency: "INR", description: "", expiresAtMillis: 9e12}};
    expect(() => assertOfferResponse({grant: null, payment, serverTimeMillis: 1000})).toThrow();
    expect(() => assertOfferResponse({grant: null, payment: null, serverTimeMillis: 1000, secret: "private"})).toThrow();
  });
  it("only server admission uses confirmation language", () => {
    const payment = {paymentId: `ep_${"a".repeat(32)}`, status: "captured" as const,
      amountPaise: 10000, currency: "INR" as const, mode: "test" as const,
      refundedAmountPaise: 0, cancellationReason: null, cancellationPolicy: null, cancellationQuote: null, expiresAtMillis: 9e12, checkout: null};
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

describe("offer response and authored schema", () => {
  const schema = JSON.parse(readFileSync(
    "../contracts/callable_responses/manage_event_offer_checkout_response.schema.json",
    "utf8",
  ));
  const schemaAccepts = new Ajv().compile(schema);
  const payment = {
    paymentId: `ep_${"a".repeat(32)}`, status: "captured", amountPaise: 10000,
    currency: "INR", mode: "test", refundedAmountPaise: 0,
    expiresAtMillis: 9e12, checkout: null, cancellationReason: null,
    cancellationPolicy: null, cancellationQuote: null,
  };
  const grant = {
    grantId: "a".repeat(64), eventName: "Event", eventId: "event1",
    startTimeMillis: 9e12, amountPaise: 10000, currency: "INR",
    expiresAtMillis: 9e12,
    cancellationPolicy: {refundDeadlineMillis: 0, eventStartsAtMillis: 9e12},
  };
  const response = (fields: Record<string, unknown>) =>
    ({grant: null, payment: null, serverTimeMillis: 1000, ...fields});
  const checkout = {
    publicToken: "rzp_test_key", orderId: "order_one", amountPaise: 10000,
    currency: "INR", description: "Admission", expiresAtMillis: 9e12,
  };

  it.each([
    ["ordinary payment", response({payment}), true],
    ["ordinary grant", response({grant}), true],
    ["singleton array test mode", response({payment: {...payment, mode: ["test"]}}), false],
    ["singleton array live mode", response({payment: {...payment, mode: ["live"]}}), false],
    ["array mode with checkout", response({payment: {...payment, mode: ["test"],
      status: "checkoutReady", checkout}}), false],
    ["numeric mode", response({payment: {...payment, mode: 1}}), false],
    ["null mode", response({payment: {...payment, mode: null}}), false],
    ["200 supplementary event-name code points", response({grant: {...grant,
      eventName: "😀".repeat(200)}}), true],
    ["201 supplementary event-name code points", response({grant: {...grant,
      eventName: "😀".repeat(201)}}), false],
    ["mixed 200-point event name", response({grant: {...grant,
      eventName: `${"a".repeat(199)}😀`}}), true],
    ["mixed 201-point event name", response({grant: {...grant,
      eventName: `${"a".repeat(200)}😀`}}), false],
    ["200 supplementary checkout-description code points", response({payment: {
      ...payment, status: "checkoutReady", checkout: {...checkout,
        description: "😀".repeat(200)}}}), true],
    ["201 supplementary checkout-description code points", response({payment: {
      ...payment, status: "checkoutReady", checkout: {...checkout,
        description: "😀".repeat(201)}}}), false],
    ["mixed 200-point checkout description", response({payment: {
      ...payment, status: "checkoutReady", checkout: {...checkout,
        description: `${"a".repeat(199)}😀`}}}), true],
    ["mixed 201-point checkout description", response({payment: {
      ...payment, status: "checkoutReady", checkout: {...checkout,
        description: `${"a".repeat(200)}😀`}}}), false],
  ] as const)("agrees with the schema for %s", (_name, payload, accepted) => {
    // The callable boundary receives JSON, not JavaScript objects with custom coercion.
    const wireValue: unknown = JSON.parse(JSON.stringify(payload));
    expect(schemaAccepts(wireValue)).toBe(accepted);
    if (accepted) expect(() => assertOfferResponse(wireValue)).not.toThrow();
    else expect(() => assertOfferResponse(wireValue)).toThrow();
  });

  it.each([
    ["simultaneous grant and payment", response({grant, payment})],
    ["checkout amount mismatch", response({payment: {...payment,
      status: "checkoutReady", checkout: {...checkout, amountPaise: 10001}}})],
    ["cancellation reason on a captured payment", response({payment: {...payment,
      cancellationReason: "eventCancelled"}})],
    ["cancelled payment without guest cancellation", response({payment: {...payment,
      status: "cancelled", cancellationReason: "eventCancelled"}})],
  ] as const)("preserves the stronger %s check", (_name, payload) => {
    const wireValue: unknown = JSON.parse(JSON.stringify(payload));
    expect(schemaAccepts(wireValue)).toBe(true);
    expect(() => assertOfferResponse(wireValue)).toThrow();
  });
});
