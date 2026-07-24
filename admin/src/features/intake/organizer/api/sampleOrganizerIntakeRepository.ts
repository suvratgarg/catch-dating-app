import organizerIntakeBridgeUrl from
  "../generated/organizerIntakeBridge.json?url";
import type {OrganizerIntakeBridge} from
  "../types/organizerIntakeTypes";

export async function loadSampleOrganizerIntakeBridge():
Promise<OrganizerIntakeBridge> {
  const response = await fetch(organizerIntakeBridgeUrl, {
    credentials: "same-origin",
  });
  if (!response.ok) {
    throw new Error(
      `Unable to load organizer intake sample (${response.status}).`
    );
  }
  return await response.json() as OrganizerIntakeBridge;
}
