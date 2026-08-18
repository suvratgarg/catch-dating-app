import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";

const getPublicOrganizerForm = vi.hoisted(() => vi.fn());
const watchPublicFormAuthState = vi.hoisted(() => vi.fn());

vi.mock("../../firebase", () => ({
  beginOrganizerFormResponse: vi.fn(),
  beginPublicEventPhoneVerification: vi.fn(),
  completePublicFormEmailSignIn: vi.fn(),
  createOrganizerFormAssetIntent: vi.fn(),
  finalizeOrganizerFormAsset: vi.fn(),
  getPublicOrganizerForm,
  saveOrganizerFormResponseDraft: vi.fn(),
  sendPublicFormEmailSignInLink: vi.fn(),
  submitOrganizerFormResponse: vi.fn(),
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
