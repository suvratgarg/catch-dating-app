# Protected WhatsApp actor session handoff

This user-operated helper exports an already signed-in Google actor's short-lived
Firebase ID token into the existing operator runtime's protected file format.
It creates no plan, approval, `adminOwner` grant or provider action. Existing
setup planning, account-incarnation, recipient preservation, endpoint, receipt,
STOP and replay enforcement remain in the operator runtime.

Source publication alone does not activate this flow. The parent owns CI,
merge and hosting promotion. Any real-account operation, credential use,
provider change or owner grant still needs its separate explicit action approval.
Validation uses synthetic identities only. Google sign-in must already be
available through the existing normal UI; this helper cannot enable it or
substitute another provider.

After the reviewed source and matching Admin route are available:

1. Select an absolute owner-only directory outside every Git checkout. Use the
   same directory for `CATCH_WHATSAPP_OPERATOR_HOME` in subsequent existing
   operator commands. Do not use chat, clipboard, command arguments, shell
   environment or logs to transfer tokens or passwords.
2. Build the Functions runtime from the selected clean committed checkout.
   Obtain its existing offline fingerprint with
   `node functions/scripts/operations/setup-catch-whatsapp-reply.cjs fingerprint`.
   Prepare the existing six-field profile shape (`schemaVersion`, `scope`,
   `sourceSha`, `executionSha256`, `credentialVersionName`, `runtimePrincipal`)
   from approved operator inputs. The credential version is a numeric resource
   address, never a secret payload. No live accounts, endpoints, credentials,
   IAM or approval state are discovered by this helper.
3. Sign in as the exact selected Google actor through Catch's existing normal
   sign-in UI for the selected Firebase project, using the same browser profile.
   The actor must already exist. This helper adds no sign-in, account creation,
   linking, custom token, OAuth scope or persistence migration. A refresh cannot
   replace a fresh sign-in; `auth_time` must be at most fifteen minutes old at save.
4. Start the helper with non-secret directory and existing HTTPS Admin origin:

   ```sh
   node functions/scripts/operations/catch-whatsapp-session-handoff.cjs \
     --home /absolute/owner-only/operator-home \
     --client-origin https://your-existing-admin-origin.example
   ```

5. Open the returned `launchFile` directly. It is mode `0600` inside a mode
   `0700` directory. Do not share it. Its button navigates directly to the
   protected HTTPS Catch view with the original helper's keys and private
   one-use bootstrap capability. The view scrubs its fragment and severs its
   opener before any HTTP interaction; no loopback page supplies its trust root.
6. If the browser requests local-network permission for this explicit local
   handoff, refusal leaves it unavailable. Enter only the selected non-secret
   profile configuration in the protected HTTPS view. Validation does not persist
   it or approve setup. An existing profile is read-only and is never rebound or
   overwritten automatically. Check the selected directory, source/runtime
   fingerprints, project, actor and endpoint scope before saving.
7. Choose **Save my current Google session**. The view exports only the already
   signed-in exact actor, encrypting the session to the original helper process.
   The helper verifies the signed token with revocation checking, exact Google
   account, project, email fingerprint and fresh `auth_time`. After rechecking
   every binding it saves `profile.json` only if absent and atomically replaces
   `actor-id-token.txt`, each mode `0600`. The verified receipt contains no token.

The launch expires after fifteen minutes and is one-use. Explicit Cancel remains
available during verification. Closing the view attempts cancellation and
prevents further exports; an already committed save cannot be undone by closing
or losing a receipt. Unconfirmed save/cancellation outcomes require checking the
helper and session file before retrying. There is no automatic retry. The session
file contains no refresh credential and expires at the signed token's expiry;
the runtime verifies it on each use. The file is not automatically deleted.

The helper holds separate ephemeral RSA-OAEP and RSA-PSS private keys only in
memory. Bootstrap capabilities are encrypted, and tokens use RSA-OAEP wrapped
AES-GCM bound to the immutable challenge, scope, source, expiry and keys. Signed
responses bind method/path, a fresh request ID and the exact request digest.
Replacement loopback listeners cannot decrypt credentials, substitute keys or
forge receipts, including before the first HTTP response. Redirects and browser
credentials are disabled; CORS allows only the explicitly selected HTTPS origin.

Permissions bind the local files to the delegated OS owner; they do not defend
against a hostile process running as that same owner or prove human approval.
Configuration/session/home/source drift, account mismatch, expiry, revocation
and confirmed cancellation stop the save without granting authority. Unrelated
operator files and retained source/recovery evidence remain preserved.

Keep this bounded setup in your own foreground Terminal rather than relying on
an agent tool session as a persistent worker. After the personal Save succeeds,
run the existing `setup-catch-whatsapp-reply.cjs plan` command immediately from
the exact reviewed runtime with the same protected operator home. Use the exact
reviewed plan and separately supplied approval for `apply --plan-id <id>`.
The plan and pending recipient grant remain limited to fifteen minutes.
Bootstrap still pauses after seeding for a new sign-in before root activation;
use the protected helper again and continue only the same approved plan. A lost
or uncertain outcome requires supported read-only `reconcile --plan-id <id>`
before any continuation. Never automatically retry an unknown mutation.
