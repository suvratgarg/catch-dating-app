import {useState} from "react";
import {getMarketingConsent, setMarketingConsent} from "../../analytics";
import {Button} from "../../shared/ui/primitives";

export function MarketingConsentBanner() {
  const [consent, setConsent] = useState(() => getMarketingConsent());

  if (consent) return null;

  return (
    <aside className="consent-banner" aria-label="Analytics consent">
      <p>
        Catch uses analytics and ad measurement to understand which campaigns
        bring real waitlist and host demand.
      </p>
      <div>
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
      </div>
    </aside>
  );
}
