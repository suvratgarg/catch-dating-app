import {describe, expect, it} from "vitest";
import {
  countIncompletePublishChecklist,
  emptyPublishChecklist,
  organizerPublishingFieldIds,
  type OrganizerPublishingFormState,
  updateOrganizerLaunchMarket,
  validateOrganizerPublishingForm,
} from "./organizerPublishingHelpers";

const courtsideForm: OrganizerPublishingFormState = {
  clubId: "courtside",
  name: "Courtside",
  description: "Mumbai padel socials and community play.",
  location: "in-mh-mumbai",
  area: "Mumbai",
  tagsText: "Padel socials\nCommunity play",
  instagramHandle: "",
  phoneNumber: "",
  email: "",
  imageUrl: "",
  profileImageUrl: "",
  organizerType: "community",
  publicCategoryLabel: "Padel socials",
  cityName: "Mumbai",
  regionName: "Maharashtra",
  countryCode: "IN",
  countryName: "India",
  appVisibility: "hidden",
  publicPageSlug: "courtside",
  publicPageCitySlug: "mumbai",
  canonicalPath: "/organizers/courtside/",
  publishStatus: "draft",
  seoTitle: "",
  seoDescription: "",
  sourceConfidence: "medium",
  verificationStatus: "sourceBacked",
  headline: "",
  summary: "",
  sourceSummary: "Official source identifies Courtside in Mumbai.",
  formatsText: "Padel socials\nCommunity play",
  fitNotesText: "",
  missingEvidenceText: "Confirm the next public session.",
  reviewNote: "",
};

describe("organizerPublishingHelpers", () => {
  it("updates the governed market projection as one choice", () => {
    const updated = updateOrganizerLaunchMarket(
      {
        ...courtsideForm,
        canonicalPath: "/organizers/mumbai/courtside/",
      },
      "in-mp-indore"
    );

    expect(updated).toMatchObject({
      location: "in-mp-indore",
      cityName: "Indore",
      regionName: "Madhya Pradesh",
      countryCode: "IN",
      countryName: "India",
      publicPageCitySlug: "indore",
      canonicalPath: "/organizers/indore/courtside/",
    });
  });

  it("turns the Courtside publish blockers into field targets", () => {
    const issues = validateOrganizerPublishingForm(
      courtsideForm,
      {publishing: true, requireReviewNote: true}
    );

    expect(issues.map((issue) => issue.id)).toEqual([
      "review-note",
      "headline",
      "summary",
      "source-confidence",
    ]);
    expect(issues.map((issue) => issue.targetId)).toEqual([
      organizerPublishingFieldIds.reviewNote,
      organizerPublishingFieldIds.headline,
      organizerPublishingFieldIds.summary,
      organizerPublishingFieldIds.sourceConfidence,
    ]);
    expect(countIncompletePublishChecklist(emptyPublishChecklist)).toBe(4);
  });

  it("blocks invalid market, route, URL, and email combinations", () => {
    const issues = validateOrganizerPublishingForm({
      ...courtsideForm,
      location: "Mumbai",
      publicPageSlug: "Courtside Mumbai",
      canonicalPath: "/organizers/not-courtside/",
      imageUrl: "javascript:alert(1)",
      email: "not-an-email",
    });

    expect(issues.map((issue) => issue.id)).toEqual(expect.arrayContaining([
      "launch-market",
      "slug-shape",
      "image-url",
      "email-shape",
      "route-slug",
    ]));
    expect(issues.every((issue) =>
      issue.severity !== "blocker" || Boolean(issue.targetId)
    )).toBe(true);
  });
});
