import type {Firestore, Transaction} from "firebase-admin/firestore";

/**
 * Consent callbacks contain only transactional reads and staged writes.
 * Firestore's SDK retries ABORTED and expired transactions, but does not
 * recognize the emulator's exact closed-transaction INVALID_ARGUMENT reply.
 * Normalize that callback failure into the existing bounded SDK retry loop.
 * Commit failures are deliberately outside this catch; their outcome may be
 * uncertain and must be resolved by the caller's immutable request receipt.
 */
export function runPreferenceTransaction<T>(db: Firestore,
  update: (tx: Transaction) => Promise<T>): Promise<T> {
  return db.runTransaction(async (tx) => {
    try {
      return await update(tx);
    } catch (error) {
      if (error instanceof Error && "code" in error && error.code === 3 &&
          "details" in error &&
          error.details === "Transaction is invalid or closed.") {
        throw Object.assign(new Error("Consent transaction closed during read",
          {cause: error}), {code: 10}); // Firestore ABORTED; SDK owns backoff.
      }
      throw error;
    }
  });
}
