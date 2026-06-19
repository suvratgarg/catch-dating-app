# Catch Admin

Internal admin and analytics console for Catch operations.

## CI/CD

`.github/workflows/admin-website.yml` validates admin-console changes on pull
requests and deploys the production Firebase Hosting `admin` target after
matching changes land on `main`. The deploy job requires the prod GitHub
Environment Vite Firebase/App Check variables and fails before build if the
dashboard would point at the wrong Firebase project or stay in sample mode.

## Local Development

```bash
npm install
npm run dev
```

The app starts in `sample` data mode by default so the UI can be reviewed before
admin claims and App Check are configured.

For live Firebase calls, create a local `.env.local` from `env.example` and set:

```bash
VITE_ADMIN_DATA_MODE=live
VITE_ADMIN_FIREBASE_ENV=dev
VITE_ADMIN_APPCHECK_SITE_KEY=<dev-web-app-check-site-key>
VITE_FIREBASE_MEASUREMENT_ID=<dev-web-measurement-id>
```

Live mode calls `adminGetOverview` for dashboard data,
`adminGetHostAnalytics` for host/admin analytics, `adminDecideAccessApplication`
for access review decisions, and `adminDecideClubClaim` for organizer claim
review. The signed-in Firebase user must have at least one admin custom claim
for overview reads: `admin`, `adminOwner`, `safetyReviewer`, `support`,
`finance`, or `analyticsViewer`.
Access application Approve/Deny and organizer claim Approve/Reject require
`admin`, `adminOwner`, or `support`.

Host analytics live mode reads the shared BigQuery-backed
`adminGetHostAnalytics` callable. Production hosting builds must set
`VITE_ADMIN_DATA_MODE=live`, `VITE_ADMIN_FIREBASE_ENV=prod`, and
`VITE_ADMIN_APPCHECK_SITE_KEY`; otherwise the deployed dashboard remains in
sample mode or fails App Check before it reaches the analytics backend.
Firebase Hosting deploys run `node tool/env/check_web_hosting_env.mjs admin`
before building so missing Firebase/App Check env fails before a dashboard can
be shipped.
