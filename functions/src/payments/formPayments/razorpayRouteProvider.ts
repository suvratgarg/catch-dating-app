import {RazorpayPaymentProvider, assertAmount, assertToken, invalidInput,
  invalidResponse, providerId, type FormPaymentOrder} from
  "./razorpayPaymentProvider";

export interface RazorpayRouteTerms {
  paymentAmountMinor: number;
  destinationAccountId: string;
  transferAmountMinor: number;
  settlementHold: boolean;
}

/** Platform credentials and explicit frozen transfer terms, without OAuth.
 * The token argument is the bound public key handle, never a merchant token.
 * The caller owns eligibility and durable order/refund idempotency.
 */
export class RazorpayRouteProvider extends RazorpayPaymentProvider {
  private readonly terms: Readonly<RazorpayRouteTerms>;

  constructor(input: {keyId: string; keySecret: string;
    mode: "test" | "live"; terms: RazorpayRouteTerms},
  fetchImpl: typeof fetch = fetch) {
    if (input.mode !== "test" && input.mode !== "live") invalidInput();
    if (!new RegExp(`^rzp_${input.mode}_[A-Za-z0-9]+$`, "u")
      .test(input.keyId)) invalidInput();
    assertToken(input.keySecret);
    providerId(input.terms.destinationAccountId, "acc_");
    assertAmount(input.terms.transferAmountMinor);
    assertAmount(input.terms.paymentAmountMinor);
    if (input.terms.transferAmountMinor > input.terms.paymentAmountMinor) {
      invalidInput();
    }
    if (typeof input.terms.settlementHold !== "boolean") invalidInput();
    const {keyId, keySecret} = input;
    super({signatureSecret: keySecret, authorization: (handle) => {
      if (handle !== keyId) invalidInput();
      return `Basic ${Buffer.from(`${keyId}:${keySecret}`).toString("base64")}`;
    }}, fetchImpl);
    this.terms = Object.freeze({...input.terms});
  }

  override async createOrder(handle: string,
    input: {amount: number; receipt: string}): Promise<FormPaymentOrder> {
    if (input.amount !== this.terms.paymentAmountMinor) invalidInput();
    const order = await super.createOrder(handle, input);
    // A successful POST does not prove that the intended transfer was attached.
    return this.verifiedOrder(handle, order.id, true);
  }

  override async findOrderByReceipt(handle: string, receipt: string):
    Promise<FormPaymentOrder | null> {
    const order = await super.findOrderByReceipt(handle, receipt);
    return order ? this.fetchOrder(handle, order.id) : null;
  }

  override async fetchOrder(handle: string, orderId: string):
    Promise<FormPaymentOrder> {
    return this.verifiedOrder(handle, orderId, false);
  }

  override async refundPayment(handle: string, input: {
    paymentId: string; amount: number; idempotencyKey: string;
  }) {
    // reverse_all is appropriate for full failed-fulfillment refunds. Partial
    // refunds require a separate allocation/reversal plan, not this operation.
    if (input.amount !== this.terms.paymentAmountMinor) invalidInput();
    return super.refundPayment(handle, input);
  }

  private async verifiedOrder(handle: string, orderId: string,
    checkInitialHold: boolean): Promise<FormPaymentOrder> {
    // Validate the ordinary order and its expanded transfer separately. The
    // unfiltered expansion must include the single intended transfer even after
    // settlement or reversal. A missing/extra transfer requires review.
    const order = await super.fetchOrder(handle, orderId);
    const expanded = await this.api(handle,
      `/v1/orders/${orderId}?expand[]=transfers`, "GET");
    if (order.amount !== this.terms.paymentAmountMinor ||
        expanded.id !== order.id || expanded.amount !== order.amount ||
        expanded.currency !== order.currency ||
        expanded.receipt !== order.receipt) invalidResponse();
    const transfers = expanded.transfers;
    if (!record(transfers) || transfers.entity !== "collection" ||
        transfers.count !== 1 || !Array.isArray(transfers.items) ||
        transfers.items.length !== 1) invalidResponse();
    const transfer = transfers.items[0];
    if (!record(transfer) || transfer.entity !== "transfer" ||
        transfer.source !== orderId ||
        transfer.recipient !== this.terms.destinationAccountId ||
        transfer.amount !== this.terms.transferAmountMinor ||
        transfer.currency !== "INR" ||
        typeof transfer.amount_reversed !== "number" ||
        !Number.isSafeInteger(transfer.amount_reversed) ||
        transfer.amount_reversed < 0 ||
        transfer.amount_reversed > this.terms.transferAmountMinor) {
      invalidResponse();
    }
    if (checkInitialHold &&
        (transfer.on_hold !== this.terms.settlementHold ||
          this.terms.settlementHold && transfer.on_hold_until !== null)) {
      invalidResponse();
    }
    providerId(transfer.id, "trf_");
    return order;
  }

  protected override orderFields(amount: number): Record<string, unknown> {
    if (this.terms.transferAmountMinor > amount) invalidInput();
    return {transfers: [{account: this.terms.destinationAccountId,
      amount: this.terms.transferAmountMinor, currency: "INR",
      on_hold: this.terms.settlementHold}]};
  }

  protected override refundFields(): Record<string, unknown> {
    // Full failed-fulfillment refunds must recover the organizer transfer too.
    // A rejected reversal remains pending/review, never silently self-funded.
    return {reverse_all: true};
  }
}

function record(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value);
}
