import {
  loadEventIntakeDashboard,
} from "../../../../shared/api/adminApi";
import type {
  AdminGetEventIntakeDashboardResponse,
} from "../../../../shared/types/adminTypes";

/**
 * Loads the server projection of completed Supply Intake Operations runs.
 * The callable name remains stable, but no dashboard document or repository
 * artifact participates in the live read.
 */
export async function loadEventIntakeBridge():
Promise<AdminGetEventIntakeDashboardResponse> {
  return loadEventIntakeDashboard();
}

export {
  recordEventIntakeReviewDecision,
} from "../../../../shared/api/adminApi";
