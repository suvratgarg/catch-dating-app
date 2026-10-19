/** @vitest-environment jsdom */
/** @vitest-environment-options {"url":"https://forms.client.example/"} */
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {BrowserRouter, Route, Routes} from "react-router";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import type {PublicOrganizerForm, PublicOrganizerFormDraft,
  PublicOrganizerFormReceipt} from "../firebase";
import {publicFormsCopy} from "../content/forms";
import {CustomFormDomainGate} from "./CustomFormDomainGate";
import {PublicFormPage} from "../features/forms/PublicFormPage";

type FirebaseApi = typeof import("../firebase");
const api = vi.hoisted(() => ({
  getPublicOrganizerForm: vi.fn<FirebaseApi["getPublicOrganizerForm"]>(),
  beginOrganizerFormResponse: vi.fn<FirebaseApi["beginOrganizerFormResponse"]>(),
  saveOrganizerFormResponseDraft: vi.fn<FirebaseApi["saveOrganizerFormResponseDraft"]>(),
  submitOrganizerFormResponse: vi.fn<FirebaseApi["submitOrganizerFormResponse"]>(),
  watchPublicFormAuthState: vi.fn<FirebaseApi["watchPublicFormAuthState"]>(),
  listParticipantFormActivity: vi.fn<FirebaseApi["listParticipantFormActivity"]>(),
  findOrganizerFormPayment: vi.fn<FirebaseApi["findOrganizerFormPayment"]>(),
  getOrganizerFormPayment: vi.fn<FirebaseApi["getOrganizerFormPayment"]>(),
  prepareOrganizerFormPayment: vi.fn<FirebaseApi["prepareOrganizerFormPayment"]>(),
  beginPublicEventPhoneVerification: vi.fn(), completePublicFormEmailSignIn: vi.fn(),
  createOrganizerFormAssetIntent: vi.fn(), finalizeOrganizerFormAsset: vi.fn(),
  promoteFormCommunicationIntent: vi.fn(), sendPublicFormEmailSignInLink: vi.fn(),
  uploadOrganizerFormAsset: vi.fn(), withdrawOrganizerFormResponse: vi.fn(),
}));
vi.mock("../firebase", () => api);

const hostname = "forms.client.example";
const form: PublicOrganizerForm = {
  publicFormId: "bound-public", formId: "bound-form", versionId: "bound-version",
  version: 1, availabilityStatus: "active", availabilityMessage: null,
  organizer: {organizerId: "synthetic-organizer", name: "Synthetic organizer", logoUrl: null},
  definition: {
    title: "Synthetic client application", description: "Synthetic integration fixture",
    purpose: "application", defaultTargetKind: "organizer", defaultTargetId: null,
    identityPolicy: "anonymous", payment: null, logicRules: [],
    appearance: {preset: "minimal", logoAssetId: null, coverAssetId: null, activityKind: null},
    availability: {opensAt: null, closesAt: null, responseLimit: null, closedMessage: null},
    consent: {consentCopy: "Share my synthetic answer", consentVersion: "synthetic-v1",
      retentionCopy: "Synthetic fixture only"},
    completion: {title: "Synthetic response received", message: "Synthetic submission complete",
      actionKind: "none", actionLabel: null, actionUrl: null},
    sections: [{sectionId: "details", title: "Details", description: null, pageBreak: false,
      questions: [{questionId: "name", key: "name", label: "Your name", helpText: null,
        kind: "shortText", required: true, options: [], canonicalFieldId: null,
        privacyClass: "organizerCustom", answerDestination: "organizerOnly",
        prefillPolicy: "never", hostPresentation: "detailOnly",
        validation: {minLength: null, maxLength: 80, minNumber: null, maxNumber: null,
          earliestDate: null, latestDate: null, minSelections: null, maxSelections: null,
          maxFileCount: null, maxFileSizeBytes: null, allowedMimeTypes: [],
          patternPreset: null, customError: null}}]}],
  },
};
const draft: PublicOrganizerFormDraft = {
  draftId: "bound-draft", draftToken: "synthetic-anonymous-draft-token", form,
  revision: 1, answers: {}, consentAccepted: false, identityKind: "anonymous",
  expiresAtMillis: 2_000_000_000_000,
};
const receipt: PublicOrganizerFormReceipt = {
  responseId: "bound-response", formId: form.formId, versionId: form.versionId,
  status: "submitted", submittedAtMillis: 1_800_000_000_000,
  withdrawalToken: "synthetic-withdrawal-token", completion: form.definition.completion,
};
let client: QueryClient | undefined;
let domainFetch: ReturnType<typeof vi.fn<typeof fetch>>;

beforeEach(() => {
  window.localStorage.clear();
  window.sessionStorage.clear();
  window.history.replaceState({}, "", "/f/other-public");
  domainFetch = vi.fn<typeof fetch>();
  vi.stubGlobal("fetch", domainFetch);
  api.getPublicOrganizerForm.mockImplementation(async ({publicFormId}) => {
    if (publicFormId !== form.publicFormId) throw new Error("Unexpected public form");
    return form;
  });
  api.beginOrganizerFormResponse.mockImplementation(async ({publicFormId}) => {
    if (publicFormId !== form.publicFormId) throw new Error("Unexpected draft owner");
    return draft;
  });
  api.watchPublicFormAuthState.mockImplementation((listener) => {
    listener(null);
    return () => undefined;
  });
  api.saveOrganizerFormResponseDraft.mockImplementation(async (payload) => ({
    draftId: payload.draftId, revision: payload.expectedRevision + 1,
    expiresAtMillis: draft.expiresAtMillis,
  }));
  api.submitOrganizerFormResponse.mockResolvedValue(receipt);
});
afterEach(() => {
  cleanup();
  client?.clear();
  client = undefined;
  window.localStorage.clear();
  window.sessionStorage.clear();
  window.history.replaceState({}, "", "/");
  vi.unstubAllGlobals();
});

