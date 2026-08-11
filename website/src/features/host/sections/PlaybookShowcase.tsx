import {websiteCopy} from "@content/generated";
import {websiteTemplates} from "@content/templates";
import {useEffect, useState} from "react";
import {trackMarketingEvent} from "../../../analytics";
import {playbook, playbookModules, playbookStages} from "@content/host";
import {SectionHeader} from "../../../shared/site";
import {
  HostFeatureRail,
  HostFeatureSection,
  PlaybookCatalog,
  PlaybookFormatNote,
  PlaybookIntro,
  PrivacyGuardrail,
} from "../../../shared/ui/primitives";
import type {HostCaptureMap} from "./CaptureFrames";

export function PlaybookShowcase({captures: _captures}: {captures: HostCaptureMap}) {
  const [stage, setStage] = useState("arrival");

  useEffect(() => {
    const anchor = window.location.hash.slice(1);
    if (!anchor.startsWith("playbook-")) return;
    requestAnimationFrame(() => document.getElementById(anchor)?.scrollIntoView({block: "center"}));
  }, []);

  return (
    <HostFeatureSection id="playbook" variant="event-success" aria-labelledby="playbook-title">
      <SectionHeader eyebrow={playbook.eyebrow} id="playbook-title" title={playbook.title} />
      <PlaybookIntro>
        {playbook.body.map((paragraph) => <p key={paragraph}>{paragraph}</p>)}
      </PlaybookIntro>
      <HostFeatureRail
        activeId={stage}
        bodyVisibility="always"
        items={playbookStages.map((item) => ({
          id: item.id,
          label: item.label,
          body: websiteTemplates.playbookStageBody(item.sub, item.hostLine),
        }))}
        label={playbook.railLabel}
        onSelect={setStage}
        reveal
        variant="event-success"
      />
      <PlaybookCatalog
        activeAnchor={window.location.hash.slice(1)}
        aria-label={websiteCopy["playbookshowcase_0325"]}
        items={playbookModules}
        onExpand={(moduleId) => {
          const module = playbookModules.find((item) => item.id === moduleId);
          trackMarketingEvent("playbook_module_expanded", {
            module_id: moduleId,
            module_stage: module?.stageId ?? "unknown",
          });
        }}
      />
      <PrivacyGuardrail>
        <strong>{playbook.guardrailTitle}</strong> {playbook.guardrailBody}
      </PrivacyGuardrail>
      <PlaybookFormatNote>{playbook.formatNote}</PlaybookFormatNote>
    </HostFeatureSection>
  );
}
