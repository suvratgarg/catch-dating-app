import {useMutation, useQueryClient} from "@tanstack/react-query";
import {type Dispatch, type SetStateAction, useEffect, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import type {RequestClubClaimPayload, User} from "../../firebase";
import type {FormStatus} from "../../shared/forms/types";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {readableError} from "./claimModel";

type ClaimAuthEventPrefix = "claim_flow" | "listing_claim";

interface ClaimAuthControllerOptions {
  eventPrefix: ClaimAuthEventPrefix;
  listingId: string | null;
  onAuthUser?: (user: User | null) => void;
  setStatus: Dispatch<SetStateAction<FormStatus>>;
}

export function useClaimAuthController({
  eventPrefix,
  listingId,
  onAuthUser,
  setStatus,
}: ClaimAuthControllerOptions) {
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);

  useEffect(() => {
    let cancelled = false;
    let unsubscribe: () => void = () => undefined;

    void import("../../firebase")
      .then(({watchClaimAuthState}) => {
        if (cancelled) return;
        unsubscribe = watchClaimAuthState((nextUser) => {
          setUser(nextUser);
          setAuthReady(true);
          onAuthUser?.(nextUser);
        });
      })
      .catch(() => {
        if (cancelled) return;
        setUser(null);
        setAuthReady(true);
        onAuthUser?.(null);
      });

    return () => {
      cancelled = true;
      unsubscribe();
    };
  }, [onAuthUser]);

  async function handleSignIn() {
    setIsSigningIn(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent(`${eventPrefix}_sign_in_started`, {
      listing_id: listingId,
    });
    try {
      const {signInForClaim} = await import("../../firebase");
      await signInForClaim();
      trackMarketingEvent(`${eventPrefix}_signed_in`, {
        listing_id: listingId,
      });
    } catch (error) {
      setStatus({message: readableError(error), tone: "is-error"});
      trackMarketingEvent(`${eventPrefix}_sign_in_error`, {
        listing_id: listingId,
      });
    } finally {
      setIsSigningIn(false);
    }
  }

  async function handleSignOut() {
    const {signOutClaimUser} = await import("../../firebase");
    await signOutClaimUser();
  }

  return {
    authReady,
    handleSignIn,
    handleSignOut,
    isSigningIn,
    user,
  };
}

export function useClaimRequestMutation(listingId: string | null) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (payload: RequestClubClaimPayload) => {
      const {requestClubClaim} = await import("../../firebase");
      return requestClubClaim(payload);
    },
    mutationKey: websiteQueryKeys.claims.request(listingId),
    onSuccess: async (_response, payload: RequestClubClaimPayload) => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: websiteQueryKeys.claims.lookup(payload.clubId),
        }),
        queryClient.invalidateQueries({
          queryKey: websiteQueryKeys.claims.requests(),
        }),
      ]);
    },
  });
}
