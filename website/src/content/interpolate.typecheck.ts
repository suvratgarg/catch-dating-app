import {interpolateContent} from "./interpolate";

interpolateContent("Hello {name} in {city}", {name: "Aarav", city: "Mumbai"});

// @ts-expect-error Literal templates require every declared token.
interpolateContent("Hello {name} in {city}", {name: "Aarav"});

// @ts-expect-error Literal templates reject extra or misspelled token keys.
interpolateContent("Hello {name}", {name: "Aarav", nmae: "typo"});

const dynamicTemplate: string = "Hello {name}";
interpolateContent(dynamicTemplate, {name: "Aarav"});
