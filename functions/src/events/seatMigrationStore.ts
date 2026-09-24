/** Canonical server-only seat bootstrap entry point. */
export {bootstrapEventSeatLedgerPaged as bootstrapEventSeatLedger} from
  "./seatMigrationPaged";
export type {PagedSeatBootstrapCommand as SeatMigrationBootstrapCommand,
  PagedSeatBootstrapDeps as SeatMigrationStoreDependencies} from
  "./seatMigrationPaged";
