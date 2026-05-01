# Cloud Functions

Functions are deployed to `asia-south1` in all Firebase environments:

- `dev` -> `catchdates-dev`
- `staging` -> `catchdates-staging`
- `prod` -> `catch-dating-app-64e51`

## Security Defaults

Callable app endpoints must use the shared App Check options from
`src/shared/callableOptions.ts`.

Use:

```ts
onCall(appCheckCallableOptions, handler)
onCall(appCheckCallableOptionsWithSecrets([...]), handler)
```

Do not inline `{enforceAppCheck: true, invoker: "public"}` in individual
function files. Firebase callable Gen 2 functions must be publicly invokable at
the Cloud Run/IAM layer so client SDK calls can reach the callable adapter; App
Check and Firebase Auth are then enforced by the shared callable options and
each handler. The shared options declare this intent, and the default `npm test`
suite includes a guard test that fails when an exported callable does not use
the shared App Check options.

After deploying callable Functions, run `npm run sync:callable-invokers -- \
<project-id> [...]`. Current callable deployment manifests do not reliably
propagate `invoker` onto the underlying Cloud Run services, and a missing
binding shows up as a Cloud Run/GFE HTML 401/403 before Firebase callable
handling. The sync command grants `allUsers` only the `roles/run.invoker`
permission on the callable Cloud Run services; it does not bypass Firebase Auth
or App Check.

The public `joinWaitlist` endpoint is an HTTPS endpoint for the marketing site,
not a Firebase callable function. It uses an explicit CORS origin allowlist for
Catch domains, Firebase Hosting domains, and local previews. Keep any future
public web-abuse controls for that endpoint separate from callable App Check
enforcement.

## Secrets

Razorpay secret definitions live in `src/payments/razorpay.ts`.

Current state: `dev`, `staging`, and `prod` use the same Razorpay test-mode
secrets because live Razorpay credentials have not been introduced yet.

Before real payments launch:

1. Create environment-owned Razorpay test/live credentials.
2. Set `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` in each Firebase project.
3. Deploy Functions for each environment.
4. Smoke test order creation, payment verification, cancellation, and refunds.

## Commands

```bash
npm run lint
npm test
./tool/firebase_with_env.sh dev deploy --only functions
./tool/firebase_with_env.sh staging deploy --only functions
./tool/firebase_with_env.sh prod deploy --only functions
npm run sync:callable-invokers -- catchdates-dev catchdates-staging catch-dating-app-64e51
```
