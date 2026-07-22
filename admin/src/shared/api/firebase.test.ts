import {beforeEach, describe, expect, it, vi} from "vitest";

const mocks = vi.hoisted(() => ({
  confirmation: {confirm: vi.fn()},
  getAuth: vi.fn(() => ({name: "admin-auth"})),
  googleProviderSetCustomParameters: vi.fn(),
  recaptchaClear: vi.fn(),
  recaptchaVerifier: vi.fn(),
  signInWithPhoneNumber: vi.fn(),
  signInWithPopup: vi.fn(),
  signOut: vi.fn(),
}));

vi.mock("firebase/auth", () => ({
  getAuth: mocks.getAuth,
  GoogleAuthProvider: function GoogleAuthProvider() {
    return {setCustomParameters: mocks.googleProviderSetCustomParameters};
  },
  RecaptchaVerifier: function RecaptchaVerifier(...args: unknown[]) {
    mocks.recaptchaVerifier(...args);
    return {clear: mocks.recaptchaClear};
  },
  signInWithPhoneNumber: mocks.signInWithPhoneNumber,
  signInWithPopup: mocks.signInWithPopup,
  signOut: mocks.signOut,
}));

vi.mock("./firebaseCore", () => ({
  firebaseApp: {name: "admin-app"},
  firebaseConfig: vi.fn(),
}));

import {
  auth,
  confirmPhoneSignInCode,
  requestPhoneSignInCode,
  resetPhoneSignIn,
  signInWithGoogle,
  signOutAdmin,
} from "./firebase";

describe("admin Firebase authentication", () => {
  beforeEach(() => {
    resetPhoneSignIn();
    mocks.confirmation.confirm.mockReset();
    mocks.googleProviderSetCustomParameters.mockReset();
    mocks.recaptchaClear.mockReset();
    mocks.recaptchaVerifier.mockReset();
    mocks.signInWithPhoneNumber.mockReset();
    mocks.signInWithPopup.mockReset();
    mocks.signOut.mockReset();
  });

  it("uses an invisible reCAPTCHA verifier for phone OTP sign-in", async () => {
    mocks.signInWithPhoneNumber.mockResolvedValue(mocks.confirmation);

    await requestPhoneSignInCode("+919000000000");

    expect(mocks.recaptchaVerifier).toHaveBeenCalledWith(
      auth,
      "admin-phone-recaptcha",
      {size: "invisible"}
    );
    expect(mocks.signInWithPhoneNumber).toHaveBeenCalledWith(
      auth,
      "+919000000000",
      expect.anything()
    );

    await confirmPhoneSignInCode("123456");

    expect(mocks.confirmation.confirm).toHaveBeenCalledWith("123456");
    expect(mocks.recaptchaClear).toHaveBeenCalledOnce();
  });

  it("keeps Google popup sign-in available", async () => {
    await signInWithGoogle();

    expect(mocks.googleProviderSetCustomParameters).toHaveBeenCalledWith({
      prompt: "select_account",
    });
    expect(mocks.signInWithPopup).toHaveBeenCalledWith(auth, expect.anything());
  });

  it("clears the verifier when requesting an SMS code fails", async () => {
    const error = new Error("SMS unavailable");
    mocks.signInWithPhoneNumber.mockRejectedValue(error);

    await expect(requestPhoneSignInCode("+919000000000")).rejects.toBe(error);

    expect(mocks.recaptchaClear).toHaveBeenCalledOnce();
    await expect(confirmPhoneSignInCode("123456")).rejects.toThrow(
      "Request a phone verification code before continuing."
    );
  });

  it("clears pending phone verification before signing out", async () => {
    mocks.signInWithPhoneNumber.mockResolvedValue(mocks.confirmation);
    await requestPhoneSignInCode("+919000000000");

    await signOutAdmin();

    expect(mocks.recaptchaClear).toHaveBeenCalledOnce();
    expect(mocks.signOut).toHaveBeenCalledWith(auth);
  });
});
