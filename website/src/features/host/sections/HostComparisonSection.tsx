import {SectionHeader} from "../../../shared/site";
import {useEffect, useRef, useState} from "react";
import {
  HostComparisonSummaryCards,
  HostComparisonTable,
  HostComparisonTableHeading,
  HostFeatureSection,
  TextActionButton,
  UiLabel,
} from "../../../shared/ui/primitives";
import {
  hostComparisonColumns,
  hostComparisonRows,
} from "../../marketing/content";

const hostComparisonSummaryCards = [
  {
    key: "tools",
    label: "Luma · Eventbrite · District · BookMyShow · Instagram · WhatsApp · Forms",
    title: "They help you publish, sell, or get discovered.",
    body:
      "Useful reach, event pages, and payments. Then social hosts still assemble admissions, ratios, door proof, follow-up, and reputation signals across scattered tools.",
  },
  {
    key: "catch",
    label: "Catch",
    title: "Catch fills it, runs it, and proves it.",
    body:
      "Admission rules, waitlists, check-in, live console, attendance proof, post-event matching, verified reviews, and host reports stay in one loop.",
  },
];

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
    <HostFeatureSection variant="comparison" aria-labelledby="host-comparison-title">
      <SectionHeader
        eyebrow="The honest comparison"
        id="host-comparison-title"
        title="Announcing an event is solved. Running one is not." />
      <HostComparisonSummaryCards items={hostComparisonSummaryCards} />
      <TextActionButton
        aria-expanded={open}
        aria-controls="host-comparison-table"
        onClick={() => setOpen((current) => !current)}
      >
        {open ? "Hide full comparison" : "See full comparison"}
      </TextActionButton>
      {open ? (
        <>
          <HostComparisonTableHeading
            id="host-comparison-table"
            ref={comparisonTableRef}
            tabIndex={-1}
          >
            <UiLabel>Full table</UiLabel>
            <p>
              District and BookMyShow are strong Indian discovery and ticketing
              surfaces. Catch is positioned around the host operating loop after the
              listing goes live.
            </p>
          </HostComparisonTableHeading>
          <HostComparisonTable>
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
          </HostComparisonTable>
        </>
      ) : null}
    </HostFeatureSection>
  );
}
