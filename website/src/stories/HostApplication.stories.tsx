import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostApplicationPage} from "../features/host/HostApplicationPage";
const meta = {title: "Marketing Website/Host/Application", component: HostApplicationPage} satisfies Meta<typeof HostApplicationPage>;
export default meta;
type Story = StoryObj<typeof meta>;
export const Application: Story = {
  parameters: {
    catchRoute: {id: "host_apply", path: "/host/apply/", reviewStates: ["initial", "interactive-steps", "review", "submitted", "error"], stateCoverage: {storybook: ["initial"], manual: ["interactive-steps", "review", "submitted", "error"]}},
    catchComponent: {id: "route_host_apply", routeIds: ["host_apply"], states: ["initial"]},
  },
};
