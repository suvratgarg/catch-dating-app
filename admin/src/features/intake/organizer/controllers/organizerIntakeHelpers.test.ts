import {describe, expect, it} from "vitest";
import type * as Intake from "../types/organizerIntakeTypes";
import {
  curationPayloadForItem,
  intakeChecklistForDecision,
  organizerIntakeDecisionFromString,
  organizerPolicyGapDecisionFromString,
  publicationPacketReady,
} from "./organizerIntakeHelpers";

const item = {
  entityId: "club-1",
  displayName: "Sunday Club",
  surfaces: [{surfaceId: "instagram"}],
  gates: [
    {id: "identity_surface_present", passed: true},
    {id: "surface_inventory_reviewable", passed: true},
    {id: "owner_safe_public_draft", passed: false},
    {id: "market_model_present", passed: true},
    {id: "crawl_disabled_by_default", passed: true},
  ],
} as unknown as Intake.OrganizerIntakeItem;

describe("organizer intake helpers", () => {
  it("accepts only supported decision strings", () => {
    expect(organizerIntakeDecisionFromString("approve_public")).toBe(
      "approve_public"
    );
    expect(organizerIntakeDecisionFromString("reject")).toBeNull();
    expect(organizerPolicyGapDecisionFromString("reject")).toBe("reject");
    expect(organizerPolicyGapDecisionFromString("suppress")).toBeNull();
  });

  it("maps evidence gates into the durable approval checklist", () => {
    expect(intakeChecklistForDecision(item, "approve_public")).toEqual({
      identityReviewed: true,
      surfaceInventoryReviewed: true,
      ownerSafeCopyReviewed: false,
      marketScopeReviewed: true,
      mediaRightsReviewed: true,
      crawlDisabledReviewed: true,
    });
  });

  it("rejects unsafe merge payloads and trims valid split payloads", () => {
    expect(curationPayloadForItem(item, {
      operationType: "merge_entity",
      targetEntityId: "club-1",
      surfaceId: "",
      newEntityId: "",
      decision: "reject_wrong_entity",
      reason: "",
    })).toEqual({ok: false, message: "Choose a different merge target."});

    expect(curationPayloadForItem(item, {
      operationType: "split_surface",
      targetEntityId: "",
      surfaceId: "instagram",
      newEntityId: "  club-2  ",
      decision: "reject_wrong_entity",
      reason: "Duplicate identity",
    })).toEqual({
      ok: true,
      value: {
        operationType: "split_surface",
        entityId: "club-1",
        surfaceId: "instagram",
        newEntityId: "club-2",
        reason: "Duplicate identity",
      },
    });
  });

  it("requires every publication blocker and checklist item to clear", () => {
    expect(publicationPacketReady({
      status: "ready_for_manual_publication_review",
      dataBlockers: [],
      evidenceBlockers: [],
      approvalChecklist: {
        identityReviewed: true,
        surfaceInventoryReviewed: true,
        ownerSafeCopyReviewed: true,
        marketScopeReviewed: true,
        mediaRightsReviewed: true,
        crawlDisabledReviewed: true,
      },
    } as unknown as Intake.OrganizerPublicationReviewPacket)).toBe(true);
  });
});
