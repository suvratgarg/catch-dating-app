import {getAuth, GoogleAuthProvider, signInWithPopup, signOut} from "firebase/auth";
import {firebaseApp} from "./firebaseCore";
export {firebaseConfig} from "./firebaseCore";

export const auth = getAuth(firebaseApp);

export async function signInWithGoogle() {
  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({prompt: "select_account"});
  await signInWithPopup(auth, provider);
}

export function signOutAdmin() {
  return signOut(auth);
}
