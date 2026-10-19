import assert from "node:assert/strict";
import test from "node:test";
import {projectPublicReview} from "../../src/server/publicReviewProjection.ts";
import {projectPublicOrganizer} from "../../src/server/publicOrganizerProjection.ts";
import {organizerFixture} from "./organizerFixture.mjs";
const stamp = {toMillis: () => Date.parse("2026-10-01T10:00:00Z")};
const base = () => ({organizerId: "host", eventId: "past-event", reviewerName: "Guest", reviewerUserId: "SECRET",
  createdAt: stamp, rating: 5, comment: "Welcoming event.", moderationStatus: "published", verificationStatus: "verified", source: "catchEvent"});
test("public reviews preserve scope and response while stripping identities and private metadata", () => {
  const review = projectPublicReview("review", {...base(), isAnonymous: true, reviewerName: "PRIVATE",
    ownerResponse: {hostName: "Host", hostUserId: "SECRET", message: "Thanks!", updatedAt: stamp, hostAvatarUrl: "javascript:bad()"}}, "host");
  assert.equal(review.reviewerName, "Anonymous guest");
  assert.equal(review.eventId, "past-event");
  assert.equal(review.ownerResponse.message, "Thanks!");
  assert.equal(review.ownerResponse.hostAvatarUrl, null);
  assert(!JSON.stringify(review).match(/SECRET|PRIVATE|reviewerUserId|hostUserId/));
});
test("moderated, foreign, synthetic and malformed reviews never reach the public DTO", () => {
  for (const patch of [{moderationStatus: "pending"}, {moderationStatus: "rejected"}, {organizerId: "other"},
    {synthetic: true}, {dataOrigin: "catchDemo"}, {createdAt: null}, {rating: NaN}, {rating: 6}, {comment: "x".repeat(1001)}]) {
    assert.equal(projectPublicReview("review", {...base(), ...patch}, "host"), null);
  }
  assert.equal(projectPublicReview("review", {...base(), source: "publicListing"}, "host").verificationStatus, "unverified");
  assert.equal(projectPublicReview("review", {...base(), verificationStatus: "unverified"}, "host").verificationStatus, "unverified");
});
test("organiser credibility uses canonical followers and verified-review counts", () => {
  const data = {...organizerFixture(), rating: 4.5, reviewCount: 10, verifiedReviewCount: 4, followerCount: 23};
  const listing = projectPublicOrganizer("host", data, new Set(["indore"]));
  assert.deepEqual(listing.metrics, {rating: 4.5, reviewCount: 10, verifiedReviewCount: 4, followerCount: 23});
  assert.equal(projectPublicOrganizer("host", {...data, verifiedReviewCount: 0}, new Set(["indore"])).metrics.rating, undefined);
});
