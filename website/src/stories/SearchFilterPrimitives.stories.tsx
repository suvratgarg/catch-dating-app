import type {Meta, StoryObj} from "@storybook/react-vite";
import type {FormEvent} from "react";
import {
  Button,
  FilterRail,
  PublicSearchBar,
  SearchFormShell,
  SelectField,
  TextField,
  ToggleChipButton,
  type PublicSearchSuggestion,
} from "../shared/ui/primitives";

const searchSuggestions: PublicSearchSuggestion[] = [
  {
    id: "afterfly",
    href: "/organizers/afterfly/",
    label: "Afterfly",
    meta: "Run club · Mumbai",
    type: "organizer",
    activityToken: "var(--activity-run)",
  },
  {
    id: "sunday-table",
    href: "/organizers/club-sales-sunday-table/",
    label: "Sunday Table Club",
    meta: "Dinner series · Indore",
    type: "organizer",
  },
  {
    id: "dinner-format",
    href: "/organizers/?q=dinner",
    label: "Dinner clubs",
    meta: "Format",
    type: "format",
  },
];

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

export const PublicSearchBarStory: Story = {
  name: "Public search bar",
  parameters: {
    catchComponent: {
      id: "shared_search_form_shell",
      routeIds: ["home", "organizer_search"],
      states: ["public-search", "suggestions"],
    },
  },
  render: () => (
    <PublicSearchBar
      cityHref="/organizers/?city=Mumbai"
      cityName="Mumbai"
      onCityClick={() => undefined}
      onSearchSubmit={() => undefined}
      onSuggestionClick={() => undefined}
      searchHrefForQuery={searchHrefForQuery}
      suggestions={searchSuggestions}
    />
  ),
};

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
      <TextField
        id="storybook-organizer-search-query"
        label="Search organizers"
        name="q"
        placeholder="Try Sunday Table, Indore, run club, dinner"
      />
      <Button type="submit">Search</Button>
    </SearchFormShell>
  ),
};

export const OrganizerFilterRailStory: Story = {
  name: "Organizer filter rail",
  parameters: {
    catchComponent: {
      id: "shared_filter_rail",
      routeIds: ["organizer_search"],
      states: ["status-city-format-filters"],
    },
  },
  render: () => (
    <FilterRail>
      <SelectField
        id="storybook-organizer-status-filter"
        label="Status"
        name="status"
        defaultValue="unclaimed"
      >
        <option value="all">Any status</option>
        <option value="verified">Verified on Catch</option>
        <option value="claimed">Claimed</option>
        <option value="unclaimed">Unclaimed</option>
      </SelectField>
      <SelectField
        id="storybook-organizer-city-filter"
        label="City"
        name="city"
        defaultValue="Mumbai"
      >
        <option value="all">Any city</option>
        <option>Mumbai</option>
        <option>Indore</option>
        <option>Bengaluru</option>
      </SelectField>
      <SelectField
        id="storybook-organizer-format-filter"
        label="Format"
        name="format"
        defaultValue="run club"
      >
        <option value="all">Any format</option>
        <option>run club</option>
        <option>dinner</option>
        <option>rooftop social</option>
      </SelectField>
      <ToggleChipButton selected onClick={() => undefined}>
        Has upcoming events
      </ToggleChipButton>
    </FilterRail>
  ),
};

function preventSubmit(event: FormEvent<HTMLFormElement>) {
  event.preventDefault();
}

function searchHrefForQuery(query: string) {
  const trimmed = query.trim();
  return trimmed ? `/organizers/?q=${encodeURIComponent(trimmed)}` : "/organizers/";
}
