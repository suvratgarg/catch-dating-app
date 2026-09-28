import type {ReactNode} from "react";
import {useLocation} from "react-router";
import {publicEventListingsContext, usePublicEventListingsController} from
  "../features/organizers/usePublicEventListingsController";

export function PublicEventListingsProvider({children}: {children: ReactNode}) {
  const {pathname} = useLocation();
  const enabled = pathname === "/" || pathname.startsWith("/events/") ||
    pathname === "/organizers" || pathname.startsWith("/organizers/");
  const value = usePublicEventListingsController(enabled);
  return <publicEventListingsContext.Provider value={value}>
    {children}
  </publicEventListingsContext.Provider>;
}
