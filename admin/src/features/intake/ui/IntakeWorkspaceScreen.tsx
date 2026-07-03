import {useState, type ReactNode} from "react";
import {
  AdminIntakePublicationBoundaryPanel,
  AdminIntakeWorkspaceHeader,
  AdminIntakeWorkspaceTabs,
} from "../../../shared/ui/AdminPrimitives";
import {EventIntakeWorkspace} from "../events/ui/EventIntakeWorkspace";
import {OrganizerIntakeScreen} from "../organizer/ui/OrganizerIntakeScreen";

export type IntakeWorkspaceTab = "events" | "organizers";

const intakeWorkspaceTabs: Array<{id: IntakeWorkspaceTab; label: string}> = [
  {id: "events", label: "Event leads"},
  {id: "organizers", label: "Organizers"},
];

export function IntakeWorkspaceScreen() {
  const [activeWorkspace, setActiveWorkspace] =
    useState<IntakeWorkspaceTab>("events");
  return (
    <IntakeWorkspace
      activeWorkspace={activeWorkspace}
      eventsContent={<EventIntakeWorkspace />}
      organizersContent={<OrganizerIntakeScreen />}
      onWorkspaceChange={setActiveWorkspace}
    />
  );
}

export function IntakeWorkspace({
  activeWorkspace,
  eventsContent,
  onWorkspaceChange,
  organizersContent,
}: {
  activeWorkspace: IntakeWorkspaceTab;
  eventsContent: ReactNode;
  onWorkspaceChange: (workspace: IntakeWorkspaceTab) => void;
  organizersContent: ReactNode;
}) {
  return (
    <>
      <AdminIntakeWorkspaceHeader
        actions={(
          <AdminIntakeWorkspaceTabs
            ariaLabel="Intake workspace"
            options={intakeWorkspaceTabs}
            value={activeWorkspace}
            onChange={onWorkspaceChange}
          />
        )}
        eyebrow="Intake workspace"
        title={activeWorkspace === "events" ? "Event intake" : "Organizer intake"}
      >
        {activeWorkspace === "events" ?
          "Search-source setup, raw lead review, candidate editing, and event-owned review decisions before external import planning or Marketing consume these records." :
          "Organizer discovery, evidence review, curation, publication readiness, and claim handoff."}
      </AdminIntakeWorkspaceHeader>
      <AdminIntakePublicationBoundaryPanel activeWorkspace={activeWorkspace} />
      {activeWorkspace === "events" ? eventsContent : organizersContent}
    </>
  );
}
