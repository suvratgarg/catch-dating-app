import {createHash, randomBytes} from "node:crypto";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {validateCatchWhatsappAppAuthorityDocument} from
  "../shared/generated/validators/catchWhatsappAppAuthorityDocument";
import {
  catchReadinessAuthorityBindings,
  catchReplyAuthorityBindings,
  denyCatchAppAuthority,
  finalizeCatchAppGrant,
  prepareCatchAppGrant,
  readCatchAppAuthority,
} from "./whatsappAppAuthority";
import type {
  CatchAuthorityPrincipal,
  CatchFirebaseObservation,
  CatchVerifiedSession,
  CatchCapability,
} from "./whatsappAppAuthority";

export const CATCH_APP_AUTHORITIES = "catchWhatsappAppAuthorities";
export interface CatchCurrentFirebaseAuthority {
  observe(uid: string): Promise<CatchFirebaseObservation>;
  verifySession(uid: string, idToken: string): Promise<CatchVerifiedSession>;
}
/**
 * A bounded observation, not a lock on Firebase Auth. Recheck runs immediately
 * before transaction commit. External Auth changes after that read remain a
 * documented race; durable app denials are protected by Firestore read sets.
 */
export interface CatchFreshAuthContext extends CatchAuditedAuthFence {
  recheck(): Promise<void>;
}
export async function withCatchFreshAuthContext<T>(
  firebase: CatchCurrentFirebaseAuthority,
  identity: {
    projectId: string;
    uids: string[];
    actorUid: string;
    actorIdToken: string;
  },
  callback: (context: CatchFreshAuthContext) => Promise<T>,
  now: () => number = Date.now,
): Promise<T> {
  const exact = [...new Set(identity.uids)].sort();
  if (
    exact.length !== identity.uids.length ||
    exact.length < 1 ||
    exact.length > 3 ||
    !exact.includes(identity.actorUid) ||
    !exact.every((value) => /^[A-Za-z0-9_-]{1,128}$/u.test(value)) ||
    !identity.actorIdToken ||
    !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(identity.projectId)
  ) {
    unavailable();
  }
  const began = now();
  if (!Number.isSafeInteger(began) || began < 0) unavailable();
  const first = await Promise.all(
    exact.map((value) => firebase.observe(value)),
  );
  const session = await firebase.verifySession(
    identity.actorUid,
    identity.actorIdToken,
  );
  const initialReadAt = now();
  if (
    !Number.isSafeInteger(initialReadAt) ||
    initialReadAt < began ||
    initialReadAt - began >= 30000
  ) {
    unavailable();
  }
  if (
    session.projectId !== identity.projectId ||
    session.uid !== identity.actorUid ||
    first.some(
      (value, index) =>
        value.projectId !== identity.projectId ||
        value.uid !== exact[index] ||
        value.disabled ||
        !Number.isSafeInteger(value.observedAtMillis) ||
        value.observedAtMillis < began ||
        value.observedAtMillis > initialReadAt,
    )
  ) {
    unavailable();
  }
  const fingerprint = first.map((value) =>
    JSON.stringify({
      creationTimeMillis: value.creationTimeMillis,
      disabled: value.disabled,
      relevantRoles: value.relevantRoles,
      endpointHash: value.endpointHash,
      tokensValidAfterMillis: value.tokensValidAfterMillis,
    }),
  );
  let lastObserved = initialReadAt;
  const assertHeld = () => {
    const current = now();
    if (
      !Number.isSafeInteger(current) ||
      current < lastObserved ||
      current - began >= 30000
    ) {
      unavailable();
    }
    lastObserved = current;
  };
  const recheck = async () => {
    assertHeld();
    const observed = await Promise.all(
      exact.map((value) => firebase.observe(value)),
    );
    const verified = await firebase.verifySession(
      identity.actorUid,
      identity.actorIdToken,
    );
    if (
      verified.projectId !== session.projectId ||
      verified.uid !== session.uid ||
      verified.authTimeSeconds !== session.authTimeSeconds ||
      verified.expiresAtSeconds !== session.expiresAtSeconds ||
      observed.some(
        (value, index) =>
          value.projectId !== identity.projectId ||
          value.uid !== exact[index] ||
          value.disabled ||
          !Number.isSafeInteger(value.observedAtMillis) ||
          value.observedAtMillis < began ||
          value.observedAtMillis > now() ||
          JSON.stringify({
            creationTimeMillis: value.creationTimeMillis,
            disabled: value.disabled,
            relevantRoles: value.relevantRoles,
            endpointHash: value.endpointHash,
            tokensValidAfterMillis: value.tokensValidAfterMillis,
          }) !== fingerprint[index],
      )
    ) {
      unavailable();
    }
    assertHeld();
  };
  const context: CatchFreshAuthContext = {
    projectId: identity.projectId,
    uids: exact,
    provenanceSha256: createHash("sha256")
      .update(
        JSON.stringify([
          "catch.fresh-auth/v1",
          identity.projectId,
          exact,
          fingerprint,
          began,
        ]),
      )
      .digest("hex"),
    assertHeld,
    recheck,
    readSession: async (value) => {
      if (value !== identity.actorUid) unavailable();
      return firebase.verifySession(value, identity.actorIdToken);
    },
    authorizeDenial: async () => unavailable(),
  };
  await recheck();
  const result = await callback(context);
  // A postcommit failure is uncertain and must never trigger a blind retry.
  await recheck();
  return result;
}
/**
 * Legacy protected issuer shape retained for disconnected internal commands.
 * The production callable uses CatchFreshAuthContext below. In that context
 * assertHeld checks only the bounded observation window; it does not lock
 * Firebase Auth or exclude Console/Admin SDK changes. A hash is provenance,
 * never authorization by itself.
 */
