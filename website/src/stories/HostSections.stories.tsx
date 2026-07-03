import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostApplicationFlow} from "../features/host/application/HostApplicationFlow";
import {CreateEventWalkthrough as CreateEventWalkthroughComponent} from "../features/host/sections/CreateEventWalkthrough";
import {EventSuccessShowcase as EventSuccessShowcaseComponent} from "../features/host/sections/EventSuccessShowcase";
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
  HostPreviewAdmissionSection as HostPreviewAdmissionSectionComponent,
  HostPreviewAfterSection as HostPreviewAfterSectionComponent,
  HostPreviewApplySection as HostPreviewApplySectionComponent,
  HostPreviewCreateFlowSection as HostPreviewCreateFlowSectionComponent,
  HostPreviewFaqSection as HostPreviewFaqSectionComponent,
  HostPreviewFormatsSection as HostPreviewFormatsSectionComponent,
  HostPreviewHeroSection as HostPreviewHeroSectionComponent,
  HostPreviewLiveSection as HostPreviewLiveSectionComponent,
  HostPreviewOfferSection as HostPreviewOfferSectionComponent,
  HostPreviewOperatingLoopSection as HostPreviewOperatingLoopSectionComponent,
  HostPreviewPaymentsSection as HostPreviewPaymentsSectionComponent,
  HostPreviewTrustSection as HostPreviewTrustSectionComponent,
} from "../features/host/sections/HostPreviewSections";
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
      routeIds: ["host", "host_preview"],
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
      routeIds: ["host", "host_preview"],
      states: ["capture-fallback"],
    },
  },
  render: () => <CreateEventWalkthroughComponent captures={placeholderCaptures} />,
};

export const EventSuccessShowcaseSection: Story = {
  name: "Event Success showcase",
  parameters: {
    catchComponent: {
      id: "host_event_success_showcase",
      routeIds: ["host"],
      states: ["default", "activity", "after", "debrief"],
    },
  },
  render: () => <EventSuccessShowcaseComponent captures={captures} />,
};

export const HostComparisonSectionStory: Story = {
  name: "Host comparison",
  parameters: {
    catchComponent: {
      id: "host_comparison_section",
      routeIds: ["host", "host_preview"],
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
    catchComponent: {
      id: "host_apply_section",
      routeIds: ["host"],
      states: ["initial", "interactive-steps"],
    },
  },
  render: () => <HostApplySectionComponent />,
};

export const HostPreviewHeroSectionStory: Story = {
  name: "Host preview hero",
  parameters: {
    catchComponent: {
      id: "host_preview_hero_section",
      routeIds: ["host_preview"],
      states: ["default", "capture-fallback"],
    },
  },
  render: () => <HostPreviewHeroSectionComponent captures={captures} />,
};

export const HostPreviewHeroFallback: Story = {
  name: "Host preview hero · fallback captures",
  parameters: {
    catchComponent: {
      id: "host_preview_hero_section",
      routeIds: ["host_preview"],
      states: ["capture-fallback"],
    },
  },
  render: () => <HostPreviewHeroSectionComponent captures={placeholderCaptures} />,
};

export const HostPreviewOfferSectionStory: Story = {
  name: "Host preview offer",
  parameters: {
    catchComponent: {
      id: "host_preview_offer_section",
      routeIds: ["host_preview"],
      states: ["founding-host-offer"],
    },
  },
  render: () => <HostPreviewOfferSectionComponent />,
};

export const HostPreviewFormatsSectionStory: Story = {
  name: "Host preview formats",
  parameters: {
    catchComponent: {
      id: "host_preview_formats_section",
      routeIds: ["host_preview"],
      states: ["default"],
    },
  },
  render: () => <HostPreviewFormatsSectionComponent />,
};

export const HostPreviewOperatingLoopSectionStory: Story = {
  name: "Host preview operating loop",
  parameters: {
    catchComponent: {
      id: "host_preview_operating_loop_section",
      routeIds: ["host_preview"],
      states: ["default"],
    },
  },
  render: () => <HostPreviewOperatingLoopSectionComponent />,
};

export const HostPreviewCreateFlowSectionStory: Story = {
  name: "Host preview create flow",
  parameters: {
    catchComponent: {
      id: "host_preview_create_flow_section",
      routeIds: ["host_preview"],
      states: ["composes-create-event-walkthrough"],
    },
  },
  render: () => <HostPreviewCreateFlowSectionComponent captures={captures} />,
};

export const HostPreviewAdmissionSectionStory: Story = {
  name: "Host preview admission",
  parameters: {
    catchComponent: {
      id: "host_preview_admission_section",
      routeIds: ["host_preview"],
      states: ["roster-states"],
    },
  },
  render: () => <HostPreviewAdmissionSectionComponent />,
};

export const HostPreviewPaymentsSectionStory: Story = {
  name: "Host preview payments",
  parameters: {
    catchComponent: {
      id: "host_preview_payments_section",
      routeIds: ["host_preview"],
      states: ["payment-states"],
    },
  },
  render: () => <HostPreviewPaymentsSectionComponent />,
};

export const HostPreviewLiveSectionStory: Story = {
  name: "Host preview live",
  parameters: {
    catchComponent: {
      id: "host_preview_live_section",
      routeIds: ["host_preview"],
      states: ["default", "capture-fallback"],
    },
  },
  render: () => <HostPreviewLiveSectionComponent captures={captures} />,
};

export const HostPreviewLiveFallback: Story = {
  name: "Host preview live · fallback captures",
  parameters: {
    catchComponent: {
      id: "host_preview_live_section",
      routeIds: ["host_preview"],
      states: ["capture-fallback"],
    },
  },
  render: () => <HostPreviewLiveSectionComponent captures={placeholderCaptures} />,
};

export const HostPreviewAfterSectionStory: Story = {
  name: "Host preview after",
  parameters: {
    catchComponent: {
      id: "host_preview_after_section",
      routeIds: ["host_preview"],
      states: ["capture-grid"],
    },
  },
  render: () => <HostPreviewAfterSectionComponent captures={captures} />,
};

export const HostPreviewTrustSectionStory: Story = {
  name: "Host preview trust",
  parameters: {
    catchComponent: {
      id: "host_preview_trust_section",
      routeIds: ["host_preview"],
      states: ["default"],
    },
  },
  render: () => <HostPreviewTrustSectionComponent />,
};

export const HostPreviewFaqSectionStory: Story = {
  name: "Host preview FAQ",
  parameters: {
    catchComponent: {
      id: "host_preview_faq_section",
      routeIds: ["host_preview"],
      states: ["default"],
    },
  },
  render: () => <HostPreviewFaqSectionComponent />,
};

export const HostPreviewApplySectionStory: Story = {
  name: "Host preview apply",
  parameters: {
    catchComponent: {
      id: "host_preview_apply_section",
      routeIds: ["host_preview"],
      states: ["composes-host-application-flow"],
    },
  },
  render: () => <HostPreviewApplySectionComponent />,
};

export const HostApplicationFlowInitial: Story = {
  name: "Host application flow · initial",
  parameters: {
    catchComponent: {
      id: "host_application_flow",
      routeIds: ["host", "host_preview"],
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
