import {useState} from "react";
import {
  getMarketingConsent,
  setMarketingConsent,
  shouldShowMarketingConsentBanner,
} from "../../analytics";
import {Button, MarketingConsentBannerShell} from "../../shared/ui/primitives";

export function MarketingConsentBanner() {
  const [consent, setConsent] = useState(() => getMarketingConsent());

  if (!shouldShowMarketingConsentBanner(consent)) return null;

  return (
    <MarketingConsentBannerShell
      aria-label="Analytics consent"
      body={
        <>
          Catch uses analytics and ad measurement to understand which campaigns
          bring real waitlist and host demand.
        </>
      }
      actions={
        <>
          <Button
            size="small"
            type="button"
            onClick={() => setConsent(setMarketingConsent("accepted"))}
          >
            Accept all
          </Button>
          <Button
            size="small"
            type="button"
            variant="ghost"
            onClick={() => setConsent(setMarketingConsent("essential"))}
          >
            Essential only
          </Button>
        </>
      }
    />
  );
}