export interface CatchAuditedAuthFence {
  projectId: string;
  uids: readonly string[];
  provenanceSha256: string;
  assertHeld(): void;
  /** Current signature/revocation-verified session, from a protected source. */
  readSession(uid: string): Promise<CatchVerifiedSession>;
  /**
   * Independently authorizes this exact denial; missing authority cannot
   * grant.
   */
  authorizeDenial(actorUid: string, targetUid: string): Promise<void>;
}
/**
 * An independently operated issuer must exclude every relevant Firebase Auth
 * and role mutator, including console and Admin SDK access, until callback and
 * Firestore commit have completed. A Firestore lease, audit log, token check or
 * this interface alone cannot provide that exclusion. No issuer is configured
 * by this package; a missing issuer fails before the callback begins.
 */
export interface CatchExternalAuthFenceIssuer {
  withExclusiveFence<T>(
    identity: { projectId: string; uids: readonly string[]; nonce: string },
    callback: (
      fence: CatchAuditedAuthFence & {
        nonce: string;
        expiresAtMillis: number;
      },
    ) => Promise<T>,
  ): Promise<T>;
}

/** Validate the externally enforced fence at both sides of the full span. */
export async function withCatchExternalAuthFence<T>(
  issuer: CatchExternalAuthFenceIssuer | null,
  identity: { projectId: string; uids: string[] },
  callback: (fence: CatchAuditedAuthFence) => Promise<T>,
  now: () => number = Date.now,
): Promise<T> {
  const exact = [...new Set(identity.uids)].sort();
  const validUid = (value: string) => /^[A-Za-z0-9_-]{1,128}$/u.test(value);
  if (
    !issuer ||
    typeof issuer.withExclusiveFence !== "function" ||
    !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(identity.projectId) ||
    exact.length !== identity.uids.length ||
    exact.length < 1 ||
    exact.length > 3 ||
    !exact.every(validUid)
  ) {
    unavailable();
  }
  const nonce = randomBytes(32).toString("hex");
  return issuer.withExclusiveFence(
    {projectId: identity.projectId, uids: exact, nonce},
    async (fence) => {
      const startedAt = now();
      if (
        !fence ||
        fence.projectId !== identity.projectId ||
        fence.nonce !== nonce ||
        !Number.isSafeInteger(startedAt) ||
        startedAt < 0 ||
        !Number.isSafeInteger(fence.expiresAtMillis) ||
        fence.expiresAtMillis <= startedAt ||
        fence.expiresAtMillis - startedAt > 60000 ||
        !Array.isArray(fence.uids) ||
        JSON.stringify([...fence.uids].sort()) !== JSON.stringify(exact) ||
        !/^[a-f0-9]{64}$/u.test(fence.provenanceSha256) ||
        typeof fence.assertHeld !== "function" ||
        typeof fence.readSession !== "function" ||
        typeof fence.authorizeDenial !== "function"
      ) {
        unavailable();
      }
      const expiresAtMillis = fence.expiresAtMillis;
      let lastObserved = startedAt;
      const assertHeld = () => {
        const observed = now();
        if (
          !Number.isSafeInteger(observed) ||
          observed < lastObserved ||
          observed >= expiresAtMillis
        ) {
          unavailable();
        }
        lastObserved = observed;
        fence.assertHeld();
      };
      const guarded: CatchAuditedAuthFence = {
        projectId: fence.projectId,
        uids: [...exact],
        provenanceSha256: fence.provenanceSha256,
        assertHeld,
        readSession: async (uid) => {
          if (!exact.includes(uid)) unavailable();
          assertHeld();
          const value = await fence.readSession(uid);
          assertHeld();
          return value;
        },
        authorizeDenial: async (actorUid, targetUid) => {
          if (!exact.includes(actorUid) || !exact.includes(targetUid)) {
            unavailable();
          }
          assertHeld();
          await fence.authorizeDenial(actorUid, targetUid);
          assertHeld();
        },
      };
      assertHeld();
      const result = await callback(guarded);
      // A loss after an uncertain commit propagates. Callers must reconcile;
      // never interpret this as a definite abort or retry the mutation.
      assertHeld();
      return result;
    },
  );
}
export interface CatchAppAuthorityStoreDependencies {
  projectId: string;
  now: () => number;
  firebase: CatchCurrentFirebaseAuthority;
  withAuditedAuthFence<T>(
    identity: { projectId: string; uids: string[] },
    callback: (fence: CatchAuditedAuthFence) => Promise<T>,
  ): Promise<T>;
  withFreshAuthContext?<T>(
    identity: {
      projectId: string;
      uids: string[];
      actorUid: string;
      actorIdToken: string;
    },
    callback: (context: CatchFreshAuthContext) => Promise<T>,
  ): Promise<T>;
}
function unavailable(): never {
  throw new Error("Catch app authority unavailable.");
}
function uid(value: string): void {
  if (!/^[A-Za-z0-9_-]{1,128}$/u.test(value)) unavailable();
}

