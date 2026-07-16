import {websiteCopy} from "@content/generated";
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
      aria-label={websiteCopy["marketingconsentbanner_0328"]}
      body={
        <>{websiteCopy["marketingconsentbanner_0329"]}</>
      }
      actions={
        <>
          <Button
            size="small"
            type="button"
            onClick={() => setConsent(setMarketingConsent("accepted"))}
          >{websiteCopy["marketingconsentbanner_0327"]}</Button>
          <Button
            size="small"
            type="button"
            variant="ghost"
            onClick={() => setConsent(setMarketingConsent("essential"))}
          >{websiteCopy["marketingconsentbanner_0330"]}</Button>
        </>
      }
    />
  );
}
