import {type FormEvent, useCallback, useEffect, useMemo, useRef, useState} from "react";
import {useMutation} from "@tanstack/react-query";
import {
  beginOrganizerFormResponse,
  beginPublicEventPhoneVerification,
  completePublicFormEmailSignIn,
  createOrganizerFormAssetIntent,
  finalizeOrganizerFormAsset,
  getPublicOrganizerForm,
  saveOrganizerFormResponseDraft,
  sendPublicFormEmailSignInLink,
  submitOrganizerFormResponse,
  uploadOrganizerFormAsset,
  watchPublicFormAuthState,
  withdrawOrganizerFormResponse,
  type PublicEventPhoneVerification,
  type PublicOrganizerForm,
  type PublicOrganizerFormDraft,
  type PublicOrganizerFormReceipt,
  type User,
} from "../../firebase";
import {publicFormsCopy} from "../../content/forms";
import type {FormStatus} from "../../shared/forms/types";
import {
  validatePublicFormAnswers,
  visiblePublicFormSections,
  type PublicFormAnswer,
  type PublicFormAnswers,
  type PublicFormQuestion,
} from "./publicFormModel";

export type PublicFormStage =
  "loading" | "unavailable" | "identity" | "phoneCode" |
  "emailSent" | "form" | "review" | "complete" | "withdrawn";

export interface PublicFormUploadState {
  status: "uploading" | "ready" | "error";
  label: string;
}

