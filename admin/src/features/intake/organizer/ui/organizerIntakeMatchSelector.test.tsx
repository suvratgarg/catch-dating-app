import {fireEvent, render, screen} from "@testing-library/react";
import {useState} from "react";
import {expect, it, vi} from "vitest";
import type * as Intake from "../types/organizerIntakeTypes";
import {organizerIntakeDiscoveryPanels} from "./organizerIntakeDiscoveryPanels";

const candidate = {candidateId: "candidate-1", title: "Courtside",
  rank: 1, platform: "officialWebsite", surfaceKind: "homepage",
  reviewAction: "attach_existing", observedAt: "2026-09-27",
  normalizedKey: "domain:courtside.example",
  canonicalUrl: "https://courtside.example/", snippet: null,
  queryIntent: {marketSlug: "mumbai", entityHint: null}, diagnostics: [],
  existingEntityMatches: [{entityId: "org-1"}, {entityId: "org-2"}],
} as unknown as Intake.OrganizerSearchCandidate;
const commands = {curateSurface: "Attach ENTITY to CANDIDATE_ID"} as
  Intake.OrganizerSearchCandidateCommands;

it("requires an explicit matched organizer in candidate review", () => {
  const onAttachCandidate = vi.fn();
  function Harness() {
    const [selectedMatch, setSelectedMatch] = useState("");
    return <organizerIntakeDiscoveryPanels.OrganizerSearchCandidateCard
      candidate={candidate} commands={commands} inFlight={false}
      onAttachCandidate={onAttachCandidate}
      onSelectMatch={(_candidateId, organizerId) =>
        setSelectedMatch(organizerId)} selectedMatch={selectedMatch} />;
  }
  render(<Harness />);
  const attach = screen.getByRole("button", {name: "Attach surface"});
  expect((attach as HTMLButtonElement).disabled).toBe(true);
  fireEvent.change(screen.getByLabelText("Reviewed canonical organizer"),
    {target: {value: "org-2"}});
  expect((attach as HTMLButtonElement).disabled).toBe(false);
  fireEvent.click(attach);
  expect(onAttachCandidate).toHaveBeenCalledWith(candidate);
});
