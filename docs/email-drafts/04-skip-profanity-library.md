# Email Draft: Why we're NOT replacing the text profanity filter

## What we found

The initial audit identified `functions/src/moderation/textFilter.ts` (~149
lines) as a candidate for replacement by `bad-words` (v4.0.0, last updated Aug
2024) or `leo-profanity` (v1.9.0, last updated Jan 2026).

On deeper analysis, neither library can replace what this module actually does.

## Three dealbreakers

### 1. Multi-word phrase matching

Both libraries are **word-level** filters — they match individual tokens. The
current filter matches **phrases** using substring search:

```
BLOCK: "i will kill you", "kill yourself", "i know where you live and"
FLAG:  "whatsapp me", "dm me on insta", "telegram me", "earn money fast"
```

These are critical for safety (credible threats) and anti-spam (off-platform
solicitation). Word-level filters miss these entirely since each individual
word is harmless.

### 2. Domain-specific lists

The current lists include terms no generic profanity library would have:

- **India-specific hate speech:** "chamar", "bhangi", "chura", "mulla", "kafir"
  (casteist and religious slurs)
- **India-specific profanity:** "bhenchod", "madarchod", "chutiya", "harami"
- **PII detection:** "my aadhaar", "my pan card", "my passport number"
- **Off-platform solicitation:** "whatsapp me", "add me on snap", "telegram me"
- **Scam patterns:** "earn money fast", "work from home earn"

These domain-specific lists are the real value of the module. A generic library
would require adding ALL of these as custom words anyway — we'd be maintaining
custom word lists PLUS a library dependency.

### 3. Two-tier block/flag system

The current system distinguishes between:
- **BLOCK** — content is immediately removed (hate speech, threats)
- **FLAG** — content is queued for human review (mild profanity, solicitation)

Generic libraries only provide binary "is profane" / "is clean" checks. The
two-tier system is business logic that the library can't replace.

## What we should do instead

The module's own doc comment at lines 31-33 already describes the right
improvement:

> For runtime configurability without a deploy, add a Firestore document
> at `config/moderation` that this module reads on cold start.

This would let us update the word lists from the Firebase console without
deploying code — a bigger operational win than swapping to a library that
doesn't cover our use case anyway.

## The one library improvement worth making

Both libraries' built-in word lists are more comprehensive for English
profanity than our 6-entry list. We could **seed** our list by copying their
default word lists into our config, giving us broader coverage while keeping
our domain-specific additions and phrase matching.
