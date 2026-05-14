# Public Profile Overhaul Tracker

Last updated: 2026-05-14

## Goal

Make the shared public profile surface feel person-first, expressive, trustworthy in the right ways, and optimized for post-event matching. The card is reused in the swipe stack, profile preview, chat header profile view, and public profile routes, so changes here should be treated as product-critical.

## Completed Baseline

- Redesigned `ProfileCard` toward the approved Option A direction: large hero photo, light editorial sections, running as a supporting differentiator.
- Made meaningful profile blocks individually likeable/commentable.
- Replaced the generic bio with structured profile prompts and photo prompts.
- Added a source-of-truth prompt catalog in `lib/user_profile/domain/profile_prompts.dart`.
- Migrated legacy bio content into the prompt "A perfect run with me looks like...".

## Implementation Log

### 2026-05-14: Confidence, Identity, Compatibility Slice

- Added `lib/public_profile/domain/profile_insights.dart` as the pure scoring and insight layer.
- Added profile quality scoring for photos, prompts, captions, relationship goal, running details, background facts, and lifestyle facts.
- Added owner-only profile quality guidance at the top of Edit Profile.
- Added derived/selected emotional run tags on the running identity card.
- Added "Why you might click" / profile signals section to the shared `ProfileCard`.
- Wired swipe-stack cards with viewer profile and shared run title so compatibility reasons can use real context.
- Added `SwipeReactionTargetType.compatibility` so the compatibility block can be liked/commented on like other meaningful blocks.
- Updated Firestore swipe validation to allow compatibility reactions.

### 2026-05-14: Preferred Run-Time Identity Slice

- Added `PreferredRunTime` to private `UserProfile` and public `PublicProfile`.
- Added `preferredRunTimes` to onboarding completion and Edit Profile Running Details.
- Projected preferred run times through `syncPublicProfile` and the generated Firestore TypeScript contract.
- Added morning/evening/midday emotional run tags from selected run-time preferences.
- Added viewer-aware time-of-day compatibility reasons such as "You both like morning runs".
- Folded run-time preferences into profile-quality scoring so running identity means pace, distance, why, and when.

## Current Product Decisions

- Do not add photo verification as a profile-card trust signal. Catch users meet at an event before seeing the profile, so photo verification is not the main trust problem.
- Do not add phone verification as a visible trust signal. Phone OTP login already verifies phone number.
- Do not add "recently active" as a primary trust signal while matching is bound to the 24-hour post-event swipe window.
- Profile completeness is a useful confidence signal and can be used to incentivize better profiles.
- Run host or member history may be useful, but it should be framed as social context and community proof, not identity verification.
- "Why you might click" is a high-priority profile-card feature. It should include running and non-running compatibility reasons.
- Same-city compatibility is not useful while swiping is city/event scoped.
- Time-of-day preference is now an explicit profile field and can later be enriched with attendance-derived behavior.

## Workstream 1: Confidence Signals

Confidence signals should answer "is this profile worth engaging with?" rather than "is this person real?"

Candidate signals:

| Signal | Source | Use | Status |
| --- | --- | --- | --- |
| Profile complete | Computed from prompts, photos, captions, run details, facts | Badge or profile-quality nudge | Implemented |
| Met at this event | Current swipe/event context | Subtle context line: "Met at Thursday Social Run" | Implemented for swipe context |
| Club regular | Attendance or club membership history | Soft social proof | Needs data audit |
| Run host | Host role/history | Community credibility | Needs product decision |
| First Catch run | Attendance count | Context, not a penalty | Proposed |
| Repeat runner | Attendance count | Context, not a ranking | Proposed |

Run host/member history explanation:

- This is not a verification badge.
- It can show that the person participates in the same real-world running community.
- Examples: "2 Catch runs attended", "Regular at Indore Morning Runs", "Run host", "Met at Thursday 5K".
- This should be light and contextual, not a status hierarchy that makes newer users feel lower value.

## Workstream 2: Emotional Run Identity

These tags should make running feel personal rather than purely numeric.

Derived candidates:

| Tag | Derivation | Notes |
| --- | --- | --- |
| Morning regular | Preferred run times include early morning or morning | Implemented from selected run times |
| Evening regular | Preferred run times include evening or night | Implemented from selected run times |
| Midday miles | Preferred run times include afternoon | Implemented from selected run times |
| Easy miles | Pace preference and run choices skew easy/social | Implemented from public pace |
| Tempo energy | Pace preference or selected run vibe skews faster | Implemented from public pace |
| 5K regular | Preferred or attended distances cluster around 5K | Implemented from preferred distances |
| Long-run person | Preferred or attended distances skew longer | Implemented from preferred distances |
| Club regular | Multiple events with same club | Depends on run-club data |
| New to Catch | Low attendance count | Should be friendly, not a warning |

