import assert from "node:assert/strict";
import test from "node:test";
import {buildPlacesAutocompleteRequestBody} from "./googlePlaces";

test(
  "buildPlacesAutocompleteRequestBody scopes supported country searches",
  () => {
    const body = buildPlacesAutocompleteRequestBody({
      input: "Hyde Park",
      sessionToken: "places-session-1",
      countryIsoCode: "AU",
      latitude: -33.8688,
      longitude: 151.2093,
    });

    assert.deepEqual(body, {
      input: "Hyde Park",
      includedRegionCodes: ["au"],
      languageCode: "en",
      regionCode: "au",
      sessionToken: "places-session-1",
      locationBias: {
        circle: {
          center: {latitude: -33.8688, longitude: 151.2093},
          radius: 50000,
        },
      },
    });
  }
);

test(
  "buildPlacesAutocompleteRequestBody defaults to all supported markets",
  () => {
    const body = buildPlacesAutocompleteRequestBody({
      input: "Park",
    });

    assert.deepEqual(body, {
      input: "Park",
      includedRegionCodes: ["in", "np", "au", "us"],
      languageCode: "en",
    });
  }
);
