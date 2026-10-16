import {
  type ConfirmationResult,
  getAuth,
  GoogleAuthProvider,
  RecaptchaVerifier,
  signInWithPhoneNumber,
  signInWithPopup,
  signOut,
} from "firebase/auth";
import {firebaseApp} from "./firebaseCore";
export {firebaseConfig} from "./firebaseCore";

export const auth = getAuth(firebaseApp);

export async function signInWithGoogleAdmin() {
  resetPhoneSignIn();
  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({prompt: "select_account"});
  await signInWithPopup(auth, provider);
}

let phoneSignInGeneration = 0;
let phoneConfirmation: ConfirmationResult | null = null;
let phoneRecaptchaVerifier: RecaptchaVerifier | null = null;

export async function requestPhoneSignInCode(phoneNumber: string) {
  resetPhoneSignIn();
  const generation = phoneSignInGeneration;
  const verifier = new RecaptchaVerifier(
    auth,
    "admin-phone-recaptcha",
    {size: "invisible"}
  );
  phoneRecaptchaVerifier = verifier;
  try {
    const confirmation = await signInWithPhoneNumber(
      auth,
      phoneNumber,
      verifier
    );
    if (generation !== phoneSignInGeneration) {
      throw new Error("Phone verification was cancelled. Request a new code.");
    }
    phoneConfirmation = confirmation;
  } catch (error) {
    if (generation === phoneSignInGeneration) resetPhoneSignIn();
    throw error;
  }
}

export async function confirmPhoneSignInCode(code: string) {
  if (!phoneConfirmation) {
    throw new Error("Request a phone verification code before continuing.");
  }
  await phoneConfirmation.confirm(code);
  resetPhoneSignIn();
}

export function resetPhoneSignIn() {
  ++phoneSignInGeneration;
  phoneConfirmation = null;
  phoneRecaptchaVerifier?.clear();
  phoneRecaptchaVerifier = null;
}

export function signOutAdmin() {
  resetPhoneSignIn();
  return signOut(auth);
}
