import organizerIntakeBridgeUrl from "../generated/organizerIntakeBridge.json?url";
import type * as Intake from "../types/organizerIntakeTypes";

export async function loadOrganizerIntakeBridge():
Promise<Intake.OrganizerIntakeBridge> {
  const response = await fetch(organizerIntakeBridgeUrl, {
    credentials: "same-origin",
  });
  if (!response.ok) {
    throw new Error(
      `Unable to load organizer intake bridge (${response.status}).`
    );
  }
  return await response.json() as Intake.OrganizerIntakeBridge;
}
