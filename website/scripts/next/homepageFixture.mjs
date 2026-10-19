import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {organizerFixture} from "./organizerFixture.mjs";

// Separate namespace from the rewrite's acceptance fixtures; impossible to seed production.
if (process.env.FIRESTORE_EMULATOR_HOST !== "127.0.0.1:8765") throw new Error("Isolated emulator required");
const db = getFirestore(initializeApp({projectId: "demo-catch-homepage"}, "homepage-design-fixture"));
const organisers = [
  ["sunday-strides", "Sunday Strides", "Social runs", "A welcoming community run by runners, for everyone. Regular runs across Mumbai to keep you moving and meeting new people."],
  ["table-stories", "Table Stories", "Dinners", "Curated dinner experiences that bring interesting people to the table, from neighbourhood gems to private chefs."],
  ["court-social", "Court Social", "Racket socials", "Racket sports, real connections. Laid-back games and socials for all levels across Mumbai."],
];
for (const [id, name, category, description] of organisers) {
  const data = organizerFixture();
  Object.assign(data, {name, description, publicCategoryLabel: category, cityName: "Mumbai", regionName: "Maharashtra", location: "in-mh-mumbai", locationCityId: "in-mh-mumbai", locationMarketId: "in-mh-mumbai", tags: [category], rating: 0, reviewCount: 0, nextEventAt: null, nextEventLabel: null});
  Object.assign(data.publicPage, {slug: id, citySlug: "mumbai", canonicalPath: `/organizers/${id}/`, indexStatus: "noindex", robots: "noindex, follow"});
  data.claim.claimHref = `/organizers/${id}/#claim`;
  await db.doc(`organizers/${id}`).set(data);
}
const saturday = new Date(); saturday.setUTCDate(saturday.getUTCDate() + ((6-saturday.getUTCDay()+7)%7 || 7)); saturday.setUTCHours(11,30,0,0);
const events = [
  ["sunday-run", "Sunday Social Run", "sunday-strides", "socialRun", "Bandra", 0, 14],
  ["long-table", "The Long Table", "table-stories", "dinner", "Khar", 120000, 2],
  ["pickleball-partners", "Pickleball & New Partners", "court-social", "pickleball", "Andheri", 65000, 0],
  ["friday-quiz", "Friday Quiz Club", "table-stories", "pubQuiz", "Lower Parel", 40000, -21],
];
for (const [id, name, organizerId, activityKind, venue, price, offset] of events) {
  const start = new Date(saturday.getTime()+offset*3600000);
  await db.doc(`events/${id}`).set({name, organizerId, clubId: organizerId, publicationState: "published", status: "active", eventFormat: {activityKind}, startTime: Timestamp.fromDate(start), endTime: Timestamp.fromMillis(start.getTime()+7200000), eventTimezone: "Asia/Kolkata", meetingLocation: {name: venue}, currency: "INR", priceInPaise: price, capacityLimit: 30, bookedCount: 6, publicRegistrationEnabled: true, publicRegistrationMode: price ? "paid" : "free", description: "Illustrative local preview event. This is not a real booking."});
}
await db.terminate();
console.log("Homepage preview fixtures ready in demo-catch-homepage; Indore intentionally has no listings.");
