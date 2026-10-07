# Protected WhatsApp actor session handoff

This user-operated helper exports an already signed-in Google actor's short-lived
Firebase ID token into the existing operator runtime's protected file format.
It creates no plan, approval, `adminOwner` grant or provider action. Existing
setup planning, account-incarnation, recipient preservation, endpoint, receipt,
STOP and replay enforcement remain in the operator runtime.

Source publication alone does not activate this flow. The parent owns CI,
merge and hosting promotion. Any real-account operation, credential use or
owner grant still needs its separate explicit action approval. This change was
validated with synthetic identities only.

After the exact reviewed source and Admin route are available:

1. Select an absolute owner-only directory outside every Git checkout. Use the
   same directory for `CATCH_WHATSAPP_OPERATOR_HOME` in subsequent existing
   operator commands. Do not use chat, clipboard, command arguments, shell
   environment or logs to transfer tokens or passwords.
2. Build the Functions runtime from the selected clean committed checkout.
   Obtain its existing offline fingerprint with
   `node functions/scripts/operations/setup-catch-whatsapp-reply.cjs fingerprint`.
   Prepare the existing six-field profile shape (`schemaVersion`, `scope`,
   `sourceSha`, `executionSha256`, `credentialVersionName`, `runtimePrincipal`)
   from approved operator inputs. `credentialVersionName` is a numeric version
   resource address, never a secret payload. The helper does not discover live
   accounts, endpoints, credentials, IAM or approval state.
3. Sign in as the exact selected Google actor using Catch's existing normal
   sign-in UI for the selected Firebase project. The actor must already exist;
   this helper introduces no sign-in, account creation, linking, custom token,
   OAuth scope or persistence migration. A refresh cannot replace a fresh
   sign-in. Sign-in must be less than five minutes old at save time.
4. Start the helper with non-secret directory and HTTPS Admin origin inputs:

   ```sh
   node functions/scripts/operations/catch-whatsapp-session-handoff.cjs \
     --home /absolute/owner-only/operator-home \
     --client-origin https://your-existing-admin-origin.example
   ```

5. Open the returned `launchFile` directly in the same browser profile as the
   normal sign-in. The file is mode `0600`, inside a mode `0700` directory. Its
   private one-use launch capability is not printed; do not share the file.
   Enter only the selected non-secret profile configuration in the local UI.
   Validation does not persist it or approve setup. An existing profile is
   displayed read-only and is never rebound or overwritten automatically.
6. Open the handoff view from the local UI. Check its exact project, actor UID,
   local destination and source; choose **Transfer my current Google session**.
   Only that window and origin can return that request's token. The local
   helper verifies the signed token with revocation checking, exact account,
   Google provider, project, email fingerprint and fresh `auth_time`. After all
   bindings are rechecked it saves `profile.json` if absent and atomically
   replaces `actor-id-token.txt`, each mode `0600`. The receipt contains no token.

The launch expires after five minutes and is one-use. Cancel in either protected
UI, close the local UI, or stop the helper before saving to abort. Interrupted
window/opener communication, including browser COOP restrictions, fails closed;
restart through the protected UI rather than copying credentials manually.
A cancellation racing a completed save reports the saved state where the helper
can confirm it; an unconfirmed cancellation requires checking the helper before
retrying. The session file contains no refresh credential and expires at the
signed token's expiry; the runtime must verify it on every use. The file is not
automatically deleted at expiry.

Permissions bind access to the delegated OS owner; they do not defend against
another process running as that same owner or prove human approval. Other
local users cannot initialize the helper from its public loopback page alone.
Host, Origin, one-use capability, exclusive HttpOnly SameSite cookie and CSRF
checks protect the local endpoints. Configuration, session, home or committed
helper/runtime drift, account mismatch, expiry, revocation and cancellation
stop the save without granting authority. Existing unrelated operator files
and retained source/recovery evidence are preserved.
