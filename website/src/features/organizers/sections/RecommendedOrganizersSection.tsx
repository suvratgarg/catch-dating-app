import {hostListings} from "../data";
import {OrganizerMiniCard} from "../OrganizerMiniCard";
import {isVerifiedListing} from "../selectors";
import type {HostListing} from "../types";

export function RecommendedOrganizersSection({current}: {current: HostListing}) {
  const recommended = hostListings
    .filter((listing) => listing.id !== current.id && isVerifiedListing(listing))
    .slice(0, 3);
  if (!recommended.length) return null;

  return (
    <section className="listing-section recommended-organizers" aria-labelledby="recommended-organizers-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">While you are here</span>
        <h2 id="recommended-organizers-title">Verified organizers nearby in the product loop.</h2>
        <p>
          Unclaimed pages keep the source ledger visible, but verified profiles
          can show owner-managed activity, reviews, and event outcomes.
        </p>
      </div>
      <div className="featured-organizers__grid">
        {recommended.map((listing) => (
          <OrganizerMiniCard listing={listing} key={listing.id} />
        ))}
      </div>
    </section>
  );
}
