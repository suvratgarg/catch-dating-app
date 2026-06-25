import {type FormEvent, useEffect, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {
  claimFirebaseConfigured,
  requestClubClaim,
  signInForClaim,
  signOutClaimUser,
  type User,
  watchClaimAuthState,
} from "../../firebase";
import type {FormStatus} from "../../shared/forms/types";
import {isPublicApiEnabled} from "../organizers/selectors";
import type {HostListing} from "../organizers/types";
import {
  nullableString,
  parseProofUrls,
  type ClaimRole,
} from "./claimModel";

export function useListingClaimController(listing: HostListing) {
  const publicApiEnabled = isPublicApiEnabled(listing);
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<FormStatus>({
    message: "",
    tone: "",
  });

  useEffect(() => {
    return watchClaimAuthState((nextUser) => {
      setUser(nextUser);
      setAuthReady(true);
    });
  }, []);

  async function handleSignIn() {
    setIsSigningIn(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("listing_claim_sign_in_started", {
      listing_id: listing.id,
    });
    try {
      await signInForClaim();
      trackMarketingEvent("listing_claim_signed_in", {
        listing_id: listing.id,
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "Sign-in did not complete. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("listing_claim_sign_in_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSigningIn(false);
    }
  }

  async function handleSignOut() {
    await signOutClaimUser();
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!publicApiEnabled) {
      setStatus({
        message: listing.publicApi.reason,
        tone: "is-error",
      });
      return;
    }
    if (!user) {
      setStatus({
        message: "Sign in before requesting this claim.",
        tone: "is-error",
      });
      return;
    }

    const form = event.currentTarget;
    const formData = new FormData(form);
    const requesterName = String(formData.get("requesterName") || "").trim();
    const requesterRole = String(formData.get("requesterRole") || "") as
      ClaimRole;
    const businessEmail = nullableString(formData.get("businessEmail"));
    const businessPhone = nullableString(formData.get("businessPhone"));
    const proofUrls = parseProofUrls(formData.get("proofUrls"));
    const message = nullableString(formData.get("message"));

    if (!requesterName || !requesterRole) {
      setStatus({
        message: "Add your name and role before requesting the claim.",
        tone: "is-error",
      });
      return;
    }

    if (!businessEmail && !businessPhone && proofUrls.length === 0) {
      setStatus({
        message: "Add a business contact or at least one public proof link.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("listing_claim_submit_attempt", {
      listing_id: listing.id,
      proof_count: proofUrls.length,
      requester_role: requesterRole,
    });

    try {
      await requestClubClaim({
        clubId: listing.id,
        requesterName,
        requesterRole,
        businessEmail,
        businessPhone,
        proofUrls,
        message,
      });
      form.reset();
      setStatus({
        message: "Claim request received. Catch will review it before ownership changes.",
        tone: "is-success",
      });
      trackMarketingEvent("listing_claim_submitted", {
        listing_id: listing.id,
        proof_count: proofUrls.length,
        requester_role: requesterRole,
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "We could not submit this claim request. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("listing_claim_submit_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return {
    authReady,
    handleSignIn,
    handleSignOut,
    handleSubmit,
    isConfigured: claimFirebaseConfigured && publicApiEnabled,
    notConfiguredReason: publicApiEnabled ?
      "Claim submission needs the website Firebase/App Check config." :
      listing.publicApi.reason,
    publicApiEnabled,
    isSigningIn,
    isSubmitting,
    status,
    user,
  };
}
