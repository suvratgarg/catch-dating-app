import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {MemoryRouter} from "react-router";
import {afterEach, describe, expect, it, vi} from "vitest";
import type {PublicFormQuestion} from "./publicFormModel";

const usePublicFormController = vi.hoisted(() => vi.fn());
vi.mock("./usePublicFormController", () => ({usePublicFormController}));
import {PublicFormPage} from "./PublicFormPage";

afterEach(() => { cleanup(); vi.unstubAllEnvs(); });

const cities = ["Mumbai", "Bangalore", "Hyderabad", "Ahmedabad", "Dubai"];
const city = {
  questionId: "city", label: "Event city", kind: "singleChoice", required: true,
  options: cities.map((value) => ({optionId: value, value, label: value})),
  validation: {},
} as PublicFormQuestion;

function renderForm(question = city, answer?: string,
  cityOptions?: Array<{marketId: string; cityId: string; label: string;
    regionName: string; countryIsoCode: string}>) {
  const updateAnswer = vi.fn();
  const blurQuestion = vi.fn();
  const section = {title: "Your city", questions: [question]};
  usePublicFormController.mockReturnValue({
    stage: "form", form: {organizer: {name: "Saket Run Club"}, cityOptions, definition: {
      title: "RSVP Escape — demo", appearance: {preset: "editorial"},
      sections: [section],
    }}, activeSection: section, visibleSections: [section], sectionIndex: 0,
    answers: {city: answer}, errors: {}, uploads: {}, updateAnswer,
    blurQuestion,
    status: {message: "", tone: ""},
  });
  render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
  return Object.assign(updateAnswer, {blurQuestion});
}

