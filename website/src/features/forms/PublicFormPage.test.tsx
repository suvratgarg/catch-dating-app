import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {MemoryRouter} from "react-router";
import {afterEach, describe, expect, it, vi} from "vitest";
import type {PublicFormQuestion} from "./publicFormModel";

const usePublicFormController = vi.hoisted(() => vi.fn());
vi.mock("./usePublicFormController", () => ({usePublicFormController}));
import {PublicFormPage} from "./PublicFormPage";

afterEach(cleanup);

const cities = ["Mumbai", "Bangalore", "Hyderabad", "Ahmedabad", "Dubai"];
const city = {
  questionId: "city", label: "Event city", kind: "singleChoice", required: true,
  options: cities.map((value) => ({optionId: value, value, label: value})),
  validation: {},
} as PublicFormQuestion;

function renderForm(question = city, answer?: string) {
  const updateAnswer = vi.fn();
  const section = {title: "Your city", questions: [question]};
  usePublicFormController.mockReturnValue({
    stage: "form", form: {organizer: {name: "Saket Run Club"}, definition: {
      title: "RSVP Escape — demo", appearance: {preset: "editorial"},
      sections: [section],
    }}, activeSection: section, visibleSections: [section], sectionIndex: 0,
    answers: {city: answer}, errors: {}, uploads: {}, updateAnswer,
    status: {message: "", tone: ""},
  });
  render(<MemoryRouter><PublicFormPage /></MemoryRouter>);
  return updateAnswer;
}

describe("public form choices", () => {
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

describe("public form payment", () => {
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
});
