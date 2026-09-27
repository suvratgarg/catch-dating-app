import * as admin from "firebase-admin";
import {createHash} from "node:crypto";
import type {Request, Response} from "express";
import {HttpsError} from "firebase-functions/v2/https";
import {adminRolesFromToken} from "../admin/adminAuth";
import type {SalesPrincipal} from "../admin/sales/types";
import {ASSISTANT_ACTIONS, READ_ACTIONS, WRITE_ACTIONS} from "./actions";
import {SALES_ASSISTANT_OPENAPI} from "./openapi";

const ID = /^[A-Za-z0-9_-]{3,128}$/u;
const REQUEST_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$/u;
const MAX_BODY_BYTES = 16_384;

export interface AssistantPrincipal {
  uid: string;
  roles: readonly string[];
  clientId: string;
  clientAuthUid: string;
  delegationId: string;
  organizerIds: readonly string[];
  allowedActions: readonly string[];
  fieldIds: readonly string[];
  readEndpoints: false;
}

export interface AssistantAuthorization {
  authorizeInTransaction(
    tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
    principal: SalesPrincipal, action: string,
    organizerId: string | null, fieldId?: string | null
  ): Promise<void>;
  authorizeRead(
    db: FirebaseFirestore.Firestore, principal: SalesPrincipal,
    action: string, organizerId: string | null,
    fieldId?: string | null
  ): Promise<void>;
}

export interface AssistantGatewayDeps {
  db: FirebaseFirestore.Firestore;
  verifyIdToken(token: string): Promise<{uid: string}>;
  getUser(uid: string): Promise<{
    disabled: boolean; customClaims?: Record<string, unknown>;
  }>;
  executeRead(
    db: FirebaseFirestore.Firestore, principal: AssistantPrincipal,
    action: string, payload: Record<string, unknown>,
    authorization: AssistantAuthorization
  ): Promise<unknown>;
  executeAction(
    db: FirebaseFirestore.Firestore, principal: AssistantPrincipal,
    action: string, payload: Record<string, unknown>, now: Date,
    authorization: AssistantAuthorization
  ): Promise<unknown>;
  now(): Date;
}

export const firebaseAssistantGatewayDeps = {
  db: () => admin.firestore(),
  verifyIdToken: (token: string) => admin.auth().verifyIdToken(token, true),
  getUser: (uid: string) => admin.auth().getUser(uid),
  now: () => new Date(),
};

class GatewayError extends Error {
  constructor(public readonly status: number, message: string) {
    super(message);
  }
}

function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new GatewayError(400, "Expected an object payload.");
  }
  return value as Record<string, unknown>;
}

function id(value: unknown): string {
  if (typeof value !== "string" || !ID.test(value)) {
    throw new GatewayError(400, "Invalid identifier.");
  }
  return value;
}

function token(header: unknown, prefix: string): string {
  if (typeof header !== "string" || !header.startsWith(prefix)) {
    throw new GatewayError(401, "Authentication required.");
  }
  const value = header.slice(prefix.length);
  if (!/^[A-Za-z0-9._-]{32,8192}$/u.test(value)) {
    throw new GatewayError(401, "Invalid authentication token.");
  }
  return value;
}

async function verifiedUid(value: string,
  deps: Pick<AssistantGatewayDeps, "verifyIdToken">): Promise<string> {
  try {
    return (await deps.verifyIdToken(value)).uid;
  } catch {
    throw new GatewayError(401, "Invalid Firebase identity.");
  }
}

function strings(value: unknown, max: number): string[] {
  if (!Array.isArray(value) || value.length === 0 || value.length > max ||
      value.some((part) => typeof part !== "string" || !ID.test(part))) {
    throw new GatewayError(403, "Delegation scope is invalid.");
  }
  return [...new Set(value as string[])];
}

function fieldScope(value: unknown): string[] {
  if (value === undefined ||
      (Array.isArray(value) && value.length === 0)) return [];
  if (!Array.isArray(value) || value.length > 50 ||
      value.some((part) => typeof part !== "string" ||
        part.length > 96 || !/^sales\.[A-Za-z0-9._:-]+$/u.test(part))) {
    throw new GatewayError(403, "Delegation field scope is invalid.");
  }
  return [...new Set(value as string[])];
}

function actions(value: unknown): string[] {
  if (!Array.isArray(value) || value.length === 0 || value.length > 20 ||
      value.some((part) => typeof part !== "string" ||
        !ASSISTANT_ACTIONS.includes(part))) {
    throw new GatewayError(403, "Delegation actions are invalid.");
  }
  return [...new Set(value as string[])];
}

