import legalDocument from "./legal.json" with {type: "json"};
import type {StoreCtaCopy} from "./types";

export const ownerGatedSiteDestinations = {
  contactHref: "mailto:suvrat@catchdates.com",
} as const;

export const siteFooterLegalLinks = [
  {href: "/privacy/", label: "Privacy"},
  {href: "/terms/", label: "Terms"},
  {href: "/help/", label: "Help"},
] as const;

export const siteMenuCopy = {
  dialogLabel: "Site menu",
  openLabel: "Menu",
  closeLabel: "Close",
  kicker: "Catch · Menu",
  hint: "The event before the match",
  navLabel: "Mobile",
} as const;

export const storeCtaCopy = [
  {
    platform: "ios",
    kicker: "Download on the",
    label: "App Store",
    shortLabel: "iOS",
  },
  {
    platform: "android",
    kicker: "Get it on",
    label: "Google Play",
    shortLabel: "Play",
  },
] as const satisfies readonly StoreCtaCopy[];

// One authored owner for public marketing chrome across route families.
export const publicSiteCopy = {
  menu: {
    dialogLabel: "Site menu", openLabel: "Menu", closeLabel: "Close",
    kicker: "Catch · For organisers", hint: "Presence, guests, and the live event", navLabel: "Mobile",
  },
  nav: [
    {href: "/explore/", label: "Find events"},
    {href: "/organizers/", label: "Organisers"},
    {href: "/host/", label: "Catch Host"},
    {href: "/host/#pricing", label: "Pricing and access"},
  ],
  actions: [
    {href: "/claim/", label: "Claim your page", variant: "secondary"},
    {href: "/host/apply/", label: "Apply for a pilot", variant: "primary"},
  ],
  footerBody: "Catch for organisers: public discovery, guest coordination, and a supported live-event pilot.",
  footerOperator: legalDocument.ui.footerBody,
  localNavLabel: "On this page",
  relatedLinksLabel: "Related links",
} as const;

export const consumerSiteCopy = {
  menu: {dialogLabel: "Site menu", openLabel: "Menu", closeLabel: "Close", kicker: "Catch", hint: "Find something worth showing up for.", navLabel: "Mobile"},
  nav: [{href: "/explore/", label: "Find events"}, {href: "/organizers/", label: "Organisers"}, {href: "/host/", label: "For organisers"}],
  footer: "Discover events, share interests, and spend time with people.",
} as const;
