import {Timestamp, type Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {HostAcquisitionConsentDocument} from
  "../shared/generated/hostAcquisitionConsentDocument";
import type {HostAcquisitionConsentHTTPRequest} from
  "../shared/generated/hostAcquisitionConsentHttpRequest";
import type {HostAcquisitionConsentHTTPResponse} from
  "../shared/generated/hostAcquisitionConsentHttpResponse";
import {validateHostAcquisitionConsentDocument} from
  "../shared/generated/validators/hostAcquisitionConsentDocument";
import {validateHostAcquisitionConsentHTTPRequest} from
  "../shared/generated/validators/hostAcquisitionConsentHttpRequest";
import {
  hasCurrentHostConsent, hostConsentKey, HOST_ATTRIBUTION_LIFETIME_MS,
  HOST_META_DELIVERY_LIFETIME_MS, newHostConsentAuthority,
  parseHostConsentChoice,
} from "./consentPolicy";

export const HOST_CONSENT_COLLECTION = "hostAcquisitionConsents";

function result(status: "active" | "revoked" | "disabled",
  expiresAt: number | null): HostAcquisitionConsentHTTPResponse {
  return {ok: true, status, expiresAt};
}

/** One transaction serializes grant, replay and withdrawal. In particular,
 * withdrawal can win before a delayed grant: its tombstone prevents that
 * request from resurrecting permission. Provider I/O never belongs here. */
export async function recordHostConsent(input: {
  db: Firestore;
  request: HostAcquisitionConsentHTTPRequest;
  enabled: boolean;
  now?: () => number;
}): Promise<HostAcquisitionConsentHTTPResponse> {
  const {request} = input;
  if (request.action === "grant" && !input.enabled) {
    return result("disabled", null);
  }
  if (!validateHostAcquisitionConsentHTTPRequest(request)) {
    throw new HttpsError("invalid-argument", "Invalid privacy choice.");
  }
  const consentId = hostConsentKey(request.capability)!;
  const ref = input.db.collection(HOST_CONSENT_COLLECTION).doc(consentId);
  return input.db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    const raw = snapshot.data();
    if (snapshot.exists && (!validateHostAcquisitionConsentDocument(raw) ||
        raw.consentId !== consentId)) {
      throw new HttpsError("failed-precondition",
        "Stored privacy choice is invalid.");
    }
    const prior = snapshot.exists ?
      raw as HostAcquisitionConsentDocument : null;
    const now = (input.now ?? Date.now)();
    if (!Number.isSafeInteger(now) || now <= 0) {
      throw new Error("Invalid server clock.");
    }

    if (prior?.status === "revoked") {
      return result("revoked", null);
    }
    if (request.action === "revoke") {
      const row = {
        schemaVersion: 1,
        classification: "sales_private",
        consentId,
        status: "revoked",
        authority: prior?.authority ?
          {...prior.authority, revokedAt: now} : null,
        createdAt: prior?.createdAt ?? Timestamp.fromMillis(now),
        updatedAt: Timestamp.fromMillis(now),
        // Outlive every grant and queue that might race this withdrawal.
        expiresAt: Timestamp.fromMillis(now + HOST_ATTRIBUTION_LIFETIME_MS +
          HOST_META_DELIVERY_LIFETIME_MS),
      };
      if (!validateHostAcquisitionConsentDocument(row)) {
        throw new Error("Invalid Host withdrawal record.");
      }
      tx.set(ref, row);
      return result("revoked", null);
    }

    if (prior) {
      const authority = prior.authority;
      const choice = request.choice!;
      if (!authority || choice.version !== authority.version ||
          choice.purpose !== authority.purpose ||
          choice.analytics !== authority.analytics ||
          choice.advertising !== authority.advertising ||
          choice.chosenAt !== authority.chosenAt) {
        throw new HttpsError("failed-precondition",
          "Use a fresh privacy choice.");
      }
      return hasCurrentHostConsent(authority, now, "analytics") ?
        result("active", authority.expiresAt) : result("revoked", null);
    }

    const choice = parseHostConsentChoice(request.choice, now);
    if (!choice) {
      throw new HttpsError("invalid-argument", "Privacy choice has expired.");
    }
    const authority = newHostConsentAuthority(choice, now);
    const row = {
      schemaVersion: 1,
      classification: "sales_private",
      consentId,
      status: "active",
      authority,
      createdAt: Timestamp.fromMillis(now),
      updatedAt: Timestamp.fromMillis(now),
      expiresAt: Timestamp.fromMillis(authority.expiresAt),
    };
    if (!validateHostAcquisitionConsentDocument(row)) {
      throw new Error("Invalid Host permission record.");
    }
    tx.create(ref, row);
    return result("active", authority.expiresAt);
  });
}
