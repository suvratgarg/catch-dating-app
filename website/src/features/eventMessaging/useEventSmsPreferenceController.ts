import {useSenderPreferencesController} from "./useSenderPreferencesController";
import {smsPreferencePort} from "./smsPreferencePort";

export function useEventSmsPreferenceController(eventId: string, attendeeId: string) {
  return useSenderPreferencesController(smsPreferencePort, eventId, attendeeId);
}
