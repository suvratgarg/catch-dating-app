import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostApplicationFlow} from "../features/host/application/HostApplicationFlow";
import {CreateEventWalkthrough as CreateEventWalkthroughComponent} from "../features/host/sections/CreateEventWalkthrough";
import {PlaybookShowcase as PlaybookShowcaseComponent} from "../features/host/sections/PlaybookShowcase";
import {HostComparisonSection as HostComparisonSectionComponent} from "../features/host/sections/HostComparisonSection";
import {
  HostApplySection as HostApplySectionComponent,
  HostCapturesSection as HostCapturesSectionComponent,
  HostEvidenceSection as HostEvidenceSectionComponent,
  HostFillRoomSection as HostFillRoomSectionComponent,
  HostHeroSection as HostHeroSectionComponent,
  HostLiveModulesSection as HostLiveModulesSectionComponent,
  HostProofLedgerSection as HostProofLedgerSectionComponent,
  HostSurfaceSection as HostSurfaceSectionComponent,
  HostWorkflowSection as HostWorkflowSectionComponent,
} from "../features/host/sections/HostPageSections";
import {
  HostFaqSection as HostFaqSectionComponent,
  HostFoundingOfferSection as HostFoundingOfferSectionComponent,
  HostTrustSection as HostTrustSectionComponent,
} from "../features/host/sections/HostSupportingSections";
import {WaitlistSection} from "../shared/ui/primitives";
import {captures, placeholderCaptures} from "./fixtures/marketingCaptures";

const meta = {
  title: "Marketing Website/Host/Sections",
  parameters: {
    catchComponentRegistry: {
      path: "design/website/components.json",
    },
    catchRouteContract: {
      path: "design/website/routes.json",
    },
  },
} satisfies Meta;

export default meta;

type Story = StoryObj<typeof meta>;

export const CreateEventWalkthroughSection: Story = {
  name: "Create event walkthrough",
  parameters: {
    catchComponent: {
      id: "host_create_event_walkthrough",
      routeIds: ["host"],
      states: ["default", "interactive-steps", "capture-fallback"],
    },
  },
  render: () => <CreateEventWalkthroughComponent captures={captures} />,
};

export const CreateEventWalkthroughFallback: Story = {
  name: "Create event walkthrough · fallback captures",
  parameters: {
    catchComponent: {
      id: "host_create_event_walkthrough",
      routeIds: ["host"],
      states: ["capture-fallback"],
    },
  },
  render: () => <CreateEventWalkthroughComponent captures={placeholderCaptures} />,
};

export const PlaybookShowcaseSection: Story = {
  name: "Playbook showcase",
  parameters: {
    catchComponent: {
      id: "host_playbook_showcase",
      routeIds: ["host"],
      states: ["default", "activity", "after", "debrief", "module-expanded", "deep-link"],
    },
  },
  render: () => <PlaybookShowcaseComponent captures={captures} />,
};

export const HostComparisonSectionStory: Story = {
  name: "Host comparison",
  parameters: {
    catchComponent: {
      id: "host_comparison_section",
      routeIds: ["host"],
      states: ["collapsed", "expanded-interaction"],
    },
  },
  render: () => <HostComparisonSectionComponent />,
};

export const HostHeroSectionStory: Story = {
  name: "Host hero",
  parameters: {
    catchComponent: {
      id: "host_hero_section",
      routeIds: ["host"],
      states: ["default", "host-console"],
    },
  },
  render: () => <HostHeroSectionComponent />,
};

export const HostEvidenceSectionStory: Story = {
  name: "Host evidence",
  parameters: {
    catchComponent: {
      id: "host_evidence_section",
      routeIds: ["host"],
      states: ["default", "evidence-strip"],
    },
  },
  render: () => <HostEvidenceSectionComponent />,
};

export const HostWorkflowSectionStory: Story = {
  name: "Host workflow",
  parameters: {
    catchComponent: {
      id: "host_workflow_section",
      routeIds: ["host"],
      states: ["default"],
    },
  },
  render: () => <HostWorkflowSectionComponent />,
};

export const HostSurfaceSectionStory: Story = {
  name: "Host surface",
  parameters: {
    catchComponent: {
      id: "host_surface_section",
      routeIds: ["host"],
      states: ["default"],
    },
  },
  render: () => <HostSurfaceSectionComponent />,
};

export const HostFillRoomSectionStory: Story = {
  name: "Host fill room",
  parameters: {
    catchComponent: {
      id: "host_fill_room_section",
      routeIds: ["host"],
      states: ["checkout", "waitlist", "cohorts"],
    },
  },
  render: () => <HostFillRoomSectionComponent />,
};

export const HostLiveModulesSectionStory: Story = {
  name: "Host live modules",
  parameters: {
    catchComponent: {
      id: "host_live_modules_section",
      routeIds: ["host"],
      states: ["default", "module-stack"],
    },
  },
  render: () => <HostLiveModulesSectionComponent />,
};

export const HostProofLedgerSectionStory: Story = {
  name: "Host proof ledger",
  parameters: {
    catchComponent: {
      id: "host_proof_ledger_section",
      routeIds: ["host"],
      states: ["default"],
    },
  },
  render: () => <HostProofLedgerSectionComponent />,
};

export const HostCapturesSectionStory: Story = {
  name: "Host captures",
  parameters: {
    catchComponent: {
      id: "host_captures_section",
      routeIds: ["host"],
      states: ["default", "capture-grid"],
    },
  },
  render: () => <HostCapturesSectionComponent captures={captures} />,
};

export const HostCapturesFallback: Story = {
  name: "Host captures · fallback captures",
  parameters: {
    catchComponent: {
      id: "host_captures_section",
      routeIds: ["host"],
      states: ["capture-fallback"],
    },
  },
  render: () => <HostCapturesSectionComponent captures={placeholderCaptures} />,
};

export const HostApplySectionStory: Story = {
  name: "Host apply section",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "host_apply_section",
      routeIds: ["host"],
      states: ["initial", "interactive-steps"],
    },
  },
  render: () => <HostApplySectionComponent />,
};

export const HostFoundingOfferSectionStory: Story = {
  name: "Host founding offer",
  parameters: {
    catchComponent: {
      id: "host_founding_offer_section",
      routeIds: ["host"],
      states: ["founding-host-offer"],
    },
  },
  render: () => <HostFoundingOfferSectionComponent />,
};

export const HostTrustSectionStory: Story = {
  name: "Host trust",
  parameters: {
    catchComponent: {
      id: "host_trust_section",
      routeIds: ["host"],
      states: ["default"],
    },
  },
  render: () => <HostTrustSectionComponent />,
};

export const HostFaqSectionStory: Story = {
  name: "Host FAQ",
  parameters: {
    catchComponent: {
      id: "host_faq_section",
      routeIds: ["host"],
      states: ["default"],
    },
  },
  render: () => <HostFaqSectionComponent />,
};

export const HostApplicationFlowInitial: Story = {
  name: "Host application flow · initial",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "host_application_flow",
      routeIds: ["host"],
      states: ["initial", "interactive-steps"],
    },
  },
  render: () => (
    <WaitlistSection
      id="founding-hosts"
      introReveal={false}
      titleId="host-application-story-title"
      title="Bring the format. Catch handles the loop around it."
      body="Apply as a founding host if you run events, communities, venues, or formats where the right singles can meet with more context."
    >
      <HostApplicationFlow />
    </WaitlistSection>
  ),
};