/** Same-transaction durable authority with current Firebase observations. */
export class CatchAppAuthorityStore {
  constructor(
    readonly db: Firestore,
    readonly deps: CatchAppAuthorityStoreDependencies,
  ) {}

  private identity(): void {
    if (
      Reflect.get(this.db, "projectId") !== this.deps.projectId ||
      this.db.databaseId !== "(default)" ||
      !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(this.deps.projectId) ||
      (typeof this.deps.withAuditedAuthFence !== "function" &&
        typeof this.deps.withFreshAuthContext !== "function") ||
      typeof this.deps.firebase?.observe !== "function" ||
      typeof this.deps.firebase?.verifySession !== "function"
    ) {
      unavailable();
    }
  }
  assertFence(fence: CatchAuditedAuthFence, uids: string[]): void {
    this.identity();
    if (
      !fence ||
      fence.projectId !== this.deps.projectId ||
      !/^[a-f0-9]{64}$/u.test(fence.provenanceSha256) ||
      !Array.isArray(fence.uids) ||
      new Set(fence.uids).size !== fence.uids.length ||
      !uids.every((value) => fence.uids.includes(value)) ||
      typeof fence.assertHeld !== "function" ||
      typeof fence.readSession !== "function"
    ) {
      unavailable();
    }
    fence.assertHeld();
  }

