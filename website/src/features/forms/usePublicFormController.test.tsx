import {Blob as NodeBlob} from "node:buffer";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";

const beginOrganizerFormResponse = vi.hoisted(() => vi.fn());
const saveOrganizerFormResponseDraft = vi.hoisted(() => vi.fn());
const submitOrganizerFormResponse = vi.hoisted(() => vi.fn());
const getPublicOrganizerForm = vi.hoisted(() => vi.fn());
const watchPublicFormAuthState = vi.hoisted(() => vi.fn());
const findOrganizerFormPayment = vi.hoisted(() => vi.fn());
const createOrganizerFormAssetIntent = vi.hoisted(() => vi.fn());
const uploadOrganizerFormAsset = vi.hoisted(() => vi.fn());
const finalizeOrganizerFormAsset = vi.hoisted(() => vi.fn());

vi.mock("../../firebase", () => ({
  beginOrganizerFormResponse,
  beginPublicEventPhoneVerification: vi.fn(),
  completePublicFormEmailSignIn: vi.fn(),
  createOrganizerFormAssetIntent,
  finalizeOrganizerFormAsset,
  getPublicOrganizerForm,
  findOrganizerFormPayment,
  saveOrganizerFormResponseDraft,
  sendPublicFormEmailSignInLink: vi.fn(),
  submitOrganizerFormResponse,
  uploadOrganizerFormAsset,
  watchPublicFormAuthState,
  withdrawOrganizerFormResponse: vi.fn(),
}));

import {usePublicFormController} from "./usePublicFormController";
import type {PublicFormQuestion} from "./publicFormModel";

beforeEach(() => {findOrganizerFormPayment.mockResolvedValue({payment: null});});
afterEach(() => {vi.restoreAllMocks();});

function wrapper() {
  const client = new QueryClient({
    defaultOptions: {mutations: {retry: false}, queries: {retry: false}},
  });
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  };
}

describe("usePublicFormController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    window.localStorage.clear();
    window.sessionStorage.clear();
    watchPublicFormAuthState.mockImplementation((listener) => {
      listener(null);
      return vi.fn();
    });
  });

  it("fails closed with a useful status when the public form cannot load", async () => {
    getPublicOrganizerForm.mockRejectedValue(new Error("Form unavailable"));
    const {result} = renderHook(
      () => usePublicFormController("public-form-1"),
      {wrapper: wrapper()}
    );

    await waitFor(() => expect(result.current.stage).toBe("unavailable"));
    expect(result.current.status).toEqual({
      message: "Form unavailable",
      tone: "is-error",
    });
    expect(getPublicOrganizerForm).toHaveBeenCalledWith({
      publicFormId: "public-form-1",
      sourceToken: null,
    });
  });
});

const form = {
  publicFormId: "public-form-1", formId: "form-1", versionId: "version-1",
  availabilityStatus: "active", organizer: {name: "Demo organizer"},
  definition: {identityPolicy: "phoneVerified", payment: null, logicRules: [],
    consent: {consentCopy: "Share my answers"},
    sections: [{sectionId: "details", title: "Details", questions: []}]},
  messagingOffer: {termsVersion: "form-whatsapp-v1",
    organizerWhatsapp: "Organizer WhatsApp", catchWhatsapp: "Catch WhatsApp"},
};
const draft = {draftId: "draft-1", draftToken: null, revision: 1, form,
  answers: {}, consentAccepted: false, expiresAtMillis: 100000};