describe("public form choices", () => {
  it("uses canonical market ids for reusable Catch city answers", () => {
    const change = renderForm({...city, kind: "shortText", options: [],
      canonicalFieldId: "city", answerDestination: "catchProfile",
      label: "Where do you live?"}, "in-mh-mumbai", [{
      marketId: "in-mh-mumbai", cityId: "in-mh-mumbai", label: "Mumbai",
      regionName: "Maharashtra", countryIsoCode: "IN",
    }]);
    const select = screen.getByRole("combobox", {name: "Where do you live?"});
    expect((select as HTMLSelectElement).value).toBe("in-mh-mumbai");
    expect(screen.getByRole("option", {name: "Mumbai, Maharashtra"})).toBeTruthy();
    fireEvent.change(select, {target: {value: "in-mh-mumbai"}});
    expect(change).toHaveBeenCalledWith("city", "in-mh-mumbai");
  });
  it("shows an India country picker instead of asking people to type +91", () => {
    const change = renderForm({...city, label: "Phone number", kind: "phone",
      options: [], canonicalFieldId: null}, "+919876543210");
    const number = screen.getByRole("textbox", {name: "Phone number"}) as HTMLInputElement;
    const country = screen.getByRole("combobox", {name: "Country code"}) as HTMLSelectElement;
    expect(country.value).toBe("+91");
    expect(number.value).toBe("9876543210");
    fireEvent.change(number, {target: {value: "9876543211"}});
    expect(change).toHaveBeenCalledWith("city", "+919876543211");
  });

  it("puts phone verification within the first page without duplicating the phone field", () => {
    const updateAnswer = vi.fn();
    const setPhoneNumber = vi.fn();
    const question = {...city, questionId: "mobile", label: "Mobile number",
      kind: "phone", options: [], canonicalFieldId: "phoneNumber"} as PublicFormQuestion;
    const section = {sectionId: "details", title: "Your details", questions: [question]};
    usePublicFormController.mockReturnValue({
      stage: "form", form: {organizer: {name: "Saket Run Club"}, definition: {
        title: "RSVP Escape", appearance: {preset: "editorial"},
        identityPolicy: "phoneVerified", sections: [section],
      }}, activeSection: section, visibleSections: [section], sectionIndex: 0,
      answers: {}, errors: {mobile: "Mobile number is required."}, uploads: {}, updateAnswer,
      blurQuestion: vi.fn(), setPhoneNumber, phoneNumber: "",
      verifiedPhone: null, verificationStep: "phone", pending: false,
      recaptchaContainerId: "test-recaptcha", status: {message: "", tone: ""},
    });
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    expect(screen.getAllByRole("textbox", {name: "Mobile number"})).toHaveLength(1);
    expect(screen.getByRole("alert").textContent).toBe("Mobile number is required.");
    expect(screen.getByRole("button", {name: "Send code"})).toBeTruthy();
    fireEvent.change(screen.getByRole("textbox", {name: "Mobile number"}),
      {target: {value: "9876543210"}});
    expect(setPhoneNumber).toHaveBeenCalledWith("+919876543210");
    expect(updateAnswer).toHaveBeenCalledWith("mobile", "+919876543210");
  });

  it("requests validation when a field loses focus", () => {
    const change = renderForm(city);
    fireEvent.blur(screen.getByRole("combobox", {name: "Event city"}));
    expect(change.blurQuestion).toHaveBeenCalledWith("city");
  });
  it("renders all five cities in an accessible dropdown and preserves values", () => {
    const change = renderForm(city, "Mumbai");
    const select = screen.getByRole("combobox", {name: "Event city"});
    expect((select as HTMLSelectElement).value).toBe("Mumbai");
    expect(screen.getAllByRole("option")).toHaveLength(6);
    fireEvent.change(select, {target: {value: "Dubai"}});
    expect(change).toHaveBeenCalledWith("city", "Dubai");
    fireEvent.change(select, {target: {value: ""}});
    expect(change).toHaveBeenLastCalledWith("city", null);
  });

  it("keeps short choices visible as buttons", () => {
    renderForm({...city, options: city.options.slice(0, 2)});
    expect(screen.queryByRole("combobox")).toBeNull();
    expect(screen.getByRole("button", {name: "Mumbai"})).not.toBeNull();
  });

  it("labels optional questions and does not give them native required validation", () => {
    renderForm({...city, required: false});
    expect(screen.getByText("optional")).not.toBeNull();
    expect(screen.queryByText("required")).toBeNull();
    expect((screen.getByRole("combobox") as HTMLSelectElement).required).toBe(false);
  });

  it("keeps legacy canonical mappings organizer-only", () => {
    renderForm({...city, canonicalFieldId: "city"});
    expect(screen.getByText("Answers are sent only to the organizer named above.")).not.toBeNull();
    expect(screen.queryByText(/Saved privately until you claim/u)).toBeNull();
  });

  it("explains profile preparation and the claim-and-share boundary", () => {
    renderForm({...city, answerDestination: "catchProfile"});
    expect(screen.getByText(/Catch profile field\. Saved privately/u)).not.toBeNull();
    expect(screen.getByText(/Other users can see only the fields you choose/u)).not.toBeNull();
    expect(screen.queryByText("Answers are sent only to the organizer named above.")).toBeNull();
  });

  it("distinguishes organizer cards from the core profile", () => {
    renderForm({...city, answerDestination: "organizerCard"});
    expect(screen.getByText(/Organizer card field\. Private to you and this organizer/u)).not.toBeNull();
    expect(screen.queryByText(/Catch profile field\./u)).toBeNull();
  });
});

