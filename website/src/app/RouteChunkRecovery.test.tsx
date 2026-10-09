import {act, cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {Component, Suspense, useEffect, useState, type ReactNode} from "react";
import {MemoryRouter, useNavigate} from "react-router";
import {afterEach, describe, expect, it, vi} from "vitest";
import {PendingRequestProvider, usePendingRequestRegistration} from "../shared/pendingRequest";
import {Button, TextField} from "../shared/ui/primitives";
import {recoverableLazy, RouteChunkRecovery} from "./RouteChunkRecovery";

afterEach(() => { cleanup(); vi.restoreAllMocks(); });

class ExistingRuntimeErrorPolicy extends Component<{children: ReactNode}, {failed: boolean}> {
  state = {failed: false};
  static getDerivedStateFromError() { return {failed: true}; }
  render() { return this.state.failed ? <p>Existing runtime error policy</p> : this.props.children; }
}

function harness(children: ReactNode, pending = false) {
  function Pending() { usePendingRequestRegistration(pending); return null; }
  vi.spyOn(console, "error").mockImplementation(() => undefined);
  return render(<MemoryRouter><PendingRequestProvider>
    <Pending /><ExistingRuntimeErrorPolicy><RouteChunkRecovery><Suspense fallback={<p>Loading route</p>}>
      {children}
    </Suspense></RouteChunkRecovery></ExistingRuntimeErrorPolicy>
  </PendingRequestProvider></MemoryRouter>);
}

describe("route chunk recovery", () => {
  it("shows a focused accessible fallback and loads a new lazy entry on deliberate retry", async () => {
    const load = vi.fn().mockRejectedValue(new Error("private chunk URL/token"));
    const recover = vi.fn().mockResolvedValue({default: () => <h1>Recovered route</h1>});
    const Page = recoverableLazy(load, recover);
    harness(<Page />);
    const alert = await screen.findByRole("alert");
    expect(alert.textContent).not.toContain("private chunk");
    expect(document.activeElement).toBe(screen.getByRole("heading"));
    expect(load).toHaveBeenCalledTimes(1);
    expect(recover).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("button", {name: "Try again"}));
    await screen.findByRole("heading", {name: "Recovered route"});
    expect(recover).toHaveBeenCalledTimes(1);
    expect(load).toHaveBeenCalledTimes(1);
  });

  it("bounds persistent failures to one recovery attempt and retains safe navigation", async () => {
    const load = vi.fn().mockRejectedValue(new Error("offline"));
    const recover = vi.fn().mockRejectedValue(new Error("offline again"));
    const Page = recoverableLazy(load, recover);
    harness(<Page />);
    fireEvent.click(await screen.findByRole("button", {name: "Try again"}));
    await screen.findByText("This page is still unavailable. Please try again later.");
    expect(screen.queryByRole("button", {name: "Try again"})).toBeNull();
    expect(screen.getByRole("button", {name: "Return to Catch"})).not.toBeNull();
    expect(load).toHaveBeenCalledTimes(1);
    expect(recover).toHaveBeenCalledTimes(1);
  });

  it("blocks recovery and safe navigation while a surrounding request is pending", async () => {
    const recover = vi.fn();
    const Page = recoverableLazy<Record<string, never>>(
      () => Promise.reject(new Error("offline")), recover);
    harness(<Page />, true);
    const retry = await screen.findByRole("button", {name: "Try again"});
    const home = screen.getByRole("button", {name: "Return to Catch"});
    expect((retry as HTMLButtonElement).disabled).toBe(true);
    expect((home as HTMLButtonElement).disabled).toBe(true);
    fireEvent.click(retry);
    fireEvent.click(home);
    expect(recover).not.toHaveBeenCalled();
    const beforeUnload = new Event("beforeunload", {cancelable: true});
    window.dispatchEvent(beforeUnload);
    expect(beforeUnload.defaultPrevented).toBe(true);
  });

  it("does not remount a healthy form when the history entry changes", async () => {
    const mounts = vi.fn();
    const load = vi.fn().mockResolvedValue({default: function Form() {
      const [answer, setAnswer] = useState(() => { mounts(); return ""; });
      const navigate = useNavigate();
      return <><TextField id="answer" label="Answer" value={answer}
        onChange={event => setAnswer(event.target.value)} />
        <Button onClick={() => void navigate("/?step=2")}>Next step</Button></>;
    }});
    const recover = vi.fn();
    const Page = recoverableLazy(load, recover);
    harness(<Page />);
    fireEvent.change(await screen.findByLabelText("Answer"), {target: {value: "Retained draft"}});
    fireEvent.click(screen.getByRole("button", {name: "Next step"}));
    await waitFor(() => expect((screen.getByLabelText("Answer") as HTMLInputElement).value)
      .toBe("Retained draft"));
    expect(mounts).toHaveBeenCalledTimes(1);
    expect(load).toHaveBeenCalledTimes(1);
    expect(recover).not.toHaveBeenCalled();
  });

  it("propagates mounted render errors without new recovery, navigation or repeated side effects", async () => {
    const recover = vi.fn();
    const mounted = vi.fn();
    const Page = recoverableLazy(async () => ({default: function BrokenForm() {
      const [broken, setBroken] = useState(false);
      useEffect(() => { mounted(); }, []);
      if (broken) throw new Error("render error containing private form data");
      return <Button onClick={() => setBroken(true)}>Break mounted form</Button>;
    }}), recover);
    harness(<Page />, true);
    fireEvent.click(await screen.findByRole("button", {name: "Break mounted form"}));
    await screen.findByText("Existing runtime error policy");
    expect(screen.queryByRole("alert")).toBeNull();
    expect(screen.queryByRole("button", {name: "Try again"})).toBeNull();
    expect(screen.queryByRole("button", {name: "Return to Catch"})).toBeNull();
    await act(async () => undefined);
    expect(recover).not.toHaveBeenCalled();
    expect(mounted).toHaveBeenCalledTimes(1);
  });
});
