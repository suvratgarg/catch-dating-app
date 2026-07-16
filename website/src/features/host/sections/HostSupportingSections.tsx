import {
  HostPreviewFaqList,
  HostPreviewOfferCard,
  HostPreviewOfferShell,
  HostPreviewOfferSteps,
  HostPreviewSection,
  HostPreviewSectionHead,
  HostPreviewTrustGrid,
} from "../../../shared/ui/primitives";
import {
  hostFaq,
  hostFaqs,
  hostFoundingOffer,
  hostTrust,
  hostTrustItems,
} from "@content/host";

export function HostFoundingOfferSection() {
  return (
    <HostPreviewOfferShell id="offer" aria-labelledby="host-offer-title">
      <HostPreviewOfferCard
        badgeAriaLabel={hostFoundingOffer.badgeAriaLabel}
        badgeLabel={hostFoundingOffer.badgeLabel}
        badgeValue={hostFoundingOffer.badgeValue}
        body={hostFoundingOffer.body}
        reveal
        title={hostFoundingOffer.title}
        titleId="host-offer-title"
      />
      <HostPreviewOfferSteps items={hostFoundingOffer.steps} reveal />
    </HostPreviewOfferShell>
  );
}

export function HostTrustSection() {
  return (
    <HostPreviewSection variant="trust" aria-labelledby="host-trust-title">
      <HostPreviewSectionHead
        body={hostTrust.body}
        reveal
        title={hostTrust.title}
        titleId="host-trust-title"
      />
      <HostPreviewTrustGrid items={hostTrustItems} reveal />
    </HostPreviewSection>
  );
}

export function HostFaqSection() {
  return (
    <HostPreviewSection variant="faq" aria-labelledby="host-faq-title">
      <HostPreviewSectionHead
        reveal
        title={hostFaq.title}
        titleId="host-faq-title"
      />
      <HostPreviewFaqList items={hostFaqs} reveal />
    </HostPreviewSection>
  );
}
