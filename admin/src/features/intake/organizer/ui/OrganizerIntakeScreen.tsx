import {lazy, Suspense, useState} from "react";

import {
  AdminButton,
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
      fallback={<AdminWorkbenchNote>Loading organizer intake...</AdminWorkbenchNote>}
    >
      <OrganizerIntakeLoadedScreen />
    </Suspense>
  );
}

function OrganizerIntakeLoadedScreen() {
  const {setError: onError, setNotice: onNotice} = useAdminFeedback();
  const controller = useOrganizerIntakeController({onError, onNotice});
  return <OrganizerIntakeWorkspace controller={controller} />;
}

export function OrganizerIntakeWorkspace({
  controller,
}: {
  controller: OrganizerIntakeController;
}) {
  const [showDiagnostics, setShowDiagnostics] = useState(false);
  if (!showDiagnostics) {
    return (
      <organizerIntakeWorkbench.OrganizerTaskWorkbench
        controller={controller}
        onShowDiagnostics={() => setShowDiagnostics(true)}
      />
    );
  }
  if (!controller.diagnosticsBridge) {
    return (
      <organizerIntakeWorkbench.OrganizerTaskWorkbench
        controller={controller}
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
