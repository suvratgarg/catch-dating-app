import {websiteCopy} from "@content/generated";
import {websiteTemplates} from "@content/templates";
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
import {claimUnlocks} from "@content/marketing";
import {ActivityMark, StatusBadge} from "../../organizers/OrganizerIdentity";
import {activityForListing} from "../../organizers/publicDiscovery";
import {organizerPolicyForListing} from "../../organizers/organizerPolicy";
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
  const policy = listing ? organizerPolicyForListing(listing) : null;
  return (
    <ClaimFlowHero
      eyebrow={websiteCopy["claimpagesections_0049"]}
      title={websiteCopy["claimpagesections_0092"]}
      body={websiteCopy["claimpagesections_0056"]}
      summaryTitle={listing?.name ?? "No listing selected"}
      summaryBody={listing ?
        `${listing.category} · ${listing.city} · ${policy?.badge.label}` :
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
    claimRuntimeAvailable,
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
    <ClaimFlowWorkspace
      onSubmit={handleClaimSubmit}
      pending={isSubmitting}
    >
      <StepRail
        currentIndex={currentStepIndex}
        getDisabled={(_item, index) => index > currentStepIndex}
        items={claimFlowSteps}
        label={websiteCopy["claimpagesections_0047"]}
        onSelect={setStep}
      />

      <ClaimFlowPanel aria-live="polite">
        {step === "listing" ? (
          <ClaimFlowStage>
            <TextField
              id="claim-search"
              label={websiteCopy["claimpagesections_0085"]}
              value={query}
              placeholder={websiteCopy["claimpagesections_0071"]}
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
                    <small>
                      {item.category} · {item.city} · {item.sources.length}{" "}
                      {websiteCopy["claimpagesections_0088"]}
                    </small>
                  </span>
                  <StatusBadge listing={item} compact />
                </ClaimResultButton>
              ))}
              {!searchResults.length ? (
                <EmptyState variant="claim">
                  <strong>{websiteCopy["claimpagesections_0067"]}</strong>
                  <p>{websiteCopy["claimpagesections_0089"]}</p>
                  <ButtonLink variant="ghost" href="/host/#founding-hosts">{websiteCopy["claimpagesections_0090"]}</ButtonLink>
                </EmptyState>
              ) : null}
            </ClaimListingResults>
            <ActionGroup>
              <ButtonLink variant="ghost" href="/host/#founding-hosts">{websiteCopy["claimpagesections_0064"]}</ButtonLink>
              <Button
                disabled={!listing}
                type="button"
                onClick={() => setStep("role")}
              >{websiteCopy["claimpagesections_0052"]}</Button>
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
              <TextActionButton onClick={() => setStep("listing")}>{websiteCopy["claimpagesections_0043"]}</TextActionButton>
            </SelectedListingCard>

            <FieldGrid>
              <TextField
                id="claim-name"
                label={websiteCopy["claimpagesections_0101"]}
                value={requesterName}
                autoComplete="name"
                onChange={(event) => setRequesterName(event.currentTarget.value)}
                required
              />
              <SelectField
                id="claim-role"
                label={websiteCopy["claimpagesections_0081"]}
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
                label={websiteCopy["claimpagesections_0038"]}
                type="email"
                value={businessEmail}
                autoComplete="email"
                onChange={(event) => setBusinessEmail(event.currentTarget.value)}
              />
              <TextField
                id="claim-phone"
                label={websiteCopy["claimpagesections_0039"]}
                type="tel"
                value={businessPhone}
                autoComplete="tel"
                onChange={(event) => setBusinessPhone(event.currentTarget.value)}
              />
              <TextAreaField
                id="claim-proof"
                label={websiteCopy["claimpagesections_0074"]}
                rows={3}
                value={proofUrls}
                placeholder={websiteCopy["claimpagesections_0069"]}
                onChange={(event) => setProofUrls(event.currentTarget.value)}
                span
              />
            </FieldGrid>

            <ActionGroup>
              <Button variant="ghost" type="button" onClick={() => setStep("listing")}>{websiteCopy["claimpagesections_0037"]}</Button>
              <Button
                disabled={!canContinueRole}
                type="button"
                onClick={() => setStep("verify")}
              >{websiteCopy["claimpagesections_0052"]}</Button>
            </ActionGroup>
          </ClaimFlowStage>
        ) : null}

        {step === "verify" && listing ? (
          <ClaimFlowStage>
            <div>
              <UiLabel>{websiteCopy["claimpagesections_0098"]}</UiLabel>
              <h2>{websiteCopy["claimpagesections_0059"]}</h2>
              <p>{websiteCopy["claimpagesections_0035"]}</p>
            </div>

            <VerificationMethodGrid aria-label={websiteCopy["claimpagesections_0059"]}>
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
                <UiLabel>{websiteCopy["claimpagesections_0046"]}</UiLabel>
                <dl>
                  <div><dt>{websiteCopy["claimpagesections_0061"]}</dt><dd>{listing.name}</dd></div>
                  <div><dt>{websiteCopy["claimpagesections_0078"]}</dt><dd>{requesterName}</dd></div>
                  <div><dt>{websiteCopy["claimpagesections_0081"]}</dt><dd>{claimRoleOptions.find((option) => option.value === requesterRole)?.label}</dd></div>
                  <div><dt>{websiteCopy["claimpagesections_0050"]}</dt><dd>{businessEmail || businessPhone || "Proof links only"}</dd></div>
                </dl>
              </div>
              <div>
                <UiLabel>{websiteCopy["claimpagesections_0096"]}</UiLabel>
                <ul>
                  {claimUnlocks.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </div>
            </ContentGrid>

            <TextAreaField
              id="claim-message"
              label={websiteCopy["claimpagesections_0068"]}
              rows={3}
              value={message}
              maxLength={1000}
              placeholder={websiteCopy["claimpagesections_0033"]}
              onChange={(event) => setMessage(event.currentTarget.value)}
            />

            <AuthStatusRow
              variant="flow"
              action={
                user ? (
                  <Button variant="ghost" onClick={() => void handleSignOut()} type="button">{websiteCopy["claimpagesections_0087"]}</Button>
                ) : (
                  <Button
                    variant="ghost"
                    disabled={!claimRuntimeAvailable || !authReady || isSigningIn}
                    onClick={() => void handleSignIn()}
                    type="button"
                  >
                    {isSigningIn ? "Signing in..." : "Sign in"}
                  </Button>
                )
              }
            >
              {!claimRuntimeAvailable ? (
                "Claim submission is unavailable in this website build."
              ) : user ? (
                `Signed in as ${user.displayName || user.email || "Catch user"}`
              ) : authReady ? (
                "Sign in with Google to submit the claim."
              ) : (
                "Checking sign-in status."
              )}
            </AuthStatusRow>

            <ActionGroup>
              <Button variant="ghost" type="button" onClick={() => setStep("role")}>{websiteCopy["claimpagesections_0037"]}</Button>
              <Button
                disabled={!claimRuntimeAvailable || isSubmitting || !user}
                type="submit"
              >
                {isSubmitting ? "Submitting..." : "Submit claim"}
              </Button>
            </ActionGroup>
          </ClaimFlowStage>
        ) : null}

        {step === "submitted" && listing ? (
          <ClaimFlowStage>
            <ProcessStatusPanel
              mark="✓"
              eyebrow={websiteCopy["claimpagesections_0045"]}
              title={websiteTemplates.listingOwnerPending(listing.name)}
              body={requestId ?
                `Request ${requestId} is pending. Catch will verify ownership before attaching host tools.` :
                "Catch will verify ownership before attaching host tools, review responses, event publishing, or analytics."}
              items={claimWhileYouWaitItems(listing)}
              onActionClick={trackProcessStatusAction}
              actions={[
                {href: listing.path, label: websiteCopy["claimpagesections_0099"], variant: "secondary"},
                {href: "/host/", label: websiteCopy["claimpagesections_0055"], variant: "primary"},
              ]}
            />
            <OwnerUnlockBoard
              items={[
                {title: websiteCopy["claimpagesections_0073"], body: websiteCopy["claimpagesections_0057"]},
                {title: websiteCopy["claimpagesections_0054"], body: websiteCopy["claimpagesections_0076"]},
                {title: websiteCopy["claimpagesections_0080"], body: websiteCopy["claimpagesections_0079"]},
                {title: websiteCopy["claimpagesections_0077"], body: websiteCopy["claimpagesections_0095"]},
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
        eyebrow={websiteCopy["claimpagesections_0032"]}
        title={websiteTemplates.listingHasOwner(listing.name)}
        body={websiteCopy["claimpagesections_0040"]}
        items={[
          {
            title: websiteCopy["claimpagesections_0072"],
            body: websiteCopy["claimpagesections_0053"],
          },
          {
            title: websiteCopy["claimpagesections_0075"],
            body: websiteCopy["claimpagesections_0063"],
          },
          {
            title: websiteCopy["claimpagesections_0065"],
            body: websiteCopy["claimpagesections_0086"],
          },
        ]}
        onActionClick={trackProcessStatusAction}
        actions={[
          {href: listing.path, label: websiteCopy["claimpagesections_0099"], variant: "primary"},
          {href: "/claim/", label: websiteCopy["claimpagesections_0084"], variant: "secondary"},
          {href: "/host/#founding-hosts", label: websiteCopy["claimpagesections_0090"], variant: "secondary"},
        ]}
      />
    );
  }

  if (state === "claimUnavailable" && listing) {
    return (
      <ProcessStatusPanel
        mark="!"
        eyebrow={websiteCopy["claimpagesections_0048"]}
        title={websiteTemplates.listingClaimUnavailable(listing.name)}
        body={websiteCopy["claimpagesections_0041"]}
        items={[
          {
            title: websiteCopy["claimpagesections_0094"],
            body: websiteCopy["claimpagesections_0100"],
          },
          {
            title: websiteCopy["claimpagesections_0066"],
            body: websiteCopy["claimpagesections_0051"],
          },
          {
            title: websiteCopy["claimpagesections_0058"],
            body: websiteCopy["claimpagesections_0097"],
          },
        ]}
        onActionClick={trackProcessStatusAction}
        actions={[
          {href: listing.path, label: websiteCopy["claimpagesections_0099"], variant: "primary"},
          {href: "/claim/", label: websiteCopy["claimpagesections_0084"], variant: "secondary"},
          {href: "/host/#founding-hosts", label: websiteCopy["claimpagesections_0034"], variant: "secondary"},
        ]}
      />
    );
  }

  if (state === "pendingClaim") {
    return (
      <ProcessStatusPanel
        mark="..."
        eyebrow={websiteCopy["claimpagesections_0045"]}
        title={listing ? `${listing.name} is already in owner review.` : "This claim is in owner review."}
        body={requestId ?
          `Request ${requestId} is pending. Catch will verify ownership before attaching host tools.` :
          "Catch will verify ownership before attaching host tools, review responses, event publishing, or analytics."}
        items={claimWhileYouWaitItems(listing)}
        onActionClick={trackProcessStatusAction}
        actions={[
          ...(listing ? [{href: listing.path, label: websiteCopy["claimpagesections_0099"], variant: "secondary" as const}] : []),
          {href: "/host/", label: websiteCopy["claimpagesections_0055"], variant: "primary"},
          {href: "/claim/", label: websiteCopy["claimpagesections_0082"], variant: "secondary"},
        ]}
      />
    );
  }

  return (
    <ProcessStatusPanel
      mark="?"
      eyebrow={websiteCopy["claimpagesections_0062"]}
      title={lookup ? `No claimable page matched "${lookup}".` : "No claimable page matched this link."}
      body={websiteCopy["claimpagesections_0093"]}
      items={[
        {
          title: websiteCopy["claimpagesections_0044"],
          body: websiteCopy["claimpagesections_0083"],
        },
        {
          title: websiteCopy["claimpagesections_0091"],
          body: websiteCopy["claimpagesections_0060"],
        },
        {
          title: websiteCopy["claimpagesections_0036"],
          body: websiteCopy["claimpagesections_0042"],
        },
      ]}
      onActionClick={trackProcessStatusAction}
      actions={[
        {href: "/claim/", label: websiteCopy["claimpagesections_0084"], variant: "primary"},
        {href: "/organizers/", label: websiteCopy["claimpagesections_0070"], variant: "secondary"},
        {href: "/host/#founding-hosts", label: websiteCopy["claimpagesections_0090"], variant: "secondary"},
      ]}
    />
  );
}
