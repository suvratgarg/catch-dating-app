import type {Meta, StoryObj} from "@storybook/react-vite";
import type {FormEvent} from "react";
import {useState} from "react";
import {SectionHeader} from "../shared/site/SectionHeader";
import {
  ActionGroup,
  Button,
  ButtonLink,
  ContentGrid,
  ControlRow,
  EventSuccessModuleGrid,
  EvidenceStrip,
  FeaturedOrganizersCta,
  FieldGrid,
  FormStatus,
  HostConsoleGrid,
  HostConsoleHeader,
  HostConsoleTimeline,
  HostCreateFieldGrid,
  HostCreateMockBar,
  ListingSuccessMetricGrid,
  ModuleStack,
  PanelShell,
  ProductBoardCard,
  ProductBoardMain,
  ProductBoardNav,
  ProductModuleGrid,
  ProductShell,
  ProofLedgerRows,
  SelectField,
  StepRail,
  TextField,
  UiLabel,
  WaitlistFormShell,
  WaitlistSection,
} from "../shared/ui/primitives";

const meta = {
  title: "Marketing Website/Shared/Layout And Form Primitives",
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

export const UiLabelShellStory: Story = {
  name: "UI labels",
  parameters: {
    catchComponent: {
      id: "shared_ui_label_shell",
      routeIds: ["home", "host", "host_preview", "claim", "claim_lookup", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["eyebrow", "metadata-label"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <article>
        <UiLabel>Public proof</UiLabel>
        <h3>Source-backed profile</h3>
        <p>Small metadata labels stay visually consistent across public sections and flow panels.</p>
      </article>
      <article>
        <UiLabel>Owner review</UiLabel>
        <h3>Claim packet ready</h3>
        <p>The same label primitive is used for route copy, field groups, and public proof rails.</p>
      </article>
    </ContentGrid>
  ),
};

export const SectionHeaderStory: Story = {
  name: "Section header",
  parameters: {
    catchComponent: {
      id: "shared_section_header",
      routeIds: ["home", "host", "host_preview", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["default", "wide", "h1"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <SectionHeader
        eyebrow="Organizer discovery"
        title="Find source-backed organizers"
        body="Shared section headers keep route sections aligned without duplicating heading markup."
      />
      <SectionHeader
        eyebrow="Host launch"
        title="Publish safer social events"
        body="Wide headers give route-level sections a denser intro when the section owns more evidence."
        headingLevel="h1"
        wide
      />
    </ContentGrid>
  ),
};

export const ActionGroupStory: Story = {
  name: "Action groups",
  parameters: {
    catchComponent: {
      id: "shared_action_group",
      routeIds: ["home", "host", "host_preview", "claim", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["flow", "hero", "host-create-flow"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <ActionGroup>
        <Button type="button">Continue</Button>
        <Button type="button" variant="ghost">Save draft</Button>
      </ActionGroup>
      <ActionGroup variant="hero" reveal>
        <ButtonLink href="/organizers/">Browse organizers</ButtonLink>
        <ButtonLink href="/host/" variant="ghost">Host with Catch</ButtonLink>
      </ActionGroup>
      <ActionGroup variant="host-create-flow">
        <Button type="button">Publish preview</Button>
        <Button type="button" variant="ghost">Review evidence</Button>
      </ActionGroup>
    </ContentGrid>
  ),
};

export const FieldGridStory: Story = {
  name: "Field grid",
  parameters: {
    catchComponent: {
      id: "shared_field_grid",
      routeIds: ["host", "host_preview", "claim"],
      states: ["two-column", "span-field", "select-field"],
    },
  },
  render: () => (
    <FieldGrid>
      <TextField id="storybook-field-name" label="Organizer name" name="organizerName" defaultValue="Sunday Table Club" />
      <SelectField id="storybook-field-format" label="Format" name="format" defaultValue="dinner">
        <option value="dinner">Dinner club</option>
        <option value="run">Run club</option>
      </SelectField>
      <TextField
        id="storybook-field-source"
        label="Source link"
        name="source"
        defaultValue="https://example.com/sunday-table"
        span
      />
    </FieldGrid>
  ),
};

export const StepRailStory: Story = {
  name: "Step rail",
  parameters: {
    catchComponent: {
      id: "shared_operational_step_rail",
      routeIds: ["host", "claim"],
      states: ["current", "complete", "disabled"],
    },
  },
  render: () => <StepRailDemo />,
};

export const WaitlistSectionStory: Story = {
  name: "Waitlist section",
  parameters: {
    catchComponent: {
      id: "shared_waitlist_section",
      routeIds: ["home", "host", "host_preview"],
      states: ["member", "host"],
    },
  },
  render: () => (
    <WaitlistSection
      title="Join the member waitlist"
      titleId="storybook-waitlist-section-title"
      body="Waitlist sections own the intro and form slot while route sections configure copy."
    >
      <WaitlistFormShell onSubmit={preventSubmit}>
        <TextField id="storybook-waitlist-name" label="Full name" name="fullName" required />
        <TextField id="storybook-waitlist-email" label="Email" name="email" type="email" required />
        <Button type="submit">Join the list</Button>
      </WaitlistFormShell>
    </WaitlistSection>
  ),
};

export const WaitlistFormShellStory: Story = {
  name: "Waitlist form shell",
  parameters: {
    catchComponent: {
      id: "shared_waitlist_form_shell",
      routeIds: ["home"],
      states: ["member-fields", "status"],
    },
  },
  render: () => (
    <WaitlistFormShell onSubmit={preventSubmit}>
      <TextField id="storybook-form-name" label="Full name" name="fullName" autoComplete="name" required />
      <TextField id="storybook-form-email" label="Email" name="email" type="email" autoComplete="email" required />
      <SelectField id="storybook-form-city" label="City" name="city" defaultValue="Mumbai">
        <option>Mumbai</option>
        <option>Indore</option>
        <option>Bengaluru</option>
      </SelectField>
      <Button type="submit">Join the list</Button>
      <FormStatus status={{message: "Saved locally for Storybook review.", tone: "is-success"}} />
    </WaitlistFormShell>
  ),
};

export const ContentGridStory: Story = {
  name: "Content grids",
  parameters: {
    catchComponent: {
      id: "shared_content_grid",
      routeIds: ["home", "host", "claim", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["format", "trust", "surface", "claim-review", "listing-event"],
    },
  },
  render: () => (
    <ContentGrid variant="trust">
      <article>
        <UiLabel>Trust</UiLabel>
        <h3>Source review</h3>
        <p>Content grids own repeated card layouts for route sections and proof panels.</p>
      </article>
      <article>
        <UiLabel>Safety</UiLabel>
        <h3>Owner controls</h3>
        <p>Feature sections configure the cards; the primitive owns the grid contract.</p>
      </article>
    </ContentGrid>
  ),
};

export const PanelShellStory: Story = {
  name: "Panel shells",
  parameters: {
    catchComponent: {
      id: "shared_panel_shell",
      routeIds: ["home", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["hero", "event-ticket", "listing", "claim-unlocks"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <PanelShell variant="hero" reveal>
        <UiLabel>Hero panel</UiLabel>
        <h3>Launch proof</h3>
        <p>Hero panels hold dense proof beside route copy.</p>
      </PanelShell>
      <PanelShell variant="event-ticket" reveal>
        <UiLabel>Event ticket</UiLabel>
        <h3>Dinner club preview</h3>
        <p>Ticket panels keep generated event previews visually consistent.</p>
      </PanelShell>
      <PanelShell variant="claim-unlocks" reveal>
        <UiLabel>Claim unlocks</UiLabel>
        <h3>Owner controls</h3>
        <p>Claim panels show what unlocks after review.</p>
      </PanelShell>
    </ContentGrid>
  ),
};

export const ProductShellStory: Story = {
  name: "Product shells",
  parameters: {
    catchComponent: {
      id: "shared_product_shell",
      routeIds: ["home", "host", "host_preview"],
      states: ["product-board", "host-console", "module-stack", "host-create-mock"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <ProductShell variant="product-board" reveal>
        <ProductBoardNav
          items={[
            {key: "discover", label: "Discover", active: true},
            {key: "claim", label: "Claim"},
            {key: "publish", label: "Publish"},
          ]}
        />
        <ProductBoardMain>
          <ProductBoardCard>
            <UiLabel>Organizer profile</UiLabel>
            <h3>Source-backed listing</h3>
            <ControlRow label="Profile strength" value="92%" />
          </ProductBoardCard>
          <ProductBoardCard tone="dark">
            <UiLabel>Launch queue</UiLabel>
            <h3>3 events ready</h3>
            <p>Configured product cards reuse the board shell without local wrappers.</p>
          </ProductBoardCard>
        </ProductBoardMain>
      </ProductShell>
      <ProductShell variant="host-console" reveal>
        <HostConsoleHeader label="Host console" title="Sunday Table Club" />
        <HostConsoleGrid
          items={[
            {label: "RSVPs", value: "84"},
            {label: "Review score", value: "4.9"},
          ]}
        />
        <HostConsoleTimeline
          items={[
            {label: "Event live", value: "Today"},
            {label: "Safety brief", value: "Sent"},
          ]}
        />
      </ProductShell>
      <ModuleStack
        items={[
          {label: "Event Success", title: "QR check-in", body: "Attendance and host notes stay tied to the event."},
          {label: "Safety", title: "Guest list controls", body: "Host controls are surfaced before launch."},
        ]}
      />
      <ProductShell variant="host-create-mock" reveal>
        <HostCreateMockBar activeIndex={1} items={[{id: "details"}, {id: "proof"}, {id: "publish"}]}>
          <UiLabel>Create event</UiLabel>
        </HostCreateMockBar>
        <HostCreateFieldGrid
          fields={[
            {label: "Format", value: "Dinner", options: ["Dinner", "Run", "Social"], activeOption: "Dinner"},
            {label: "Capacity", value: "18 guests"},
            {label: "Safety note", value: "Host verified", wide: true},
          ]}
        />
      </ProductShell>
    </ContentGrid>
  ),
};

export const RowShellStory: Story = {
  name: "Row shells",
  parameters: {
    catchComponent: {
      id: "shared_row_shell",
      routeIds: ["home", "host"],
      states: ["evidence-strip", "proof-ledger", "featured-cta"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <EvidenceStrip
        items={[
          {label: "Source-backed organizers", value: "42"},
          {label: "Launch cities", value: "9"},
          {label: "Claim packets", value: "18"},
        ]}
      />
      <ProofLedgerRows
        items={[
          {label: "Published source", proof: "Public event URL and organizer identity match."},
          {label: "Owner response", proof: "Claim request is ready for staff review."},
        ]}
      />
      <FeaturedOrganizersCta body="Route sections configure the CTA; the shared primitive owns the repeated row shell.">
        <ButtonLink href="/organizers/">Browse organizers</ButtonLink>
      </FeaturedOrganizersCta>
    </ContentGrid>
  ),
};

export const ControlRowStory: Story = {
  name: "Control row",
  parameters: {
    catchComponent: {
      id: "shared_control_row",
      routeIds: ["home"],
      states: ["label-value"],
    },
  },
  render: () => (
    <ProductBoardCard>
      <ControlRow label="Source confidence" value="High" />
      <ControlRow label="Profile strength" value="92%" />
      <ControlRow label="Owner claim" value="Ready" />
    </ProductBoardCard>
  ),
};

export const SuccessGridStory: Story = {
  name: "Success grids",
  parameters: {
    catchComponent: {
      id: "shared_success_grid",
      routeIds: ["host"],
      states: ["event-success-module"],
    },
  },
  render: () => (
    <EventSuccessModuleGrid
      items={[
        {
          attendee: "Clear check-in and safety expectations.",
          host: "Attendance and outcome notes return to the host console.",
          stage: "Before",
          title: "Brief",
        },
        {
          attendee: "Guests see the right event context.",
          host: "Hosts can reconcile arrivals against bookings.",
          stage: "During",
          title: "Check in",
        },
      ]}
    />
  ),
};

export const ListingSuccessMetricGridStory: Story = {
  name: "Listing success metric grid",
  parameters: {
    catchComponent: {
      id: "shared_listing_success_metric_grid",
      routeIds: ["organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["listing-metrics"],
    },
  },
  render: () => (
    <ListingSuccessMetricGrid
      items={[
        {label: "Verified check-ins", value: "164"},
        {label: "Repeat hosts", value: "7"},
        {label: "Post-event score", value: "4.8"},
      ]}
    />
  ),
};

function preventSubmit(event: FormEvent<HTMLFormElement>) {
  event.preventDefault();
}

function StepRailDemo() {
  const [activeId, setActiveId] = useState("proof");
  const items = [
    {
      id: "identity",
      label: "Identity",
      body: "Organizer, city, and source proof.",
    },
    {
      id: "proof",
      label: "Proof",
      body: "Events, links, and ownership checks.",
    },
    {
      id: "publish",
      label: "Publish",
      body: "Route and review evidence ready.",
    },
  ];
  const currentIndex = Math.max(0, items.findIndex((item) => item.id === activeId));

  return (
    <StepRail
      currentIndex={currentIndex}
      getDisabled={(_, index) => index > currentIndex + 1}
      items={items}
      label="Storybook operational steps"
      onSelect={setActiveId}
    />
  );
}
