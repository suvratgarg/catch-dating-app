import {
  AuthStatusRow,
  Button,
  ButtonLink,
  ClaimBandGrid,
  ClaimBandRail,
  ClaimBandSection,
  ClaimMissingEvidenceList,
  ClaimRequestForm,
  ClaimRequestPanel,
  ClaimRequestPanelHeading,
  FormStatus,
  ListingSectionIntro,
  PanelShell,
  SelectField,
  TextAreaField,
  TextField,
  UiLabel,
} from "../../../shared/ui/primitives";
import {claimRoleOptions} from "../../claims/claimModel";
import type {ListingClaimController} from "../../claims/useListingClaimController";
import {claimUnlocks} from "../../marketing/content";
import {trackCtaClick} from "../../marketing/tracking";
import {trackOrganizerAnalytics} from "../analytics";
import {claimHrefForListing} from "../routing";
import type {HostListing} from "../types";

export function ListingMissingEvidenceSection({
  claimController,
  listing,
}: {
  claimController: ListingClaimController;
  listing: HostListing;
}) {
  return (
    <ClaimBandSection aria-labelledby="listing-missing-title">
      <ListingSectionIntro
        eyebrow="Before public indexing"
        title="Missing evidence"
        titleId="listing-missing-title"
        body="This is the pressure mechanic from the prototype: visitors can see what is known, what is missing, and why a verified Catch profile earns stronger placement."
      />
      <ClaimBandGrid>
        <ClaimMissingEvidenceList items={listing.missingEvidence} />
        <ClaimBandRail>
          <ClaimUnlocksCard listing={listing} />
          <ClaimListingPanel controller={claimController} listing={listing} />
        </ClaimBandRail>
      </ClaimBandGrid>
    </ClaimBandSection>
  );
}

function ClaimUnlocksCard({listing}: {listing: HostListing}) {
  const claimHref = claimHrefForListing(listing);
  return (
    <PanelShell variant="claim-unlocks" as="aside" reveal>
      <UiLabel>Claiming unlocks</UiLabel>
      <h3>What {listing.name} cannot show yet.</h3>
      <ul>
        {claimUnlocks.map((item) => (
          <li key={item}>{item}</li>
        ))}
      </ul>
      <ButtonLink
        href={claimHref}
        onClick={() => {
          trackCtaClick("claim_unlocks_panel", claimHref);
          trackOrganizerAnalytics(listing, "claimClick", "claim_unlocks_panel");
        }}
      >
        Claim this listing
      </ButtonLink>
    </PanelShell>
  );
}

function ClaimListingPanel({
  controller,
  listing,
}: {
  controller: ListingClaimController;
  listing: HostListing;
}) {
  const {
    authReady,
    handleSignIn,
    handleSignOut,
    handleSubmit,
    isConfigured,
    isSigningIn,
    isSubmitting,
    notConfiguredReason,
    status,
    user,
  } = controller;

  if (!isConfigured) {
    return (
      <ClaimRequestPanel id="claim" reveal>
        <div>
          <UiLabel>Claim this listing</UiLabel>
          <h3>Owner review is not enabled for this listing.</h3>
          <p>
            {notConfiguredReason} Use the host application while this public
            claim flow is being connected.
          </p>
        </div>
        <ButtonLink
          href="/host/#founding-hosts"
          onClick={() => trackCtaClick("listing_claim_fallback", "/host/#founding-hosts")}
        >
          Apply as host
        </ButtonLink>
      </ClaimRequestPanel>
    );
  }

  return (
    <ClaimRequestPanel id="claim" reveal>
      <ClaimRequestPanelHeading>
        <UiLabel>Claim this listing</UiLabel>
        <h3>Request ownership for {listing.name}</h3>
        <p>
          Approved claims attach this profile to a Catch host account before
          owner tools or responses are unlocked.
        </p>
      </ClaimRequestPanelHeading>

      <AuthStatusRow
        action={
          user ? (
            <Button
              variant="ghost"
              onClick={() => void handleSignOut()}
              type="button"
            >
              Sign out
            </Button>
          ) : (
            <Button
              disabled={!authReady || isSigningIn}
              onClick={() => void handleSignIn()}
              type="button"
            >
              {isSigningIn ? "Signing in..." : "Sign in"}
            </Button>
          )
        }
      >
        {user ?
          `Signed in as ${user.displayName || user.email || "Catch user"}` :
          authReady ?
            "Sign in to request ownership." :
            "Checking sign-in status."}
      </AuthStatusRow>

      <ClaimRequestForm onSubmit={handleSubmit}>
        <TextField
          id={`claim-${listing.id}-requester-name`}
          label="Your name"
          name="requesterName"
          autoComplete="name"
          defaultValue={user?.displayName ?? ""}
          required
        />
        <SelectField
          id={`claim-${listing.id}-requester-role`}
          label="Role"
          name="requesterRole"
          defaultValue="owner"
          required
        >
          {claimRoleOptions.map((option) => (
            <option value={option.value} key={option.value}>
              {option.label}
            </option>
          ))}
        </SelectField>
        <TextField
          id={`claim-${listing.id}-business-email`}
          label="Business email"
          name="businessEmail"
          type="email"
          autoComplete="email"
          defaultValue={user?.email ?? ""}
        />
        <TextField
          id={`claim-${listing.id}-business-phone`}
          label="Business phone"
          name="businessPhone"
          type="tel"
          autoComplete="tel"
        />
        <TextAreaField
          id={`claim-${listing.id}-proof-urls`}
          label="Proof links"
          name="proofUrls"
          rows={3}
          placeholder="Official website, Instagram, Luma, Linktree, or event page"
          span
        />
        <TextAreaField
          id={`claim-${listing.id}-message`}
          label="Note for review"
          name="message"
          rows={3}
          maxLength={1000}
          placeholder="Anything Catch should know before approving ownership"
          span
        />
        <Button disabled={!user || isSubmitting} type="submit">
          {isSubmitting ? "Submitting..." : "Request claim"}
        </Button>
        <FormStatus status={status} />
      </ClaimRequestForm>
    </ClaimRequestPanel>
  );
}
