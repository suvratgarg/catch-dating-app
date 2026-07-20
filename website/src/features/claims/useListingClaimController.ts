import {websiteCopy} from "@content/generated";
import {type FormEvent, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {claimFirebaseConfigured} from "../../firebaseConfig";
import type {FormStatus} from "../../shared/forms/types";
import {organizerPolicyForListing} from "../organizers/organizerPolicy";
import type {HostListing} from "../organizers/types";
import {
  claimContactValidationMessage,
  nullableString,
  parseProofUrls,
  type ClaimRole,
} from "./claimModel";
import {
  useClaimAuthController,
  useClaimRequestMutation,
} from "./useClaimRequestMutation";

export function useListingClaimController(listing: HostListing) {
  const policy = organizerPolicyForListing(listing);
  const publicApiEnabled = policy.canRequestClaim;
  const [status, setStatus] = useState<FormStatus>({
    message: "",
    tone: "",
  });

  const claimRequestMutation = useClaimRequestMutation(listing.id);
  const {
    authReady,
    handleSignIn,
    handleSignOut,
    isSigningIn,
    user,
  } = useClaimAuthController({
    eventPrefix: "listing_claim",
    listingId: listing.id,
    setStatus,
  });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!publicApiEnabled) {
      setStatus({
        message: policy.claimRequestReason,
        tone: "is-error",
      });
      return;
    }
    if (!user) {
      setStatus({
        message: websiteCopy["uselistingclaimcontroller_0107"],
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

    const validationMessage = claimContactValidationMessage({
      businessEmail,
      businessPhone,
      parsedProofUrls: proofUrls,
      requesterName,
      requesterRole,
    });
    if (validationMessage) {
      setStatus({message: validationMessage, tone: "is-error"});
      return;
    }

    setStatus({message: "", tone: ""});
    trackMarketingEvent("listing_claim_submit_attempt", {
      club_id: listing.id,
      claim_role: requesterRole,
      proof_count: proofUrls.length,
    });

    try {
      await claimRequestMutation.mutateAsync({
        organizerId: listing.id,
        requesterName,
        requesterRole,
        businessEmail,
        businessPhone,
        proofUrls,
        message,
      });
      form.reset();
      setStatus({
        message: websiteCopy["uselistingclaimcontroller_0106"],
        tone: "is-success",
      });
      trackMarketingEvent("listing_claim_submitted", {
        club_id: listing.id,
        claim_role: requesterRole,
        proof_count: proofUrls.length,
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
        club_id: listing.id,
      });
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
      policy.claimRequestReason,
    publicApiEnabled,
    isSigningIn,
    isSubmitting: claimRequestMutation.isPending,
    status,
    user,
  };
}

export type ListingClaimController = ReturnType<typeof useListingClaimController>;