function mount() {
  client = new QueryClient({defaultOptions: {
    queries: {retry: false}, mutations: {retry: false},
  }});
  // Real location hostname, gate, router, page and controller. Only transport is synthetic.
  return render(<QueryClientProvider client={client}>
    <BrowserRouter><CustomFormDomainGate>
      <Routes>
        <Route path="/f/:publicFormId" element={<PublicFormPage />} />
        <Route path="*" element={<p>Unrelated route must remain hidden</p>} />
      </Routes>
    </CustomFormDomainGate></BrowserRouter>
  </QueryClientProvider>);
}
function resolvedDomain() {
  return new Response(JSON.stringify({hostname, publicFormId: form.publicFormId}),
    {status: 200, headers: {"Content-Type": "application/json"}});
}
function expectNoFormWork() {
  for (const operation of Object.values(api)) expect(operation).not.toHaveBeenCalled();
  expect(screen.queryByRole("textbox", {name: "Your name"})).toBeNull();
  expect(screen.queryByRole("button", {name: publicFormsCopy.submit})).toBeNull();
  expect(screen.queryByText("Unrelated route must remain hidden")).toBeNull();
}

describe("custom domain and real public form integration (synthetic jsdom)", () => {
  it("submits only the resolved form after redirect, review and explicit consent", async () => {
    domainFetch.mockResolvedValue(resolvedDomain());
    mount();
    const answer = await screen.findByRole("textbox", {name: "Your name"});
    await waitFor(() => expect(api.beginOrganizerFormResponse).toHaveBeenCalledOnce());
    expect(window.location.hostname).toBe(hostname);
    expect(window.location.pathname).toBe(`/f/${form.publicFormId}`);
    expect(domainFetch).toHaveBeenCalledWith(`/api/form-domain?hostname=${hostname}`,
      expect.objectContaining({credentials: "omit", cache: "no-store",
        signal: expect.any(AbortSignal)}));
    expect(api.getPublicOrganizerForm).toHaveBeenCalledExactlyOnceWith({
      publicFormId: form.publicFormId, sourceToken: null,
    });
    expect(api.beginOrganizerFormResponse).toHaveBeenCalledWith({
      publicFormId: form.publicFormId, sourceToken: null, requestId: expect.any(String),
    });
    fireEvent.change(answer, {target: {value: "Synthetic respondent"}});
    fireEvent.click(screen.getByRole("button", {name: publicFormsCopy.review}));
    await screen.findByRole("heading", {name: publicFormsCopy.reviewTitle});
    const consent = screen.getByRole("checkbox", {name: form.definition.consent.consentCopy});
    expect((consent as HTMLInputElement).checked).toBe(false);
    expect(api.submitOrganizerFormResponse).not.toHaveBeenCalled();
    fireEvent.click(consent);
    fireEvent.click(screen.getByRole("button", {name: publicFormsCopy.submit}));
    await screen.findByRole("heading", {name: receipt.completion.title});
    expect(api.saveOrganizerFormResponseDraft).toHaveBeenLastCalledWith({
      draftId: draft.draftId, draftToken: draft.draftToken,
      expectedRevision: expect.any(Number), answers: {name: "Synthetic respondent"},
      consentAccepted: true,
    });
    const lastSave = api.saveOrganizerFormResponseDraft.mock.calls.at(-1)![0];
    expect(api.submitOrganizerFormResponse).toHaveBeenCalledExactlyOnceWith({
      draftId: draft.draftId, draftToken: draft.draftToken,
      expectedRevision: lastSave.expectedRevision + 1, requestId: expect.any(String),
    });
    expect(screen.queryByText("Unrelated route must remain hidden")).toBeNull();
    expect(api.beginPublicEventPhoneVerification).not.toHaveBeenCalled();
    expect(api.prepareOrganizerFormPayment).not.toHaveBeenCalled();
  });

  it("does no form or auth work while host resolution is held", async () => {
    let resolve!: (response: Response) => void;
    domainFetch.mockImplementation(() => new Promise<Response>((done) => {resolve = done;}));
    mount();
    expect(screen.getByText(publicFormsCopy.loading)).toBeTruthy();
    expectNoFormWork();
    await act(async () => {resolve(resolvedDomain());});
    await screen.findByRole("textbox", {name: "Your name"});
    await waitFor(() => expect(api.beginOrganizerFormResponse).toHaveBeenCalledOnce());
    expect(api.getPublicOrganizerForm).toHaveBeenCalledWith({
      publicFormId: form.publicFormId, sourceToken: null,
    });
  });

  // Unknown and revoked are the same opaque denial at the browser boundary;
  // server/Firestore suites independently establish why a host is denied.
  for (const reason of ["unknown", "revoked", "mismatched-host"] as const) {
    it(`does not mount a form for ${reason} resolution`, async () => {
      domainFetch.mockResolvedValue(reason === "mismatched-host" ?
        new Response(JSON.stringify({hostname: "other.client.example",
          publicFormId: form.publicFormId}), {status: 200}) :
        new Response(null, {status: 404}));
      mount();
      await screen.findByRole("heading", {name: publicFormsCopy.unavailableTitle});
      expectNoFormWork();
      expect(window.location.pathname).toBe("/f/other-public");
    });
  }

  it("does not mount a form after a resolution transport failure", async () => {
    domainFetch.mockRejectedValue(new Error("Synthetic network failure"));
    mount();
    await screen.findByRole("heading", {name: publicFormsCopy.unavailableTitle});
    expectNoFormWork();
  });
});
