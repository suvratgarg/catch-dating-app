import * as crypto from "crypto";
import {defineSecret} from "firebase-functions/params";
import Razorpay from "razorpay";

export const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
export const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

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
  const expectedSignature = crypto
    .createHmac("sha256", razorpayKeySecret.value())
    .update(`${orderId}|${paymentId}`)
    .digest("hex");

  return expectedSignature === signature;
}
