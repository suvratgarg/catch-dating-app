import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostConceptPage} from "../features/host/concepts/HostConceptPage";
import {PageShell} from "../shared/site";

const meta = {
  title: "Marketing Website/Host/Migrated concepts",
  component: HostConceptPage,
  parameters: {layout:"fullscreen", a11y:{test:"error"}},
  render: (args) => <PageShell pageClassName="host-page host-content-review"><HostConceptPage {...args} /></PageShell>,
} satisfies Meta<typeof HostConceptPage>;
export default meta;
type Story = StoryObj<typeof meta>;
export const Overview: Story = {args:{slug:"index"}, parameters:{catchComponent:{id:"host_concept_page",routeIds:["host_overview"],states:["default","local-interaction","canonical-handoff"]}}};
export const Platform: Story = {args:{slug:"host"}, parameters:{catchComponent:{id:"host_concept_platform",routeIds:["host_platform"],states:["default","local-interaction","canonical-handoff"]}}};
export const Planners: Story = {args:{slug:"planners"}, parameters:{catchComponent:{id:"host_concept_planners",routeIds:["host_planners"],states:["default","local-interaction","canonical-handoff"]}}};
export const Mixers: Story = {args:{slug:"mixers"}, parameters:{catchComponent:{id:"host_concept_mixers",routeIds:["host_mixers"],states:["default","local-interaction","canonical-handoff"]}}};
export const Clubs: Story = {args:{slug:"clubs"}, parameters:{catchComponent:{id:"host_concept_clubs",routeIds:["host_clubs"],states:["default","local-interaction","canonical-handoff"]}}};
export const Directory: Story = {args:{slug:"directory"}, parameters:{catchComponent:{id:"host_concept_directory",routeIds:["host_directory"],states:["default","local-interaction","canonical-handoff"]}}};
export const Claim: Story = {args:{slug:"claim"}, parameters:{catchComponent:{id:"host_concept_claim",routeIds:["host_claim"],states:["default","local-interaction","canonical-handoff"]}}};
export const Apply: Story = {args:{slug:"apply"}, parameters:{catchComponent:{id:"host_concept_apply",routeIds:["host_apply"],states:["default","local-interaction","canonical-handoff"]}}};
export const Stack: Story = {args:{slug:"stack"}, parameters:{catchComponent:{id:"host_concept_stack",routeIds:["host_stack"],states:["default","local-interaction","canonical-handoff"]}}};