function sameScope(a: readonly string[], b: readonly string[]): boolean {
  return a.length === b.length && a.every((value) => b.includes(value));
}

function expiry(value: unknown): number {
  if (typeof value === "string") return Date.parse(value);
  if (value && typeof value === "object" && "toMillis" in value &&
      typeof (value as {toMillis: unknown}).toMillis === "function") {
    return (value as {toMillis: () => number}).toMillis();
  }
  return Number.NaN;
}

function positiveInteger(value: unknown, ceiling: number): number {
  if (!Number.isInteger(value) || typeof value !== "number" ||
      value < 1 || value > ceiling) {
    throw new GatewayError(403, "Delegation budget is invalid.");
  }
  return value;
}

async function ownerUid(req: Request, deps: AssistantGatewayDeps):
  Promise<string> {
  const bearer = token(req.headers.authorization, "Bearer ");
  const uid = await verifiedUid(bearer, deps);
  const user = await deps.getUser(uid);
  if (user.disabled || user.customClaims?.adminOwner !== true) {
    throw new GatewayError(403, "Current admin owner required.");
  }
  return uid;
}

async function manageDelegation(req: Request, deps: AssistantGatewayDeps):
  Promise<unknown> {
  const issuerUid = await ownerUid(req, deps);
  const body = object(req.body);
  if (Buffer.byteLength(JSON.stringify(body), "utf8") > MAX_BODY_BYTES) {
    throw new GatewayError(413, "Payload is too large.");
  }
  const now = deps.now();
  await chargeBudget(deps.db, {uid: issuerUid, roles: ["adminOwner"],
    clientId: "owner", clientAuthUid: issuerUid,
    delegationId: issuerUid, organizerIds: [],
    allowedActions: [], fieldIds: [], readEndpoints: false},
  {perMinute: 10, perDay: 100}, now);
  if (req.method === "PUT" &&
      /^\/v1\/clients\/[A-Za-z0-9_-]{3,128}$/u.test(req.path)) {
    const clientId = id(req.path.slice("/v1/clients/".length));
    const authUid = id(body.authUid);
    if (Object.keys(body).some((key) =>
      !["authUid", "active"].includes(key)) ||
      typeof body.active !== "boolean" || authUid === issuerUid) {
      throw new GatewayError(400, "Invalid client registration.");
    }
    const user = await deps.getUser(authUid);
    if (user.disabled || adminRolesFromToken(user.customClaims).length > 0) {
      throw new GatewayError(403,
        "Client must be a separate non-admin account.");
    }
    const ref = deps.db.collection("assistantClients").doc(clientId);
    await deps.db.runTransaction(async (tx) => {
      const existing = await tx.get(ref);
      if (existing.exists && existing.data()?.authUid !== authUid) {
        throw new GatewayError(409, "Client identity cannot be reassigned.");
      }
      tx.set(ref, {authUid, active: body.active,
        updatedByUid: issuerUid, updatedAt: now.toISOString()});
    });
    return {clientId, authUid, active: body.active};
  }
  if (req.method === "POST" && req.path === "/v1/delegations") {
    if (Object.keys(body).some((key) => ![
      "delegationId", "actorUid", "clientId", "allowedActions",
      "organizerIds", "fieldIds", "expiresAt", "maxRequestsPerMinute",
      "maxRequestsPerDay",
    ].includes(key))) {
      throw new GatewayError(400, "Unknown delegation field.");
    }
    const delegationId = id(body.delegationId);
    const actorUid = id(body.actorUid);
    const clientId = id(body.clientId);
    const allowedActions = actions(body.allowedActions);
    const organizerIds = strings(body.organizerIds, 30);
    const fieldIds = fieldScope(body.fieldIds);
    const expiresAt = expiry(body.expiresAt);
    const maxRequestsPerMinute = positiveInteger(
      body.maxRequestsPerMinute, 60);
    const maxRequestsPerDay = positiveInteger(body.maxRequestsPerDay, 1000);
    if (!Number.isFinite(expiresAt) || expiresAt <= now.getTime() ||
        expiresAt > now.getTime() + 7 * 86_400_000) {
      throw new GatewayError(400, "Invalid delegation scope or expiry.");
    }
    const [actor, clientDoc] = await Promise.all([
      deps.getUser(actorUid),
      deps.db.collection("assistantClients").doc(clientId).get(),
    ]);
    const actorRoles = adminRolesFromToken(actor.customClaims);
    if (actor.disabled || !actorRoles.some((role) =>
      role === "admin" || role === "adminOwner") ||
      clientDoc.data()?.active !== true) {
      throw new GatewayError(403, "Employee and client must be active.");
    }
    const ref = deps.db.collection("assistantDelegations").doc(delegationId);
    try {
      await ref.create({actorUid, clientId, allowedActions, organizerIds,
        fieldIds, expiresAt: new Date(expiresAt).toISOString(),
        maxRequestsPerMinute, maxRequestsPerDay, revoked: false,
        issuedByUid: issuerUid, issuedAt: now.toISOString()});
    } catch (error) {
      if (error && typeof error === "object" && "code" in error &&
          (error as {code: unknown}).code === 6) {
        throw new GatewayError(409, "Delegation already exists.");
      }
      throw error;
    }
    return {delegationId, actorUid, clientId, allowedActions,
      organizerIds, fieldIds, expiresAt: new Date(expiresAt).toISOString()};
  }
  const revoke = /^\/v1\/delegations\/([A-Za-z0-9_-]{3,128})\/revoke$/u
    .exec(req.path);
  if (req.method === "POST" && revoke) {
    if (Object.keys(body).length !== 0) {
      throw new GatewayError(400, "Revoke payload must be empty.");
    }
    const ref = deps.db.collection("assistantDelegations").doc(revoke[1]);
    if (!(await ref.get()).exists) {
      throw new GatewayError(404, "Delegation not found.");
    }
    await ref.update({revoked: true, revokedByUid: issuerUid,
      revokedAt: now.toISOString()});
    return {delegationId: revoke[1], revoked: true};
  }
  throw new GatewayError(404, "Unknown endpoint.");
}

