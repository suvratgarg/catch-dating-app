import {useSenderPreferencesController} from "./useSenderPreferencesController";
import {rcsPreferencePort} from "./rcsPreferencePort";

export function useEventRcsPreferencesController(eventId: string, attendeeId: string) {
  return useSenderPreferencesController(rcsPreferencePort, eventId, attendeeId);
}
