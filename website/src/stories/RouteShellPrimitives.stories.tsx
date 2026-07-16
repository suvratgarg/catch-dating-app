import type {Meta, StoryObj} from "@storybook/react-vite";
import type {FormEvent, ReactNode} from "react";
import {hostListings} from "./fixtures/hostListings";
import {claimHrefForListing} from "../features/organizers/routing";
import {isUnclaimedListing} from "../features/organizers/selectors";
import {HostListingSections} from "../features/organizers/sections/HostListingSections";
import type {HostListingPageController} from "../features/organizers/useHostListingPageController";
import type {ListingClaimController} from "../features/claims/useListingClaimController";
import type {HostListing} from "../features/organizers/types";
import {PageShell, WebsitePageMain} from "../shared/site/PageShell";
import {WebsiteQueryProvider} from "../shared/query/queryClient";
import {
  Button,
  ButtonLink,
  ClaimBandGrid,
  ClaimBandRail,
  ClaimBandSection,
  ClaimFlowHero,
  ClaimFlowMain,
  ClaimFlowPanel,
  ClaimFlowStage,
  ClaimFlowWorkspace,
  ClaimListingResults,
  ClaimMissingEvidenceList,
  ClaimRequestForm,
  ClaimRequestPanel,
  ClaimRequestPanelHeading,
  ClaimResultButton,
  ContentGrid,
  DirectoryClaimPressureCopy,
  DirectoryClaimPressureCta,
  DirectoryClaimPressureList,
  DirectoryClaimPressureStats,
  FieldGrid,
  FormStatus,
  HostApplicationCompletenessSummary,
  HostApplicationPanel,
  HostApplicationReviewCard,
  HostApplicationReviewGrid,
  HostApplicationShell,
  HostApplicationStage,
  HostApplicationSubmitted,
  HostComparisonTableHeading,
  HostCreateFlowCapture,
  HostFeatureGrid,
  HostFeatureRail,
  HostFeatureSection,
  HostHeroCopy,
  HostHeroInner,
  HostHeroShell,
  HostPageSection,
  HostPreviewApplyShell,
  HostPreviewChipRow,
  HostPreviewConsole,
  HostPreviewFaqList,
  HostPreviewFormatRail,
  HostPreviewHeroCopy,
  HostPreviewHeroInner,
  HostPreviewHeroMedia,
  HostPreviewHeroProduct,
  HostPreviewHeroShell,
  HostPreviewHeroStores,
  HostPreviewLiveGrid,
  HostPreviewLiveModules,
  HostPreviewLoopGrid,
  HostPreviewMain,
  HostPreviewOfferCard,
  HostPreviewOfferShell,
  HostPreviewOfferSteps,
  HostPreviewPaymentFlow,
  HostPreviewProductSplitCopy,
  HostPreviewRoster,
  HostPreviewSection,
  HostPreviewSectionHead,
  HostPreviewTrustGrid,
  OperationalNote,
  OrganizerResultSummary,
  OrganizerSearchSection,
  OrganizerSearchStats,
  OwnerUnlockBoard,
  PrivacyGuardrail,
  ProductShell,
  SelectedListingCard,
  SelectField,
  TextField,
  UiLabel,
  VerificationMethodGrid,
} from "../shared/ui/primitives";

const claimableListing = hostListings.find(isUnclaimedListing) ?? requireListing("afterfly");
const listingRouteIds = ["organizer_listing_canonical", "organizer_listing_legacy"];

