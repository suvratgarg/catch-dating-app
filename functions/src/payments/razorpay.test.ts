import assert from "node:assert/strict";
import crypto from "node:crypto";
import test from "node:test";
import {verifyPaymentSignatureWithSecret} from "./razorpay";

test(
  "verifyPaymentSignatureWithSecret verifies valid Razorpay signatures",
  () => {
    const signature = crypto
      .createHmac("sha256", "secret")
      .update("order_123|pay_123")
      .digest("hex");

    assert.equal(
      verifyPaymentSignatureWithSecret({
        orderId: "order_123",
        paymentId: "pay_123",
        signature,
        secret: "secret",
      }),
      true
    );
  }
);

test("verifyPaymentSignatureWithSecret rejects malformed signatures", () => {
  assert.equal(
    verifyPaymentSignatureWithSecret({
      orderId: "order_123",
      paymentId: "pay_123",
      signature: "not-hex",
      secret: "secret",
    }),
    false
  );
  assert.equal(
    verifyPaymentSignatureWithSecret({
      orderId: "order_123",
      paymentId: "pay_123",
      signature: "abcd",
      secret: "secret",
    }),
    false
  );
});
