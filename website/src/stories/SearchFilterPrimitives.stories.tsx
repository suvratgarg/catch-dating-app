import {CatchField} from "@catch/web-ui";
import type {Meta, StoryObj} from "@storybook/react-vite";
import type {FormEvent} from "react";
import {
  Button,
  FilterRail,
  PublicSearchBar,
  SearchFormShell,
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
      <CatchField
        recipe="select"
        id="storybook-organizer-status-filter"
        title="Status"
        name="status"
        values={["all", "verified", "claimed", "unclaimed"]}
        itemLabelBuilder={(status) => ({all: "Any status", verified: "Verified on Catch",
          claimed: "Claimed", unclaimed: "Unclaimed"})[status] ?? status}
        initialValue="unclaimed"
      />
      <CatchField
        recipe="select"
        id="storybook-organizer-city-filter"
        title="City"
        name="city"
        values={["all", "Mumbai", "Indore", "Bengaluru"]}
        itemLabelBuilder={(city) => city === "all" ? "Any city" : city}
        initialValue="Mumbai"
      />
      <CatchField
        recipe="select"
        id="storybook-organizer-format-filter"
        title="Format"
        name="format"
        values={["all", "run club", "dinner", "rooftop social"]}
        itemLabelBuilder={(format) => format === "all" ? "Any format" : format}
        initialValue="run club"
      />
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
