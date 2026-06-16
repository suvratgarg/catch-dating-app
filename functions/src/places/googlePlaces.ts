import {HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

export const googleMapsPlacesApiKey = defineSecret(
  "GOOGLE_MAPS_PLACES_API_KEY"
);

const autocompleteEndpoint =
  "https://places.googleapis.com/v1/places:autocomplete";
const detailsEndpoint = "https://places.googleapis.com/v1/places";
const supportedRegionCodes = ["in", "np", "au", "us"];

export interface PlaceAutocompleteResult {
  placeId: string;
  description: string;
  mainText: string;
  secondaryText: string;
}

export interface PlaceDetailsResult {
  placeId: string;
  displayName: string;
  formattedAddress: string;
  latitude: number;
  longitude: number;
}

interface GooglePlaceAutocompleteResponse {
  suggestions?: Array<{
    placePrediction?: {
      placeId?: string;
      text?: {text?: string};
      structuredFormat?: {
        mainText?: {text?: string};
        secondaryText?: {text?: string};
      };
    };
  }>;
}

interface GooglePlaceDetailsResponse {
  id?: string;
  displayName?: {text?: string};
  formattedAddress?: string;
  location?: {
    latitude?: number;
    longitude?: number;
  };
}

/**
 * Calls Google Places Autocomplete (New) for meeting-point search.
 * @param {object} params Autocomplete request parameters.
 * @param {string} params.input User-entered search query.
 * @param {string=} params.sessionToken Google billing/session token.
 * @param {number=} params.latitude Optional latitude bias.
 * @param {number=} params.longitude Optional longitude bias.
 * @param {string=} params.countryIsoCode Optional ISO country scope.
 * @return {Promise<PlaceAutocompleteResult[]>} Normalized predictions.
 */
export async function autocompletePlaces({
  input,
  sessionToken,
  latitude,
  longitude,
  countryIsoCode,
}: {
  input: string;
  sessionToken?: string;
  latitude?: number;
  longitude?: number;
  countryIsoCode?: string;
}): Promise<PlaceAutocompleteResult[]> {
  const body = buildPlacesAutocompleteRequestBody({
    input,
    sessionToken,
    latitude,
    longitude,
    countryIsoCode,
  });

  const response = await fetch(autocompleteEndpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": googleMapsPlacesApiKey.value(),
      "X-Goog-FieldMask": [
        "suggestions.placePrediction.placeId",
        "suggestions.placePrediction.text.text",
        "suggestions.placePrediction.structuredFormat.mainText.text",
        "suggestions.placePrediction.structuredFormat.secondaryText.text",
      ].join(","),
    },
    body: JSON.stringify(body),
  });

  const json = await parsePlacesResponse<GooglePlaceAutocompleteResponse>(
    response
  );

  return (json.suggestions ?? [])
    .map((suggestion) => suggestion.placePrediction)
    .filter((prediction): prediction is NonNullable<typeof prediction> =>
      prediction != null && prediction.placeId != null
    )
    .map((prediction) => {
      const description = prediction.text?.text ?? "";
      const mainText = prediction.structuredFormat?.mainText?.text ??
        description;
      const secondaryText =
        prediction.structuredFormat?.secondaryText?.text ?? "";
      return {
        placeId: prediction.placeId ?? "",
        description,
        mainText,
        secondaryText,
      };
    })
    .filter((result) => result.placeId.length > 0);
}

/**
 * Builds the Places Autocomplete request body.
 * @param {object} params Autocomplete request parameters.
 * @param {string} params.input User-entered search query.
 * @param {string=} params.sessionToken Google billing/session token.
 * @param {number=} params.latitude Optional latitude bias.
 * @param {number=} params.longitude Optional longitude bias.
 * @param {string=} params.countryIsoCode Optional ISO country scope.
 * @return {Record<string, unknown>} Google Places request body.
 */
