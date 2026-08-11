import {hostComparisonRows, hostPageCopy} from "@content/host";
import {SectionHeader} from "../../../shared/site";
import {
  HostComparisonCallout,
  HostComparisonTable,
  HostFeatureSection,
} from "../../../shared/ui/primitives";

export function HostComparisonSection() {
  return (
    <HostFeatureSection
      id="works-now"
      variant="comparison"
      aria-labelledby="host-comparison-title"
    >
      <SectionHeader
        eyebrow={hostPageCopy.comparison.label}
        id="host-comparison-title"
        title={hostPageCopy.comparison.title}
      />
      <HostComparisonTable
        ariaLabel={hostPageCopy.comparison.tableLabel}
        tableClassName="comparison-table--bridge"
      >
        <thead>
          <tr>
            <th>{hostPageCopy.comparison.bookingColumn}</th>
            <th>{hostPageCopy.comparison.catchColumn}</th>
          </tr>
        </thead>
        <tbody>
          {hostComparisonRows.map(([booking, catchAlongside]) => (
            <tr key={booking}>
              <td>{booking}</td>
              <td>{catchAlongside}</td>
            </tr>
          ))}
        </tbody>
      </HostComparisonTable>
      <HostComparisonCallout limits={hostPageCopy.comparison.limits}>
        <strong>{hostPageCopy.comparison.callout}</strong>
      </HostComparisonCallout>
    </HostFeatureSection>
  );
}
