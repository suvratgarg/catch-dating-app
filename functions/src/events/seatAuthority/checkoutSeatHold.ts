import {CanonicalSeatIdentity, SeatTransaction} from "./seatAuthority";
import {prepareSeatHold} from "./seatHold";
import type {CheckoutHoldCommand, PreparedSeatHold} from "./seatHold";
export {applySeatHold as applyCheckoutHold} from "./seatHold";
export type {CheckoutHoldCommand, CheckoutHoldOperation,
  PreparedSeatHold as PreparedCheckoutHold} from "./seatHold";

/** Prepare an owner-bound hold; apply after every caller authority read. */
export function prepareCheckoutHold<Subject>(params: {
  tx: SeatTransaction;
  command: CheckoutHoldCommand<Subject>;
  resolveIdentity: (subject: Subject) => Promise<CanonicalSeatIdentity>;
}): Promise<PreparedSeatHold> {
  return prepareSeatHold(params);
}
