import {organizerFixture} from "./organizerFixture.mjs";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

// This writer cannot connect to a real Firebase project.
if (process.env.FIRESTORE_EMULATOR_HOST !== "127.0.0.1:8765") throw new Error("Isolated emulator required");
const db = getFirestore(initializeApp({projectId: "demo-catch-nextjs"}));
const data = organizerFixture();
await db.doc("organizers/next-proof").set(data);
await db.terminate();
console.log("Isolated organizer fixture ready");
