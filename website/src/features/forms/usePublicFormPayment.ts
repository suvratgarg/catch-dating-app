import {useCallback, useEffect, useRef, useState} from "react";
import {useMutation} from "@tanstack/react-query";
import {getOrganizerFormPayment, prepareOrganizerFormPayment,
  type PublicOrganizerFormPayment, type PublicOrganizerFormPaymentRequest,
  type PublicOrganizerFormReceipt} from "../../firebase";
import type {FormStatus} from "../../shared/forms/types";
import {openFormCheckout} from "./razorpayFormCheckout";

interface PendingPayment {
  uid: string;
  request: PublicOrganizerFormPaymentRequest;
  paymentId: string | null;
}

export function usePublicFormPayment(publicFormId: string,
  onStart: () => void, onReceipt: (receipt: PublicOrganizerFormReceipt) => void) {
  const [payment, setPayment] = useState<PublicOrganizerFormPayment | null>(null);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});
  const pendingRef = useRef<PendingPayment | null>(null);
  const operationRef = useRef<Promise<void> | null>(null);
  const checkoutRef = useRef<AbortController | null>(null);
  const mountedRef = useRef(true);
  const storageKey = `catch:form:${publicFormId}:payment`;
  useEffect(() => {
    mountedRef.current = true;
    return () => {mountedRef.current = false; checkoutRef.current?.abort();};
  }, []);
  const readPending = useCallback((): PendingPayment | null => {
    try {
      const value = JSON.parse(window.localStorage.getItem(storageKey) ?? "null");
      if (!value || typeof value.uid !== "string" ||
          !value.request || typeof value.request.draftId !== "string" ||
          value.request.draftToken !== null ||
          !Number.isSafeInteger(value.request.expectedRevision) ||
          typeof value.request.requestId !== "string" ||
          !(value.paymentId === null || /^fp_[a-f0-9]{32}$/u.test(value.paymentId))) {
        return null;
      }
      return value as PendingPayment;
    } catch {return null;}
  }, [storageKey]);
  const persist = useCallback((value: PendingPayment) => {
    // Persist before requesting a provider order. A lost reply resumes the
    // same frozen draft instead of creating a second checkout.
    window.localStorage.setItem(storageKey, JSON.stringify(value));
    pendingRef.current = value;
  }, [storageKey]);
  const apply = useCallback((value: PublicOrganizerFormPayment, owner: PendingPayment) => {
    const pending = pendingRef.current;
    if (!mountedRef.current || pending?.uid !== owner.uid ||
        pending.request.draftId !== owner.request.draftId) return false;
    persist({...pending, paymentId: value.paymentId});
    setPayment(value);
    setStatus({message: "", tone: ""});
    if (value.receipt) onReceipt(value.receipt);
    return true;
  }, [onReceipt, persist]);
  const check = useCallback(async () => {
    const pending = pendingRef.current;
    if (!pending) return;
    const value = pending.paymentId ? await getOrganizerFormPayment({
      paymentId: pending.paymentId, callback: null,
    }) : await prepareOrganizerFormPayment(pending.request);
    apply(value, pending);
  }, [apply]);
  const mutation = useMutation<void, unknown, () => Promise<void>>({
    mutationFn: (action) => action(),
    onError: (error) => setStatus({tone: "is-error", message:
      error instanceof Error ? error.message : "Payment is being checked. Try again."}),
  });
  const resume = useCallback(async (uid: string | null) => {
    const pending = readPending();
    if (!uid || pending?.uid !== uid) return false;
    pendingRef.current = pending;
    onStart();
    if (operationRef.current) {await operationRef.current; return true;}
    const operation = check().catch((error: unknown) => {
      if (mountedRef.current) setStatus({tone: "is-error", message:
        error instanceof Error ? error.message : "Check payment status to continue."});
    });
    operationRef.current = operation;
    try {await operation;} finally {operationRef.current = null;}
    return true;
  }, [check, onStart, readPending]);
  const prepare = useCallback(async (request: PublicOrganizerFormPaymentRequest,
    uid: string) => {
    const existing = readPending();
    persist(existing?.uid === uid && existing.request.draftId === request.draftId ?
      existing : {uid, request, paymentId: null});
    onStart();
    await check();
  }, [check, onStart, persist, readPending]);
  const refresh = () => mutation.mutateAsync(check).catch(() => undefined);
  const resetSession = useCallback(() => {
    checkoutRef.current?.abort();
    pendingRef.current = null;
    setPayment(null);
    setStatus({message: "", tone: ""});
  }, []);
  const restart = async () => {
    const current = pendingRef.current;
    if (!current?.paymentId) return false;
    const latest = await getOrganizerFormPayment({paymentId: current.paymentId,
      callback: null});
    if (!apply(latest, current) || latest.receipt ||
        !["expired", "refunded"].includes(latest.status)) return false;
    window.localStorage.removeItem(storageKey);
    resetSession();
    return true;
  };
  const pay = (organizerName: string) => mutation.mutateAsync(async () => {
    const current = pendingRef.current;
    if (!current?.paymentId) {await check(); return;}
    // Refresh immediately before opening; an old rendered order may have been
    // captured in another tab, expired, or disconnected by the organizer.
    const latest = await getOrganizerFormPayment({paymentId: current.paymentId,
      callback: null});
    if (!apply(latest, current) || !latest.checkout || latest.receipt) return;
    checkoutRef.current?.abort();
    const abort = new AbortController();
    checkoutRef.current = abort;
    const callback = await openFormCheckout(latest.checkout, organizerName,
      abort.signal);
    if (abort.signal.aborted || !mountedRef.current) return;
    apply(await getOrganizerFormPayment({paymentId: latest.paymentId, callback}), current);
  }).catch(() => undefined);
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
