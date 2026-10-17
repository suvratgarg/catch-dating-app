import fs from "node:fs";
import {fromRepo} from "../lib/repo_paths.mjs";
import {assertProdWriteAllowed} from "../lib/firebase_project.mjs";
import {parseFirebaseWebConfig} from "./storage_rules_firestore_iam.mjs";
import {hostingDomainTarget} from "./form_domain_hosting.mjs";

const actions = new Set(["status", "reserve", "verify", "provision", "prepare-origins", "activate", "revoke", "remove-origins"]);
const values = new Map([["--env", "environment"], ["--hostname", "hostname"],
  ["--action", "action"], ["--organizer-id", "organizerId"], ["--form-id", "formId"],
  ["--generation", "generation"], ["--requested-by-manager", "managerUid"], ["--site-key", "siteKey"]]);
const docId = (value) => typeof value === "string" && value.length > 0 && value.length <= 128 &&
  !/[\s/]/u.test(value) && value !== "." && value !== "..";

export function parseDomainOperatorArgs(argv) {
  const result = {action: "status", apply: false, allowProd: false};
  const seen = new Set();
  for (let index = 0; index < argv.length; index++) {
    const flag = argv[index];
    if (seen.has(flag)) throw new Error(`Repeated argument: ${flag}`);
    seen.add(flag);
    if (flag === "--apply") result.apply = true;
    else if (flag === "--allow-prod") result.allowProd = true;
    else if (values.has(flag)) {
      const value = argv[++index];
      if (!value || value.startsWith("--")) throw new Error(`A value is required for ${flag}.`);
      result[values.get(flag)] = value;
    } else throw new Error(`Unknown argument: ${flag}`);
  }
  if (!["dev", "staging", "prod"].includes(result.environment) || !actions.has(result.action) || !result.hostname) {
    throw new Error("Use an explicit --env dev|staging|prod, --hostname and supported --action.");
  }
  if (result.action === "status" && result.apply) throw new Error("Status cannot apply changes.");
  if (result.generation !== undefined) {
    if (!/^[1-9][0-9]*$/u.test(result.generation) || !Number.isSafeInteger(Number(result.generation))) {
      throw new Error("Generation must be a positive safe integer.");
    }
    result.generation = Number(result.generation);
  }
  if (result.action !== "status") {
    if (![result.organizerId, result.formId, result.managerUid].every(docId)) {
      throw new Error("Write plans require exact organizer/form IDs and --requested-by-manager UID.");
    }
    if (result.action !== "reserve" && result.generation === undefined) throw new Error("Use the current --generation from status.");
    if (result.action === "reserve" && result.generation !== undefined) throw new Error("Reserve creates a new generation; do not supply one.");
  }
  if (["prepare-origins", "activate", "remove-origins"].includes(result.action) && !result.siteKey) {
    throw new Error("Use the deployed website's public --site-key for origin preparation and activation.");
  }
  assertProdWriteAllowed({env: result.environment, apply: result.apply, allowProd: result.allowProd,
    action: "change a custom form domain"});
  return result;
}

/** Resolve only the checked-in marketing site, never an ambient/default project.
 * The public web app identifiers are deployment inputs, not live acceptance.
 */
export function configuredDomainTarget(args, {readFile = fs.readFileSync} = {}) {
  const rc = JSON.parse(readFile(fromRepo(".firebaserc"), "utf8"));
  const projectId = rc.projects?.[args.environment];
  const config = parseFirebaseWebConfig(readFile(fromRepo("firebase", args.environment,
    "web", "firebase-messaging-sw.js"), "utf8"));
  const sites = rc.targets?.[projectId]?.hosting?.marketing;
  if (config.projectId !== projectId || !Array.isArray(sites) || sites.length !== 1) {
    throw new Error("Configure exactly one marketing Hosting site for this environment before onboarding.");
  }
  const hosting = hostingDomainTarget({projectId, projectNumber: config.projectNumber,
    siteId: sites[0], hostname: args.hostname});
  return {...hosting, appId: config.appId, bucket: config.storageBucket,
    siteKey: args.siteKey, expectedCname: `${hosting.siteId}.web.app`};
}

/** The API binds both the numeric project identity and the marketing site.
 * This does not assert which website build is currently deployed there.
 */
export async function verifyDomainProviderTarget(input, {request}) {
  const target = hostingDomainTarget(input);
  const get = async (url) => {
    let response;
    try {
      response = await request({method: "GET", url, responseType: "json",
        timeout: 30_000, maxRedirects: 0, retry: false});
    } catch {throw new Error("Cannot verify the configured Firebase project/site.");}
    if (response?.status !== 200 || !response.data || typeof response.data !== "object") {
      throw new Error("Invalid Firebase project/site metadata.");
    }
    return response.data;
  };
  const project = await get(`https://cloudresourcemanager.googleapis.com/v3/projects/${target.projectId}`);
  if (project.name !== `projects/${target.projectNumber}` || project.projectId !== target.projectId || project.state !== "ACTIVE") {
    throw new Error("Configured Firebase project identity is not active or does not match.");
  }
  const site = await get(`https://firebasehosting.googleapis.com/v1beta1/${target.parent}`);
  if (![target.parent, `projects/${target.projectId}/sites/${target.siteId}`].includes(site.name) ||
      site.defaultUrl !== `https://${target.siteId}.web.app`) {
    throw new Error("Configured marketing Hosting site does not match.");
  }
  return {projectId: target.projectId, projectNumber: target.projectNumber, siteId: target.siteId};
}
