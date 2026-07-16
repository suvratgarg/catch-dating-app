import type {Meta, StoryObj} from "@storybook/react-vite";
import type {ReactNode} from "react";
import {WaitlistForm} from "../features/waitlist/WaitlistForm";
import {WebsiteQueryProvider} from "../shared/query/queryClient";
import {PageShell, WebsitePageMain} from "../shared/site";
import {WaitlistSection} from "../shared/ui/primitives";

const meta = {
  title: "Marketing Website/Waitlist/Form",
  parameters: {
    catchComponentRegistry: {
      path: "design/website/components.json",
    },
    catchRouteContract: {
      path: "design/website/routes.json",
    },
  },
} satisfies Meta;

export default meta;

type Story = StoryObj<typeof meta>;

export const MemberWaitlistForm: Story = {
  name: "Member",
  parameters: {
    catchComponent: {
      id: "waitlist_form_adapter",
      routeIds: ["home", "host"],
      states: ["member"],
    },
  },
  render: () => (
    <WaitlistStoryFrame>
      <WaitlistForm variant="member" />
    </WaitlistStoryFrame>
  ),
};

export const HostWaitlistForm: Story = {
  name: "Host",
  parameters: {
    catchComponent: {
      id: "waitlist_form_adapter",
      routeIds: ["home", "host"],
      states: ["host"],
    },
  },
  render: () => (
    <WaitlistStoryFrame>
      <WaitlistForm variant="host" />
    </WaitlistStoryFrame>
  ),
};

function WaitlistStoryFrame({children}: {children: ReactNode}) {
  return (
    <WebsiteQueryProvider>
      <PageShell pageClassName="home-page">
        <WebsitePageMain>
          <WaitlistSection
            titleId="storybook-waitlist-title"
            title="Be first in your city."
            body="Join the member waitlist or apply as a founding host. We will reach out as city access opens."
          >
            {children}
          </WaitlistSection>
        </WebsitePageMain>
      </PageShell>
    </WebsiteQueryProvider>
  );
}
