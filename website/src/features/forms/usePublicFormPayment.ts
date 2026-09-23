import {useCallback, useEffect, useRef, useState} from "react";
import {useMutation} from "@tanstack/react-query";
import {findOrganizerFormPayment, getOrganizerFormPayment, prepareOrganizerFormPayment,
  type PublicOrganizerFormPayment, type PublicOrganizerFormPaymentRequest,
  type PublicOrganizerFormReceipt} from "../../firebase";
import type {FormStatus} from "../../shared/forms/types";
import {openFormCheckout} from "./razorpayFormCheckout";
import {readFormStorage, writeFormStorage, removeFormStorage} from "./publicFormStorage";

interface PendingPayment {
  uid: string;
  request: PublicOrganizerFormPaymentRequest | null;
  paymentId: string | null;
}

export function usePublicFormPayment(publicFormId: string,
  onStart: () => void, onReceipt: (receipt: PublicOrganizerFormReceipt) => void) {
  const [payment, setPayment] = useState<PublicOrganizerFormPayment | null>(null);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});
  const pendingRef = useRef<PendingPayment | null>(null);
  const operationRef = useRef<{uid: string; epoch: number; result: Promise<boolean>} | null>(null);
  const epochRef = useRef(0);
  const checkoutRef = useRef<AbortController | null>(null);
  const mountedRef = useRef(true);
  const storageKey = `catch:form:${publicFormId}:payment`;
  useEffect(() => {
    mountedRef.current = true;
    return () => {mountedRef.current = false; epochRef.current++; checkoutRef.current?.abort();};
  }, []);
  const readPending = useCallback((): PendingPayment | null => {
    try {
      const value = JSON.parse(readFormStorage("local", storageKey) ?? "null");
      if (!value || typeof value.uid !== "string" ||
          !(value.paymentId === null || /^fp_[a-f0-9]{32}$/u.test(value.paymentId))) return null;
      const request = value.request;
      if (request !== null && (!request || typeof request.draftId !== "string" ||
          request.draftToken !== null || !Number.isSafeInteger(request.expectedRevision) ||
          typeof request.requestId !== "string")) return null;
      if (!request && !value.paymentId) return null;
      return value as PendingPayment;
    } catch {return null;}
  }, [storageKey]);
  const persist = useCallback((value: PendingPayment) => {
    pendingRef.current = value;
    // Browser storage is an optimization. Account-owned server discovery is
    // the recovery path when storage is disabled, full or cleared.
    writeFormStorage("local", storageKey, JSON.stringify(value));
  }, [storageKey]);
  const apply = useCallback((value: PublicOrganizerFormPayment,
    owner: PendingPayment, epoch: number) => {
    const pending = pendingRef.current;
    if (!mountedRef.current || epoch !== epochRef.current || pending?.uid !== owner.uid ||
        (owner.paymentId ? pending.paymentId !== owner.paymentId :
          pending.request?.draftId !== owner.request?.draftId)) return false;
    persist({...pending, paymentId: value.paymentId});
    setPayment(value);
    setStatus({message: "", tone: ""});
    if (value.receipt) onReceipt(value.receipt);
    return true;
  }, [onReceipt, persist]);
  const report = useCallback((error: unknown, epoch: number) => {
    if (mountedRef.current && epoch === epochRef.current) {
      setStatus({tone: "is-error", message: error instanceof Error ? error.message :
        "Payment is being checked. Try again."});
    }
  }, []);
  const check = useCallback(async () => {
    const pending = pendingRef.current;
    const epoch = epochRef.current;
    if (!pending) return;
    const value = pending.paymentId ? await getOrganizerFormPayment({
      paymentId: pending.paymentId, callback: null,
    }) : pending.request ? await prepareOrganizerFormPayment(pending.request) : null;
    if (value) apply(value, pending, epoch);
    return value;
  }, [apply]);
  const mutation = useMutation<void, unknown, () => Promise<void>>({
    mutationFn: (action) => action(),
  });
  const resume = useCallback(async (uid: string | null) => {
    if (!uid) return false;
    const epoch = epochRef.current;
    const running = operationRef.current;
    if (running?.uid === uid && running.epoch === epoch) return running.result;
    const operation = (async () => {
      const local = pendingRef.current ?? readPending();
      if (local?.uid === uid) {
        pendingRef.current = local;
        onStart();
        try {
          const latest = await check();
          if (latest && !latest.receipt && ["expired", "refunded"].includes(latest.status) &&
              mountedRef.current && epoch === epochRef.current &&
              pendingRef.current?.uid === uid &&
              pendingRef.current.paymentId === latest.paymentId) {
            const found = await findOrganizerFormPayment({publicFormId});
            if (found.payment && mountedRef.current && epoch === epochRef.current) {
              const owner = {uid, request: null, paymentId: found.payment.paymentId};
              persist(owner);
              apply(found.payment, owner, epoch);
            }
          }
        } catch (error) {report(error, epoch);}
        return true;
      }
      // No provider side effect: discovery returns this account's recoverable
      // payment. A failed lookup must not silently start a new draft.
      const found = await findOrganizerFormPayment({publicFormId});
      if (!mountedRef.current || epoch !== epochRef.current) return true;
      if (!found.payment) return false;
      const owner = {uid, request: null, paymentId: found.payment.paymentId};
      persist(owner);
      onStart();
      apply(found.payment, owner, epoch);
      return true;
    })();
    const handle = {uid, epoch, result: operation};
    operationRef.current = handle;
    try {return await operation;} finally {
      if (operationRef.current === handle) operationRef.current = null;
    }
  }, [apply, check, onStart, persist, publicFormId, readPending, report]);
  const prepare = useCallback(async (request: PublicOrganizerFormPaymentRequest,
    uid: string) => {
    const existing = pendingRef.current ?? readPending();
    persist(existing?.uid === uid && existing.request?.draftId === request.draftId ?
      existing : {uid, request, paymentId: null});
    onStart();
    await check();
  }, [check, onStart, persist, readPending]);
  const run = (action: () => Promise<void>) => {
    const epoch = epochRef.current;
    return mutation.mutateAsync(async () => {
      if (!mountedRef.current || epoch !== epochRef.current) return;
      await action();
    }).catch((error: unknown) => report(error, epoch));
  };
  const refresh = () => run(async () => {await check();});
  const resetMutation = mutation.reset;
  const resetSession = useCallback(() => {
    epochRef.current++;
    checkoutRef.current?.abort();
    operationRef.current = null;
    pendingRef.current = null;
    resetMutation();
    setPayment(null);
    setStatus({message: "", tone: ""});
  }, [resetMutation]);
  useEffect(() => {resetSession();}, [publicFormId, resetSession]);
  const restart = async () => {
    const current = pendingRef.current;
    const epoch = epochRef.current;
    if (!current?.paymentId) return false;
    const latest = await getOrganizerFormPayment({paymentId: current.paymentId,
      callback: null});
    if (!apply(latest, current, epoch) || latest.receipt ||
        !["expired", "refunded"].includes(latest.status)) return false;
    removeFormStorage("local", storageKey);
    resetSession();
    return true;
  };
  const pay = (organizerName: string) => run(async () => {
    const current = pendingRef.current;
    const epoch = epochRef.current;
    if (!current?.paymentId) {await check(); return;}
    // Refresh before opening: another tab may have paid or the order expired.
    const latest = await getOrganizerFormPayment({paymentId: current.paymentId,
      callback: null});
    if (!apply(latest, current, epoch) || !latest.checkout || latest.receipt) return;
    checkoutRef.current?.abort();
    const abort = new AbortController();
    checkoutRef.current = abort;
    const callback = await openFormCheckout(latest.checkout, organizerName, abort.signal);
    if (abort.signal.aborted || !mountedRef.current || epoch !== epochRef.current) return;
    apply(await getOrganizerFormPayment({paymentId: latest.paymentId, callback}), current, epoch);
  });
  useEffect(() => {
    if (!payment || payment.receipt || mutation.isPending ||
        !["creatingOrder", "orderUnknown", "checkoutReady", "failed", "verifying", "captured",
          "refundPending"].includes(payment.status)) return;
    const timer = window.setTimeout(() => {void refresh();}, 10_000);
    return () => window.clearTimeout(timer);
  }, [payment, mutation.isPending]);
  return {payment, status, pending: mutation.isPending, prepare, resume,
    hasPending: readPending, pay, refresh, resetSession, restart};
}
