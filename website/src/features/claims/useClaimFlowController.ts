import {websiteCopy} from "@content/generated";
import {type FormEvent, useCallback, useMemo, useRef, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {claimFirebaseConfigured} from "../../firebaseConfig";
import {hostListings} from "../organizers/data";
import {organizerPolicyForListing} from "../organizers/organizerPolicy";
import {
  isClaimSubmissionEnabledListing,
  isPubliclyReadableListing,
} from "../organizers/selectors";
import type {HostListing} from "../organizers/types";
import type {FormStatus} from "../../shared/forms/types";
import {usePendingRequestRegistration} from "../../shared/pendingRequest";
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
  const preselectedListing = routeState.listing &&
    isPubliclyReadableListing(routeState.listing) ?
    routeState.listing :
    null;
  const claimUrlState = routeState.urlState;
  const urlRequestId = routeState.requestId;
  const submissionInFlight = useRef<Promise<unknown> | null>(null);
  const [step, setStepState] = useState<ClaimFlowStep>(
    claimUrlState ? "listing" : preselectedListing ? "role" : "listing"
  );
  const [listing, setListing] = useState<HostListing | null>(preselectedListing);
  const [query, setQueryState] = useState(preselectedListing?.name ?? "");
  const [requesterName, setRequesterNameState] = useState("");
  const [requesterRole, setRequesterRoleState] = useState<ClaimRole>("owner");
  const [businessEmail, setBusinessEmailState] = useState("");
  const [businessPhone, setBusinessPhoneState] = useState("");
  const [proofUrls, setProofUrlsState] = useState("");
  const [message, setMessageState] = useState("");
  const [verificationMethod, setVerificationMethod] =
    useState<ClaimVerificationMethodId>("publicProof");
  const [requestId, setRequestId] = useState<string | null>(null);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});

  const claimRequestMutation = useClaimRequestMutation(listing?.id ?? null);
  usePendingRequestRegistration(claimRequestMutation.isPending);
  const handleAuthUser = useCallback((nextUser: ReturnType<
    typeof useClaimAuthController
  >["user"]) => {
    if (submissionInFlight.current) return;
    setRequesterNameState((current) => current || nextUser?.displayName || "");
    setBusinessEmailState((current) => current || nextUser?.email || "");
  }, []);
  const {
    authReady,
    handleSignIn: handleAuthSignIn,
    handleSignOut: handleAuthSignOut,
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
    if (submissionInFlight.current) return;
    setListing(nextListing);
    setQueryState(nextListing.name);
  }

  function setQuery(nextQuery: string) {
    if (submissionInFlight.current) return;
    setQueryState(nextQuery);
  }

  function setRequesterName(nextRequesterName: string) {
    if (submissionInFlight.current) return;
    setRequesterNameState(nextRequesterName);
  }

  function setRequesterRole(nextRequesterRole: ClaimRole) {
    if (submissionInFlight.current) return;
    setRequesterRoleState(nextRequesterRole);
  }

  function setBusinessEmail(nextBusinessEmail: string) {
    if (submissionInFlight.current) return;
    setBusinessEmailState(nextBusinessEmail);
  }

  function setBusinessPhone(nextBusinessPhone: string) {
    if (submissionInFlight.current) return;
    setBusinessPhoneState(nextBusinessPhone);
  }

  function setProofUrls(nextProofUrls: string) {
    if (submissionInFlight.current) return;
    setProofUrlsState(nextProofUrls);
  }

  function setMessage(nextMessage: string) {
    if (submissionInFlight.current) return;
    setMessageState(nextMessage);
  }

  function setVerificationMethodSafely(nextMethod: ClaimVerificationMethodId) {
    if (submissionInFlight.current) return;
    setVerificationMethod(nextMethod);
  }

  function setStep(nextStep: ClaimFlowStep) {
    if (submissionInFlight.current) return;
    setStepState(nextStep);
  }

  async function handleSignIn() {
    if (submissionInFlight.current) return;
    await handleAuthSignIn();
  }

  async function handleSignOut() {
    if (submissionInFlight.current) return;
    await handleAuthSignOut();
  }

  async function handleClaimSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (submissionInFlight.current) return;
    if (!listing) {
      setStatus({message: websiteCopy["useclaimflowcontroller_0102"], tone: "is-error"});
      setStepState("listing");
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
      setStepState("role");
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

    const request = claimRequestMutation.mutateAsync({
      organizerId: listing.id,
      requesterName: requesterName.trim(),
      requesterRole,
      businessEmail: businessEmail.trim() || null,
      businessPhone: businessPhone.trim() || null,
      proofUrls: parsedProofUrls,
      message: reviewMessage || null,
    });
    submissionInFlight.current = request;
    try {
      const response = await request;
      setRequestId(response.requestId);
      setStatus({
        message: websiteCopy["useclaimflowcontroller_0103"],
        tone: "is-success",
      });
      setStepState("submitted");
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
    } finally {
      if (submissionInFlight.current === request) {
        submissionInFlight.current = null;
      }
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
    claimRuntimeAvailable: claimFirebaseConfigured,
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
    setVerificationMethod: setVerificationMethodSafely,
    status,
    step,
    user,
    verificationMethod,
  };
}

export type ClaimFlowController = ReturnType<typeof useClaimFlowController>;
