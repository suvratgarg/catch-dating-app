import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {EventAssistanceView} from "./EventAssistancePage";
import type {AssistanceScreen} from "./eventAssistanceModel";
import {guestUpdateFixture as view, eventAssistanceCopy as copy} from "../../content/eventAssistance";

afterEach(cleanup);
const ready: Extract<AssistanceScreen, {kind: "ready"}> = {kind: "ready", view, fresh: true,
  pending: false, pendingChoice: null, retryChoice: null, notice: ""};

it("presents current instructions and submits only the selected approved choice", () => {
  const submit = vi.fn();
  render(<EventAssistanceView screen={ready} submit={submit}
    refresh={() => undefined} refreshing={false} />);
  expect(screen.getByRole("heading", {name: view.title})).toBeTruthy();
  expect(screen.getByText(view.text)).toBeTruthy();
  fireEvent.click(screen.getByRole("button", {name: "I’m on my way"}));
  expect(submit).toHaveBeenCalledExactlyOnceWith("on-my-way");
});

it("disables stale choices and keeps the refresh action available", () => {
  const submit = vi.fn();
  const refresh = vi.fn();
  render(<EventAssistanceView screen={{...ready, fresh: false}} submit={submit}
    refresh={refresh} refreshing={false} />);
  const choice = screen.getByRole("button", {name: "I’m on my way"}) as HTMLButtonElement;
  expect(choice.disabled).toBe(true);
  fireEvent.click(choice);
  expect(submit).not.toHaveBeenCalled();
  expect(screen.getByText(copy.stale)).toBeTruthy();
  fireEvent.click(screen.getByRole("button", {name: copy.refresh}));
  expect(refresh).toHaveBeenCalledOnce();
});

it("confirms the recorded response without presenting another action", () => {
  render(<EventAssistanceView screen={{...ready, view: {...view, choices: [],
    response: {label: "I’m on my way", receivedAt: 1_000_001}}}}
    submit={() => undefined} refresh={() => undefined} refreshing={false} />);
  expect(screen.getByRole("heading", {name: copy.saved})).toBeTruthy();
  expect(screen.getByText("I’m on my way").getAttribute("role")).toBe("status");
  expect(screen.queryByRole("button", {name: "I’m on my way"})).toBeNull();
});

it("retains text withdrawal controls when event instructions are closed", () => {
  render(<EventAssistanceView screen={{kind: "unavailable", reason: "eventClosed"}}
    submit={() => undefined} refresh={() => undefined} refreshing={false}
    textPreferences={<p>Event text withdrawal remains available</p>} />);
  expect(screen.getByText("Event text withdrawal remains available")).toBeTruthy();
});
