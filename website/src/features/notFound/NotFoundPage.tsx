import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import {ProcessStatusPanel} from "../../shared/ui/primitives";

export function NotFoundPage() {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "/organizers/", label: "Organizers"},
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="/organizers/"
        ctaLabel="Search organizers"
      />

      <WebsitePageMain id="top">
        <ProcessStatusPanel
          mark="404"
          eyebrow="Page not found"
          title="This Catch page is not available."
          body="The link may have moved, or the organizer profile may not exist yet."
          items={[
            {
              title: "Search the organizer directory",
              body: "Look up public profiles by city, format, organizer name, or review signal.",
            },
            {
              title: "Browse the member site",
              body: "Return to the public homepage for the current Catch event flow.",
            },
            {
              title: "Open host tools",
              body: "If you own the page you expected, start from the host route or claim search.",
            },
          ]}
          actions={[
            {href: "/organizers/", label: "Search organizers", variant: "primary"},
            {href: "/", label: "Member site", variant: "secondary"},
            {href: "/host/", label: "For hosts", variant: "secondary"},
          ]}
        />
      </WebsitePageMain>

      <SiteFooter
        brandHref="/"
        body="Curated singles events. Real context. Better conversations."
        links={[
          {href: "/organizers/", label: "Organizers"},
          {href: "/host/", label: "For hosts"},
          {href: "/claim/", label: "Claim a listing"},
        ]}
      />
    </>
  );
}
