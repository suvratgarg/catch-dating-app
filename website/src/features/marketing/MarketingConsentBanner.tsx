import {websiteCopy} from "@content/generated";
import {marketingConsentPreferencesCopy} from "../../content/marketingConsent";
import {useEffect, useState} from "react";
import {
  getMarketingConsent,
  marketingConsentChangedEvent,
  setMarketingConsent,
  shouldShowMarketingConsentBanner,
} from "../../analytics";
import {Button, MarketingConsentBannerShell} from "../../shared/ui/primitives";

export function MarketingConsentBanner() {
  const [consent, setConsent] = useState(() => getMarketingConsent());

  useEffect(() => {
    const changed = () => setConsent(getMarketingConsent());
    window.addEventListener(marketingConsentChangedEvent, changed);
    return () => window.removeEventListener(marketingConsentChangedEvent, changed);
  }, []);
  const [editing, setEditing] = useState(false);
  const choose = (choice: "accepted" | "analytics" | "essential") => {
    setConsent(setMarketingConsent(choice));
    setEditing(false);
  };
  if (!editing && !shouldShowMarketingConsentBanner(consent)) {
    return <Button size="small" variant="ghost" type="button"
      onClick={() => setEditing(true)}>{marketingConsentPreferencesCopy.preferences}</Button>;
  }

  return (
    <MarketingConsentBannerShell
      aria-label={websiteCopy["marketingconsentbanner_0328"]}
      body={
        <>{marketingConsentPreferencesCopy.body}</>
      }
      actions={
        <>
          <Button
            size="small"
            type="button"
            onClick={() => choose("analytics")}
          >{marketingConsentPreferencesCopy.allowAnalytics}</Button>
          <Button size="small" type="button" onClick={() => choose("accepted")}>
            {marketingConsentPreferencesCopy.allowMarketing}
          </Button>
          <Button
            size="small"
            type="button"
            variant="ghost"
            onClick={() => choose("essential")}
          >{websiteCopy["marketingconsentbanner_0330"]}</Button>
        </>
      }
    />
  );
}
