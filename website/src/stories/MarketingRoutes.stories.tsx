import type {Meta, StoryObj} from "@storybook/react-vite";
import {HomePage} from "../features/home/HomePage";
import {HostPage} from "../features/host/HostPage";
import {HostPreviewPage} from "../features/host/HostPreviewPage";
import {captures} from "./fixtures/marketingCaptures";

const meta = {
  title: "Marketing Website/Routes",
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

export const Home: Story = {
  name: "/",
  parameters: {
    catchRoute: {
      id: "home",
      path: "/",
      reviewStates: ["default", "app-download-pending", "waitlist-form"],
    },
    catchComponent: {
      id: "route_home",
      routeIds: ["home"],
      states: ["default", "app-download-pending", "waitlist-form"],
    },
  },
  render: () => <HomePage captures={captures} />,
};

export const Host: Story = {
  name: "/host/",
  parameters: {
    catchRoute: {
      id: "host",
      path: "/host/",
      reviewStates: ["default", "host-application", "capture-placeholders"],
    },
    catchComponent: {
      id: "route_host",
      routeIds: ["host"],
      states: ["default", "host-application", "capture-placeholders"],
    },
  },
  render: () => <HostPage captures={captures} />,
};

export const HostPreview: Story = {
  name: "/host/preview/",
  parameters: {
    catchRoute: {
      id: "host_preview",
      path: "/host/preview/",
      reviewStates: ["default", "founding-host-offer", "create-flow"],
    },
    catchComponent: {
      id: "route_host_preview",
      routeIds: ["host_preview"],
      states: ["default", "founding-host-offer", "create-flow"],
    },
  },
  render: () => <HostPreviewPage captures={captures} />,
};
