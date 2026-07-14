import {useState, type ReactNode} from "react";
import {useLocation, useNavigate} from "react-router";
import {
  AdminIntakeBoundaryNotice,
  AdminIntakePublicationBoundaryPanel,
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
  const location = useLocation();
  const navigate = useNavigate();
  const activeWorkspace = intakeWorkspaceForPath(location.pathname);
  return (
    <IntakeWorkspace
      activeWorkspace={activeWorkspace}
      eventsContent={<EventIntakeWorkspace />}
      organizersContent={<OrganizerIntakeScreen />}
      onWorkspaceChange={(workspace) => navigate(`/intake/${workspace}`)}
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
  const [showBoundaryDetails, setShowBoundaryDetails] = useState(false);
  const isEvents = activeWorkspace === "events";
  const content = isEvents ? eventsContent : organizersContent;
  return (
    <>
      <AdminIntakeWorkspaceTabs
        ariaLabel="Intake workspace"
        options={intakeWorkspaceTabs}
        value={activeWorkspace}
        onChange={onWorkspaceChange}
      />
      <AdminIntakeBoundaryNotice
        actionLabel={showBoundaryDetails ? "Hide details" : "View boundary"}
        title={isEvents ?
          "Approval records an intake decision—it does not publish an event." :
          "Approval creates a publishing handoff—not ownership or app visibility."}
        onAction={() => setShowBoundaryDetails((current) => !current)}
      >
        {isEvents ?
          "Canonical events, external-event promotion, bookings, and payments stay separately gated." :
          "Claims, app discovery, crawling, and canonical edits stay separately gated."}
      </AdminIntakeBoundaryNotice>
      {showBoundaryDetails ? (
        <AdminIntakePublicationBoundaryPanel activeWorkspace={activeWorkspace} />
      ) : null}
      {content}
    </>
  );
}

function intakeWorkspaceForPath(pathname: string): IntakeWorkspaceTab {
  if (pathname.startsWith("/intake/events")) return "events";
  return "organizers";
}