describe("form consent and authenticated draft ownership", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    window.localStorage.clear();
    window.sessionStorage.clear();
    watchPublicFormAuthState.mockImplementation((listener) => {
      listener({uid: "person-1"});
      return vi.fn();
    });
    getPublicOrganizerForm.mockResolvedValue(form);
    beginOrganizerFormResponse.mockResolvedValue(draft);
    saveOrganizerFormResponseDraft.mockResolvedValue({revision: 2, expiresAtMillis: 200000});
    submitOrganizerFormResponse.mockResolvedValue({responseId: "response-1", formId: "form-1",
      status: "submitted", completion: {title: "Received"}});
  });

  it("recovers a paid response even when the current form is full and republished", async () => {
    getPublicOrganizerForm.mockResolvedValue({...form, availabilityStatus: "full", versionId: "version-2"});
    findOrganizerFormPayment.mockResolvedValue({payment: recoveredPayment});
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(result.current.stage).toBe("complete"));
    expect(result.current.receipt?.versionId).toBe("version-1");
    expect(beginOrganizerFormResponse).not.toHaveBeenCalled();
  });

  it("allows phone verification to recover a closed form without creating a draft", async () => {
    let authChanged!: (value: {uid: string} | null) => void;
    watchPublicFormAuthState.mockImplementation((listener) => {
      authChanged = listener; listener(null); return vi.fn();
    });
    getPublicOrganizerForm.mockResolvedValue({...form, availabilityStatus: "paused"});
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(result.current.stage).toBe("unavailable"));
    act(() => result.current.recoverPayment());
    expect(result.current.stage).toBe("identity");
    expect(result.current.recoveringPayment).toBe(true);
    findOrganizerFormPayment.mockResolvedValue({payment: recoveredPayment});
    act(() => authChanged({uid: "person-1"}));
    await waitFor(() => expect(result.current.stage).toBe("complete"));
    expect(beginOrganizerFormResponse).not.toHaveBeenCalled();
  });

  it("never begins a new draft after an unavailable recovery lookup", async () => {
    findOrganizerFormPayment.mockRejectedValue(new Error("Payment lookup unavailable"));
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(result.current.status.message).toBe("Payment lookup unavailable"));
    expect(result.current.stage).toBe("unavailable");
    expect(beginOrganizerFormResponse).not.toHaveBeenCalled();
  });

  it("submits with an in-memory draft id when browser storage is unavailable", async () => {
    for (const method of ["getItem", "setItem", "removeItem"] as const) {
      vi.spyOn(Storage.prototype, method).mockImplementation(() => {throw new Error("Denied");});
    }
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(result.current.stage).toBe("form"));
    act(() => result.current.updateConsent(true));
    await act(async () => {await result.current.submit();});
    expect(result.current.stage).toBe("complete");
  });

  it("restores a free receipt only for its cached account owner", async () => {
    window.localStorage.setItem("catch:form:public-form-1:receipt", JSON.stringify({
      ...recoveredPayment.receipt, cacheOwnerUid: "person-1",
    }));
    const first = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(first.result.current.stage).toBe("complete"));
    expect(beginOrganizerFormResponse).not.toHaveBeenCalled();
    first.unmount();
    watchPublicFormAuthState.mockImplementation((listener) => {
      listener({uid: "other"}); return vi.fn();
    });
    const second = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(second.result.current.stage).toBe("form"));
    expect(second.result.current.receipt).toBeNull();
  });

  it("starts unchecked and persists independent optional choices with the submitted snapshot", async () => {
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(result.current.stage).toBe("form"));
    expect(result.current.messagingChoices).toEqual({termsVersion: "form-whatsapp-v1",
      organizerWhatsapp: false, catchWhatsapp: false});
    act(() => {
      result.current.updateConsent(true);
      result.current.updateMessagingChoice("organizerWhatsapp", true);
    });
    await act(async () => { await result.current.submit(); });
    expect(saveOrganizerFormResponseDraft).toHaveBeenLastCalledWith(expect.objectContaining({
      consentAccepted: true, messagingChoices: {termsVersion: "form-whatsapp-v1",
        organizerWhatsapp: true, catchWhatsapp: false},
    }));
    expect(result.current.stage).toBe("complete");
  });

  it("submits normally with neither optional choice selected", async () => {
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(result.current.stage).toBe("form"));
    act(() => result.current.updateConsent(true));
    await act(async () => { await result.current.submit(); });
    expect(submitOrganizerFormResponse).toHaveBeenCalledTimes(1);
    expect(saveOrganizerFormResponseDraft.mock.calls[0][0].messagingChoices)
      .toEqual({termsVersion: "form-whatsapp-v1", organizerWhatsapp: false, catchWhatsapp: false});
  });

  for (const step of ["intent", "upload", "finalize"] as const) {
    for (const outcome of ["success", "failure"] as const) {
      it(`ignores an old account's ${step} ${outcome} after switching identity`, async () => {
        let authChanged!: (value: {uid: string}) => void;
        watchPublicFormAuthState.mockImplementation((listener) => {
          authChanged = listener; listener({uid: "person-1"}); return vi.fn();
        });
        const intent = {assetId: "old-private-photo", uploadToken: "old-upload"};
        createOrganizerFormAssetIntent.mockResolvedValue(intent);
        uploadOrganizerFormAsset.mockResolvedValue(undefined);
        finalizeOrganizerFormAsset.mockResolvedValue(undefined);
        const pendingStep = {intent: createOrganizerFormAssetIntent,
          upload: uploadOrganizerFormAsset, finalize: finalizeOrganizerFormAsset}[step];
        let finish!: (value?: unknown) => void;
        let reject!: (error: Error) => void;
        pendingStep.mockImplementationOnce(() => new Promise((resolve, fail) => {
          finish = resolve; reject = fail;
        }));
        const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
        await waitFor(() => expect(result.current.stage).toBe("form"));
        let uploading!: Promise<void>;
        act(() => {
          uploading = result.current.uploadAnswer(photoQuestion, [photoFile]);
        });
        await waitFor(() => expect(pendingStep).toHaveBeenCalledTimes(1));
        beginOrganizerFormResponse.mockResolvedValue({...draft, draftId: "draft-2"});
        act(() => authChanged({uid: "person-2"}));
        await waitFor(() => expect(beginOrganizerFormResponse).toHaveBeenCalledTimes(2));
        await act(async () => {
          if (outcome === "success") finish(intent);
          else reject(new Error("Old account upload failed"));
          await uploading;
        });
        expect(result.current.answers).toEqual({});
        expect(result.current.uploads).toEqual({});
        expect(result.current.uploadInProgress).toBe(false);
        expect(result.current.status.message).toBe("");
        if (step === "intent") expect(uploadOrganizerFormAsset).not.toHaveBeenCalled();
        if (step !== "finalize") expect(finalizeOrganizerFormAsset).not.toHaveBeenCalled();
      });
    }
  }

  it("keeps a successful upload on its original account's draft", async () => {
    createOrganizerFormAssetIntent.mockResolvedValue({assetId: "photo-1", uploadToken: "upload-1"});
    uploadOrganizerFormAsset.mockResolvedValue(undefined);
    finalizeOrganizerFormAsset.mockResolvedValue(undefined);
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(result.current.stage).toBe("form"));
    await act(async () => {await result.current.uploadAnswer(photoQuestion, [photoFile]);});
    expect(result.current.answers).toEqual({photo: ["photo-1"]});
    expect(result.current.uploads.photo.status).toBe("ready");
    expect(finalizeOrganizerFormAsset).toHaveBeenCalledWith({draftId: "draft-1",
      draftToken: null, assetId: "photo-1", uploadToken: "upload-1"});
  });

  it("an old identity's draft result cannot populate the next identity's form", async () => {
    let authChanged: (value: {uid: string}) => void = () => undefined;
    watchPublicFormAuthState.mockImplementation((listener) => {
      authChanged = listener; listener({uid: "person-1"}); return vi.fn();
    });
    let finishOld: (value: unknown) => void = () => undefined;
    beginOrganizerFormResponse.mockImplementationOnce(() => new Promise((resolve) => { finishOld = resolve; }));
    beginOrganizerFormResponse.mockResolvedValue({...draft, draftId: "draft-2"});
    const {result} = renderHook(() => usePublicFormController("public-form-1"), {wrapper: wrapper()});
    await waitFor(() => expect(beginOrganizerFormResponse).toHaveBeenCalledTimes(1));
    act(() => authChanged({uid: "person-2"}));
    await waitFor(() => expect(result.current.stage).toBe("form"));
    await act(async () => { finishOld({...draft, answers: {secret: "private old answer"},
      messagingChoices: {termsVersion: "form-whatsapp-v1", organizerWhatsapp: true, catchWhatsapp: true}}); });
    expect(result.current.answers).toEqual({});
    expect(result.current.messagingChoices.organizerWhatsapp).toBe(false);
    expect(result.current.messagingChoices.catchWhatsapp).toBe(false);
  });
});

const recoveredPayment = {paymentId: `fp_${"a".repeat(32)}`, status: "submitted",
  checkout: null, receipt: {responseId: "response-1", formId: "form-1", versionId: "version-1",
    status: "submitted", submittedAtMillis: 1000, withdrawalToken: null,
    completion: {title: "Received", message: null, actionKind: "none",
      actionLabel: null, actionUrl: null}}};

const photoQuestion: PublicFormQuestion = {
  questionId: "photo", key: "photo", label: "Photo", helpText: null,
  kind: "file", required: false, options: [], canonicalFieldId: null,
  privacyClass: "organizerCustom", prefillPolicy: "never", hostPresentation: "detailOnly",
  validation: {minLength: null, maxLength: null, minNumber: null, maxNumber: null,
    earliestDate: null, latestDate: null, minSelections: null, maxSelections: null,
    maxFileCount: 1, maxFileSizeBytes: null, allowedMimeTypes: ["image/png"],
    patternPreset: null, customError: null},
};
const photoFile = {blob: new NodeBlob(["synthetic photo"], {type: "image/png"}) as Blob,
  name: "photo.png"};
