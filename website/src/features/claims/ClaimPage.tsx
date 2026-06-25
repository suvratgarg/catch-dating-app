import type {CSSProperties} from "react";
import {ProcessStatusPanel, SiteFooter, SiteHeader} from "../../components/site";
import {
  AuthStatusRow,
  Button,
  ButtonLink,
  ChoiceCard,
  FormStatus,
  PlainButton,
  SelectField,
  StepRail,
  TextActionButton,
  TextAreaField,
  TextField,
} from "../../shared/ui/primitives";
import {claimUnlocks} from "../marketing/content";
import {ActivityMark, StatusBadge} from "../organizers/OrganizerIdentity";
import {activityForListing} from "../organizers/publicDiscovery";
import type {ClaimUrlState} from "../organizers/routing";
import type {HostListing} from "../organizers/types";
import {
  claimFlowSteps,
  claimRoleOptions,
  claimVerificationMethods,
  claimWhileYouWaitItems,
  type ClaimRole,
} from "./claimModel";
import {useClaimFlowController} from "./useClaimFlowController";

export function ClaimPage() {
  const {
    activeRequestId,
    authReady,
    businessEmail,
    businessPhone,
    canContinueRole,
    claimLookup,
    claimUrlState,
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
  } = useClaimFlowController();

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "/organizers/", label: "Find listing"},
          {href: "/host/", label: "Host tools"},
          {href: "/#trust", label: "Trust"},
        ]}
        ctaHref="/host/#founding-hosts"
        ctaLabel="Start fresh"
      />

      <main className="claim-flow">
        <section className="claim-flow__hero">
          <div className="claim-flow__intro" data-reveal>
            <span className="ui-label">Claim your listing</span>
            <h1>Take control of how your events show up.</h1>
            <p>
              Find an unclaimed organizer page, prove your role, and send the
              operating packet Catch needs before owner tools unlock.
            </p>
          </div>
          <div className="claim-flow__summary" data-reveal>
            <strong>{listing?.name ?? "No listing selected"}</strong>
            <span>
              {listing ?
                `${listing.category} · ${listing.city} · ${listing.sourceConfidence.replaceAll("_", " ")}` :
                "Search the source-backed organizer directory first."}
            </span>
          </div>
        </section>

        {claimUrlState ? (
          <ClaimUrlStatePanel
            state={claimUrlState}
            listing={listing}
            lookup={claimLookup}
            requestId={activeRequestId}
          />
        ) : (
          <form className="claim-flow__workspace" onSubmit={handleClaimSubmit}>
          <StepRail
            currentIndex={currentStepIndex}
            getDisabled={(_item, index) => index > currentStepIndex}
            items={claimFlowSteps}
            label="Claim progress"
            onSelect={setStep}
          />

          <section className="claim-flow__panel" aria-live="polite">
            {step === "listing" ? (
              <div className="claim-flow__stage">
                <TextField
                  id="claim-search"
                  label="Search unclaimed listings"
                  value={query}
                  placeholder="Organizer, venue, category, or city"
                  onChange={(event) => setQuery(event.currentTarget.value)}
                />
                <div className="claim-listing-results">
                  {searchResults.map((item) => (
                    <PlainButton
                      className={listing?.id === item.id ? "claim-result is-selected" : "claim-result"}
                      key={item.id}
                      onClick={() => {
                        selectListing(item);
                      }}
                      type="button"
                      style={{"--activity": activityForListing(item).token} as CSSProperties}
                    >
                      <ActivityMark listing={item} size="sm" />
                      <span>
                        <strong>{item.name}</strong>
                        <small>{item.category} · {item.city} · {item.sources.length} sources</small>
                      </span>
                      <StatusBadge listing={item} compact />
                    </PlainButton>
                  ))}
                  {!searchResults.length ? (
                    <div className="claim-empty-state">
                      <strong>No unclaimed listing found.</strong>
                      <p>
                        Start as a fresh host so Catch can create the organizer
                        profile from first-party details.
                      </p>
                      <ButtonLink variant="ghost" href="/host/#founding-hosts">
                        Start fresh
                      </ButtonLink>
                    </div>
                  ) : null}
                </div>
                <div className="flow-actions">
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
                </div>
              </div>
            ) : null}

            {step === "role" && listing ? (
              <div className="claim-flow__stage">
                <div className="selected-listing-card">
                  <ActivityMark listing={listing} size="sm" />
                  <span>
                    <strong>{listing.name}</strong>
                    <small>{listing.category} · {listing.city}</small>
                  </span>
                  <TextActionButton onClick={() => setStep("listing")}>
                    Change
                  </TextActionButton>
                </div>

                <div className="flow-field-grid">
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
                </div>

                <div className="flow-actions">
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
                </div>
              </div>
            ) : null}

            {step === "verify" && listing ? (
              <div className="claim-flow__stage">
                <div>
                  <span className="ui-label">Verification method</span>
                  <h2>How Catch should verify ownership.</h2>
                  <p>
                    Approved claims attach this page to a host account before
                    editing, review responses, events, or analytics are unlocked.
                  </p>
                </div>

                <div className="verification-methods">
                  {claimVerificationMethods.map((method) => (
                    <ChoiceCard
                      body={method.body}
                      key={method.id}
                      onClick={() => setVerificationMethod(method.id)}
                      selected={verificationMethod === method.id}
                      title={method.title}
                    />
                  ))}
                </div>

                <div className="claim-review-grid">
                  <div>
                    <span className="ui-label">Claim packet</span>
                    <dl>
                      <div><dt>Listing</dt><dd>{listing.name}</dd></div>
                      <div><dt>Requester</dt><dd>{requesterName}</dd></div>
                      <div><dt>Role</dt><dd>{claimRoleOptions.find((option) => option.value === requesterRole)?.label}</dd></div>
                      <div><dt>Contact</dt><dd>{businessEmail || businessPhone || "Proof links only"}</dd></div>
                    </dl>
                  </div>
                  <div>
                    <span className="ui-label">Unlocks after approval</span>
                    <ul>
                      {claimUnlocks.map((item) => (
                        <li key={item}>{item}</li>
                      ))}
                    </ul>
                  </div>
                </div>

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
                  className="claim-auth-row--flow"
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

                <div className="flow-actions">
                  <Button variant="ghost" type="button" onClick={() => setStep("role")}>
                    Back
                  </Button>
                  <Button disabled={isSubmitting || !user} type="submit">
                    {isSubmitting ? "Submitting..." : "Submit claim"}
                  </Button>
                </div>
              </div>
            ) : null}

            {step === "submitted" && listing ? (
              <div className="claim-flow__stage">
                <ProcessStatusPanel
                  mark="✓"
                  eyebrow="Claim in review"
                  title={`${listing.name} is waiting for owner approval.`}
                  body={requestId ?
                    `Request ${requestId} is pending. Catch will verify ownership before attaching host tools.` :
                    "Catch will verify ownership before attaching host tools, review responses, event publishing, or analytics."}
                  items={claimWhileYouWaitItems(listing)}
                  actions={[
                    {href: listing.path, label: "View public listing", variant: "secondary"},
                    {href: "/host/", label: "Explore host tools", variant: "primary"},
                  ]}
                />
                <div className="owner-unlock-board">
                  {[
                    ["Profile", "Fix source details, description, photos, and event categories."],
                    ["Events", "Publish the first Catch event with admission, price, waitlist, and Event Success."],
                    ["Reviews", "Respond as owner and separate public reviews from verified attendee reviews."],
                    ["Reports", "Track attendance, catches, matches, repeat interest, and safety totals."],
                  ].map(([title, body]) => (
                    <article key={title}>
                      <span>{title}</span>
                      <p>{body}</p>
                    </article>
                  ))}
                </div>
              </div>
            ) : null}

            <FormStatus status={status} />
          </section>
          </form>
        )}
      </main>

      <SiteFooter
        brandHref="/"
        body="Claimable organizer profiles with verified owner review before host tools unlock."
        links={[
          {href: "/organizers/", label: "Organizer search"},
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
        ]}
      />
    </>
  );
}

function ClaimUrlStatePanel({
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
        actions={[
          {href: listing.path, label: "View public listing", variant: "primary"},
          {href: "/claim/", label: "Search claimable pages", variant: "secondary"},
          {href: "/host/#founding-hosts", label: "Start fresh", variant: "secondary"},
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
      actions={[
        {href: "/claim/", label: "Search claimable pages", variant: "primary"},
        {href: "/organizers/", label: "Open directory", variant: "secondary"},
        {href: "/host/#founding-hosts", label: "Start fresh", variant: "secondary"},
      ]}
    />
  );
}
