import {CanonicalSeatIdentity, SeatTransaction} from "./seatAuthority";
import {prepareSeatHold} from "./seatHold";
import type {TemporaryHoldCommand, PreparedSeatHold} from "./seatHold";
export {applySeatHold as applyTemporaryHold} from "./seatHold";
export type {TemporaryHoldCommand, TemporaryHoldOperation,
  PreparedSeatHold as PreparedTemporaryHold} from "./seatHold";

/** Prepare an owner-bound hold; apply after every caller authority read. */
export function prepareTemporaryHold<Subject>(params: {
  tx: SeatTransaction;
  command: TemporaryHoldCommand<Subject>;
  resolveIdentity: (subject: Subject) => Promise<CanonicalSeatIdentity>;
}): Promise<PreparedSeatHold> {
  return prepareSeatHold(params);
}