Asked/edit-profile candidates:

| Tag | Prompt or field source | Notes |
| --- | --- | --- |
| Chatty miles | "My ideal run vibe is..." | Good matchability signal |
| Quiet miles | Same | Important compatibility signal |
| Coffee after | "After a run, find me..." | Strong social hook |
| Race-training | Running goal field or prompt | More emotional than pace alone |
| Run for headspace | Running reason field or prompt | Implemented from running reasons |
| Route explorer | Running style field or prompt | Useful personality signal |
| Walk-run friendly | Running style field or prompt | Inclusion and expectation-setting |
| Music runner | Running preference field | Potential conversation hook |

## Workstream 3: Why You Might Click

This feature should generate 1-3 short compatibility reasons for the profile card. Reasons must be specific, true, and not overstate certainty.

Running reasons:

| Reason | Source |
| --- | --- |
| You both prefer morning runs | Preferred run times now; attendance later |
| Your pace ranges overlap | Pace range fields |
| You both like easy social runs | Running vibe/reason |
| You both prefer 5K runs | Preferred distances |
| You both showed up to the same run | Event context |
| You both run with the same club | Run-club membership/history |
| You both like coffee-after-run energy | Prompt/tag |

Non-running reasons:

| Reason | Source |
| --- | --- |
| You are looking for the same thing | Relationship goal |
| You both wrote thoughtful prompts | Profile quality/completeness |
| You both mention food, music, books, travel, or similar themes | Prompt/caption text matching, later NLP |
| You both prefer low-pressure conversation starters | Prompt interaction patterns, future |
| You share language preferences | Profile facts |
| You have compatible age preferences | Match filters |
| Their profile has a prompt you can easily respond to | Prompt quality heuristic |

Avoid:

- Same city while the matching pool is already city scoped.
- Vague reasons like "You seem compatible".
- Reasons based on sensitive or protected attributes.
- Reasons that imply exact inference from weak data.

## Workstream 4: Profile Quality Guidance

The goal is to improve conversion by helping users build profiles that make others more likely to start a conversation.

Candidate surfaces:

| Surface | Purpose | Notes |
| --- | --- | --- |
| Edit Profile top panel | Profile strength, missing items, primary CTA | Best main home |
| Prompt section inline nudges | Suggest stronger prompt answers | Useful but should not feel noisy |
| Photo section inline nudges | Encourage captions and varied photos | High impact |
| Preview tab checklist | Show what would improve the public card | Good education surface |
| Post-onboarding nudge | Catch incomplete profiles after signup | Keep low friction |

Draft guidance categories:

- Add at least 3 clear photos.
- Add captions to photos that create easy openers.
- Answer 3 prompts with specifics, not generic claims.
- Include one running-specific detail that says how it feels to run with you.
- Fill pace, distance, why, and run-time preferences so compatibility reasons can be generated.
- Use one playful or personal detail outside running.

## Workstream 5: Data Model and Scoring

Likely additions:

- Profile completeness score or derived view model.
- Emotional run tags, with `derived` vs `userSelected` provenance.
- Compatibility reason generator that receives viewer profile, target profile, and event context.
- Optional per-block quality hints for prompts/photos.

Open modeling questions:

- Should historical event/run-club participation be projected into public profiles, or fetched as event context only?
- Should attendance history later refine selected time-of-day preferences, and should that influence recommendations separately from profile display?
- Should compatibility reasons stay client-side, move to Functions, or be precomputed for the event swipe window once they depend on richer context?
- Should complete profiles get a public badge everywhere, or only inside the compatibility/profile-signals section?

## Proposed Iteration Order

1. Finalize confidence-signal rules and whether to show run history publicly.
2. Define the emotional run tag catalog, including derived vs asked fields.
3. Define the compatibility reason generator and rank order.
4. Mock up the profile card with confidence signals, emotional tags, and the compatibility ribbon.
5. Implement data/model additions behind the shared public profile card.
6. Add owner-only profile quality guidance in Edit Profile and Preview.
7. Add tests for scoring, reason generation, omitted empty signals, and card overflow.

## Verification Plan

- Widget tests for profile-card rendering with and without each signal category.
- Unit tests for profile completeness scoring.
- Unit tests for emotional tag derivation.
- Unit tests for compatibility reason generation and ordering.
- Golden or screenshot checks for long names, long prompts, missing photos, and dense chip sets.
- Focused `flutter analyze` and profile/public-profile/swipe tests.
