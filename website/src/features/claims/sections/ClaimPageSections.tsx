import {trackMarketingEvent} from "../../../analytics";
import {
  AuthStatusRow,
  ActionGroup,
  Button,
  ButtonLink,
  ClaimFlowHero,
  ClaimFlowPanel,
  ClaimFlowStage,
  ClaimFlowWorkspace,
  ClaimListingResults,
  ClaimResultButton,
  ChoiceCard,
  ContentGrid,
  EmptyState,
  FieldGrid,
  FormStatus,
  OwnerUnlockBoard,
  ProcessStatusPanel,
  type ProcessStatusAction,
  SelectField,
  SelectedListingCard,
  StepRail,
  TextActionButton,
  TextAreaField,
  TextField,
  UiLabel,
  VerificationMethodGrid,
} from "../../../shared/ui/primitives";
import {claimUnlocks} from "../../marketing/content";
import {ActivityMark, StatusBadge} from "../../organizers/OrganizerIdentity";
import {activityForListing} from "../../organizers/publicDiscovery";
import type {HostListing} from "../../organizers/types";
import type {ClaimUrlState} from "../claimRouting";
import {
  claimFlowSteps,
  claimRoleOptions,
  claimVerificationMethods,
  claimWhileYouWaitItems,
  type ClaimRole,
} from "../claimModel";
import type {ClaimFlowController} from "../useClaimFlowController";

function trackProcessStatusAction(action: ProcessStatusAction) {
  trackMarketingEvent("cta_click", {
    cta_href: action.href,
    cta_label: action.trackingLabel ?? "process_status_action",
    page_path: `${window.location.pathname}${window.location.search}`,
  });
}

export function ClaimHeroSection({listing}: {listing: HostListing | null}) {
  return (
    <ClaimFlowHero
      eyebrow="Claim your listing"
      title="Take control of how your events show up."
      body="Find an unclaimed organizer page, prove your role, and send the operating packet Catch needs before owner tools unlock."
      summaryTitle={listing?.name ?? "No listing selected"}
      summaryBody={listing ?
        `${listing.category} · ${listing.city} · ${listing.sourceConfidence.replaceAll("_", " ")}` :
        "Search the source-backed organizer directory first."}
    />
  );
}

