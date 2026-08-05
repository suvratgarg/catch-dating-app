import {
  loadCrossPathsShowcaseCandidates,
  setCrossPathsShowcaseEligibility,
} from "../../../shared/api/adminApi";
import type {AdminListCrossPathsShowcaseCandidatesCallablePayload} from
  "../../../generated/contracts/adminListCrossPathsShowcaseCandidatesCallablePayload";
import type {AdminSetCrossPathsShowcaseEligibilityCallablePayload} from
  "../../../generated/contracts/adminSetCrossPathsShowcaseEligibilityCallablePayload";

export function loadCrossPathsShowcaseReviewPage(
  payload: AdminListCrossPathsShowcaseCandidatesCallablePayload
) {
  return loadCrossPathsShowcaseCandidates(payload);
}

export function saveCrossPathsShowcaseDecision(
  payload: AdminSetCrossPathsShowcaseEligibilityCallablePayload
) {
  return setCrossPathsShowcaseEligibility(payload);
}
