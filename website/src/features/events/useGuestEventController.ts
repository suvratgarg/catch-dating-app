import {useEffect, useId, useRef, useState, type FormEvent} from "react";
import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {beginPublicEventPhoneVerification, getGuestEventViewerState,
  watchPublicFormAuthState, signOutGuestUser, type User, type PublicEventPhoneVerification} from "../../firebase";
import {guestEventCopy as copy} from "../../content/events";

/** Identity changes clear private projections; status refresh never charges or admits. */
export function useGuestEventController(eventId: string) {
  const [user, setUser] = useState<User | null | undefined>();
  const [phone, setPhone] = useState("");
  const [code, setCode] = useState("");
  const [codeSent, setCodeSent] = useState(false);
  const [message, setMessage] = useState("");
  const challenge = useRef<PublicEventPhoneVerification | null>(null);
  const scope = useRef({epoch: 0, mounted: false, uid: ""});
  const cache = useQueryClient();
  const recaptchaId = `guest-${useId().replace(/[^a-zA-Z0-9_-]/gu, "")}`;
  const mutation = useMutation({retry: false, gcTime: 0,
    mutationFn: (action: () => Promise<void>) => action()});
  const reset = mutation.reset;
  useEffect(() => {
    scope.current.mounted = true;
    const stop = watchPublicFormAuthState((next) => {
      const uid = next?.phoneNumber ? next.uid : "";
      if (scope.current.uid !== uid) {
        cache.removeQueries({queryKey: ["guest-event", eventId, scope.current.uid]});
        scope.current.epoch++;
        scope.current.uid = uid;
        challenge.current?.clear(); challenge.current = null;
        setCode(""); setCodeSent(false); setMessage(""); reset();
      }
      setUser(next);
    });
    return () => {
      scope.current.mounted = false;
      scope.current.epoch++;
      challenge.current?.clear(); stop();
      cache.removeQueries({queryKey: ["guest-event", eventId]});
    };
  }, [cache, eventId, reset]);
  const query = useQuery({
    queryKey: ["guest-event", eventId, user?.phoneNumber ? user.uid : ""],
    enabled: Boolean(user?.phoneNumber), retry: false, gcTime: 0,
    refetchInterval: 15_000, refetchOnWindowFocus: "always",
    queryFn: async () => {
      const result = await getGuestEventViewerState(eventId);
      if (result.viewer.eventId !== eventId || !result.viewer.guest ||
          result.viewer.guest.expiresAtMillis <= Date.now()) throw new Error(copy.unavailable);
      return result.viewer;
    },
  });
  async function submit(event: FormEvent) {
    event.preventDefault();
    if (mutation.isPending) return;
    const epoch = scope.current.epoch;
    const current = () => scope.current.mounted && scope.current.epoch === epoch;
    setMessage("");
    try {
      await mutation.mutateAsync(async () => {
        if (!codeSent) {
          const normalized = phone.replace(/[\s()-]/gu, "");
          if (!/^\+[1-9][0-9]{7,14}$/u.test(normalized)) throw new Error(copy.invalidPhone);
          challenge.current?.clear();
          const next = await beginPublicEventPhoneVerification(normalized, recaptchaId);
          if (!current()) { next.clear(); return; }
          challenge.current = next;
          setCodeSent(true);
        } else {
          if (!challenge.current || !/^\d{6}$/u.test(code)) throw new Error(copy.invalidCode);
          await challenge.current.confirm(code);
          // The shared auth observer owns the transition and next account read.
        }
      });
    } catch {
      if (current()) setMessage(codeSent ? copy.invalidCode : copy.verificationFailed);
    }
  }
  return {user, phone, setPhone, code, setCode, codeSent, submit, message,
    pending: mutation.isPending, recaptchaId,
    viewer: query.isError || !query.data?.guest || query.data.guest.expiresAtMillis <= Date.now() ? null : query.data,
    loading: user === undefined || Boolean(user?.phoneNumber) && query.isPending,
    changeAccount: () => signOutGuestUser().catch(() => setMessage(copy.verificationFailed)),
    error: query.isError, refresh: () => query.refetch()};
}