function assertPayload(action: string, payload: Record<string, unknown>,
  principal: AssistantPrincipal): void {
  if (Buffer.byteLength(JSON.stringify(payload), "utf8") >
      MAX_BODY_BYTES) {
    throw new GatewayError(413, "Payload is too large.");
  }
  if (WRITE_ACTIONS.includes(action as typeof WRITE_ACTIONS[number])) {
    if (typeof payload.requestId !== "string" ||
        !REQUEST_ID.test(payload.requestId)) {
      throw new GatewayError(400, "A stable requestId is required.");
    }
  }
  const requestedOrg = payload.organizerId;
  if (requestedOrg !== undefined &&
      (typeof requestedOrg !== "string" ||
       !principal.organizerIds.includes(requestedOrg))) {
    throw new GatewayError(403, "Host is outside delegation.");
  }
  if (action === "hosts.search" && payload.limit !== undefined &&
      (!Number.isInteger(payload.limit) ||
       (payload.limit as number) < 1 || (payload.limit as number) > 50)) {
    throw new GatewayError(400, "Search limit must be 1 through 50.");
  }
  if (action === "fields.setValue" &&
      (typeof payload.fieldId !== "string" ||
       !principal.fieldIds.includes(payload.fieldId))) {
    throw new GatewayError(403, "Field is outside delegation.");
  }
  if (action === "fields.create" &&
      (!principal.allowedActions.includes("fields.create") ||
       !payload.field || typeof payload.field !== "object" ||
       Array.isArray(payload.field))) {
    throw new GatewayError(403, "A private sales field is required.");
  }
  // No assistant route may alter protected product or sales authority fields.
  for (const key of ["assignedUid", "paymentStatus",
    "suppression", "scorePolicy", "publicVisibility", "publish",
    "sendMessage", "claimStatus"]) {
    if (key in payload ||
        (payload.fields && typeof payload.fields === "object" &&
         key in payload.fields) ||
        (payload.field && typeof payload.field === "object" &&
         key in payload.field)) {
      throw new GatewayError(403, "Protected field.");
    }
  }
}