export function usePublicFormController(publicFormId: string) {
  const [stage, setStage] = useState<PublicFormStage>("loading");
  const [form, setForm] = useState<PublicOrganizerForm | null>(null);
  const [draft, setDraft] = useState<PublicOrganizerFormDraft | null>(null);
  const [receipt, setReceipt] = useState<PublicOrganizerFormReceipt | null>(
    () => storedReceipt(publicFormId)
  );
  const [answers, setAnswers] = useState<PublicFormAnswers>({});
  const [consentAccepted, setConsentAccepted] = useState(false);
  const [sectionIndex, setSectionIndex] = useState(0);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});
  const [phoneNumber, setPhoneNumber] = useState("");
  const [code, setCode] = useState("");
  const [email, setEmail] = useState(() =>
    window.localStorage.getItem(emailStorageKey(publicFormId)) ?? "");
  const [saveState, setSaveState] = useState<"idle" | "saving" | "saved">("idle");
  const [dirtyRevision, setDirtyRevision] = useState(0);
  const [uploads, setUploads] = useState<
    Record<string, PublicFormUploadState>
  >({});
  const formRef = useRef<PublicOrganizerForm | null>(null);
  const userRef = useRef<User | null>(null);
  const draftRef = useRef<PublicOrganizerFormDraft | null>(null);
  const answersRef = useRef<PublicFormAnswers>({});
  const consentRef = useRef(false);
  const verificationRef = useRef<PublicEventPhoneVerification | null>(null);
  const saveChainRef = useRef<Promise<void>>(Promise.resolve());
  const startPromiseRef = useRef<Promise<void> | null>(null);
  const submitRequestIdRef = useRef(requestId());
  const sourceToken = useMemo(() => {
    const value = new URLSearchParams(window.location.search).get("source");
    return value && /^[A-Za-z0-9_-]{20,160}$/u.test(value) ? value : null;
  }, []);
  const embed = useMemo(() =>
    new URLSearchParams(window.location.search).get("embed") === "1", []);
  const recaptchaContainerId = `public-form-recaptcha-${publicFormId}`;
  const visibleSections = useMemo(() => form ?
    visiblePublicFormSections(form.definition, answers) : [], [answers, form]);
  const activeSection = visibleSections[Math.min(
    sectionIndex,
    Math.max(0, visibleSections.length - 1)
  )] ?? null;
  const actionMutation = useMutation<void, unknown, () => Promise<void>>({
    mutationFn: (action) => action(),
    onError: (error) => {
      setStatus({message: publicFormError(error), tone: "is-error"});
    },
  });
  const pending = actionMutation.isPending;
  const uploadInProgress = Object.values(uploads).some(
    (upload) => upload.status === "uploading"
  );

  const startDraft = useCallback(async (nextForm: PublicOrganizerForm) => {
    if (startPromiseRef.current) return startPromiseRef.current;
    const operation = (async () => {
      try {
        const started = await beginOrganizerFormResponse({
          publicFormId,
          sourceToken,
          requestId: stableStartRequestId(publicFormId),
        });
        draftRef.current = started;
        answersRef.current = {...started.answers};
        consentRef.current = started.consentAccepted;
        setDraft(started);
        setAnswers({...started.answers});
        setConsentAccepted(started.consentAccepted);
        setStatus({message: "", tone: ""});
        setStage("form");
      } catch (error) {
        setStatus({message: publicFormError(error), tone: "is-error"});
        const policy = nextForm.definition.identityPolicy;
        setStage(policy === "anonymous" ? "unavailable" : "identity");
      }
    })();
    startPromiseRef.current = operation;
    try {
      await operation;
    } finally {
      if (startPromiseRef.current === operation) startPromiseRef.current = null;
    }
  }, [publicFormId, sourceToken]);

  useEffect(() => {
    let cancelled = false;
    const unsubscribe = watchPublicFormAuthState((user) => {
      if (cancelled) return;
      userRef.current = user;
      const loaded = formRef.current;
      if (user && loaded && loaded.availabilityStatus === "active" &&
          loaded.definition.identityPolicy !== "anonymous") {
        void startDraft(loaded);
      }
    });
    void getPublicOrganizerForm({publicFormId, sourceToken})
      .then(async (loaded) => {
        if (cancelled) return;
        formRef.current = loaded;
        setForm(loaded);
        const savedReceipt = storedReceipt(publicFormId);
        if (savedReceipt?.formId === loaded.formId &&
            savedReceipt.status === "submitted") {
          setReceipt(savedReceipt);
          setStage("complete");
          return;
        }
        if (loaded.availabilityStatus !== "active") {
          setStage("unavailable");
          return;
        }
        if (loaded.definition.identityPolicy === "anonymous" || userRef.current) {
          await startDraft(loaded);
        } else {
          setStage("identity");
        }
      })
      .catch((error) => {
        if (cancelled) return;
        setStatus({message: publicFormError(error), tone: "is-error"});
        setStage("unavailable");
      });
    return () => {
      cancelled = true;
      verificationRef.current?.clear();
      unsubscribe();
    };
  }, [publicFormId, sourceToken, startDraft]);

  const flushSave = useCallback(() => {
    const operation = async () => {
      const current = draftRef.current;
      if (!current || current.form.versionId !== formRef.current?.versionId) return;
      setSaveState("saving");
      try {
        const saved = await saveOrganizerFormResponseDraft({
          draftId: current.draftId,
          draftToken: current.draftToken,
          expectedRevision: current.revision,
          answers: answersRef.current,
          consentAccepted: consentRef.current,
        });
        const updated = {...current, revision: saved.revision,
          expiresAtMillis: saved.expiresAtMillis,
          answers: {...answersRef.current},
          consentAccepted: consentRef.current};
        draftRef.current = updated;
        setDraft(updated);
        setSaveState("saved");
      } catch (error) {
        setSaveState("idle");
        setStatus({message: publicFormError(error), tone: "is-error"});
        throw error;
      }
    };
    const next = saveChainRef.current.then(operation, operation);
    saveChainRef.current = next.catch(() => undefined);
    return next;
  }, []);

  useEffect(() => {
    if (dirtyRevision === 0 || stage !== "form") return undefined;
    setSaveState("saving");
    const timer = window.setTimeout(() => void flushSave(), 700);
    return () => window.clearTimeout(timer);
  }, [dirtyRevision, flushSave, stage]);

  function updateAnswer(questionId: string, value: PublicFormAnswer) {
    setAnswers((current) => {
      const updated = {...current, [questionId]: value};
      answersRef.current = updated;
      return updated;
    });
    setErrors((current) => {
      if (!(questionId in current)) return current;
      const updated = {...current};
      delete updated[questionId];
      return updated;
    });
    setDirtyRevision((value) => value + 1);
  }

  function updateConsent(value: boolean) {
    consentRef.current = value;
    setConsentAccepted(value);
    setDirtyRevision((current) => current + 1);
  }

  async function handlePhoneSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus({message: "", tone: ""});
    await actionMutation.mutateAsync(async () => {
      verificationRef.current?.clear();
      verificationRef.current = await beginPublicEventPhoneVerification(
        normalizePhone(phoneNumber),
        recaptchaContainerId
      );
      setStage("phoneCode");
    }).catch(() => undefined);
  }

  async function handleCodeSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const verification = verificationRef.current;
    if (!verification) return;
    await actionMutation.mutateAsync(async () => {
      await verification.confirm(code);
      verification.clear();
      verificationRef.current = null;
      if (formRef.current) await startDraft(formRef.current);
    }).catch(() => undefined);
  }

  async function handleEmailSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus({message: "", tone: ""});
    await actionMutation.mutateAsync(async () => {
      const key = emailStorageKey(publicFormId);
      const currentUrl = window.location.href;
      if (currentUrl.includes("mode=signIn")) {
        await completePublicFormEmailSignIn(email.trim(), currentUrl);
        window.localStorage.removeItem(key);
        if (formRef.current) await startDraft(formRef.current);
      } else {
        window.localStorage.setItem(key, email.trim());
        await sendPublicFormEmailSignInLink(email.trim(), currentUrl);
        setStage("emailSent");
      }
    }).catch(() => undefined);
  }

  async function nextSection() {
    if (!activeSection) return;
    if (uploadInProgress) {
      setStatus({message: publicFormsCopy.uploadPending, tone: "is-error"});
      return;
    }
    const nextErrors = validatePublicFormAnswers(activeSection.questions, answers);
    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) return;
    await flushSave().catch(() => undefined);
    if (sectionIndex >= visibleSections.length - 1) {
      setStage("review");
    } else {
      setSectionIndex((current) => current + 1);
      window.scrollTo({top: 0, behavior: "smooth"});
    }
  }

  async function uploadAnswer(
    question: PublicFormQuestion,
    files: Array<{blob: Blob; name: string}>
  ) {
    const current = draftRef.current;
    if (!current || files.length === 0) return;
    const maximum = question.kind === "signature" ? 1 :
      question.validation.maxFileCount ?? 1;
    if (files.length > maximum) {
      setStatus({
        message: question.validation.customError ??
          `${question.label} accepts at most ${maximum} file${maximum === 1 ? "" : "s"}.`,
        tone: "is-error",
      });
      return;
    }
    setUploads((value) => ({
      ...value,
      [question.questionId]: {
        status: "uploading",
        label: publicFormsCopy.uploadingFile,
      },
    }));
    try {
      const assetIds: string[] = [];
      for (const file of files) {
        const sha256 = await sha256Hex(file.blob);
        const intent = await createOrganizerFormAssetIntent({
          draftId: current.draftId,
          draftToken: current.draftToken,
          questionId: question.questionId,
          requestId: requestId(),
          originalFileName: file.name,
          contentType: requireSupportedContentType(file.blob.type),
          sizeBytes: file.blob.size,
          sha256,
        });
        await uploadOrganizerFormAsset(intent, file.blob);
        await finalizeOrganizerFormAsset({
          draftId: current.draftId,
          draftToken: current.draftToken,
          assetId: intent.assetId,
          uploadToken: intent.uploadToken,
        });
        assetIds.push(intent.assetId);
      }
      updateAnswer(
        question.questionId,
        question.kind === "signature" ? assetIds[0] : assetIds
      );
      setUploads((value) => ({
        ...value,
        [question.questionId]: {
          status: "ready",
          label: question.kind === "signature" ?
            publicFormsCopy.signatureReady : publicFormsCopy.uploadedFile,
        },
      }));
      setStatus({message: "", tone: ""});
    } catch (error) {
      setUploads((value) => ({
        ...value,
        [question.questionId]: {
          status: "error",
          label: publicFormsCopy.uploadFailed,
        },
      }));
      setStatus({message: publicFormError(error), tone: "is-error"});
    }
  }

  function previousSection() {
    if (sectionIndex === 0) return;
    setSectionIndex((current) => Math.max(0, current - 1));
    window.scrollTo({top: 0, behavior: "smooth"});
  }

  async function submit() {
    const questions = visibleSections.flatMap((section) => section.questions);
    const nextErrors = validatePublicFormAnswers(questions, answers);
    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) {
      setStage("form");
      setSectionIndex(sectionForFirstError(visibleSections, nextErrors));
      return;
    }
    if (!consentRef.current) {
      setStatus({message: form?.definition.consent.consentCopy ??
        publicFormsCopy.genericError, tone: "is-error"});
      return;
    }
    await actionMutation.mutateAsync(async () => {
      await flushSave();
      const current = draftRef.current;
      if (!current) throw new Error(publicFormsCopy.genericError);
      const submitted = await submitOrganizerFormResponse({
        draftId: current.draftId,
        draftToken: current.draftToken,
        expectedRevision: current.revision,
        requestId: submitRequestIdRef.current,
      });
      setReceipt(submitted);
      persistReceipt(publicFormId, submitted);
      setStage("complete");
      setStatus({message: "", tone: ""});
    }).catch(() => undefined);
  }

  async function withdraw() {
    if (!receipt) return;
    await actionMutation.mutateAsync(async () => {
      await withdrawOrganizerFormResponse({
        responseId: receipt.responseId,
        withdrawalToken: receipt.withdrawalToken,
        requestId: requestId(),
      });
      clearReceipt(publicFormId);
      setStage("withdrawn");
    }).catch(() => undefined);
  }

  return {
    activeSection,
    answers,
    code,
    consentAccepted,
    embed,
    email,
    errors,
    form,
    handleCodeSubmit,
    handleEmailSubmit,
    handlePhoneSubmit,
    nextSection,
    pending,
    phoneNumber,
    previousSection,
    receipt,
    recaptchaContainerId,
    saveState,
    sectionIndex,
    setCode,
    setEmail,
    setPhoneNumber,
    setSectionIndex,
    setStage,
    stage,
    status,
    submit,
    updateAnswer,
    updateConsent,
    uploadAnswer,
    uploadInProgress,
    uploads,
    visibleSections,
    withdraw,
  };
}

