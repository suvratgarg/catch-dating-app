---
status: active
---

# Catch Web Config

Shared React web runtime configuration and tooling for Catch's web-native surfaces.

- `vite-react.ts` owns the common Vite defaults for marketing and admin.
- `tsconfig.*.json` owns the common TypeScript compiler options.
- `styles/catch-web.css` imports generated design tokens and shared browser
  baseline styles.
- `generated/` is written by `dart run tool/design_tokens.dart`.

Keep deployable apps separate (`website/`, `admin/`) and share platform
plumbing here.

Runtime imports use the `@catch/web-config` workspace:

- `@catch/web-config/query` creates independent TanStack Query clients with one
  retry/cache policy. Public roots own their clients; Admin supplies a shorter
  freshness window and retains its session mutation fence and cache teardown.
- `@catch/web-config/firebase` owns environment field mapping and the development
  project configuration. The website requires a complete explicit production
  configuration. Admin currently retains its existing per-field development
  fallback; production build validation must supply and verify its environment.
  App Check provider selection and authorization remain surface-owned.

Sharing these factories does not share cached private data or sign users into
another origin. Firebase Auth persistence and session/role lifetimes remain
owned by each application.
