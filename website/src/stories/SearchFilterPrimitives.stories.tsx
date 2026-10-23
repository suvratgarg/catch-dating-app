import {CatchField} from "@catch/web-ui";
import type {Meta, StoryObj} from "@storybook/react-vite";
import type {FormEvent} from "react";
import {Button, SearchFormShell} from "../shared/ui/primitives";

const meta = {
  title: "Marketing Website/Shared/Search And Filters",
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

export const OrganizerSearchFormShellStory: Story = {
  name: "Organizer search shell",
  parameters: {
    catchComponent: {
      id: "shared_search_form_shell",
      routeIds: ["organizer_search"],
      states: ["organizer-search-form"],
    },
  },
  render: () => (
    <SearchFormShell variant="organizer" onSubmit={preventSubmit}>
      <CatchField
        recipe="input"
        id="storybook-organizer-search-query"
        title="Search organizers"
        name="q"
        inputHint="Try Sunday Table, Indore, run club, dinner"
      />
      <Button type="submit">Search</Button>
    </SearchFormShell>
  ),
};

function preventSubmit(event: FormEvent<HTMLFormElement>) {
  event.preventDefault();
}

