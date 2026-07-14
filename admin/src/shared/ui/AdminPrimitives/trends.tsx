import type {ReactNode} from "react";

import {DataTable} from "./data";
import {AdminSecondaryDisclosure, EmptyState} from "./workbench";

export interface AdminTrendSeriesDefinition {
  id: string;
  label: string;
  formatValue?: (value: number) => ReactNode;
}

export interface AdminTrendPoint {
  label: string;
  values: Record<string, number>;
}

export function AdminTrendSeries({
  ariaLabel,
  emptyLabel,
  points,
  series,
}: {
  ariaLabel: string;
  emptyLabel: ReactNode;
  points: AdminTrendPoint[];
  series: AdminTrendSeriesDefinition[];
}) {
  if (points.length === 0 || series.length === 0) {
    return <EmptyState variant="workbench">{emptyLabel}</EmptyState>;
  }

  const values = points.flatMap((point) =>
    series.map((definition) => safeTrendValue(point.values[definition.id]))
  );
  const minimum = Math.min(0, ...values);
  const maximum = Math.max(1, ...values);
  const range = Math.max(1, maximum - minimum);
  const pathFor = (seriesId: string) => points.map((point, index) => {
    const x = points.length === 1 ? 300 : (index / (points.length - 1)) * 600;
    const value = safeTrendValue(point.values[seriesId]);
    const y = 188 - ((value - minimum) / range) * 176;
    return `${index === 0 ? "M" : "L"} ${x.toFixed(2)} ${y.toFixed(2)}`;
  }).join(" ");

  return (
    <div className="admin-trend-series">
      <figure aria-label={ariaLabel}>
        <svg aria-hidden="true" preserveAspectRatio="none" viewBox="0 0 600 200">
          <line className="admin-trend-axis" x1="0" x2="600" y1="188" y2="188" />
          {series.map((definition, index) => (
            <path
              className={`admin-trend-line admin-trend-line-${(index % 4) + 1}`}
              d={pathFor(definition.id)}
              key={definition.id}
            />
          ))}
        </svg>
        <figcaption>
          {series.map((definition, index) => (
            <span key={definition.id}>
              <i className={`admin-trend-swatch admin-trend-swatch-${(index % 4) + 1}`} />
              {definition.label}
            </span>
          ))}
        </figcaption>
      </figure>
      <AdminSecondaryDisclosure summary="View chart data as a table">
        <DataTable ariaLabel={`${ariaLabel} data`} variant="workbench">
          <thead>
            <tr>
              <th>Period</th>
              {series.map((definition) => (
                <th key={definition.id}>{definition.label}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {points.map((point) => (
              <tr key={point.label}>
                <td>{point.label}</td>
                {series.map((definition) => {
                  const value = safeTrendValue(point.values[definition.id]);
                  return (
                    <td key={definition.id}>
                      {definition.formatValue?.(value) ?? value}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </DataTable>
      </AdminSecondaryDisclosure>
    </div>
  );
}

function safeTrendValue(value: number | undefined): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}
