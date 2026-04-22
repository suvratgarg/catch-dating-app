import * as crypto from "crypto";
import {defineSecret} from "firebase-functions/params";
import Razorpay from "razorpay";

export const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
export const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

export const razorpayCurrency = "INR";

export function createRazorpayClient(): Razorpay {
  return new Razorpay({
    key_id: razorpayKeyId.value(),
    key_secret: razorpayKeySecret.value(),
  });
}

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
