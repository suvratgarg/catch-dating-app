import {
  type ConfirmationResult,
  getAuth,
  RecaptchaVerifier,
  signInWithPhoneNumber,
  signOut,
} from "firebase/auth";
import {firebaseApp} from "./firebaseCore";
export {firebaseConfig} from "./firebaseCore";

export const auth = getAuth(firebaseApp);

let phoneConfirmation: ConfirmationResult | null = null;
let phoneRecaptchaVerifier: RecaptchaVerifier | null = null;

export async function requestPhoneSignInCode(phoneNumber: string) {
  resetPhoneSignIn();
  phoneRecaptchaVerifier = new RecaptchaVerifier(
    auth,
    "admin-phone-recaptcha",
    {size: "invisible"}
  );
  try {
    phoneConfirmation = await signInWithPhoneNumber(
      auth,
      phoneNumber,
      phoneRecaptchaVerifier
    );
  } catch (error) {
    resetPhoneSignIn();
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
  phoneConfirmation = null;
  phoneRecaptchaVerifier?.clear();
  phoneRecaptchaVerifier = null;
}

export function signOutAdmin() {
  resetPhoneSignIn();
  return signOut(auth);
}
