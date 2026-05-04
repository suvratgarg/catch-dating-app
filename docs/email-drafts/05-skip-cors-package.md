# Email Draft: Why we're NOT using the cors npm package

## What we found

The initial audit identified ~60 lines of "custom CORS logic" in
`functions/src/waitlist/joinWaitlist.ts` that could theoretically be replaced
by the `cors` npm package.

On closer inspection, the "custom CORS logic" breaks down as:

1. **`waitlistAllowedOrigins()`** (13 lines) — Domain-specific origin allowlist
   that varies by project ID (prod vs. non-prod Firebase projects, custom
   domain, localhost). This is business logic, not boilerplate. The `cors`
   package would still need this same function passed as its `origin` option.

2. **`setCorsHeaders()`** (12 lines) — Sets 4 headers. This is the only part
   the `cors` package could replace, saving ~7 lines.

3. **`resolveWaitlistCorsOrigin()`** (8 lines) — A thin resolver that calls
   into `waitlistAllowedOrigins`. Already extracted and testable.

4. **OPTIONS handler + origin check** (~10 lines) — This is the natural
   structure of the `onRequest` handler.

## Why we're keeping it

- **The `cors` package is an Express middleware.** Cloud Functions v2's
  `onRequest` has type-compatible `Request`/`Response` types but isn't full
  Express. Edge cases around the middleware-request-response lifecycle could
  surface.
- **Net savings: ~5-7 lines** for the cost of a new dependency. The
  origin-resolution logic (the actually complex part) stays the same
  regardless.
- **The current code has no bugs, no CVEs, no maintenance burden.** It's
  well-structured, project-aware, and tested.

## When we would add it

If we had 5+ HTTP endpoints all needing CORS, a shared middleware wrapper
(either custom or the `cors` package) would pay for itself. For a single
endpoint, the wrapper is more code than the inline headers.
