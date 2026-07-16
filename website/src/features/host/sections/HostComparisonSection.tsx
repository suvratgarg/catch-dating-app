import {websiteCopy} from "@content/generated";
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
} from "@content/marketing";

const hostComparisonSummaryCards = [
  {
    key: "tools",
    label: websiteCopy["hostcomparisonsection_0289"],
    title: websiteCopy["hostcomparisonsection_0291"],
    body:
      websiteCopy["hostcomparisonsection_0292"],
  },
  {
    key: "catch",
    label: websiteCopy["hostcomparisonsection_0285"],
    title: websiteCopy["hostcomparisonsection_0286"],
    body:
      websiteCopy["hostcomparisonsection_0282"],
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
        eyebrow={websiteCopy["hostcomparisonsection_0290"]}
        id="host-comparison-title"
        title={websiteCopy["hostcomparisonsection_0283"]} />
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
            <UiLabel>{websiteCopy["hostcomparisonsection_0288"]}</UiLabel>
            <p>{websiteCopy["hostcomparisonsection_0287"]}</p>
          </HostComparisonTableHeading>
          <HostComparisonTable>
              <thead>
                <tr>
                  <th>{websiteCopy["hostcomparisonsection_0284"]}</th>
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
