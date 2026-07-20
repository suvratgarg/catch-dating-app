import {describe, expect, it} from "vitest";
import {hostListings} from "./data";
import {organizerPolicyForListing} from "./organizerPolicy";
import type {HostListing} from "./types";

interface PolicyFixtureFields {
  authority: {
    appVisibility: string;
    claimState: string;
    indexStatus: string;
    ownershipState: string;
    provenanceOrigin: string;
    publishStatus: string;
    sourceConfidence: string;
    verificationStatus: string;
  };
  capabilities: {
    claimRequest: {state: string; reason: string};
    publicReviews: {readState: string; writeState: string; reason: string};
  };
}

function listingWithPolicy(
  authority: Partial<PolicyFixtureFields["authority"]>,
  capabilities: Partial<PolicyFixtureFields["capabilities"]> = {}
): HostListing {
  return {
    ...hostListings[0],
    authority: {
      appVisibility: "hidden",
      claimState: "unclaimed",
      indexStatus: "indexed",
      ownershipState: "programmatic",
      provenanceOrigin: "scraper",
      publishStatus: "published",
      sourceConfidence: "high",
      verificationStatus: "sourceBacked",
      ...authority,
    },
    capabilities: {
      claimRequest: {state: "enabled", reason: ""},
      publicReviews: {readState: "enabled", writeState: "enabled", reason: ""},
      ...capabilities,
    },
  } as HostListing;
}

describe("organizerPolicyForListing", () => {
  it("keeps source trust independent from claimability", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({}));

    expect(policy).toMatchObject({
      badge: {label: "Source-backed listing", tone: "verified"},
      canReadPublicReviews: true,
      canRequestClaim: true,
      canWritePublicReview: true,
      claimState: "unclaimed",
      ownershipState: "programmatic",
      verificationStatus: "sourceBacked",
    });
  });

  it("renders pending ownership review without reopening claims", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({
      claimState: "claimPending",
    }));

    expect(policy.canRequestClaim).toBe(false);
    expect(policy.canWritePublicReview).toBe(true);
    expect(policy.badge).toMatchObject({label: "Claim pending", tone: "claimed"});
    expect(policy.claimRequestReason).toContain("already under review");
  });

  it("maps owner verification explicitly and keeps claim UI closed", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({
      claimState: "claimed",
      ownershipState: "claimed",
      sourceConfidence: "ownerVerified",
      verificationStatus: "ownerVerified",
    }));

    expect(policy.canRequestClaim).toBe(false);
    expect(policy.badge).toEqual({
      compactLabel: "Verified",
      label: "Verified on Catch",
      tone: "verified",
    });
  });

  it("blocks every public action for suppressed publication", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({
      claimState: "suppressed",
      publishStatus: "suppressed",
    }));

    expect(policy.canRequestClaim).toBe(false);
    expect(policy.canReadPublicReviews).toBe(false);
    expect(policy.canWritePublicReview).toBe(false);
    expect(policy.badge.label).toBe("Listing unavailable");
  });

  it("keeps claim and review capabilities independent", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({}, {
      claimRequest: {state: "disabled", reason: "Claim target is syncing."},
      publicReviews: {readState: "enabled", writeState: "enabled", reason: ""},
    }));

    expect(policy.canRequestClaim).toBe(false);
    expect(policy.claimRequestReason).toBe("Claim target is syncing.");
    expect(policy.canReadPublicReviews).toBe(true);
    expect(policy.canWritePublicReview).toBe(true);
  });

  it("adapts old unclaimed projections through the legacy public API flag", () => {
    const listing = {
      ...hostListings[0],
      status: "unclaimed",
      publicApi: {...hostListings[0].publicApi, state: "enabled", reason: ""},
    } as HostListing;
    const policy = organizerPolicyForListing(listing);

    expect(policy.canRequestClaim).toBe(true);
    expect(policy.canReadPublicReviews).toBe(true);
    expect(policy.canWritePublicReview).toBe(true);
  });

  it("fails closed for incomplete authority and capability projections", () => {
    const listing = {
      ...hostListings[0],
      authority: {claimState: "unclaimed"},
      capabilities: {},
      publicApi: {...hostListings[0].publicApi, state: "enabled", reason: ""},
    } as HostListing;

    const policy = organizerPolicyForListing(listing);

    expect(policy.ownershipState).toBe("unknown");
    expect(policy.canRequestClaim).toBe(false);
    expect(policy.canReadPublicReviews).toBe(false);
    expect(policy.canWritePublicReview).toBe(false);
  });
});