/** Revalidates live delegation immediately before a domain read or commit. */
export function createSalesAssistantAuthorization(
  deps: Pick<AssistantGatewayDeps, "getUser" | "now" | "verifyIdToken">,
  clientToken: string
): AssistantAuthorization {
  const verify = async (db: FirebaseFirestore.Firestore,
    principal: SalesPrincipal, action: string,
    organizerId: string | null, fieldId: string | null | undefined,
    tx?: FirebaseFirestore.Transaction): Promise<void> => {
    if (!principal.clientId || !principal.clientAuthUid ||
        !principal.delegationId) {
      throw new GatewayError(403, "Delegation identity required.");
    }
    if (await verifiedUid(clientToken, deps) !== principal.clientAuthUid) {
      throw new GatewayError(403, "Client identity changed.");
    }
    const clientRef = db.collection("assistantClients").doc(principal.clientId);
    const delegationRef = db.collection("assistantDelegations")
      .doc(principal.delegationId);
    const [currentClient, currentDelegation] = await Promise.all([
      tx ? tx.get(clientRef) : clientRef.get(),
      tx ? tx.get(delegationRef) : delegationRef.get(),
    ]);
    const liveClient = currentClient.data();
    const liveDelegation = currentDelegation.data();
    const [currentEmployee, currentClientUser] = await Promise.all([
      deps.getUser(principal.uid), deps.getUser(principal.clientAuthUid),
    ]);
    const currentRoles = adminRolesFromToken(currentEmployee.customClaims);
    if (!liveClient || liveClient.active !== true ||
        liveClient.authUid !== principal.clientAuthUid || !liveDelegation ||
        liveDelegation.revoked === true ||
        liveDelegation.actorUid !== principal.uid ||
        liveDelegation.clientId !== principal.clientId ||
        !(expiry(liveDelegation.expiresAt) > deps.now().getTime()) ||
        currentEmployee.disabled || currentClientUser.disabled ||
        adminRolesFromToken(currentClientUser.customClaims).length > 0 ||
        !currentRoles.some((role) =>
          role === "admin" || role === "adminOwner") ||
        !sameScope(principal.allowedActions ?? [],
          actions(liveDelegation.allowedActions)) ||
        !sameScope(principal.organizerIds ?? [],
          strings(liveDelegation.organizerIds, 30)) ||
        !sameScope(principal.fieldIds ?? [],
          fieldScope(liveDelegation.fieldIds)) ||
        !actions(liveDelegation.allowedActions).includes(action) ||
        (organizerId !== null &&
          !strings(liveDelegation.organizerIds, 30).includes(organizerId)) ||
        (fieldId !== null && fieldId !== undefined &&
          !fieldScope(liveDelegation.fieldIds).includes(fieldId))) {
      throw new GatewayError(403, "Delegation changed before execution.");
    }
  };
  return {
    authorizeInTransaction: (tx, db, principal, action, organizerId,
      fieldId) => verify(db, principal, action, organizerId, fieldId, tx),
    authorizeRead: (db, principal, action, organizerId, fieldId) =>
      verify(db, principal, action, organizerId, fieldId),
  };
}

async function principalFor(req: Request, deps: AssistantGatewayDeps,
  action: string): Promise<{principal: AssistantPrincipal;
    perMinute: number; perDay: number}> {
  const clientToken = token(req.headers.authorization, "Bearer ");
  const clientId = id(req.headers["x-assistant-client-id"]);
  const delegationId = id(req.headers["x-assistant-delegation-id"]);
  const clientUid = await verifiedUid(clientToken, deps);
  const clientRef = deps.db.collection("assistantClients").doc(clientId);
  const delegationRef = deps.db.collection("assistantDelegations")
    .doc(delegationId);
  const [clientDoc, delegationDoc] = await Promise.all([
    clientRef.get(), delegationRef.get(),
  ]);
  const clientRecord = clientDoc.data();
  const delegation = delegationDoc.data();
  if (!clientRecord || clientRecord.active !== true ||
      clientRecord.authUid !== clientUid || !delegation ||
      typeof delegation.actorUid !== "string" ||
      !ID.test(delegation.actorUid)) {
    throw new GatewayError(403, "Active delegation required.");
  }
  const employeeUid = delegation.actorUid;
  if (employeeUid === clientUid) {
    throw new GatewayError(403, "Separate client identity required.");
  }
  const [employeeUser, clientUser] = await Promise.all([
    deps.getUser(employeeUid), deps.getUser(clientUid),
  ]);
  const roles = adminRolesFromToken(employeeUser.customClaims);
  if (employeeUser.disabled || clientUser.disabled ||
      adminRolesFromToken(clientUser.customClaims).length > 0 ||
      !roles.some((role) => role === "admin" || role === "adminOwner")) {
    throw new GatewayError(403, "Current employee authority required.");
  }
  if (delegation.revoked === true ||
      delegation.actorUid !== employeeUid ||
      delegation.clientId !== clientId ||
      !(expiry(delegation.expiresAt) > deps.now().getTime())) {
    throw new GatewayError(403, "Active delegation required.");
  }
  const allowedActions = actions(delegation.allowedActions);
  if (!allowedActions.includes(action)) {
    throw new GatewayError(403, "Action is outside delegation.");
  }
  const organizerIds = strings(delegation.organizerIds, 30);
  const fieldIds = fieldScope(delegation.fieldIds);
  return {
    principal: {uid: employeeUid, roles, clientId, clientAuthUid: clientUid,
      delegationId,
      organizerIds, allowedActions, fieldIds, readEndpoints: false,
    },
    perMinute: positiveInteger(delegation.maxRequestsPerMinute, 60),
    perDay: positiveInteger(delegation.maxRequestsPerDay, 1000),
  };
}

