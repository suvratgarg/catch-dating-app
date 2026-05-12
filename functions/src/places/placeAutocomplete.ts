import {onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";
import {checkRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {
  autocompletePlaces,
  getPlaceDetails,
  googleMapsPlacesApiKey,
} from "./googlePlaces";

const PlacesAutocompleteSchema = z.object({
  input: z.string().trim().min(2).max(120),
  sessionToken: z.string().trim().min(8).max(128).optional(),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
});

const PlaceDetailsSchema = z.object({
  placeId: z.string().trim().min(1).max(256),
  sessionToken: z.string().trim().min(8).max(128).optional(),
});

export const placesAutocomplete = onCall(
  appCheckCallableOptionsWithSecrets([googleMapsPlacesApiKey]),
  async (request) => {
    const userId = requireAuth(request);
    const payload = validateCallable(request, PlacesAutocompleteSchema);
    await checkRateLimit(admin.firestore(), userId, "placesAutocomplete");

    return {
      predictions: await autocompletePlaces(payload),
    };
  }
);

export const placeDetails = onCall(
  appCheckCallableOptionsWithSecrets([googleMapsPlacesApiKey]),
  async (request) => {
    const userId = requireAuth(request);
    const payload = validateCallable(request, PlaceDetailsSchema);
    await checkRateLimit(admin.firestore(), userId, "placeDetails");

    return {
      place: await getPlaceDetails(payload),
    };
  }
);