  async principal(
    tx: Transaction,
    fence: CatchAuditedAuthFence,
    value: string,
    session: "none" | "protected" | { idToken: string },
  ): Promise<CatchAuthorityPrincipal> {
    uid(value);
    this.assertFence(fence, [value]);
    const record = (
      await tx.get(this.db.collection(CATCH_APP_AUTHORITIES).doc(value))
    ).data();
    if (
      !validateCatchWhatsappAppAuthorityDocument(record) ||
      record.uid !== value ||
      record.projectId !== this.deps.projectId
    ) {
      unavailable();
    }
    readCatchAppAuthority(record);
    const auth = await this.deps.firebase.observe(value);
    const verified =
      session === "none" ?
        undefined :
        session === "protected" ?
          await fence.readSession(value) :
          await this.deps.firebase.verifySession(value, session.idToken);
    this.assertFence(fence, [value]);
    return {record, auth, ...(verified ? {session: verified} : {})};
  }
  async readinessBindings(
    tx: Transaction,
    fence: CatchAuditedAuthFence,
    scope: {
      reviewerUid: string;
      recipientUid: string;
      endpointHash: string;
    },
  ) {
    const [reviewer, recipient] = await Promise.all([
      this.principal(tx, fence, scope.reviewerUid, "protected"),
      this.principal(tx, fence, scope.recipientUid, "none"),
    ]);
    this.assertFence(fence, [scope.reviewerUid, scope.recipientUid]);
    return catchReadinessAuthorityBindings(
      {...scope, projectId: this.deps.projectId, reviewer, recipient},
      this.deps.now(),
    );
  }
  async replyAuthorization(
    tx: Transaction,
    fence: CatchAuditedAuthFence,
    scope: {
      actorUid: string;
      reviewerUid: string;
      recipientUid: string;
      endpointHash: string;
    },
    idToken: string,
  ) {
    const [actor, reviewer, recipient] = await Promise.all([
      this.principal(tx, fence, scope.actorUid, {idToken}),
      this.principal(tx, fence, scope.reviewerUid, "protected"),
      this.principal(tx, fence, scope.recipientUid, "none"),
    ]);
    this.assertFence(fence, [
      scope.actorUid,
      scope.reviewerUid,
      scope.recipientUid,
    ]);
    const bindings = catchReplyAuthorityBindings(
      {
        ...scope,
        projectId: this.deps.projectId,
        actor,
        reviewer,
        recipient,
      },
      this.deps.now(),
    );
    // Pure authorization above has already validated these protected shapes.
    const expiresAtMillis = Math.min(
      (actor.session as CatchVerifiedSession).expiresAtSeconds * 1000,
      (reviewer.session as CatchVerifiedSession).expiresAtSeconds * 1000,
      ...[actor, reviewer, recipient].map(
        (entry) =>
          (entry.auth as CatchFirebaseObservation).observedAtMillis + 30000,
      ),
    );
    return {bindings, expiresAtMillis};
  }

  async runFenced<T>(
    uids: string[],
    callback: (tx: Transaction, fence: CatchAuditedAuthFence) => Promise<T>,
    actor?: {
      uid: string;
      idToken: string;
    },
  ): Promise<T> {
    this.identity();
    const exact = [...new Set(uids)].sort();
    if (exact.length < 1 || exact.length > 3) unavailable();
    exact.forEach(uid);
    const execute = async (fence: CatchAuditedAuthFence) => {
      this.assertFence(fence, exact);
      for (let attempt = 0; ; attempt++) {
        let callbackFailed = false;
        let result: T;
        try {
          result = await this.db.runTransaction(
            async (tx) => {
              try {
                this.assertFence(fence, exact);
                const value = await callback(tx, fence);
                this.assertFence(fence, exact);
                return value;
              } catch (error) {
                callbackFailed = true;
                throw error;
              }
            },
            {maxAttempts: 1},
          );
        } catch (error) {
          // Unknown commits never retry. The current SDK has no reviewed
          // definite-abort classifier; ordinary production code 10
          // fails closed.
          if (
            callbackFailed ||
            attempt >= 2 ||
            !error ||
            typeof error !== "object" ||
            !("code" in error) ||
            error.code !== 10 ||
            !("definiteNonCommit" in error) ||
            error.definiteNonCommit !== true
          ) {
            throw error;
          }
          continue;
        }
        // Postcommit observation failure is uncertain, never a
        // definite abort/retry.
        this.assertFence(fence, exact);
        return result;
      }
    };
    if (this.deps.withFreshAuthContext) {
      if (!actor || !exact.includes(actor.uid)) unavailable();
      return this.deps.withFreshAuthContext(
        {
          projectId: this.deps.projectId,
          uids: exact,
          actorUid: actor.uid,
          actorIdToken: actor.idToken,
        },
        execute,
      );
    }
    return this.deps.withAuditedAuthFence(
      {projectId: this.deps.projectId, uids: exact},
      execute,
    );
  }

