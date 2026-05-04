// Creates the config/cities Firestore document in all three Firebase projects.
// Usage: node tool/create_config_cities.js
//
// Requires Application Default Credentials with Firestore access to
// catchdates-dev, catchdates-staging, and catch-dating-app-64e51.

const admin = require("../functions/node_modules/firebase-admin");

const CITIES_DOC = {
  cityNames: [
    "mumbai", "delhi", "bangalore", "hyderabad",
    "chennai", "kolkata", "pune", "ahmedabad", "indore",
  ],
  cities: [
    { name: "mumbai", label: "Mumbai", latitude: 19.076, longitude: 72.8777 },
    { name: "delhi", label: "Delhi", latitude: 28.7041, longitude: 77.1025 },
    { name: "bangalore", label: "Bangalore", latitude: 12.9716, longitude: 77.5946 },
    { name: "hyderabad", label: "Hyderabad", latitude: 17.385, longitude: 78.4867 },
    { name: "chennai", label: "Chennai", latitude: 13.0827, longitude: 80.2707 },
    { name: "kolkata", label: "Kolkata", latitude: 22.5726, longitude: 88.3639 },
    { name: "pune", label: "Pune", latitude: 18.5204, longitude: 73.8567 },
    { name: "ahmedabad", label: "Ahmedabad", latitude: 23.0225, longitude: 72.5714 },
    { name: "indore", label: "Indore", latitude: 22.7196, longitude: 75.8577 },
  ],
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
