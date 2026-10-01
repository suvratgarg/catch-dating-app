import type {Meta, StoryObj} from "@storybook/react-vite";
import {MarketingSection} from "../shared/ui/primitives";
import {PublicSiteFooter, PublicSiteHeader, WebsitePageMain} from "../shared/site";

const publicRouteIds = ["home", "visitor_discovery", "host", "claim", "claim_lookup", "privacy", "terms", "help", "not_found", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy", "event_detail_canonical", "host_workflows", "host_overview", "host_platform", "host_planners", "host_mixers", "host_clubs", "host_directory", "host_claim", "host_apply", "host_stack"];
const meta = {title: "Marketing Website/Shared/Public site chrome", component: PublicSiteHeader} satisfies Meta<typeof PublicSiteHeader>;
export default meta;
type Story = StoryObj<typeof meta>;

export const PublicSiteHeaderStory: Story = {
  parameters: {catchComponent: {id: "shared_public_site_header", routeIds: publicRouteIds,
    states: ["global-navigation", "secondary-navigation"]}},
  render: () => <>
    <PublicSiteHeader localNav={[{href: "#events", label: "Events"},
      {href: "#about", label: "About"}, {href: "#reviews", label: "Reviews"}]}
      localActions={[{href: "/claim/example/", label: "Claim listing"}]} />
    <WebsitePageMain>
      <MarketingSection variant="story" id="events"><h1>Organiser profile</h1><p>Browse this organiser's events.</p></MarketingSection>
      <section id="about"><h2>About</h2><p>Public organiser information.</p></section>
      <section id="reviews"><h2>Reviews</h2><p>Published public reviews.</p></section>
    </WebsitePageMain>
  </>,
};

export const PublicSiteFooterStory: Story = {
  parameters: {catchComponent: {id: "shared_public_site_footer", routeIds: publicRouteIds,
    states: ["global-links", "context-links"]}},
  render: () => <PublicSiteFooter body="Explore this organiser's public sources and events."
    links={[{href: "/organizers/", label: "Search organisers"}, {href: "/host/", label: "For hosts"}]} />,
};