const meta = {
  title: "Marketing Website/Shared/Route Shells",
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

export const PageShellStory: Story = {
  name: "Page shell",
  parameters: {
    catchComponent: {
      id: "shared_page_shell",
      routeIds: ["home", "host", "claim", "claim_lookup", "not_found", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["page-shell", "website-main"],
    },
  },
  render: () => (
    <PageShell pageClassName="home-page">
      <WebsitePageMain aria-label="Storybook page shell preview">
        <ContentGrid variant="surface">
          <article>
            <UiLabel>Route shell</UiLabel>
            <h1>Shared page shell</h1>
            <p>App routes configure the page class; feature sections own the content.</p>
          </article>
        </ContentGrid>
      </WebsitePageMain>
    </PageShell>
  ),
};

export const ClaimFlowShellStory: Story = {
  name: "Claim flow shell",
  parameters: {
    catchComponent: {
      id: "shared_claim_flow_shell",
      routeIds: ["claim", "claim_lookup"],
      states: ["route-root", "hero", "workspace", "panel", "listing-results", "verification"],
    },
  },
  render: () => (
    <ClaimFlowMain>
      <ClaimFlowHero
        eyebrow="Claim organizer page"
        title="Prove ownership before controls unlock"
        body="The route shell holds the hero, workspace, selected listing, and verification stages."
        summaryTitle="Review path"
        summaryBody="Owner proof, public sources, and staff review"
      />
      <ClaimFlowWorkspace onSubmit={preventSubmit}>
        <ClaimFlowPanel>
          <ClaimFlowStage>
            <FieldGrid>
              <TextField id="storybook-claim-name" label="Requester name" name="requesterName" defaultValue="Taylor Host" />
              <SelectField id="storybook-claim-role" label="Role" name="requesterRole" defaultValue="owner">
                <option value="owner">Owner</option>
                <option value="manager">Manager</option>
              </SelectField>
            </FieldGrid>
            <ClaimListingResults>
              <ClaimResultButton activityToken="var(--activity-dinner)" selected>
                Sunday Table Club
              </ClaimResultButton>
              <SelectedListingCard>
                <strong>Selected listing</strong>
                <p>Profile evidence and source links are ready for staff review.</p>
              </SelectedListingCard>
            </ClaimListingResults>
            <VerificationMethodGrid aria-label="Verification evidence">
              <article>
                <UiLabel>Public proof</UiLabel>
                <p>Link to event pages or social profiles that show ownership.</p>
              </article>
              <article>
                <UiLabel>Business contact</UiLabel>
                <p>Add a reachable email or phone number for the review packet.</p>
              </article>
            </VerificationMethodGrid>
            <OwnerUnlockBoard
              items={[
                {title: "Owner response", body: "Reply to public review signals after approval."},
                {title: "Event controls", body: "Publish app-created events from the host surface."},
              ]}
            />
          </ClaimFlowStage>
        </ClaimFlowPanel>
      </ClaimFlowWorkspace>
    </ClaimFlowMain>
  ),
};

export const ClaimBandShellStory: Story = {
  name: "Listing claim band shell",
  parameters: {
    catchComponent: {
      id: "shared_claim_shell",
      routeIds: listingRouteIds,
      states: ["claim-band", "rail", "request-panel"],
    },
  },
  render: () => (
    <ClaimBandSection>
      <ClaimBandGrid>
        <div>
          <UiLabel>Claim page</UiLabel>
          <h2>Unlock owner controls for this organizer profile.</h2>
          <p>Claim-band shells keep generated listing claim CTAs and owner proof rails aligned.</p>
        </div>
        <ClaimBandRail>
          <strong>Review checks</strong>
          <span>Public source</span>
          <span>Owner role</span>
          <span>Business contact</span>
        </ClaimBandRail>
      </ClaimBandGrid>
      <ClaimRequestPanel reveal>
        <ClaimRequestPanelHeading>
          <UiLabel>Request ownership</UiLabel>
          <h3>Staff reviews proof before the page changes state.</h3>
        </ClaimRequestPanelHeading>
        <ButtonLink href="/claim/afterfly/">Start claim</ButtonLink>
      </ClaimRequestPanel>
    </ClaimBandSection>
  ),
};

export const ListingClaimShellStory: Story = {
  name: "Listing claim form shell",
  parameters: {
    catchComponent: {
      id: "shared_listing_claim_shell",
      routeIds: listingRouteIds,
      states: ["missing-list", "claim-request-form", "status"],
    },
  },
  render: () => (
    <ClaimRequestPanel>
      <ClaimRequestPanelHeading>
        <UiLabel>Missing evidence</UiLabel>
        <h3>What this listing still needs</h3>
      </ClaimRequestPanelHeading>
      <ClaimMissingEvidenceList
        items={[
          "A source page that names the organizer.",
          "A reachable owner email or phone number.",
          "Proof that the requester can manage this public listing.",
        ]}
      />
      <ClaimRequestForm onSubmit={preventSubmit}>
        <TextField id="storybook-listing-claim-name" label="Requester name" name="requesterName" />
        <TextField id="storybook-listing-claim-email" label="Business email" name="businessEmail" type="email" />
        <Button type="submit">Send claim request</Button>
        <FormStatus status={{message: "Storybook claim request is ready for review.", tone: "is-success"}} />
      </ClaimRequestForm>
    </ClaimRequestPanel>
  ),
};

export const HostPageShellStory: Story = {
  name: "Host page shell",
  parameters: {
    catchComponent: {
      id: "shared_host_page_shell",
      routeIds: ["host"],
      states: ["hero", "section-variants"],
    },
  },
  render: () => (
    <>
      <HostHeroShell>
        <HostHeroInner>
          <HostHeroCopy>
            <UiLabel>Host with Catch</UiLabel>
            <h1>Launch source-backed social events.</h1>
            <p>Host page shells keep hero and section variants governed by shared primitives.</p>
          </HostHeroCopy>
          <ProductShell variant="host-console">
            <strong>Live console</strong>
            <p>Roster, waitlist, and event notes in one host surface.</p>
          </ProductShell>
        </HostHeroInner>
      </HostHeroShell>
      <ContentGrid variant="surface">
        {(["evidence", "surface", "fill-room", "proof-ledger"] as const).map((variant) => (
          <HostPageSection variant={variant} key={variant}>
            <UiLabel>{variant}</UiLabel>
            <h2>{variant} section</h2>
            <p>Route copy configures this shared host section shell.</p>
          </HostPageSection>
        ))}
      </ContentGrid>
    </>
  ),
};

export const HostApplicationShellStory: Story = {
  name: "Host application shell",
  parameters: {
    catchComponent: {
      id: "shared_host_application_shell",
      routeIds: ["host"],
      states: ["form", "panel", "stage", "submitted", "review", "summary"],
    },
  },
  render: () => (
    <HostApplicationShell onSubmit={preventSubmit} reveal>
      <HostApplicationPanel>
        <HostApplicationStage>
          <TextField id="storybook-host-application-name" label="Organizer name" name="organizerName" defaultValue="Sunday Table Club" />
          <OperationalNote title="Review note" body="Host applications use shared panels and stages for all field groups." />
        </HostApplicationStage>
      </HostApplicationPanel>
      <HostApplicationReviewGrid>
        <HostApplicationReviewCard
          title="Profile"
          rows={[
            ["Organizer", "Sunday Table Club"],
            ["City", "Mumbai"],
          ]}
        />
        <HostApplicationReviewCard
          title="Launch"
          rows={[
            ["Format", "Dinner"],
            ["Capacity", "18 guests"],
          ]}
        />
      </HostApplicationReviewGrid>
      <HostApplicationCompletenessSummary
        label="Application completeness"
        meter="3 of 4"
        items={[
          {done: true, label: "Organizer profile"},
          {done: true, label: "Source proof"},
          {done: false, label: "Safety notes"},
        ]}
      />
      <HostApplicationSubmitted
        label="Submitted"
        title="Host application queued"
        body="Staff can review this packet before the host account changes state."
      />
    </HostApplicationShell>
  ),
};

export const HostFeatureSectionShellStory: Story = {
  name: "Host feature section shell",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "shared_host_feature_section_shell",
      routeIds: ["host"],
      states: ["create-flow", "event-success", "comparison", "rail", "guardrail"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <HostFeatureSection variant="create-flow">
        <HostFeatureGrid variant="create-flow">
          <HostFeatureRail
            activeId="details"
            label="Create event steps"
            variant="create-flow"
            items={[
              {id: "details", label: "Details", body: "Set the format and venue."},
              {id: "proof", label: "Proof", body: "Attach source-backed trust context."},
            ]}
            onSelect={() => undefined}
          />
          <HostCreateFlowCapture>
            <strong>Host create flow preview</strong>
          </HostCreateFlowCapture>
        </HostFeatureGrid>
      </HostFeatureSection>
      <HostFeatureSection variant="comparison">
        <HostFeatureGrid variant="comparison-split">
          <HostComparisonTableHeading>
            <UiLabel>Comparison</UiLabel>
            <h2>Catch vs. generic forms</h2>
          </HostComparisonTableHeading>
          <PrivacyGuardrail>
            <strong>Privacy guardrail</strong>
            <p>Guests see event context only after the right checks pass.</p>
          </PrivacyGuardrail>
        </HostFeatureGrid>
      </HostFeatureSection>
      <HostFeatureSection variant="event-success">
        <HostFeatureGrid variant="event-success">
          <HostFeatureRail
            activeId="checkin"
            label="Playbook stages"
            variant="event-success"
            items={[
              {id: "checkin", label: "Check-in", body: "Validate arrivals."},
              {id: "debrief", label: "Debrief", body: "Capture outcome notes."},
            ]}
            onSelect={() => undefined}
          />
        </HostFeatureGrid>
      </HostFeatureSection>
    </ContentGrid>
  ),
};

export const HostPreviewShellStory: Story = {
  name: "Host preview shell",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "shared_host_preview_shell",
      routeIds: ["host"],
      states: ["main", "hero", "offer", "sections", "apply", "live", "trust", "faq"],
    },
  },
  render: () => (
    <HostPreviewMain>
      <HostPreviewHeroShell>
        <HostPreviewHeroInner>
          <HostPreviewHeroCopy>
            <UiLabel>Preview</UiLabel>
            <h1>Host preview route shell</h1>
            <p>Preview-specific shells stay governed before launch traffic reaches them.</p>
            <HostPreviewHeroStores>
              <ButtonLink href="/download/">Open app</ButtonLink>
            </HostPreviewHeroStores>
          </HostPreviewHeroCopy>
          <HostPreviewHeroMedia>
            <HostPreviewHeroProduct>
              <HostPreviewConsole
                label="Live room"
                title="Dinner club"
                items={[
                  {label: "Guests", value: "18"},
                  {label: "Waitlist", value: "6"},
                ]}
              />
            </HostPreviewHeroProduct>
          </HostPreviewHeroMedia>
        </HostPreviewHeroInner>
      </HostPreviewHeroShell>
      <HostPreviewOfferShell>
        <HostPreviewOfferCard
          badgeAriaLabel="Founding host offer"
          badgeLabel="Founding"
          badgeValue="0%"
          title="Founding host offer"
          titleId="storybook-host-preview-offer"
          body="Offer cards, steps, and sections use shared route-specific shells."
        />
        <HostPreviewOfferSteps items={["Apply", "Review", "Launch"]} />
      </HostPreviewOfferShell>
      <HostPreviewSection variant="product-split">
        <HostPreviewSectionHead title="Launch formats" titleId="storybook-host-preview-section" />
        <HostPreviewFormatRail
          items={[
            {key: "dinner", label: "Dinner", active: true},
            {key: "run", label: "Run club"},
          ]}
        />
        <HostPreviewProductSplitCopy
          title="Everything before publish"
          titleId="storybook-host-preview-split"
          body="Format rails, chip rows, rosters, live modules, and payment flows stay component-owned."
        >
          <HostPreviewChipRow items={[{key: "safety", label: "Safety"}, {key: "proof", label: "Proof"}]} />
        </HostPreviewProductSplitCopy>
      </HostPreviewSection>
      <HostPreviewSection variant="loop">
        <HostPreviewLoopGrid
          items={[
            {step: "Apply", title: "Send context", body: "Tell Catch about the room."},
            {step: "Launch", title: "Publish with controls", body: "Use waitlist, roster, and check-in."},
          ]}
        />
      </HostPreviewSection>
      <HostPreviewSection variant="live">
        <HostPreviewLiveGrid>
          <HostPreviewRoster
            items={[
              {name: "Aarav", status: "Checked in", note: "Dinner seat 4"},
              {name: "Mira", status: "Waitlist", note: "Notify if space opens"},
            ]}
          />
          <HostPreviewPaymentFlow items={["Ticket", "Refund policy", "Settlement"]} />
          <HostPreviewLiveModules items={["QR check-in", "Crowd balance", "First hello"]} />
        </HostPreviewLiveGrid>
      </HostPreviewSection>
      <HostPreviewSection variant="trust">
        <HostPreviewTrustGrid
          items={[
            {title: "Owner review", body: "Staff review happens before controls unlock."},
            {title: "Guest safety", body: "Event context controls what guests can see."},
          ]}
        />
        <HostPreviewFaqList
          items={[
            {question: "Can I publish directly?", answer: "Catch reviews the first host packet before launch."},
          ]}
        />
      </HostPreviewSection>
      <HostPreviewApplyShell
        title="Apply as a host"
        titleId="storybook-host-preview-apply"
        body="The apply shell reuses the governed waitlist section contract."
      >
        <ButtonLink href="/host/apply/">Start application</ButtonLink>
      </HostPreviewApplyShell>
    </HostPreviewMain>
  ),
};

