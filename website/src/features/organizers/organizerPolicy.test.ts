import {describe, expect, it} from "vitest";
import {organizerListingCopy} from "../../content/organizer";
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
    publicReviews: {
      targetState: string;
      readState: string;
      writeState: string;
      reason: string;
    };
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
      publicReviews: {
        targetState: "enabled",
        readState: "enabled",
        writeState: "enabled",
        reason: "",
      },
      ...capabilities,
    },
  } as HostListing;
}

describe("organizerPolicyForListing", () => {
  it("keeps source trust independent from claimability", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({}));

    expect(policy).toMatchObject({
      badge: {
        label: organizerListingCopy.badges.sourceBacked.label,
        tone: "claimed",
      },
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
    expect(policy.badge).toMatchObject({
      label: organizerListingCopy.badges.claimPending.label,
      tone: "claimed",
    });
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
      label: organizerListingCopy.badges.ownerVerified.label,
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
    expect(policy.badge.label).toBe(organizerListingCopy.badges.suppressed.label);
  });

  it("keeps claim and review capabilities independent", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({}, {
      claimRequest: {state: "disabled", reason: "Claim target is syncing."},
      publicReviews: {
        targetState: "enabled",
        readState: "enabled",
        writeState: "enabled",
        reason: "",
      },
    }));

    expect(policy.canRequestClaim).toBe(false);
    expect(policy.claimRequestReason).toBe("Claim target is syncing.");
    expect(policy.canReadPublicReviews).toBe(true);
    expect(policy.canWritePublicReview).toBe(true);
  });

  it("adapts old unclaimed projections through the legacy public API flag", () => {
    const legacyListing = Object.fromEntries(
      Object.entries(hostListings[0]).filter(
        ([key]) => !["authority", "capabilities"].includes(key)
      )
    );
    const listing = {
      ...legacyListing,
      status: "unclaimed",
      publicApi: {...hostListings[0].publicApi, state: "enabled", reason: ""},
    } as HostListing;
    const policy = organizerPolicyForListing(listing);

    expect(policy.canRequestClaim).toBe(true);
    expect(policy.canReadPublicReviews).toBe(true);
    expect(policy.canWritePublicReview).toBe(true);
  });

  it("fails public routes closed for stale published suppression", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({
      claimState: "suppressed",
      publishStatus: "published",
    }));

    expect(policy.isPubliclyReadable).toBe(false);
    expect(policy.canRequestClaim).toBe(false);
    expect(policy.canReadPublicReviews).toBe(false);
    expect(policy.canWritePublicReview).toBe(false);
  });

  it("requires a canonical target before projected review capabilities", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({}, {
      publicReviews: {
        targetState: "disabled",
        readState: "enabled",
        writeState: "enabled",
        reason: "Canonical target is not ready.",
      },
    }));

    expect(policy.canReadPublicReviews).toBe(false);
    expect(policy.canWritePublicReview).toBe(false);
    expect(policy.publicReviewReason).toContain("canonical organizer target");
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

  it("keeps first-party creation distinct from owner verification", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({
      claimState: "claimed",
      ownershipState: "userCreated",
      provenanceOrigin: "userCreated",
      sourceConfidence: "high",
      verificationStatus: "sourceBacked",
    }));

    expect(policy.trustState).toBe("firstParty");
    expect(policy.badge).toMatchObject({
      label: organizerListingCopy.badges.firstParty.label,
      tone: "claimed",
    });
  });

  it("keeps a canonical verified first-party payload first-party", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({
      claimState: "verified",
      ownershipState: "userCreated",
      provenanceOrigin: "userCreated",
      sourceConfidence: "ownerVerified",
      verificationStatus: "ownerVerified",
    }));

    expect(policy.trustState).toBe("firstParty");
    expect(policy.badge.label).toBe(organizerListingCopy.badges.firstParty.label);
  });

  it("fails public reads and actions closed until a projected page is published", () => {
    const policy = organizerPolicyForListing(listingWithPolicy({
      publishStatus: "qa",
    }));

    expect(policy.isPubliclyReadable).toBe(false);
    expect(policy.canRequestClaim).toBe(false);
    expect(policy.canReadPublicReviews).toBe(false);
    expect(policy.canWritePublicReview).toBe(false);
  });
});