export function buildPlacesAutocompleteRequestBody({
  input,
  sessionToken,
  latitude,
  longitude,
  countryIsoCode,
}: {
  input: string;
  sessionToken?: string;
  latitude?: number;
  longitude?: number;
  countryIsoCode?: string;
}): Record<string, unknown> {
  const regionCodes = autocompleteRegionCodes(countryIsoCode);
  const body: Record<string, unknown> = {
    input,
    includedRegionCodes: regionCodes,
    languageCode: "en",
  };

  if (regionCodes.length === 1) {
    body.regionCode = regionCodes[0];
  }

  if (sessionToken) {
    body.sessionToken = sessionToken;
  }

  if (latitude != null && longitude != null) {
    body.locationBias = {
      circle: {
        center: {latitude, longitude},
        radius: 50000,
      },
    };
  }

  return body;
}

/**
 * Returns supported Places region scopes for a requested country.
 * @param {string=} countryIsoCode ISO country code from the app.
 * @return {string[]} Lowercase Places region codes.
 */
function autocompleteRegionCodes(countryIsoCode?: string): string[] {
  const normalized = countryIsoCode?.trim().toLowerCase();
  if (normalized != null && supportedRegionCodes.includes(normalized)) {
    return [normalized];
  }
  return supportedRegionCodes;
}

/**
 * Fetches coordinates and display metadata for a Google Places result.
 * @param {object} params Place details request parameters.
 * @param {string} params.placeId Google place ID.
 * @param {string=} params.sessionToken Google billing/session token.
 * @return {Promise<PlaceDetailsResult>} Normalized place details.
 */
export async function getPlaceDetails({
  placeId,
  sessionToken,
}: {
  placeId: string;
  sessionToken?: string;
}): Promise<PlaceDetailsResult> {
  const normalizedPlaceId = placeId.replace(/^places\//, "");
  const url = new URL(`${detailsEndpoint}/${encodeURIComponent(
    normalizedPlaceId
  )}`);
  if (sessionToken) {
    url.searchParams.set("sessionToken", sessionToken);
  }

  const response = await fetch(url, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": googleMapsPlacesApiKey.value(),
      "X-Goog-FieldMask": "id,displayName,formattedAddress,location",
    },
  });

  const json = await parsePlacesResponse<GooglePlaceDetailsResponse>(response);
  const lat = json.location?.latitude;
  const lng = json.location?.longitude;
  if (json.id == null || lat == null || lng == null) {
    throw new HttpsError(
      "internal",
      "Google Places returned an incomplete place details response."
    );
  }

  return {
    placeId: json.id,
    displayName: json.displayName?.text ?? "",
    formattedAddress: json.formattedAddress ?? "",
    latitude: lat,
    longitude: lng,
  };
}

/**
 * Parses a Places API response and converts upstream failures to callable
 * errors.
 * @param {Response} response Fetch response from Google Places.
 * @return {Promise<T>} Parsed JSON payload.
 */
async function parsePlacesResponse<T>(response: Response): Promise<T> {
  const text = await response.text();
  let json: unknown;
  try {
    json = text.length > 0 ? JSON.parse(text) : {};
  } catch {
    throw new HttpsError(
      "internal",
      "Google Places returned a malformed response."
    );
  }

  if (!response.ok) {
    // Log the upstream detail for ops, but never forward raw Google error text
    // (which can carry key/quota/infra detail) to the client.
    logger.warn("Google Places request failed", {
      status: response.status,
      upstreamMessage: extractGoogleErrorMessage(json),
    });
    throw new HttpsError(
      "internal",
      "Place lookup is unavailable right now. Please try again."
    );
  }

  return json as T;
}

/**
 * Extracts Google API error.message from an unknown JSON payload.
 * @param {unknown} json Parsed JSON response body.
 * @return {string | null} Error message when present.
 */
function extractGoogleErrorMessage(json: unknown): string | null {
  if (
    json != null &&
    typeof json === "object" &&
    "error" in json &&
    typeof json.error === "object" &&
    json.error != null &&
    "message" in json.error &&
    typeof json.error.message === "string"
  ) {
    return json.error.message;
  }
  return null;
}
