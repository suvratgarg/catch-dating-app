import type {PublicOrganizerFormPayment} from "../../firebase";

type Checkout = NonNullable<PublicOrganizerFormPayment["checkout"]>;
export interface FormCheckoutCallback {paymentId: string; signature: string}
interface CheckoutResult {
  razorpay_payment_id: string;
  razorpay_order_id: string;
  razorpay_signature: string;
}
interface CheckoutOptions {
  key: string; order_id: string; amount: number; currency: "INR";
  name: string; description: string;
  handler: (result: CheckoutResult) => void;
  modal: {ondismiss: () => void};
}
interface CheckoutInstance {open: () => void; close: () => void}
type CheckoutConstructor = new (options: CheckoutOptions) => CheckoutInstance;
declare global {interface Window {Razorpay?: CheckoutConstructor}}

let scriptPromise: Promise<CheckoutConstructor> | null = null;
function loadCheckout(): Promise<CheckoutConstructor> {
  if (window.Razorpay) return Promise.resolve(window.Razorpay);
  if (scriptPromise) return scriptPromise;
  const pending = new Promise<CheckoutConstructor>((resolve, reject) => {
    const script = document.createElement("script");
    const timer = window.setTimeout(() => fail(), 15_000);
    function fail() {
      window.clearTimeout(timer);
      script.remove();
      reject(new Error("Secure checkout could not load. Please try again."));
    }
    script.src = "https://checkout.razorpay.com/v1/checkout.js";
    script.async = true;
    script.referrerPolicy = "no-referrer";
    script.onerror = fail;
    script.onload = () => {
      window.clearTimeout(timer);
      if (window.Razorpay) resolve(window.Razorpay);
      else fail();
    };
    document.head.append(script);
  });
  scriptPromise = pending.catch((error: unknown) => {
    scriptPromise = null;
    throw error;
  });
  return scriptPromise;
}

/** The callback is verification input, never evidence that a form submitted. */
export async function openFormCheckout(checkout: Checkout, organizerName: string,
  signal: AbortSignal): Promise<FormCheckoutCallback | null> {
  if (checkout.expiresAtMillis <= Date.now()) {
    throw new Error("This checkout has expired. Check payment status first.");
  }
  const Razorpay = await loadCheckout();
  if (signal.aborted) return null;
  return new Promise((resolve, reject) => {
    let done = false;
    const settle = (value: FormCheckoutCallback | null) => {
      if (done) return;
      done = true;
      signal.removeEventListener("abort", abort);
      resolve(value);
    };
    const instance = new Razorpay({key: checkout.publicToken,
      order_id: checkout.orderId, amount: checkout.amountPaise, currency: "INR",
      name: organizerName, description: checkout.description,
      handler: (result) => {
        if (result.razorpay_order_id !== checkout.orderId ||
            !/^pay_[A-Za-z0-9]+$/u.test(result.razorpay_payment_id) ||
            !/^[a-fA-F0-9]{64}$/u.test(result.razorpay_signature)) {
          if (done) return;
          done = true;
          signal.removeEventListener("abort", abort);
          reject(new Error("Payment is being checked. Please check its status."));
          return;
        }
        settle({paymentId: result.razorpay_payment_id,
          signature: result.razorpay_signature});
      }, modal: {ondismiss: () => settle(null)},
    });
    function abort() {instance.close(); settle(null);}
    signal.addEventListener("abort", abort, {once: true});
    instance.open();
  });
}
