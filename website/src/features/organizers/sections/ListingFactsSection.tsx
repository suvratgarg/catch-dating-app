import type {HostListing} from "../types";

export function ListingFactsSection({
  isAppCreated,
  listing,
}: {
  isAppCreated: boolean;
  listing: HostListing;
}) {
  return (
    <section className="listing-section" aria-labelledby="listing-facts-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">
          {isAppCreated ? "Club profile" : "Known profile"}
        </span>
        <h2 id="listing-facts-title">
          {isAppCreated ?
            "A Catch-created club with real product context." :
            "A source-conservative seed listing."}
        </h2>
        <p>{listing.sourceSummary}</p>
      </div>
      <div className="listing-grid">
        {listing.facts.map((fact) => (
          <article className="listing-card" data-reveal key={fact.label}>
            <span>{fact.label}</span>
            <strong>{fact.value}</strong>
          </article>
        ))}
      </div>
    </section>
  );
}