async function chargeBudget(db: FirebaseFirestore.Firestore,
  principal: AssistantPrincipal, limits: {perMinute: number; perDay: number},
  now: Date): Promise<void> {
  const digest = createHash("sha256")
    .update(`${principal.clientId}:${principal.delegationId}`)
    .digest("hex").slice(0, 40);
  const minute = Math.floor(now.getTime() / 60_000);
  const day = now.toISOString().slice(0, 10);
  const refs = [
    db.collection("assistantGatewayBudgets").doc(`${digest}_m_${minute}`),
    db.collection("assistantGatewayBudgets").doc(`${digest}_d_${day}`),
  ];
  await db.runTransaction(async (tx) => {
    const snapshots = await Promise.all(refs.map((ref) => tx.get(ref)));
    if (snapshots.some((snap, index) =>
      (snap.data()?.count ?? 0) >=
      (index === 0 ? limits.perMinute : limits.perDay))) {
      throw new GatewayError(429, "Delegation budget reached.");
    }
    refs.forEach((ref, index) => tx.set(ref, {
      count: (snapshots[index].data()?.count ?? 0) + 1,
      expiresAt: admin.firestore.Timestamp.fromMillis(now.getTime() +
        (index === 0 ? 120_000 : 172_800_000)),
    }));
  });
}

/** Versioned HTTP adapter sharing the Admin sales services. */
export function createSalesAssistantGateway(deps: AssistantGatewayDeps) {
  return async (req: Request, res: Response): Promise<void> => {
    res.set("Cache-Control", "no-store");
    res.set("X-Content-Type-Options", "nosniff");
    try {
      if (req.method === "GET" && req.path === "/v1/openapi.json") {
        res.status(200).json(SALES_ASSISTANT_OPENAPI);
        return;
      }
      if (req.path.startsWith("/v1/delegations") ||
          req.path.startsWith("/v1/clients/")) {
        if (!req.is("application/json")) {
          throw new GatewayError(415, "JSON required.");
        }
        res.status(200).json({schemaVersion: 1,
          result: await manageDelegation(req, deps)});
        return;
      }
      if (req.method !== "POST" ||
          !/^\/v1\/actions\/[a-z]+\.[A-Za-z]+$/u.test(req.path)) {
        throw new GatewayError(404, "Unknown endpoint.");
      }
      const action = req.path.slice("/v1/actions/".length);
      if (!ASSISTANT_ACTIONS.includes(action)) {
        throw new GatewayError(404, "Unknown action.");
      }
      if (!req.is("application/json")) {
        throw new GatewayError(415, "JSON required.");
      }
      const payload = object(req.body);
      const scope = await principalFor(req, deps, action);
      const authorization = createSalesAssistantAuthorization(
        deps, token(req.headers.authorization, "Bearer "));
      assertPayload(action, payload, scope.principal);
      await chargeBudget(deps.db, scope.principal, scope, deps.now());
      const isRead = READ_ACTIONS.includes(
        action as typeof READ_ACTIONS[number]);
      const result = isRead ?
        await deps.executeRead(deps.db, scope.principal, action, payload,
          authorization) :
        await deps.executeAction(
          deps.db, scope.principal, action, payload, deps.now(), authorization);
      if (isRead) {
        await authorization.authorizeRead(deps.db, scope.principal, action,
          typeof payload.organizerId === "string" ? payload.organizerId : null);
      }
      res.status(200).json({schemaVersion: 1, asOf: deps.now().toISOString(),
        result});
    } catch (error) {
      const status = error instanceof GatewayError ? error.status :
        error instanceof HttpsError ? ({
          "invalid-argument": 400, "unauthenticated": 401,
          "permission-denied": 403, "not-found": 404,
          "already-exists": 409, "aborted": 409,
          "failed-precondition": 409, "resource-exhausted": 429,
        } as Record<string, number>)[error.code] ?? 503 : 503;
      res.status(status).json({error: error instanceof GatewayError ||
        error instanceof HttpsError ? error.message :
        "Assistant gateway unavailable."});
    }
  };
}
