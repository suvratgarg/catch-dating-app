export type CompatibilitySignal =
  "mutual_interest" |
  "one_way_interest" |
  "questionnaire_match" |
  "social";

export interface CompatibilityParticipant {
  gender?: string;
  interestedInGenders?: string[];
  compatibilityAnswerIds?: string[];
}

export interface CompatibilityScore {
  score: number;
  compatibility: CompatibilitySignal;
}

/**
 * Scores two attendees using profile interest and optional event answers.
 * @param {CompatibilityParticipant} a First attendee.
 * @param {CompatibilityParticipant} b Second attendee.
 * @param {boolean} requireMutualInterest Whether one-way interest is blocked.
 * @return {CompatibilityScore} Compatibility score and display signal.
 */
export function scoreCompatibilityPair(
  a: CompatibilityParticipant,
  b: CompatibilityParticipant,
  requireMutualInterest: boolean
): CompatibilityScore {
  const aInterested = isInterestedIn(a, b);
  const bInterested = isInterestedIn(b, a);
  if (requireMutualInterest && (!aInterested || !bInterested)) {
    return {score: 0, compatibility: "social"};
  }
  const baseScore = aInterested && bInterested ?
    2 :
    aInterested || bInterested ? 1 : 0;
  if (baseScore === 0) {
    return {score: 0, compatibility: "social"};
  }
  const sharedAnswerCount = sharedCompatibilityAnswerCount(a, b);
  const questionnaireBoost = Math.min(1, sharedAnswerCount * 0.5);
  if (questionnaireBoost > 0) {
    return {
      score: baseScore + questionnaireBoost,
      compatibility: "questionnaire_match",
    };
  }
  return {
    score: baseScore,
    compatibility: baseScore === 2 ? "mutual_interest" : "one_way_interest",
  };
}

/**
 * Counts shared event-scoped compatibility answers.
 * @param {CompatibilityParticipant} a First attendee.
 * @param {CompatibilityParticipant} b Second attendee.
 * @return {number} Shared answer count.
 */
export function sharedCompatibilityAnswerCount(
  a: CompatibilityParticipant,
  b: CompatibilityParticipant
): number {
  const aAnswerIds = a.compatibilityAnswerIds ?? [];
  const bAnswerIds = b.compatibilityAnswerIds ?? [];
  if (aAnswerIds.length === 0 || bAnswerIds.length === 0) return 0;
  const bAnswers = new Set(bAnswerIds);
  return aAnswerIds.filter((answerId) => bAnswers.has(answerId)).length;
}

/**
 * Checks one attendee's declared interest in another attendee's gender.
 * @param {CompatibilityParticipant} viewer Person whose interest is checked.
 * @param {CompatibilityParticipant} candidate Potential peer.
 * @return {boolean} True when candidate gender is included.
 */
function isInterestedIn(
  viewer: CompatibilityParticipant,
  candidate: CompatibilityParticipant
): boolean {
  if (candidate.gender === undefined) return false;
  return viewer.interestedInGenders?.includes(candidate.gender) === true;
}
