import {useSenderPreferencesController} from "./useSenderPreferencesController";
import {whatsappPreferencePort} from "./whatsappPreferencePort";

export function useEventWhatsappPreferencesController(eventId: string, attendeeId: string) {
  return useSenderPreferencesController(whatsappPreferencePort, eventId, attendeeId);
}
