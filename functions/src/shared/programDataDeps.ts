import * as admin from "firebase-admin";
import {checkRateLimit} from "./rateLimit";

/** Data-only program handlers share these runtime seams. External providers
 * keep their own explicit dependencies and never run inside transactions.
 */
export interface ProgramDataDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

export const defaultProgramDataDeps: ProgramDataDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};
