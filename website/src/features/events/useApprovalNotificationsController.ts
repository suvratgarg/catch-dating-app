import {useEffect, useId, useRef, useState, type FormEvent} from "react";
import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {manageEventApprovalNotifications, refreshGuestIdentity, verifyGuestEmail, type User} from "../../firebase";
import {approvalNotificationCopy as copy} from "../../content/events";

export function useApprovalNotificationsController(eventId: string, user: User) {
  const key = ["event-approval-notifications", eventId, user.uid] as const;
  const cache = useQueryClient();
  const scope = useRef({mounted: false, epoch: 0});
  const [draft, setDraft] = useState<{revision: number; phoneUpdates: boolean; emailUpdates: boolean} | null>(null);
  const [email, setEmail] = useState(user.email ?? "");
  const [message, setMessage] = useState("");
  const id = useId();
  const query = useQuery({queryKey: key, gcTime: 0, retry: false,
    queryFn: () => manageEventApprovalNotifications({eventId, expectedUid: user.uid, action: "get"})});
  const mutation = useMutation({gcTime: 0, retry: false,
    mutationFn: (action: () => Promise<void>) => action()});
  useEffect(() => {
    scope.current.mounted = true;
    return () => {scope.current.mounted = false; scope.current.epoch++;
      cache.removeQueries({queryKey: ["event-approval-notifications", eventId, user.uid]});};
  }, [cache, eventId, user.uid]);
  const value = query.data;
  const choices = draft && draft.revision === value?.revision ? draft : value?.choices;
  function choose(name: "phoneUpdates" | "emailUpdates", checked: boolean) {
    if (value && choices) setDraft({revision: value.revision, ...choices, [name]: checked});
  }
  async function run(action: (current: () => boolean) => Promise<void>) {
    if (mutation.isPending) return;
    const epoch = scope.current.epoch;
    const current = () => scope.current.mounted && scope.current.epoch === epoch;
    setMessage("");
    try {await mutation.mutateAsync(() => action(current));}
    catch {if (current()) setMessage(copy.error);}
  }
  function save(event: FormEvent) {
    event.preventDefault();
    if (!value || !choices) return;
    void run(async (current) => {
      const updated = await manageEventApprovalNotifications({eventId, expectedUid: user.uid, action: "save",
        expectedRevision: value.revision, termsVersion: value.terms.version,
        choices: {phoneUpdates: choices.phoneUpdates, emailUpdates: choices.emailUpdates}});
      if (current()) {cache.setQueryData(key, updated); setDraft(null); setMessage(copy.saved);}
    });
  }
  return {id, value, choices, choose, save, email, setEmail, message,
    loading: query.isPending, error: query.isError, pending: mutation.isPending,
    verify: () => run(async (current) => {
      await verifyGuestEmail(user.uid, email, eventId);
      if (current()) setMessage(copy.verificationSent);
    }),
    refresh: () => run(async (current) => {
      await refreshGuestIdentity(user.uid);
      if (current()) {setDraft(null); await query.refetch();}
    })};
}