  /**
   * Internal command, no deployed export/bootstrap or client authority
   * writer.
   */
  async deny(actorUid: string, targetUid: string, expectedRevision: number) {
    return this.runFenced([actorUid, targetUid], async (tx, fence) => {
      if (typeof fence.authorizeDenial !== "function") unavailable();
      await fence.authorizeDenial(actorUid, targetUid);
      const ref = this.db.collection(CATCH_APP_AUTHORITIES).doc(targetUid);
      const prior = await tx.get(ref);
      this.assertFence(fence, [actorUid, targetUid]);
      const record = denyCatchAppAuthority(
        prior.exists ? prior.data() : null,
        {projectId: this.deps.projectId, uid: targetUid},
        expectedRevision,
        this.deps.now(),
      );
      if (!validateCatchWhatsappAppAuthorityDocument(record)) unavailable();
      if (prior.exists) tx.update(ref, {...record});
      else tx.create(ref, {...record});
      return record;
    });
  }
  async prepare(
    actorUid: string,
    actorIdToken: string,
    targetUid: string,
    input: {
      expectedRevision: number;
      nonce: string;
      capabilities: CatchCapability[];
      endpointHash: string | null;
      expiresAtMillis: number;
    },
  ) {
    const frozen = structuredClone(input);
    return this.runFenced(
      [actorUid, targetUid],
      async (tx, fence) => {
        const owner = await this.principal(tx, fence, actorUid, {
          idToken: actorIdToken,
        });
        const target = await this.principal(tx, fence, targetUid, "none");
        if ("recheck" in fence && typeof fence.recheck === "function") {
          await (fence as CatchFreshAuthContext).recheck();
        }
        this.assertFence(fence, [actorUid, targetUid]);
        const record = prepareCatchAppGrant(
          target.record,
          frozen,
          owner,
          target.auth,
          this.deps.now(),
        );
        if (!validateCatchWhatsappAppAuthorityDocument(record)) unavailable();
        tx.update(this.db.collection(CATCH_APP_AUTHORITIES).doc(targetUid), {
          ...record,
        });
        return record;
      },
      {uid: actorUid, idToken: actorIdToken},
    );
  }
  async finalize(
    actorUid: string,
    actorIdToken: string,
    targetUid: string,
    input: { expectedRevision: number; nonce: string },
  ) {
    const frozen = {...input};
    return this.runFenced(
      [actorUid, targetUid],
      async (tx, fence) => {
        const owner = await this.principal(tx, fence, actorUid, {
          idToken: actorIdToken,
        });
        const target = await this.principal(tx, fence, targetUid, "none");
        if ("recheck" in fence && typeof fence.recheck === "function") {
          await (fence as CatchFreshAuthContext).recheck();
        }
        this.assertFence(fence, [actorUid, targetUid]);
        const record = finalizeCatchAppGrant(
          target.record,
          frozen.expectedRevision,
          frozen.nonce,
          owner,
          target.auth,
          this.deps.now(),
        );
        if (!validateCatchWhatsappAppAuthorityDocument(record)) unavailable();
        tx.update(this.db.collection(CATCH_APP_AUTHORITIES).doc(targetUid), {
          ...record,
        });
        return record;
      },
      {uid: actorUid, idToken: actorIdToken},
    );
  }
}
