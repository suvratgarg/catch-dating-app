import {expect, userEvent, within} from "storybook/test";
import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostApplicationFlow} from "../features/host/application/HostApplicationFlow";
import {CreateEventWalkthrough as CreateEventWalkthroughComponent} from "../features/host/sections/CreateEventWalkthrough";
import {PlaybookShowcase as PlaybookShowcaseComponent} from "../features/host/sections/PlaybookShowcase";
import {HostComparisonSection as HostComparisonSectionComponent} from "../features/host/sections/HostComparisonSection";
import {
  HostApplySection as HostApplySectionComponent,
  HostCapturesSection as HostCapturesSectionComponent,
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
  play: ({canvasElement}) => exerciseRailContrast(canvasElement, ".host-create-flow__rail"),
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
  play: ({canvasElement}) => exerciseRailContrast(canvasElement, ".event-success-stage-rail"),
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
      states: ["default", "capture-stage"],
    },
  },
  render: () => <HostHeroSectionComponent captures={captures} />,
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
      states: ["beta-offer"],
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

// WCAG contrast from rendered colors, including transparent ancestor surfaces.
function contrastRatio(element: HTMLElement, foreground = getComputedStyle(element).color) {
  const context = document.createElement("canvas").getContext("2d")!;
  const rgba = (color: string) => {
    context.clearRect(0, 0, 1, 1);
    context.fillStyle = color;
    context.fillRect(0, 0, 1, 1);
    return Array.from(context.getImageData(0, 0, 1, 1).data);
  };
  const blend = (front: number[], back: number[]) =>
    back.map((value, index) => front[index] * front[3] / 255 + value * (1 - front[3] / 255));
  const ancestors: HTMLElement[] = [];
  for (let node: HTMLElement | null = element; node; node = node.parentElement) ancestors.push(node);
  let background = [255, 255, 255];
  for (const node of ancestors.reverse()) background = blend(rgba(getComputedStyle(node).backgroundColor), background);
  const luminance = (rgb: number[]) => rgb.map((value) => {
    const channel = value / 255;
    return channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4;
  }).reduce((sum, value, index) => sum + value * [0.2126, 0.7152, 0.0722][index], 0);
  const ink = luminance(blend(rgba(foreground), background));
  const surface = luminance(background);
  return (Math.max(ink, surface) + 0.05) / (Math.min(ink, surface) + 0.05);
}

async function exerciseRailContrast(canvasElement: HTMLElement, selector: string) {
  const rail = canvasElement.querySelector<HTMLElement>(selector)!;
  const buttons = within(rail).getAllByRole("button");
  const initial = buttons.find((button) => button.getAttribute("aria-current") === "step")!;
  for (const button of buttons) {
    for (const label of button.querySelectorAll<HTMLElement>("span, strong, small")) {
      await expect(contrastRatio(label)).toBeGreaterThanOrEqual(4.5);
    }
    await userEvent.click(button);
    await expect(button).toHaveAttribute("aria-current", "step");
    await expect(button).toHaveClass("is-active");
    await userEvent.hover(button);
    for (const label of button.querySelectorAll<HTMLElement>("span, strong, small")) {
      await expect(contrastRatio(label)).toBeGreaterThanOrEqual(4.5);
    }
    await userEvent.tab();
    button.focus();
    await expect(button).toHaveFocus();
    await expect(button.matches(":focus-visible")).toBe(true);
    const style = getComputedStyle(button);
    await expect(style.outlineStyle).toBe("solid");
    await expect(parseFloat(style.outlineWidth)).toBeGreaterThanOrEqual(2);
    await expect(contrastRatio(button, style.outlineColor)).toBeGreaterThanOrEqual(3);
    for (const label of button.querySelectorAll<HTMLElement>("span, strong, small")) {
      await expect(contrastRatio(label)).toBeGreaterThanOrEqual(4.5);
    }
  }
  await userEvent.click(initial);
  await expect(initial).toHaveAttribute("aria-current", "step");
  await userEvent.unhover(initial);
  initial.blur();
}