async function sha256Hex(blob: Blob) {
  const digest = await globalThis.crypto.subtle.digest(
    "SHA-256",
    await blob.arrayBuffer()
  );
  return [...new Uint8Array(digest)]
    .map((value) => value.toString(16).padStart(2, "0"))
    .join("");
}

function requireSupportedContentType(value: string) {
  if (value === "image/jpeg" || value === "image/png" ||
      value === "image/webp" || value === "application/pdf") return value;
  throw new Error("Choose a JPEG, PNG, WebP, or PDF file.");
}

function requestId() {
  return globalThis.crypto?.randomUUID?.() ??
    `request-${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

function stableStartRequestId(publicFormId: string) {
  const key = `catch:form:${publicFormId}:start`;
  const existing = window.sessionStorage.getItem(key);
  if (existing) return existing;
  const created = requestId();
  window.sessionStorage.setItem(key, created);
  return created;
}

function emailStorageKey(publicFormId: string) {
  return `catch:form:${publicFormId}:email`;
}

function persistReceipt(
  publicFormId: string,
  receipt: PublicOrganizerFormReceipt
) {
  window.localStorage.setItem(
    `catch:form:${publicFormId}:receipt`,
    JSON.stringify(receipt)
  );
}

function clearReceipt(publicFormId: string) {
  window.localStorage.removeItem(`catch:form:${publicFormId}:receipt`);
}

function storedReceipt(publicFormId: string): PublicOrganizerFormReceipt | null {
  const value = window.localStorage.getItem(
    `catch:form:${publicFormId}:receipt`
  );
  if (!value) return null;
  try {
    const parsed: unknown = JSON.parse(value);
    if (!isRecord(parsed) || typeof parsed.responseId !== "string" ||
        typeof parsed.formId !== "string" ||
        typeof parsed.versionId !== "string" ||
        parsed.status !== "submitted" ||
        typeof parsed.submittedAtMillis !== "number" ||
        !(parsed.withdrawalToken === null ||
          typeof parsed.withdrawalToken === "string") ||
        !isRecord(parsed.completion)) return null;
    return parsed as PublicOrganizerFormReceipt;
  } catch {
    return null;
  }
}

function normalizePhone(value: string) {
  return value.replace(/[\s()-]/gu, "");
}

function sectionForFirstError(
  sections: ReturnType<typeof visiblePublicFormSections>,
  errors: Record<string, string>
) {
  const index = sections.findIndex((section) =>
    section.questions.some((question) => question.questionId in errors));
  return index < 0 ? 0 : index;
}

function publicFormError(error: unknown) {
  if (error instanceof Error && error.message.trim()) return error.message;
  return publicFormsCopy.genericError;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
