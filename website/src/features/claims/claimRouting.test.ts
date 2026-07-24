import {describe, expect, it} from "vitest";
import {hostListings} from "../organizers/data";
import type {HostListing} from "../organizers/types";
import {
  claimRouteStateForLocation,
  claimUrlStateForListing,
} from "./claimRouting";

function withAuthority(
  claimState: HostListing["authority"]["claimState"],
  ownershipState: HostListing["authority"]["ownershipState"] = "programmatic"
) {
  return {
    ...hostListings[0],
    authority: {
      ...hostListings[0].authority,
      claimState,
      ownershipState,
      publishStatus: "published",
      verificationStatus: "sourceBacked",
    },
    capabilities: {
      claimRequest: {state: "enabled", reason: ""},
      publicReviews: {
        targetState: "enabled",
        readState: "enabled",
        writeState: "enabled",
        reason: "",
      },
    },
  } as HostListing;
}

describe("claim routing policy", () => {
  it("derives pending state from listing authority", () => {
    expect(claimUrlStateForListing(withAuthority("claimPending"), "listing-1"))
      .toBe("pendingClaim");
  });

  it("treats claimed and verified authority as already owned", () => {
    expect(claimUrlStateForListing(withAuthority("claimed", "claimed"), "listing-1"))
      .toBe("alreadyClaimed");
    expect(claimUrlStateForListing(withAuthority("verified", "claimed"), "listing-1"))
      .toBe("alreadyClaimed");
  });

  it("does not let query parameters forge a pending claim state", () => {
    const listing = hostListings[0];
    const route = claimRouteStateForLocation({
      pathname: "/claim/",
      search: `?listing=${listing.id}&claimStatus=pending&requestId=forged`,
    });

    expect(route.requestId).toBe("forged");
    expect(route.urlState).toBe("claimUnavailable");
  });

  it("distinguishes missing and unavailable listings", () => {
    expect(claimUrlStateForListing(null, "missing")).toBe("notFound");
    expect(claimUrlStateForListing(withAuthority("suppressed"), "listing-1"))
      .toBe("claimUnavailable");
  });
});
