import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import type {Firestore} from "firebase-admin/firestore";
import {
  CatchAppAuthorityStore,
  CATCH_APP_AUTHORITIES,
} from "./whatsappAppAuthorityStore";
import type {CatchAuditedAuthFence} from "./whatsappAppAuthorityStore";
import {catchReadinessAuthorityBindings} from "./whatsappAppAuthority";
import type {
  CatchAppAuthority,
  CatchFirebaseObservation,
} from "./whatsappAppAuthority";
import {catchEndpointHash} from "./whatsappReply";
import {deriveCatchIngressEvidence} from "./whatsappIngressEvidence";
import {CATCH_INGRESS_EVIDENCE} from "./whatsappIngressStore";
import type {CatchReceipt} from "./whatsappEndpointStops";

/**
 * Synthetic-only seeded authority; no production bootstrap or fence
 * assertion.
 */
export function createSyntheticCatchAuthority(
  db: Firestore,
  now: () => number,
  endpoint: string,
  projectId = "demo-catch-authority",
  recipientUid = "participant",
) {
  const rows = new Map<string, Record<string, unknown>>();
  let held = false;
  const endpointHash = catchEndpointHash(endpoint);
  const incarnation = (uid: string) =>
    createHash("sha256")
      .update(
        JSON.stringify(["catch.firebase-creation/v1", projectId, uid, 1000]),
      )
      .digest("hex");
  const observation = (uid: string): CatchFirebaseObservation => ({
    projectId,
    uid,
    creationTimeMillis: 1000,
    observedAtMillis: now(),
    disabled: false,
    relevantRoles:
      uid === "owner" ? ["adminOwner"] : uid === "agent" ? ["support"] : [],
    endpointHash: uid === recipientUid ? endpointHash : null,
    tokensValidAfterMillis: 0,
  });
  const session = (uid: string) => ({
    projectId,
    uid,
    authTimeSeconds: Math.floor(now() / 1000) - 1,
    expiresAtSeconds: Math.floor(now() / 1000) + 1800,
  });
  for (const uid of ["owner", "agent", recipientUid]) {
    const record: CatchAppAuthority = {
      schemaVersion: 1,
      projectId,
      uid,
      revision: 1,
      incarnation: incarnation(uid),
      state: "active",
      authNotBeforeSeconds: 0,
      updatedAtMillis: now() - 1000,
      capabilities:
        uid === "owner" ?
          ["review"] :
          uid === "agent" ?
            ["reply"] :
            ["receive"],
      endpointHash: uid === recipientUid ? endpointHash : null,
      pending: null,
      grantedBy: null,
    };
    rows.set(CATCH_APP_AUTHORITIES + "/" + uid, {...record});
  }
  const fence = (
    uids: readonly string[],
    assertHeld = () => assert.equal(held, true),
  ): CatchAuditedAuthFence => ({
    projectId,
    uids: [...uids],
    provenanceSha256: "a".repeat(64),
    assertHeld,
    readSession: async (uid) => {
      assertHeld();
      return session(uid);
    },
    authorizeDenial: async (actor, target) => {
      assertHeld();
      assert.equal(actor, "owner");
      assert.ok(uids.includes(target));
    },
  });
  const store = new CatchAppAuthorityStore(db, {
    projectId,
    now,
    firebase: {
      observe: async (uid) => observation(uid),
      verifySession: async (uid, token) => {
        assert.equal(token, "synthetic-current-id-token");
        return session(uid);
      },
    },
    withAuditedAuthFence: async ({uids}, callback) => {
      assert.equal(held, false);
      held = true;
      try {
        return await callback(fence(uids));
      } finally {
        held = false;
      }
    },
  });
  const principal = (uid: string, withSession: boolean) => ({
    record: rows.get(CATCH_APP_AUTHORITIES + "/" + uid),
    auth: observation(uid),
    ...(withSession ? {session: session(uid)} : {}),
  });
  const bindings = catchReadinessAuthorityBindings(
    {
      projectId,
      reviewerUid: "owner",
      recipientUid,
      endpointHash,
      reviewer: principal("owner", true),
      recipient: principal(recipientUid, false),
    },
    now(),
  );
  const ingress = (receipt: CatchReceipt) => {
    const evidence = deriveCatchIngressEvidence(receipt);
    return {
      schemaVersion: 1,
      ...evidence,
      wabaId: receipt.wabaId,
      phoneNumberId: receipt.phoneNumberId,
      endpointHash: catchEndpointHash("+" + receipt.participantId),
      state: evidence.classification === "ambiguous" ? "blocked" : "accepted",
      receivedAtMillis: receipt.receivedAtMillis,
    };
  };
  const seedInto = (
    records: Map<string, Record<string, unknown>>,
    receipt?: CatchReceipt,
  ) => {
    for (const [key, row] of rows) records.set(key, structuredClone(row));
    if (receipt) {
      records.set(
        CATCH_INGRESS_EVIDENCE + "/" + receipt.eventId,
        ingress(receipt),
      );
    }
  };
  return {
    store,
    rows,
    bindings,
    fence,
    seedInto,
    ingress,
    held: () => held,
  };
}