describe("embedded public form resize", () => {
  it("sends dimensions only as the form grows and shrinks", () => {
    const postMessage = vi.fn();
    const originalParent = window.parent;
    const originalReferrer = Object.getOwnPropertyDescriptor(document, "referrer");
    const originalResizeObserver = globalThis.ResizeObserver;
    const originalRect = HTMLElement.prototype.getBoundingClientRect;
    let notify: (() => void) | undefined;
    let height = 780;
    try {
      Object.defineProperty(window, "parent", {value: {postMessage}, configurable: true});
      Object.defineProperty(document, "referrer", {value: "https://client.example/apply",
        configurable: true});
      window.history.replaceState({}, "", "/f/public-form-1/?embed=1&embedId=frame_1");
      globalThis.ResizeObserver = class {
        constructor(callback: ResizeObserverCallback) { notify = () => callback([], this); }
        observe() {}
        disconnect() {}
        unobserve() {}
      };
      HTMLElement.prototype.getBoundingClientRect = () => ({height} as DOMRect);
      usePublicFormController.mockReturnValue({embed: true, stage: "loading",
        form: null, status: {message: "", tone: ""}});
      render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
      expect(postMessage).toHaveBeenCalledWith({
        type: "catch:form:resize", version: 1, embedId: "frame_1", height: 780,
      }, "https://client.example");
      height = 420;
      notify?.();
      expect(postMessage).toHaveBeenLastCalledWith({
        type: "catch:form:resize", version: 1, embedId: "frame_1", height: 420,
      }, "https://client.example");
      expect(JSON.stringify(postMessage.mock.calls)).not.toMatch(/answer|draftToken|sourceToken/u);
    } finally {
      Object.defineProperty(window, "parent", {value: originalParent, configurable: true});
      if (originalReferrer) Object.defineProperty(document, "referrer", originalReferrer);
      globalThis.ResizeObserver = originalResizeObserver;
      HTMLElement.prototype.getBoundingClientRect = originalRect;
      window.history.replaceState({}, "", "/");
    }
  });
});

describe("public form payment", () => {
  it("offers recovery on a closed form without implying a new submission", () => {
    const recoverPayment = vi.fn();
    usePublicFormController.mockReturnValue({stage: "unavailable",
      form: {organizer: {name: "RSVP"}, definition: {sections: [],
        appearance: {preset: "minimal"}}}, status: {message: "", tone: ""}, recoverPayment});
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    fireEvent.click(screen.getByRole("button", {name: "Check an existing payment"}));
    expect(recoverPayment).toHaveBeenCalledOnce();
    expect(screen.queryByRole("button", {name: /Pay ₹/u})).toBeNull();
  });

  it("recovery requests the original phone even after the form changed to anonymous", () => {
    usePublicFormController.mockReturnValue({stage: "identity", recoveringPayment: true,
      form: {organizer: {name: "RSVP"}, definition: {sections: [], identityPolicy: "anonymous",
        appearance: {preset: "minimal"}}}, status: {message: "", tone: ""}, phoneNumber: "",
      setPhoneNumber: vi.fn(), handlePhoneSubmit: vi.fn()});
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    expect(screen.getByRole("heading", {name: "Find your payment"})).not.toBeNull();
    expect(screen.getByRole("textbox", {name: "Mobile number"})).not.toBeNull();
    expect(screen.getByText(/This does not start another payment/u)).not.toBeNull();
  });
  function renderPayment(status: string, checkout = true) {
    const pay = vi.fn();
    const refresh = vi.fn();
    usePublicFormController.mockReturnValue({stage: "payment",
      form: {organizer: {name: "RSVP"}, definition: {sections: [],
        appearance: {preset: "minimal"}, payment: {amountPaise: 20000,
          refundPolicy: "Refunded if cancelled"}}},
      status: {message: "", tone: ""}, pending: false,
      payments: {pay, refresh, pending: false, status: {message: "", tone: ""},
        payment: {status, checkout: checkout ? {} : null, mode: "test",
          amountPaise: 20000, refundPolicy: "Refunded if cancelled"}},
    });
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    return {pay, refresh};
  }

  it("shows the fee, refund policy and admission boundary before checkout", () => {
    const {pay} = renderPayment("checkoutReady");
    expect(screen.getByText("Refunded if cancelled")).not.toBeNull();
    expect(screen.getByText(/Payment does not guarantee acceptance/u)).not.toBeNull();
    expect(screen.getByText(/Test checkout/u)).not.toBeNull();
    fireEvent.click(screen.getByRole("button", {name: "Pay ₹200 and submit"}));
    expect(pay).toHaveBeenCalledWith("RSVP");
  });

  it("withholds payment and completion controls while verification is uncertain", () => {
    const {refresh} = renderPayment("orderUnknown", false);
    expect(screen.queryByRole("button", {name: /Pay ₹/u})).toBeNull();
    expect(screen.queryByText("Response received")).toBeNull();
    expect(screen.queryByRole("button", {name: "Start a new response"})).toBeNull();
    fireEvent.click(screen.getByRole("button", {name: "Check payment status"}));
    expect(refresh).toHaveBeenCalledOnce();
  });
});

