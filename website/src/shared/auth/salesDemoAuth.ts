import {beginSalesDemoPhoneVerification, signInForClaim,
  signOutClaimUser, watchSalesDemoAuthState} from "../../firebase";

export interface SalesDemoViewer {
  uid: string;
  email: string | null;
  emailVerified: boolean;
  phoneNumber: string | null;
}

export interface SalesDemoPhoneChallenge {
  confirm(code: string): Promise<void>;
  clear(): void;
}

export interface SalesDemoAuth {
  watch(callback: (viewer: SalesDemoViewer | null) => void): () => void;
  signInGoogle(): Promise<void>;
  signOut?(): Promise<void>;
  beginPhone(phone: string, recaptchaContainerId: string):
    Promise<SalesDemoPhoneChallenge>;
}

export const websiteSalesDemoAuth: SalesDemoAuth = {
  watch: (callback) => watchSalesDemoAuthState((user) => callback(user ? {
    uid: user.uid,
    email: user.email,
    emailVerified: user.emailVerified,
    phoneNumber: user.phoneNumber,
  } : null)),
  signInGoogle: signInForClaim,
  signOut: signOutClaimUser,
  beginPhone: async (phone, recaptchaContainerId) => {
    const challenge = await beginSalesDemoPhoneVerification(
      phone, recaptchaContainerId);
    return {confirm: async (code) => {await challenge.confirm(code);},
      clear: challenge.clear};
  },
};
