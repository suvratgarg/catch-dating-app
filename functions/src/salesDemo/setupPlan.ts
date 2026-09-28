import {createHash} from "node:crypto";
import {organizerFormTemplateReview} from "../organizers/organizerForms";
import {fail, id, only, record, text} from "./model";

export type SetupPlan = {mode: "manual"; requirements: string[]} | {
  mode: "template"; requirements: string[]; templateId: string;
  templateVersion: number; templateHash: string; materializerVersion: 1;
  title: string;
};

/** Free-text mappings never authorize question structure or publication. */
export function reviewedSetupPlan(raw: unknown): SetupPlan {
  if (raw === undefined) {
    return {mode: "manual", requirements: [
      "Review your requirements with the Catch team before creating a form."]};
  }
  const input = record(raw);
  only(input, ["mode", "requirements", "templateId", "title"]);
  if (!Array.isArray(input.requirements) || input.requirements.length > 12) {
    return fail("invalid-argument", "List up to twelve manual setup steps.");
  }
  const requirements = input.requirements.map(text);
  if (input.mode === "manual") {
    if (input.templateId !== undefined || input.title !== undefined ||
        requirements.length === 0) {
      return fail("invalid-argument", "Manual setup needs explicit steps.");
    }
    return {mode: "manual", requirements};
  }
  if (input.mode !== "template") {
    return fail("invalid-argument", "Choose a supported setup mode.");
  }
  const template = organizerFormTemplateReview(id(input.templateId));
  return {mode: "template", requirements, ...template,
    title: text(input.title)};
}

export function currentSetupPlan(plan: SetupPlan | undefined): SetupPlan {
  if (!plan) return reviewedSetupPlan(undefined);
  if (plan.mode === "template") {
    const current = organizerFormTemplateReview(plan.templateId);
    if (current.templateVersion !== plan.templateVersion ||
        current.templateHash !== plan.templateHash ||
        current.materializerVersion !== plan.materializerVersion) {
      return fail("failed-precondition",
        "The template changed. Ask for a newly reviewed setup plan.");
    }
  }
  return plan;
}

export function setupPlanHash(plan: SetupPlan): string {
  return createHash("sha256").update(JSON.stringify(plan)).digest("hex");
}
