import {getFunctions} from "firebase/functions";
import {firebaseApp} from "./firebaseCore";

export const functions = getFunctions(firebaseApp, "asia-south1");
