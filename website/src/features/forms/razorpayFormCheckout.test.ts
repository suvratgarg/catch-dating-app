import {afterEach, describe, expect, it} from "vitest";
import {openFormCheckout} from "./razorpayFormCheckout";
import {publicFormsCopy} from "../../content/forms";

const checkout = {publicToken: "rzp_test_oauth_public", orderId: "order_one",
  amountPaise: 20000, currency: "INR" as const,
  description: publicFormsCopy.paymentKicker,
  expiresAtMillis: 9e12};
afterEach(() => {delete window.Razorpay;});

describe("Razorpay checkout adapter", () => {
  it("uses the server order and forwards only a matching signed callback", async () => {
    let options!: ConstructorParameters<NonNullable<Window["Razorpay"]>>[0];
    window.Razorpay = class {
      constructor(value: typeof options) {options = value;}
      open() {}
      close() {}
    };
    const promise = openFormCheckout(checkout, "RSVP", new AbortController().signal);
    await Promise.resolve();
    expect(options).toMatchObject({key: checkout.publicToken, order_id: "order_one",
      amount: 20000, currency: "INR"});
    expect(options).not.toHaveProperty("callback_url");
    options.handler({razorpay_order_id: "order_one", razorpay_payment_id: "pay_one",
      razorpay_signature: "a".repeat(64)});
    await expect(promise).resolves.toEqual({paymentId: "pay_one", signature: "a".repeat(64)});
  });

  it("closing checkout is not success; wrong-order callbacks fail closed", async () => {
    let options!: ConstructorParameters<NonNullable<Window["Razorpay"]>>[0];
    window.Razorpay = class {
      constructor(value: typeof options) {options = value;}
      open() {}
      close() {options.modal.ondismiss();}
    };
    const abort = new AbortController();
    const dismissed = openFormCheckout(checkout, "RSVP", abort.signal);
    await Promise.resolve();
    abort.abort();
    await expect(dismissed).resolves.toBeNull();
    const mismatch = openFormCheckout(checkout, "RSVP", new AbortController().signal);
    await Promise.resolve();
    options.handler({razorpay_order_id: "order_other", razorpay_payment_id: "pay_one",
      razorpay_signature: "a".repeat(64)});
    await expect(mismatch).rejects.toThrow("being checked");
    await expect(openFormCheckout({...checkout, expiresAtMillis: 1}, "RSVP",
      new AbortController().signal)).rejects.toThrow("expired");
  });
});
