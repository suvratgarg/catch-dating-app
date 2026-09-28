import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {executeSalesAction, executeSalesRead} from "../admin/sales/service";
import type {
  SalesMutationAction, SalesReadAction,
} from "../admin/sales/types";
import {createSalesAssistantGateway} from "./gateway";

/** Deploy after server-only Firestore rules and client onboarding review. */
export const salesAssistant = onRequest({
  region: "asia-south1", invoker: "public", cors: false,
  maxInstances: 10, timeoutSeconds: 30,
}, (req, res) => createSalesAssistantGateway({
  db: admin.firestore(),
  verifyIdToken: (token) => admin.auth().verifyIdToken(token, true),
  getUser: (uid) => admin.auth().getUser(uid),
  executeRead: (db, principal, action, payload, authorization) =>
    executeSalesRead(principal, action as SalesReadAction, payload, {
      firestore: () => db, now: () => new Date(),
      ...authorization,
    }),
  executeAction: (db, principal, action, payload, now, authorization) =>
    executeSalesAction(principal, action as SalesMutationAction, payload, {
      firestore: () => db, now: () => now,
      ...authorization,
    }),
  now: () => new Date(),
})(req, res));
