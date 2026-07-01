import type {HostListing} from "../types";

export function ListingFitSection({
  isAppCreated,
  listing,
}: {
  isAppCreated: boolean;
  listing: HostListing;
}) {
  return (
    <section className="listing-section" id="fit" aria-labelledby="listing-fit-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">{isAppCreated ? "Page format" : "Catch fit"}</span>
        <h2 id="listing-fit-title">
          {isAppCreated ?
            "What the app-created profile needs to emphasize." :
            "Why this category belongs in the first test."}
        </h2>
      </div>
      <div className="listing-grid listing-grid--fit">
        {listing.fitNotes.map((note) => (
          <article className="listing-card" data-reveal key={note}>
            <p>{note}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
