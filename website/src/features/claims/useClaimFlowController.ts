import {websiteCopy} from "@content/generated";
import {type FormEvent, useCallback, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {claimFirebaseConfigured} from "../../firebaseConfig";
import {hostListings} from "../organizers/data";
import {organizerPolicyForListing} from "../organizers/organizerPolicy";
import {isClaimSubmissionEnabledListing} from "../organizers/selectors";
import type {HostListing} from "../organizers/types";
import type {FormStatus} from "../../shared/forms/types";
import {emptyClaimRouteState, type ClaimRouteState} from "./claimRouting";
import {
  claimContactValidationMessage,
  claimFlowSteps,
  claimVerificationMethods,
  parseProofUrls,
  readableError,
  type ClaimFlowStep,
  type ClaimRole,
  type ClaimVerificationMethodId,
} from "./claimModel";
import {
  useClaimAuthController,
  useClaimRequestMutation,
} from "./useClaimRequestMutation";

export function useClaimFlowController(routeState: ClaimRouteState = emptyClaimRouteState) {
  const claimLookup = routeState.lookup;
  const preselectedListing = routeState.listing;
  const claimUrlState = routeState.urlState;
  const urlRequestId = routeState.requestId;
  const [step, setStep] = useState<ClaimFlowStep>(
    claimUrlState ? "listing" : preselectedListing ? "role" : "listing"
  );
  const [listing, setListing] = useState<HostListing | null>(preselectedListing);
  const [query, setQuery] = useState(preselectedListing?.name ?? "");
  const [requesterName, setRequesterName] = useState("");
  const [requesterRole, setRequesterRole] = useState<ClaimRole>("owner");
  const [businessEmail, setBusinessEmail] = useState("");
  const [businessPhone, setBusinessPhone] = useState("");
  const [proofUrls, setProofUrls] = useState("");
  const [message, setMessage] = useState("");
  const [verificationMethod, setVerificationMethod] =
    useState<ClaimVerificationMethodId>("publicProof");
  const [requestId, setRequestId] = useState<string | null>(null);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});

  const claimRequestMutation = useClaimRequestMutation(listing?.id ?? null);
  const handleAuthUser = useCallback((nextUser: ReturnType<
    typeof useClaimAuthController
  >["user"]) => {
    setRequesterName((current) => current || nextUser?.displayName || "");
    setBusinessEmail((current) => current || nextUser?.email || "");
  }, []);
  const {
    authReady,
    handleSignIn,
    handleSignOut,
    isSigningIn,
    user,
  } = useClaimAuthController({
    eventPrefix: "claim_flow",
    listingId: listing?.id ?? null,
    onAuthUser: handleAuthUser,
    setStatus,
  });

  const searchResults = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    const claimableListings = hostListings.filter(isClaimSubmissionEnabledListing);
    if (normalized.length <= 1) return claimableListings.slice(0, 5);
    return claimableListings
      .filter((item) =>
        [
          item.name,
          item.category,
          item.city,
          item.region,
          ...item.formats,
        ].join(" ").toLowerCase().includes(normalized)
      )
      .slice(0, 8);
  }, [query]);

  const currentStepIndex = claimFlowSteps.findIndex((item) => item.id === step);
  const selectedMethod =
    claimVerificationMethods.find((method) => method.id === verificationMethod) ??
    claimVerificationMethods[0];
  const activeRequestId = requestId ?? urlRequestId;
  const canContinueRole =
    Boolean(listing) &&
    requesterName.trim().length >= 2 &&
    (businessEmail.trim().length > 0 ||
      businessPhone.trim().length > 0 ||
      proofUrls.trim().length > 0);

  function selectListing(nextListing: HostListing) {
    setListing(nextListing);
    setQuery(nextListing.name);
  }

  async function handleClaimSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!listing) {
      setStatus({message: websiteCopy["useclaimflowcontroller_0102"], tone: "is-error"});
      setStep("listing");
      return;
    }
    const policy = organizerPolicyForListing(listing);
    if (!policy.canRequestClaim) {
      setStatus({
        message: policy.claimRequestReason,
        tone: "is-error",
      });
      return;
    }

    const parsedProofUrls = parseProofUrls(proofUrls);
    const validationMessage = claimContactValidationMessage({
      businessEmail: businessEmail.trim() || null,
      businessPhone: businessPhone.trim() || null,
      parsedProofUrls,
      requesterName,
      requesterRole,
    });
    if (validationMessage) {
      setStatus({message: validationMessage, tone: "is-error"});
      setStep("role");
      return;
    }
    if (!claimFirebaseConfigured) {
      setStatus({
        message:
          websiteCopy["useclaimflowcontroller_0104"],
        tone: "is-error",
      });
      return;
    }
    if (!user) {
      setStatus({message: websiteCopy["useclaimflowcontroller_0105"], tone: "is-error"});
      return;
    }

    const reviewMessage = [
      `Verification method: ${selectedMethod.title}`,
      message.trim(),
    ].filter(Boolean).join("\n\n");

    setStatus({message: "", tone: ""});
    trackMarketingEvent("claim_flow_submit_attempt", {
      club_id: listing.id,
      claim_role: requesterRole,
      proof_count: parsedProofUrls.length,
      verification_method: verificationMethod,
    });

    try {
      const response = await claimRequestMutation.mutateAsync({
        organizerId: listing.id,
        requesterName: requesterName.trim(),
        requesterRole,
        businessEmail: businessEmail.trim() || null,
        businessPhone: businessPhone.trim() || null,
        proofUrls: parsedProofUrls,
        message: reviewMessage || null,
      });
      setRequestId(response.requestId);
      setStatus({
        message: websiteCopy["useclaimflowcontroller_0103"],
        tone: "is-success",
      });
      setStep("submitted");
      trackMarketingEvent("claim_flow_submitted", {
        club_id: listing.id,
        claim_role: requesterRole,
        proof_count: parsedProofUrls.length,
        request_id: response.requestId,
      });
    } catch (error) {
      setStatus({message: readableError(error), tone: "is-error"});
      trackMarketingEvent("claim_flow_submit_error", {
        club_id: listing.id,
      });
    }
  }

  return {
    activeRequestId,
    authReady,
    businessEmail,
    businessPhone,
    canContinueRole,
    claimLookup,
    claimUrlState,
    currentStepIndex,
    handleClaimSubmit,
    handleSignIn,
    handleSignOut,
    isSigningIn,
    isSubmitting: claimRequestMutation.isPending,
    listing,
    message,
    proofUrls,
    query,
    requesterName,
    requesterRole,
    requestId,
    searchResults,
    selectedMethod,
    selectListing,
    setBusinessEmail,
    setBusinessPhone,
    setMessage,
    setProofUrls,
    setQuery,
    setRequesterName,
    setRequesterRole,
    setStep,
    setVerificationMethod,
    status,
    step,
    user,
    verificationMethod,
  };
}

export type ClaimFlowController = ReturnType<typeof useClaimFlowController>;
