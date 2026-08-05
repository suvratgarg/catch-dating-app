import {act, renderHook, waitFor} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {useCrossPathsShowcaseController} from
  "./useCrossPathsShowcaseController";

const repository = vi.hoisted(() => ({
  loadCrossPathsShowcaseReviewPage: vi.fn(),
  saveCrossPathsShowcaseDecision: vi.fn(),
}));

vi.mock("../api/crossPathsShowcaseRepository", () => repository);

describe("useCrossPathsShowcaseController", () => {
  beforeEach(() => {
    Object.values(repository).forEach((mock) => mock.mockReset());
    repository.loadCrossPathsShowcaseReviewPage.mockResolvedValue(queuePage());
    repository.saveCrossPathsShowcaseDecision.mockResolvedValue({
      uid: "user-rhea",
      status: "eligible",
      reasonCodes: [],
      profileFingerprint: "a".repeat(64),
      ruleVersion: 1,
      reviewVersion: 1,
      reviewedAt: "2026-08-05T10:00:00.000Z",
    });
  });

  it("loads the bounded needs-review queue through TanStack Query", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useCrossPathsShowcaseController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});

    await waitFor(() => expect(result.current.candidates).toHaveLength(1));
    expect(repository.loadCrossPathsShowcaseReviewPage).toHaveBeenCalledWith({
      status: "needsReview",
      cursor: null,
      limit: 25,
    });
    expect(result.current.candidates[0]).not.toHaveProperty("score");
  });

  it("freezes and submits a trimmed audited decision payload", async () => {
    const onError = vi.fn();
    const onNotice = vi.fn();
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useCrossPathsShowcaseController({
      onError,
      onNotice,
    }), {wrapper});
    await waitFor(() => expect(result.current.candidates).toHaveLength(1));

    await act(async () => {
      await expect(result.current.decide({
        uid: " user-rhea ",
        status: "eligible",
        reviewChecklist: {
          primaryPortraitClear: true,
          profileRepresentsCurrentMember: true,
          showcasePolicyReviewed: true,
        },
        reviewNote: "  Reviewed current public profile.  ",
      })).resolves.toBe(true);
    });

    expect(repository.saveCrossPathsShowcaseDecision.mock.calls[0]?.[0]).toEqual({
      uid: "user-rhea",
      status: "eligible",
      reviewChecklist: {
        primaryPortraitClear: true,
        profileRepresentsCurrentMember: true,
        showcasePolicyReviewed: true,
      },
      reviewNote: "Reviewed current public profile.",
    });
    expect(onError).toHaveBeenLastCalledWith(null);
    expect(onNotice).toHaveBeenLastCalledWith(
      "Cross Paths showcase status updated for user-rhea."
    );
  });

  it("requires an audit note before calling the mutation", async () => {
    const onError = vi.fn();
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useCrossPathsShowcaseController({
      onError,
      onNotice: vi.fn(),
    }), {wrapper});
    await waitFor(() => expect(result.current.candidates).toHaveLength(1));

    await act(async () => {
      await expect(result.current.decide({
        uid: "user-rhea",
        status: "paused",
        reviewChecklist: {
          primaryPortraitClear: false,
          profileRepresentsCurrentMember: false,
          showcasePolicyReviewed: false,
        },
        reviewNote: "   ",
      })).resolves.toBe(false);
    });

    expect(repository.saveCrossPathsShowcaseDecision).not.toHaveBeenCalled();
    expect(onError).toHaveBeenLastCalledWith(
      "Add a review note before recording a decision."
    );
  });
});

function queuePage() {
  return {
    schemaVersion: 1 as const,
    generatedAt: "2026-08-05T10:00:00.000Z",
    candidates: [{
      uid: "user-rhea",
      name: "Rhea",
      age: 28,
      gender: "woman",
      city: "mumbai",
      photoUrls: ["https://images.example/rhea.jpg"],
      promptAnswers: [],
      relationshipGoal: "longTermRelationship",
      automaticStatus: "ready" as const,
      automaticReasonCodes: [],
      storedStatus: null,
      effectiveStatus: "needsReview" as const,
      effectiveReasonCodes: [],
      profileFingerprint: "a".repeat(64),
      reviewedByUid: null,
      reviewedAt: null,
      reviewNote: null,
    }],
    nextCursor: null,
  };
}
