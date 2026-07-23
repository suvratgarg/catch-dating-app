import {listActionExecutions} from "../../../shared/api/adminApi";
import type {
  AdminListActionExecutionsPayload,
  AdminListActionExecutionsResponse,
} from "../../../shared/types/adminTypes";

export async function loadAdminActionExecutions(
  payload: AdminListActionExecutionsPayload = {}
): Promise<AdminListActionExecutionsResponse> {
  return listActionExecutions(payload);
}
