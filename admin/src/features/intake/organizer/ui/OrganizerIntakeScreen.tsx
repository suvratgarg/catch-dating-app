import {lazy, Suspense, useState} from "react";
import {useNavigate} from "react-router";

import {
  AdminButton,
  AdminIntakeReviewWorkbench,
  AdminToolbar,
  AdminWorkbenchNote,
} from "../../../../shared/ui/AdminPrimitives";
import {useAdminFeedback} from
  "../../../../shared/feedback/AdminFeedbackContext";
import {
  type OrganizerIntakeController,
  useOrganizerIntakeController,
} from "../controllers/useOrganizerIntakeController";
import {organizerIntakeWorkbench} from "./organizerIntakeWorkbench";

const LazyOrganizerIntakeDiagnostics = lazy(async () => {
  const module = await import("./organizerIntakeDiagnostics");
  return {
    default: module.organizerIntakeDiagnostics.OrganizerIntakeDiagnostics,
  };
});

export function OrganizerIntakeScreen() {
  return (
    <Suspense
      fallback={(
        <AdminIntakeReviewWorkbench
          detail={null}
          items={[]}
          queueMeta="Loading live projection"
          queueTitle="Organizer intake"
          readOnly
          selectedId={null}
          state="loading"
          onSelect={() => undefined}
        />
      )}
    >
      <OrganizerIntakeLoadedScreen />
    </Suspense>
  );
}

function OrganizerIntakeLoadedScreen() {
  const navigate = useNavigate();
  const {setError: onError, setNotice: onNotice} = useAdminFeedback();
  const controller = useOrganizerIntakeController({
    onError,
    onNotice,
    onOrganizerDraftCreated: (organizerId) =>
      navigate(`/organizers/${encodeURIComponent(organizerId)}`),
  });
  return <OrganizerIntakeWorkspace controller={controller} />;
}

export function OrganizerIntakeWorkspace({
  controller,
  nowMs,
}: {
  controller: OrganizerIntakeController;
  nowMs?: number;
}) {
  const [showDiagnostics, setShowDiagnostics] = useState(false);
  if (!showDiagnostics) {
    return (
      <organizerIntakeWorkbench.OrganizerTaskWorkbench
        controller={controller}
        nowMs={nowMs}
        onShowDiagnostics={() => setShowDiagnostics(true)}
      />
    );
  }
  if (!controller.diagnosticsBridge) {
    return (
      <organizerIntakeWorkbench.OrganizerTaskWorkbench
        controller={controller}
        nowMs={nowMs}
        onShowDiagnostics={() => setShowDiagnostics(false)}
      />
    );
  }
  return (
    <>
      <AdminToolbar>
        <AdminWorkbenchNote>
          Diagnostics preserves generated pipeline, policy, crawl, curation,
          and import evidence without forcing it into the daily decision path.
        </AdminWorkbenchNote>
        <AdminButton onClick={() => setShowDiagnostics(false)}>
          Back to review queue
        </AdminButton>
      </AdminToolbar>
      <Suspense fallback={<AdminWorkbenchNote>Loading diagnostics...</AdminWorkbenchNote>}>
        <LazyOrganizerIntakeDiagnostics
          bridge={controller.diagnosticsBridge}
          controller={controller}
        />
      </Suspense>
    </>
  );
}
