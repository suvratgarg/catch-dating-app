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
