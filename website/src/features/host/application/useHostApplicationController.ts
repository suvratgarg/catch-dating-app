import {websiteCopy} from "@content/generated";
import {useMutation} from "@tanstack/react-query";
import {type FormEvent, useRef, useState} from "react";
import {
  createMarketingEventId,
  trackMarketingEvent,
  type WaitlistAnalyticsPayload,
  waitlistAnalyticsPayload,
} from "../../../analytics";
import type {FormStatus} from "../../../shared/forms/types";
import {usePendingRequestRegistration} from "../../../shared/pendingRequest";
import {websiteQueryKeys} from "../../../shared/query/queryKeys";
import {
  hostApplicationIsComplete,
  hostApplicationStepError,
  hostApplicationStepIsComplete,
  hostApplicationSteps,
  initialHostApplicationDraft,
  type HostApplicationDraft,
  type HostApplicationStep,
} from "./applicationModel";

type HostApplicationSubmitBody = WaitlistAnalyticsPayload & {
  fullName: string;
  email: string;
  city: string;
  role: "host";
  instagram: string;
  website: string;
  hostApplication: {
    organizationName: string;
    organizationType: string;
    operatingCity: string;
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
  };
};

type HostApplicationSubmitResponse = {
  alreadyJoined?: boolean;
  error?: string;
};

export function useHostApplicationController() {
  const [draft, setDraft] = useState<HostApplicationDraft>(initialHostApplicationDraft);
  const [step, setStep] = useState<HostApplicationStep>("profile");
  const [hasStarted, setHasStarted] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});
  const submitMutation = useMutation({
    mutationKey: websiteQueryKeys.hostApplications.submit(),
    mutationFn: submitHostApplication,
  });
  const submissionInFlight =
    useRef<Promise<HostApplicationSubmitResponse> | null>(null);
  usePendingRequestRegistration(submitMutation.isPending);

  const currentStepIndex = hostApplicationSteps.findIndex((item) => item.id === step);
  const resolvedCity = draft.city === "Other" ? draft.customCity.trim() : draft.city;
  const canContinue = hostApplicationStepIsComplete(step, draft);

  function updateDraft<K extends keyof HostApplicationDraft>(
    key: K,
    value: HostApplicationDraft[K]
  ) {
    if (submissionInFlight.current) return;
    setDraft((current) => ({...current, [key]: value}));
  }

  function toggleDraftList(key: "formats" | "eventSuccessModules", value: string) {
    if (submissionInFlight.current) return;
    setDraft((current) => {
      const values = current[key];
      const next = values.includes(value)
        ? values.filter((item) => item !== value)
        : [...values, value];
      return {...current, [key]: next};
    });
  }

  function handleFormStart() {
    if (submissionInFlight.current) return;
    if (hasStarted) return;
    setHasStarted(true);
    trackMarketingEvent("host_operating_application_started", {
      form_variant: "host",
    });
  }

  function goToStep(nextStep: HostApplicationStep) {
    if (submissionInFlight.current) return;
    setStep(nextStep);
  }

  function goNext() {
    if (submissionInFlight.current) return;
    if (!canContinue) {
      setStatus({
        message: hostApplicationStepError(step),
        tone: "is-error",
      });
      return;
    }
    const next = hostApplicationSteps[currentStepIndex + 1];
    if (next) {
      setStatus({message: "", tone: ""});
      setStep(next.id);
    }
  }

  function goBack() {
    if (submissionInFlight.current) return;
    const previous = hostApplicationSteps[currentStepIndex - 1];
    if (previous) setStep(previous.id);
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (submissionInFlight.current) return;
    if (!hostApplicationIsComplete(draft)) {
      setStatus({
        message: websiteCopy["usehostapplicationcontroller_0266"],
        tone: "is-error",
      });
      return;
    }

    const eventId = createMarketingEventId("host_lead");
    const conversionPayload = waitlistAnalyticsPayload(eventId, "host");
    const body = {
      fullName: draft.fullName.trim(),
      email: draft.email.trim(),
      city: resolvedCity,
      role: "host" as const,
      instagram: draft.communityLink.trim(),
      website: "",
      hostApplication: {
        organizationName: draft.organizationName.trim(),
        organizationType: draft.organizationType,
        operatingCity: resolvedCity,
        communityLink: draft.communityLink.trim(),
        formats: draft.formats,
        eventCadence: draft.eventCadence,
        nextEventName: draft.nextEventName.trim(),
        nextEventDate: draft.nextEventDate,
        eventLocation: draft.eventLocation.trim(),
        expectedCapacity: draft.expectedCapacity,
        priceRange: draft.priceRange,
        admissionModel: draft.admissionModel,
        waitlistPlan: draft.waitlistPlan,
        paymentReadiness: draft.paymentReadiness,
        eventSuccessModules: draft.eventSuccessModules,
        hostGoals: draft.hostGoals.trim(),
        operatingNotes: draft.operatingNotes.trim(),
      },
      ...conversionPayload,
    };

    setStatus({message: "", tone: ""});
    trackMarketingEvent("host_application_submit_attempt", {
      city: body.city,
      event_id: eventId,
      format_count: draft.formats.length,
      module_count: draft.eventSuccessModules.length,
    });

    const request = submitMutation.mutateAsync(body);
    submissionInFlight.current = request;
    try {
      const data = await request;
      setSubmitted(true);
      setStatus({
        message: data.alreadyJoined
          ? "Application updated. Catch refreshed your operating packet."
          : "Application submitted. Catch will review the host packet before onboarding.",
        tone: "is-success",
      });
      trackMarketingEvent("host_operating_application_submitted", {
        already_joined: Boolean(data.alreadyJoined),
        city: body.city,
        event_id: eventId,
        format_count: draft.formats.length,
        module_count: draft.eventSuccessModules.length,
      });
      trackMarketingEvent("generate_lead", {
        city: body.city,
        event_id: eventId,
        form_variant: "host",
        lead_type: "host",
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "We couldn't submit the host application. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("host_operating_application_submit_error", {
        event_id: eventId,
      });
    } finally {
      if (submissionInFlight.current === request) {
        submissionInFlight.current = null;
      }
    }
  }

  return {
    canContinue,
    currentStepIndex,
    draft,
    goBack,
    goNext,
    goToStep,
    handleFormStart,
    handleSubmit,
    isSubmitting: submitMutation.isPending,
    resolvedCity,
    status,
    step,
    submitted,
    toggleDraftList,
    updateDraft,
  };
}

async function submitHostApplication(
  body: HostApplicationSubmitBody
): Promise<HostApplicationSubmitResponse> {
  const response = await fetch("/api/join-waitlist", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(body),
  });
  const data = (await response.json().catch(() => ({}))) as
    HostApplicationSubmitResponse;

  if (!response.ok) {
    throw new Error(
      typeof data.error === "string"
        ? data.error
        : "We couldn't submit the host application. Please try again."
    );
  }

  return data;
}
