import {httpsCallable} from "firebase/functions";
import {validateAdminCallableRequest,
  validateAdminCallableResponse} from
  "../../../generated/validators/adminCallableValidators";
import {dataMode} from "../../../shared/api/dataMode";
import {functions} from "../../../shared/api/firebaseFunctions";
import type {SalesHistoryApi} from "./salesHistoryTypes";

async function call<Request, Response>(name: string,
  payload: Request): Promise<Response> {
  if (dataMode() === "sample") {
    throw new Error("Imported source history is unavailable in sample mode.");
  }
  validateAdminCallableRequest(name, payload);
  const result = await httpsCallable<Request, Response>(functions, name)(payload);
  validateAdminCallableResponse(name, result.data);
  return result.data;
}

export const salesHistoryApi: SalesHistoryApi = {
  listRecords: (input) => call("adminListSalesImportHistory", input),
  listRows: (input) => call("adminListSalesImportHistoryRows", input),
};
