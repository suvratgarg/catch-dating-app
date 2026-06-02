---
doc_id: web_surface_architecture
version: 0.3.0
updated: 2026-06-02
owner: web_platform
status: active
---

# Web Surface Architecture

## Decision

Use one apex domain with separate subdomains for distinct web products:

| Domain | Surface | Repo source | Firebase Hosting target |
|---|---|---|---|
| `catchdates.com` | Public marketing site, public host pages, SEO pages, legal/support pages, app-link files, and public lead capture | `website/` | `marketing` |
| `www.catchdates.com` | Redirect to `catchdates.com` | Firebase custom domain redirect | `marketing` |
| `app.catchdates.com` | Consumer app on Flutter web | `build/web` | `app` |
| `admin.catchdates.com` | Internal admin and analytics console | `admin/` | `admin` |

Keep the Flutter web app separate from the public website. The Flutter web app is
the consumer app surface and should continue sharing mobile app code. The
marketing and admin surfaces are web-native products and should use the same
React + TypeScript stack where practical.

## Current Stack

- Root `package.json` exposes npm workspace scripts for the web-native apps.
- `packages/web-config/` contains shared Vite, TypeScript, and token/base CSS
  plumbing for React web surfaces.
- `website/` is a Vite + React + TypeScript marketing app.
- `website/public/` contains Vite public assets, including `.well-known/`, fonts,
  app-sourced marketing screenshots, and the favicon.
- `website/dist/` is the deployable marketing build.
- `website/scripts/postbuild.mjs` writes a static `host/index.html` after the
  Vite build so `/host/` has route-specific title, description, canonical, and
  Open Graph metadata.
- `admin/` remains the separate Vite + React + TypeScript admin app.
- `build/web` remains the Flutter web deploy artifact for `app.catchdates.com`.

Design-token CSS and web font copies are generated into
`packages/web-config/generated/` by `dart run tool/design_tokens.dart`, then
bundled by Vite through `packages/web-config/styles/catch-web.css`.

## Firebase Hosting Setup

`firebase.json` declares three Hosting targets:

- `marketing`: builds `website/` and deploys `website/dist`.
- `app`: deploys `build/web` for the Flutter web app.
- `admin`: builds `admin/` and deploys `admin/dist` with `X-Robots-Tag:
  noindex, nofollow`.

The production `.firebaserc` currently binds `marketing` to the existing default
Hosting site, `catch-dating-app-64e51`. Before deploying the `app` or `admin`
targets, create or choose actual Firebase Hosting site IDs and bind them:

```sh
firebase target:apply hosting marketing <marketing-site-id> --project <project-id>
firebase target:apply hosting app <app-site-id> --project <project-id>
firebase target:apply hosting admin <admin-site-id> --project <project-id>
```

Then attach custom domains in Firebase Hosting:

- `catchdates.com` and `www.catchdates.com` to the marketing site.
- `app.catchdates.com` to the app site.
- `admin.catchdates.com` to the admin site.

The existing default Hosting site can remain the marketing site if it is already
bound to `catchdates.com`; the app and admin surfaces should still be separate
Hosting sites.

## Marketing CI/CD

`.github/workflows/marketing-website.yml` is the marketing site's scoped
pipeline:

- pull requests validate generated web tokens, app-derived screenshot assets,
  marketing screenshot design context, and the Vite production build;
- pushes to `main` that touch marketing-site inputs deploy only
  `hosting:marketing` to the production Firebase project;
- deployment uses the checked `prod` Firebase alias plus the repo's existing
  Google Cloud Workload Identity environment variables.

The workflow intentionally does not deploy Cloud Functions. Backend production
changes, including `/api/join-waitlist`, still go through the guarded Firebase
deploy workflow so hosting and backend release risk stay independently
controlled.

## Future Host Dashboard

A future host dashboard still fits this architecture. Prefer:

| Domain | Surface | Stack | Permission model |
|---|---|---|---|
| `hosts.catchdates.com` | Authenticated host portal for club/event management, scoped analytics, payout readiness, and event operations | React + TypeScript | Server-side Functions authorize host ownership per club/event |

Do not put host tools under `admin.catchdates.com`. Hosts are external operators,
not internal admins. Keep `/host/` on `catchdates.com` as the public host
marketing/acquisition page, and use `hosts.catchdates.com` only for authenticated
host workflows once that product exists.

Host portal APIs should follow the same server-owned pattern as admin APIs:

- the browser client never receives service-account credentials;
- Functions validate Firebase Auth and host ownership;
- mutations write audit or activity records where operationally useful;
- analytics responses are scoped to clubs/events the signed-in host can manage.

## Why Subdomains Instead Of Paths

Subdomains keep each surface independently deployable and reduce routing
conflicts:

- Flutter web can own `app.catchdates.com/**` without sharing a catch-all with
  the marketing site.
- Marketing can own SEO pages, `/host/`, `.well-known/`, and public Functions
  rewrites.
- Admin can use separate security headers, App Check settings, auth behavior,
  and release cadence.
- A future host portal can be added without overloading either the consumer app
  or the internal admin console.
