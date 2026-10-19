import {hostListings} from "./hostListings";
import type {HostListing} from "../../features/organizers/types";
// Stable, explicitly illustrative Storybook data; never loaded by public routes.
export const consumerHomeStoryListings: HostListing[] = [{
  ...hostListings[0], id: "storybook-club", name: "Preview Club", city: "Mumbai", citySlug: "mumbai", path: "/organizers/preview-club/",
  catchEvents: [{id: "storybook-run", role: "Hosted event", title: "Sunday Social Run", summary: "Illustrative Storybook event", activityKind: "socialRun", timeline: "upcoming", startTime: "2030-01-02", endTime: "2030-01-03", date: "Sun 2 Jan · 7 AM", location: "Bandra", capacityLimit: 20, bookedCount: 1, checkedInCount: 0, waitlistedCount: 0, priceLabel: "Free", publicRegistrationEnabled: true, catchExperienceActivities: ["introductions"]}],
}];