export const OrganizerSearchSectionShellStory: Story = {
  name: "Organizer search section shell",
  parameters: {
    catchComponent: {
      id: "shared_organizer_search_section_shell",
      routeIds: ["organizer_search"],
      states: ["hero", "results", "claim-pressure"],
    },
  },
  render: () => (
    <>
      <OrganizerSearchSection variant="hero" reveal>
        <UiLabel>Organizer directory</UiLabel>
        <h1>Search source-backed organizer pages</h1>
        <OrganizerSearchStats
          items={[
            {label: "Profiles", value: "42"},
            {label: "Cities", value: "9"},
          ]}
        />
      </OrganizerSearchSection>
      <OrganizerSearchSection variant="results">
        <OrganizerResultSummary>
          <strong>12 organizers found</strong>
          <p>Results sections own summaries while result cards stay separate primitives.</p>
        </OrganizerResultSummary>
      </OrganizerSearchSection>
      <OrganizerSearchSection variant="claim-pressure">
        <DirectoryClaimPressureCopy>
          <UiLabel>Claim pressure</UiLabel>
          <h2>Turn public profiles into owner-managed pages.</h2>
        </DirectoryClaimPressureCopy>
        <DirectoryClaimPressureStats
          items={[
            {label: "Claimable", value: "18"},
            {label: "Verified", value: "7"},
          ]}
        />
        <DirectoryClaimPressureList>
          <span>Attach source proof</span>
          <span>Review owner role</span>
          <span>Unlock responses</span>
        </DirectoryClaimPressureList>
        <DirectoryClaimPressureCta href="/claim/">Start claim</DirectoryClaimPressureCta>
      </OrganizerSearchSection>
    </>
  ),
};

