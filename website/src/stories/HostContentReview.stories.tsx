import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostContentReview} from "../features/host/HostContentReview";
import {PageShell} from "../shared/site";

const meta = {
  title: "Marketing Website/Host/Content organisation",
  parameters: {layout: "fullscreen", a11y: {test: "error"}},
  render: () => <PageShell pageClassName="host-content-review"><HostContentReview /></PageShell>,
} satisfies Meta;
export default meta;
type Story = StoryObj<typeof meta>;
export const WorkflowLed: Story = {
  parameters: {catchComponent: {
    id: "host_content_review", routeIds: ["host"], states: ["workflow-led-content", "fictional-examples"],
  }},
};
