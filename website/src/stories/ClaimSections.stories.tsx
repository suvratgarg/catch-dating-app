import type {Meta, StoryObj} from "@storybook/react-vite";
import type {Dispatch, FormEvent, SetStateAction} from "react";
import {
  ClaimHeroSection,
  ClaimUrlStateSection,
  ClaimWorkspaceSection,
} from "../features/claims/sections/ClaimPageSections";
import {
  claimVerificationMethods,
  type ClaimFlowStep,
  type ClaimRole,
  type ClaimVerificationMethodId,
} from "../features/claims/claimModel";
import type {ClaimFlowController} from "../features/claims/useClaimFlowController";
import {hostListings} from "./fixtures/hostListings";
import {isUnclaimedListing, isVerifiedListing} from "../features/organizers/selectors";
import type {HostListing} from "../features/organizers/types";

const claimableListing = hostListings.find(isUnclaimedListing) ?? requireListing("afterfly");
const claimedListing = hostListings.find(isVerifiedListing) ?? requireListing("club-sales-sunday-table");

const meta = {
  title: "Marketing Website/Claims/Sections",
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

export const ClaimHero: Story = {
  name: "Hero",
  parameters: {
    catchComponent: {
      id: "claim_hero_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["no-listing", "selected-listing"],
    },
  },
  render: () => <ClaimHeroSection listing={claimableListing} />,
};

export const ClaimUrlState: Story = {
  name: "URL state · already claimed",
  parameters: {
    catchComponent: {
      id: "claim_url_state_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["already-claimed"],
    },
  },
  render: () => (
    <ClaimUrlStateSection
      state="alreadyClaimed"
      listing={claimedListing}
      lookup={claimedListing.slug}
      requestId={null}
    />
  ),
};

export const ClaimUrlStatePending: Story = {
  name: "URL state · pending claim",
  parameters: {
    catchComponent: {
      id: "claim_url_state_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["pending-claim"],
    },
  },
  render: () => (
    <ClaimUrlStateSection
      state="pendingClaim"
      listing={claimableListing}
      lookup={claimableListing.slug}
      requestId="claim_req_123"
    />
  ),
};

export const ClaimUrlStateNotFound: Story = {
  name: "URL state · not found",
  parameters: {
    catchComponent: {
      id: "claim_url_state_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["not-found"],
    },
  },
  render: () => (
    <ClaimUrlStateSection
      state="notFound"
      listing={null}
      lookup="missing-organizer"
      requestId={null}
    />
  ),
};

export const ClaimWorkspace: Story = {
  name: "Workspace · verify",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "claim_workspace_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["verify"],
    },
  },
  render: () => (
    <ClaimWorkspaceSection
      controller={mockClaimController({
        currentStepIndex: 2,
        step: "verify",
      })}
    />
  ),
};

export const ClaimWorkspaceListingSearch: Story = {
  name: "Workspace · listing search",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "claim_workspace_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["listing-search"],
    },
  },
  render: () => (
    <ClaimWorkspaceSection
      controller={mockClaimController({
        currentStepIndex: 0,
        listing: null,
        query: "dinner",
        searchResults: [claimableListing],
        step: "listing",
      })}
    />
  ),
};

export const ClaimWorkspaceRole: Story = {
  name: "Workspace · role",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "claim_workspace_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["role"],
    },
  },
  render: () => (
    <ClaimWorkspaceSection
      controller={mockClaimController({
        currentStepIndex: 1,
        step: "role",
      })}
    />
  ),
};

export const ClaimWorkspaceSubmitted: Story = {
  name: "Workspace · submitted",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "claim_workspace_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["submitted"],
    },
  },
  render: () => (
    <ClaimWorkspaceSection
      controller={mockClaimController({
        currentStepIndex: 3,
        requestId: "claim_req_123",
        step: "submitted",
      })}
    />
  ),
};

function mockClaimController(overrides: Partial<ClaimFlowController> = {}): ClaimFlowController {
  const listing = claimableListing;
  const setString = noopSetter<string>();
  const setRole = noopSetter<ClaimRole>();
  const setStep = noopSetter<ClaimFlowStep>();
  const setVerificationMethod = noopSetter<ClaimVerificationMethodId>();

  return {
    activeRequestId: null,
    authReady: true,
    businessEmail: "host@example.com",
    businessPhone: "",
    canContinueRole: true,
    claimLookup: null,
    claimUrlState: null,
    currentStepIndex: 0,
    handleClaimSubmit: async (event: FormEvent<HTMLFormElement>) => {
      event.preventDefault();
    },
    handleSignIn: async () => undefined,
    handleSignOut: async () => undefined,
    isSigningIn: false,
    isSubmitting: false,
    listing,
    message: "",
    proofUrls: "https://example.com/events",
    query: listing.name,
    requesterName: "Taylor Host",
    requesterRole: "owner",
    requestId: null,
    searchResults: [listing],
    selectedMethod: claimVerificationMethods[0],
    selectListing: (_listing: HostListing) => undefined,
    setBusinessEmail: setString,
    setBusinessPhone: setString,
    setMessage: setString,
    setProofUrls: setString,
    setQuery: setString,
    setRequesterName: setString,
    setRequesterRole: setRole,
    setStep,
    setVerificationMethod,
    status: {message: "", tone: ""},
    step: "listing",
    user: null,
    verificationMethod: "publicProof",
    ...overrides,
  };
}

function noopSetter<T>(): Dispatch<SetStateAction<T>> {
  return () => undefined;
}

function requireListing(id: string): HostListing {
  const listing = hostListings.find((item) => item.id === id);
  if (!listing) {
    throw new Error(`Missing generated organizer listing fixture: ${id}`);
  }
  return listing;
}
