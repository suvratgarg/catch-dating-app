import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";

const beginOrganizerFormResponse = vi.hoisted(() => vi.fn());
const saveOrganizerFormResponseDraft = vi.hoisted(() => vi.fn());
const submitOrganizerFormResponse = vi.hoisted(() => vi.fn());
const getPublicOrganizerForm = vi.hoisted(() => vi.fn());
const watchPublicFormAuthState = vi.hoisted(() => vi.fn());

vi.mock("../../firebase", () => ({
  beginOrganizerFormResponse,
  beginPublicEventPhoneVerification: vi.fn(),
  completePublicFormEmailSignIn: vi.fn(),
  createOrganizerFormAssetIntent: vi.fn(),
  finalizeOrganizerFormAsset: vi.fn(),
  getPublicOrganizerForm,
  saveOrganizerFormResponseDraft,
  sendPublicFormEmailSignInLink: vi.fn(),
  submitOrganizerFormResponse,
  uploadOrganizerFormAsset: vi.fn(),
  watchPublicFormAuthState,
  withdrawOrganizerFormResponse: vi.fn(),
}));

import {usePublicFormController} from "./usePublicFormController";

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
