import {DemoContinuationWorkspace} from "./DemoContinuationWorkspace";
import {websiteCopy} from "@content/generated";
import {PublicSiteFooter, PublicSiteHeader} from "../../shared/site";
import {ClaimFlowMain} from "../../shared/ui/primitives";
import {
  ClaimHeroSection,
  ClaimUrlStateSection,
  ClaimWorkspaceSection,
} from "./sections/ClaimPageSections";
import type {ClaimRouteState} from "./claimRouting";
import {useClaimFlowController} from "./useClaimFlowController";

export function ClaimPage({routeState}: {routeState: ClaimRouteState}) {
  if (routeState.continuationId) return <DemoContinuationWorkspace key={routeState.continuationId} continuationId={routeState.continuationId} />;
  return <PublicClaimPage routeState={routeState} />;
}
function PublicClaimPage({routeState}: {routeState: ClaimRouteState}) {
  const controller = useClaimFlowController(routeState);
  const {claimUrlState} = controller;

  return (
    <>
      <PublicSiteHeader
        localNav={[
          {href: "/organizers/", label: websiteCopy["claimpage_0025"]},
          {href: "/host/", label: websiteCopy["claimpage_0027"]},
          {href: "/explore/#trust", label: websiteCopy["claimpage_0031"]},
        ]}
        localActions={[{href: "/host/#founding-hosts", label: websiteCopy["claimpage_0030"]}]}
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

      <PublicSiteFooter
        body={websiteCopy["claimpage_0024"]}
        links={[
          {href: "/organizers/", label: websiteCopy["claimpage_0029"]},
          {href: "/host/", label: websiteCopy["claimpage_0026"]},
          {href: "/explore/", label: websiteCopy["claimpage_0028"]},
        ]}
      />
    </>
  );
}
