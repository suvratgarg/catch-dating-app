import type {App} from "firebase-admin/app";
import {Firestore, getFirestore} from "firebase-admin/firestore";

const configured = new WeakSet<Firestore>();

/** Emulator fixtures use code-aware gRPC stream retries so transaction aborts
 * reach the transaction runner instead of replaying a closed transaction.
 * Production clients retain their existing transport settings.
 */
export function getEmulatorFirestore(app?: App): Firestore {
  const host = process.env.FIRESTORE_EMULATOR_HOST ?? "";
  const match =
    /^(?:127\.0\.0\.1|localhost|\[::1\]):([1-9]\d{0,4})$/u.exec(host);
  if (!match || Number(match[1]) > 65535) {
    throw new Error("A local Firestore emulator is required.");
  }

  const db = app ? getFirestore(app) : getFirestore();
  if (!configured.has(db)) {
    db.settings({gaxServerStreamingRetries: true});
    configured.add(db);
  }
  return db;
}
