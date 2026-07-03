import {SiteFooter, SiteHeader} from "../../shared/site";
import {ClaimFlowMain} from "../../shared/ui/primitives";
import {
  ClaimHeroSection,
  ClaimUrlStateSection,
  ClaimWorkspaceSection,
} from "./sections/ClaimPageSections";
import type {ClaimRouteState} from "./claimRouting";
import {useClaimFlowController} from "./useClaimFlowController";

export function ClaimPage({routeState}: {routeState: ClaimRouteState}) {
  const controller = useClaimFlowController(routeState);
  const {claimUrlState} = controller;

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

      <ClaimFlowMain>
        <ClaimHeroSection listing={controller.listing} />

        {claimUrlState ? (
          <ClaimUrlStateSection
            state={claimUrlState}
            listing={controller.listing}
            lookup={controller.claimLookup}
            requestId={controller.activeRequestId}
          />
        ) : (
          <ClaimWorkspaceSection controller={controller} />
        )}
      </ClaimFlowMain>

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
