export type CompatibilitySignal =
  "mutual_interest" |
  "one_way_interest" |
  "questionnaire_match" |
  "social";

export type QuestionnaireScoringMode =
  "off" | "icebreaker" | "light" | "strong";

export interface CompatibilityParticipant {
  gender?: string;
  interestedInGenders?: string[];
  compatibilityAnswerIds?: string[];
}

export interface CompatibilityScore {
  score: number;
  compatibility: CompatibilitySignal;
}

export interface DatingCompatibilityScore extends CompatibilityScore {
  mutualInterest: boolean;
  oneWayInterest: boolean;
  orientationCompatible: boolean;
  sharedAnswerCount: number;
}

export interface DatingCompatibilityOptions {
  questionnaireMode?: QuestionnaireScoringMode;
  allowOrientationFallback?: boolean;
}

const MUTUAL_INTEREST_SCORE = 100;
const ONE_WAY_INTEREST_SCORE = 15;
const SOCIAL_FALLBACK_SCORE = 1;
const LIGHT_QUESTIONNAIRE_BOOST = 10;
const STRONG_QUESTIONNAIRE_BOOST = 25;

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
  const scored = scoreDatingCompatibilityPair(a, b, {
    questionnaireMode: "light",
    allowOrientationFallback: !requireMutualInterest,
  });
  if (requireMutualInterest && !scored.mutualInterest) {
    return {score: 0, compatibility: "social"};
  }
  return {score: scored.score / 50, compatibility: scored.compatibility};
}

/**
 * Scores a dating-coded pair with explicit hard/soft signal metadata.
 * @param {CompatibilityParticipant} a First attendee.
 * @param {CompatibilityParticipant} b Second attendee.
 * @param {DatingCompatibilityOptions} options Scoring options.
 * @return {DatingCompatibilityScore} Score and explainability metadata.
 */
export function scoreDatingCompatibilityPair(
  a: CompatibilityParticipant,
  b: CompatibilityParticipant,
  options: DatingCompatibilityOptions = {}
): DatingCompatibilityScore {
  const aInterested = isInterestedIn(a, b);
  const bInterested = isInterestedIn(b, a);
  const mutualInterest = aInterested && bInterested;
  const oneWayInterest = !mutualInterest && (aInterested || bInterested);
  const sharedAnswerCount = sharedCompatibilityAnswerCount(a, b);
  const questionnaireBoost = questionnaireScore(
    sharedAnswerCount,
    options.questionnaireMode ?? "light"
  );

  if (mutualInterest) {
    return {
      score: MUTUAL_INTEREST_SCORE + questionnaireBoost,
      compatibility: questionnaireBoost > 0 ?
        "questionnaire_match" :
        "mutual_interest",
      mutualInterest,
      oneWayInterest,
      orientationCompatible: true,
      sharedAnswerCount,
    };
  }

  if (oneWayInterest) {
    return {
      score: ONE_WAY_INTEREST_SCORE + Math.floor(questionnaireBoost / 4),
      compatibility: "one_way_interest",
      mutualInterest,
      oneWayInterest,
      orientationCompatible: false,
      sharedAnswerCount,
    };
  }

  return {
    score: options.allowOrientationFallback === true ?
      SOCIAL_FALLBACK_SCORE :
      0,
    compatibility: "social",
    mutualInterest,
    oneWayInterest,
    orientationCompatible: false,
    sharedAnswerCount,
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

/**
 * Weights shared answers based on the host's questionnaire intent.
 * @param {number} sharedAnswerCount Number of shared answer ids.
 * @param {QuestionnaireScoringMode} mode Questionnaire scoring mode.
 * @return {number} Pair-score boost.
 */
function questionnaireScore(
  sharedAnswerCount: number,
  mode: QuestionnaireScoringMode
): number {
  if (sharedAnswerCount <= 0) return 0;
  switch (mode) {
  case "off":
  case "icebreaker":
    return 0;
  case "light":
    return Math.min(30, sharedAnswerCount * LIGHT_QUESTIONNAIRE_BOOST);
  case "strong":
    return Math.min(75, sharedAnswerCount * STRONG_QUESTIONNAIRE_BOOST);
  }
}
