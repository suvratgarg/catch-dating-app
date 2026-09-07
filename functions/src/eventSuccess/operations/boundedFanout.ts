/** Shared pagination mechanics; domain adapters own identity and authority. */
export interface FanoutCheckpoint<Failure> {
  phase: "scan" | "retry" | "complete" | "review" | "expired";
  cursor: string | null;
  visited: number;
  dueAt: number | null;
  failures: Failure[];
  retries: number;
}

export async function advanceFanoutPage<Failure>(
  previous: FanoutCheckpoint<Failure>, expiresAt: number,
  clock: () => number, ports: {
    list: (cursor: string | null, limit: number) => Promise<string[]>;
    visit: (id: string) => Promise<Failure | null>;
    failureId: (failure: Failure) => string;
  }): Promise<FanoutCheckpoint<Failure>> {
  const c = structuredClone(previous);
  if (clock() >= expiresAt) return {...c, phase: "expired", dueAt: null};
  if (c.phase !== "scan" && c.phase !== "retry") {
    throw new Error("Only active fanout checkpoints can advance");
  }
  let continueRetryPage = false;
  if (c.phase === "retry") {
    const pending = c.failures.filter((f) => c.cursor === null ||
      ports.failureId(f) > c.cursor).sort((a, b) =>
      ports.failureId(a) < ports.failureId(b) ? -1 : 1);
    for (const previous of pending.slice(0, 20)) {
      const id = ports.failureId(previous);
      const failure = await ports.visit(id);
      c.failures = c.failures.filter((f) => ports.failureId(f) !== id);
      if (failure) c.failures.push(failure);
      c.cursor = id;
    }
    continueRetryPage = pending.length > 20;
    if (!continueRetryPage) {
      c.retries += 1;
      c.cursor = null;
    }
    c.phase = !c.failures.length ? "complete" :
      c.retries >= 5 ? "review" : "retry";
  } else {
    const room = Math.min(20, 10_000 - c.visited, 100 - c.failures.length);
    if (room <= 0) {
      c.phase = "review";
    } else {
      const page = await ports.list(c.cursor, room + 1);
      for (const id of page.slice(0, room)) {
        const failure = await ports.visit(id);
        if (failure) c.failures.push(failure);
        c.cursor = id;
        c.visited += 1;
      }
      c.phase = page.length > room ? "scan" :
        c.failures.length ? "retry" : "complete";
      if (c.phase === "retry") c.cursor = null;
      if (c.phase === "scan" &&
          (c.visited >= 10_000 || c.failures.length >= 100)) {
        c.phase = "review";
      }
    }
  }
  c.dueAt = c.phase === "scan" || continueRetryPage ? clock() :
    c.phase === "retry" ? Math.min(expiresAt,
      clock() + 30_000 * 2 ** c.retries) : null;
  return c;
}
