import {type MouseEvent, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {PlainButton, PlainLink} from "../../shared/ui/primitives";
import {storeCtas, type StoreCta} from "./content";
import {trackCtaClick} from "./tracking";

export function AppDownloadCtas({
  placement,
  className,
  initialStatus = "App Store and Play Store links are coming soon.",
}: {
  placement: string;
  className?: string;
  initialStatus?: string;
}) {
  const [status, setStatus] = useState(initialStatus);
  const statusId = `${placement}-store-status`;
  const rootClassName = ["app-download-ctas", className].filter(Boolean).join(" ");

  function handlePendingStoreClick(store: StoreCta) {
    setStatus(
      `${store.label} is not live yet. Join the waitlist and we will send the link when it opens.`
    );
    trackMarketingEvent("store_cta_pending", {
      platform: store.platform,
      placement,
      page_path: `${window.location.pathname}${window.location.search}`,
    });
  }

  function handleStoreLinkClick(store: StoreCta) {
    trackCtaClick(`store_${placement}_${store.platform}`, store.href);
    trackMarketingEvent("store_cta_click", {
      platform: store.platform,
      placement,
      store_href: store.href,
      page_path: `${window.location.pathname}${window.location.search}`,
    });
  }

  return (
    <div className={rootClassName} data-reveal>
      <div className="app-download-ctas__buttons">
        {storeCtas.map((store) => (
          <StoreButton
            key={store.platform}
            store={store}
            statusId={statusId}
            onPendingClick={handlePendingStoreClick}
            onStoreLinkClick={handleStoreLinkClick}
          />
        ))}
      </div>
      <p className="app-download-ctas__status" id={statusId} role="status" aria-live="polite">
        {status}
      </p>
    </div>
  );
}

function StoreButton({
  store,
  statusId,
  onPendingClick,
  onStoreLinkClick,
}: {
  store: StoreCta;
  statusId: string;
  onPendingClick: (store: StoreCta) => void;
  onStoreLinkClick: (store: StoreCta) => void;
}) {
  const content = (
    <>
      <span className="store-button__mark" aria-hidden="true">
        {store.platform === "ios" ? <AppleStoreMark /> : <GooglePlayStoreMark />}
      </span>
      <span>
        <span className="store-button__kicker">{store.kicker}</span>
        <strong>{store.label}</strong>
      </span>
    </>
  );

  if (!store.href) {
    return (
      <PlainButton
        className="store-button is-pending"
        type="button"
        aria-describedby={statusId}
        onClick={() => onPendingClick(store)}
      >
        {content}
      </PlainButton>
    );
  }

  return (
    <PlainLink
      className="store-button"
      href={store.href}
      target="_blank"
      rel="noreferrer"
      onClick={(event: MouseEvent<HTMLAnchorElement>) => {
        if (!store.href) {
          event.preventDefault();
          onPendingClick(store);
          return;
        }
        onStoreLinkClick(store);
      }}
    >
      {content}
    </PlainLink>
  );
}

function AppleStoreMark() {
  return (
    <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
      <path
        d="M16.48 12.74c.02-2.14 1.72-3.16 1.8-3.2-1.02-1.5-2.58-1.7-3.12-1.72-1.32-.14-2.6.78-3.27.78-.69 0-1.72-.76-2.83-.74-1.44.02-2.78.85-3.52 2.15-1.52 2.63-.39 6.5 1.07 8.63.73 1.04 1.58 2.2 2.7 2.16 1.09-.04 1.5-.69 2.82-.69 1.31 0 1.69.69 2.84.67 1.18-.02 1.92-1.05 2.62-2.1.84-1.2 1.17-2.39 1.18-2.45-.03-.01-2.26-.87-2.29-3.49Zm-2.18-6.32c.59-.74.99-1.74.88-2.76-.85.04-1.9.59-2.51 1.3-.55.64-1.04 1.68-.91 2.66.96.08 1.93-.48 2.54-1.2Z"
        fill="currentColor"
      />
    </svg>
  );
}

function GooglePlayStoreMark() {
  return (
    <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
      <path
        d="M4.5 3.7c-.26.28-.42.72-.42 1.28v14.04c0 .56.16 1 .42 1.28l7.7-8.3-7.7-8.3Z"
        fill="currentColor"
        opacity="0.86"
      />
      <path
        d="m14.84 9.15-2.64 2.84 2.64 2.85 3.26-1.85c1.09-.62 1.09-1.36 0-1.98l-3.26-1.86Z"
        fill="currentColor"
      />
      <path
        d="m14.84 9.15-3.07-1.74-5.1-2.9 5.53 7.48 2.64-2.84Z"
        fill="currentColor"
        opacity="0.68"
      />
      <path
        d="m6.67 19.49 5.1-2.9 3.07-1.75-2.64-2.85-5.53 7.5Z"
        fill="currentColor"
        opacity="0.68"
      />
    </svg>
  );
}
