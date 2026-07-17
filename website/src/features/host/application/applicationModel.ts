import {websiteCopy} from "@content/generated";
import {activeFeaturedCity} from "@content/markets";

export type HostApplicationStep = "profile" | "event" | "policy" | "success" | "review";

export interface HostApplicationDraft {
  fullName: string;
  email: string;
  city: string;
  customCity: string;
  organizationName: string;
  organizationType: string;
  communityLink: string;
  formats: string[];
  eventCadence: string;
  nextEventName: string;
  nextEventDate: string;
  eventLocation: string;
  expectedCapacity: string;
  priceRange: string;
  admissionModel: string;
  waitlistPlan: string;
  paymentReadiness: string;
  eventSuccessModules: string[];
  hostGoals: string;
  operatingNotes: string;
}

export const hostApplicationSteps: Array<{
  id: HostApplicationStep;
  label: string;
  body: string;
}> = [
  {
    id: "profile",
    label: websiteCopy["applicationmodel_0185"],
    body: websiteCopy["applicationmodel_0204"],
  },
  {
    id: "event",
    label: websiteCopy["applicationmodel_0179"],
    body: websiteCopy["applicationmodel_0200"],
  },
  {
    id: "policy",
    label: websiteCopy["applicationmodel_0169"],
    body: websiteCopy["applicationmodel_0174"],
  },
  {
    id: "success",
    label: websiteCopy["applicationmodel_0195"],
    body: websiteCopy["applicationmodel_0180"],
  },
  {
    id: "review",
    label: websiteCopy["applicationmodel_0199"],
    body: websiteCopy["applicationmodel_0175"],
  },
];

export const hostFormatOptions = [
  websiteCopy["applicationmodel_0178"],
  websiteCopy["applicationmodel_0196"],
  websiteCopy["applicationmodel_0197"],
  websiteCopy["applicationmodel_0189"],
  websiteCopy["applicationmodel_0192"],
  websiteCopy["applicationmodel_0172"],
  websiteCopy["applicationmodel_0176"],
  websiteCopy["applicationmodel_0177"],
];

export const hostSuccessModuleOptions = [
  websiteCopy["applicationmodel_0173"],
  websiteCopy["applicationmodel_0171"],
  websiteCopy["applicationmodel_0203"],
  websiteCopy["applicationmodel_0198"],
  websiteCopy["applicationmodel_0201"],
  websiteCopy["applicationmodel_0184"],
  websiteCopy["applicationmodel_0191"],
  websiteCopy["applicationmodel_0202"],
  websiteCopy["applicationmodel_0190"],
];

export const initialHostApplicationDraft: HostApplicationDraft = {
  fullName: "",
  email: "",
  city: activeFeaturedCity.label,
  customCity: "",
  organizationName: "",
  organizationType: websiteCopy["applicationmodel_0186"],
  communityLink: "",
  formats: [websiteCopy["applicationmodel_0178"]],
  eventCadence: websiteCopy["applicationmodel_0187"],
  nextEventName: "",
  nextEventDate: "",
  eventLocation: "",
  expectedCapacity: "20",
  priceRange: "₹1,000–₹2,000",
  admissionModel: websiteCopy["applicationmodel_0194"],
  waitlistPlan: websiteCopy["applicationmodel_0193"],
  paymentReadiness: websiteCopy["applicationmodel_0188"],
  eventSuccessModules: [
    websiteCopy["applicationmodel_0171"],
    websiteCopy["applicationmodel_0203"],
    websiteCopy["applicationmodel_0191"],
  ],
  hostGoals: "",
  operatingNotes: "",
};

export function hostApplicationStepIsComplete(
  step: HostApplicationStep,
  draft: HostApplicationDraft
): boolean {
  if (step === "profile") {
    return Boolean(
      draft.fullName.trim() &&
      draft.email.trim() &&
      (draft.city !== "Other" || draft.customCity.trim()) &&
      draft.organizationName.trim() &&
      draft.communityLink.trim()
    );
  }
  if (step === "event") {
    return Boolean(
      draft.formats.length &&
      draft.nextEventName.trim() &&
      draft.eventLocation.trim()
    );
  }
  if (step === "policy") {
    return Boolean(
      draft.expectedCapacity.trim() &&
      draft.priceRange.trim() &&
      draft.admissionModel &&
      draft.waitlistPlan &&
      draft.paymentReadiness
    );
  }
  if (step === "success") {
    return Boolean(draft.eventSuccessModules.length && draft.hostGoals.trim());
  }
  return hostApplicationIsComplete(draft);
}

export function hostApplicationStepError(step: HostApplicationStep) {
  switch (step) {
    case "profile":
      return "Add your identity, organizer name, city, and public link.";
    case "event":
      return "Choose at least one format and describe the first event and location.";
    case "policy":
      return "Add capacity, pricing, admission, waitlist, and payment readiness.";
    case "success":
      return "Choose at least one Playbook module and add your host goal.";
    case "review":
      return "Finish the required fields before submitting.";
  }
}

export function hostApplicationIsComplete(draft: HostApplicationDraft): boolean {
  return hostApplicationSteps
    .filter((item) => item.id !== "review")
    .every((item) => hostApplicationStepIsComplete(item.id, draft));
}

export function hostApplicationCompleteness(draft: HostApplicationDraft) {
  const checklist = hostApplicationChecklist(draft);
  const completed = checklist.filter((item) => item.done).length;
  return Math.round((completed / checklist.length) * 100);
}

export function hostApplicationChecklist(draft: HostApplicationDraft) {
  return [
    {
      label: websiteCopy["applicationmodel_0183"],
      done: hostApplicationStepIsComplete("profile", draft),
    },
    {
      label: websiteCopy["applicationmodel_0182"],
      done: hostApplicationStepIsComplete("event", draft),
    },
    {
      label: websiteCopy["applicationmodel_0170"],
      done: hostApplicationStepIsComplete("policy", draft),
    },
    {
      label: websiteCopy["applicationmodel_0181"],
      done: hostApplicationStepIsComplete("success", draft),
    },
  ];
}