export function ClaimWorkspaceSection({controller}: {controller: ClaimFlowController}) {
  const {
    authReady,
    businessEmail,
    businessPhone,
    canContinueRole,
    currentStepIndex,
    handleClaimSubmit,
    handleSignIn,
    handleSignOut,
    isSigningIn,
    isSubmitting,
    listing,
    message,
    proofUrls,
    query,
    requesterName,
    requesterRole,
    requestId,
    searchResults,
    selectListing,
    setBusinessEmail,
    setBusinessPhone,
    setMessage,
    setProofUrls,
    setQuery,
    setRequesterName,
    setRequesterRole,
    setStep,
    setVerificationMethod,
    status,
    step,
    user,
    verificationMethod,
  } = controller;

  return (
    <ClaimFlowWorkspace onSubmit={handleClaimSubmit}>
      <StepRail
        currentIndex={currentStepIndex}
        getDisabled={(_item, index) => index > currentStepIndex}
        items={claimFlowSteps}
        label="Claim progress"
        onSelect={setStep}
      />

      <ClaimFlowPanel aria-live="polite">
        {step === "listing" ? (
          <ClaimFlowStage>
            <TextField
              id="claim-search"
              label="Search unclaimed listings"
              value={query}
              placeholder="Organizer, venue, category, or city"
              onChange={(event) => setQuery(event.currentTarget.value)}
            />
            <ClaimListingResults>
              {searchResults.map((item) => (
                <ClaimResultButton
                  activityToken={activityForListing(item).token}
                  key={item.id}
                  onClick={() => {
                    selectListing(item);
                  }}
                  selected={listing?.id === item.id}
                >
                  <ActivityMark listing={item} size="sm" />
                  <span>
                    <strong>{item.name}</strong>
                    <small>{item.category} · {item.city} · {item.sources.length} sources</small>
                  </span>
                  <StatusBadge listing={item} compact />
                </ClaimResultButton>
              ))}
              {!searchResults.length ? (
                <EmptyState variant="claim">
                  <strong>No unclaimed listing found.</strong>
                  <p>
                    Start as a fresh host so Catch can create the organizer
                    profile from first-party details.
                  </p>
                  <ButtonLink variant="ghost" href="/host/#founding-hosts">
                    Start fresh
                  </ButtonLink>
                </EmptyState>
              ) : null}
            </ClaimListingResults>
            <ActionGroup>
              <ButtonLink variant="ghost" href="/host/#founding-hosts">
                My organizer is not listed
              </ButtonLink>
              <Button
                disabled={!listing}
                type="button"
                onClick={() => setStep("role")}
              >
                Continue
              </Button>
            </ActionGroup>
          </ClaimFlowStage>
        ) : null}

        {step === "role" && listing ? (
          <ClaimFlowStage>
            <SelectedListingCard>
              <ActivityMark listing={listing} size="sm" />
              <span>
                <strong>{listing.name}</strong>
                <small>{listing.category} · {listing.city}</small>
              </span>
              <TextActionButton onClick={() => setStep("listing")}>
                Change
              </TextActionButton>
            </SelectedListingCard>

            <FieldGrid>
              <TextField
                id="claim-name"
                label="Your name"
                value={requesterName}
                autoComplete="name"
                onChange={(event) => setRequesterName(event.currentTarget.value)}
                required
              />
              <SelectField
                id="claim-role"
                label="Role"
                value={requesterRole}
                onChange={(event) => setRequesterRole(event.currentTarget.value as ClaimRole)}
                required
              >
                {claimRoleOptions.map((option) => (
                  <option value={option.value} key={option.value}>
                    {option.label}
                  </option>
                ))}
              </SelectField>
              <TextField
                id="claim-email"
                label="Business email"
                type="email"
                value={businessEmail}
                autoComplete="email"
                onChange={(event) => setBusinessEmail(event.currentTarget.value)}
              />
              <TextField
                id="claim-phone"
                label="Business phone"
                type="tel"
                value={businessPhone}
                autoComplete="tel"
                onChange={(event) => setBusinessPhone(event.currentTarget.value)}
              />
              <TextAreaField
                id="claim-proof"
                label="Proof links"
                rows={3}
                value={proofUrls}
                placeholder="Official website, Instagram, Luma, Linktree, or event page"
                onChange={(event) => setProofUrls(event.currentTarget.value)}
                span
              />
            </FieldGrid>

            <ActionGroup>
              <Button variant="ghost" type="button" onClick={() => setStep("listing")}>
                Back
              </Button>
              <Button
                disabled={!canContinueRole}
                type="button"
                onClick={() => setStep("verify")}
              >
                Continue
              </Button>
            </ActionGroup>
          </ClaimFlowStage>
        ) : null}

        {step === "verify" && listing ? (
          <ClaimFlowStage>
            <div>
              <UiLabel>Verification method</UiLabel>
              <h2>How Catch should verify ownership.</h2>
              <p>
                Approved claims attach this page to a host account before
                editing, review responses, events, or analytics are unlocked.
              </p>
            </div>

            <VerificationMethodGrid>
              {claimVerificationMethods.map((method) => (
                <ChoiceCard
                  body={method.body}
                  key={method.id}
                  onClick={() => setVerificationMethod(method.id)}
                  selected={verificationMethod === method.id}
                  title={method.title}
                />
              ))}
            </VerificationMethodGrid>

            <ContentGrid variant="claim-review">
              <div>
                <UiLabel>Claim packet</UiLabel>
                <dl>
                  <div><dt>Listing</dt><dd>{listing.name}</dd></div>
                  <div><dt>Requester</dt><dd>{requesterName}</dd></div>
                  <div><dt>Role</dt><dd>{claimRoleOptions.find((option) => option.value === requesterRole)?.label}</dd></div>
                  <div><dt>Contact</dt><dd>{businessEmail || businessPhone || "Proof links only"}</dd></div>
                </dl>
              </div>
              <div>
                <UiLabel>Unlocks after approval</UiLabel>
                <ul>
                  {claimUnlocks.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </div>
            </ContentGrid>

            <TextAreaField
              id="claim-message"
              label="Note for review"
              rows={3}
              value={message}
              maxLength={1000}
              placeholder="Anything Catch should know before approving ownership"
              onChange={(event) => setMessage(event.currentTarget.value)}
            />

            <AuthStatusRow
              variant="flow"
              action={
                user ? (
                  <Button variant="ghost" onClick={() => void handleSignOut()} type="button">
                    Sign out
                  </Button>
                ) : (
                  <Button
                    variant="ghost"
                    disabled={!authReady || isSigningIn}
                    onClick={() => void handleSignIn()}
                    type="button"
                  >
                    {isSigningIn ? "Signing in..." : "Sign in"}
                  </Button>
                )
              }
            >
              {user ? (
                `Signed in as ${user.displayName || user.email || "Catch user"}`
              ) : authReady ? (
                "Sign in with Google to submit the claim."
              ) : (
                "Checking sign-in status."
              )}
            </AuthStatusRow>

            <ActionGroup>
              <Button variant="ghost" type="button" onClick={() => setStep("role")}>
                Back
              </Button>
              <Button disabled={isSubmitting || !user} type="submit">
                {isSubmitting ? "Submitting..." : "Submit claim"}
              </Button>
            </ActionGroup>
          </ClaimFlowStage>
        ) : null}

        {step === "submitted" && listing ? (
          <ClaimFlowStage>
            <ProcessStatusPanel
              mark="✓"
              eyebrow="Claim in review"
              title={`${listing.name} is waiting for owner approval.`}
              body={requestId ?
                `Request ${requestId} is pending. Catch will verify ownership before attaching host tools.` :
                "Catch will verify ownership before attaching host tools, review responses, event publishing, or analytics."}
              items={claimWhileYouWaitItems(listing)}
              onActionClick={trackProcessStatusAction}
              actions={[
                {href: listing.path, label: "View public listing", variant: "secondary"},
                {href: "/host/", label: "Explore host tools", variant: "primary"},
              ]}
            />
            <OwnerUnlockBoard
              items={[
                {title: "Profile", body: "Fix source details, description, photos, and event categories."},
                {title: "Events", body: "Publish the first Catch event with admission, price, waitlist, and Event Success."},
                {title: "Reviews", body: "Respond as owner and separate public reviews from verified attendee reviews."},
                {title: "Reports", body: "Track attendance, catches, matches, repeat interest, and safety totals."},
              ]}
            />
          </ClaimFlowStage>
        ) : null}

        <FormStatus status={status} />
      </ClaimFlowPanel>
    </ClaimFlowWorkspace>
  );
}

export function ClaimUrlStateSection({
  state,
  listing,
  lookup,
  requestId,
}: {
  state: ClaimUrlState;
  listing: HostListing | null;
  lookup: string | null;
  requestId: string | null;
}) {
  if (state === "alreadyClaimed" && listing) {
    return (
      <ProcessStatusPanel
        mark="C"
        eyebrow="Already claimed"
        title={`${listing.name} already has owner context.`}
        body="Catch does not open a second owner request from this public claim flow. Use the public profile, events, or organizer search instead."
        items={[
          {
            title: "Owner tools stay gated",
            body: "Edits, event publishing, review responses, and reports stay attached to the verified owner account.",
          },
          {
            title: "Public profile remains visible",
            body: "Members can still inspect source details, Catch events, reviews, and event outcomes from the profile.",
          },
          {
            title: "Need a different organizer?",
            body: "Search unclaimed seed pages or start fresh so Catch can review a new host packet.",
          },
        ]}
        onActionClick={trackProcessStatusAction}
        actions={[
          {href: listing.path, label: "View public listing", variant: "primary"},
          {href: "/claim/", label: "Search claimable pages", variant: "secondary"},
          {href: "/host/#founding-hosts", label: "Start fresh", variant: "secondary"},
        ]}
      />
    );
  }

  if (state === "claimUnavailable" && listing) {
    return (
      <ProcessStatusPanel
        mark="!"
        eyebrow="Claim setup in progress"
        title={`${listing.name} is not accepting owner requests yet.`}
        body="Catch has published this source-backed profile, but its owner-review target is not ready. No claim packet can be submitted from this page yet."
        items={[
          {
            title: "The public profile stays visible",
            body: "You can review the organizer facts and public sources while Catch finishes claim setup.",
          },
          {
            title: "No partial request is created",
            body: "Contact details and proof links are not collected until the verified claim target is available.",
          },
          {
            title: "Hosts can still start fresh",
            body: "Use the host application if you need to submit first-party organizer details now.",
          },
        ]}
        onActionClick={trackProcessStatusAction}
        actions={[
          {href: listing.path, label: "View public listing", variant: "primary"},
          {href: "/claim/", label: "Search claimable pages", variant: "secondary"},
          {href: "/host/#founding-hosts", label: "Apply as host", variant: "secondary"},
        ]}
      />
    );
  }

  if (state === "pendingClaim") {
    return (
      <ProcessStatusPanel
        mark="..."
        eyebrow="Claim in review"
        title={listing ? `${listing.name} is already in owner review.` : "This claim is in owner review."}
        body={requestId ?
          `Request ${requestId} is pending. Catch will verify ownership before attaching host tools.` :
          "Catch will verify ownership before attaching host tools, review responses, event publishing, or analytics."}
        items={claimWhileYouWaitItems(listing)}
        onActionClick={trackProcessStatusAction}
        actions={[
          ...(listing ? [{href: listing.path, label: "View public listing", variant: "secondary" as const}] : []),
          {href: "/host/", label: "Explore host tools", variant: "primary"},
          {href: "/claim/", label: "Search another page", variant: "secondary"},
        ]}
      />
    );
  }

  return (
    <ProcessStatusPanel
      mark="?"
      eyebrow="Listing not found"
      title={lookup ? `No claimable page matched "${lookup}".` : "No claimable page matched this link."}
      body="The claim URL does not match a generated organizer page. The owner can still apply as a fresh host or search the source-backed directory."
      items={[
        {
          title: "Check the directory",
          body: "Search by organizer name, city, format, or source event before starting a new packet.",
        },
        {
          title: "Start from first-party details",
          body: "If the page does not exist yet, the host application can create a cleaner first-party profile.",
        },
        {
          title: "Avoid duplicate claims",
          body: "Catch should only review ownership against a stable generated page or a fresh host packet.",
        },
      ]}
      onActionClick={trackProcessStatusAction}
      actions={[
        {href: "/claim/", label: "Search claimable pages", variant: "primary"},
        {href: "/organizers/", label: "Open directory", variant: "secondary"},
        {href: "/host/#founding-hosts", label: "Start fresh", variant: "secondary"},
      ]}
    />
  );
}
