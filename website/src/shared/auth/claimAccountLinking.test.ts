import {describe, expect, it, vi} from "vitest";
import type {ApplicationVerifier, Auth, User} from "firebase/auth";
import {beginClaimPhoneLink, signInOrLinkClaimGoogle} from "../../firebase";
import {claimAccountLinkingErrorMessage} from "./claimAccountLinking";
function fixture(providers: string[] = [], phoneNumber: string | null = null) {
  const user = {uid: "same-owner", phoneNumber, getIdToken: vi.fn().mockResolvedValue("fresh-token"),
    providerData: providers.map((providerId) => ({providerId}))} as unknown as User;
  const state = {currentUser: user as User | null, authStateReady: vi.fn().mockResolvedValue(undefined)};
  const auth = state as unknown as Auth;
  const result = {user};
  const confirm = vi.fn().mockResolvedValue(result);
  const api = {GoogleAuthProvider: class {setCustomParameters() {}},
    PhoneAuthProvider: class {constructor(_auth: Auth) {} static credential(id: string, code: string) {return {id, code};}
      verifyPhoneNumber = vi.fn().mockResolvedValue("verification-id");},
    signInWithPopup: vi.fn().mockImplementation(async () => {state.currentUser = user; return result;}),
    linkWithPopup: vi.fn().mockResolvedValue(result),
    reauthenticateWithPopup: vi.fn().mockResolvedValue(result),
    signInWithPhoneNumber: vi.fn().mockResolvedValue({confirm}),
    linkWithPhoneNumber: vi.fn().mockResolvedValue({confirm}),
    reauthenticateWithCredential: vi.fn().mockResolvedValue(result)};
  return {user, auth, state, api, sdk: api as unknown as typeof import("firebase/auth"), confirm};
}
const verifier = {type: "recaptcha", verify: async () => "verified"} as ApplicationVerifier;
describe("claim account credential continuity", () => {
  it("shows owned fallback for SDK failures and retains explicit recovery guidance", () => {
    expect(claimAccountLinkingErrorMessage(new Error("auth/code-expired"), "Try again.")).toBe("Try again.");
    expect(claimAccountLinkingErrorMessage(Object.assign(new Error("SDK detail"), {code: "auth/network-request-failed"}), "Try again.")).toBe("Try again.");
    expect(claimAccountLinkingErrorMessage(new Error("Your account changed. Restart verification."), "Try again.")).toBe("Your account changed. Restart verification.");
  });
  it("links Google to an existing phone UID without switching sign-in", async () => {
    const f = fixture(["phone"], "+15555550100");
    await signInOrLinkClaimGoogle(f.auth, f.sdk);
    expect(f.api.linkWithPopup).toHaveBeenCalledWith(f.user, expect.anything());
    expect(f.api.signInWithPopup).not.toHaveBeenCalled();
    expect(f.auth.currentUser?.uid).toBe("same-owner");
  });
  it("reauthenticates an already linked Google account and signs in only when signed out", async () => {
    const f = fixture(["google.com"]); await signInOrLinkClaimGoogle(f.auth, f.sdk);
    expect(f.api.reauthenticateWithPopup).toHaveBeenCalled();
    expect(f.api.linkWithPopup).not.toHaveBeenCalled();
    f.state.currentUser = null; await signInOrLinkClaimGoogle(f.auth, f.sdk);
    expect(f.api.signInWithPopup).toHaveBeenCalled();
  });
  it("links phone to the current Google UID and rejects a changed identity before OTP confirmation", async () => {
    const f = fixture(["google.com"]);
    const challenge = await beginClaimPhoneLink(f.auth, "+15555550100", verifier, f.sdk);
    expect(f.api.linkWithPhoneNumber).toHaveBeenCalledWith(f.user, "+15555550100", verifier);
    expect(f.api.signInWithPhoneNumber).not.toHaveBeenCalled();
    await challenge.confirm("123456"); expect(f.confirm).toHaveBeenCalledOnce();
    f.state.currentUser = {uid: "another-user"} as User;
    await expect(challenge.confirm("123456")).rejects.toThrow("account changed");
    expect(f.confirm).toHaveBeenCalledOnce();
  });
  it("reauthenticates the existing phone and rejects an implicit phone replacement", async () => {
    const f = fixture(["phone"], "+15555550100");
    const challenge = await beginClaimPhoneLink(f.auth, "+15555550100", verifier, f.sdk);
    await challenge.confirm("123456"); expect(f.api.reauthenticateWithCredential).toHaveBeenCalled();
    await expect(beginClaimPhoneLink(f.auth, "+15555550200", verifier, f.sdk)).rejects.toThrow("phone already linked");
    expect(f.api.linkWithPhoneNumber).not.toHaveBeenCalled();
  });
  it("rejects a signed-out OTP after another account signs in", async () => {
    const f = fixture(); f.state.currentUser = null;
    const challenge = await beginClaimPhoneLink(f.auth, "+15555550100", verifier, f.sdk);
    f.state.currentUser = {uid: "another-user"} as User;
    await expect(challenge.confirm("123456")).rejects.toThrow("account changed");
    expect(f.confirm).not.toHaveBeenCalled();
    expect(f.auth.currentUser?.uid).toBe("another-user");
  });
  it("checks the signed-out phone result and maps credential collisions", async () => {
    const f = fixture(); f.state.currentUser = null;
    const challenge = await beginClaimPhoneLink(f.auth, "+15555550100", verifier, f.sdk);
    f.confirm.mockImplementationOnce(async () => {f.state.currentUser = f.user; return {user: f.user};});
    await challenge.confirm("123456");
    expect(f.user.getIdToken).toHaveBeenCalledWith(true);
    f.state.currentUser = null;
    f.confirm.mockRejectedValueOnce({code: "auth/credential-already-in-use"});
    await expect(challenge.confirm("123456")).rejects.toThrow("Accounts were not combined");
  });
  it("credential collisions offer recovery and do not fall back to switching accounts", async () => {
    const f = fixture(["phone"]);
    f.api.linkWithPopup.mockRejectedValue({code: "auth/credential-already-in-use"});
    await expect(signInOrLinkClaimGoogle(f.auth, f.sdk)).rejects.toThrow("Accounts were not combined");
    expect(f.api.signInWithPopup).not.toHaveBeenCalled();
    expect(f.auth.currentUser?.uid).toBe("same-owner");
  });
});
