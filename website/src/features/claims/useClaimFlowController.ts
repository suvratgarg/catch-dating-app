import {type FormEvent, useEffect, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {
  claimFirebaseConfigured,
  requestClubClaim,
  signInForClaim,
  signOutClaimUser,
  type User,
  watchClaimAuthState,
} from "../../firebase";
import {hostListings} from "../organizers/data";
import {
  claimStateForLocation,
  getClaimListingFromLocation,
  getClaimListingLookupFromLocation,
  getClaimRequestIdFromLocation,
} from "../organizers/routing";
import {isPublicApiEnabled, isUnclaimedListing} from "../organizers/selectors";
import type {HostListing} from "../organizers/types";
import type {FormStatus} from "../../shared/forms/types";
import {
  claimFlowSteps,
  claimVerificationMethods,
  parseProofUrls,
  readableError,
  type ClaimFlowStep,
  type ClaimRole,
  type ClaimVerificationMethodId,
} from "./claimModel";

export function useClaimFlowController() {
  const claimLookup = getClaimListingLookupFromLocation();
  const preselectedListing = getClaimListingFromLocation();
  const claimUrlState = claimStateForLocation(claimLookup, preselectedListing);
  const urlRequestId = getClaimRequestIdFromLocation();
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
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});

  useEffect(() => {
    return watchClaimAuthState((nextUser) => {
      setUser(nextUser);
      setAuthReady(true);
      setRequesterName((current) => current || nextUser?.displayName || "");
      setBusinessEmail((current) => current || nextUser?.email || "");
    });
  }, []);

  const searchResults = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    const claimableListings = hostListings.filter(isUnclaimedListing);
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

  async function handleSignIn() {
    setIsSigningIn(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("claim_flow_sign_in_started", {
      listing_id: listing?.id ?? null,
    });
    try {
      await signInForClaim();
      trackMarketingEvent("claim_flow_signed_in", {
        listing_id: listing?.id ?? null,
      });
    } catch (error) {
      setStatus({message: readableError(error), tone: "is-error"});
      trackMarketingEvent("claim_flow_sign_in_error", {
        listing_id: listing?.id ?? null,
      });
    } finally {
      setIsSigningIn(false);
    }
  }

  async function handleSignOut() {
    await signOutClaimUser();
  }

  async function handleClaimSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!listing) {
      setStatus({message: "Choose a listing before submitting.", tone: "is-error"});
      setStep("listing");
      return;
    }
    if (!isPublicApiEnabled(listing)) {
      setStatus({
        message: listing.publicApi.reason,
        tone: "is-error",
      });
      return;
    }

    const parsedProofUrls = parseProofUrls(proofUrls);
    if (!requesterName.trim() || !requesterRole) {
      setStatus({message: "Add your name and role before submitting.", tone: "is-error"});
      setStep("role");
      return;
    }
    if (!businessEmail.trim() && !businessPhone.trim() && parsedProofUrls.length === 0) {
      setStatus({
        message: "Add a business email, phone, or proof link.",
        tone: "is-error",
      });
      setStep("role");
      return;
    }
    if (!claimFirebaseConfigured) {
      setStatus({
        message:
          "Claim submission needs the website Firebase/App Check config. The operating packet is ready, but this local build cannot submit it.",
        tone: "is-error",
      });
      return;
    }
    if (!user) {
      setStatus({message: "Sign in before submitting this claim.", tone: "is-error"});
      return;
    }

    const reviewMessage = [
      `Verification method: ${selectedMethod.title}`,
      message.trim(),
    ].filter(Boolean).join("\n\n");

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("claim_flow_submit_attempt", {
      listing_id: listing.id,
      proof_count: parsedProofUrls.length,
      requester_role: requesterRole,
      verification_method: verificationMethod,
    });

    try {
      const response = await requestClubClaim({
        clubId: listing.id,
        requesterName: requesterName.trim(),
        requesterRole,
        businessEmail: businessEmail.trim() || null,
        businessPhone: businessPhone.trim() || null,
        proofUrls: parsedProofUrls,
        message: reviewMessage || null,
      });
      setRequestId(response.requestId);
      setStatus({
        message: "Claim request received. Catch will review ownership before tools unlock.",
        tone: "is-success",
      });
      setStep("submitted");
      trackMarketingEvent("claim_flow_submitted", {
        listing_id: listing.id,
        proof_count: parsedProofUrls.length,
        requester_role: requesterRole,
        request_id: response.requestId,
      });
    } catch (error) {
      setStatus({message: readableError(error), tone: "is-error"});
      trackMarketingEvent("claim_flow_submit_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSubmitting(false);
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
    isSubmitting,
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
