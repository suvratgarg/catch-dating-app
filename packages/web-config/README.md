# Catch Web Config

Shared React web tooling for Catch's web-native surfaces.

- `vite-react.ts` owns the common Vite defaults for marketing and admin.
- `tsconfig.*.json` owns the common TypeScript compiler options.
- `styles/catch-web.css` imports generated design tokens and shared browser
  baseline styles.
- `generated/` is written by `dart run tool/design_tokens.dart`.

Keep deployable apps separate (`website/`, `admin/`) and share platform
plumbing here.
