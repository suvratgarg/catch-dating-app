import {CatchField} from "@catch/web-ui";
import {websiteCopy} from "@content/generated";
import {
  AuthStatusRow,
  Button,
  ButtonLink,
  ClaimBandGrid,
  ClaimBandRail,
  ClaimBandSection,
  ClaimRequestForm,
  ClaimRequestPanel,
  ClaimRequestPanelHeading,
  FormStatus,
  ListingSectionIntro,
  PanelShell,
  UiLabel,
} from "../../../shared/ui/primitives";
import {claimRoleOptions} from "../../claims/claimModel";
import type {ListingClaimController} from "../../claims/useListingClaimController";
import {claimUnlocks} from "@content/marketing";
import {organizerListingCopy} from "@content/organizer";
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
        eyebrow={organizerListingCopy.claims.introEyebrow}
        title={organizerListingCopy.claims.introTitle}
        titleId="listing-missing-title"
        body={organizerListingCopy.claims.introBody}
      />
      <ClaimBandGrid>
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
      <h3>
        {websiteCopy["listingclaimsections_0383"]} {listing.name}{" "}
        {websiteCopy["listingclaimsections_0370"]}
      </h3>
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
    isSigningIn,
    isSubmitting,
    notConfiguredReason,
    presentation,
    status,
    user,
  } = controller;

  if (presentation.panel === "runtimeFallback") {
    return (
      <ClaimRequestPanel id="claim" reveal>
        <div>
          <UiLabel>{websiteCopy["listingclaimsections_0371"]}</UiLabel>
          <h3>{websiteCopy["listingclaimsections_0376"]}</h3>
          <p>
            {notConfiguredReason} {websiteCopy["listingclaimsections_0382"]}</p>
        </div>
        <ButtonLink
          href="/host/apply/"
          onClick={() => trackCtaClick("listing_claim_fallback", "/host/apply/")}
        >{websiteCopy["listingclaimsections_0365"]}</ButtonLink>
      </ClaimRequestPanel>
    );
  }

  return (
    <ClaimRequestPanel id="claim" reveal>
      <ClaimRequestPanelHeading>
        <UiLabel>{websiteCopy["listingclaimsections_0371"]}</UiLabel>
        <h3>{websiteCopy["listingclaimsections_0378"]} {listing.name}</h3>
        <p>{websiteCopy["listingclaimsections_0366"]}</p>
      </ClaimRequestPanelHeading>

      <AuthStatusRow
        action={
          user ? (
            <Button
              disabled={isSubmitting}
              variant="ghost"
              onClick={() => void handleSignOut()}
              type="button"
            >{websiteCopy["listingclaimsections_0380"]}</Button>
          ) : (
            <Button
              disabled={!authReady || isSigningIn || isSubmitting}
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

      <ClaimRequestForm onSubmit={handleSubmit} pending={isSubmitting}>
        <CatchField
          recipe="input"
          id={`claim-${listing.id}-requester-name`}
          title={websiteCopy["listingclaimsections_0384"]}
          name="requesterName"
          autoComplete="name"
          initialValue={user?.displayName ?? ""}
          required
        />
        <CatchField
          recipe="select"
          id={`claim-${listing.id}-requester-role`}
          title={websiteCopy["listingclaimsections_0379"]}
          name="requesterRole"
          values={claimRoleOptions}
          itemLabelBuilder={(option) => option.label}
          itemValueBuilder={(option) => option.value}
          initialValue={claimRoleOptions.find((option) => option.value === "owner")}
          required
        />
        <CatchField
          recipe="input"
          id={`claim-${listing.id}-business-email`}
          title={websiteCopy["listingclaimsections_0368"]}
          name="businessEmail"
          autoComplete="email"
          initialValue={user?.email ?? ""}
          keyboardType="emailAddress"
        />
        <CatchField
          recipe="input"
          id={`claim-${listing.id}-business-phone`}
          title={websiteCopy["listingclaimsections_0369"]}
          name="businessPhone"
          autoComplete="tel"
          keyboardType="phone"
        />
        <CatchField
          recipe="input"
          id={`claim-${listing.id}-proof-urls`}
          title={websiteCopy["listingclaimsections_0377"]}
          name="proofUrls"
          maxLines={3}
          inputHint={websiteCopy["listingclaimsections_0375"]}
        />
        <CatchField
          recipe="input"
          id={`claim-${listing.id}-message`}
          title={websiteCopy["listingclaimsections_0374"]}
          name="message"
          maxLines={3}
          maxLength={1000}
          inputHint={websiteCopy["listingclaimsections_0364"]}
        />
        <Button disabled={!user || isSubmitting} type="submit">
          {isSubmitting ? "Submitting..." : "Request claim"}
        </Button>
        <FormStatus status={status} />
      </ClaimRequestForm>
    </ClaimRequestPanel>
  );
}