describe("review messaging choices", () => {
  it("shows two independent unchecked optional controls using the server's copy", () => {
    const updateMessagingChoice = vi.fn();
    usePublicFormController.mockReturnValue({stage: "review", answers: {},
      form: {organizer: {name: "RSVP"}, messagingOffer: {
        termsVersion: "form-whatsapp-v1", organizerWhatsapp: "From RSVP on WhatsApp (optional)",
        catchWhatsapp: "From Catch on WhatsApp (optional)",
      }, definition: {title: "Application", appearance: {preset: "minimal"}, sections: [],
        consent: {retentionCopy: "Keep until withdrawal", consentCopy: "Share answers"}}},
      visibleSections: [], consentAccepted: true,
      messagingChoices: {organizerWhatsapp: false, catchWhatsapp: false},
      updateMessagingChoice, status: {message: "", tone: ""}, pending: false,
    });
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    for (const name of ["From RSVP on WhatsApp (optional)", "From Catch on WhatsApp (optional)"]) {
      const input = screen.getByRole("checkbox", {name}) as HTMLInputElement;
      expect(input.checked).toBe(false);
      expect(input.required).toBe(false);
    }
    fireEvent.click(screen.getByRole("checkbox", {name: "From Catch on WhatsApp (optional)"}));
    expect(updateMessagingChoice).toHaveBeenCalledWith("catchWhatsapp", true);
    expect(screen.getByText(/These choices do not affect your application or payment/u)).not.toBeNull();
  });

  it("keeps all three v2 purposes separate and optional", () => {
    const updateMessagingChoice = vi.fn();
    usePublicFormController.mockReturnValue({stage: "review", answers: {},
      form: {organizer: {name: "RSVP"}, messagingOffer: {
        termsVersion: "form-whatsapp-v2", organizerWhatsapp: null,
        catchWhatsapp: null, organizerOperationsWhatsapp: "Application updates",
        organizerMarketingWhatsapp: "Organizer future events",
        catchMarketingWhatsapp: "Catch future experiences",
      }, definition: {title: "Application", appearance: {preset: "minimal"},
        sections: [], consent: {retentionCopy: "Keep until withdrawal",
          consentCopy: "Share answers"}}},
      visibleSections: [], consentAccepted: true,
      messagingChoices: {organizerOperationsWhatsapp: false,
        organizerMarketingWhatsapp: false, catchMarketingWhatsapp: false},
      messagingEndpointAvailable: true, updateMessagingChoice,
      status: {message: "", tone: ""}, pending: false,
    });
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    for (const name of ["Application updates", "Organizer future events",
      "Catch future experiences"]) {
      const checkbox = screen.getByRole("checkbox", {name}) as HTMLInputElement;
      expect(checkbox.checked).toBe(false);
      expect(checkbox.required).toBe(false);
    }
    fireEvent.click(screen.getByRole("checkbox", {name: "Application updates"}));
    expect(updateMessagingChoice).toHaveBeenCalledWith(
      "organizerOperationsWhatsapp", true);
    expect(screen.getByText(/only after you verify the same mobile number/u))
      .not.toBeNull();
  });

  it("explains and disables v2 choices when no WhatsApp number is captured", () => {
    usePublicFormController.mockReturnValue({stage: "review", answers: {},
      form: {organizer: {name: "RSVP"}, messagingOffer: {
        termsVersion: "form-whatsapp-v2", organizerOperationsWhatsapp: "Application updates",
      }, definition: {title: "Application", appearance: {preset: "minimal"},
        sections: [], consent: {retentionCopy: "Keep until withdrawal",
          consentCopy: "Share answers"}}},
      visibleSections: [], consentAccepted: true,
      messagingChoices: {organizerOperationsWhatsapp: false},
      messagingEndpointAvailable: false, status: {message: "", tone: ""},
      pending: false,
    });
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    expect((screen.getByRole("checkbox", {name: "Application updates"}) as
      HTMLInputElement).disabled).toBe(true);
    expect(screen.getByText(/leave these boxes unchecked/u)).not.toBeNull();
    expect(screen.getByRole("button", {name: "Submit response"})).not.toBeNull();
  });
});

