// Creates the config/cities Firestore document in all three Firebase projects.
// Usage: node tool/create_config_cities.js
//
// Requires Application Default Credentials with Firestore access to
// catchdates-dev, catchdates-staging, and catch-dating-app-64e51.

const admin = require("../functions/node_modules/firebase-admin");

const cities = [
  ["mumbai", "Mumbai", 19.076, 72.8777, "IN", "INR", "+91", "Asia/Kolkata"],
  ["delhi", "Delhi", 28.7041, 77.1025, "IN", "INR", "+91", "Asia/Kolkata"],
  ["bangalore", "Bangalore", 12.9716, 77.5946, "IN", "INR", "+91", "Asia/Kolkata"],
  ["hyderabad", "Hyderabad", 17.385, 78.4867, "IN", "INR", "+91", "Asia/Kolkata"],
  ["chennai", "Chennai", 13.0827, 80.2707, "IN", "INR", "+91", "Asia/Kolkata"],
  ["kolkata", "Kolkata", 22.5726, 88.3639, "IN", "INR", "+91", "Asia/Kolkata"],
  ["pune", "Pune", 18.5204, 73.8567, "IN", "INR", "+91", "Asia/Kolkata"],
  ["ahmedabad", "Ahmedabad", 23.0225, 72.5714, "IN", "INR", "+91", "Asia/Kolkata"],
  ["indore", "Indore", 22.7196, 75.8577, "IN", "INR", "+91", "Asia/Kolkata"],
  ["kathmandu", "Kathmandu", 27.7172, 85.324, "NP", "NPR", "+977", "Asia/Kathmandu"],
  ["pokhara", "Pokhara", 28.2096, 83.9856, "NP", "NPR", "+977", "Asia/Kathmandu"],
  ["sydney", "Sydney", -33.8688, 151.2093, "AU", "AUD", "+61", "Australia/Sydney"],
  ["melbourne", "Melbourne", -37.8136, 144.9631, "AU", "AUD", "+61", "Australia/Melbourne"],
  ["brisbane", "Brisbane", -27.4698, 153.0251, "AU", "AUD", "+61", "Australia/Brisbane"],
  ["new-york", "New York", 40.7128, -74.006, "US", "USD", "+1", "America/New_York"],
  ["san-francisco", "San Francisco", 37.7749, -122.4194, "US", "USD", "+1", "America/Los_Angeles"],
  ["los-angeles", "Los Angeles", 34.0522, -118.2437, "US", "USD", "+1", "America/Los_Angeles"],
].map(([
  name,
  label,
  latitude,
  longitude,
  countryIsoCode,
  currencyCode,
  dialCode,
  timeZone,
]) => ({
  name,
  label,
  latitude,
  longitude,
  countryIsoCode,
  currencyCode,
  dialCode,
  timeZone,
}));

const CITIES_DOC = {
  cityNames: cities.map((city) => city.name),
  cities,
};

async function createConfigDoc(projectId) {
  const app = admin.initializeApp({ projectId }, projectId);
  const db = app.firestore();
  await db.collection("config").doc("cities").set(CITIES_DOC);
  console.log(`  OK  ${projectId}`);
  await app.delete();
}

(async () => {
  console.log("Creating config/cities...\n");
  try {
    await createConfigDoc("catchdates-dev");
    await createConfigDoc("catchdates-staging");
    await createConfigDoc("catch-dating-app-64e51");
    console.log("\nDone — all 3 projects configured.");
  } catch (e) {
    console.error("\nFAILED:", e.message);
    process.exit(1);
  }
})();
