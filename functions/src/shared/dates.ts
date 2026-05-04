import {differenceInYears} from "date-fns";

/**
 * Computes age in full years from a date of birth.
 * @param {Date} dob The user's date of birth.
 * @return {number} Age in whole years.
 */
export function computeAge(dob: Date): number {
  return differenceInYears(new Date(), dob);
}
