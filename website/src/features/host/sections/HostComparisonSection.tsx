import {useEffect, useRef, useState} from "react";
import {TextActionButton} from "../../../shared/ui/primitives";
import {
  hostComparisonColumns,
  hostComparisonRows,
} from "../../marketing/content";

export function HostComparisonSection() {
  const [open, setOpen] = useState(false);
  const comparisonTableRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!open) {
      return;
    }
    const frameId = window.requestAnimationFrame(() => {
      comparisonTableRef.current?.scrollIntoView({behavior: "smooth", block: "start"});
    });
    return () => window.cancelAnimationFrame(frameId);
  }, [open]);

  return (
    <section className="host-comparison" aria-labelledby="host-comparison-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">The honest comparison</span>
        <h2 id="host-comparison-title">Announcing an event is solved. Running one is not.</h2>
      </div>
      <div className="host-comparison__split">
        <article data-reveal>
          <span className="ui-label">Luma · Eventbrite · District · BookMyShow · Instagram · WhatsApp · Forms</span>
          <h3>They help you publish, sell, or get discovered.</h3>
          <p>
            Useful reach, event pages, and payments. Then social hosts still
            assemble admissions, ratios, door proof, follow-up, and reputation
            signals across scattered tools.
          </p>
        </article>
        <article data-reveal>
          <span className="ui-label">Catch</span>
          <h3>Catch fills it, runs it, and proves it.</h3>
          <p>
            Admission rules, waitlists, check-in, live console, attendance proof,
            post-event matching, verified reviews, and host reports stay in one loop.
          </p>
        </article>
      </div>
      <TextActionButton
        aria-expanded={open}
        aria-controls="host-comparison-table"
        onClick={() => setOpen((current) => !current)}
      >
        {open ? "Hide full comparison" : "See full comparison"}
      </TextActionButton>
      {open ? (
        <>
          <div
            className="comparison-table-heading"
            id="host-comparison-table"
            ref={comparisonTableRef}
            data-reveal
            tabIndex={-1}
          >
            <span className="ui-label">Full table</span>
            <p>
              District and BookMyShow are strong Indian discovery and ticketing
              surfaces. Catch is positioned around the host operating loop after the
              listing goes live.
            </p>
          </div>
          <div className="comparison-table-wrap" data-reveal>
            <table className="comparison-table" aria-label="Host platform comparison">
              <thead>
                <tr>
                  <th>Capability</th>
                  {hostComparisonColumns.map((column) => (
                    <th key={column}>{column}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {hostComparisonRows.map((row) => (
                  <tr key={row[0]}>
                    <td>{row[0]}</td>
                    {row.slice(1).map((value, index) => (
                      <td key={`${row[0]}-${index}`} data-value={value}>
                        {value === "yes" ? "Yes" : value === "partial" ? "Partial" : "No"}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      ) : null}
    </section>
  );
}
