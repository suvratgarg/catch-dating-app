import {trackOrganizerAnalytics} from "../analytics";
import type {HostListing} from "../types";

export function ListingSourcesSection({listing}: {listing: HostListing}) {
  return (
    <section className="listing-section listing-section--split" id="sources">
      <div data-reveal>
        <span className="ui-label">Source ledger</span>
        <h2>Evidence before indexing.</h2>
        <p>
          Thin pages should stay out of search until identity, cadence, and
          owner-safe details are verified.
        </p>
      </div>

      <div className="listing-ledger" data-reveal>
        {listing.sources.map((source) => (
          <article key={`${source.type}-${source.label}`}>
            <div>
              <strong>{source.label}</strong>
              <span>{source.confidence} confidence</span>
            </div>
            <p>{source.detail}</p>
            {source.href ? (
              <a
                className="source-link"
                href={source.href}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackOrganizerAnalytics(
                  listing,
                  source.type === "socialProfile" ? "contactClick" : "outboundClick",
                  `source_${source.type}`
                )}
              >
                Open source
              </a>
            ) : null}
          </article>
        ))}
      </div>
    </section>
  );
}
