export type StatusTone = "" | "is-error" | "is-success";

export interface FormStatus {
  message: string;
  tone: StatusTone;
}
