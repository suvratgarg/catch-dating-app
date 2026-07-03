import {useCallback} from "react";
import type {
  AppDownloadCtaGroupProps,
  AppDownloadCtaItem,
} from "../../shared/ui/primitives";
import {trackMarketingEvent} from "../../analytics";
import {storeCtas} from "./content";
import {trackCtaClick} from "./tracking";

type AppDownloadCtaConfig = Pick<
  AppDownloadCtaGroupProps,
  "items" | "onPendingClick" | "onStoreLinkClick" | "placement"
>;

export function useAppDownloadCtas({placement}: {placement: string}): AppDownloadCtaConfig {
  const handlePendingClick = useCallback(
    (store: AppDownloadCtaItem) => {
      trackMarketingEvent("store_cta_pending", {
        platform: store.platform,
        placement,
        page_path: `${window.location.pathname}${window.location.search}`,
      });
    },
    [placement]
  );

  const handleStoreLinkClick = useCallback(
    (store: AppDownloadCtaItem) => {
      trackCtaClick(`store_${placement}_${store.platform}`, store.href);
      trackMarketingEvent("store_cta_click", {
        platform: store.platform,
        placement,
        store_href: store.href,
        page_path: `${window.location.pathname}${window.location.search}`,
      });
    },
    [placement]
  );

  return {
    items: storeCtas,
    onPendingClick: handlePendingClick,
    onStoreLinkClick: handleStoreLinkClick,
    placement,
  };
}
