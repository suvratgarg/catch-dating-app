import {useCallback} from "react";
import type {
  AppDownloadCtaGroupProps,
  AppDownloadCtaItem,
} from "../../shared/ui/primitives";
import {storeCtaCopy} from "@content/site";
import {trackMarketingEvent} from "../../analytics";
import {trackCtaClick} from "./tracking";

type AppDownloadCtaConfig = Pick<
  AppDownloadCtaGroupProps,
  "items" | "onPendingClick" | "onStoreLinkClick" | "placement"
>;

const storeUrls = {
  android: import.meta.env.VITE_PLAY_STORE_URL?.trim() ?? "",
  ios: import.meta.env.VITE_APP_STORE_URL?.trim() ?? "",
} satisfies Record<(typeof storeCtaCopy)[number]["platform"], string>;

const storeCtas: AppDownloadCtaItem[] = storeCtaCopy.map((store) => ({
  ...store,
  href: storeUrls[store.platform],
}));

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
