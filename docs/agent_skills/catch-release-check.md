# catch-release-check

Use for CI, Firebase deploys, native release config, App Store/TestFlight,
environment config, and release-readiness docs.

Read: `docs/release_operations.md`, `docs/web_surface_architecture.md`, and
`tool/README.md`.

Loop: build a release context pack, run local CI-equivalent checks, verify live
workflow/deploy state when the answer depends on it, and keep release docs in
sync with the verified state.

Failure modes to avoid: treating PR checks as deploy proof, ignoring tool
manifest drift, and assuming console state without verification.
