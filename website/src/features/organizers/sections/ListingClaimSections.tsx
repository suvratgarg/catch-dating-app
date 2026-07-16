import {websiteCopy} from "@content/generated";
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
import {claimUnlocks} from "@content/marketing";
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
        eyebrow={websiteCopy["listingclaimsections_0367"]}
        title={websiteCopy["listingclaimsections_0373"]}
        titleId="listing-missing-title"
        body={websiteCopy["listingclaimsections_0381"]}
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
      <UiLabel>{websiteCopy["listingclaimsections_0372"]}</UiLabel>
      <h3>{websiteCopy["listingclaimsections_0383"]}{listing.name}{websiteCopy["listingclaimsections_0370"]}</h3>
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
      >{websiteCopy["listingclaimsections_0371"]}</ButtonLink>
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
          <UiLabel>{websiteCopy["listingclaimsections_0371"]}</UiLabel>
          <h3>{websiteCopy["listingclaimsections_0376"]}</h3>
          <p>
            {notConfiguredReason}{websiteCopy["listingclaimsections_0382"]}</p>
        </div>
        <ButtonLink
          href="/host/#founding-hosts"
          onClick={() => trackCtaClick("listing_claim_fallback", "/host/#founding-hosts")}
        >{websiteCopy["listingclaimsections_0365"]}</ButtonLink>
      </ClaimRequestPanel>
    );
  }

  return (
    <ClaimRequestPanel id="claim" reveal>
      <ClaimRequestPanelHeading>
        <UiLabel>{websiteCopy["listingclaimsections_0371"]}</UiLabel>
        <h3>{websiteCopy["listingclaimsections_0378"]}{listing.name}</h3>
        <p>{websiteCopy["listingclaimsections_0366"]}</p>
      </ClaimRequestPanelHeading>

      <AuthStatusRow
        action={
          user ? (
            <Button
              variant="ghost"
              onClick={() => void handleSignOut()}
              type="button"
            >{websiteCopy["listingclaimsections_0380"]}</Button>
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
          label={websiteCopy["listingclaimsections_0384"]}
          name="requesterName"
          autoComplete="name"
          defaultValue={user?.displayName ?? ""}
          required
        />
        <SelectField
          id={`claim-${listing.id}-requester-role`}
          label={websiteCopy["listingclaimsections_0379"]}
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
          label={websiteCopy["listingclaimsections_0368"]}
          name="businessEmail"
          type="email"
          autoComplete="email"
          defaultValue={user?.email ?? ""}
        />
        <TextField
          id={`claim-${listing.id}-business-phone`}
          label={websiteCopy["listingclaimsections_0369"]}
          name="businessPhone"
          type="tel"
          autoComplete="tel"
        />
        <TextAreaField
          id={`claim-${listing.id}-proof-urls`}
          label={websiteCopy["listingclaimsections_0377"]}
          name="proofUrls"
          rows={3}
          placeholder={websiteCopy["listingclaimsections_0375"]}
          span
        />
        <TextAreaField
          id={`claim-${listing.id}-message`}
          label={websiteCopy["listingclaimsections_0374"]}
          name="message"
          rows={3}
          maxLength={1000}
          placeholder={websiteCopy["listingclaimsections_0364"]}
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
