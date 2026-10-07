import type {ApplicationVerifier, Auth, User} from "firebase/auth";
type AuthSdk = typeof import("firebase/auth");

function unchanged(auth: Auth, user: User) {
  if (auth.currentUser?.uid !== user.uid) throw new Error("Your account changed. Restart verification from the current account.");
}
function recovery(error: unknown): never {
  const code = error && typeof error === "object" && "code" in error ? String(error.code) : "";
  if (["auth/credential-already-in-use", "auth/account-exists-with-different-credential",
    "auth/email-already-in-use", "auth/provider-already-linked"].includes(code)) {
    throw new Error("This sign-in method belongs to an existing account or is already linked. Sign in to that account or contact support to recover access. Accounts were not combined.");
  }
  throw error;
}

/** Explicit verification links credentials to the existing UID, never merges accounts. */
export async function signInOrLinkClaimGoogle(auth: Auth, sdk?: AuthSdk): Promise<void> {
  await auth.authStateReady();
  const api = sdk ?? await import("firebase/auth");
  const current = auth.currentUser;
  const provider = new api.GoogleAuthProvider();
  provider.setCustomParameters({prompt: "select_account"});
  try {
    if (!current) {
      const result = await api.signInWithPopup(auth, provider);
      unchanged(auth, result.user);
      await result.user.getIdToken(true);
      return;
    }
    unchanged(auth, current);
    const result = current.providerData.some((p) => p.providerId === "google.com") ?
      await api.reauthenticateWithPopup(current, provider) : await api.linkWithPopup(current, provider);
    unchanged(auth, current);
    if (result.user.uid !== current.uid) throw new Error("Verification did not preserve your account. Restart from the current account.");
    await result.user.getIdToken(true);
  } catch (error) {recovery(error);}
}

/** Sales-only path; public guest phone sign-in semantics remain separate. */
export async function beginClaimPhoneLink(auth: Auth, phone: string,
  verifier: ApplicationVerifier, sdk?: AuthSdk) {
  await auth.authStateReady();
  const api = sdk ?? await import("firebase/auth");
  const current = auth.currentUser;
  try {
    if (!current) {
      const confirmation = await api.signInWithPhoneNumber(auth, phone, verifier);
      return {confirm: async (code: string) => {
        if (auth.currentUser) throw new Error("Your account changed. Restart verification from the current account.");
        try {
          const result = await confirmation.confirm(code);
          unchanged(auth, result.user);
          await result.user.getIdToken(true);
          return result;
        } catch (error) {return recovery(error);}
      }};
    }
    unchanged(auth, current);
    if (current.phoneNumber && current.phoneNumber !== phone) {
      throw new Error("Use the phone already linked to this account, or recover the intended account before continuing.");
    }
    if (!current.phoneNumber) {
      const confirmation = await api.linkWithPhoneNumber(current, phone, verifier);
      return {confirm: async (code: string) => {
        unchanged(auth, current);
        try {
          const result = await confirmation.confirm(code);
          unchanged(auth, current);
          if (result.user.uid !== current.uid) throw new Error("Phone verification changed your account. Restart verification.");
          await result.user.getIdToken(true);
          return result;
        } catch (error) {return recovery(error);}
      }};
    }
    const verificationId = await new api.PhoneAuthProvider(auth).verifyPhoneNumber(phone, verifier);
    return {confirm: async (code: string) => {
      unchanged(auth, current);
      try {
        const result = await api.reauthenticateWithCredential(current,
          api.PhoneAuthProvider.credential(verificationId, code));
        unchanged(auth, current);
        if (result.user.uid !== current.uid) throw new Error("Phone verification changed your account. Restart verification.");
        await result.user.getIdToken(true);
        return result;
      } catch (error) {return recovery(error);}
    }};
  } catch (error) {return recovery(error);}
}
