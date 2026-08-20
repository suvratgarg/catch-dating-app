/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates or continues an India host's Razorpay Route linked-account setup. Legal, stakeholder, and settlement details are sent to Razorpay and are never persisted in Catch Firestore.
 */
export interface CreateRazorpayHostPaymentAccountCallablePayload {
  legalBusinessName: string;
  businessType:
    | "individual"
    | "proprietorship"
    | "partnership"
    | "private_limited"
    | "public_limited"
    | "llp"
    | "trust"
    | "society"
    | "ngo";
  contactName: string;
  email: string;
  phone: string;
  businessModel: string;
  businessPan: string;
  bankAccountNumber: string;
  ifscCode: string;
  beneficiaryName: string;
  stakeholderName: string;
  stakeholderEmail: string;
  stakeholderPhone: string;
  stakeholderPan: string;
  stakeholderOwnershipPercent: number;
  stakeholderIsDirector: boolean;
  stakeholderIsExecutive: boolean;
  termsAccepted: true;
}
