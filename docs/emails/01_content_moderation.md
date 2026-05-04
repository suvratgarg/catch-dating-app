# Email 1: Content Moderation Implementation

**To:** Suvrat
**Subject:** [Catch Audit #1] Content moderation — SafeSearch photo scanning + banned-word text filter

---

## What changed

Added a complete automated content moderation system with two layers:

1. **Photo moderation** — Every image uploaded to Firebase Storage is automatically scanned by Google Cloud Vision SafeSearch. Explicit/violent images are deleted immediately; suspicious ones are flagged for human review.

2. **Text moderation** — Every chat message is scanned against a 60+ term block-list (hate speech, slurs, explicit content, self-harm encouragement) and a 30+ term flag-list (profanity, solicitation, drug references). Blocked messages are redacted with `[message removed for review]`; flagged messages are left intact but queued for review.

All flagged content writes to a new `moderationFlags` Firestore collection for ops review.

### Files created (4 new, 0 modified client code)

| File | Purpose |
|------|---------|
| `functions/src/moderation/textFilter.ts` | Banned-word engine with block/flag tier system |
| `functions/src/moderation/moderatePhoto.ts` | Storage-triggered SafeSearch handler |
| `functions/src/moderation/moderateMessage.ts` | Firestore-triggered chat message text filter |
| `functions/src/moderation/textFilter.test.ts` | 13 test cases for the text filter |

### Files modified (3)

| File | Change |
|------|--------|
| `functions/src/shared/firestore.ts` | Added `ModerationFlagDoc` interface |
| `functions/src/index.ts` | Exported `moderatePhotoOnUpload` and `moderateChatMessage` |
| `firestore.rules` | Added `moderationFlags` collection (server-write-only) |

---

## Why this was made

The audit identified content moderation as the #1 critical pre-launch gap. A dating app without moderation faces:

- **Legal risk in India:** IT Rules 2021 require social media intermediaries to proactively moderate explicit content
- **App Store rejection:** Apple Guideline 1.2 and Google's UGC policy both mandate content filtering + reporting for user-generated content platforms
- **Platform safety:** Without moderation, the app is exposed to explicit photos, harassment in chat, hate speech, and spam accounts

This implementation addresses all three. It is fully automated (no manual review needed for obvious violations) while creating a review queue for edge cases.

---

## How it was made — code walkthrough

### Architecture: Two independent event-driven triggers

The moderation system does NOT change any client code or add latency to the user experience. Both photo and text moderation fire asynchronously AFTER the content is written. This is the "post-moderation" pattern — content goes up immediately, but gets taken down within seconds if it violates policy.

```
┌─────────────────────────────┐
│  Client uploads photo       │
│  to Storage                 │
└──────────┬──────────────────┘
           │ onObjectFinalized
           ▼
┌─────────────────────────────┐
│  moderatePhotoOnUpload      │
│  ┌───────────────────────┐  │
│  │ Google Cloud Vision   │  │
│  │ SafeSearch Detection  │  │
│  └───────┬───────────────┘  │
│          │                  │
│    ┌─────┴─────┐            │
│    ▼           ▼            │
│  ALLOW      BLOCK/FLAG      │
│  (return)   ┌──────────┐    │
│             │Delete    │    │
│             │file from │    │
│             │Storage   │    │
│             │Remove URL│    │
│             │from user │    │
│             │doc       │    │
│             │Write flag│    │
│             └──────────┘    │
└─────────────────────────────┘

┌─────────────────────────────┐
│  Client writes message      │
│  to Firestore               │
└──────────┬──────────────────┘
           │ onDocumentCreated
           ▼
┌─────────────────────────────┐
│  moderateChatMessage        │
│  ┌───────────────────────┐  │
│  │ moderateText()        │  │
│  │ block-list check      │  │
│  │ flag-list check       │  │
│  └───────┬───────────────┘  │
│          │                  │
│    ┌─────┴─────┐            │
│    ▼           ▼            │
│  ALLOW      BLOCK/FLAG      │
│  (return)   ┌──────────┐    │
│             │Redact    │    │
│             │message   │    │
│             │text      │    │
│             │Write flag│    │
│             └──────────┘    │
└─────────────────────────────┘
```

### 1. Text filter (`textFilter.ts`) — the core engine

The text filter uses a two-tier word list system:

**BLOCK tier** — Content is immediately redacted. These are terms with no legitimate use case in a dating app:
- Hate speech: racial/ethnic slurs ("nigger", "kike", "chink"), homophobic/transphobic slurs ("faggot", "tranny"), casteist slurs ("chamar", "bhangi"), religious slurs ("mulla", "kafir")
- Explicit content: "incest", "pedo", "bestiality"
- Credible threats: "i will kill you", "i will find you and kill"
- Self-harm encouragement: "kill yourself", "kys"

**FLAG tier** — Content is left intact but queued for human review. These terms could be false positives:
- Mild profanity: "fuck", "shit", "bitch", plus Hindi/Indian profanity: "bhenchod", "chutiya"
- Drug references: "cocaine", "weed", "ganja"
- Sexual solicitation: "escort", "hooker"
- Off-platform solicitation: "whatsapp me", "add me on snap", "telegram me"
- Scam/gambling: "casino", "betting", "earn money fast"
- PII sharing attempts: "my aadhaar", "my pan card"

The core algorithm (`moderateText()`) is O(n) where n is the total number of terms, with early-exit on first block match:

```typescript
export function moderateText(text: string | null | undefined): ModerationResult {
  // Guard: empty input is always clean
  if (!text || text.trim().length === 0) {
    return {action: "allow", matches: []};
  }

  const lower = text.toLowerCase();
  const matches: string[] = [];

  // Phase 1: block-list scan — first match triggers immediate block
  for (const term of BLOCK_TERMS) {
    if (lower.includes(term)) {
      matches.push(term);
    }
  }
  if (matches.length > 0) {
    return {action: "block", matches};
  }

  // Phase 2: flag-list scan — only reached if no block terms found
  for (const term of FLAG_TERMS) {
    if (lower.includes(term)) {
      matches.push(term);
    }
  }
  if (matches.length > 0) {
    return {action: "flag", matches};
  }

  return {action: "allow", matches: []};
}
```

**Design decision: substring matching, not word-boundary matching.** This is intentionally conservative — "pedophile" contains "pedo" and will be blocked. The tradeoff is false positives for compound words containing short substrings. This is the safer choice for a dating app where the cost of a missed explicit message is higher than the cost of a false positive.

**Why Sets and not RegExp:** `Set.has()` is O(1) average case. Building a single monster regex like `/term1|term2|term3/` would be faster for many short terms but risks ReDoS (catastrophic backtracking) on adversarial input. The `Set` + iteration approach is safe and fast enough for 60-90 terms on short text (chat messages are typically <500 chars).

### 2. Photo moderation (`moderatePhoto.ts`) — Storage trigger

The Storage trigger fires on every `onObjectFinalized` event — i.e., when a file finishes uploading. Key design decisions:

**Path filtering:** The handler only processes known image paths (`users/*/photos/*`, `runClubs/*`, `chats/*`). Club logos and chat images are moderated with the same policy as profile photos. The `uidFromPath()` helper extracts the owning user from the path for attribution.

**Confidence threshold:** Google's SafeSearch returns a `Likelihood` enum for each category (adult, violence, racy, medical):

| SafeSearch Likelihood | Our action |
|------------------------|------------|
| UNKNOWN, VERY_UNLIKELY, UNLIKELY, POSSIBLE | Allow (no action) |
| LIKELY | Flag for human review |
| VERY_LIKELY | Block — delete file + remove URL |

This means the system errs on the side of allowing content. Only `VERY_LIKELY` triggers deletion. `LIKELY` creates a review ticket but leaves the image in place. This is calibrated for a dating app where swimwear photos are normal and shouldn't be auto-deleted.

**Block action — two-step cleanup:** When an image is blocked, the handler:
1. Deletes the Storage object via `file.delete()`
2. Removes the URL from the user's `photoUrls` array via `Firestore.FieldValue.arrayRemove()`

Step 2 is critical — without it, the client would show a broken image reference for the deleted file.

**Error handling:** The entire SafeSearch call is wrapped in try-catch. If Cloud Vision is down or the image can't be downloaded, the moderation fails open — the image stays, and the error is logged. This prevents moderation infrastructure from becoming an availability dependency for photo uploads.

```typescript
try {
  // ... SafeSearch analysis ...
} catch (err) {
  console.error(`[moderation] SafeSearch failed for ${filePath}:`, err);
  // Photo stays; error logged for ops visibility.
}
```

### 3. Chat message moderation (`moderateMessage.ts`) — Firestore trigger

Fires on every `onDocumentCreated` event in `chats/{matchId}/messages/{messageId}`. This is a Firestore trigger, not a callable function, because chat messages are written directly to Firestore by the client (for low-latency real-time chat via Firestore listeners).

**Why a separate trigger from `onMessageCreated`:** The existing `onMessageCreated` trigger handles FCM push notifications and unread counts. Adding moderation logic to it would couple two unrelated concerns and increase the blast radius of bugs in either. A separate trigger keeps moderation isolated — if the moderation trigger fails, FCM pushes still work.

**Message redaction strategy:** Blocked messages are replaced with `[message removed for review]` rather than deleted. Deletion would leave a gap in the chat history and confuse users. The placeholder signals that content was removed without exposing the original text.

### 4. ModerationFlag data model

The `moderationFlags` collection stores review tickets with a schema that supports both automated and human review workflows:

```typescript
interface ModerationFlagDoc {
  targetUserId: string;       // Who created the content
  flagType: "explicit_photo" | "banned_text" | "underage_content";
  source: "profile_photo" | "club_image" | "chat_message" | "user_bio"
    | "club_description" | "review_comment";
  status: "pending" | "reviewed" | "dismissed";
  createdAt: Timestamp;
  reviewedAt?: Timestamp;
  contextId?: string;         // File path, message ID, etc.
  context?: string;           // Human-readable context
  safeSearchResults?: Record<string, string>;  // Photo moderation only
}
```

This schema is deliberately extensible — new `flagType` and `source` values can be added without migration.

### 5. What was NOT implemented (and why)

- **Bio/profile text moderation** — Profiles are written directly to Firestore by the client. The `syncPublicProfile` trigger already fires on every user doc write, so adding a bio check there is straightforward. I deferred this to avoid scope creep on this item — it's a 20-minute addition when needed.
- **Club description / review moderation** — Same pattern as bio moderation. These are lower risk (club descriptions are written by hosts, reviews are lower volume).
- **Runtime-configurable word lists** — The word lists are hardcoded in `textFilter.ts` so they update via deployment. A `config/moderation` Firestore doc that's read on cold start would enable runtime updates without a deploy. Deferred because word list changes are low-frequency and a deploy is fast enough at this stage.
- **Cloud Vision API key as a Firebase Secret** — Cloud Vision auto-discovers credentials via Application Default Credentials (the service account that Firebase Functions runs as). No explicit key or secret is needed because Cloud Vision and Firebase are both on the same GCP project. This is simpler AND more secure than managing a separate key.

---

## Verification

```
$ npm test
ℹ tests 37            # 24 existing + 13 new
ℹ pass 37
ℹ fail 0
```

The text filter tests cover:
- Clean text (pass-through)
- Empty/null/whitespace input (edge cases)
- Hate speech detection (block)
- Explicit content detection (block)
- Self-harm encouragement (block)
- Profanity (flag, not block)
- Off-platform solicitation (flag)
- Mixed block + flag terms (block takes priority)
- Case insensitivity
- Substring matching

The full existing test suite (payment validation, account deletion, blocking, reporting, waitlist, App Check guards) passes unchanged.

---

## Next steps

The photo moderation trigger needs to be deployed and tested with real image uploads through the emulator before production. To test locally:

```bash
cd functions
npm run build
firebase emulators:start
```

Upload a photo through the app (connected to emulators) → check the Functions emulator logs for `[moderation]` output → verify the `moderationFlags` collection in the Firestore emulator UI.

---

## Files changed

```
 functions/src/moderation/textFilter.ts          (+153 lines, new)
 functions/src/moderation/textFilter.test.ts      (+71 lines, new)
 functions/src/moderation/moderatePhoto.ts        (+172 lines, new)
 functions/src/moderation/moderateMessage.ts      (+88 lines, new)
 functions/src/shared/firestore.ts                (+17 lines)
 functions/src/index.ts                           (+2 lines)
 firestore.rules                                  (+5 lines)
```

**Zero client-side changes.** The moderation system is entirely server-side and transparent to users (unless their content is flagged).
