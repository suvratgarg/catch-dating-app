export interface OfferCredential {readonly token?: string; readonly paymentId?: string; readonly grantId?: string; readonly instance: string}
let current: OfferCredential | null = null;

/** Strip the fragment synchronously, before rendering or loading analytics. */
export function captureOfferCredential(location: Pick<Location, "pathname" | "hash">,
  replace: (path: string) => void, historyState?: unknown): OfferCredential | null {
  if (location.pathname !== "/offer" && location.pathname !== "/offer/") return null;
  if (location.hash) {
    const token = location.hash.slice(1);
    current = token === current?.token ? current : /^[A-Za-z0-9_-]{43}$/u.test(token) ?
      {token, instance: crypto.randomUUID()} : null;
    replace(location.pathname);
    return current;
  }
  if (!current && historyState && typeof historyState === "object") {
    const id = (historyState as Record<string, unknown>).catchOfferPaymentId;
    if (typeof id === "string" && /^ep_[a-f0-9]{32}$/u.test(id)) {
      current = {paymentId: id, instance: crypto.randomUUID()};
    } else {
      const grantId = (historyState as Record<string, unknown>).catchOfferGrantId;
      if (typeof grantId === "string" && /^[a-f0-9]{64}$/u.test(grantId)) {
        current = {grantId, instance: crypto.randomUUID()};
      }
    }
  }
  return current;
}

/** A non-secret reference survives reload; the API still enforces payer UID.
 * Neither the invitation token nor payment details enter browser storage.
 */
export function rememberOfferPayment(paymentId: string) {
  if (!/^ep_[a-f0-9]{32}$/u.test(paymentId) ||
      !["/offer", "/offer/"].includes(window.location.pathname)) return;
  try {
    window.history.replaceState({...window.history.state, catchOfferPaymentId: paymentId}, "");
  } catch { /* Recovery hint is optional; reopening the original link also works. */ }
}

export function rememberOfferGrant(grantId: string) {
  if (!/^[a-f0-9]{64}$/u.test(grantId) ||
      !["/offer", "/offer/"].includes(window.location.pathname)) return;
  try {
    window.history.replaceState({...window.history.state, catchOfferGrantId: grantId}, "");
  } catch { /* Reopening the original invitation remains the recovery path. */ }
}
