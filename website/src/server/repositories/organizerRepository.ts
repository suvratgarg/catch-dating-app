import {isPubliclyReadableListing, isVerifiedListing} from "../../features/organizers/selectors";
import type {HostListing} from "../../features/organizers/types";
import {projectPublicOrganizer} from "../publicOrganizerProjection";
import {readBounded, type PublicDocument, type PublicQuery, type PublicReader} from "./publicReader";

const listBound = 400;
const recommendationReadBound = 12;

export interface PublishedOrganizerRoute {
  listing: HostListing;
  isLegacyPath: boolean;
}

function published(db: PublicReader): PublicQuery {
  return db.collection("organizers").where("publicPage.publishStatus", "==", "published");
}

function project(docs: readonly PublicDocument[], markets: ReadonlySet<string>): HostListing[] {
  return docs.flatMap((doc) => {
    const listing = projectPublicOrganizer(doc.id, doc.data(), markets);
    return listing ? [listing] : [];
  });
}

/** Listings that claim the same path are all withheld rather than guessed between. */
function withUniquePaths(listings: HostListing[]): HostListing[] {
  const counts = new Map<string, number>();
  for (const listing of listings) counts.set(listing.path, (counts.get(listing.path) ?? 0) + 1);
  return listings.filter((listing) => counts.get(listing.path) === 1);
}

async function listingsAtPath(db: PublicReader, path: string, markets: ReadonlySet<string>) {
  const snapshot = await published(db).where("publicPage.canonicalPath", "==", path).limit(2).get();
  return project(snapshot.docs, markets).filter((listing) => listing.path === path);
}

async function hasUniquePath(db: PublicReader, listing: HostListing, markets: ReadonlySet<string>) {
  return (await listingsAtPath(db, listing.path, markets)).length === 1;
}

/** Every published organizer page: directory, discovery, claim lookup and sitemap. */
export async function listPublishedOrganizers(
  db: PublicReader,
  markets: ReadonlySet<string>
): Promise<HostListing[]> {
  return withUniquePaths(project(await readBounded(published(db), listBound), markets));
}

/** A canonical path wins; otherwise one unambiguous legacy alias redirects to it. */
export async function findPublishedOrganizerByPath(
  db: PublicReader,
  pathname: string,
  markets: ReadonlySet<string>
): Promise<PublishedOrganizerRoute | null> {
  const path = pathname.endsWith("/") ? pathname : `${pathname}/`;
  const canonical = await listingsAtPath(db, path, markets);
  if (canonical.length === 1) return {listing: canonical[0], isLegacyPath: false};
  const aliasSnapshot = await published(db)
    .where("publicPage.legacyPaths", "array-contains", path).limit(2).get();
  const aliases = project(aliasSnapshot.docs, markets)
    .filter((listing) => listing.legacyPaths?.includes(path));
  if (aliases.length !== 1 || !await hasUniquePath(db, aliases[0], markets)) return null;
  return {listing: aliases[0], isLegacyPath: true};
}

/** The organizer behind an event page, held to the same publication and path rules. */
export async function findPublishedOrganizerById(
  db: PublicReader,
  organizerId: string,
  markets: ReadonlySet<string>
): Promise<HostListing | null> {
  const snapshot = await db.collection("organizers").doc(organizerId).get();
  if (!snapshot.exists) return null;
  const listing = projectPublicOrganizer(snapshot.id, snapshot.data(), markets);
  return listing && await hasUniquePath(db, listing, markets) ? listing : null;
}

/**
 * Verified organizers for a recommendation rail, in document-id order like the
 * full catalog read, filtered exactly as `RecommendedOrganizersSection` filters
 * the full catalog. Each trust signal is one bounded equality read.
 */
export async function listRecommendedOrganizers(
  db: PublicReader,
  markets: ReadonlySet<string>,
  excludeId: string,
  count = 3
): Promise<HostListing[]> {
  const reads = await Promise.all([
    ["ownership.state", "userCreated"],
    ["provenance.verificationStatus", "ownerVerified"],
    ["claim.state", "verified"],
  ].map(([field, value]) => published(db).where(field, "==", value).limit(recommendationReadBound).get()));
  const byId = new Map<string, HostListing>();
  for (const listing of project(reads.flatMap((snapshot) => snapshot.docs), markets)) {
    byId.set(listing.id, listing);
  }
  const candidates = [...byId.values()]
    .filter((listing) => listing.id !== excludeId && isPubliclyReadableListing(listing) && isVerifiedListing(listing))
    .sort((a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
  const recommended: HostListing[] = [];
  for (const listing of candidates) {
    if (recommended.length === count) break;
    if (await hasUniquePath(db, listing, markets)) recommended.push(listing);
  }
  return recommended;
}