export const ListingSectionsAssemblyStory: Story = {
  name: "Listing sections assembly",
  parameters: {
    catchComponent: {
      id: "listing_sections_assembly",
      routeIds: listingRouteIds,
      states: ["route-assembly"],
    },
  },
  render: () => (
    <QueryStoryFrame>
      <HostListingSections
        claimController={mockListingClaimController()}
        controller={mockHostListingController(claimableListing)}
        listing={claimableListing}
      />
    </QueryStoryFrame>
  ),
};

function QueryStoryFrame({children}: {children: ReactNode}) {
  return <WebsiteQueryProvider>{children}</WebsiteQueryProvider>;
}

function preventSubmit(event: FormEvent<HTMLFormElement>) {
  event.preventDefault();
}

function mockHostListingController(listing: HostListing): HostListingPageController {
  return {
    claimHref: claimHrefForListing(listing),
    footerLinks: [
      {href: "/host/", label: "For hosts"},
      {href: "#profile", label: "Profile"},
    ],
    handleSaveListing: () => undefined,
    handleShareListing: async () => undefined,
    hasEventSupply: Boolean(listing.catchEvents?.length || listing.externalEvents?.length),
    headerCtaLabel: "Claim listing",
    isAppCreated: false,
    isSaved: false,
    nav: [
      {href: "#profile", label: "Profile"},
      {href: "#reviews", label: "Reviews"},
      {href: "/organizers/", label: "Search"},
    ],
    shareStatus: "",
  };
}

function mockListingClaimController(
  overrides: Partial<ListingClaimController> = {}
): ListingClaimController {
  return {
    authReady: true,
    handleSignIn: async () => undefined,
    handleSignOut: async () => undefined,
    handleSubmit: async (event: FormEvent<HTMLFormElement>) => {
      event.preventDefault();
    },
    isConfigured: true,
    isSigningIn: false,
    isSubmitting: false,
    notConfiguredReason: "",
    publicApiEnabled: true,
    status: {message: "", tone: ""},
    user: null,
    ...overrides,
  };
}

function requireListing(slug: string) {
  const listing = hostListings.find((item) => item.slug === slug || item.id === slug);
  if (!listing) {
    throw new Error(`Missing generated organizer listing fixture: ${slug}`);
  }
  return listing;
}
