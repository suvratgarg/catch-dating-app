import * as crypto from "crypto";
import {defineSecret} from "firebase-functions/params";
import Razorpay from "razorpay";

export const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
export const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");
export const razorpayWebhookSecret = defineSecret("RAZORPAY_WEBHOOK_SECRET");

export const razorpayCurrency = "INR";

/**
 * Creates a Razorpay SDK client from configured Firebase secrets.
 * @return {Razorpay} Razorpay SDK client.
 */
export function createRazorpayClient(): Razorpay {
  return new Razorpay({
    key_id: razorpayKeyId.value(),
    key_secret: razorpayKeySecret.value(),
  });
}

/**
 * Verifies the Razorpay payment signature for an order/payment pair.
 * @param {object} params Signature verification parameters.
 * @param {string} params.orderId Razorpay order id.
 * @param {string} params.paymentId Razorpay payment id.
 * @param {string} params.signature Client-returned signature.
 * @return {boolean} Whether the signature matches.
 */
export function verifyPaymentSignature({
  orderId,
  paymentId,
  signature,
}: {
  orderId: string;
  paymentId: string;
  signature: string;
}): boolean {
  return verifyPaymentSignatureWithSecret({
    orderId,
    paymentId,
    signature,
    secret: razorpayKeySecret.value(),
  });
}

/**
 * Verifies a Razorpay payment signature with an explicit secret.
 *
 * Exposed for focused tests so production verification can use a
 * timing-safe comparison without reaching Firebase Secret Manager.
 * @param {object} params Signature verification parameters.
 * @param {string} params.orderId Razorpay order id.
 * @param {string} params.paymentId Razorpay payment id.
 * @param {string} params.signature Client-returned signature.
 * @param {string} params.secret Razorpay key secret.
 * @return {boolean} Whether the signature matches.
 */
export function verifyPaymentSignatureWithSecret({
  orderId,
  paymentId,
  signature,
  secret,
}: {
  orderId: string;
  paymentId: string;
  signature: string;
  secret: string;
}): boolean {
  const expectedSignature = crypto
    .createHmac("sha256", secret)
    .update(`${orderId}|${paymentId}`)
    .digest("hex");

  if (!/^[a-f0-9]+$/i.test(signature)) {
    return false;
  }
  const expected = Buffer.from(expectedSignature, "hex");
  const actual = Buffer.from(signature, "hex");
  return expected.length === actual.length &&
    crypto.timingSafeEqual(expected, actual);
}

/**
 * Verifies a Razorpay webhook signature.
 *
 * Razorpay signs webhook deliveries with HMAC-SHA256 of the exact raw request
 * body keyed by the webhook secret, hex-encoded, and sends it in the
 * `x-razorpay-signature` header. We compare against the raw body (never the
 * re-serialized JSON) using a timing-safe equality check.
 * @param {Buffer|string} rawBody Exact raw request body bytes.
 * @param {string|undefined} signature Value of the x-razorpay-signature header.
 * @param {string} secret Razorpay webhook secret.
 * @return {boolean} Whether the signature is valid.
 */
export function verifyRazorpayWebhookSignature(
  rawBody: Buffer | string,
  signature: string | undefined,
  secret: string
): boolean {
  if (typeof signature !== "string" || !/^[a-f0-9]+$/i.test(signature)) {
    return false;
  }
  const expectedSignature = crypto
    .createHmac("sha256", secret)
    .update(rawBody)
    .digest("hex");
  const expected = Buffer.from(expectedSignature, "hex");
  const actual = Buffer.from(signature, "hex");
  return expected.length === actual.length &&
    crypto.timingSafeEqual(expected, actual);
}
