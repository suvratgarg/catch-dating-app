# Catch Admin

Internal admin and analytics console for Catch operations.

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
```

Live mode calls `adminGetOverview` for dashboard data,
`adminDecideAccessApplication` for access review decisions, and
`adminDecideClubClaim` for organizer claim review. The signed-in Firebase user
must have at least one admin custom claim for overview reads: `admin`,
`adminOwner`, `safetyReviewer`, `support`, `finance`, or `analyticsViewer`.
Access application Approve/Deny and organizer claim Approve/Reject require
`admin`, `adminOwner`, or `support`.
