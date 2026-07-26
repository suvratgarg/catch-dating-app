import type {Dispatch, SetStateAction} from "react";

import {
  AdminFieldGrid,
  AdminOrganizerIntakeCheckboxField,
  SelectField,
} from "../../../../shared/ui/AdminPrimitives";
import type * as Intake from "../types/organizerIntakeTypes";

function OrganizerVisibilityControls({
  checklist,
  entityId,
  form,
  setChecklists,
  setForms,
}: {
  checklist: Intake.OrganizerSurfaceChecklistState;
  entityId: string;
  form: Intake.OrganizerVisibilityFormState;
  setChecklists: Dispatch<SetStateAction<
    Record<string, Intake.OrganizerSurfaceChecklistState>
  >>;
  setForms: Dispatch<SetStateAction<
    Record<string, Intake.OrganizerVisibilityFormState>
  >>;
}) {
  const updateChecklist = (
    field: keyof Intake.OrganizerSurfaceChecklistState,
    checked: boolean
  ) => setChecklists((current) => ({
    ...current,
    [entityId]: {...checklist, [field]: checked},
  }));
  const anyVisible =
    form.publishStatus === "published" ||
    form.indexStatus === "indexed" ||
    form.appVisibility === "discoverable";

  return (
    <>
      <AdminFieldGrid>
        <SelectField
          label="Public web"
          options={[
            {value: "draft", label: "Off — keep draft"},
            {value: "published", label: "On — publish page"},
          ]}
          value={form.publishStatus === "suppressed" ?
            "draft" :
            form.publishStatus}
          onChange={(publishStatus) =>
            setForms((current) => ({
              ...current,
              [entityId]: {
                ...form,
                publishStatus: publishStatus as "draft" | "published",
                indexStatus: publishStatus === "published" ?
                  form.indexStatus :
                  "noindex",
              },
            }))}
        />
        <SelectField
          label="Search indexing"
          options={[
            {value: "noindex", label: "Off — noindex"},
            {value: "indexed", label: "On — index"},
          ]}
          value={form.indexStatus}
          onChange={(indexStatus) =>
            setForms((current) => ({
              ...current,
              [entityId]: {
                ...form,
                indexStatus: indexStatus as "noindex" | "indexed",
              },
            }))}
        />
        <SelectField
          label="App discovery"
          options={[
            {value: "hidden", label: "Off — hidden"},
            {value: "discoverable", label: "On — discoverable"},
          ]}
          value={form.appVisibility}
          onChange={(appVisibility) =>
            setForms((current) => ({
              ...current,
              [entityId]: {
                ...form,
                appVisibility: appVisibility as "hidden" | "discoverable",
              },
            }))}
        />
      </AdminFieldGrid>
      {anyVisible ? (
        <>
          <SurfaceCheck
            checked={checklist.claimTargetReviewed}
            label="Claim target is present and owner-safe"
            onChange={(checked) =>
              updateChecklist("claimTargetReviewed", checked)}
          />
          <SurfaceCheck
            checked={checklist.takedownPathReviewed}
            label="Takedown path is available"
            onChange={(checked) =>
              updateChecklist("takedownPathReviewed", checked)}
          />
          <SurfaceCheck
            checked={checklist.impersonationReviewed}
            label="Identity does not impersonate another organizer"
            onChange={(checked) =>
              updateChecklist("impersonationReviewed", checked)}
          />
        </>
      ) : null}
      {form.appVisibility === "discoverable" ? (
        <>
          <SurfaceCheck
            checked={checklist.operatingStatusReviewed}
            label="Organizer is currently operating"
            onChange={(checked) =>
              updateChecklist("operatingStatusReviewed", checked)}
          />
          <SurfaceCheck
            checked={checklist.eventAccuracyReviewed}
            label="Current event time and place are accurate"
            onChange={(checked) =>
              updateChecklist("eventAccuracyReviewed", checked)}
          />
          <SurfaceCheck
            checked={checklist.unclaimedAffordancesReviewed}
            label="Unclaimed listing has no booking or host-contact actions"
            onChange={(checked) =>
              updateChecklist("unclaimedAffordancesReviewed", checked)}
          />
        </>
      ) : null}
    </>
  );
}

function SurfaceCheck({
  checked,
  label,
  onChange,
}: {
  checked: boolean;
  label: string;
  onChange: (checked: boolean) => void;
}) {
  return (
    <AdminOrganizerIntakeCheckboxField
      checked={checked}
      label={label}
      onChange={onChange}
    />
  );
}

export const organizerIntakeVisibilityControls = {
  OrganizerVisibilityControls,
};
