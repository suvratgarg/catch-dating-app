import {
  type EventIntakeController,
  useEventIntakeController,
} from "../controllers/useEventIntakeController";
import {useAdminFeedback} from "../../../../shared/feedback/AdminFeedbackContext";
import {eventIntakeWorkbench} from "./eventIntakeWorkbench";

export function EventIntakeWorkspace() {
  const {setError: onError, setNotice: onNotice} = useAdminFeedback();
  const controller = useEventIntakeController({onError, onNotice});
  return <EventIntakePreviewWorkspace controller={controller} />;
}

export function EventIntakePreviewWorkspace({
  controller,
}: {
  controller: EventIntakeController;
}) {
  return (
    <eventIntakeWorkbench.EventTaskWorkbench controller={controller} />
  );
}
