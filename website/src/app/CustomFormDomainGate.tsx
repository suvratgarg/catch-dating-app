import {useEffect, useState, type ReactNode} from "react";
import {Navigate, useLocation} from "react-router";
import {publicFormsCopy} from "../content/forms";
import {WebsitePageMain} from "../shared/site";

export function isCatchWebsiteHost(hostname: string): boolean {
  return hostname === "catchdates.com" || hostname === "www.catchdates.com" ||
    hostname === "localhost" || hostname === "127.0.0.1" ||
    hostname === "[::1]" || hostname.endsWith(".web.app") ||
    hostname.endsWith(".firebaseapp.com");
}

export function publicFormIdForCustomHost(
  hostname: string, value: unknown
): string | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) return null;
  const record = value as Record<string, unknown>;
  if (Object.keys(record).sort().join(",") !== "hostname,publicFormId" ||
      record.hostname !== hostname ||
      typeof record.publicFormId !== "string" ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(record.publicFormId)) return null;
  return record.publicFormId;
}

/** Unknown and revoked hosts never render the marketing site or another form. */
export function CustomFormDomainGate({
  children,
  hostname: requestedHostname = window.location.hostname,
}: {children: ReactNode; hostname?: string}) {
  const hostname = requestedHostname.toLowerCase();
  const location = useLocation();
  const [formId, setFormId] = useState<string | null | undefined>(undefined);
  useEffect(() => {
    if (isCatchWebsiteHost(hostname)) return;
    const controller = new AbortController();
    void fetch(`/api/form-domain?hostname=${encodeURIComponent(hostname)}`, {
      signal: controller.signal, credentials: "omit", cache: "no-store",
    }).then(async (response) => response.ok ? response.json() : null)
      .then((value: unknown) => {
        if (!controller.signal.aborted) {
          setFormId(publicFormIdForCustomHost(hostname, value));
        }
      }).catch(() => {
        if (!controller.signal.aborted) setFormId(null);
      });
    return () => controller.abort();
  }, [hostname]);
  if (isCatchWebsiteHost(hostname)) return <>{children}</>;
  if (formId === undefined) {
    return <WebsitePageMain><p>{publicFormsCopy.loading}</p></WebsitePageMain>;
  }
  if (!formId) {
    return <WebsitePageMain>
      <h1>{publicFormsCopy.unavailableTitle}</h1>
    </WebsitePageMain>;
  }
  const path = `/f/${encodeURIComponent(formId)}`;
  if (location.pathname !== path && location.pathname !== `${path}/`) {
    return <Navigate to={path} replace />;
  }
  return <>{children}</>;
}
