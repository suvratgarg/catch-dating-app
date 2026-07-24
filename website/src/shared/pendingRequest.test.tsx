import {cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";
import {
  PendingRequestProvider,
  usePendingRequestRegistration,
} from "./pendingRequest";
import {Button, ButtonLink, Form, TextField} from "./ui/primitives";

function PendingLink({
  onClick,
  pending,
}: {
  onClick: () => void;
  pending: boolean;
}) {
  usePendingRequestRegistration(pending);
  return (
    <ButtonLink
      href="/host"
      onClick={(event) => {
        event.preventDefault();
        onClick();
      }}
    >
      Leave form
    </ButtonLink>
  );
}

describe("pending request controls", () => {
  afterEach(cleanup);

  it("disables every native control inside a pending form boundary", () => {
    const {container} = render(
      <Form pending>
        <TextField id="name" label="Name" />
        <Button type="submit">Submit</Button>
      </Form>
    );

    const form = container.querySelector("form");
    const boundary = form?.querySelector("fieldset");
    expect(form?.getAttribute("aria-busy")).toBe("true");
    expect(boundary?.hasAttribute("disabled")).toBe(true);
    expect(screen.getByLabelText("Name").matches(":disabled")).toBe(true);
    expect(screen.getByRole("button", {name: "Submit"}).matches(":disabled")).toBe(true);
  });

  it("blocks shared route links while any request is pending", async () => {
    const onClick = vi.fn();
    const {rerender} = render(
      <PendingRequestProvider>
        <PendingLink onClick={onClick} pending />
        <Form>
          <TextField id="sibling-field" label="Sibling form field" />
        </Form>
      </PendingRequestProvider>
    );

    const link = screen.getByRole("link", {name: "Leave form"});
    await waitFor(() => expect(link.getAttribute("aria-disabled")).toBe("true"));
    expect(screen.getByLabelText("Sibling form field").matches(":disabled")).toBe(true);
    const beforeUnload = new Event("beforeunload", {cancelable: true});
    fireEvent(window, beforeUnload);
    expect(beforeUnload.defaultPrevented).toBe(true);
    fireEvent.click(link);
    expect(onClick).not.toHaveBeenCalled();

    rerender(
      <PendingRequestProvider>
        <PendingLink onClick={onClick} pending={false} />
        <Form>
          <TextField id="sibling-field" label="Sibling form field" />
        </Form>
      </PendingRequestProvider>
    );
    await waitFor(() => expect(link.hasAttribute("aria-disabled")).toBe(false));
    expect(screen.getByLabelText("Sibling form field").matches(":disabled")).toBe(false);
    fireEvent.click(link);
    expect(onClick).toHaveBeenCalledTimes(1);
  });
});
