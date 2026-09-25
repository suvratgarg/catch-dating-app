import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useRef, useState} from "react";
import {getProgramHouseholdRsvpView, submitProgramHouseholdRsvp} from "../../firebase";
import {householdRsvpCopy as copy} from "../../content/householdRsvp";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import type {SubmitProgramHouseholdRsvpCallablePayload as Submission} from "../../shared/contracts/generated/submitProgramHouseholdRsvpCallablePayload";
import {
  draftChanged,
  draftsFromView,
  withResponseDraft,
  type Credential,
  type HouseholdRsvpScreen,
  type ResponseDraft,
} from "./householdRsvpModel";

export function useHouseholdRsvpController(credential: Credential | null) {
  const client = useQueryClient();
  // A page instance owns its cache. The bearer token never enters query or
  // mutation keys.
  const [instanceId] = useState(() => crypto.randomUUID());
  const queryKey = websiteQueryKeys.householdRsvp.view(instanceId);
  const mounted = useRef(true);
  const locked = useRef(false);
  useEffect(() => {
    mounted.current = true;
    return () => { mounted.current = false; };
  }, []);

  const [drafts, setDrafts] = useState<Map<string, ResponseDraft> | null>(null);
  const [messagingConsent, setMessagingConsent] = useState<boolean | null>(null);
  const [submitted, setSubmitted] = useState(false);
  const [notice, setNotice] = useState("");

  const query = useQuery({
    queryKey, enabled: credential !== null,
    queryFn: async () => {
      if (!credential) throw new Error("Missing household RSVP credential");
      return getProgramHouseholdRsvpView(credential);
    },
    retry: false, gcTime: 0, staleTime: 0,
    refetchOnWindowFocus: "always", refetchOnReconnect: "always",
  });

  // Drafts are seeded once per loaded view and kept across background
  // refetches so an in-flight edit is never clobbered by fresher data.
  const view = query.data ?? null;
  const baseDrafts = view ? draftsFromView(view) : new Map<string, ResponseDraft>();
  const effectiveDrafts = drafts ?? baseDrafts;
  const effectiveConsent = messagingConsent ??
    view?.messagingConsentGranted === true;

  function setResponse(guestId: string, functionId: string,
    patch: Partial<ResponseDraft>) {
    if (locked.current) return;
    setDrafts(withResponseDraft(
      effectiveDrafts, guestId, functionId, patch));
    setSubmitted(false);
    setNotice("");
  }

  function setConsent(value: boolean) {
    if (locked.current) return;
    setMessagingConsent(value);
    setSubmitted(false);
    setNotice("");
  }

  const mutation = useMutation({
    mutationKey: websiteQueryKeys.householdRsvp.submit(instanceId),
    retry: false, gcTime: 0,
    mutationFn: async (input: Submission) => {
      await client.cancelQueries({queryKey});
      return submitProgramHouseholdRsvp(input);
    },
    onSuccess: async () => {
      if (!mounted.current) return;
      setSubmitted(true);
      setNotice(copy.saved);
      await client.invalidateQueries({queryKey});
    },
    onError: () => {
      if (mounted.current) setNotice(copy.uncertain);
    },
    onSettled: () => {
      locked.current = false;
    },
  });

  function submit() {
    if (!credential || locked.current || !view || effectiveDrafts.size === 0 ||
        query.isError) {
      return;
    }
    locked.current = true;
    setNotice("");
    mutation.mutate({
      token: credential.token,
      responses: [...effectiveDrafts.values()],
      messagingConsent: effectiveConsent,
    });
  }

  const dirty = view !== null && (
    effectiveConsent !== (view.messagingConsentGranted === true) ||
    [...effectiveDrafts.values()].some((draft) => {
      const fn = view.members
        .find((member) => member.guestId === draft.guestId)
        ?.functions.find((entry) => entry.functionId === draft.functionId);
      return fn ? draftChanged(draft, fn) : true;
    })
  );

  let screen: HouseholdRsvpScreen;
  if (!credential) {
    screen = {kind: "unavailable", reason: "invalid"};
  } else if (query.error && typeof query.error === "object" &&
      "code" in query.error &&
      (query.error.code === "functions/not-found" ||
        query.error.code === "functions/unauthenticated" ||
        query.error.code === "functions/permission-denied")) {
    screen = {kind: "unavailable", reason: "invalid"};
  } else if (!view && query.isPending) {
    screen = {kind: "loading"};
  } else if (!view) {
    screen = {kind: "unavailable", reason: "network"};
  } else {
    screen = {
      kind: "ready", view, drafts: effectiveDrafts,
      messagingConsent: effectiveConsent, dirty,
      pending: mutation.isPending, submitted, notice,
    };
  }

  return {
    screen,
    setResponse,
    setConsent,
    submit,
    refreshing: query.isFetching,
    refresh: () => {
      if (!locked.current) {
        setDrafts(null);
        setMessagingConsent(null);
        void query.refetch();
      }
    },
  };
}