describe("profile review after submission", () => {
  function complete(profileReviewAvailable?: boolean, paymentStatus?: string) {
    vi.stubEnv("VITE_FIREBASE_PROJECT_ID", "catch-dating-app-64e51");
    usePublicFormController.mockReturnValue({stage: "complete",
      form: {organizer: {name: "RSVP"}, definition: {
        appearance: {preset: "minimal"}, sections: [],
      }}, pending: false, status: {message: "", tone: ""},
      receipt: {responseId: "response-id", profileReviewAvailable,
        completion: {title: "Received", message: "Thank you",
          actionUrl: "https://example.test/next", actionLabel: "Organizer next step"}},
      withdraw: vi.fn(),
      payments: paymentStatus ? {payment: {status: paymentStatus}} : undefined,
    });
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
  }
  it("does not claim an existing response disappeared after a refund", () => {
    complete(false, "refunded");
    expect(screen.getByText(/Your payment was refunded\. Your response is still submitted/u)).not.toBeNull();
    expect(screen.queryByText(/No response was submitted/u)).toBeNull();
  });
  it("offers owned review alongside the organizer action and withdrawal", () => {
    complete(true);
    expect(screen.getByRole("link", {name: "Review my profile in Catch"})
      .getAttribute("href")).toBe("https://app.catchdates.com/#/you/forms/response-id");
    expect(screen.getByText(/same verified phone number/u)).not.toBeNull();
    expect(screen.getByRole("link", {name: "Organizer next step"})).not.toBeNull();
    expect(screen.getByRole("button", {name: "Withdraw response"})).not.toBeNull();
  });
  it.each([false, undefined])("does not offer a claim for a missing proposal: %s", (available) => {
    complete(available);
    expect(screen.queryByRole("link", {name: "Review my profile in Catch"})).toBeNull();
  });
});

it("offers same-number verification for a submitted v2 choice", () => {
  const startConsentPromotion = vi.fn();
  usePublicFormController.mockReturnValue({stage: "complete",
    form: {organizer: {name: "RSVP"}, messagingOffer: {
      termsVersion: "form-whatsapp-v2"}, definition: {
      appearance: {preset: "minimal"}, sections: [],
    }}, pending: false, pendingConsentResponseId: "response-id",
    status: {message: "", tone: ""},
    receipt: {responseId: "response-id", completion: {
      title: "Received", message: "Thank you"}},
    startConsentPromotion, withdraw: vi.fn(),
  });
  render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
  fireEvent.click(screen.getByRole("button", {
    name: "Verify number for WhatsApp choices"}));
  expect(startConsentPromotion).toHaveBeenCalledOnce();
});

it("does not prompt verification for unchecked or already promoted choices",
  () => {
    usePublicFormController.mockReturnValue({stage: "complete",
      form: {organizer: {name: "RSVP"}, messagingOffer: {
        termsVersion: "form-whatsapp-v2"}, definition: {
        appearance: {preset: "minimal"}, sections: [],
      }}, pending: false, pendingConsentResponseId: null,
      status: {message: "", tone: ""}, receipt: {
        responseId: "response-id", completion: {
          title: "Received", message: "Thank you"}},
      withdraw: vi.fn(),
    });
    render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
    expect(screen.queryByRole("button", {
      name: "Verify number for WhatsApp choices"})).toBeNull();
  });
