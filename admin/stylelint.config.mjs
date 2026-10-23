import {reportingOptions, tokenRules} from "@catch/web-config/stylelint";

/**
 * Admin CSS takes every colour, length, type, timing, shadow and stacking
 * value from the generated Catch tokens. Existing violations are recorded in
 * stylelint-suppressions.json, which may only shrink.
 */
export default {
  ...reportingOptions,
  rules: tokenRules,
};
