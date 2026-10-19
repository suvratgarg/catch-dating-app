import "server-only";
import {validatePublicRuntimeEnvironment} from "./publicEnvironment";
import {publicExternalEvent} from "./publicExternalEvent";
import {getApps, initializeApp, applicationDefault} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {cache} from "react";
import {activeEventLiveCities} from "../content/markets";
import type {PublicCatalog} from "../app/next/publicCatalogTypes";
import {projectLivePublicCatchEvent} from "../features/organizers/publicCatchEventProjection";
import {projectPublicOrganizer} from "./publicOrganizerProjection";
import {projectPublicReview} from "./publicReviewProjection";
import type {HostListing} from "../features/organizers/types";
import {publicEventAuthorized} from "./publicReadPolicy";

const markets = new Set(activeEventLiveCities.map(city => city.slug));
const limit = 400;
function database() {
  validatePublicRuntimeEnvironment();
  const projectId = process.env.CATCH_PUBLIC_FIRESTORE_PROJECT;
  if (!projectId) throw new Error("CATCH_PUBLIC_FIRESTORE_PROJECT is required");
  const name = "catch-public-website-reader";
  const app = getApps().find(candidate => candidate.name === name) ?? initializeApp({
    projectId, credential: applicationDefault(),
  }, name);
  return getFirestore(app);
}

/** React cache deduplicates within one render only. No cross-request or offline cache. */
async function loadPublicCatalog(): Promise<PublicCatalog> {
  const db = database();
  const readAt = Date.now();
  const [organizers, events, externalEvents] = await withinReadDeadline(Promise.all([
    db.collection("organizers").where("publicPage.publishStatus", "==", "published").limit(limit + 1).get(),
    db.collection("events").where("publicationState", "==", "published").limit(limit + 1).get(),
    db.collection("externalEvents").where("publicationStatus", "==", "public").limit(limit + 1).get(),
  ]));
  if (organizers.size > limit || events.size > limit || externalEvents.size > limit) throw new Error("PUBLIC_CATALOG_READ_BOUND_EXCEEDED");
  const candidates = organizers.docs.flatMap(doc => {
    const listing = projectPublicOrganizer(doc.id, doc.data(), markets);
    return listing ? [listing] : [];
  });
  const pathCounts = new Map<string, number>();
  for (const listing of candidates) pathCounts.set(listing.path, (pathCounts.get(listing.path) ?? 0) + 1);
  const listings = candidates.filter(listing => pathCounts.get(listing.path) === 1);
  const byId = new Map(listings.map(listing => [listing.id, listing]));
  for (const doc of events.docs) {
    const raw = doc.data();
    if (!publicEventAuthorized(doc.id, raw)) continue;
    const row = projectLivePublicCatchEvent(doc.id, raw, readAt);
    if (row) byId.get(row.organizerId)?.catchEvents?.push(row.event);
  }
  for (const doc of externalEvents.docs) {
    const row = publicExternalEvent(doc.id, doc.data());
    const listing = row && byId.get(row.organizerId);
    if (row && listing) (listing.externalEvents ??= []).push(row.event);
  }
  return {listings, readAt};
}
export const readPublicCatalog = cache(loadPublicCatalog);

async function withinReadDeadline<T>(read: Promise<T>): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([read, new Promise<never>((_, reject) => {
      timer = setTimeout(() => reject(new Error("PUBLIC_READ_TIMEOUT")), 8_000);
    })]);
  } finally {clearTimeout(timer);}
}

/** Two bounded reads at most, only for a resolved detail route. Never fan out across discovery. */
export async function readPublicListingReviews(listing: HostListing, eventId?: string): Promise<HostListing> {
  if (listing.capabilities.publicReviews.readState !== "enabled") return listing;
  try {
    const reviews = database().collection("reviews");
    const snapshots = await withinReadDeadline(Promise.all([
      reviews.where("organizerId", "==", listing.id).orderBy("createdAt", "desc").limit(50).get(),
      ...(eventId ? [reviews.where("eventId", "==", eventId).orderBy("createdAt", "desc").limit(50).get()] : []),
    ]));
    const published = snapshots.flatMap(snapshot => snapshot.docs.flatMap(doc => {
      const review = projectPublicReview(doc.id, doc.data(), listing.id);
      return review ? [review] : [];
    }));
    return {...listing, reviewReadState: "ready", reviews: [...new Map(published.map(review => [review.id, review])).values()]
      .sort((a, b) => Date.parse(b.createdAt) - Date.parse(a.createdAt))};
  } catch {
    // A missing index or transient read failure must not erase the event or imply zero reviews.
    return {...listing, reviews: [], reviewReadState: "unavailable"};
  }
}
