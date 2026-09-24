import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {validatePreviewEventOffersCallablePayload} from
  "../shared/generated/validators/previewEventOffersInput";
import {validateCommitEventOffersCallablePayload} from
  "../shared/generated/validators/commitEventOffersInput";
import {validateMutateEventOfferCallablePayload} from
  "../shared/generated/validators/mutateEventOfferInput";
import {validateGetEventOfferCallablePayload} from
  "../shared/generated/validators/getEventOfferInput";
import {validateListEventOffersCallablePayload} from
  "../shared/generated/validators/listEventOffersInput";
import {validateEventOfferPreviewCallableResponse} from
  "../shared/generated/validators/eventOfferPreviewOutput";
import {validateEventOfferCommitCallableResponse} from
  "../shared/generated/validators/eventOfferCommitOutput";
import {validateEventOfferMutationCallableResponse} from
  "../shared/generated/validators/eventOfferMutationOutput";
import {validateEventOfferDetailCallableResponse} from
  "../shared/generated/validators/eventOfferDetailOutput";
import {validateEventOfferListCallableResponse} from
  "../shared/generated/validators/eventOfferListOutput";
import {FirestoreEventOfferRepository} from "./eventOfferFirestoreRepository";
import {OfferDomainError} from "./eventOfferDomain";
import {
  commitEventOffers as commit, getEventOffer as detail,
  listEventOffers as list, mutateEventOffer as mutate,
  previewEventOffers as preview, OfferRepository,
} from "./eventOfferService";

export interface OfferCallableDependencies {
  firestore: () => FirebaseFirestore.Firestore;
  repository: (db: FirebaseFirestore.Firestore) => OfferRepository;
  checkRateLimit: typeof checkRateLimit;
  /** Release boundary; no request or environment flag may bypass it. */
  integrationReady: () => boolean;
}
const defaultDeps: OfferCallableDependencies = {
  firestore: () => admin.firestore(),
  repository: (db) => new FirestoreEventOfferRepository(db),
  checkRateLimit,
  integrationReady: () => false,
};

async function execute<T>(params: {
  uid: string;
  action: string;
  deps: OfferCallableDependencies;
  run: (repository: OfferRepository) => Promise<T>;
  validate: (value: unknown) => boolean;
}): Promise<T> {
  const {uid, action, deps, run, validate} = params;
  if (!deps.integrationReady()) {
    throw new HttpsError("failed-precondition",
      "Event offer integration is not ready.");
  }
  const db = deps.firestore();
  await deps.checkRateLimit(db, uid, action);
  try {
    const result = await run(deps.repository(db));
    if (!validate(result)) {
      throw new HttpsError("internal", "Invalid event offer result.");
    }
    return result;
  } catch (error) {
    if (error instanceof OfferDomainError) {
      const codes = {invalid: "invalid-argument", denied: "permission-denied",
        conflict: "failed-precondition"} as const;
      throw new HttpsError(codes[error.code], error.message,
        error.code === "conflict" ? {reason: "offer_review_required"} :
          undefined);
    }
    throw error;
  }
}

export async function previewEventOffersHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const uid = requireAuth(request);
  const input = validateCallableWithAjv(request,
    validatePreviewEventOffersCallablePayload);
  return execute({uid, action: "previewEventOffers", deps,
    run: (repository) => preview({repository, actor: {uid}, input}),
    validate: validateEventOfferPreviewCallableResponse});
}

export async function commitEventOffersHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const uid = requireAuth(request);
  const input = validateCallableWithAjv(request,
    validateCommitEventOffersCallablePayload);
  return execute({uid, action: "commitEventOffers", deps,
    run: (repository) => commit({repository, actor: {uid}, input}),
    validate: validateEventOfferCommitCallableResponse});
}

export async function mutateEventOfferHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const uid = requireAuth(request);
  const input = validateCallableWithAjv(request,
    validateMutateEventOfferCallablePayload);
  return execute({uid, action: "mutateEventOffer", deps,
    run: (repository) => mutate({repository, actor: {uid}, ...input}),
    validate: validateEventOfferMutationCallableResponse});
}

export async function getEventOfferHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const uid = requireAuth(request);
  const input = validateCallableWithAjv(request,
    validateGetEventOfferCallablePayload);
  return execute({uid, action: "getEventOffer", deps,
    run: (repository) => detail({repository, actor: {uid}, ...input}),
    validate: validateEventOfferDetailCallableResponse});
}

export async function listEventOffersHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const uid = requireAuth(request);
  const input = validateCallableWithAjv(request,
    validateListEventOffersCallablePayload);
  return execute({uid, action: "listEventOffers", deps,
    run: (repository) => list({repository, actor: {uid}, ...input}),
    validate: validateEventOfferListCallableResponse});
}

export const previewEventOffers = onCall(appCheckCallableOptions,
  (request) => previewEventOffersHandler(request));
export const commitEventOffers = onCall(appCheckCallableOptions,
  (request) => commitEventOffersHandler(request));
export const mutateEventOffer = onCall(appCheckCallableOptions,
  (request) => mutateEventOfferHandler(request));
export const getEventOffer = onCall(appCheckCallableOptions,
  (request) => getEventOfferHandler(request));
export const listEventOffers = onCall(appCheckCallableOptions,
  (request) => listEventOffersHandler(request));
