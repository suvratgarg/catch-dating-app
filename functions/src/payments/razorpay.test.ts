import assert from "node:assert/strict";
import crypto from "node:crypto";
import test from "node:test";
import {
  verifyPaymentSignatureWithSecret,
  verifyRazorpayWebhookSignature,
} from "./razorpay";

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

test("verifyRazorpayWebhookSignature accepts a body signed with the secret",
  () => {
    const rawBody = Buffer.from(JSON.stringify({event: "payment.captured"}));
    const signature = crypto
      .createHmac("sha256", "whsec")
      .update(rawBody)
      .digest("hex");

    assert.equal(
      verifyRazorpayWebhookSignature(rawBody, signature, "whsec"),
      true
    );
  });

test("verifyRazorpayWebhookSignature rejects tampered bodies and bad headers",
  () => {
    const rawBody = Buffer.from(JSON.stringify({event: "payment.captured"}));
    const signature = crypto
      .createHmac("sha256", "whsec")
      .update(rawBody)
      .digest("hex");

    // Tampered body.
    assert.equal(
      verifyRazorpayWebhookSignature(
        Buffer.from(JSON.stringify({event: "payment.failed"})),
        signature,
        "whsec"
      ),
      false
    );
    // Wrong secret.
    assert.equal(
      verifyRazorpayWebhookSignature(rawBody, signature, "other"),
      false
    );
    // Missing / non-hex signature header.
    assert.equal(
      verifyRazorpayWebhookSignature(rawBody, undefined, "whsec"),
      false
    );
    assert.equal(
      verifyRazorpayWebhookSignature(rawBody, "not-hex", "whsec"),
      false
    );
  });
