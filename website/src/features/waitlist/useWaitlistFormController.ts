import {websiteCopy} from "@content/generated";
import {useMutation} from "@tanstack/react-query";
import {type FormEvent, useMemo, useState} from "react";
import {
  createMarketingEventId,
  trackMarketingEvent,
  type WaitlistAnalyticsPayload,
  waitlistAnalyticsPayload,
} from "../../analytics";
import type {FormStatus, FormVariant} from "../../shared/forms/types";
import {websiteQueryKeys} from "../../shared/query/queryKeys";

type JoinWaitlistBody = WaitlistAnalyticsPayload & {
  fullName: string;
  email: string;
  city: string;
  role: string;
  instagram: string;
  website: string;
};

type JoinWaitlistResponse = {
  alreadyJoined?: boolean;
  error?: string;
};

export function useWaitlistFormController(variant: FormVariant) {
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});
  const [showCustomCity, setShowCustomCity] = useState(false);
  const [hasStarted, setHasStarted] = useState(false);
  const submitMutation = useMutation({
    mutationKey: websiteQueryKeys.waitlist.submit(variant),
    mutationFn: submitJoinWaitlist,
  });

  const roleOptions = useMemo(
    () =>
      variant === "host"
        ? [
            {value: "host", label: websiteCopy["usewaitlistformcontroller_0508"]},
            {value: "both", label: websiteCopy["usewaitlistformcontroller_0509"]},
          ]
        : [
            {value: "", label: websiteCopy["usewaitlistformcontroller_0507"]},
            {value: "member", label: websiteCopy["usewaitlistformcontroller_0510"]},
            {value: "host", label: websiteCopy["usewaitlistformcontroller_0508"]},
            {value: "both", label: websiteCopy["usewaitlistformcontroller_0506"]},
          ],
    [variant]
  );

  function handleCityChange(city: string) {
    setShowCustomCity(city === "Other");
    if (!city) return;
    trackMarketingEvent("city_selected", {
      city,
      form_variant: variant,
    });
  }

  function handleRoleChange(role: string) {
    if (!role) return;
    trackMarketingEvent("role_selected", {
      form_variant: variant,
      role,
    });
  }

  function handleFormStart() {
    if (hasStarted) return;
    setHasStarted(true);
    trackMarketingEvent(
      variant === "host" ? "host_lead_started" : "waitlist_started",
      {form_variant: variant}
    );
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const payload = new FormData(form);
    const cityValue =
      payload.get("city") === "Other"
        ? String(payload.get("customCity") || "").trim()
        : String(payload.get("city") || "").trim();

    const eventId = createMarketingEventId(
      variant === "host" ? "host_lead" : "waitlist"
    );
    const conversionPayload = waitlistAnalyticsPayload(eventId, variant);
    const body = {
      fullName: String(payload.get("fullName") || "").trim(),
      email: String(payload.get("email") || "").trim(),
      city: cityValue,
      role: String(payload.get("role") || "").trim(),
      instagram: String(payload.get("instagram") || "").trim(),
      website: String(payload.get("website") || "").trim(),
      ...conversionPayload,
    };

    if (!body.fullName || !body.email || !body.city || !body.role) {
      setStatus({
        message: websiteCopy["usewaitlistformcontroller_0511"],
        tone: "is-error",
      });
      return;
    }

    setStatus({message: "", tone: ""});
    trackMarketingEvent(
      variant === "host" ? "host_lead_submit_attempt" : "waitlist_submit_attempt",
      {city: body.city, event_id: eventId, form_variant: variant, role: body.role}
    );

    try {
      const data = await submitMutation.mutateAsync(body);
      form.reset();
      setShowCustomCity(false);
      setHasStarted(false);
      setStatus({
        message: data.alreadyJoined
          ? "You're already on the list. We refreshed your details."
          : "You're in. We'll reach out when Catch opens in your city.",
        tone: "is-success",
      });
      trackMarketingEvent(
        variant === "host" ? "host_lead_submitted" : "waitlist_submitted",
        {
          already_joined: Boolean(data.alreadyJoined),
          city: body.city,
          event_id: eventId,
          form_variant: variant,
          role: body.role,
        }
      );
      trackMarketingEvent("generate_lead", {
        city: body.city,
        event_id: eventId,
        form_variant: variant,
        lead_type: variant === "host" ? "host" : "member",
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error
            ? error.message
            : "We couldn't save your spot. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("lead_submit_error", {
        event_id: eventId,
        form_variant: variant,
      });
    }
  }

  return {
    handleCityChange,
    handleFormStart,
    handleRoleChange,
    handleSubmit,
    isSubmitting: submitMutation.isPending,
    roleOptions,
    showCustomCity,
    status,
  };
}

async function submitJoinWaitlist(body: JoinWaitlistBody): Promise<JoinWaitlistResponse> {
  const response = await fetch("/api/join-waitlist", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(body),
  });
  const data = (await response.json().catch(() => ({}))) as JoinWaitlistResponse;

  if (!response.ok) {
    throw new Error(
      typeof data.error === "string"
        ? data.error
        : "We couldn't save your spot. Please try again."
    );
  }

  return data;
}
