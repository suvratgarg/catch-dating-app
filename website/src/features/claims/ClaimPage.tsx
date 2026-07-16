import {websiteCopy} from "@content/generated";
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
          {href: "/organizers/", label: websiteCopy["claimpage_0025"]},
          {href: "/host/", label: websiteCopy["claimpage_0027"]},
          {href: "/#trust", label: websiteCopy["claimpage_0031"]},
        ]}
        ctaHref="/host/#founding-hosts"
        ctaLabel={websiteCopy["claimpage_0030"]}
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
        body={websiteCopy["claimpage_0024"]}
        links={[
          {href: "/organizers/", label: websiteCopy["claimpage_0029"]},
          {href: "/host/", label: websiteCopy["claimpage_0026"]},
          {href: "/", label: websiteCopy["claimpage_0028"]},
        ]}
      />
    </>
  );
}
