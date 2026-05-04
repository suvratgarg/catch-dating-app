import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {ZodType} from "zod";

export function validateCallable<T>(
  request: CallableRequest<unknown>,
  schema: ZodType<T>,
): T {
  const result = schema.safeParse(request.data);
  if (!result.success) {
    const message = result.error.issues
      .map((i) => `${i.path.join(".")}: ${i.message}`)
      .join("; ");
    throw new HttpsError("invalid-argument", message);
  }
  return result.data;
}
