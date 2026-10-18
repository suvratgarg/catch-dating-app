import {expect, fn, userEvent, within} from "storybook/test";
import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostApplicationPage} from "../features/host/HostApplicationPage";
const meta = {title: "Marketing Website/Host/Application", component: HostApplicationPage} satisfies Meta<typeof HostApplicationPage>;
export default meta;
type Story = StoryObj<typeof meta>;
export const Application: Story = {
  play: exerciseReviewBeforeSubmit,
  parameters: {
    catchRoute: {id: "host_apply", path: "/host/apply/", reviewStates: ["initial", "interactive-steps", "review", "submitted", "error"], stateCoverage: {storybook: ["initial"], manual: ["interactive-steps", "review", "submitted", "error"]}},
    catchComponent: {id: "route_host_apply", routeIds: ["host_apply"], states: ["initial"]},
  },
};

// A native browser click catches the Continue -> Submit DOM reuse bug that
// jsdom click dispatch cannot reproduce. Return to the initial visual state.
async function exerciseReviewBeforeSubmit({canvasElement}: {canvasElement: HTMLElement}) {
  const canvas = within(canvasElement);
  const events = import.meta.env.MODE === "test"
    ? (await import("vitest/browser") as typeof import("@vitest/browser-playwright/context")).userEvent
    : userEvent;
  const originalFetch = globalThis.fetch;
  const submit = fn(async () => new Response(JSON.stringify({ok: true, alreadyJoined: false}), {
    headers: {"Content-Type": "application/json"},
  }));
  globalThis.fetch = submit;
  const field = (id: string) => canvasElement.querySelector<HTMLInputElement>(`#${id}`)!;
  const next = () => events.click(canvas.getByRole("button", {name: "Continue"}));
  try {
    await userEvent.type(field("host-full-name"), "Local QA");
    await userEvent.type(field("host-email"), "qa@example.com");
    await userEvent.type(field("host-org-name"), "Local QA Club");
    await userEvent.type(field("host-community-link"), "https://example.com/qa");
    await next();
    await userEvent.type(field("host-event-name"), "Local verification event");
    await userEvent.type(field("host-event-location"), "Local test venue");
    await next();
    await next();
    await userEvent.type(field("host-goals"), "Review before explicit submission.");
    await next();
    await expect(canvas.getByRole("button", {name: "Submit host packet"})).toBeVisible();
    await expect(submit).not.toHaveBeenCalled();
    await events.click(canvasElement.querySelector<HTMLButtonElement>(".operational-step-rail button")!);
    for (const id of ["host-full-name", "host-email", "host-org-name", "host-community-link"]) {
      await userEvent.clear(field(id));
    }
    (document.activeElement as HTMLElement | null)?.blur();
    window.scrollTo({top: 0, behavior: "instant"});
  } finally {
    globalThis.fetch = originalFetch;
  }
}
